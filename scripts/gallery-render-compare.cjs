// #140 actual exported-browser comparison. Requires ?render_qa=1 diagnostics.
// node scripts/gallery-render-compare.cjs <url> <output-dir> [comma-separated modes]
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const puppeteer = require(process.env.PUPPETEER_MODULE || path.join(require('os').homedir(),'promo-lab/node_modules/puppeteer-core'));
const pause = ms => new Promise(resolve => setTimeout(resolve,ms));
(async () => {
 const url = new URL(process.argv[2]); url.searchParams.set('render_qa','1');
 const out=process.argv[3]; fs.mkdirSync(out,{recursive:true});
 const modes=(process.argv[4]||'current,copy-none,copy-full').split(',');
 // Keep the decoding key separate from the blind packet until review concludes.
 const shuffled=[...modes]; for(let i=shuffled.length-1;i>0;i--){const j=crypto.randomInt(i+1);[shuffled[i],shuffled[j]]=[shuffled[j],shuffled[i]];}
 const key=Object.fromEntries(shuffled.map((mode,i)=>[String.fromCharCode(65+i),mode]));
 fs.writeFileSync(out+'-key.json',JSON.stringify(key,null,2));
 const browser=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:'new',args:['--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist','--no-sandbox']});
 try {
  const page=await browser.newPage(); const errors=[];
  page.on('pageerror',e=>errors.push(String(e)));
  page.on('console',m=>{if(m.type()==='error'){errors.push(m.text());console.error(m.text());}});
  await page.setViewport({width:1600,height:900});
  await page.goto(url.href,{waitUntil:'load',timeout:120000});
  await page.waitForFunction(()=>window.loadPerf?.some(m=>m.name==='game-shown') && window.galleryRenderCommand,{timeout:120000});
  await pause(3000);
  const gpu=await page.evaluate(()=>{const gl=document.createElement('canvas').getContext('webgl2');const ext=gl?.getExtension('WEBGL_debug_renderer_info');return ext?gl.getParameter(ext.UNMASKED_RENDERER_WEBGL):'unknown';});
  const command=async request=>{await page.evaluate(r=>window.galleryRenderCommand(JSON.stringify(r)),request);await pause(60);};
  const results=[];
  for(const width of [1600,720]) {
   const height=width===1600?900:486;
   await page.setViewport({width,height});await pause(500);
   await page.mouse.move(10,40);
   for(const [label,mode] of Object.entries(key)) {
    await command({action:'mode',mode});
    for(const scene of ['entry','warm','art','white']) {
     await command({action:'pose',scene});await pause(400);
     const prefix=path.join(out,`${label}-${width}-${scene}`);
     await page.screenshot({path:prefix+'.png'});
     const initial=await page.evaluate(()=>window.galleryRenderState);
     if(initial.paintings!==23)throw new Error('Artwork count changed');
     if(scene==='warm') {await pause(500);await page.screenshot({path:prefix+'-held.png'});}
     await page.evaluate(()=>{
      window.renderTrace=[];window.renderDeltas=[];window.renderTracing=true;
      let lastTick=-1,lastTime;
      function record(t){
       if(!window.renderTracing)return;
       const s=window.galleryRenderState;
       if(s?.replaying && s.tick!==lastTick){window.renderTrace.push(JSON.parse(JSON.stringify(s)));lastTick=s.tick;}
       if(lastTime && s?.replaying)window.renderDeltas.push(t-lastTime);
       lastTime=t;requestAnimationFrame(record);
      }requestAnimationFrame(record);
     });
     const video=await page.screencast({path:prefix+'.webm',fps:30});
     await command({action:'replay',scene});
     const replayStarted=Date.now();
     try {
      await page.waitForFunction(()=>window.galleryRenderState?.tick>=480 && !window.galleryRenderState.replaying,{timeout:30000});
     } catch(error) {
      const failure=await page.evaluate(()=>({state:window.galleryRenderState,trace:window.renderTrace,deltas:window.renderDeltas}));
      fs.writeFileSync(prefix+'-failure.json',JSON.stringify({...failure,wall_ms:Date.now()-replayStarted,errors},null,2));
      await video.stop();throw error;
     }
     await video.stop();
     const evidence=await page.evaluate(()=>{window.renderTracing=false;return {trace:window.renderTrace,deltas:window.renderDeltas,final:window.galleryRenderState,dpr:devicePixelRatio};});
     const sorted=evidence.deltas.slice().sort((a,b)=>a-b);
     const metrics={median_ms:sorted[Math.floor(sorted.length*.5)],p95_ms:sorted[Math.floor(sorted.length*.95)],samples:sorted.length};
     const result={label,mode,width,height,scene,gpu,initial,...evidence,metrics};
     fs.writeFileSync(prefix+'.json',JSON.stringify(result,null,2));results.push({...result,trace:undefined,deltas:undefined});
     console.log(JSON.stringify({label,mode,width,scene,viewport:initial.viewport,space_after:evidence.final.space,...metrics}));
    }
   }
  }
  fs.writeFileSync(out+'-results.json',JSON.stringify({url:url.href,results,errors},null,2));
  if(errors.some(e=>/No loader found|Failed loading resource|RuntimeError|SCRIPT ERROR|Parse Error/.test(e)))throw new Error(errors.join('\n'));
 } finally {await browser.close();}
})().catch(e=>{console.error(e);process.exit(1);});
