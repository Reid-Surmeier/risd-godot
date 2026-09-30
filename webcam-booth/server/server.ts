import { createServer } from 'node:http';
import { readFile, writeFile, mkdir, rm, stat, readdir } from 'node:fs/promises';
import { resolve, join, extname, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { promisify } from 'node:util';
import { execFile, spawn } from 'node:child_process';
import { createHash } from 'node:crypto';
import { Effect } from 'effect';
import { createGeneration } from './generation.ts';
import type { Capture, Portrait } from './interface.ts';
const execute=promisify(execFile);
const root=resolve(fileURLToPath(new URL('../',import.meta.url)));
const tool='/home/reidsurmeier/Image-generation-pipline/bin/image-pipeline';
const privateRoot=process.env.BOOTH_LEDGER_ROOT??join(root,'build/private');
try{await readFile(join(privateRoot,'ledger.json'),'utf8')}catch{throw Error('Spending ledger missing; restore recorded reservations before serving generation.')}
const hash=(data:Buffer|string)=>createHash('sha256').update(data).digest('hex');
async function validate(capture:Capture){
 const bytes=Buffer.from(capture.image.split(',')[1],'base64');
 await new Promise<void>((resolve,reject)=>{
  const child=spawn('/usr/bin/python3',['-c','import sys,io; from PIL import Image; i=Image.open(io.BytesIO(sys.stdin.buffer.read())); assert i.format in ("PNG","JPEG") and 64<=i.width<=2048 and 64<=i.height<=2048; i.verify()'],{stdio:['pipe','ignore','ignore']});
  child.once('error',reject);child.once('exit',code=>code===0?resolve():reject({code:'invalid',message:'The capture is not a valid supported image.'}));child.stdin.on('error',()=>{});child.stdin.end(bytes);
 });
}
async function provider(capture:Capture,onPrepared:()=>void=()=>{}):Promise<Portrait>{
 if(!process.env.OPENROUTER_API_KEY)throw Error('No server credential');
 const relative=`build/private/captures/${capture.id}`;const home=join(root,relative);
 await mkdir(home,{recursive:true,mode:0o700});
 let recordedRun:string|undefined;let recordedCostCents:number|undefined;
 try{
 try{
  // Canonical PNG input is transient and excluded from the Web export and Git.
  const encoded=Buffer.from(capture.image.split(',')[1],'base64');await writeFile(join(home,'input'),encoded,{mode:0o600});
  await execute('/usr/bin/python3',['-c','from PIL import Image; import sys; Image.open(sys.argv[1]).convert("RGB").save(sys.argv[2])',join(home,'input'),join(home,'subject.png')]);
  const subject=await readFile(join(home,'subject.png'));
  const prompt='Create one recognizable portrait of the person in image one. Image two supplies only early Nintendo 3D low-poly flat facets, pastel blue gradient and yellow spiral sun. Preserve the photographed identity, hairstyle, skin tone, clothing, neck and shoulders reaching the bottom edge. Face the camera. No Wario hat, goggles, moustache, slapping hand, desk, text, watermark, frame, glove, bomb or fuse. Single finished square portrait.\n';
  await writeFile(join(home,'prompt.txt'),prompt);
  const style=await readFile(join(root,'assets/portrait-fixture.png'));
  await writeFile(join(home,'plan.json'),JSON.stringify({attempts:[{id:'001',prompt:`${relative}/prompt.txt`,promptSha256:hash(prompt),size:'1024x1024',inputs:[{path:`${relative}/subject.png`,sha256:hash(subject)},{path:'assets/portrait-fixture.png',sha256:hash(style)}]}]}));
  await writeFile(join(home,'recipe.json'),JSON.stringify({procedure:'edit',plan:`${relative}/plan.json`,attempt:'001'}));
  const call=async(args:string[])=>JSON.parse((await execute(tool,args,{maxBuffer:4_000_000,timeout:660_000})).stdout);
  const prepared=await call(['prepare','--application',root,'--recipe',`${relative}/recipe.json`,'--unit-cost','0.01','--budget','0.01']);
  onPrepared();
  const cents=(cost:unknown)=>typeof cost==='string'&&/^\d+(?:\.\d+)?$/.test(cost)?Math.ceil(Number(cost)*100):undefined;
  let result;
  try{result=await call(['image','--application',root,'--objective',prepared.objective,'--execute']);}
  catch(error){let costCents;try{const failed=JSON.parse((error as {stdout:string}).stdout);costCents=cents(failed.cost);recordedCostCents=costCents;recordedRun=failed.runId;}catch{};throw {costCents};}
  recordedRun=result.runId;recordedCostCents=cents(result.cost);
  if(result.result?.length!==1||!result.runId)throw {costCents:cents(result.cost)};
  const output=resolve(result.result[0].path);
  if(!output.startsWith(join(root,'artifacts/image-generation/runs')+sep))throw Error('Output outside recorded run');
  const image=await readFile(output);
  // The immutable receipt keeps source hashes/cost, while capture/result payloads are ephemeral.
  await writeFile(join(privateRoot,`${capture.id}-receipt.json`),JSON.stringify({run:result.runId,cost:result.cost,spendState:result.spendState,inputSha256:hash(subject),outputSha256:hash(image),model:'meta/muse-image',provider:'openrouter',count:1,at:new Date().toISOString()}));
  const portrait={image:`data:${result.result[0].mediaType};base64,${image.toString('base64')}`,run:result.runId,costCents:cents(result.cost)};
  return portrait;
 }finally{
  await rm(home,{recursive:true,force:true});
  if(recordedRun&&/^run-[a-f0-9]{24}$/.test(recordedRun)){
   // Preserve immutable money/hash records while deleting ephemeral portrait payloads, even on failure.
   const runRoot=join(root,'artifacts/image-generation/runs',recordedRun);
   for(const file of ['provider-response.json','outputs','materialized'])await rm(join(runRoot,file),{recursive:true,force:true});
   await writeFile(join(runRoot,'ephemeral-cleanup.json'),JSON.stringify({run:recordedRun,deletedPayloads:['provider-response.json','outputs','materialized'],retained:'state/request/events carry hashes and cost; no image bytes',at:new Date().toISOString()}));
  }
 }
 }catch{throw {costCents:recordedCostCents};}
}
const generate=Effect.runSync(createGeneration({root:privateRoot,provider:capture=>provider(capture,()=>{const job=jobs.get(capture.id);if(job)job.completed=1;}),validate,requireLedger:true}));
type Outcome={_tag:'Left';left:import('./errors.ts').GenerationError}|{_tag:'Right';right:Portrait};
type Job={hash:string;outcome?:Outcome;delivered?:boolean;completed:number;runsBefore:Set<string>;run?:string};
const jobs=new Map<string,Job>();
const runsRoot=join(root,'artifacts/image-generation/runs');
async function progress(id:string,job:Job){
 try{
  if(!job.run){
   for(const run of await readdir(runsRoot)){
    if(job.runsBefore.has(run)||!/^run-[a-f0-9]{24}$/.test(run))continue;
    const request=JSON.parse(await readFile(join(runsRoot,run,'request.json'),'utf8'));
    if(Array.isArray(request.references)&&request.references.some((ref:{applicationPath?:unknown})=>ref?.applicationPath===`build/private/captures/${id}/subject.png`)){job.run=run;break;}
   }
  }
  if(job.run){
   const state=JSON.parse(await readFile(join(runsRoot,job.run,'state.json'),'utf8'));
   if(state.runId===job.run){
    if(state.phase==='submission_may_have_started')job.completed=Math.max(job.completed,2);
    if(['provider_evidence_received','generated_outputs_received','awaiting_donor_choice','donor_selected','assembly_completed','verified_candidate'].includes(state.phase))job.completed=Math.max(job.completed,3);
   }
  }
 }catch{} // Optional UI telemetry never changes generation or spending; retry incomplete file writes next poll.
 return {completed:job.completed,total:4};
}
const mime:Record<string,string>={'.html':'text/html','.js':'text/javascript','.wasm':'application/wasm','.pck':'application/octet-stream','.png':'image/png','.webp':'image/webp','.json':'application/json','.mp4':'video/mp4','.task':'application/octet-stream'};
const server=createServer(async(request,response)=>{
 const send=(status:number,data:unknown)=>{response.writeHead(status,{'Content-Type':'application/json','Cache-Control':'no-store'});response.end(JSON.stringify(data));};
 try{
  const path=new URL(request.url??'/', 'http://booth.invalid').pathname;
  if((path==='/api/portrait'||path==='/api/portrait/status')&&request.method==='POST'){
   const origin=request.headers.origin;
   const forwarded=request.headers['x-forwarded-host'];const host=typeof forwarded==='string'?forwarded:request.headers.host;
   if(!origin||new URL(origin).host!==host){send(403,{error:'Same-origin request required.'});return;}
   let length=0;const chunks:Buffer[]=[];
   for await(const chunk of request){length+=chunk.length;if(length>2_000_100){send(413,{error:'Capture too large.'});return;}chunks.push(chunk);}
   if(path==='/api/portrait/status'){
    let id;try{id=JSON.parse(Buffer.concat(chunks).toString('utf8')).id;}catch{send(400,{error:'Invalid capture.'});return;}
    const job=typeof id==='string'?jobs.get(id):undefined;
    if(!job){send(404,{error:'Capture result is unavailable. Take a new picture deliberately.'});return;}
    if(!job.outcome){send(202,{pending:true,progress:await progress(id,job)});return;}
    if(!job.delivered){job.delivered=true;setTimeout(()=>{if(jobs.get(id)===job)jobs.delete(id)},15_000).unref();}
    const outcome=job.outcome;
    if(outcome._tag==='Left'){send(outcome.left.code==='invalid'?400:outcome.left.code==='busy'?409:503,{error:outcome.left.message,code:outcome.left.code});return;}
    send(200,outcome.right);return;
   }
   let capture:Capture;try{capture=JSON.parse(Buffer.concat(chunks).toString('utf8'));if(!capture||typeof capture.id!=='string'||typeof capture.image!=='string')throw Error();}catch{send(400,{error:'Invalid capture.'});return;}
   if(request.headers.prefer==='respond-async'){
    if(!/^[0-9a-f-]{36}$/.test(capture.id)||capture.image.length>2_000_000){send(400,{error:'Invalid capture.'});return;}
    const captureHash=hash(capture.image);const prior=jobs.get(capture.id);
    if(prior){send(prior.hash===captureHash?202:400,prior.hash===captureHash?{pending:true,progress:await progress(capture.id,prior)}:{error:'Capture identity already used.'});return;}
    if([...jobs.values()].some(job=>!job.outcome)){send(409,{error:'Another portrait is being prepared.'});return;}
    const job:Job={hash:captureHash,completed:0,runsBefore:new Set()};jobs.set(capture.id,job);
    job.runsBefore=new Set(await readdir(runsRoot).catch(()=>[]));
    void Effect.runPromise(Effect.either(generate(capture))).then(outcome=>{job.outcome=outcome;setTimeout(()=>{if(jobs.get(capture.id)===job)jobs.delete(capture.id)},60_000).unref();});
    send(202,{pending:true,progress:await progress(capture.id,job)});return;
   }
   const outcome=await Effect.runPromise(Effect.either(generate(capture)));
   if(outcome._tag==='Left'){send(outcome.left.code==='invalid'?400:outcome.left.code==='busy'?409:503,{error:outcome.left.message,code:outcome.left.code});return;}
   send(200,outcome.right);return;
  }
  if(request.method!=='GET'&&request.method!=='HEAD'){send(405,{error:'Method not supported.'});return;}
  const publicRoot=join(root,'build/web');const file=resolve(publicRoot,'.'+decodeURIComponent(path==='/'?'/index.html':path));
  if(!file.startsWith(publicRoot+sep)){send(403,{error:'Unavailable.'});return;}
  const info=await stat(file);if(!info.isFile()){send(404,{error:'Unavailable.'});return;}
  response.writeHead(200,{'Content-Type':mime[extname(file)]??'application/octet-stream','Cache-Control':'no-store','X-Content-Type-Options':'nosniff'});
  response.end(request.method==='HEAD'?undefined:await readFile(file));
 }catch{if(!response.headersSent)send(400,{error:'Request unavailable.'});else response.end();}
});
server.requestTimeout=700_000;
server.listen(Number(process.env.BOOTH_PORT??8129),'127.0.0.1',()=>console.log('Booth adapter listening; provider key stays in process environment.'));
