const fs=require('fs'),assert=require('assert/strict'),puppeteer=require('/home/reidsurmeier/promo-lab/node_modules/puppeteer-core');
const wait=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
 const [url,out]=process.argv.slice(2);fs.mkdirSync(out,{recursive:true});
 const browser=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:true,protocolTimeout:300000,args:['--no-sandbox','--use-angle=swiftshader','--enable-unsafe-swiftshader']});
 try{
 const page=await browser.newPage(),errors=[],records={url};await page.setViewport({width:800,height:600});
 page.on('pageerror',e=>errors.push(String(e)));page.on('console',m=>{if(m.type()==='error'&&!/404|2D MSAA|render_target_set_msaa/.test(m.text()))errors.push(m.text())});
 await page.goto(url+'?qa-crt=1',{waitUntil:'domcontentloaded',timeout:120000});
 await page.waitForFunction(()=>window.shellCrtQa?.shell.active===4&&!document.getElementById('status'),{timeout:240000});
 console.log('Loaded');await page.setViewport({width:1080,height:1080});await wait(800);
 const state=()=>page.evaluate(()=>window.shellCrtQa);
 const xy=async p=>page.evaluate(p=>{let r=window.shellCrtQa.stage_rect;return[r[0]+p[0]*r[2]/1080,r[1]+p[1]*r[3]/1080]},p);
 const click=async p=>page.mouse.click(...await xy(p));
 const center=r=>[r[0]+r[2]/2,r[1]+r[3]/2];
 const drag=async(p,d)=>{let a=await xy(p),b=await xy([p[0]+d[0],p[1]+d[1]]);await page.mouse.move(...a);await page.mouse.down();await page.mouse.move(...b,{steps:12});await page.mouse.up();await wait(500)};
 await click(center((await state()).shell.tabs[2].rect));await page.waitForFunction(()=>window.shellCrtQa?.shell.active===2&&!window.shellCrtQa.shell.switching);await wait(1200);
 let initial=(await state()).tenant;records.initial=initial;await page.screenshot({path:out+'/before.png'});
 for(const [key,size] of [['viewer_rect',[800,680]],['catalogue_rect',[1050,1320]]]){
  let before=(await state()).tenant[key],s=before[2]/size[0];
  await drag([before[0]+before[2]-24*s,before[1]+before[3]-24*s],[-80,-80]);
  let small=(await state()).tenant[key];assert(small[2]<before[2]-20);assert(Math.abs(small[2]/small[3]-size[0]/size[1])<.001);
  s=small[2]/size[0];await drag([small[0]+100*s,small[1]+20*s],[25,35]);
  let moved=(await state()).tenant[key];assert(Math.hypot(moved[0]-small[0],moved[1]-small[1])>20);
  await drag([moved[0]+moved[2]-24*s,moved[1]+moved[3]-24*s],[35,30]);
  let large=(await state()).tenant[key];assert(large[2]>small[2]);assert(Math.abs(large[2]/large[3]-size[0]/size[1])<.001);
 }
 // Independent chat/friends windows start at their original desktop placements.
 let ds=initial.desktop_scale,base=initial.catalogue_rect;
 for(const r of [[15,1320,665,315],[700,1320,330,315]]){
  const p=[base[0]+r[0]*ds,base[1]+r[1]*ds];
  await drag([p[0]+(r[2]-24)*ds,p[1]+(r[3]-24)*ds],[-25,-15]);
  await drag([p[0]+20*ds,p[1]+10*ds],[-180,-35]);
 }
 await page.mouse.move(10,60);await wait(500);await page.screenshot({path:out+'/adjusted.png'});
 let t=(await state()).tenant,cat=t.catalogue_rect,s=cat[2]/1050;
 await click([cat[0]+(40+247+109)*s,cat[1]+(185+82)*s]);await wait(700);
 t=(await state()).tenant;assert.equal(t.selected_id,'20260811122415');let yaw=t.yaw;
 await drag(center(t.viewport_rect),[45,10]);t=(await state()).tenant;assert(Math.abs(t.yaw-yaw)>1);
 const retained={viewer:t.viewer_rect,catalogue:t.catalogue_rect};
 await click(center((await state()).shell.tabs[4].rect));await wait(500);await click(center((await state()).shell.tabs[2].rect));await wait(600);
 t=(await state()).tenant;assert.deepEqual(t.viewer_rect,retained.viewer);assert.deepEqual(t.catalogue_rect,retained.catalogue);
 await page.setViewport({width:486,height:720});await wait(700);t=(await state()).tenant;
 assert.deepEqual(t.viewer_rect,retained.viewer);assert.deepEqual(t.catalogue_rect,retained.catalogue);
 await page.screenshot({path:out+'/portrait.png'});records.after=t;assert.deepEqual(errors,[]);records.errors=errors;
 fs.writeFileSync(out+'/results.json',JSON.stringify(records,null,2));console.log('WINDOW192 browser resize/drag/aspect, scan selection/orbit, tab return and portrait PASS');
 }finally{await browser.close()}
})().catch(e=>{console.error(e);process.exitCode=1});
