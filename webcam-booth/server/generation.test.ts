import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, readFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { Effect } from 'effect';
import { createGeneration } from './generation.ts';
const capture = {id:'01234567-0123-4123-8123-012345678901',image:'data:image/png;base64,iVBORw0KGgo='};
test('validation, concurrent duplicate reuse, reservation and uncertain failure', async () => {
 const root=await mkdtemp(join(tmpdir(),'booth-test-'));let calls=0;let release!:()=>void;
 const provider=async()=>{calls++;await new Promise<void>(r=>{release=r});return {image:'data:image/webp;base64,AAAA',run:'test-run'}};
 try {
  const generate=Effect.runSync(createGeneration({root,provider,validate:async()=>{}}));
  assert.equal((await Effect.runPromise(Effect.either(generate({...capture,image:'not-an-image'}))))._tag,'Left');
  const first=Effect.runPromise(generate(capture));await new Promise(r=>setTimeout(r,50));
  const duplicate=Effect.runPromise(generate(capture));
  const busy=await Effect.runPromise(Effect.either(generate({...capture,id:'11234567-0123-4123-8123-012345678901'})));
  assert.equal(busy._tag,'Left');release();assert.deepEqual(await first,await duplicate);assert.equal(calls,1);
  const ledger=JSON.parse(await readFile(join(root,'ledger.json'),'utf8'));assert.equal(ledger.entries[capture.id].reservedCents,1);
  const failed=Effect.runSync(createGeneration({root,provider:async()=>{throw Error('private provider details')},validate:async()=>{}}));
  const next={...capture,id:'21234567-0123-4123-8123-012345678901'};
  assert.equal((await Effect.runPromise(Effect.either(failed(next))))._tag,'Left');
  assert.equal((await Effect.runPromise(Effect.either(failed(next))))._tag,'Left');
  const capped=Effect.runSync(createGeneration({root,ceilingCents:1,provider,validate:async()=>{}}));
  assert.equal((await Effect.runPromise(Effect.either(capped({...capture,id:'31234567-0123-4123-8123-012345678901'}))))._tag,'Left');
 } finally {await rm(root,{recursive:true,force:true})}
});
