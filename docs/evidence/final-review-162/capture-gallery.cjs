const fs=require('fs'),assert=require('assert/strict'),p=require('/home/reidsurmeier/promo-lab/node_modules/puppeteer-core');
const wait=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{const [base,out]=process.argv.slice(2);fs.mkdirSync(out,{recursive:true});const b=await p.launch({executablePath:'/usr/bin/google-chrome',headless:true,protocolTimeout:300000,args:['--no-sandbox','--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist']});
try{const page=await b.newPage(),errors=[],states=[];await page.setViewport({width:1080,height:1080});page.on('pageerror',e=>errors.push(String(e)));page.on('console',m=>{if(m.type()==='error'&&!/404|2D MSAA|render_target_set_msaa/.test(m.text()))errors.push(m.text())});const url=new URL(base);url.searchParams.set('qa-crt','1');url.searchParams.set('render_qa','1');await page.goto(url.href,{waitUntil:'domcontentloaded',timeout:120000});await page.waitForFunction(()=>window.shellCrtQa?.shell.active===4&&!window.shellCrtQa.shell.switching&&!document.getElementById('status'),{timeout:240000});
const state=()=>page.evaluate(()=>window.shellCrtQa);const rect=r=>Array.isArray(r)?r:r.match(/-?\d+(?:\.\d+)?/g).map(Number);const center=r=>{const[x,y,w,h]=rect(r);return[x+w/2,y+h/2]};
function screen([x,y],s){const[ox,oy,dw,dh]=s.stage_rect,qx=x/1080-.5,qy=y/1080-.5,a=.018*(qx*qx+qy*qy),c=1+.018/4,k=2*c/(1+Math.sqrt(1+4*a*c));return[ox+(qx*k+.5)*dw,oy+(qy*k+.5)*dh]}
async function click(r){await page.mouse.click(...screen(center(r),await state()));await wait(700)}
async function tab(i){await click((await state()).shell.tabs[i].rect);await page.waitForFunction(i=>window.shellCrtQa.shell.active===i&&!window.shellCrtQa.shell.switching,{},i);await wait(900)}
async function shot(name){await page.screenshot({path:`${out}/${name}.png`});states.push({name,state:await state()})}
await page.waitForFunction(()=>window.galleryRenderCommand,{timeout:240000});
for(const scene of ['warm','art','bench','skylight','wall','portal','floor']){
 await page.evaluate(scene=>window.galleryRenderCommand(JSON.stringify({action:'pose',scene})),scene);
 await wait(700);await shot(scene);
}
assert.deepEqual(errors,[]);fs.writeFileSync(`${out}/states.json`,JSON.stringify({states,errors},null,2));console.log('FINAL_DETAILS seven framed views PASS');
}finally{await b.close()}})().catch(e=>{console.error(e);process.exitCode=1});
