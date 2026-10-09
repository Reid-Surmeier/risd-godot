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
for(let i=0;i<7;i++){await tab(i);if(i===3){await page.waitForFunction(()=>window.shellCrtQa.tenant.playing&&window.shellCrtQa.tenant.stream_position>.3,{timeout:120000})}if(i===6){await page.waitForFunction(()=>document.querySelector("#flowers-game ruffle-player")?.metadata,{timeout:120000});await wait(4000)}await page.mouse.move(10,40);await shot(`tab-${i}`)}
await tab(2);for(let i=0;i<4;i++){await click((await state()).tenant.cards[i]);let t=(await state()).tenant;assert.equal(t.model_loaded,true);await shot(`viewer-${i}-preview`);await page.mouse.move(10,40);await wait(700);await shot(`viewer-${i}`)}
await tab(5);const nav=(await state()).tenant.navigation;for(const[name,r]of Object.entries(nav)){await click(r);await page.mouse.move(10,40);await wait(700);await shot(`playground-${(await state()).tenant.page}`)}
await tab(4);
const command=action=>page.evaluate(action=>window.galleryRenderCommand(JSON.stringify(action)),action);
for(const scene of ['bench','floor','wall','skylight','portal','warm']){await command({action:'pose',scene});await wait(700);await shot(`gallery-${scene}`)}
for(const [w,h]of[[1080,1080],[1920,1080],[1080,1920],[720,486],[486,720]]){
 await page.setViewport({width:w,height:h});await wait(700);const s=await state(),d=Math.min(w,h);
 assert.deepEqual(s.stage_rect,[(w-d)/2,(h-d)/2,d,d]);await shot(`fit-${w}x${h}`);
}
await tab(2);await shot('viewer-portrait');await tab(1);await shot('sketchbook-portrait');
await page.setViewport({width:1080,height:1080});await page.waitForFunction(()=>JSON.stringify(window.shellCrtQa?.stage_rect)==='[0,0,1080,1080]');await tab(4);await command({action:'pose',scene:'warm'});await command({action:'release'});await wait(400);
const recorder=await page.screencast({path:`${out}/visitor-motion.webm`,ffmpegPath:'/usr/bin/ffmpeg'});
for(const key of ['s','d','w','a']){await page.keyboard.down(key);await wait(1200);await page.keyboard.up(key);await wait(450)}
await recorder.stop();await shot('visitor-after-movement');
const renderer=await page.evaluate(()=>{const gl=document.createElement('canvas').getContext('webgl2'),e=gl?.getExtension('WEBGL_debug_renderer_info');return e?gl.getParameter(e.UNMASKED_RENDERER_WEBGL):null});
fs.writeFileSync(`${out}/renderer.json`,JSON.stringify({renderer},null,2));
assert.deepEqual(errors,[]);fs.writeFileSync(`${out}/states.json`,JSON.stringify({states,errors},null,2));console.log('FINAL_TABS seven tabs, four live scans and Playground pages PASS');
}catch(error){
const pages=await b.pages();for(const page of pages){if(!page.isClosed()&&page.url().includes("ba6b3c05")){const failure=await page.evaluate(()=>({state:window.shellCrtQa,crt:window.crtQaState,dom:{active:document.activeElement?.tagName,flowers:document.querySelector('#flowers-game')?.getAttribute('style')}}));fs.writeFileSync(`${out}/failure-state.json`,JSON.stringify(failure,null,2));await page.screenshot({path:`${out}/failure.png`});break}}throw error
}finally{await b.close()}})().catch(e=>{console.error(e);process.exitCode=1});
