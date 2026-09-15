const {chromium}=await import(process.env.PLAYWRIGHT_MODULE || 'playwright');
import assert from 'node:assert/strict';import {mkdirSync,writeFileSync} from 'node:fs';
const browser=await chromium.launch({headless:true,args:['--no-sandbox']}),page=await browser.newPage({viewport:{width:1440,height:972}}),errors=[];page.on('pageerror',e=>errors.push(e.message));
const out=process.argv[3]||'/tmp/risd-zoom82-after';mkdirSync(out,{recursive:true});
const state=()=>page.evaluate(()=>window.shellCrtQa);
function screen(x,y,s){const[w,h]=s.logical_size,[dw,dh]=s.display_size,aspect=h/w,qx=(x/w-.5)/aspect,qy=y/h-.5,a=.018*(qx*qx+qy*qy),c=1+.018/4,k=2*c/(1+Math.sqrt(1+4*a*c));return[(qx*k*aspect+.5)*dw,(qy*k+.5)*dh];}
try{
await page.goto(process.argv[2]+'?qa-crt=1');await page.waitForFunction(()=>window.shellCrtQa?.shell.active===4,null,{timeout:90000});let s=await state();let[x,y,w,h]=s.shell.tabs[2].rect;
await page.mouse.click(...screen(x+w/2,y+h/2,s));await page.waitForFunction(()=>window.shellCrtQa?.shell.active===2&&!window.shellCrtQa.shell.switching);s=await state();
// Pause the automatic orbit before inspecting the same front at both limits.
let p=s.tenant.controls['play-pause'].match(/-?\d+(?:\.\d+)?/g).map(Number);await page.mouse.click(...screen(p[0]+p[2]/2,p[1]+p[3]/2,s));await page.waitForTimeout(300);
s=await state();const vr=s.tenant.viewport_rect;console.log('viewport',vr);const center=screen(vr[0]+vr[2]/2,vr[1]+vr[3]/2,s);
await page.mouse.move(...center);for(let i=0;i<24;i++){await page.mouse.wheel(0,-120);await page.waitForTimeout(30);}await page.waitForTimeout(400);s=await state();
const closest=s.tenant.distance;assert.equal(closest,Number(process.argv[4]||'2.8'));await page.screenshot({path:out+'/closest.png'});
await page.mouse.down();await page.mouse.move(center[0]+35,center[1],{steps:6});await page.mouse.up();await page.waitForTimeout(300);assert.notEqual((await state()).tenant.yaw,s.tenant.yaw);await page.screenshot({path:out+'/orbit.png'});
await page.mouse.dblclick(...center);await page.waitForTimeout(350);assert.equal((await state()).tenant.distance,8.7);
await page.mouse.wheel(0,-120);await page.waitForTimeout(300);assert.ok((await state()).tenant.distance<8.7);
assert.deepEqual(errors,[]);writeFileSync(out+'/report.json',JSON.stringify({closest,reset:8.7,orbit:true,errors},null,2));console.log({closest,reset:8.7,errors});
}finally{await browser.close();}
