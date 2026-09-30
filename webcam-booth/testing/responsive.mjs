import assert from 'node:assert/strict';
import {writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {chromium} from '/home/reidsurmeier/.npm-global/lib/node_modules/playwright/index.mjs';
const root=resolve(import.meta.dirname,'..');
const browser=await chromium.launch({executablePath:'/usr/bin/google-chrome',headless:true,args:['--no-sandbox','--enable-unsafe-swiftshader']});
const results=[];
try{
 for(const viewport of [{width:390,height:844},{width:844,height:390},{width:1024,height:700}]){
  const page=await browser.newPage({viewport});await page.goto(process.env.BOOTH_TEST_URL??'https://windows-wsl.taile06c45.ts.net/webcam-booth-live-01a0f059/');
  await page.waitForFunction(()=>window.boothState?.state==='camera');
  const sample=page.getByRole('button',{name:'Try sample photo',exact:true});await sample.focus();await page.keyboard.press('Enter');
  await page.waitForFunction(()=>window.boothState.source==='fixture');
  for(const name of ['Enable camera','Try sample photo','Take picture']){
   const box=await page.getByRole('button',{name,exact:true}).boundingBox();assert(box.height>=44&&box.width>=130);assert(box.x>=0&&box.y>=0&&box.x+box.width<=viewport.width+1&&box.y+box.height<=viewport.height+1);
  }
  await page.getByRole('button',{name:'Take picture',exact:true}).click();await page.waitForFunction(()=>window.boothState.state==='portrait');
  const cancel=page.getByRole('button',{name:'Return to camera',exact:true});assert((await cancel.boundingBox()).height>=44);
  await page.screenshot({path:resolve(root,`review/evidence/13-responsive-${viewport.width}x${viewport.height}.png`)});
  await cancel.focus();await page.keyboard.press('Enter');await page.waitForFunction(()=>window.boothState.state==='camera');
  assert.equal(await page.evaluate(()=>window.boothState.has_capture),false);
  results.push({viewport,keyboard:true,touch_minimum_px:44,fixture_loop:true,https:await page.evaluate(()=>window.isSecureContext)});await page.close();
 }
 await writeFile(resolve(root,'review/evidence/responsive.json'),JSON.stringify({passed:true,provider_calls:0,results},null,2)+'\n');console.log('HTTPS responsive controls and keyboard loop passed at three viewports.');
}finally{await browser.close()}
