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
test('verified-image filter and manifest bytes; official entity/category normalization',async()=>{
  const s=store(),record=structuredClone(corpus.records[0]);
  // Fixture transport bytes only: this is not painting-ingestion evidence.
  const bytes=Buffer.from('fixture bytes'),sha256=createHash('sha256').update(bytes).digest('hex');
  record.image={id:'fixture',source_url:'https://risdmuseum.cdn.picturepark.com/v/fixture/',evidence_url:record.source_url,sha256,mime:'image/jpeg',width:1,height:1,verified_at:corpus.fetched_at,rights:{status:'public_domain',evidence_url:record.source_url,observed_at:corpus.fetched_at}};
  await run(publish(s,[record,...corpus.records.slice(1)],corpus.coverage,corpus.fetched_at));
  assert.equal((await run(search(s,await run(parseQuery('has_image=true'))))).total,1);
  s.media.set(sha256,{bytes,mime:'image/jpeg'});assert.deepEqual((await run(image(s,sha256))).bytes,bytes);
  s.media.set(sha256,{bytes:Buffer.from('corrupt'),mime:'image/jpeg'});assert.equal((await run(Effect.either(image(s,sha256))))._tag,'Left');
  const raw=JSON.parse(await readFile(new URL('../../../docs/evidence/collection-search/official-object-1377691.json',import.meta.url),'utf8'));
  raw[0].title='A &amp; B &#233;';raw[0].type=['pAiNtInGs'];
  const normalized=await run(normalize(raw,corpus.fetched_at));assert.equal(normalized[0].title,'A & B é');assert.equal(normalized[0].category,'Painting');assert.equal(normalized[0].rights.status,'unknown');
});
