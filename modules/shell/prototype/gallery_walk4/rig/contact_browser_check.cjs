// Rendered contact review with real keys, at embedded and larger browser sizes.
const fs=require('fs'),path=require('path');
const puppeteer=require(path.join(require('os').homedir(),'promo-lab/node_modules/puppeteer-core'));
const wait=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
 const out=process.argv[3];fs.mkdirSync(out,{recursive:true});
 const browser=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:'new',args:['--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist','--no-sandbox']});
 const results=[];
 try{
 for(const [label,width,height] of [['embedded',1600,900],['large',2880,1800]]){
  const p=await browser.newPage();await p.setViewport({width,height});const events=[],errors=[];
  p.on('console',m=>{if(/NAV_SPACE|ENTRY_COMPLETE/.test(m.text()))events.push(m.text());if(m.type()==='error')errors.push(m.text());});p.on('pageerror',e=>errors.push(String(e)));
  await p.goto(process.argv[2],{waitUntil:'load',timeout:120000});await p.waitForFunction(()=>window.loadPerf?.some(m=>m.name==='game-shown'),{timeout:120000});await wait(2500);
  await p.evaluate(()=>{const d=document.createElement('div');d.id='qa-keys';d.style='position:fixed;left:8px;bottom:55px;background:white;color:black;font:18px monospace;padding:8px;z-index:9999;pointer-events:none';document.body.appendChild(d);const held=new Set();const update=()=>d.textContent='QA input: '+([...held].join('+')||'released');window.addEventListener('keydown',e=>{held.add(e.key);update()});window.addEventListener('keyup',e=>{held.delete(e.key);update()});update()});
  await p.screenshot({path:path.join(out,label+'-idle.png')});
  const recorder=await p.screencast({path:path.join(out,label+'-motion.webm'),fps:30});
  await p.keyboard.down('s');await wait(700);await p.keyboard.down('d');await wait(650);await p.keyboard.up('s');await wait(650);await p.keyboard.up('d');await p.keyboard.down('w');await wait(650);await p.keyboard.up('w');await wait(700);
  await p.screenshot({path:path.join(out,label+'-stop.png')});
  await recorder.stop();
  // Return to the reproducible initial view, then enter its adjacent white room.
  await p.reload({waitUntil:'load',timeout:120000});await p.waitForFunction(()=>window.loadPerf?.some(m=>m.name==='game-shown'),{timeout:120000});await wait(2500);
  await p.keyboard.down('w');await wait(2700);await p.keyboard.up('w');await wait(400);
  await p.screenshot({path:path.join(out,label+'-white.png')});
  if(!events.some(e=>e.includes('gallery -> arch')))throw Error(label+' white-room entry failed');
  results.push({label,viewport:[width,height],events,errors});await p.close();
 }
 fs.writeFileSync(path.join(out,'browser.json'),JSON.stringify(results,null,2));
 if(results.some(r=>r.errors.some(e=>/SCRIPT ERROR|RuntimeError|Failed loading/.test(e))))throw Error('new runtime error');
 console.log('CONTACT_BROWSER passed embedded/large straight, turn, stop, white-room views');
 }finally{await browser.close()}
})().catch(e=>{console.error(e);process.exit(1)});
