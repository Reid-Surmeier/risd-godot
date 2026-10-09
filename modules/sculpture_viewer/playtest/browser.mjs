// #157: restored Viewer, four scans, isolated worlds, orbit/zoom and five fitted viewports.
// PLAYWRIGHT_MODULE=/absolute/playwright/index.mjs node modules/sculpture_viewer/playtest/browser.mjs URL
import assert from 'node:assert/strict';
import {mkdirSync,writeFileSync} from 'node:fs';
const {chromium}=await import(process.env.PLAYWRIGHT_MODULE||'playwright');
const out='docs/evidence/viewer-157';mkdirSync(out,{recursive:true});
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
 const selections=[];
 await tab(1); // Instantiate Sketchbook first: its Buddha must never leak into scan worlds.
 for(const [width,height] of [[1080,1080],[1920,1080],[1080,1920],[720,486],[486,720]]){
  await page.setViewportSize({width,height});
  await page.waitForFunction(([w,h])=>window.shellCrtQa?.display_size[0]===w&&window.shellCrtQa?.display_size[1]===h,[width,height]);
  await tab(2);let t=(await state()).tenant;
  for(let i=0;i<4;i++){
   await click(center(t.cards[i]));t=(await state()).tenant;
   assert.equal(t.selected,i);assert.equal(t.model_id,t.selected_id);assert.equal(t.model_loaded,true);
   assert.equal(t['3d_preview_available'],true);assert.equal(t.hover_model_loaded,true);
   assert.equal(t.hover_model_id,t.selected_id);assert.equal(t.separate_preview_world,true);
   const view=center(t.viewport_rect),pitch=t.pitch;
   await drag(view,[view[0]+22,view[1]+15]);assert.notEqual((await state()).tenant.pitch,pitch);
   const distance=(await state()).tenant.distance;await wheel(view);assert.ok((await state()).tenant.distance<distance);
   await page.mouse.move(...screen(center(t.cards[i]),await state()));await settle();
   if(width===1080&&height===1080)await shot(`scan-${i}`);
   selections.push({width,height,index:i,id:t.model_id,loaded:true});
  }
  await click(center(t.cards[19]));t=(await state()).tenant;
  assert.equal(t.model_loaded,false);assert.equal(t['3d_preview_available'],false);assert.equal(t.hover_model_loaded,false);
  await shot(`${width}x${height}-image-only`);
  await tab(0);await tab(2);assert.equal((await state()).tenant.selected,19);
  await click(center(t.cards[0]));await page.mouse.move(10,30);await settle();
  await shot(`${width}x${height}-viewer`);
  matrix.push({width,height,status:'pass'});console.log(`PASS Viewer ${width}x${height}`);
 }
 assert.deepEqual(errors,[]);
 writeFileSync(`${out}/browser.json`,JSON.stringify({candidate:'viewer157',matrix,selections,errors},null,2)+'\n');
} catch(error) {
 const pages=browser.contexts().flatMap(c=>c.pages());
 if(pages[0]){await pages[0].screenshot({path:`${out}/failure.png`});writeFileSync(`${out}/failure.json`,JSON.stringify({error:String(error),state:await pages[0].evaluate(()=>window.shellCrtQa),errors},null,2));}
 throw error;
} finally {await browser.close();}
