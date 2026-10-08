const fs=require('fs'),assert=require('assert/strict');
const puppeteer=require('/home/reidsurmeier/promo-lab/node_modules/puppeteer-core');
const pause=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
 const browser=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:'new',args:['--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist','--no-sandbox','--autoplay-policy=no-user-gesture-required']});
 try{
  const p=await browser.newPage();await p.setViewport({width:1280,height:800});const errors=[];
  p.on('pageerror',e=>errors.push(String(e)));p.on('console',m=>{if(/SCRIPT ERROR|Failed loading resource|No loader found/.test(m.text()))errors.push(m.text());});
  await p.goto('http://127.0.0.1:8871/82adbc3e-dirty.html?qa-crt=1&qa-perf=1',{waitUntil:'load',timeout:180000});
  await p.waitForFunction(()=>window.loadPerf?.some(m=>m.name==='game-shown')&&window.galleryPerf?.samples.length>0,{timeout:240000});
  const state=await p.evaluate(()=>({active:shellCrtQa.shell.active,switching:shellCrtQa.shell.switching,status:document.getElementById('status')!==null,position:galleryPerf.samples.at(-1).position,marks:loadPerf}));
  assert.equal(state.active,4);assert.equal(state.switching,false);assert.equal(state.status,false);
  await p.focus('#canvas');
  state.position=await p.evaluate(()=>galleryPerf.samples.at(-1).position);
  await p.keyboard.down('s');
  await p.waitForFunction(()=>galleryPerf.samples.at(-1).held.includes('down')&&Math.hypot(...galleryPerf.samples.at(-1).velocity)>.5,{timeout:7000});await pause(650);
  const moving=await p.evaluate(()=>galleryPerf.samples.at(-1));await p.keyboard.up('s');await p.waitForFunction(()=>galleryPerf.samples.at(-1).held.length===0&&Math.hypot(...galleryPerf.samples.at(-1).velocity)<.01,{timeout:7000});
  const stopped=await p.evaluate(()=>galleryPerf.samples.at(-1));
  const displacement=Math.hypot(...moving.position.map((n,i)=>n-state.position[i]));
  const input=await p.evaluate(()=>({focus:document.activeElement?.tagName,keys:galleryPerf.keys.slice(-6),samples:galleryPerf.samples.slice(-6)})); console.log(JSON.stringify({state,moving,stopped,displacement,input}));
  fs.writeFileSync('build/hall-launch-281b/usable-attempt.json',JSON.stringify({state,moving,stopped,displacement,input},null,2));
  assert.ok(displacement>.2);assert.ok(Math.hypot(...moving.velocity)>.5);assert.ok(Math.hypot(...stopped.velocity)<.01);
  const idle=await p.evaluate(async()=>{const gaps=[];let previous;const end=performance.now()+2000;await new Promise(resolve=>{function frame(t){if(previous!==undefined)gaps.push(t-previous);previous=t;if(t>=end)resolve();else requestAnimationFrame(frame);}requestAnimationFrame(frame)});return {frames:gaps.length,max_gap_ms:Math.max(...gaps),over_50_ms:gaps.filter(v=>v>50).length};});
  const firstKey=await p.evaluate(()=>galleryPerf.keys.find(k=>k.pressed&&k.key==='S'));const shown=state.marks.find(m=>m.name==='game-shown').t;const result={state,moving,stopped,displacement,idle,first_key_after_shown_ms:firstKey.browser_ms-shown,errors};assert.deepEqual(errors,[]);
  fs.writeFileSync('docs/evidence/hall-launch-281b/usable-collection.json',JSON.stringify(result,null,2));console.log(JSON.stringify(result));
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1});
