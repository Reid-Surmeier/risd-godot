// #141: real exported startup, first-click and Godot input/frame evidence.
// node scripts/gallery-performance-check.cjs URL OUTPUT_JSON [CPU_RATE=1]
const fs = require('fs');
const assert = require('assert/strict');
const puppeteer = require(process.env.PUPPETEER_MODULE || require('path').join(require('os').homedir(), 'promo-lab/node_modules/puppeteer-core'));
const pause = ms => new Promise(r => setTimeout(r, ms));
const distribution = values => {
 const a = values.filter(Number.isFinite).sort((a,b)=>a-b);
 return {count:a.length,median:a[Math.floor(a.length*.5)],p95:a[Math.floor(a.length*.95)],max:a.at(-1),over50:a.filter(x=>x>50).length};
};
(async()=>{
 const [url,out,cpu='1'] = process.argv.slice(2);
 const browser = await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:'new',args:['--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist','--no-sandbox']});
 // If this script is killed (a wrapping `timeout`, a tool limit), Chrome would live on with the whole game in
 // memory: five orphans held 7 GB on 8 Oct. Puppeteer closes it on SIGTERM; this watcher covers SIGKILL too.
 require('child_process').spawn('sh',['-c',`while kill -0 ${process.pid} 2>/dev/null; do sleep 2; done; kill -9 ${browser.process().pid}`],{detached:true,stdio:'ignore'}).unref();
 try {
  const p = await browser.newPage(); await p.setViewport({width:1600,height:900}); await p.setCacheEnabled(false);
  const cdp=await p.createCDPSession(); await cdp.send('Emulation.setCPUThrottlingRate',{rate:Number(cpu)});
  if(process.env.NETWORK_MBIT)await cdp.send('Network.emulateNetworkConditions',{offline:false,latency:20,downloadThroughput:Number(process.env.NETWORK_MBIT)*1e6/8,uploadThroughput:1e6});
  const errors=[],consoleLog=[]; p.on('pageerror',e=>errors.push(String(e)));p.on('console',m=>{consoleLog.push(m.text());if(/SCRIPT ERROR|Failed loading resource|No loader found/.test(m.text()))errors.push(m.text());});
  await p.evaluateOnNewDocument(()=>{
   window.perfDomKeys=[];window.perfRaf=[];window.perfHeap=[];let previous;
   setInterval(()=>{if(performance.memory)perfHeap.push(performance.memory.usedJSHeapSize);},100);
   for(const kind of ['keydown','keyup'])addEventListener(kind,e=>window.perfDomKeys.push({kind,key:e.key,ms:performance.now(),event_ms:e.timeStamp,repeat:e.repeat}),true);
   function frame(t){if(previous)window.perfRaf.push({t,ms:t-previous});previous=t;requestAnimationFrame(frame);}requestAnimationFrame(frame);
  });
  const target=new URL(url);target.searchParams.set('qa-perf','1');target.searchParams.set('qa-crt','1');
  await p.goto(target.href,{waitUntil:'domcontentloaded',timeout:180000});
  await p.waitForFunction(()=>window.loadPerf?.some(m=>m.name==='game-shown'),{timeout:180000});
  await p.waitForFunction(()=>window.galleryPerf?.samples?.length>5,{timeout:15000});
  await pause(2500);
  const load=await p.evaluate(()=>({marks:loadPerf,resources:performance.getEntriesByType('resource').filter(r=>/\.(gz|pck|wasm)/.test(r.name)).map(r=>({name:r.name.split('/').pop(),bytes:r.transferSize,duration:r.duration})),memory:performance.memory?{used:performance.memory.usedJSHeapSize,total:performance.memory.totalJSHeapSize}:null}));
  await p.screenshot({path:out.replace(/\.json$/, '-start.png')});
  const tabs=[];
  for(const i of [0,1,2,3,5,6,4]) {
   const rect=await p.evaluate(i=>window.shellCrtQa.shell.tabs[i].rect,i);
   const before=await p.evaluate(()=>performance.now());
   await p.mouse.click(rect[0]+rect[2]/2,rect[1]+rect[3]/2);
   await p.waitForFunction(i=>window.shellCrtQa?.shell.active===i&&!window.shellCrtQa.shell.switching,{},i);
   await pause(350);
   const check=await p.evaluate(({i,before})=>({i,elapsed:performance.now()-before-350,gaps:perfRaf.filter(s=>s.t>=before).map(s=>s.ms),key:shellCrtQa.shell.tabs[i].key,tenant:shellCrtQa.shell.tabs[i].tenant}),{i,before});
   check.frames=distribution(check.gaps);delete check.gaps;tabs.push(check);assert.equal(check.tenant,'ok');
  }
  await pause(500);
  if(process.env.TRACE_FILE)await p.tracing.start({path:process.env.TRACE_FILE,categories:['devtools.timeline','v8','blink.user_timing','disabled-by-default-v8.gc']});
  const origin=await p.evaluate(()=>({keys:galleryPerf.keys.length,dom:perfDomKeys.length,us:galleryPerf.samples.at(-1).us,browser_ms:performance.now(),focused:document.hasFocus(),visibility:document.visibilityState,active:shellCrtQa.shell.active}));
  const phases=[];
  const step=async(label,changes,expected)=>{
   for(const [key,down]of changes)await p.keyboard[down?'down':'up'](key);
   await pause(400);
   const state=await p.evaluate(()=>galleryPerf.samples.at(-1));
   assert.deepEqual([...state.held].sort(),[...expected].sort(),label+' held state');
   phases.push({label,state});
  };
  await step('S',[['s',true]],['down']);
  await step('stop',[['s',false]],[]);
  await step('W',[['w',true]],['up']);
  await step('W+D',[['d',true]],['up','right']);
  await step('D',[['w',false]],['right']);
  await step('D+S',[['s',true]],['right','down']);
  await step('S',[['d',false]],['down']);
  await step('S+W cancellation',[['w',true]],['down','up']);
  await step('W reversal',[['s',false]],['up']);
  await step('stop',[['w',false]],[]);
  await step('A',[['a',true]],['left']);
  await step('D reversal',[['a',false],['d',true]],['right']);
  await step('stop',[['d',false]],[]);
  await pause(500);
  const evidence=await p.evaluate(origin=>({godot:galleryPerf,dom:perfDomKeys.slice(origin.dom),raf:perfRaf,heap:perfHeap}),origin);
  if(process.env.TRACE_FILE)await p.tracing.stop();
  const resources=await p.evaluate(()=>performance.getEntriesByType('resource').map(r=>({name:r.name.split('/').pop().split('?')[0],start:r.startTime,end:r.responseEnd,duration:r.duration,bytes:r.transferSize})));
  const received=evidence.godot.keys.filter(k=>k.us>origin.us&&!k.echo);
  assert.deepEqual(received.map(k=>[k.key.toLowerCase(),k.pressed]),evidence.dom.filter(k=>!k.repeat).map(k=>[k.key,k.kind==='keydown']),'Godot received every DOM key transition');
  const latency=received.map((k,i)=>k.browser_ms-evidence.dom.filter(k=>!k.repeat)[i].ms);
  const moving=evidence.godot.samples.filter(s=>s.us>origin.us);
  assert.ok(moving.some(s=>Math.hypot(...s.velocity)>.5),'nonzero velocity');
  assert.ok(moving.some(s=>Math.hypot(s.position[0]-moving[0].position[0],s.position[1]-moving[0].position[1])>.2),'actual displacement');
  assert.ok(Math.hypot(...moving.at(-1).velocity)<.01,'release stops movement');
  const canceled=phases.find(s=>s.label==='S+W cancellation').state;assert.ok(Math.hypot(...canceled.velocity)<.01,'opposed keys cancel');
  await p.screenshot({path:out.replace(/\.json$/, '-end.png')});
  const shown=load.marks.find(m=>m.name==='game-shown').t;
  const result={url:target.href,cpu:Number(cpu),network_mbit:Number(process.env.NETWORK_MBIT||0),load,tabs,phases,input_origin:origin,resources,observed_peak_js_heap_bytes:Math.max(0,...evidence.heap),startup_raf_ms:distribution(evidence.raf.filter(s=>s.t<shown).map(s=>s.ms)),latency_ms:distribution(latency),process_wall_ms:distribution(moving.map(s=>s.wall_ms??s.delta_ms)),post_draw_ms:distribution(evidence.godot.drawn.filter(s=>s.us>origin.us).map(s=>s.ms)),godot:evidence.godot,dom:evidence.dom,errors,consoleLog};
  fs.writeFileSync(out,JSON.stringify(result,null,2));
  console.log(JSON.stringify({out,marks:load.marks,tabs:tabs.map(t=>({key:t.key,elapsed:t.elapsed,maxGap:t.frames.max})),latency:result.latency_ms,process:result.process_wall_ms,draw:result.post_draw_ms,errors}));
  assert.equal(errors.length,0,'runtime errors');
 } finally {await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
