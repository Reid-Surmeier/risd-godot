const fs=require('fs');
const puppeteer=require('/home/reidsurmeier/promo-lab/node_modules/puppeteer-core');
const pause=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
 const browser=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:'new',args:['--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist','--no-sandbox']});
 try{
  const p=await browser.newPage();await p.setViewport({width:1600,height:900});
  const log=[],shots=[];let entry=false;
  p.on('console',m=>{log.push({time:Date.now(),text:m.text()});if(m.text().includes('ENTRY_COMPLETE'))entry=true;});
  await p.goto('https://windows-wsl.taile06c45.ts.net/gallery-dollhouse-01a0df97/',{waitUntil:'load',timeout:120000});
  await p.waitForFunction(()=>window.loadPerf?.some(m=>m.name==='game-shown'),{timeout:120000});
  for(let n=0;n<200&&!entry;n++)await pause(50);
  if(!entry)throw Error('entry did not complete');
  await pause(500);
  const started=Date.now();
  const shot=async name=>{await p.screenshot({path:'/tmp/gallery-blind-current/'+name+'.png'});shots.push({name,seconds:(Date.now()-started)/1000});};
  await shot('00-idle');
  const recorder=await p.screencast({path:'/tmp/gallery-blind-current/wasd-orbit.webm',fps:30});
  for(const [key,label] of [['w','01-w'],['s','02-s'],['a','03-a'],['d','04-d']]){
   await p.keyboard.down(key);await pause(80);await shot(label+'-080');await pause(270);await shot(label+'-350');await p.keyboard.up(key);await pause(350);await shot(label+'-stop');
  }
  await p.keyboard.down('w');await pause(150);await p.keyboard.down('d');await pause(300);await shot('05-wd');await p.keyboard.up('w');await pause(150);await shot('06-d-only');await p.keyboard.up('d');await pause(400);
  await p.mouse.move(760,400);await p.mouse.down();await p.mouse.move(940,360,{steps:24});await p.mouse.up();await pause(500);await shot('07-orbit');
  await p.keyboard.down('s');await pause(400);await shot('08-s-orbit');await p.keyboard.up('s');await pause(600);await shot('09-idle-orbit');
  await recorder.stop();
  await p.setViewport({width:720,height:486});await pause(500);await shot('10-small');
  fs.writeFileSync('/tmp/gallery-blind-current/capture.json',JSON.stringify({url:p.url(),shots,log},null,2));
  console.log(JSON.stringify({url:p.url(),shots}));
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});
