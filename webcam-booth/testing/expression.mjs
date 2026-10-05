import assert from 'node:assert/strict';
import {readFile,writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {execFileSync} from 'node:child_process';
import {chromium} from '/home/reidsurmeier/.npm-global/lib/node_modules/playwright/index.mjs';
const root=resolve(import.meta.dirname,'..');const evidence=resolve(root,'review/evidence');
const photo='data:image/png;base64,'+(await readFile(resolve(root,'assets/photo-fixture.png'))).toString('base64');
const portrait='data:image/webp;base64,'+(await readFile(resolve(root,'assets/sample-portrait.webp'))).toString('base64');
const browser=await chromium.launch({executablePath:'/usr/bin/google-chrome',headless:true,args:['--no-sandbox','--use-fake-device-for-media-stream','--enable-unsafe-swiftshader']});
try{
 const page=await browser.newPage({viewport:{width:1024,height:700},permissions:['camera']});
 await page.addInitScript(photo=>{
  const original=navigator.mediaDevices.getUserMedia.bind(navigator.mediaDevices);
  navigator.mediaDevices.getUserMedia=async options=>{
   const stream=await original(options);stream.getTracks().forEach(t=>t.stop());
   const canvas=document.createElement('canvas');canvas.width=640;canvas.height=480;const context=canvas.getContext('2d');
   const image=new Image();image.src=photo;await image.decode();context.drawImage(image,0,0,640,480);window.__trackingCanvas=canvas;
   return canvas.captureStream(10);
  };
 },photo);
 await page.route('**/api/portrait',route=>route.fulfill({status:200,contentType:'application/json',body:JSON.stringify({image:portrait,run:'unpaid-expression-acceptance'})}));
 await page.goto(process.env.BOOTH_TEST_URL??'http://127.0.0.1:8129/');
 await page.waitForFunction(()=>window.boothState?.state==='camera');
 await page.waitForFunction(()=>window.boothState.source==='camera');await page.getByRole('button',{name:'Take picture',exact:true}).click();
 await page.waitForFunction(()=>window.boothState.state==='portrait');
 await page.waitForFunction(()=>JSON.parse(window.booth.tracking()).face,null,{timeout:20000});
 const measured=await page.evaluate(()=>JSON.parse(window.booth.tracking()));assert.equal(measured.landmarks,478);
 await page.screenshot({path:resolve(evidence,'11-expression-neutral.png')});
 await page.evaluate(()=>{
  window.__originalTracking=window.booth.tracking;const measured=JSON.parse(window.booth.tracking());
  window.booth.tracking=()=>JSON.stringify({...measured,face:true,values:{blinkL:0.9,blinkR:0.9,smile:0.8,jaw:0.7},pose:{x:0,y:0,angle:0}});
 });
 await page.waitForFunction(()=>window.boothState.expression[0]>.8&&window.boothState.expression[2]>.7);
 await page.screenshot({path:resolve(evidence,'12-expression-blink-smile.png')});
 const box=await page.locator('#canvas').boundingBox();const scale=Math.min(box.width/1024,box.height/700);
 const region=(x0,y0,x1,y1)=>[Math.round(box.x+(box.width-1024*scale)/2+x0*scale),Math.round(box.y+(box.height-700*scale)/2+y0*scale),Math.round(box.x+(box.width-1024*scale)/2+x1*scale),Math.round(box.y+(box.height-700*scale)/2+y1*scale)];
 const regions={eyes:region(440,265,570,315),mouth:region(450,330,570,405)};
 const changed=JSON.parse(execFileSync('/usr/bin/python3',['-c','from PIL import Image;import numpy as np,sys,json;a=np.array(Image.open(sys.argv[1]).convert("RGB")).astype(int);b=np.array(Image.open(sys.argv[2]).convert("RGB")).astype(int);d=np.max(np.abs(a-b),axis=2);r=json.loads(sys.argv[3]); count=lambda p:int(np.count_nonzero(d[p[1]:p[3],p[0]:p[2]]>12));print(json.dumps({"eye_pixels":count(r["eyes"]),"mouth_pixels":count(r["mouth"])}))',resolve(evidence,'11-expression-neutral.png'),resolve(evidence,'12-expression-blink-smile.png'),JSON.stringify(regions)],{encoding:'utf8'}));
 assert(changed.eye_pixels>100&&changed.mouth_pixels>100);
 await page.evaluate(()=>{window.booth.tracking=window.__originalTracking;const c=window.__trackingCanvas.getContext('2d');c.fillStyle='white';c.fillRect(0,0,640,480);});
 await page.waitForFunction(()=>!JSON.parse(window.booth.tracking()).face&&window.boothState.expression.every(v=>v<.05));
 await page.keyboard.press('Escape');await page.waitForFunction(()=>window.boothState.state==='camera');
 assert.equal(await page.evaluate(()=>JSON.parse(window.booth.tracking()).mode),'idle');
 await page.waitForTimeout(700);assert.equal(await page.evaluate(()=>window.boothState.state),'camera');
 await writeFile(resolve(evidence,'expression.json'),JSON.stringify({passed:true,provider_calls:0,physical_webcam_tested:false,source:'fixture canvas through real browser video stream',live_worker_measurement:measured,simulated_expression_geometry:changed,observed_regions:regions,no_face_neutral:true,reset_stops_worker:true,limit:'bounded2D UV deformation; no3D reconstruction or new teeth/eyelids'},null,2)+'\n');
 console.log('Live video worker → Godot anchors/deformation, no-face and reset checks passed.');
}finally{await browser.close()}
