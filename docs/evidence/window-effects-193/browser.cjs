const fs=require('fs'),assert=require('assert/strict'),puppeteer=require('/home/reidsurmeier/promo-lab/node_modules/puppeteer-core');
const wait=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
 const [url,out]=process.argv.slice(2);fs.mkdirSync(out,{recursive:true});
 const browser=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:true,protocolTimeout:300000,args:['--no-sandbox','--use-angle=swiftshader','--enable-unsafe-swiftshader']});
 try{
 const page=await browser.newPage(),errors=[],records={url,windows:[]};await page.setViewport({width:800,height:600});
 page.on('pageerror',e=>errors.push(String(e)));
 await page.goto(url+'?qa-crt=1&render_qa=1',{waitUntil:'domcontentloaded',timeout:120000});
 await page.waitForFunction(()=>window.shellCrtQa?.shell.active===4&&!document.getElementById('status'),{timeout:240000});
 console.log('Loaded');
 const state=()=>page.evaluate(()=>window.shellCrtQa);
 const xy=async p=>{const s=await state(),[sx,sy,sw,sh]=s.stage_rect,qx=p[0]/1080-.5,qy=p[1]/1080-.5,a=.018*(qx*qx+qy*qy),c=1+.018/4,k=2*c/(1+Math.sqrt(1+4*a*c));return[sx+(qx*k+.5)*sw,sy+(qy*k+.5)*sh]};
 const click=async p=>page.mouse.click(...await xy(p));
 const center=r=>[r[0]+r[2]/2,r[1]+r[3]/2];
 const drag=async(p,d)=>{await page.mouse.move(...await xy(p));await page.mouse.down();await page.mouse.move(...await xy([p[0]+d[0],p[1]+d[1]]),{steps:12});await page.mouse.up();await wait(700)};
 const tab=async i=>{await click(center((await state()).shell.tabs[i].rect));await page.waitForFunction(i=>window.shellCrtQa?.shell.active===i&&!window.shellCrtQa.shell.switching,{},i);await wait(700)};
 assert(await page.evaluate(()=>window.crtQaState.enabled&&window.squiggleQaState.enabled));
 for(const index of [0,1,5,4]){
  await tab(index);await page.screenshot({path:out+`/page-${index}-before.png`});
  const names=(await state()).window_grips.map(g=>g.name);
  for(const name of names){
   let g=(await state()).window_grips.find(g=>g.name===name);
   if(index!==4){await click([g.rect[0]+Math.min(50,g.rect[2]/2),g.rect[1]+Math.min(10,g.rect[3]/10)]);await wait(400)}
   g=(await state()).window_grips.find(g=>g.name===name);const before=g;
   await drag(center(g.grip),[-55,-45]);g=(await state()).window_grips.find(g=>g.name===name);
   assert(g.scale[0]<before.scale[0],`${index} ${name} shrink: ${JSON.stringify({before,g})}`);
   assert(Math.abs(g.scale[0]-g.scale[1])<.0001);
   const small=g;await drag(center(g.grip),[25,20]);g=(await state()).window_grips.find(g=>g.name===name);
   assert(g.scale[0]>small.scale[0],`${name} grow`);assert(Math.abs(g.rect[2]/g.rect[3]-before.rect[2]/before.rect[3])<.0001);
   if(index===4){const r=g.rect;assert(Math.abs(r[0]+r[2]/2-540)<.01&&Math.abs(r[1]+r[3]/2-540)<.01,"resized Collection centered")}
   records.windows.push({index,name,before,after:g});console.log('PASS',index,name);
  }
  await page.mouse.move(5,5);await page.screenshot({path:out+`/page-${index}-after.png`});
  const saved=(await state()).window_grips;await tab(index===0?1:0);await tab(index);assert.deepEqual((await state()).window_grips,saved,"window scales/positions retained on tab return");
 }
 const retained=(await state()).window_grips;await tab(0);await tab(4);assert.deepEqual((await state()).window_grips,retained);
 const command=action=>page.evaluate(action=>window.galleryRenderCommand(JSON.stringify(action)),action);
 const gallery=async()=>{await command({action:'state'});return page.evaluate(()=>window.galleryRenderState)};
 await command({action:'pose',scene:'art'});await command({action:'release'});await wait(500);
 const openPainting=async()=>{
  const s=await gallery(),r=s.display_rect_normalized,c=[(r[0]+r[2])/2,r[1]+(r[3]-r[1])*.2];
  const targets=s.visible_paintings.sort((a,b)=>Math.hypot(a.point[0]-c[0],a.point[1]-c[1])-Math.hypot(b.point[0]-c[0],b.point[1]-c[1]));assert(targets.length);
  await click(targets[0].point.map(v=>v*1080));
  await page.waitForFunction(()=>{window.galleryRenderCommand(JSON.stringify({action:'state'}));return !!window.galleryRenderState.preview.tag},{timeout:20000});await wait(500);
  assert.equal((await gallery()).preview.tag,targets[0].tag);
 };
 await openPainting();await page.screenshot({path:out+'/preview-click.png'});
 await click((await gallery()).preview.close.map(v=>v*1080));await wait(600);
 assert(!(await gallery()).preview.tag);assert.deepEqual((await state()).window_grips,retained,'X restores chosen centered frame');
 await openPainting();await page.keyboard.press('Escape');await wait(600);
 assert(!(await gallery()).preview.tag);assert.deepEqual((await state()).window_grips,retained,'Escape restores chosen centered frame');
 await page.screenshot({path:out+'/preview-return.png'});
 await click([966,27]);await page.waitForFunction(()=>!!document.fullscreenElement,{timeout:5000});
 await page.setViewport({width:1600,height:1000});await wait(700);assert.deepEqual((await state()).window_grips,retained);
 await page.screenshot({path:out+'/fullscreen.png'});
 await click([966,27]);await page.waitForFunction(()=>!document.fullscreenElement,{timeout:5000});
 const before=await gallery();await page.keyboard.down('s');await wait(700);await page.keyboard.up('s');await wait(400);const stopped=await gallery();await wait(300);const still=await gallery();
 assert(Math.hypot(...before.position.map((v,i)=>v-stopped.position[i]))>.2);assert.deepEqual(still.position,stopped.position);assert.equal(stopped.paintings,23);assert.equal(stopped.visitor.identity,'Hair36');
 records.collection={before,stopped,still};
 await page.keyboard.press('F9');await wait(500);assert.equal(await page.evaluate(()=>window.squiggleQaState.enabled),false);
 await page.keyboard.press('F9');await wait(500);assert.equal(await page.evaluate(()=>window.squiggleQaState.enabled),true);
 await page.keyboard.press('F8');await wait(500);assert.equal(await page.evaluate(()=>window.crtQaState.enabled),false);
 await page.keyboard.press('F8');await wait(500);assert.equal(await page.evaluate(()=>window.crtQaState.enabled),true);
 await page.setViewport({width:486,height:720});await wait(800);assert.deepEqual((await state()).window_grips,retained);
 await page.screenshot({path:out+'/portrait.png'});await tab(1);await page.screenshot({path:out+'/portrait-sketchbook.png'});
 assert.deepEqual(errors,[]);records.errors=errors;records.status='pass';fs.writeFileSync(out+'/results.json',JSON.stringify(records,null,2));console.log('WINDOW193 browser PASS');
 }finally{await browser.close()}
})().catch(e=>{console.error(e);process.exitCode=1});
