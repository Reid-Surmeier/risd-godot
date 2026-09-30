// Offline production HTTP-handler and browser-adapter check; no provider can run.
import assert from 'node:assert/strict';
import {mkdtemp, mkdir, readFile, writeFile, rm, symlink} from 'node:fs/promises';
import {resolve, join} from 'node:path';
import {spawn} from 'node:child_process';
import {once} from 'node:events';
import vm from 'node:vm';
const app=resolve(import.meta.dirname,'..');
const temporary=await mkdtemp(resolve(app,'../.booth-http-test-'));
let child;
try {
 await mkdir(join(temporary,'server'));await mkdir(join(temporary,'build/private'),{recursive:true});
 await writeFile(join(temporary,'build/private/ledger.json'),'{"entries":{}}');
 await symlink(join(app,'server/generation.ts'),join(temporary,'server/generation.ts'));
 let source=await readFile(join(app,'server/server.ts'),'utf8');
 source=source.replace(/^const generate=.*;$/m,`let calls=0; const generate=capture=>Effect.tryPromise(async()=>{await new Promise(r=>setTimeout(r,500));return {image:'data:image/png;base64,AAAA',run:'offline-'+(++calls)};});`);
 assert(!source.includes('const generate=Effect.runSync'),'Unpaid adapter must replace generation');await writeFile(join(temporary,'server/server.ts'),source);
 child=spawn(process.execPath,['--experimental-strip-types',join(temporary,'server/server.ts')],{env:{PATH:process.env.PATH,BOOTH_PORT:'18139'},stdio:['ignore','pipe','pipe']});
 await Promise.race([once(child.stdout,'data'),once(child,'exit').then(()=>{throw Error('Test server exited')})]);
 const base='http://127.0.0.1:18139';
 const post=async(path,body,origin=base)=>{const response=await fetch(base+path,{method:'POST',headers:{Origin:origin,'Content-Type':'application/json','Prefer':'respond-async'},body:JSON.stringify(body)});return {status:response.status,body:await response.json()}};
 const capture={id:'01234567-0123-4123-8123-012345678901',image:'data:image/png;base64,AAAA'};
 assert.equal((await post('/api/portrait',capture,'https://foreign.invalid')).status,403);
 const started=performance.now();assert.equal((await post('/api/portrait',capture)).status,202);assert(performance.now()-started<400,'Submission must return before delayed work');
 assert.equal((await post('/api/portrait',capture)).status,202);
 assert.equal((await post('/api/portrait',{...capture,image:'data:image/png;base64,BBBB'})).status,400);
 assert.equal((await post('/api/portrait/status',{id:capture.id})).status,202);
 assert.equal((await post('/api/portrait/status',{id:capture.id},'https://foreign.invalid')).status,403);
 await new Promise(r=>setTimeout(r,650));
 assert.equal((await post('/api/portrait/status',{id:capture.id})).body.run,'offline-1');
 assert.equal((await post('/api/portrait/status',{id:capture.id})).body.run,'offline-1');
 assert.equal((await post('/api/portrait/status',{id:'11234567-0123-4123-8123-012345678901'})).status,404);
 // Execute the real browser adapter against an unpaid pending -> ready response.
 let submissions=0,polls=0;
 const context={window:{addEventListener(){}},document:{baseURI:base+'/',createElement:()=>({getContext:()=>({})})},navigator:{},crypto:{randomUUID:()=>capture.id},URL,AbortController,setTimeout,clearTimeout,setInterval,clearInterval,performance,fetch:async(_url,options)=>{if(String(_url).endsWith('/status')){polls++;return {status:200,ok:true,json:async()=>({image:'fixture',run:'offline-browser'})}}submissions++;assert.equal(options.headers.Prefer,'respond-async');return {status:202,ok:true,json:async()=>({pending:true,progress:{completed:2,total:4}})}}};
 vm.runInNewContext(await readFile(join(app,'camera.js'),'utf8'),context);
 await context.window.booth.generate('fixture');assert.equal(JSON.parse(context.window.booth.generated()).run,'offline-browser');assert.equal(submissions,1);assert.equal(polls,1);
 console.log('passed: short pending requests, duplicate protection, same-origin polling, one browser submission');
}finally{if(child){child.kill();await once(child,'exit')}await rm(temporary,{recursive:true,force:true})}
