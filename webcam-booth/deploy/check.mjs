import assert from 'node:assert/strict';
import {writeFile} from 'node:fs/promises';
import {chromium} from '/home/reidsurmeier/.npm-global/lib/node_modules/playwright/index.mjs';

const url=process.argv[2];
assert(url?.startsWith('https://'),'Pass the deployed HTTPS URL.');
const evidence=process.env.BOOTH_DEPLOY_EVIDENCE??'/tmp/webcam-deployment';
const browser=await chromium.launch({executablePath:'/usr/bin/google-chrome',headless:true,args:['--no-sandbox','--enable-unsafe-swiftshader']});
try {
 const page=await browser.newPage({viewport:{width:1024,height:700}});
 const errors=[];page.on('pageerror',e=>errors.push(e.message));
 let paidRequests=0;await page.route('**/api/portrait',route=>{paidRequests++;return route.abort();});
 const session=await page.context().newCDPSession(page);
 await session.send('Network.enable');
 await session.send('Network.emulateNetworkConditions',{offline:false,latency:20,downloadThroughput:1_250_000,uploadThroughput:500_000});
 const started=performance.now();await page.goto(url);
 await page.waitForFunction(()=>window.boothState?.state==='camera',null,{timeout:60000});
 const readyMs=Math.round(performance.now()-started);
 const wasm=await page.evaluate(()=>performance.getEntriesByType('resource').find(e=>e.name.endsWith('/index.wasm')).toJSON());
 assert(await page.evaluate(()=>window.isSecureContext));
 await page.getByRole('button',{name:'Try sample photo',exact:true}).click();
 await page.waitForFunction(()=>window.boothState.source==='fixture');
 await page.getByRole('button',{name:'Take picture',exact:true}).click();
 await page.waitForFunction(()=>window.boothState.state==='portrait');
 await page.screenshot({path:evidence+'.png'});
 await page.waitForFunction(()=>window.boothState.state==='explosion',null,{timeout:15000});
 await page.waitForFunction(()=>window.boothState.state==='camera',null,{timeout:15000});
 assert.equal(await page.evaluate(()=>window.boothState.has_capture),false);
 assert.equal(paidRequests,0);assert.deepEqual(errors,[]);
 const result={url,readyMs,networkMbps:10,wasm,paidRequests,sampleLoop:true};
 await writeFile(evidence+'.json',JSON.stringify(result,null,2)+'\n');
 console.log(JSON.stringify({readyMs,wasmBytes:wasm.encodedBodySize,wasmDecodedBytes:wasm.decodedBodySize,sampleLoop:true,paidRequests}));
 assert(wasm.encodedBodySize<15_000_000,'The engine download must be compressed below 15 MB.');
 assert(readyMs<25_000,'Cold startup must be under 25 seconds on the fixed 10 Mbps check.');
}finally {await browser.close();}
