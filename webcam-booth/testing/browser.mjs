import assert from 'node:assert/strict';
import {createServer} from 'node:http';
import {readFile, mkdir, writeFile} from 'node:fs/promises';
import {resolve, extname} from 'node:path';
import {execFileSync} from 'node:child_process';
import {chromium} from '/home/reidsurmeier/.npm-global/lib/node_modules/playwright/index.mjs';

const root = resolve(import.meta.dirname, '../build/web');
const evidence = resolve(import.meta.dirname, '../review/evidence');
await mkdir(evidence, {recursive: true});
const types = {'.html':'text/html','.js':'text/javascript','.wasm':'application/wasm','.pck':'application/octet-stream','.png':'image/png'};
const server = createServer(async (request, response) => {
  try {
    const path = resolve(root, '.' + new URL(request.url,'http://test').pathname.replace(/\/$/, '/index.html'));
    if (!path.startsWith(root + '/')) throw Error('outside export');
    response.setHeader('Content-Type', types[extname(path)] || 'application/octet-stream');
    response.end(await readFile(path));
  } catch { response.writeHead(404); response.end(); }
});
await new Promise(r=>server.listen(0, '127.0.0.1',r));
const origin = `http://127.0.0.1:${server.address().port}`;
const browser = await chromium.launch({executablePath: '/usr/bin/google-chrome',headless:true,args:['--no-sandbox','--use-fake-device-for-media-stream','--enable-unsafe-swiftshader']});
const context = await browser.newContext({viewport:{width:1024,height:700},permissions:['camera']});
const page = await context.newPage();
await page.addInitScript(() => {
  const original = navigator.mediaDevices.getUserMedia.bind(navigator.mediaDevices);
  window.__cameraStreams = [];
  navigator.mediaDevices.getUserMedia = async constraints => {
    const stream = await original(constraints); window.__cameraStreams.push(stream); return stream;
  };
});
const sample=await readFile(resolve(root,'../../assets/sample-portrait.webp'));
await page.route('**/api/portrait',route=>route.fulfill({status:200,contentType:'application/json',body:JSON.stringify({image:'data:image/webp;base64,'+sample.toString('base64'),run:'unpaid-adapter-fixture'})}));
let apiMode='success';
await page.unroute('**/api/portrait');
await page.route('**/api/portrait',async route=>{
 const response={status:200,contentType:'application/json',body:JSON.stringify({image:'data:image/webp;base64,'+sample.toString('base64'),run:'unpaid-adapter-fixture'})};
 if(apiMode==='delayed')await new Promise(r=>setTimeout(r,1800));
 if(apiMode==='failure')response.status=503,response.body=JSON.stringify({error:'Generation unavailable.'});
 try{await route.fulfill(response)}catch{} // cancelled request is expected
});
const errors = [];
page.on('pageerror',e=>errors.push(e.message));
page.on('console',m=>{if(/SCRIPT ERROR|^ERROR:/.test(m.text()))errors.push(m.text());});
const waitState = state=>page.waitForFunction(s=>window.boothState?.state===s,state,{timeout:30000});
const snapshot = async name=>page.screenshot({path:resolve(evidence,name+'.png')});
const click=x=>page.getByRole('button',{name:({320:'Enable camera',690:'Take picture',870:'Return to camera'})[x],exact:true}).click();
const results = [];
try {
  await page.goto(origin);
  await waitState('camera');
  await snapshot('00-camera-start');
  await click(320);
  await page.waitForFunction(()=>window.boothState.source==='camera');
  await page.evaluate(()=>{const frame=window.booth.frame,generate=window.booth.generate;window.booth.frame=()=>{window.__rawFrame=frame();return window.__rawFrame};window.booth.generate=image=>{window.__captured={image,raw:window.__rawFrame};return generate(image)}});
  await snapshot('01-camera-preview');
  assert.equal(await page.getByRole('button',{name:/sample|demo/i}).count(),0);
  const session=await context.newCDPSession(page);
  for (let i=0;i<2;i++) {
    if(i===1)await session.send('Emulation.setCPUThrottlingRate',{rate:4});
    await click(690);
    await waitState('loading');
    await page.evaluate(()=>window.booth.action('capture')); // repeated capture must not start another cycle
    if(i===0)await snapshot('02-loading');
    await waitState('portrait');
    const started=await page.evaluate(()=>performance.now());
    if(i===0)await snapshot('03-portrait');
    await waitState('explosion');
    const duration=await page.evaluate(start=>performance.now()-start,started);
    const motionTime=await page.evaluate(()=>window.boothState.motion_time);
    assert(motionTime>=10&&motionTime<11,`Burst must follow media clock: ${motionTime}`);
    assert(duration>=9000,`Fuse must finish before cutting: ${duration}`);
    if(i===0){await page.waitForTimeout(350);await snapshot('04-explosion');}
    assert.equal(await page.evaluate(()=>window.boothState.has_capture),false);
    await waitState('camera');
    assert.equal(await page.evaluate(()=>window.boothState.source),'camera');
    assert.equal(await page.evaluate(()=>window.boothState.motion_playing),false);
    results.push({check:'camera loop synchronized to native video, including throttled CPU',iteration:i+1,fuse_ms:duration,burst_media_seconds:motionTime});
  }
  await session.send('Emulation.setCPUThrottlingRate',{rate:1});
  const captured=await page.evaluate(()=>window.__captured);
  await writeFile(resolve(evidence,'capture.png'),Buffer.from(captured.image.split(',')[1],'base64'));
  await writeFile(resolve(evidence,'capture-raw.jpg'),Buffer.from(captured.raw,'base64'));
  execFileSync('python3',['-c','from PIL import Image;import sys; a=Image.open(sys.argv[1]).convert("RGB");b=Image.open(sys.argv[2]).convert("RGB");assert a.size==b.size and a.tobytes()==b.tobytes(),"Preview effects must not alter submitted pixels"',resolve(evidence,'capture.png'),resolve(evidence,'capture-raw.jpg')]);
  results.push({check:'Submitted source pixels equal decoded raw camera frame; retro effect display only',passed:true});
  await snapshot('05-reset');
  await click(690); await waitState('loading'); await click(870); await waitState('camera');
  await page.waitForTimeout(4200);
  assert.equal(await page.evaluate(()=>window.boothState.state),'camera');
  results.push({check:'cancel loading does not revive portrait',passed:true});
  await page.waitForFunction(()=>window.boothState.source==='camera',null,{timeout:20000});
  assert.equal(await page.evaluate(()=>JSON.parse(window.booth.status()).mode),'camera');
  await snapshot('06-synthetic-camera');
  await click(690); await waitState('loading'); await waitState('portrait');
  const liveStart=await page.evaluate(()=>performance.now());await waitState('explosion');
  const liveDuration=await page.evaluate(start=>performance.now()-start,liveStart);assert(liveDuration>=9000&&await page.evaluate(()=>window.boothState.motion_time>=10),`live portrait media synchronization ${liveDuration}`);
  await waitState('camera');
  await page.waitForFunction(()=>window.boothState.source==='camera');
  results.push({check:'synthetic getUserMedia frame transferred into exported Godot; capture/reset',passed:true});
  apiMode='failure';await click(690);await waitState('loading');await waitState('camera');
  assert.equal(await page.evaluate(()=>window.boothState.has_capture),false);
  await page.waitForTimeout(600);assert.equal(await page.evaluate(()=>window.boothState.message),'Generation unavailable.');
  results.push({check:'real-generation HTTP failure recovers camera with persistent message',passed:true});
  apiMode='delayed';await click(690);await waitState('loading');await click(870);await waitState('camera');
  await page.waitForTimeout(2000);assert.equal(await page.evaluate(()=>window.boothState.state),'camera');
  results.push({check:'cancel delayed real-generation result never revives portrait',passed:true});
  await click(690);await waitState('loading');await page.evaluate(()=>window.dispatchEvent(new Event('pagehide')));
  await waitState('camera');await page.waitForFunction(()=>window.boothState.source==='none');
  await page.waitForTimeout(2000);assert.equal(await page.evaluate(()=>window.boothState.state),'camera');
  results.push({check:'pagehide during real generation resets loading and discards late result',passed:true});
  apiMode='success';await click(320);await page.waitForFunction(()=>window.boothState.source==='camera');
  await page.evaluate(()=>window.__cameraStreams.at(-1).getTracks().forEach(track=>track.stop()));
  await page.waitForFunction(()=>window.boothState.source==='denied');
  await page.evaluate(()=>window.booth.action('capture'));
  assert.equal(await page.evaluate(()=>window.boothState.state),'camera');
  assert.equal(JSON.parse(await page.evaluate(()=>window.booth.status())).error,'CameraEnded');
  results.push({check:'ended camera track disables stale capture and allows retry',passed:true});
  await click(320); await page.waitForFunction(()=>window.boothState.source==='camera');
  await page.evaluate(()=>window.dispatchEvent(new Event("pagehide")));
  await page.waitForFunction(()=>window.boothState.source==='none');
  await page.evaluate(()=>window.booth.action('capture'));
  assert.equal(await page.evaluate(()=>window.boothState.state),'camera');
  results.push({check:'pagehide releases camera and disables stale capture on return',passed:true});
  // A camera request resolving after cancellation must release its stream.
  assert.equal(await page.evaluate(async()=>{
    const original = navigator.mediaDevices.getUserMedia.bind(navigator.mediaDevices);
    let finish;
    navigator.mediaDevices.getUserMedia=()=>new Promise(r=>finish=r);
    const pending=window.booth.start(); window.booth.stop();
    const canvas=document.createElement('canvas');canvas.width=10;canvas.height=10;
    const stale=canvas.captureStream(); finish(stale); await pending;
    navigator.mediaDevices.getUserMedia=original;
    return stale.getTracks()[0].readyState;
  }),'ended');
  results.push({check:'late camera permission result releases stale stream',passed:true});
  await context.close();
  const denied=await browser.newContext({viewport:{width:1024,height:700}});
  const deniedPage=await denied.newPage();
  await deniedPage.goto(origin);await deniedPage.waitForFunction(()=>window.boothState?.state==='camera');
  await deniedPage.getByRole('button',{name:'Enable camera',exact:true}).click();
  await deniedPage.waitForFunction(()=>window.boothState.source==='denied',null,{timeout:20000});
  await deniedPage.screenshot({path:resolve(evidence,'07-camera-denied.png')});
  results.push({check:'permission denial is recoverable',status:JSON.parse(await deniedPage.evaluate(()=>window.booth.status()))});
  await denied.close();
  assert.deepEqual(errors,[]);
  await writeFile(resolve(evidence,'browser.json'),JSON.stringify({passed:true,intercepted_camera_generation:true,physical_webcam_tested:false,paid_generation_tested:false,explosion_art_pending:false,results,errors},null,2)+'\n');
  console.log(JSON.stringify({passed:true,checks:results.length,evidence}));
} finally {await browser.close();await new Promise(r=>server.close(r));}
