import assert from 'node:assert/strict';
import {readFile,mkdir,writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {chromium} from '/home/reidsurmeier/.npm-global/lib/node_modules/playwright/index.mjs';
const app=resolve(import.meta.dirname,'..'),evidence=process.env.BOOTH_CLEAN_EVIDENCE??'/tmp/booth-clean';await mkdir(evidence,{recursive:true});
const image='data:image/webp;base64,'+(await readFile(resolve(app,'assets/sample-portrait.webp'))).toString('base64');
const browser=await chromium.launch({executablePath:'/usr/bin/google-chrome',headless:true,args:['--no-sandbox','--use-fake-device-for-media-stream','--enable-unsafe-swiftshader']});
try{
 const page=await browser.newPage({viewport:{width:1024,height:800},permissions:['camera']});
 await page.addInitScript(()=>{window.__cameraCalls=0;const original=navigator.mediaDevices.getUserMedia.bind(navigator.mediaDevices);navigator.mediaDevices.getUserMedia=async options=>{window.__cameraCalls++;return original(options)}});
 let completed=1,ready=false,submissions=0,polls=0;const reply=r=>r.fulfill({status:ready?200:202,contentType:'application/json',body:JSON.stringify(ready?{image,run:'unpaid-clean-flow'}:{pending:true,progress:{completed,total:4}})});
 await page.route('**/api/portrait',r=>{submissions++;return reply(r)});await page.route('**/api/portrait/status',r=>{polls++;return reply(r)});
 await page.goto(process.env.BOOTH_TEST_URL??'https://homework.reidsurmeier.wtf/');await page.waitForFunction(()=>window.boothState?.state==='camera');
 assert.equal(await page.evaluate(()=>window.__cameraCalls),1,'Request camera automatically once on page load');
 await page.waitForFunction(()=>window.boothState.source==='camera');assert.equal(await page.locator('#booth-controls').count(),0,'Remove visible footer copy');assert.equal(await page.getByRole('button',{name:'Return to camera',exact:true}).count(),0);
 await page.screenshot({path:resolve(evidence,'camera.png')});await page.getByRole('button',{name:'Take picture',exact:true}).click();await page.waitForFunction(()=>window.boothState.state==='loading'&&window.boothState.loading_completed===1);
 await page.waitForTimeout(5200);assert.equal(await page.evaluate(()=>window.boothState.loading_completed),1,'No timer-driven fake progress after4seconds');assert.equal(await page.evaluate(()=>window.boothState.state),'loading');await page.screenshot({path:resolve(evidence,'loading-prepared.png')});
 completed=2;await page.waitForFunction(()=>window.boothState.loading_completed===2);await page.screenshot({path:resolve(evidence,'loading-generation.png')});
 completed=3;await page.waitForFunction(()=>window.boothState.loading_completed===3);await page.screenshot({path:resolve(evidence,'loading-processing.png')});
 ready=true;await page.waitForFunction(()=>window.boothState.state==='portrait');await page.screenshot({path:resolve(evidence,'portrait.png')});await page.waitForFunction(()=>window.boothState.state==='explosion',null,{timeout:15000});await page.waitForFunction(()=>window.boothState.state==='camera',null,{timeout:5000});
 assert.equal(await page.evaluate(()=>window.__cameraCalls),1);assert.equal(submissions,1);assert.equal(await page.evaluate(()=>window.boothState.has_capture),false);
 ready=false;completed=1;await page.getByRole('button',{name:'Take picture',exact:true}).click();await page.waitForFunction(()=>window.boothState.state==='loading');await page.keyboard.press('Escape');await page.waitForFunction(()=>window.boothState.state==='camera');ready=true;await page.waitForTimeout(1600);assert.equal(await page.evaluate(()=>window.boothState.state),'camera','Late completion must not revive canceled portrait');
 const result={passed:true,automatic_camera_requests:1,stage_hold_ms:5200,actual_stages:[1,2,3],full_video_loop:true,escape_cancellation:true,provider_calls:0,submissions,polls,physical_webcam_tested:false};await writeFile(resolve(evidence,'clean-flow.json'),JSON.stringify(result,null,2));console.log(JSON.stringify(result));
}finally{await browser.close()}
