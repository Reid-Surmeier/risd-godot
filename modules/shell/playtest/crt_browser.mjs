// #173: the exported square and retained Tenants, exercised through browser input.
// PLAYWRIGHT_MODULE=/absolute/playwright/index.mjs node modules/shell/playtest/crt_browser.mjs URL
import assert from 'node:assert/strict';
import {mkdirSync,writeFileSync} from 'node:fs';
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright');
const out='docs/evidence/structure-173';mkdirSync(out,{recursive:true});
const url=new URL(process.argv[2]);url.searchParams.set('qa-crt','1');
const browser=await chromium.launch({executablePath:process.env.CHROMIUM_PATH||'/usr/bin/google-chrome',args:['--no-sandbox','--use-angle=swiftshader','--enable-unsafe-swiftshader']});
const errors=[],matrix=[];
try {
 const page=await browser.newPage({viewport:{width:1080,height:1080},hasTouch:true,deviceScaleFactor:1});
 page.on('pageerror',e=>errors.push(e.message));
 page.on('console',m=>{if(m.type()==='error'&&!/404|2D MSAA|render_target_set_msaa/.test(m.text()))errors.push(m.text());});
 await page.goto(url.href);
 await page.waitForFunction(()=>window.shellCrtQa?.shell.active===4&&!window.shellCrtQa.shell.switching,null,{timeout:240000});
 await page.waitForFunction(()=>!document.getElementById('status'),null,{timeout:120000});
 await page.keyboard.press('F8');await page.waitForFunction(()=>window.crtQaState?.enabled===false);
 assert.equal((await page.evaluate(()=>window.shellCrtQa)).shell.active,4,'CRT toggle retains Page');
 await page.keyboard.press('F8');await page.waitForFunction(()=>window.crtQaState?.enabled===true);
 const state=()=>page.evaluate(()=>window.shellCrtQa);
 const rect=r=>Array.isArray(r)?r:r.match(/-?\d+(?:\.\d+)?/g).map(Number);
 const center=r=>{const [x,y,w,h]=rect(r);return [x+w/2,y+h/2];};
 function screen([x,y],s){
  const [ox,oy,dw,dh]=s.stage_rect;
  const qx=x/1080-.5,qy=y/1080-.5,a=.018*(qx*qx+qy*qy),c=1+.018/4;
  const k=2*c/(1+Math.sqrt(1+4*a*c));return [ox+(qx*k+.5)*dw,oy+(qy*k+.5)*dh];
 }
 const settle=()=>page.waitForTimeout(450);
 async function click(point,touch=false){const p=screen(point,await state());if(touch)await page.touchscreen.tap(...p);else await page.mouse.click(...p);await settle();}
 async function tab(i,touch=false){await click(center((await state()).shell.tabs[i].rect),touch);await page.waitForFunction(i=>window.shellCrtQa.shell.active===i&&!window.shellCrtQa.shell.switching,i);}
 async function drag(from,to){const s=await state();await page.mouse.move(...screen(from,s));await page.mouse.down();await page.mouse.move(...screen(to,s),{steps:10});await page.mouse.up();await settle();}
 async function wheel(point){await page.mouse.move(...screen(point,await state()));await page.mouse.wheel(0,-100);await settle();}
 async function shot(name){return page.screenshot({path:`${out}/${name}.png`});}
 for(const [width,height] of [[1080,1080],[1920,1080],[1080,1920],[720,486],[486,720]]){
  const id=`${width}x${height}`;await page.setViewportSize({width,height});
  await page.waitForFunction(([w,h])=>window.shellCrtQa?.display_size[0]===w&&window.shellCrtQa?.display_size[1]===h,[width,height]);
  const s=await state(),side=Math.min(width,height);assert.deepEqual(s.logical_size,[1080,1080]);
  assert.deepEqual(s.stage_rect,[(width-side)/2,(height-side)/2,side,side]);
  for(let i=0;i<7;i++){await tab(i);await shot(`${id}-tab-${i}`);}
  // Read actual screenshot pixels outside the square; every sample must be white.
  const png=await shot(`${id}-exterior`);
  const exterior=await page.evaluate(async([encoded,r])=>{
   const image=new Image();image.src='data:image/png;base64,'+encoded;await image.decode();
   const canvas=document.createElement('canvas');canvas.width=image.width;canvas.height=image.height;
   const ctx=canvas.getContext('2d');ctx.drawImage(image,0,0);const d=ctx.getImageData(0,0,canvas.width,canvas.height).data;
   let bad=0,samples=0;for(let y=0;y<canvas.height;y+=7)for(let x=0;x<canvas.width;x+=7){
    if(x>=r[0]&&x<r[0]+r[2]&&y>=r[1]&&y<r[1]+r[3])continue;
    samples++;const p=(y*canvas.width+x)*4;if(d[p]!==255||d[p+1]!==255||d[p+2]!==255)bad++;
   }return {bad,samples};
  },[png.toString('base64'),s.stage_rect]);assert.equal(exterior.bad,0,`white exterior ${id}`);
  await tab(4,true); // actual browser touch, including nonzero stage offset
  await click([1065,1057]);assert.equal((await state()).shell.active,0,'Home');
  await click([36,1057]);await page.keyboard.press('Home');await page.keyboard.press('Enter');await settle();assert.equal((await state()).shell.active,0,'Start keyboard selection');
  await page.keyboard.press('Escape');await settle(); // dismiss the Start popup before the next viewport capture
  // atlas_window.gd intentionally filters Playwright's synthetic device -1 mouse events;
  // native Atlas acceptance covers Map drag, pan, zoom, resize, collapse and lock.
  let t=(await state()).tenant;
  // Verify exterior release terminates the Map drag (review regression).
  if(width!==height){
   t=(await state()).tenant;const r=rect(t.frame_global),p=[r[0]+r[2]/2,r[1]+8];
   await page.mouse.move(...screen(p,await state()));await page.mouse.down();await page.mouse.move(2,2);await page.mouse.up();await settle();
   assert.equal((await state()).tenant.action,'','drag released outside');
   const active=(await state()).shell.active;await page.mouse.click(2,2);await settle();assert.equal((await state()).shell.active,active,'exterior click ignored');
  }
  await tab(2);t=(await state()).tenant;await click(center(t.cards[0]));t=(await state()).tenant;assert.equal(t.model_loaded,true);assert.ok(rect(t.viewport_rect)[2]>100);
  await click(center(t.cards[19]));assert.equal((await state()).tenant.selected,19);
  let vr=rect(t.viewer_rect),vf=[vr[0]+vr[2]*.4,vr[1]+8];await drag(vf,[vf[0]+15,vf[1]+22]);
  t=(await state()).tenant;assert.ok(rect(t.viewer_rect)[1]>vr[1]+10,'Viewer window drag');
  const view=center(t.viewport_rect),pitch=t.pitch;await drag(view,[view[0]+30,view[1]+20]);assert.notEqual((await state()).tenant.pitch,pitch,'Viewer orbit');
  const distance=(await state()).tenant.distance;await wheel(view);assert.ok((await state()).tenant.distance<distance,'Viewer zoom');
  await tab(0);await tab(2);assert.equal((await state()).tenant.selected,19,'Viewer selection retained');
  await tab(5);t=(await state()).tenant;const main=rect(t.main_window),start=[main[0]+main[2]*.4,main[1]+6];
  await drag(start,[start[0]+12,start[1]+12]);assert.ok(rect((await state()).tenant.main_window)[0]>main[0]+5,'Playground main window drag');
  for(const name of ['explore','all','channels','search']){await click(center((await state()).tenant.navigation['Page_'+name]));assert.equal((await state()).tenant.page,name);await shot(`${id}-playground-${name}`);}
  await tab(1);t=(await state()).tenant;const strokes=t.strokes,[px,py,pw,ph]=rect(t.page_rect);
  await drag([px+pw*.35,py+ph*.4],[px+pw*.48,py+ph*.5]);assert.equal((await state()).tenant.strokes,strokes+1,'Sketchbook paint regression');
  matrix.push({width,height,stage:s.stage_rect,exterior,status:'pass'});console.log(`PASS ${id}`);
 }
 const candidate=url.pathname.split('/').at(-1).replace(/\.html$/,'');
 assert.deepEqual(errors,[]);writeFileSync(`${out}/browser.json`,JSON.stringify({candidate,url:'local scratch export; no owner-facing URL',controls:['seven Tabs and Home/Start selection','five viewport sizes and white exterior pixel samples','touch Tab selection with nonzero stage offset','Map exterior release','Viewer selection, window drag, orbit, zoom, and retained selection','Playground window drag and four pages','Sketchbook paint'],matrix,errors},null,2)+'\n');
} catch(error) {
 const pages=browser.contexts().flatMap(c=>c.pages());
 if(pages[0]){await pages[0].screenshot({path:`${out}/failure.png`});writeFileSync(`${out}/failure.json`,JSON.stringify({error:String(error),state:await pages[0].evaluate(()=>window.shellCrtQa),errors},null,2));}
 throw error;
} finally {await browser.close();}
