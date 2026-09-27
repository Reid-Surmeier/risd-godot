const fs=require('fs'),path=require('path');
const puppeteer=require('/home/reidsurmeier/promo-lab/node_modules/puppeteer-core');
const out='/home/reidsurmeier/orca/workspaces/risd-godot/gallery-character-scale/docs/evidence/gallery-character-scale';
const pause=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
 fs.mkdirSync(out,{recursive:true});
 const browser=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:'new',args:['--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist','--no-sandbox']});
 try{
  for(const [label,sha] of [['baseline','22089e5'],['candidate','9e1fbea-dirty']]){
   const page=await browser.newPage();await page.setViewport({width:1600,height:900});
   const errors=[];page.on('pageerror',e=>errors.push(String(e)));page.on('console',m=>{if(m.type()==='error')errors.push(m.text())});
   await page.goto(`http://127.0.0.1:${label==='baseline'?18778:18779}/${sha}.html?render_qa=1`,{waitUntil:'load',timeout:60000});
   await page.waitForFunction(()=>window.loadPerf?.some(m=>m.name==='game-shown')&&window.galleryRenderCommand,{timeout:90000});
   const gpu=await page.evaluate(()=>{const gl=document.createElement('canvas').getContext('webgl2');const ext=gl?.getExtension('WEBGL_debug_renderer_info');return ext?gl.getParameter(ext.UNMASKED_RENDERER_WEBGL):'unknown'});
   if(!gpu.includes('NVIDIA GeForce RTX 4070 SUPER')||!gpu.includes('D3D12'))throw Error('Hardware renderer absent: '+gpu);
   const metrics=[],poses=[];
   for(const width of [1600,720]){
    await page.setViewport({width,height:width===1600?900:486});await pause(350);
    for(const scene of ['entry','warm','art','white']){
     await page.evaluate(scene=>window.galleryRenderCommand(JSON.stringify({action:'pose',scene})),scene);await pause(400);
     const state=await page.evaluate(()=>window.galleryRenderState);
     if(state.paintings!==23||state.visitor?.identity!==true)throw Error('Wrong pose state: '+JSON.stringify(state));
     await page.screenshot({path:path.join(out,`${label}-${width}-${scene}.png`)});
     poses.push({width,scene,space:state.space,camera:state.camera_transform,fov:state.camera_fov});
    }
    await page.evaluate(()=>window.galleryRenderCommand(JSON.stringify({action:'pose',scene:'warm'})));await pause(400);
    const video=await page.screencast({path:path.join(out,`${label}-${width}-motion.webm`),fps:30});
    await page.evaluate(()=>window.galleryRenderCommand(JSON.stringify({action:'replay',scene:'warm'})));
    await page.waitForFunction(()=>window.galleryRenderState?.tick>=200,{timeout:25000});
    const turnTick=await page.evaluate(()=>window.galleryRenderState.tick);
    await page.screenshot({path:path.join(out,`${label}-${width}-turn.png`)});
    await page.waitForFunction(()=>window.galleryRenderState?.tick>=480&&!window.galleryRenderState?.replaying,{timeout:30000});
    await video.stop();
    const deltas=await page.evaluate(()=>new Promise(resolve=>{const a=[];let last;const end=performance.now()+2000;function tick(t){if(last)a.push(t-last);last=t;if(t<end)requestAnimationFrame(tick);else resolve(a)}requestAnimationFrame(tick)}));
    deltas.sort((a,b)=>a-b);metrics.push({width,samples:deltas.length,median_ms:deltas[Math.floor(deltas.length*.5)],p95_ms:deltas[Math.floor(deltas.length*.95)],turnTick});
   }
   const result={label,sha,gpu,marks:await page.evaluate(()=>window.loadPerf.filter(m=>['downloads-done','tabs-warm','game-shown'].includes(m.name))),metrics,poses,final:await page.evaluate(()=>window.galleryRenderState),errors};
   fs.writeFileSync(path.join(out,`${label}.json`),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({label,sha,gpu,metrics,errors,finalTick:result.final.tick}));
   await page.close();
  }
 }finally{await browser.close()}
})().catch(e=>{console.error(e);process.exit(1)});
