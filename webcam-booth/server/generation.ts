import { Effect } from 'effect';
import { mkdir, readFile, writeFile, rename, open, rm } from 'node:fs/promises';
import { join } from 'node:path';
import { createHash } from 'node:crypto';
import type { Capture, Portrait, Generation } from './interface.ts';
import type { GenerationError } from './errors.ts';
type Entry={hash:string;reservedCents:number;state:string;run?:string};
type Options={root:string;provider:(capture:Capture)=>Promise<Portrait>;validate:(capture:Capture)=>Promise<void>;ceilingCents?:number;requireLedger?:boolean};
const failure=(code:GenerationError['code'],message:string):GenerationError=>({code,message});
export const createGeneration=(options:Options):Effect.Effect<Generation> => Effect.sync(()=>{
 // ponytail: one owner session and one active provider request; add a queue only for a public launch.
 const requests=new Map<string,{hash:string;promise:Promise<Portrait>}>();let busy=false;
 const generate:Generation=capture=>Effect.tryPromise({try:async()=>{
  if(!/^[0-9a-f-]{36}$/.test(capture.id)||!/^data:image\/(png|jpeg);base64,[A-Za-z0-9+/]+=*$/.test(capture.image)||capture.image.length>2_000_000) throw failure('invalid','Capture must be a PNG or JPEG under 1.5 MB.');
  const hash=createHash('sha256').update(capture.image).digest('hex');const prior=requests.get(capture.id);
  if(prior){if(prior.hash!==hash)throw failure('invalid','Capture identity already used.');return prior.promise;}
  if(busy)throw failure('busy','Another portrait is being prepared.');
  busy=true;
  const promise=(async()=>{
   let locked=false;let releaseLock=true;
   try{
    await options.validate(capture);
    await mkdir(options.root,{recursive:true,mode:0o700});
    try{const lock=await open(join(options.root,'paid.lock'),'wx',0o600);await lock.close();locked=true;}catch{throw failure('busy','A paid operation is already reserved.');}
    const path=join(options.root,'ledger.json');let ledger:{entries:Record<string,Entry>};
    try{ledger=JSON.parse(await readFile(path,'utf8'));}catch(e){if((e as NodeJS.ErrnoException).code!=='ENOENT')throw e;if(options.requireLedger)throw failure('unavailable','Generation allowance ledger is missing.');ledger={entries:{}};}
    if(!ledger.entries||typeof ledger.entries!=='object'||Array.isArray(ledger.entries)||Object.values(ledger.entries).some(item=>!item||!Number.isSafeInteger(item.reservedCents)||item.reservedCents<1))throw failure('unavailable','Generation allowance ledger is invalid.');
    if(ledger.entries[capture.id])throw failure('uncertain','This capture was already submitted. Take a new picture deliberately.');
    const spent=Object.values(ledger.entries).reduce((sum,item)=>sum+item.reservedCents,0);
    if(spent+1>(options.ceilingCents??1000))throw failure('budget','The booth generation allowance is exhausted.');
    ledger.entries[capture.id]={hash,reservedCents:1,state:'reserved'};
    const save=async()=>{await writeFile(path+'.tmp',JSON.stringify(ledger,null,2)+'\n',{mode:0o600});await rename(path+'.tmp',path);};
    await save();releaseLock=false;
    const reconcile=(cost:unknown)=>{if(typeof cost==='number'&&Number.isSafeInteger(cost)&&cost>=0)ledger.entries[capture.id].reservedCents=Math.max(1,cost);};
    try{const portrait=await options.provider(capture);reconcile(portrait.costCents);ledger.entries[capture.id].state='received';ledger.entries[capture.id].run=portrait.run;await save();releaseLock=true;return portrait;}
    catch(error){if(error&&typeof error==='object'&&'costCents'in error)reconcile(error.costCents);ledger.entries[capture.id].state='uncertain';await save();releaseLock=true;throw failure('uncertain','Generation did not finish. Its reserved cost is retained; this capture will not be retried.');}
   }finally{if(locked&&releaseLock)await rm(join(options.root,'paid.lock'));busy=false;setTimeout(()=>requests.delete(capture.id),15_000).unref();}
  })();
  requests.set(capture.id,{hash,promise});return promise;
 },catch:e=> e&&typeof e==='object'&&'code'in e&&['invalid','busy','budget','uncertain','unavailable'].includes(String(e.code)) ? e as GenerationError : failure('unavailable','Generation is unavailable.')});
 return generate;
});
