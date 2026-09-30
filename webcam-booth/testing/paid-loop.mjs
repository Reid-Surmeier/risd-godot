// Explicit one-request paid acceptance, never included in the unpaid baseline.
import assert from 'node:assert/strict';
import {readFile,writeFile} from 'node:fs/promises';
import {execFileSync} from 'node:child_process';
import {resolve} from 'node:path';
import {chromium} from '/home/reidsurmeier/.npm-global/lib/node_modules/playwright/index.mjs';
const home=resolve(import.meta.dirname,'..');
const jpeg=execFileSync('/usr/bin/python3',['-c','from PIL import Image;import sys,io; b=io.BytesIO();Image.open(sys.argv[1]).convert("RGB").resize((320,240)).save(b,format="JPEG",quality=85);sys.stdout.buffer.write(b.getvalue())',resolve(home,'assets/photo-fixture.png')]).toString('base64');
const tag=process.env.BOOTH_PAID_PROOF??'paid-loop';if(!/^(paid-loop|final-loop|final-loop-after-clock-fix|final-loop-verified-source)$/.test(tag))throw Error('Unknown paid proof slot');
const expected=execFileSync('/usr/bin/python3',['-c','from PIL import Image;import io,sys;print(Image.open(io.BytesIO(sys.stdin.buffer.read())).tobytes().hex())'],{input:Buffer.from(jpeg,'base64')}).toString().trim();
const receipt=resolve(home,`review/evidence/${tag}.json`);
const attempt=resolve(home,`review/evidence/${tag}-attempt.json`);
try{await readFile(receipt);throw Error('Paid proof already recorded; never repeat automatically.')}catch(e){if(e.code!=='ENOENT')throw e;}
const browser=await chromium.launch({executablePath:'/usr/bin/google-chrome',headless:true,args:['--no-sandbox','--use-fake-device-for-media-stream','--enable-unsafe-swiftshader']});
try{
 const page=await browser.newPage({viewport:{width:1024,height:700},permissions:['camera']});
 let submissions=0;let sourceVerified=false;
 await page.route('**/api/portrait',async route=>{const body=route.request().postDataJSON();const pixels=execFileSync('/usr/bin/python3',['-c','from PIL import Image;import io,sys;i=Image.open(io.BytesIO(sys.stdin.buffer.read())).convert("RGB");assert i.size==(320,240);print(i.tobytes().hex())'],{input:Buffer.from(body.image.split(',')[1],'base64')}).toString().trim();assert.equal(pixels,expected,'Actual submitted source must match injected photo pixels');sourceVerified=true;await route.continue()});
 page.on('request',r=>{if(r.url().endsWith('/api/portrait')&&r.method()==='POST')submissions++;});
 await page.goto(process.env.BOOTH_TEST_URL??'http://127.0.0.1:8129/');
 await page.waitForFunction(()=>window.boothState?.state==='camera');await page.getByRole('button',{name:'Enable camera',exact:true}).click();
 await page.waitForFunction(()=>window.boothState.source==='camera');
 // Physical hardware is unavailable: feed the declared source photo through the same capture bridge.
 await page.evaluate(jpeg=>{window.booth.frame=()=>jpeg},jpeg);
 await writeFile(attempt,JSON.stringify({status:'one-paid-attempt-reserved',tag,at:new Date().toISOString()}),{flag:'wx'});
 await page.waitForTimeout(300);await page.getByRole('button',{name:'Take picture',exact:true}).click();
 await page.waitForFunction(()=>window.boothState.state==='loading');
 await page.screenshot({path:resolve(home,`review/evidence/${tag==='paid-loop'?'09-paid-loading':tag==='final-loop'?'16-final-loading':'19-final-loading'}.png`)});
 await page.waitForFunction(()=>window.boothState.state==='portrait',null,{timeout:150000});
 const started=Date.now();
 assert.equal(sourceVerified,true);assert.equal(submissions,1);assert.equal(await page.evaluate(()=>window.boothState.fixture_generation),false);
 const generated=await page.evaluate(()=>JSON.parse(window.booth.generated()));assert.match(generated.run,/^run-/);
 await page.screenshot({path:resolve(home,`review/evidence/${tag==='paid-loop'?'10-paid-portrait':tag==='final-loop'?'17-final-portrait':'20-final-portrait'}.png`)});
 await page.waitForFunction(()=>window.boothState.state==='explosion');
 assert(Date.now()-started>9400);await page.waitForFunction(()=>window.boothState.state==='camera');
 assert.equal(await page.evaluate(()=>window.boothState.has_capture),false);
 if(tag!=='paid-loop')await page.screenshot({path:resolve(home,`review/evidence/${tag==='final-loop'?'18-final-reset':'21-final-reset'}.png`)});
 await writeFile(receipt,JSON.stringify({passed:true,submissions,submitted_source_pixels_verified:sourceVerified,run:generated.run,source:'declared Figma fixture photo injected through real browser capture bridge',physical_webcam_tested:false,provider:'openrouter',model:'meta/muse-image',reserved_usd:0.01},null,2)+'\n');
 console.log('One real Muse capture→portrait→reset loop passed.');
}finally{await browser.close()}
