// Run after export; uses the host’s existing Puppeteer/Chrome/ffmpeg.
// node scripts/gallery-browser-check.cjs <url> <label> [baseline.json]
const fs = require('fs');
const puppeteer = require(process.env.PUPPETEER_MODULE || require('path').join(require('os').homedir(),'promo-lab/node_modules/puppeteer-core'));
const pause = ms => new Promise(r => setTimeout(r, ms));
(async () => {
 const url=process.argv[2], label=process.argv[3];
 const browser=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:'new',args:['--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist','--no-sandbox']});
 try {
  const p=await browser.newPage(); await p.setViewport({width:1600,height:900});
  const wallEvents=[];p.on('console',m=>{if(m.text().includes('OTHER_WALL '))wallEvents.push(m.text());});
  const errors=[]; p.on('pageerror',e=>errors.push(String(e))); p.on('console',m=>{if(m.type()==='error')errors.push(m.text());});
  await p.goto(url,{waitUntil:'load',timeout:120000});
  await p.waitForFunction(()=>window.loadPerf?.some(mark=>mark.name==='tabs-warm'),{timeout:120000});
  await pause(3000);
  if(errors.some(error=>/No loader found|Failed loading resource|RuntimeError/.test(error)))throw new Error(errors.join('\n'));
  await p.screenshot({path:'/tmp/'+label+'-start.png'});
  const gpu=await p.evaluate(()=>{const gl=document.createElement('canvas').getContext('webgl2');const ext=gl?.getExtension('WEBGL_debug_renderer_info');return ext?gl.getParameter(ext.UNMASKED_RENDERER_WEBGL):'unknown';});
  await p.keyboard.press('ArrowUp'); await pause(1000);
  const measures=[];
  for(const phase of ['standing','walking','turning']) {
   if(phase==='walking')await p.keyboard.down(label.startsWith('baseline')?'ArrowUp':'ArrowRight');
   let rotation;
   if(phase==='turning') {if(label.startsWith('baseline'))await p.keyboard.down('ArrowLeft');else rotation=setInterval(()=>p.keyboard.press('e').catch(()=>{}),1000);}
   const deltas=await p.evaluate(()=>new Promise(resolve=>{const samples=[];let before;const end=performance.now()+5000;function f(t){if(before)samples.push(t-before);before=t;if(t<end)requestAnimationFrame(f);else resolve(samples);}requestAnimationFrame(f);}));
   clearInterval(rotation);if(phase==='walking')await p.keyboard.up(label.startsWith('baseline')?'ArrowUp':'ArrowRight');if(phase==='turning' && label.startsWith('baseline'))await p.keyboard.up('ArrowLeft');
   deltas.sort((a,b)=>a-b); const percentile=q=>deltas[Math.floor((deltas.length-1)*q)];
   measures.push({phase,samples:deltas.length,median_ms:percentile(.5),p95_ms:percentile(.95),mean_ms:deltas.reduce((a,b)=>a+b,0)/deltas.length});
  }
  const recorder=await p.screencast({path:'/tmp/'+label+'.webm',fps:30});
  await p.keyboard.down('ArrowUp'); await pause(2000); await p.keyboard.up('ArrowUp');
  if(label.startsWith('baseline')) {await p.keyboard.down('ArrowLeft');await pause(2000);await p.keyboard.up('ArrowLeft');} else {await p.keyboard.press('e');await pause(2000);}
  await recorder.stop();
  await p.screenshot({path:'/tmp/'+label+'-end.png'});
  const transfer=await p.evaluate(()=>performance.getEntriesByType('resource').reduce((a,r)=>a+r.transferSize,0));
  const ui=[];
  if(!label.startsWith('baseline')) {
   await p.mouse.click(1070,187);await pause(500);
   ui.push({control:'other-wall',passed:wallEvents.length>0,events:wallEvents});
   await p.screenshot({path:'/tmp/'+label+'-other-wall.png'});
   await p.keyboard.press('F6');await pause(200);
   await p.mouse.click(630,550);await pause(300);
   await p.screenshot({path:'/tmp/'+label+'-menu.png'});
   await p.keyboard.press('ArrowDown');await p.keyboard.press('ArrowDown');await p.keyboard.press('Enter');await pause(500);
   ui.push({control:'camera',url:p.url(),passed:new URL(p.url()).searchParams.get('variant')==='gallery'});
   await p.mouse.click(866,550);await pause(500);
   ui.push({control:'lighting',url:p.url(),passed:new URL(p.url()).searchParams.get('lighting')==='original'});
   await p.screenshot({path:'/tmp/'+label+'-controls.png'});
  }
  const result={url,label,viewport:[1600,900],gpu,measures,transfer_bytes:transfer,ui,errors};
  fs.writeFileSync('/tmp/'+label+'.json',JSON.stringify(result,null,2)); console.log(JSON.stringify(result));
  if(process.argv[4]) {
   const baseline=JSON.parse(fs.readFileSync(process.argv[4]));
   for(const sample of measures) {
    const before=baseline.measures.find(m=>m.phase===sample.phase);
    if(sample.median_ms>before.median_ms*1.1 || sample.p95_ms>before.p95_ms*1.1)throw new Error('Frame-time budget failed: '+sample.phase);
   }
  }
  if(ui.some(check=>!check.passed))throw new Error('Browser control interaction failed');
 } finally {await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});
