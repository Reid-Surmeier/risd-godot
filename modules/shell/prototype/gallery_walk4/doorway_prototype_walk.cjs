// Actual exported gameplay roundtrip, visitor hidden by the prototype launcher.
const fs=require('fs'), puppeteer=require('/home/reidsurmeier/promo-lab/node_modules/puppeteer-core');
const wait=ms=>new Promise(resolve=>setTimeout(resolve,ms));
(async()=>{
 const [url,out]=process.argv.slice(2); fs.mkdirSync(out,{recursive:true});
 const portal=process.argv[4]||'far';
 const showVisitor=process.argv.includes('--show-visitor');
 const browser=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:true,args:['--no-sandbox','--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist']});
 const results=[];
 try {
  for(const width of [1600,720]) {
   const page=await browser.newPage(); await page.setViewport({width,height:Math.round(width*.75)});
   await page.setRequestInterception(true);
   page.on('request',r=>new URL(r.url()).pathname==='/favicon.ico'?r.respond({status:204}):r.continue());
   const events=[],errors=[];
   page.on('console',m=>{if(/NAV_SPACE|VIEW_ORBIT|DOORWAY_GAMEPLAY_READY|DOORWAY_FLOOR|PORTAL_FLOOR_DEPTH/.test(m.text()))events.push(m.text());if(m.type()==='error')errors.push(m.text());});
   page.on('pageerror',e=>errors.push(String(e)));
   let expectedYaw=Math.PI;
   const halfTurn=async()=>{
    const before=events.filter(e=>e.includes('VIEW_ORBIT ')).length;
    expectedYaw=(expectedYaw+Math.PI)%(2*Math.PI);
    for(let turn=0;turn<2;turn++){
     await page.keyboard.down('q'); await wait(120); await page.keyboard.up('q'); await wait(800);
    }
    for(let i=0;i<200;i++){
     const turns=events.filter(e=>e.includes('VIEW_ORBIT '));
     if(turns.length>before){
      const raw=turns.at(-1), state=JSON.parse(raw.slice(raw.indexOf('VIEW_ORBIT ')+11));
      if(Math.cos(state.yaw-expectedYaw)>0.999)return state;
     }
     await wait(100);
    }
    throw Error('No settled half-turn evidence: '+JSON.stringify({events,errors}));
   };
   await page.goto(url+'?gameplay=1&qa-floor=1&portal='+portal+(showVisitor?'&show-visitor=1':''),{waitUntil:'domcontentloaded',timeout:120000});
   for(let i=0;i<480&&!events.some(e=>e.includes('READY'));i++)await wait(500);
   if(!events.some(e=>e.includes('READY')))throw Error('Gameplay did not start: '+errors.join('\n'));
   const probe=portal==='arch'?'PORTAL_FLOOR_DEPTH':'DOORWAY_FLOOR';
   if(!events.some(e=>e.includes(probe+' clear_samples=9/9')))throw Error('Passage floor depth failed: '+events.join('\n'));
   await page.waitForFunction(()=>!document.getElementById('status'),{timeout:180000});
   if(showVisitor)await page.evaluate(()=>{window.__cameraSamples=[];window.__cameraTimer=setInterval(()=>{if(window.__portalQA)window.__cameraSamples.push({...window.__portalQA,time:performance.now()});},50);});
   await wait(1000);
   const video=await page.screencast({path:`${out}/${width}-roundtrip.webm`,fps:20});
   await page.screenshot({path:`${out}/${width}-approach.png`});
   for(const [key,route,label] of [['w',`gallery -> ${portal}`,'inside'],['s',`${portal} -> gallery`,'return']]) {
    await page.keyboard.down(key);
    for(let i=0;i<100&&!events.some(e=>e.includes(route));i++)await wait(100);
    // Continue physically through the recess, not merely to a state switch.
    if(portal==='arch')await page.waitForFunction(label==='inside'?
     'window.__portalQA?.space === "arch" && window.__portalQA.position[1] > 3.2':
     'window.__portalQA?.space === "gallery" && window.__portalQA.position[1] < -1.2',{timeout:45000});
    await page.keyboard.up(key); await wait(600);
    await page.screenshot({path:`${out}/${width}-${label}.png`});
    if(!events.some(e=>e.includes(route)))throw Error('Missing portal transition '+route);
    if(portal==='arch'&&label==='inside'){
     const state=await halfTurn();
     if(state.space!=='arch'||state.position[1]<2.2)throw Error('Did not physically pass through the recess: '+JSON.stringify(state));
     await page.screenshot({path:`${out}/${width}-inside-looking-back.png`});
     await halfTurn();
    }
   }
   await video.stop();
   const camera=showVisitor?await page.evaluate(()=>{clearInterval(window.__cameraTimer);return window.__cameraSamples;}):[];
   if(showVisitor&&(!camera.length||camera.some(s=>s.view!==0||s.fov!==23||!s.visitor_visible)))throw Error('Camera mode/FOV/visitor changed during actual input traversal');
   results.push({width,events,errors,camera}); await page.close();
  }
  fs.writeFileSync(`${out}/browser.json`,JSON.stringify(results,null,2));
  if(results.some(r=>r.errors.length))throw Error('Browser runtime errors');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});
