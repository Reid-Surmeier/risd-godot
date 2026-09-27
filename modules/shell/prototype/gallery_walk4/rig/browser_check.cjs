// Actual exported app controls: both white-room roundtrips and continuous rig turns.
// node .../rig/browser_check.cjs <url> <out-dir>
const fs=require('fs'),path=require('path');
const puppeteer=require(path.join(require('os').homedir(),'promo-lab/node_modules/puppeteer-core'));
const pause=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
 const browser=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:'new',args:['--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist','--no-sandbox']});
 const out=process.argv[3];fs.mkdirSync(out,{recursive:true});
 try{
  const p=await browser.newPage();await p.setViewport({width:1600,height:900});await p.setCacheEnabled(false);
  const events=[],errors=[];p.on('console',m=>{if(m.text().includes('NAV_SPACE')||m.text().includes('ENTRY_COMPLETE'))events.push(m.text());if(m.type()==='error')errors.push(m.text());});p.on('pageerror',e=>errors.push(String(e)));
  await p.goto(process.argv[2],{waitUntil:'load',timeout:120000});
  await p.waitForFunction(()=>window.loadPerf?.some(m=>m.name==='game-shown'),{timeout:120000});
  const marks=await p.evaluate(()=>window.loadPerf);
  await pause(2500);await p.screenshot({path:path.join(out,'entry.png')});
  const hold=async(k,ms)=>{await p.keyboard.down(k);await pause(ms);await p.keyboard.up(k);await pause(300);};
  // Initial camera faces the arch: W goes out; the white room resets its camera.
  await hold('w',2700);await p.screenshot({path:path.join(out,'white-arch.png')});
  if(!events.some(e=>e.includes('gallery -> arch')))throw Error('arch exit missing');
  await hold('s',1100);await p.screenshot({path:path.join(out,'return-arch.png')});
  if(!events.some(e=>e.includes('arch -> gallery')))throw Error('arch return missing');
  // Walk beside the benches, then return to the doorway centreline.
  await hold('a',2000);await hold('w',10000);await p.screenshot({path:path.join(out,'gallery-light-mid.png')});
  await hold('w',13500);await p.screenshot({path:path.join(out,'gallery-light-far.png')});
  await hold('d',2000);await hold('w',1200);await p.screenshot({path:path.join(out,'white-far.png')});
  if(!events.some(e=>e.includes('gallery -> far')))throw Error('far exit missing');
  await hold('s',1100);await p.screenshot({path:path.join(out,'return-far.png')});
  if(!events.some(e=>e.includes('far -> gallery')))throw Error('far return missing');
  await hold('w',2400); // Move away from the far doorway before the reversal chain.
  const recorder=await p.screencast({path:path.join(out,'motion.webm'),fps:30});
  await p.keyboard.down('s');await pause(800);await p.keyboard.down('d');await pause(800);await p.keyboard.up('s');await pause(800);await p.keyboard.down('w');await pause(800);await p.keyboard.up('d');await pause(800);await p.keyboard.up('w');await pause(700);
  await p.mouse.move(760,400);await p.mouse.down();await p.mouse.move(900,380,{steps:20});await p.mouse.up();await pause(1400);
  await recorder.stop();
  await p.screenshot({path:path.join(out,'motion-end.png')});
  const result={url:process.argv[2],marks,events,errors,transfer_bytes:await p.evaluate(()=>performance.getEntriesByType('resource').reduce((a,r)=>a+r.transferSize,0))};
  fs.writeFileSync(path.join(out,'browser.json'),JSON.stringify(result,null,2));console.log(JSON.stringify(result));
  if(errors.some(e=>/SCRIPT ERROR|Failed loading|RuntimeError/.test(e)))throw Error(errors.join('\n'));
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});
