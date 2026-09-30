// Explicit one-request paid acceptance, never included in the unpaid baseline.
import assert from 'node:assert/strict';
import {readFile,writeFile} from 'node:fs/promises';
import {execFileSync} from 'node:child_process';
import {resolve} from 'node:path';
import {chromium} from '/home/reidsurmeier/.npm-global/lib/node_modules/playwright/index.mjs';
const home=resolve(import.meta.dirname,'..');
const jpeg=execFileSync('/usr/bin/python3',['-c','from PIL import Image;import sys,io; b=io.BytesIO();Image.open(sys.argv[1]).convert("RGB").resize((640,480)).save(b,format="JPEG",quality=85);sys.stdout.buffer.write(b.getvalue())',resolve(home,'assets/photo-fixture.png')]).toString('base64');
const receipt=resolve(home,'review/evidence/paid-loop.json');
try{await readFile(receipt);throw Error('Paid proof already recorded; never repeat automatically.')}catch(e){if(e.code!=='ENOENT')throw e;}
const browser=await chromium.launch({executablePath:'/usr/bin/google-chrome',headless:true,args:['--no-sandbox','--use-fake-device-for-media-stream','--enable-unsafe-swiftshader']});
try{
 const page=await browser.newPage({viewport:{width:1024,height:700},permissions:['camera']});
 let submissions=0;page.on('request',r=>{if(r.url().endsWith('/api/portrait')&&r.method()==='POST')submissions++;});
 await page.goto(process.env.BOOTH_TEST_URL??'http://127.0.0.1:8129/');
 await page.waitForFunction(()=>window.boothState?.state==='camera');await page.mouse.click(320,609);
 await page.waitForFunction(()=>window.boothState.source==='camera');
 // Physical hardware is unavailable: feed the declared source photo through the same capture bridge.
 await page.evaluate(jpeg=>{window.booth.frame=()=>jpeg},jpeg);
 await page.waitForTimeout(300);await page.mouse.click(690,609);
 await page.waitForFunction(()=>window.boothState.state==='loading');
 await page.screenshot({path:resolve(home,'review/evidence/09-paid-loading.png')});
 await page.waitForFunction(()=>window.boothState.state==='portrait',null,{timeout:150000});
 assert.equal(submissions,1);assert.equal(await page.evaluate(()=>window.boothState.fixture_generation),false);
 const generated=await page.evaluate(()=>JSON.parse(window.booth.generated()));assert.match(generated.run,/^run-/);
 await page.screenshot({path:resolve(home,'review/evidence/10-paid-portrait.png')});
 const started=Date.now();await page.waitForFunction(()=>window.boothState.state==='explosion');
 assert(Date.now()-started>9400);await page.waitForFunction(()=>window.boothState.state==='camera');
 assert.equal(await page.evaluate(()=>window.boothState.has_capture),false);
 await writeFile(receipt,JSON.stringify({passed:true,submissions,run:generated.run,source:'declared Figma fixture photo injected through real browser capture bridge',physical_webcam_tested:false,provider:'openrouter',model:'meta/muse-image',reserved_usd:0.01},null,2)+'\n');
 console.log('One real Muse capture→portrait→reset loop passed.');
}finally{await browser.close()}
