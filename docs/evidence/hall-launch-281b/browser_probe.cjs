const fs = require('fs');
const puppeteer = require('/home/reidsurmeier/promo-lab/node_modules/puppeteer-core');
const pause = ms => new Promise(r=>setTimeout(r,ms));
(async()=>{
 const [url,phase] = process.argv.slice(2);
 for(let run=1;run<=3;run++){
  const browser=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:'new',args:['--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist','--no-sandbox','--autoplay-policy=no-user-gesture-required']});
  try{
   const p=await browser.newPage();await p.setViewport({width:1280,height:800});await p.setCacheEnabled(false);
   const errors=[];p.on('pageerror',e=>errors.push(String(e)));p.on('console',m=>{if(/SCRIPT ERROR|Failed loading resource|No loader found/.test(m.text()))errors.push(m.text());});
   const cdp=await p.createCDPSession();await cdp.send('Profiler.enable');await cdp.send('Profiler.setSamplingInterval',{interval:1000});await cdp.send('Profiler.start');
   const target=new URL(url);target.searchParams.set('qa-crt','1');
   await p.goto(target.href,{waitUntil:'load',timeout:180000});
   await p.waitForFunction(()=>window.loadPerf?.some(m=>m.name==='game-shown'),{timeout:240000});
   const {profile}=await cdp.send('Profiler.stop');
   const nodes=new Map(profile.nodes.map(n=>[n.id,n]));const parent=new Map();for(const n of profile.nodes)for(const c of n.children||[])parent.set(c,n.id);
   const costs={};let readbackUs=0;
   for(let i=0;i<(profile.samples||[]).length;i++){
    let n=nodes.get(profile.samples[i]);const dt=profile.timeDeltas[i]||0;const name=n?.callFrame.functionName||'(anonymous)';costs[name]=(costs[name]||0)+dt;
    while(n){if(/getBufferSubData/i.test(n.callFrame.functionName)){readbackUs+=dt;break;}n=nodes.get(parent.get(n.id));}
   }
   fs.writeFileSync(`build/hall-launch-281b/${phase}-${run}.cpuprofile`,JSON.stringify(profile));
   const marks=await p.evaluate(()=>window.loadPerf||[]);
   const renderer=await p.evaluate(()=>{const c=document.createElement('canvas').getContext('webgl2');const e=c&&c.getExtension('WEBGL_debug_renderer_info');return c?(e?c.getParameter(e.UNMASKED_RENDERER_WEBGL):'webgl2'):'none';});
   await pause(500);
   if(run===1)await p.screenshot({path:`docs/evidence/hall-launch-281b/browser-${phase}.png`});
   const tabs=[];
   fs.writeFileSync(`docs/evidence/hall-launch-281b/browser-${phase}-${run}.json`,JSON.stringify({phase,run,renderer,marks,readback_ms:readbackUs/1000,errors},null,2));
   for(const i of [0,1,2,3,5,6,4]){
    await p.waitForFunction(()=>window.shellCrtQa?.shell?.tabs?.length>=7,{timeout:15000});
    const rect=await p.evaluate(i=>{const q=window.shellCrtQa,r=q.shell.tabs[i].rect,s=q.stage_rect,l=q.logical_size;return [s[0]+r[0]/l[0]*s[2],s[1]+r[1]/l[1]*s[3],r[2]/l[0]*s[2],r[3]/l[1]*s[3]];},i);
    const started=await p.evaluate(()=>performance.now());
    await p.mouse.click(rect[0]+rect[2]/2,rect[1]+rect[3]/2);
    await p.waitForFunction(i=>window.shellCrtQa?.shell.active===i&&!window.shellCrtQa.shell.switching,{timeout:45000},i);
    const result=await p.evaluate(({i,started})=>({index:i,key:shellCrtQa.shell.tabs[i].key,ms:performance.now()-started,tenant:shellCrtQa.shell.tabs[i].tenant}),{i,started});
    tabs.push(result);await pause(100);
   }
   const result={phase,run,url:target.href,renderer,marks,readback_ms:readbackUs/1000,profile_top:Object.entries(costs).sort((a,b)=>b[1]-a[1]).slice(0,15).map(([name,us])=>({name,ms:us/1000})),tabs,errors};
   fs.writeFileSync(`docs/evidence/hall-launch-281b/browser-${phase}-${run}.json`,JSON.stringify(result,null,2));
   console.log(JSON.stringify(result));
  }finally{await browser.close();}
 }
})().catch(e=>{console.error(e);process.exitCode=1});
