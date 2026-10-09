const fs=require('fs'),assert=require('assert/strict'),p=require('/home/reidsurmeier/promo-lab/node_modules/puppeteer-core');
const wait=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{const [base,out]=process.argv.slice(2);fs.mkdirSync(out,{recursive:true});const b=await p.launch({executablePath:'/usr/bin/google-chrome',headless:true,protocolTimeout:300000,args:['--no-sandbox','--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist']});
try{const page=await b.newPage(),errors=[],states=[];await page.setViewport({width:1080,height:1080});page.on('pageerror',e=>errors.push(String(e)));page.on('console',m=>{if(m.type()==='error'&&!/404|2D MSAA|render_target_set_msaa/.test(m.text()))errors.push(m.text())});const url=new URL(base);url.searchParams.set('qa-crt','1');await page.goto(url.href,{waitUntil:'domcontentloaded',timeout:120000});await page.waitForFunction(()=>window.shellCrtQa?.shell.active===4&&!window.shellCrtQa.shell.switching&&!document.getElementById('status'),{timeout:240000});
const state=()=>page.evaluate(()=>window.shellCrtQa);const rect=r=>Array.isArray(r)?r:r.match(/-?\d+(?:\.\d+)?/g).map(Number);const center=r=>{const[x,y,w,h]=rect(r);return[x+w/2,y+h/2]};
function screen([x,y],s){const[ox,oy,dw,dh]=s.stage_rect,qx=x/1080-.5,qy=y/1080-.5,a=.018*(qx*qx+qy*qy),c=1+.018/4,k=2*c/(1+Math.sqrt(1+4*a*c));return[ox+(qx*k+.5)*dw,oy+(qy*k+.5)*dh]}
async function click(r){await page.mouse.click(...screen(center(r),await state()));await wait(700)}
async function tab(i){await click((await state()).shell.tabs[i].rect);await page.waitForFunction(i=>window.shellCrtQa.shell.active===i&&!window.shellCrtQa.shell.switching,{},i);await wait(900)}
async function shot(name){await page.screenshot({path:`${out}/${name}.png`});states.push({name,state:await state()});fs.writeFileSync(`${out}/states.json`,JSON.stringify({states,errors},null,2))}
await tab(5);
for(const key of ['Page_explore','Page_all','Page_channels','Page_search']) {await click((await state()).tenant.navigation[key]);await page.mouse.move(10,40);await shot(key)}
async function clientPoint(x,y){const s=await state(),r=rect(s.tenant.navigation.Page_explore),f=r[3]/34;return screen([r[0]+(x-36)*f,r[1]+(y-87)*f],s)}
await page.mouse.click(...await clientPoint(36+150,172+68+20));await page.keyboard.type('portrait');await page.keyboard.press('Enter');await wait(1000);
assert.equal((await state()).tenant.query,'portrait');assert((await state()).tenant.results.length>0 && (await state()).tenant.results.length<25);await shot('search-results');
await page.mouse.click(...await clientPoint(36+200,172+330+100));await wait(700);await shot('detail');
await page.mouse.click(...await clientPoint(20+500-80,30+36));await wait(500);
await click((await state()).tenant.navigation.Page_explore);await page.mouse.move(10,40);await shot('final-explore');
const firstId=(await state()).tenant.results[0];
console.log("SAVE_POINT",JSON.stringify(await clientPoint(36+50,172+74+51+262+30+14)),JSON.stringify((await state()).tenant));
await page.mouse.click(...await clientPoint(36+50,172+74+51+262+30+14));await wait(1000);await shot("save-attempt");console.log("SAVE_AFTER",JSON.stringify((await state()).tenant));
assert((await state()).tenant.saved_ids.some(id=>Number(id)===firstId));await shot('saved');
await page.mouse.move(...await clientPoint(250,500));await page.mouse.wheel({deltaY:12000});await wait(1200);await shot('scroll-end');
assert.equal(await page.evaluate(()=>window.scrollY),0);assert.equal((await state()).shell.active,5);
assert.deepEqual(errors,[]);fs.writeFileSync(`${out}/states.json`,JSON.stringify({states,errors},null,2));console.log('PLAYGROUND175 four pages, typed search and detail interaction PASS');
}finally{await b.close()}})().catch(e=>{console.error(e);process.exitCode=1});
