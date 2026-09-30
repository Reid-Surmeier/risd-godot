import assert from 'node:assert/strict';
import {readFile,writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {execFileSync} from 'node:child_process';
import {chromium} from '/home/reidsurmeier/.npm-global/lib/node_modules/playwright/index.mjs';
const root=resolve(import.meta.dirname,'..');
const browser=await chromium.launch({executablePath:'/usr/bin/google-chrome',headless:true,args:['--no-sandbox','--use-fake-device-for-media-stream','--enable-unsafe-swiftshader']});
const results=[];const portrait='data:image/webp;base64,'+(await readFile(resolve(root,'assets/sample-portrait.webp'))).toString('base64');
try{
 for(const viewport of [{width:390,height:844},{width:844,height:390},{width:1024,height:700}]){
  const page=await browser.newPage({viewport,permissions:['camera']});await page.route('**/api/portrait',r=>r.fulfill({status:200,contentType:'application/json',body:JSON.stringify({image:portrait,run:'unpaid-responsive-check'})}));await page.goto(process.env.BOOTH_TEST_URL??'https://windows-wsl.taile06c45.ts.net/webcam-booth-live-01a0f059/');
  await page.waitForFunction(()=>window.boothState?.state==='camera');
  const enable=page.getByRole('button',{name:'Enable camera',exact:true});await enable.focus();await page.keyboard.press('Enter');
  await page.waitForFunction(()=>window.boothState.source==='camera');
  for(const name of ['Take picture']){
   const box=await page.getByRole('button',{name,exact:true}).boundingBox();assert(box.height>=44&&box.width>=44);assert(box.x>=0&&box.y>=0&&box.x+box.width<=viewport.width+1&&box.y+box.height<=viewport.height+1);
  }
  const screenshot=resolve(root,`review/evidence/25-responsive-camera-${viewport.width}x${viewport.height}.png`);await page.screenshot({path:screenshot});
  const icon=await page.locator('#booth-shutter span').boundingBox();assert(icon.width>=44&&icon.height>=44,'Blue icon itself must be at least44px, not only the hit target');
  const bluePixels=Number(execFileSync('python3',['-c','from PIL import Image;import sys,json;im=Image.open(sys.argv[1]).convert("RGB");b=json.loads(sys.argv[2]);im=im.crop((int(b["x"]),int(b["y"]),int(b["x"]+b["width"]),int(b["y"]+b["height"])));print(sum(1 for r,g,b in im.getdata() if b>r+35 and b>g+15))',screenshot,JSON.stringify(icon)],{encoding:'utf8'}));assert(bluePixels>250,'Original blue shutter must be visibly rendered');
  await page.getByRole('button',{name:'Take picture',exact:true}).click();await page.waitForFunction(()=>window.boothState.state==='portrait');
  const cancel=page.getByRole('button',{name:'Return to camera',exact:true});assert((await cancel.boundingBox()).height>=44);
  await page.screenshot({path:resolve(root,`review/evidence/13-responsive-${viewport.width}x${viewport.height}.png`)});
  await cancel.focus();await page.keyboard.press('Enter');await page.waitForFunction(()=>window.boothState.state==='camera');
  assert.equal(await page.evaluate(()=>window.boothState.has_capture),false);
  results.push({viewport,keyboard:true,touch_minimum_px:44,visible_blue_pixels:bluePixels,icon_width:icon.width,intercepted_camera_loop:true,https:await page.evaluate(()=>window.isSecureContext)});await page.close();
 }
 await writeFile(resolve(root,'review/evidence/responsive.json'),JSON.stringify({passed:true,provider_calls:0,results},null,2)+'\n');console.log('HTTPS responsive controls and keyboard loop passed at three viewports.');
}finally{await browser.close()}
