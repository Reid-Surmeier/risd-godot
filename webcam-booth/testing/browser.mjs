import assert from 'node:assert/strict';
import {createServer} from 'node:http';
import {readFile, mkdir, writeFile} from 'node:fs/promises';
import {resolve, extname} from 'node:path';
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
const errors = [];
page.on('pageerror',e=>errors.push(e.message));
page.on('console',m=>{if(/SCRIPT ERROR|^ERROR:/.test(m.text()))errors.push(m.text());});
const waitState = state=>page.waitForFunction(s=>window.boothState?.state===s,state,{timeout:30000});
const snapshot = async name=>page.screenshot({path:resolve(evidence,name+'.png')});
const click = x=>page.mouse.click(x,609);
const results = [];
try {
  await page.goto(origin);
  await waitState('camera');
  await snapshot('00-camera-start');
  await click(490);
  await page.waitForFunction(()=>window.boothState.source==='fixture');
  await snapshot('01-camera-fixture');
  for (let i=0;i<2;i++) {
    await click(690);
    await waitState('loading');
    await click(690); // hidden Capture location must not start a second cycle
    if(i===0)await snapshot('02-loading');
    await waitState('portrait');
    const started=await page.evaluate(()=>performance.now());
    if(i===0)await snapshot('03-portrait');
    await waitState('explosion');
    const duration=await page.evaluate(start=>performance.now()-start,started);
    assert(duration >= 9700 && duration <= 10700,`fuse duration ${duration}`);
    if(i===0)await snapshot('04-explosion-placeholder');
    assert.equal(await page.evaluate(()=>window.boothState.has_capture),false);
    await waitState('camera');
    assert.equal(await page.evaluate(()=>window.boothState.source),'fixture');
    results.push({check:'complete fixture loop',iteration:i+1,fuse_ms:duration});
  }
  await snapshot('05-reset');
  await click(690); await waitState('loading'); await click(870); await waitState('camera');
  await page.waitForTimeout(4200);
  assert.equal(await page.evaluate(()=>window.boothState.state),'camera');
  results.push({check:'cancel loading does not revive portrait',passed:true});
  await click(320);
  await page.waitForFunction(()=>window.boothState.source==='camera',null,{timeout:20000});
  assert.equal(await page.evaluate(()=>JSON.parse(window.booth.status()).mode),'camera');
  await snapshot('06-synthetic-camera');
  await click(690); await waitState('loading'); await waitState('portrait');
  await click(870); await waitState('camera');
  await page.waitForFunction(()=>window.boothState.source==='camera');
  results.push({check:'synthetic getUserMedia frame transferred into exported Godot; capture/reset',passed:true});
  await page.evaluate(()=>window.booth.stop());
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
  await deniedPage.mouse.click(320,609);
  await deniedPage.waitForFunction(()=>window.boothState.source==='denied',null,{timeout:20000});
  await deniedPage.screenshot({path:resolve(evidence,'07-camera-denied.png')});
  results.push({check:'permission denial is recoverable',status:JSON.parse(await deniedPage.evaluate(()=>window.booth.status()))});
  await denied.close();
  assert.deepEqual(errors,[]);
  await writeFile(resolve(evidence,'browser.json'),JSON.stringify({passed:true,fixture_generation:true,physical_webcam_tested:false,paid_generation_tested:false,explosion_art_pending:true,results,errors},null,2)+'\n');
  console.log(JSON.stringify({passed:true,checks:results.length,evidence}));
} finally {await browser.close();await new Promise(r=>server.close(r));}
