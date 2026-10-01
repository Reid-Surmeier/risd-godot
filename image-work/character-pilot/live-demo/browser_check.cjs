// Real keyboard and multitouch playtest, using the browser already installed on this host.
const fs=require('fs'),path=require('path'),assert=require('node:assert/strict');
const puppeteer=require(path.join(require('os').homedir(),'promo-lab/node_modules/puppeteer-core'));
const wait=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
 const out=process.argv[3];fs.mkdirSync(out,{recursive:true});
 const browser=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:'new',args:['--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist','--no-sandbox']});
 const report={keyboard:{},touch:{},errors:[]};
 try{
  const page=await browser.newPage();await page.setViewport({width:960,height:720});
  page.on('pageerror',e=>report.errors.push(String(e)));
  page.on('console',m=>{if(/SCRIPT ERROR|RuntimeError|Failed loading/.test(m.text()))report.errors.push(m.text());});
  await page.goto(process.argv[2],{waitUntil:'load',timeout:60000});
  await page.waitForFunction(()=>window.characterPlaytest?.bones===24,{timeout:60000});
  const snapshot=()=>page.evaluate(()=>window.characterPlaytest);
  await page.mouse.click(480,350);
  report.keyboard.initial=await snapshot();assert.equal(report.keyboard.initial.state,'Idle');
  await page.screenshot({path:path.join(out,'desktop-idle.png')});
  await page.keyboard.down('w');
  await page.waitForFunction(()=>window.characterPlaytest?.z < -1,{timeout:12000});
  report.keyboard.walk=await snapshot();assert.equal(report.keyboard.walk.state,'Walk');
  assert(Math.abs(report.keyboard.walk.speed_mps-3.15)<0.02);
  assert(Math.abs(report.keyboard.walk.animation_rate-1.25)<0.001);
  await page.screenshot({path:path.join(out,'desktop-walk.png')});
  await page.keyboard.up('w');await page.keyboard.down('d');
  await page.waitForFunction(()=>window.characterPlaytest?.x > 0.6,{timeout:12000});
  report.keyboard.turn=await snapshot();assert(Math.abs(report.keyboard.turn.yaw-report.keyboard.walk.yaw)>0.5);
  await page.keyboard.up('d');await page.keyboard.down('Shift');await page.keyboard.down('s');
  await page.waitForFunction(n=>window.characterPlaytest?.effects > n,{timeout:12000},report.keyboard.turn.effects);
  report.keyboard.sprint=await snapshot();assert.equal(report.keyboard.sprint.state,'Dash');
  assert(Math.abs(report.keyboard.sprint.speed_mps-5.4)<0.02);
  await page.screenshot({path:path.join(out,'desktop-sprint.png')});
  await page.keyboard.up('s');await page.keyboard.up('Shift');
  await page.waitForFunction(()=>window.characterPlaytest?.state==='Idle');await wait(350);
  report.keyboard.stopped=await snapshot();await wait(500);assert.equal((await snapshot()).effects,report.keyboard.stopped.effects);
  await page.keyboard.press('r');await wait(300);report.keyboard.reset=await snapshot();
  assert(Math.hypot(report.keyboard.reset.x,report.keyboard.reset.z)<0.01);
  // Native UI button and narrow-screen simultaneous direction + Sprint touch.
  await page.mouse.click(68,105);await wait(300);report.keyboard.changed_view=await snapshot();assert.equal(report.keyboard.changed_view.view,1);
  await page.setViewport({width:390,height:844,isMobile:true,hasTouch:true});await wait(700);
  await page.screenshot({path:path.join(out,'phone-idle.png')});
  const cdp=await page.createCDPSession();
  const touch=[{x:109,y:844-212+31,id:1},{x:14+218+31,y:844-212+128+31,id:2}];
  const initial=await snapshot();
  await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:touch});
  await page.waitForFunction(()=>window.characterPlaytest?.state==='Dash',{timeout:8000});await wait(1000);
  report.touch.moving=await snapshot();assert(Math.hypot(report.touch.moving.x-initial.x,report.touch.moving.z-initial.z)>0.2);
  await page.screenshot({path:path.join(out,'phone-sprint.png')});
  await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
  await page.waitForFunction(()=>window.characterPlaytest?.state==='Idle',{timeout:8000});report.touch.stopped=await snapshot();
  assert.equal(report.errors.length,0,report.errors.join('\n'));
  fs.writeFileSync(path.join(out,'browser.json'),JSON.stringify(report,null,2)+'\n');
  console.log('PASS: keyboard walk/turn/sprint/stop/reset/view and narrow-screen two-finger sprint; no script errors');
 }finally{await browser.close()}
})().catch(e=>{console.error(e);process.exit(1)});
