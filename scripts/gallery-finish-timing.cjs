// #161 production-path timing: no Godot QA flags, screencast or screenshots during measurement.
const fs=require('fs'),assert=require('assert/strict');
const puppeteer=require('/home/reidsurmeier/promo-lab/node_modules/puppeteer-core');
const pause=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
 const [base,out]=process.argv.slice(2), results=[];
 const browser=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:true,protocolTimeout:300000,args:['--no-sandbox','--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist']});
 try {
  for(const mode of ['current','bypass','copy-full','copy-full','bypass','current']) {
   const page=await browser.newPage(),errors=[];page.on('pageerror',e=>errors.push(String(e)));
   page.on('console',m=>{if(/SCRIPT ERROR|Failed loading resource|RuntimeError/.test(m.text()))errors.push(m.text());});
   await page.setViewport({width:1080,height:1080});
   const url=new URL(base);url.searchParams.set('final_render',mode);
   await page.goto(url.href,{waitUntil:'domcontentloaded',timeout:120000});
   await page.waitForFunction(()=>window.loadPerf?.some(m=>m.name==='game-shown'),{timeout:240000});
   await pause(3000);
   const gpu=await page.evaluate(()=>{const gl=document.createElement('canvas').getContext('webgl2'),e=gl.getExtension('WEBGL_debug_renderer_info');return e?gl.getParameter(e.UNMASKED_RENDERER_WEBGL):'unknown';});
   assert.ok(!/llvmpipe|swiftshader|software|unknown/i.test(gpu),gpu);
   await page.evaluate(()=>{window.finishTiming={active:true,deltas:[]};let last;function frame(t){if(!finishTiming.active)return;if(last!==undefined)finishTiming.deltas.push(t-last);last=t;requestAnimationFrame(frame)}requestAnimationFrame(frame)});
   for(const key of ['s','a','d']){await page.keyboard.down(key);await pause(2000);await page.keyboard.up(key);}
   await pause(2000);
   const deltas=await page.evaluate(()=>{finishTiming.active=false;return finishTiming.deltas});
   assert.ok(deltas.length>60,'insufficient animation frames');assert.deepEqual(errors,[]);
   const sorted=[...deltas].sort((a,b)=>a-b);
   results.push({mode,gpu,deltas,median_ms:sorted[Math.floor(sorted.length*.5)],p95_ms:sorted[Math.floor(sorted.length*.95)],errors});
   fs.writeFileSync(out,JSON.stringify(results,null,2));console.log(JSON.stringify({...results.at(-1),deltas:undefined}));
   await page.close();
  }
 }finally{await browser.close()}
})().catch(e=>{console.error(e);process.exitCode=1});
