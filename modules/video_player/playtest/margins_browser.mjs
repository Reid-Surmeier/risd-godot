const {chromium} = await import(process.env.PLAYWRIGHT_MODULE || 'playwright');
import assert from 'node:assert/strict';import {mkdirSync,writeFileSync} from 'node:fs';
const browser=await chromium.launch({headless:true,args:['--no-sandbox']}),page=await browser.newPage({viewport:{width:1440,height:972}}),errors=[];page.on('pageerror',e=>errors.push(e.message));
const out='/tmp/risd-video83-browser';mkdirSync(out,{recursive:true});
const state=()=>page.evaluate(()=>window.shellCrtQa);
function screen(x,y,s){const [w,h]=s.logical_size,[dw,dh]=s.display_size,aspect=h/w,qx=(x/w-.5)/aspect,qy=y/h-.5,a=.018*(qx*qx+qy*qy),c=1+.018/4,k=2*c/(1+Math.sqrt(1+4*a*c));return [(qx*k*aspect+.5)*dw,(qy*k+.5)*dh];}
try{
await page.goto(process.argv[2]+'?qa-crt=1');await page.waitForFunction(()=>window.shellCrtQa?.shell.active===4,null,{timeout:90000});
let s=await state();let[x,y,w,h]=s.shell.tabs[3].rect;await page.mouse.click(...screen(x+w/2,y+h/2,s));await page.waitForFunction(()=>window.shellCrtQa?.shell.active===3&&!window.shellCrtQa.shell.switching);
const results=[];
for(const [width,height,key] of [[1440,972,'1'],[1920,1080,'3'],[720,486,'2']]){
 await page.setViewportSize({width,height});await page.keyboard.press(key);await page.waitForTimeout(700);s=await state();
 assert.equal(s.tenant.selected_video,Number(key)-1);assert.equal(s.tenant.playing,true);
 // Freeze for a stable sampled image; then use the fitted movie's top-left to sample its margin.
 await page.keyboard.press('Space');await page.waitForTimeout(300);s=await state();
 const vr=s.tenant.video_rect,pt=screen(vr[0]+vr[2]*.4,vr[1]-30,s);
 const shot=await page.screenshot({path:`${out}/${width}x${height}.png`});
 const mean=await page.evaluate(async({png,pt})=>{let i=new Image();i.src='data:image/png;base64,'+png;await i.decode();let c=document.createElement('canvas');c.width=i.width;c.height=i.height;let x=c.getContext('2d');x.drawImage(i,0,0);let d=x.getImageData(Math.round(pt[0])-3,Math.round(pt[1])-3,6,6).data;return [...d].filter((_,j)=>j%4!==3).reduce((a,b)=>a+b,0)/(36*3);},{png:shot.toString('base64'),pt});
 assert.ok(mean>225&&mean<250,'Grey margin '+mean);results.push({width,height,video:s.tenant.video_id,marginMean:mean});
}
await page.keyboard.press('f');await page.waitForTimeout(250);assert.equal((await state()).tenant.fullscreen,true);await page.keyboard.press('f');await page.waitForTimeout(250);assert.equal((await state()).tenant.fullscreen,false);
assert.deepEqual(errors,[]);writeFileSync(out+'/report.json',JSON.stringify({results,errors},null,2));console.log(JSON.stringify({results,errors}));
}finally{await browser.close();}
