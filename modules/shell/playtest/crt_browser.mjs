// PLAYWRIGHT_MODULE=/absolute/path/to/playwright/index.mjs node modules/shell/playtest/crt_browser.mjs URL
import assert from 'node:assert/strict';
import {mkdirSync, writeFileSync} from 'node:fs';
const {chromium} = await import(process.env.PLAYWRIGHT_MODULE || 'playwright');
const out = 'docs/evidence/crt';
mkdirSync(out, {recursive:true});
const url = new URL(process.argv[2]); url.searchParams.set('qa-crt','1');
const browser = await chromium.launch({executablePath:'/usr/bin/google-chrome',args:['--no-sandbox','--use-angle=swiftshader','--enable-unsafe-swiftshader']});
try {
 const page = await browser.newPage({viewport:{width:1440,height:972},deviceScaleFactor:1});
 const errors=[];
 page.on('pageerror',e=>errors.push(e.message));
 page.on('console',m=>{if(m.type()==='error' && !/404|2D MSAA|render_target_set_msaa/.test(m.text()))errors.push(m.text());});
 await page.goto(url.href);
 const state=()=>page.evaluate(()=>window.shellCrtQa);
 await page.waitForFunction(()=>window.shellCrtQa?.shell.active===4 && !window.shellCrtQa.shell.switching);
 assert.deepEqual(await page.evaluate(()=>window.crtQaState),{enabled:true,curve:.018,screen_scale:1});
 await page.waitForTimeout(700);
 const on=await page.screenshot({path:out+'/collection-crt.png'});
 const initial=(await state()).shell;
 await page.keyboard.press('F8'); await page.waitForTimeout(400);
 const off=await page.screenshot({path:out+'/collection-off.png'});
 assert.deepEqual((await state()).shell,initial,'F8 preserves all tab states');
 const metrics=await page.evaluate(async([a,b])=>{
  async function decode(s){const i=new Image();i.src='data:image/png;base64,'+s;await i.decode();const c=document.createElement('canvas');c.width=i.width;c.height=i.height;const x=c.getContext('2d');x.drawImage(i,0,0);return x.getImageData(0,0,c.width,c.height).data;}
  const [on,off]=await Promise.all([decode(a),decode(b)]);let whiteChange=0,change=0;
  for(let i=0;i<on.length;i++)if(i%4!==3){change+=Math.abs(on[i]-off[i]);if(i<1440*3*4)whiteChange+=Math.abs(on[i]-off[i]);}
  let onY=0,offY=0;
  const linear=v=>v<=10.31475?v/3294.6:((v/255+.055)/1.055)**2.4;
  for(let y=290;y<302;y++)for(let x=150;x<250;x++)for(let c=0;c<3;c++){
   const i=(y*1440+x)*4+c,w=[.2126,.7152,.0722][c];onY+=linear(on[i])*w;offY+=linear(off[i])*w;
  }
  return {mean_change:change/(1440*972*3),white_change:whiteChange/(1440*3*3),near_white_luminance_change:Math.abs(onY-offY)/offY};
 },[on.toString('base64'),off.toString('base64')]);
 assert.ok(metrics.near_white_luminance_change<.02,'Near-white brightness preserved: '+JSON.stringify(metrics));
 assert.ok(metrics.mean_change>.3,'CRT visible'); assert.ok(metrics.white_change<.1,'White stays white');
 await page.keyboard.press('F8');
 function screen(x,y,s){
  const [w,h]=s.logical_size,[dw,dh]=s.display_size,aspect=h/w;
  const qx=(x/w-.5)/aspect,qy=y/h-.5,a=.018*(qx*qx+qy*qy),c=1+.018/4;
  const k=2*c/(1+Math.sqrt(1+4*a*c));return [(qx*k*aspect+.5)*dw,(qy*k+.5)*dh];
 }
 async function openTab(index){const s=await state(),[x,y,w,h]=s.shell.tabs[index].rect;await page.mouse.click(...screen(x+w/2,y+h/2,s));await page.waitForFunction(i=>window.shellCrtQa.shell.active===i&&!window.shellCrtQa.shell.switching,index);}
 for(const index of [0,1,2,3,4,5]) {await openTab(index);await page.screenshot({path:out+`/tab-${index}.png`});}
 await openTab(2);
 let hoverState=await state();
 const [ax,ay,aw,ah]=hoverState.tenant.controls.audio.match(/-?\d+(?:\.\d+)?/g).map(Number);
 const top=screen(ax,ay,hoverState),bottom=screen(ax+aw,ay+ah,hoverState);
 const clip={x:Math.floor(top[0])-2,y:Math.floor(top[1])-2,width:Math.ceil(bottom[0]-top[0])+4,height:Math.ceil(bottom[1]-top[1])+4};
 await page.mouse.move(5,5);await page.waitForTimeout(600);
 const idle=await page.screenshot({clip});
 await page.mouse.move(...screen(ax+aw/2,ay+ah/2,hoverState));await page.waitForTimeout(600);
 const hover=await page.screenshot({clip});
 assert.ok(!idle.equals(hover),'Viewer control visibly responds to hover');
 await page.mouse.move(5,5);await page.waitForTimeout(600);
 assert.ok(idle.equals(await page.screenshot({clip})),'Viewer hover clears after leaving');
 await openTab(1);
 let s=await state(); const [px,py,pw,ph]=s.tenant.page_rect;
 const strokes=s.tenant.strokes;
 await page.mouse.move(...screen(px+pw*.25,py+ph*.35,s));await page.mouse.down();
 await page.mouse.move(...screen(px+pw*.40,py+ph*.45,s),{steps:16});await page.mouse.up();
 await page.waitForFunction(n=>window.shellCrtQa.tenant.strokes===n+1,strokes);
 s=await state();const [tx,ty,tw,th]=s.tenant.title_rect,previous=s.tenant.window_rect;
 await page.mouse.move(...screen(tx+tw*.4,ty+th*.5,s));await page.mouse.down();await page.mouse.move(...screen(tx+tw*.4-35,ty+th*.5+15,s),{steps:10});await page.mouse.up();
 await page.waitForFunction(r=>Math.abs(window.shellCrtQa.tenant.window_rect[0]-(r[0]-35))<2,previous);
 await page.screenshot({path:out+'/sketchbook-painted.png'});
 const viewports=[];
 for(const [width,height] of [[1920,1080],[720,486],[1200,600]]){
  await page.setViewportSize({width,height});await page.waitForFunction(([w,h])=>window.shellCrtQa.display_size[0]===w&&window.shellCrtQa.display_size[1]===h,[width,height]);
  await openTab(4);await page.waitForTimeout(300);
  const shot=await page.screenshot({path:out+`/fit-${width}x${height}.png`});
  const dark=await page.evaluate(async(s)=>{const i=new Image();i.src='data:image/png;base64,'+s;await i.decode();const c=document.createElement('canvas');c.width=i.width;c.height=i.height;const x=c.getContext('2d');x.drawImage(i,0,0);const d=x.getImageData(0,0,c.width,c.height).data;const black=(x,y)=>{const p=(y*c.width+x)*4;return Math.max(d[p],d[p+1],d[p+2])<24?1:0;};return [Array.from({length:c.width},(_,x)=>black(x,0)),Array.from({length:c.width},(_,x)=>black(x,c.height-1)),Array.from({length:c.height},(_,y)=>black(0,y)),Array.from({length:c.height},(_,y)=>black(c.width-1,y))].map(a=>a.reduce((x,y)=>x+y,0)/a.length);},shot.toString('base64'));
  assert.ok(dark.every(n=>n<.3),'No black bars: '+JSON.stringify(dark));viewports.push({width,height,dark_edge_fraction:dark});
  // Bottom bar must remain clickable after fitting the smaller browser.
  await openTab(1);
 }
 url.searchParams.set('crt','0');await page.goto(url.href);await page.waitForFunction(()=>window.crtQaState?.enabled===false&&window.shellCrtQa?.shell.active===4);
 assert.deepEqual(errors,[]);
 const report={status:'pass',url:process.argv[2],metrics,viewports,errors};writeFileSync(out+'/report.json',JSON.stringify(report,null,2)+'\n');console.log(JSON.stringify(report));
}finally{await browser.close();}
