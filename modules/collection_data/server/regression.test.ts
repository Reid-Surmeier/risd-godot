import {test} from 'node:test';
import assert from 'node:assert/strict';
import {mkdtemp, readFile, rm, writeFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {spawn} from 'node:child_process';
import {once} from 'node:events';
import {createServer} from 'node:net';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {fileURLToPath} from 'node:url';
import {setTimeout as delay} from 'node:timers/promises';
import {Effect} from 'effect';
import {publish, search, parseQuery, image, type Store} from './adapter.ts';
import {normalize} from './ingest.ts';
const run = Effect.runPromise;
const corpus = JSON.parse(await readFile(new URL('../../../docs/evidence/collection-search/corpus.json', import.meta.url),'utf8'));
const store = (): Store => ({snapshots:new Map(),latest:'',upstream_status:'cached',now:Date.now,media:new Map()});
test('snapshot hash ignores object property order and result mutation', async()=>{
  const s=store(),a=await run(publish(s,corpus.records,corpus.coverage,corpus.fetched_at));
  const reversed=corpus.records.map((x:object)=>Object.fromEntries(Object.entries(x).reverse()));
  assert.equal(await run(publish(s,reversed,corpus.coverage,corpus.fetched_at)),a);
  const page=await run(search(s,await run(parseQuery(''))));page.items[0].title='mutated';
  assert.notEqual((await run(search(s,await run(parseQuery(''))))).items[0].title,'mutated');
});
test('verified painting manifests match committed bytes; official entity/category normalization',async()=>{
  const s=store(); await run(publish(s,corpus.records,corpus.coverage,corpus.fetched_at));
  const paintings=(await run(search(s,await run(parseQuery('category=Painting&has_image=true'))))).items;
  assert.equal(paintings.length,2);
  for(const record of paintings){
    const bytes=await readFile(new URL(`../../../docs/evidence/collection-search/images/${record.image.sha256}.jpg`,import.meta.url));
    assert.equal(createHash('sha256').update(bytes).digest('hex'),record.image.sha256);
    s.media.set(record.image.sha256,{bytes,mime:record.image.mime});
    assert.deepEqual((await run(image(s,record.image.sha256))).bytes,bytes);
  }
  const hash=paintings[0].image.sha256;s.media.set(hash,{bytes:Buffer.from('corrupt'),mime:'image/jpeg'});assert.equal((await run(Effect.either(image(s,hash))))._tag,'Left');
  const raw=JSON.parse(await readFile(new URL('../../../docs/evidence/collection-search/official-object-1377691.json',import.meta.url),'utf8'));
  raw[0].title='A &amp; B &#233;';raw[0].type=['pAiNtInGs'];
  const normalized=await run(normalize(raw,corpus.fetched_at));assert.equal(normalized[0].title,'A & B é');assert.equal(normalized[0].category,'Painting');assert.equal(normalized[0].rights.status,'unknown');
});
test('static entry, retained GLBs and Collection route work; missing files are 404', async()=>{
  const root=await mkdtemp(join(tmpdir(),'risd-static-'));await writeFile(join(root,'index.html'),'working');await writeFile(join(root,'scan.glb'),Buffer.from('glTF'));
  const reservation=createServer();reservation.listen(0,'127.0.0.1');await once(reservation,'listening');
  const address=reservation.address();assert.ok(address && typeof address==='object');const port=address.port;
  reservation.close();await once(reservation,'close');
  const child=spawn(process.execPath,['--experimental-strip-types',fileURLToPath(new URL('./server.ts',import.meta.url)),root],{
    env:{...process.env,RISD_SEARCH_PORT:String(port)},stdio:['ignore','pipe','pipe']});
  let output='';const ready=new Promise<void>((resolve,reject)=>{
    child.stdout.on('data',data=>{output+=data;if(output.includes('server ready'))resolve();});
    child.stderr.on('data',data=>{output+=data;});
    child.once('exit',code=>reject(Error(`server exited ${code}: ${output}`)));
  });
  try{
    await Promise.race([ready,delay(5000).then(()=>{throw Error(`server timeout: ${output}`);})]);
    const base=`http://127.0.0.1:${port}`;
    const entry=await fetch(base+'/');assert.equal(entry.status,200);assert.equal(await entry.text(),'working');
    const scan=await fetch(base+'/scan.glb');assert.equal(scan.status,200);assert.equal(scan.headers.get('content-type'),'model/gltf-binary');assert.deepEqual(Buffer.from(await scan.arrayBuffer()),Buffer.from('glTF'));
    const searchReply=await fetch(base+'/api/collection/search?has_image=true');assert.equal(searchReply.status,200);assert.equal((await searchReply.json()).ok,true);
    const missing=await fetch(base+'/favicon.ico');assert.equal(missing.status,404);
    assert.equal((await missing.json()).error.detail,'Not found');
  }finally{
    child.kill();if(child.exitCode===null)await once(child,'exit');await rm(root,{recursive:true});
  }
});
