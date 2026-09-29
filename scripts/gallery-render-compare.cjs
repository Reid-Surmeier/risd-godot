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
 const browser=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:'new',protocolTimeout:300000,args:['--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist','--no-sandbox']});
 try {
  const page=await browser.newPage(); const errors=[];
  page.on('pageerror',e=>errors.push(String(e)));
  page.on('console',m=>{if(m.type()==='error'){errors.push(m.text());console.error(m.text());}});
  await page.setViewport({width:1600,height:900});
  await page.goto(url.href,{waitUntil:'load',timeout:120000});
  await page.waitForFunction(()=>window.loadPerf?.some(m=>m.name==='game-shown') && window.galleryRenderCommand,{timeout:240000});
  await pause(3000);
  const gpu=await page.evaluate(()=>{const gl=document.createElement('canvas').getContext('webgl2');const ext=gl?.getExtension('WEBGL_debug_renderer_info');return ext?gl.getParameter(ext.UNMASKED_RENDERER_WEBGL):'unknown';});
  console.log(JSON.stringify({gpu,expected_gpu:process.env.PRODUCER_BROWSER_GPU_MODE||'unspecified'}));
  if(process.env.PRODUCER_BROWSER_GPU_MODE==='hardware' && /llvmpipe|swiftshader|software|unknown/i.test(gpu))throw new Error('Hardware capture requested but renderer is '+gpu);
  const command=async request=>{
   await page.evaluate(r=>window.galleryRenderCommand(JSON.stringify(r)),request);await pause(60);
   const state=await page.evaluate(()=>window.galleryRenderState);
   if(state?.display_material?.class!=='SubViewportContainer' || !state.display_material.shader.endsWith('/gamecube.gdshader'))throw new Error('Diagnostic did not address actual gallery material: '+JSON.stringify(state?.display_material));
  };
  // Prove the intervention changes pixels on the actual displayed viewport before a blind run.
  await command({action:'pose',scene:'warm'});await command({action:'chart',visible:true});
  const preflight=out+'-preflight';fs.mkdirSync(preflight,{recursive:true});
  for(const mode of ['bypass','current']){await command({action:'mode',mode});await pause(300);await page.screenshot({path:path.join(preflight,mode+'.png')});}
  const diagnostic=await page.evaluate(()=>window.galleryRenderState);
  const changed=Number(require('child_process').execFileSync('python3',['-c',
   'from PIL import Image; import sys; a=Image.open(sys.argv[1]).convert("RGB"); b=Image.open(sys.argv[2]).convert("RGB"); r=list(map(float,sys.argv[3].split(","))); box=tuple(round(v*(a.width if i%2==0 else a.height)) for i,v in enumerate(r)); print(sum(x!=y for x,y in zip(a.crop(box).getdata(),b.crop(box).getdata())))',
   path.join(preflight,'bypass.png'),path.join(preflight,'current.png'),diagnostic.display_rect_normalized.join(',')],{encoding:'utf8'}).trim());
  if(changed===0)throw new Error('Displayed high-gradient control is unchanged between bypass and current');
  fs.writeFileSync(path.join(preflight,'result.json'),JSON.stringify({changed_pixels:changed,gpu,diagnostic},null,2));
  console.log(JSON.stringify({preflight_changed_pixels:changed}));
  await command({action:'chart',visible:false});
  const results=[];
  for(const width of (process.env.RENDER_WIDTHS||'1600,720').split(',').map(Number)) {
   const height=process.env.RENDER_SQUARE==='1'?width:(width===1600?900:486);
   await page.setViewport({width,height});await pause(500);
   await page.mouse.move(10,40);
   for(const [label,mode] of Object.entries(key)) {
    await command({action:'mode',mode});
    for(const scene of (process.env.RENDER_SCENES||'entry,warm,art,white').split(',')) {
     await command({action:'pose',scene});await pause(400);
     const prefix=path.join(out,`${label}-${width}-${scene}`);
     await page.screenshot({path:prefix+'.png'});
     const initial=await page.evaluate(()=>window.galleryRenderState);
     if(initial.paintings!==23)throw new Error('Artwork count changed');
     if(initial.space!==(scene==='white'?'far':'gallery'))throw new Error('Fixture landed in wrong room: '+scene+' '+initial.space);
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
