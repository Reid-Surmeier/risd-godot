import assert from 'node:assert/strict';
import {mkdir,writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {execFileSync} from 'node:child_process';
import {chromium} from '/home/reidsurmeier/.npm-global/lib/node_modules/playwright/index.mjs';
const evidence=process.env.BOOTH_PRESENTATION_EVIDENCE??'/tmp/booth-presentation';await mkdir(evidence,{recursive:true});
const browser=await chromium.launch({executablePath:'/usr/bin/google-chrome',headless:true,args:['--no-sandbox','--enable-unsafe-swiftshader']});
try{
 const page=await browser.newPage({viewport:{width:1024,height:800}});
 await page.addInitScript(()=>{navigator.mediaDevices.getUserMedia=async()=>{const c=document.createElement('canvas');c.width=640;c.height=480;const x=c.getContext('2d');x.fillStyle='#00bfcf';x.fillRect(0,0,640,480);window.__testCanvas=c;return c.captureStream(10)}});
 await page.route('**/api/portrait',r=>r.abort());
 await page.goto(process.env.BOOTH_TEST_URL??'https://homework.reidsurmeier.wtf/');await page.waitForFunction(()=>window.boothState?.state==='camera');
 await page.waitForFunction(()=>window.boothState.source==='camera');await page.waitForTimeout(500);
 const rect=await page.locator('#canvas').boundingBox();const scale=Math.min(rect.width/1024,rect.height/700);const origin={x:rect.x+(rect.width-1024*scale)/2,y:rect.y+(rect.height-700*scale)/2};
 const file=resolve(evidence,'camera.png');await page.screenshot({path:file});
 const pixels=JSON.parse(execFileSync('python3',['-c','from PIL import Image; import json,sys; im=Image.open(sys.argv[1]); points=json.loads(sys.argv[2]); print(json.dumps([im.getpixel(tuple(p))[:3] for p in points]))',file,JSON.stringify([[200,300],[820,300],[500,150],[700,300],[701,300],[700,306],[500,137]].map(([x,y])=>[Math.round(origin.x+x*scale),Math.round(origin.y+y*scale)]))],{encoding:'utf8'}));
 assert(pixels.slice(0,2).every(([r,g,b])=>r<50&&g>100&&b>100),`Camera must fill opening: ${JSON.stringify(pixels)}`);
 assert(pixels[2][0]>100,'Hat must cover camera');assert(pixels[6][0]>200,'White hat highlight must stay opaque');
 assert.deepEqual(pixels[3],pixels[4],'Nearest pixel blocks must be visible');assert(pixels[3].every((v,i)=>Math.abs(v-pixels[5][i])<3),'Uniform camera feed must have no CRT scanlines');
 assert.equal(await page.getByRole('button',{name:/sample|demo|Return to camera/i}).count(),0);assert.equal(await page.locator('#booth-controls').count(),0);
 const button=page.getByRole('button',{name:'Take picture',exact:true});const box=await button.boundingBox();assert(box.width>=44&&box.height>=44);assert((await button.locator('span').boundingBox()).width>=44,'Blue icon must remain visibly large');assert(Math.abs(box.x+box.width/2-(origin.x+515*scale))<3,'Blue shutter must match artwork');
 await page.mouse.move(0,0);await page.waitForTimeout(180);const inner=button.locator('span');const before=await inner.evaluate(e=>getComputedStyle(e).transform);await button.hover();await page.waitForTimeout(180);assert.notEqual(await inner.evaluate(e=>getComputedStyle(e).transform),before,'Blue button must animate');
 const hover=await inner.evaluate(e=>getComputedStyle(e).transform);await page.mouse.down();await page.waitForTimeout(180);assert.notEqual(await inner.evaluate(e=>getComputedStyle(e).transform),hover,'Blue shutter must depress');await page.mouse.move(0,0);await page.mouse.up();await page.emulateMedia({reducedMotion:'reduce'});assert.equal(await inner.evaluate(e=>getComputedStyle(e).transitionDuration),'0s');
 await page.locator('#booth-shutter span').evaluate(e=>e.style.backgroundImage='none');await page.mouse.move(0,0);await page.waitForTimeout(180);const fallback=resolve(evidence,'blue-frame-fallback.png');await page.screenshot({path:fallback});const blue=JSON.parse(execFileSync('python3',['-c','from PIL import Image;import json,sys; im=Image.open(sys.argv[1]);print(json.dumps(im.getpixel((int(sys.argv[2]),int(sys.argv[3])))[:3]))',fallback,String(Math.round(origin.x+505*scale)),String(Math.round(origin.y+560*scale))],{encoding:'utf8'}));assert(blue[2]>blue[0]+35&&blue[2]>blue[1]+15,'Original blue icon must stay in the frame if its HTML sprite fails');
 await writeFile(resolve(evidence,'presentation.json'),JSON.stringify({passed:true,pixels,box,provider_calls:0},null,2));console.log('Camera fills opening, hat overlays it, blue button animates, no demo controls.');
}finally{await browser.close()}
