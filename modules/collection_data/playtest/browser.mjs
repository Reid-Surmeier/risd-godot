const {chromium} = await import(process.env.PLAYWRIGHT_MODULE || 'playwright');
import {writeFile} from 'node:fs/promises';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {readFile} from 'node:fs/promises';
const url=process.argv[2],browser=await chromium.launch({headless:true,executablePath:process.env.CHROME_BIN,args:['--no-sandbox']}),page=await browser.newPage({viewport:{width:1920,height:1080}});
const errors=[];page.on('console',m=>console.log(m.type(),m.text()));page.on('requestfailed',r=>console.log('request failed',r.url(),r.failure()));page.on('pageerror',e=>errors.push(e.message));
await page.goto(url);await page.waitForFunction(()=>window.risdSearchProbe,null,{timeout:90000}).catch(async e=>{await page.screenshot({path:'/tmp/risd-search78/browser-failed.png'});throw e;});
const servedHash=createHash('sha256').update(await (await page.request.get(new URL('index.pck',url).href)).body()).digest('hex');
const localHash=createHash('sha256').update(await readFile('build/web-search-probe/index.pck')).digest('hex');assert.equal(servedHash,localHash);
const result=await page.evaluate(()=>window.risdSearchProbe);
assert.equal(result.search.ok,true,JSON.stringify(result));
assert.deepEqual(result.search.value.items.map(x=>x.id),['risd:1377691','risd:1584511']);
assert.deepEqual(result.rendered_hashes,[
  'b7e66eee6aac0ed42db55788dd2d2cd2e65fa3128b6599c769f140eff71e0ce6',
  'f50520a15ef1eb172fc00e472bd117be00d2f4f3136fb6949d4e06752ba6a50b'
]);
const wire=await page.evaluate(async()=>{const response=await fetch(new URL('api/collection/search?q=Monet&category=Painting',location.href));return {status:response.status,value:await response.json()}});
assert.equal(wire.status,200);assert.equal(wire.value.value.total,2);
assert.equal(errors.length,0,errors.join('\n'));
await page.screenshot({path:'/tmp/risd-search78/browser.png'});
await page.screenshot({path:'/tmp/risd-search78/browser-1920.png'});
const smallErrors=[],small=await browser.newPage({viewport:{width:720,height:486}});small.on('pageerror',e=>smallErrors.push(e.message));
await small.goto(url);await small.waitForFunction(()=>window.risdSearchProbe,null,{timeout:90000});
const smallResult=await small.evaluate(()=>window.risdSearchProbe);assert.deepEqual(smallResult.rendered_hashes,result.rendered_hashes);assert.equal(smallErrors.length,0,smallErrors.join('\n'));
await small.screenshot({path:'/tmp/risd-search78/browser-720.png'});
await writeFile('/tmp/risd-search78/browser-report.json',JSON.stringify({url,result,wire,errors,servedHash,viewports:[{width:1920,height:1080},{width:720,height:486}]},null,2));
console.log(JSON.stringify({records:result.search.value.items.map(x=>x.id),errors}));await browser.close();
