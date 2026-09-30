import assert from 'node:assert/strict';
import {readFile,writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {createHash} from 'node:crypto';
import {chromium} from '/home/reidsurmeier/.npm-global/lib/node_modules/playwright/index.mjs';
const root=resolve(import.meta.dirname,'..');
const pins=JSON.parse(await readFile(resolve(root,'tracking/pins.json'),'utf8'));
for(const file of pins.assets)assert.equal(createHash('sha256').update(await readFile(resolve(root,'tracking',file.path))).digest('hex'),file.sha256);
assert.equal(createHash('sha256').update(await readFile(resolve(root,'tracking/face_landmarker.task'))).digest('hex'),pins.modelSha256);
const photo='data:image/png;base64,'+(await readFile(resolve(root,'assets/photo-fixture.png'))).toString('base64');
const portrait='data:image/webp;base64,'+(await readFile(resolve(root,'assets/sample-portrait.webp'))).toString('base64');
const browser=await chromium.launch({executablePath:'/usr/bin/google-chrome',headless:true,args:['--no-sandbox','--enable-unsafe-swiftshader']});
try{
 const page=await browser.newPage();await page.goto(process.env.BOOTH_TEST_URL??'http://127.0.0.1:8129/');
 const result=await page.evaluate(async({photo,portrait})=>{
  const worker=new Worker(new URL('tracking-worker.js',document.baseURI));
  const wait=()=>new Promise((resolve,reject)=>{const timeout=setTimeout(()=>reject(Error('worker timeout')),30000);worker.onmessage=({data})=>{clearTimeout(timeout);data.type==='unavailable'?reject(Error(data.error)):resolve(data)};worker.onerror=reject;});
  try{
   let pending=wait();worker.postMessage({type:'portrait',token:1,image:portrait,base:new URL('tracking/',document.baseURI).href});const ready=await pending;
   const outputs=[];
   for(const image of [photo,'blank',photo]){
    let bitmap;
    if(image==='blank'){const canvas=new OffscreenCanvas(640,480);const c=canvas.getContext('2d');c.fillStyle='white';c.fillRect(0,0,640,480);bitmap=canvas.transferToImageBitmap();}
    else bitmap=await createImageBitmap(await(await fetch(image)).blob());
    pending=wait();worker.postMessage({type:'frame',token:1,bitmap,timestamp:performance.now()},[bitmap]);outputs.push(await pending);
   }
   return {ready,outputs};
  }finally{worker.terminate()}
 },{photo,portrait});
 assert.deepEqual(result.outputs.map(x=>x.face),[true,false,true]);
 for(const item of result.outputs.filter(x=>x.face)){assert.equal(item.landmarks,478);for(const v of Object.values(item.values))assert(Number.isFinite(v)&&v>=0&&v<=1);}
 assert(result.ready.anchors.left[0]<result.ready.anchors.right[0]);
 await writeFile(resolve(root,'review/evidence/tracking.json'),JSON.stringify({passed:true,local_worker:true,pin:pins.version,modelSha256:pins.modelSha256,result},null,2)+'\n');
 console.log('Pinned worker: portrait anchors, photo → no-face → recovery passed.');
}finally{await browser.close()}
