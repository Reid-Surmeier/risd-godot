import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
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
