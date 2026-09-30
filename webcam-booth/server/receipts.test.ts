import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, mkdir, readFile, writeFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { stripTypeScriptTypes } from 'node:module';
import { runInNewContext } from 'node:vm';
import { resolve, sep } from 'node:path';
import { spawn } from 'node:child_process';
import { Effect } from 'effect';
import { createGeneration } from './generation.ts';
const capture={id:'41234567-0123-4123-8123-012345678901',image:'data:image/png;base64,iVBORw0KGgo='};
test('actual success/failure charges persist and missing production ledger refuses startup',async()=>{
 const root=await mkdtemp(join(tmpdir(),'booth-receipts-'));
 try{
  const generate=Effect.runSync(createGeneration({root,ceilingCents:3,validate:async()=>{},provider:async()=>({image:'data:image/webp;base64,AAAA',run:'mock-receipt',costCents:2})}));
  await Effect.runPromise(generate(capture));
  const failed=Effect.runSync(createGeneration({root,ceilingCents:3,validate:async()=>{},provider:async()=>{throw {costCents:4}}}));
  await Effect.runPromise(Effect.either(failed({...capture,id:'51234567-0123-4123-8123-012345678901'})));
  const ledger=JSON.parse(await readFile(join(root,'ledger.json'),'utf8'));assert.equal(ledger.entries[capture.id].reservedCents,2);assert.equal(Object.values(ledger.entries).reduce((sum:number,e:any)=>sum+e.reservedCents,0),6);
  assert.equal((await Effect.runPromise(Effect.either(generate({...capture,id:'61234567-0123-4123-8123-012345678901'}))))._tag,'Left');
  const missing=Effect.runSync(createGeneration({root:join(root,'missing-live'),requireLedger:true,validate:async()=>{},provider:async()=>{throw Error('Must never dispatch')}}));
  assert.equal((await Effect.runPromise(Effect.either(missing(capture))))._tag,'Left');
  await writeFile(join(root,'ledger.json'),JSON.stringify({entries:{corrupt:{reservedCents:'NaN'}}}));
  const corrupt=Effect.runSync(createGeneration({root,requireLedger:true,validate:async()=>{},provider:async()=>{throw Error('Must never dispatch')}}));
  assert.equal((await Effect.runPromise(Effect.either(corrupt({...capture,id:'71234567-0123-4123-8123-012345678901'}))))._tag,'Left');
  const child=spawn(process.execPath,['--experimental-strip-types',join(import.meta.dirname,'server.ts')],{env:{...process.env,BOOTH_LEDGER_ROOT:join(root,'missing'),BOOTH_PORT:'0'},stdio:['ignore','ignore','pipe']});
  let message='';child.stderr.on('data',data=>message+=data);const code=await new Promise<number|null>(resolve=>child.once('exit',resolve));assert.notEqual(code,0);assert.match(message,/Spending ledger missing/);
 }finally{await rm(root,{recursive:true,force:true})}
});

test('failed post-payment ledger save keeps the paid lock until reconciliation',async()=>{
 const root=await mkdtemp(join(tmpdir(),'booth-save-failure-'));let calls=0;
 try{
  const generate=Effect.runSync(createGeneration({root,ceilingCents:3,validate:async()=>{},provider:async()=>{calls++;await mkdir(join(root,'ledger.json.tmp'));return {image:'data:image/webp;base64,AAAA',run:'mock-paid',costCents:4}}}));
  assert.equal((await Effect.runPromise(Effect.either(generate(capture))))._tag,'Left');
  assert.equal((await readFile(join(root,'paid.lock'))).length,0);
  await rm(join(root,'ledger.json.tmp'),{recursive:true});
  assert.equal((await Effect.runPromise(Effect.either(generate({...capture,id:'81234567-0123-4123-8123-012345678901'}))))._tag,'Left');assert.equal(calls,1);
 }finally{await rm(root,{recursive:true,force:true})}
});

test('known provider charges survive output, receipt and cleanup failures',async()=>{
 const source=await readFile(join(import.meta.dirname,'server.ts'),'utf8');
 const body=stripTypeScriptTypes(source.slice(source.indexOf('async function provider('),source.indexOf('\nconst generate=')));
 const run='run-aaaaaaaaaaaaaaaaaaaaaaaa',root='/unpaid-booth';
 for(const stage of ['output','receipt','cleanup','cleanup-note']){
  const provider=runInNewContext(body+';provider',{
   process:{env:{OPENROUTER_API_KEY:'unpaid-test'}},Buffer,join,resolve,sep,root,privateRoot:root+'/private',tool:'unpaid-tool',hash:()=> 'fixture-hash',mkdir:async()=>{},
   execute:async(_file:string,args:string[])=>({stdout:JSON.stringify(args[0]==='prepare'?{objective:'unpaid'}:args.includes('--execute')?{runId:run,cost:'0.040000',result:[{path:`${root}/artifacts/image-generation/runs/${run}/outputs/result.webp`,mediaType:'image/webp'}]}:{})}),
   readFile:async(path:string)=>{if(stage==='output'&&path.endsWith('result.webp'))throw Error('unpaid output failure');return Buffer.from('unpaid-fixture')},
   writeFile:async(path:string)=>{if((stage==='receipt'&&path.endsWith('-receipt.json'))||(stage==='cleanup-note'&&path.endsWith('ephemeral-cleanup.json')))throw Error('unpaid write failure')},
   rm:async(path:string)=>{if(stage==='cleanup'&&path.endsWith('/outputs'))throw Error('unpaid cleanup failure')}
  });
  await assert.rejects(provider(capture),(error:any)=>error.costCents===4,stage);
 }
});
