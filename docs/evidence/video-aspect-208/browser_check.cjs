const fs=require('fs'),assert=require('assert/strict'),p=require('/home/reidsurmeier/promo-lab/node_modules/puppeteer-core');
const wait=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{const [base,out]=process.argv.slice(2);fs.mkdirSync(out,{recursive:true});const b=await p.launch({executablePath:'/usr/bin/google-chrome',headless:true,protocolTimeout:300000,args:process.env.GALLIUM_DRIVER?['--no-sandbox','--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist','--autoplay-policy=no-user-gesture-required']:['--no-sandbox','--use-angle=swiftshader','--enable-unsafe-swiftshader','--autoplay-policy=no-user-gesture-required']});
try{const page=await b.newPage(),errors=[],states=[];await page.setViewport({width:800,height:600});page.on('pageerror',e=>errors.push(String(e)));page.on('console',m=>{if(m.type()==='error'&&!/404|2D MSAA|render_target_set_msaa/.test(m.text()))errors.push(m.text())});const url=new URL(base);url.searchParams.set('qa-crt','1');url.searchParams.set('render_qa','1');await page.goto(url.href,{waitUntil:'domcontentloaded',timeout:120000});await page.waitForFunction(()=>window.shellCrtQa?.shell.active===4&&!window.shellCrtQa.shell.switching&&!document.getElementById('status'),{timeout:240000});
await page.setViewport({width:1080,height:1080});await wait(1200);
const state=()=>page.evaluate(()=>window.shellCrtQa);const rect=r=>Array.isArray(r)?r:r.match(/-?\d+(?:\.\d+)?/g).map(Number);const center=r=>{const[x,y,w,h]=rect(r);return[x+w/2,y+h/2]};
function screen([x,y],s){const[ox,oy,dw,dh]=s.stage_rect,qx=x/1080-.5,qy=y/1080-.5,a=.018*(qx*qx+qy*qy),c=1+.018/4,k=2*c/(1+Math.sqrt(1+4*a*c));return[ox+(qx*k+.5)*dw,oy+(qy*k+.5)*dh]}
async function click(r){await page.mouse.click(...screen(center(r),await state()));await wait(700)}
async function tab(i){await click((await state()).shell.tabs[i].rect);await page.waitForFunction(i=>window.shellCrtQa.shell.active===i&&!window.shellCrtQa.shell.switching,{},i);await wait(900)}
async function shot(name){await page.screenshot({path:`${out}/${name}.png`});states.push({name,state:await state()})}
try {
await tab(3);
const sourceIds=['1191767929','1187745268','1014865523','1009870521','1008943970'];
for(let i=0;i<sourceIds.length;i++){
 await page.keyboard.press(String(i+1));await page.waitForFunction(id=>window.shellCrtQa.tenant.video_id===id&&window.shellCrtQa.tenant.playing&&window.shellCrtQa.tenant.stream_position>.3,{timeout:120000},sourceIds[i]);await wait(500);await shot(`source-${i}-window`);
 await page.keyboard.press('f');await wait(500);assert.equal((await state()).tenant.fullscreen,true);await shot(`source-${i}-fullscreen`);await page.keyboard.press('f');await wait(400);assert.equal((await state()).tenant.fullscreen,false);
}
await page.keyboard.press('1');
await page.waitForFunction(()=>window.shellCrtQa.tenant.playing&&window.shellCrtQa.tenant.stream_position>1,{timeout:120000});
await page.keyboard.press('Space');await wait(350);let paused=(await state()).tenant;assert.equal(paused.playing,false);await wait(600);assert.ok(Math.abs((await state()).tenant.stream_position-paused.stream_position)<.03);
await page.keyboard.press('Space');await wait(700);assert.equal((await state()).tenant.playing,true);assert.ok((await state()).tenant.stream_position>paused.stream_position+.25);
const seekBefore=(await state()).tenant.stream_position;
for(let i=0;i<3;i++){await page.keyboard.press('ArrowRight');await wait(250)}
assert.equal((await state()).shell.active,3);assert.ok((await state()).tenant.stream_position>seekBefore+14,'three Right keys seek fifteen seconds');
const seekRight=(await state()).tenant.stream_position;await page.keyboard.press('ArrowLeft');await wait(250);assert.ok((await state()).tenant.stream_position<seekRight-4,'Left seeks five seconds');
await wait(700);await shot('video-playing');
const recorder=await page.screencast({path:`${out}/video-playback.webm`,ffmpegPath:'/usr/bin/ffmpeg'});
for(let i=0;i<6;i++){await wait(1000);await shot(`video-frame-${i}`)}
await recorder.stop();await page.keyboard.press('f');await wait(600);assert.equal((await state()).tenant.fullscreen,true);await shot('video-fullscreen');await page.keyboard.press('f');await wait(500);assert.equal((await state()).tenant.fullscreen,false);
const returned=(await state()).tenant.stream_position;await page.keyboard.press('ArrowRight');await wait(250);assert.ok((await state()).tenant.stream_position>returned+4.5,'Right works after fullscreen return');await page.keyboard.press('ArrowLeft');await wait(250);assert.ok((await state()).tenant.stream_position<returned+2,'Left works after fullscreen return');
await page.keyboard.press('Space');await wait(300);const before=(await state()).tenant;assert.equal(before.playing,false);await tab(4);await wait(1200);await tab(3);const after=(await state()).tenant;assert.equal(after.playing,false);assert.ok(Math.abs(after.stream_position-before.stream_position)<.03);await shot('video-paused-return');
const keyboardNavigation=[];
for(const key of ['Space','Enter']){await tab(3);let reached=false;
 for(let step=0;step<30;step++){await page.keyboard.press('Tab');await wait(100);const candidate=await page.screenshot();await page.keyboard.press(key);await wait(450);const active=(await state()).shell.active;
  if(active!==3){fs.writeFileSync(`${out}/keyboard-${key.toLowerCase()}-focus.png`,candidate);keyboardNavigation.push({key,tab_steps:step+1,before:3,after:active});reached=true;break}
 }
 assert.ok(reached,`Tab then ${key} activates a Shell tab-selection control`);
} states.push({name:'keyboard-navigation',navigation:keyboardNavigation,state:await state()});
await tab(3);await page.keyboard.press('f');await wait(500);
for(const [w,h]of[[1920,1080],[1080,1920],[486,720]]){await page.setViewport({width:w,height:h});await wait(700);assert.equal((await state()).tenant.fullscreen,true);await shot(`fullscreen-fit-${w}x${h}`)}
await page.keyboard.press('f');await wait(500);assert.equal((await state()).tenant.fullscreen,false);await shot('window-portrait-return');
assert.deepEqual(errors,[]);fs.writeFileSync(`${out}/states.json`,JSON.stringify({states,paused_return:{before,after},errors},null,2));console.log('ASPECT208 five-source/window/fullscreen/viewport fits and actual playback/input/hidden-return PASS');
} catch(error){fs.writeFileSync(`${out}/failure-state.json`,JSON.stringify({state:await state(),states,errors},null,2));throw error}
}finally{await b.close()}})().catch(e=>{console.error(e);process.exitCode=1});
