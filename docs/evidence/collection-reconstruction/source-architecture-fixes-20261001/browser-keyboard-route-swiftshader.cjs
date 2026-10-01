// Real keyboard navigation using the existing opt-in Main Hall performance probe.
const fs=require('fs');
const puppeteer=require(process.env.PUPPETEER_MODULE || '/home/reidsurmeier/promo-lab/node_modules/puppeteer-core');
const pause=ms=>new Promise(resolve=>setTimeout(resolve,ms));
(async()=>{
 const [url,output,geometry]=process.argv.slice(2);
 const plan=JSON.parse(fs.readFileSync(geometry));
 const browser=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:'new',args:['--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader','--ignore-gpu-blocklist','--no-sandbox']});
 const errors=[],rows=[],consoleMessages=[],responses=[]; let page;
 try{
  fs.mkdirSync(output,{recursive:true});
  page=await browser.newPage();await page.setViewport({width:1600,height:900});
  page.on('response',r=>{if(r.status()>=400)responses.push({url:r.url(),status:r.status()});});
  page.on('console',m=>consoleMessages.push(m.text()));
  page.on('pageerror',error=>errors.push(String(error)));
  page.on('console',message=>{if(message.type()==='error')errors.push(message.text());});
  const target=new URL(url);target.searchParams.set('qa-perf','1');target.searchParams.set('variant','dollhouse');
  await page.goto(target.href,{waitUntil:'load',timeout:120000});
  await page.waitForFunction(()=>window.loadPerf?.some(x=>x.name==='game-shown')&&window.galleryPerf?.samples?.length,{timeout:120000});
  const current=()=>page.evaluate(()=>window.galleryPerf.samples.at(-1));
  await pause(2000);
  const first=await current();
  // At the original Hall entrance the dollhouse camera faces south (yaw PI).
  // No QA bridge changes or teleports: every route segment uses browser keyboard events.
  const route=[['portal',[0,2.7]],['medieval west',[-2.35,2.7]],['tracery',[-3.4,3.665]],['case bypass west',[-3.4,2.55]],['case bypass east',[3.65,2.55]],['medieval axis',[3.65,3.665]],['landing',[5.8,3.665]],['modern entry aisle',[6.3,1.0]],['modern',[6.3,-1.0]],['landing return',[6.3,1.0]],['sculpture aisle',[9.6,2.4]],['sculpture',[11.25,2.4]],['landing from sculpture',[9.6,2.4]]];
  // Sculpture and medieval axis offsets are taken from the emitted scene plan.
  const landing=plan.rooms.find(r=>r.label==='lion stair landing');
  const attach=[-5.55,-28.1];
  const midpoint=span=>(span[0]+span[1])/2;
  const medz=midpoint(landing.openings.west)+attach[1];
  const modernx=midpoint(landing.openings.north)+attach[0];
  const sculptz=midpoint(landing.openings.east)+attach[1];
  route[5][1][1]=route[6][1][1]=medz;
  for(const i of [7,8,9])route[i][1][0]=modernx;
  for(const i of [10,11,12])route[i][1][1]=sculptz;
  for(const [name,to] of route){
   const deadline=Date.now()+30000;
   let previous=await current(), previousTime=Date.now();
   while(Date.now()<deadline){
    const here=await current();const delta=to.map((v,i)=>v-here.position[i]);
    if(Math.hypot(...delta)<0.18)break;
    const axis=Math.abs(delta[0])>Math.abs(delta[1])?0:1;
    const key=axis===0?(delta[0]>0?'ArrowLeft':'ArrowRight'):(delta[1]>0?'ArrowUp':'ArrowDown');
    await page.keyboard.down(key);await pause(Math.min(300,Math.max(60,Math.abs(delta[axis])*320)));await page.keyboard.up(key);await pause(120);
    const now=await current();
    if(Math.hypot(...now.position.map((v,i)=>v-previous.position[i]))>0.05){previous=now;previousTime=Date.now();}
    else if(Date.now()-previousTime>2500)throw Error('Keyboard route trapped at '+name+': '+JSON.stringify(now));
   }
   const here=await current();const passed=Math.hypot(...to.map((v,i)=>v-here.position[i]))<0.18;
   rows.push({name,target:to,position:here.position,space:here.space,passed});
   if(!passed)throw Error('Keyboard route did not reach '+name);
   await page.screenshot({path:output+'/'+name.replaceAll(' ','-')+'.png'});
  }
  const gpu=await page.evaluate(()=>{const gl=document.createElement('canvas').getContext('webgl2');const extension=gl?.getExtension('WEBGL_debug_renderer_info');return extension?gl.getParameter(extension.UNMASKED_RENDERER_WEBGL):'unknown';});
  fs.writeFileSync(output+'/route.json',JSON.stringify({url:target.href,first,rows,errors,gpu,teleports:0,probe:'existing galleryPerf'},null,2));
  if(errors.length)throw Error(errors.join('\n'));
  console.log('BROWSER_KEYBOARD_ROUTE_OK',rows.length,gpu);
 }catch(error){const state=page?await page.evaluate(()=>({loadPerf:window.loadPerf,galleryPerf:window.galleryPerf,notice:document.getElementById('status-notice')?.textContent})).catch(()=>null):null;if(page)await page.screenshot({path:output+'/failure.png'}).catch(()=>{});fs.writeFileSync(output+'/failed-route.json',JSON.stringify({rows,errors,error:String(error),state,consoleMessages,responses},null,2));throw error;}
 finally{await browser.close();}
})().catch(error=>{console.error(error);process.exit(1)});
