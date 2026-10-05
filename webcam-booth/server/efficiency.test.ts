import assert from 'node:assert/strict';
import {test} from 'node:test';
import {readFile} from 'node:fs/promises';
import {stripTypeScriptTypes} from 'node:module';
import {runInNewContext} from 'node:vm';
import {join,resolve,sep} from 'node:path';

// Issue218: run production provider composition with unpaid tool/file adapters.
test('prepares once and executes once without a separate duplicate plan',async()=>{
 const source=await readFile(join(import.meta.dirname,'server.ts'),'utf8');
 const body=stripTypeScriptTypes(source.slice(source.indexOf('async function provider('),source.indexOf('\nconst generate=')));
 const root='/unpaid-efficiency',run='run-bbbbbbbbbbbbbbbbbbbbbbbb';const calls:string[][]=[];
 const provider=runInNewContext(body+';provider',{
  process:{env:{OPENROUTER_API_KEY:'unpaid-fixture'}},Buffer,join,resolve,sep,root,privateRoot:root+'/private',tool:'unpaid-tool',hash:()=> 'fixture-hash',mkdir:async()=>{},rm:async()=>{},writeFile:async()=>{},readFile:async()=>Buffer.from('fixture'),
  execute:async(file:string,args:string[])=>{
   if(file!=='unpaid-tool')return {stdout:''};calls.push(args);
   return {stdout:JSON.stringify(args[0]==='prepare'?{objective:'offline-objective'}:{runId:run,cost:'0.010000',result:[{path:root+'/artifacts/image-generation/runs/'+run+'/materialized/result.webp',mediaType:'image/webp'}]})};
  }
 });
 const portrait=await provider({id:'01234567-0123-4123-8123-012345678901',image:'data:image/png;base64,AAAA'});
 assert.equal(portrait.run,run);assert.equal(portrait.costCents,1);
 assert.equal(calls.length,2,'Only prepare and the validated execute command are needed');
 assert.equal(calls[0]![0],'prepare');assert(calls[0]!.includes('--budget'));
 assert.deepEqual(Array.from(calls[1]!),['image','--application',root,'--objective','offline-objective','--execute']);
});
