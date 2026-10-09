const fs=require('fs'),assert=require('assert/strict'),p=require('/home/reidsurmeier/promo-lab/node_modules/puppeteer-core');
(async()=>{const out='docs/evidence/identifier-names-222/shirt-pair';fs.mkdirSync(out,{recursive:true});const rows=[];
for(const [name,url] of [['baseline','https://windows-wsl.taile06c45.ts.net/risd-values-current-01a0f35e/6d126dbb.html'],['candidate','https://windows-wsl.taile06c45.ts.net/risd-names-current-01a0f379/2208eaba.html']]) {
 const b=await p.launch({executablePath:'/usr/bin/google-chrome',headless:true,protocolTimeout:300000,args:['--no-sandbox','--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist']});
 try{const page=await b.newPage();await page.setViewport({width:1080,height:1080});const errors=[];page.on('pageerror',e=>errors.push(String(e)));await page.goto(url+'?qa-crt=1&render_qa=1',{waitUntil:'domcontentloaded',timeout:120000});await page.waitForFunction(()=>window.shellCrtQa?.shell.active===4&&!window.shellCrtQa.shell.switching&&!document.getElementById('status'),{timeout:240000});
 await page.evaluate(()=>window.galleryRenderCommand(JSON.stringify({action:'pose',scene:'warm'})));await new Promise(r=>setTimeout(r,1000));await page.screenshot({path:`${out}/${name}-warm.png`});rows.push({name,url,state:await page.evaluate(()=>window.shellCrtQa),render:await page.evaluate(()=>window.galleryRenderQa),errors});console.log('SHIRT_PAIR222',name,'captured');assert.deepEqual(errors,[]);
 }finally{await b.close()}
}
fs.writeFileSync(`${out}/states.json`,JSON.stringify(rows,null,2));})().catch(e=>{console.error(e);process.exitCode=1});
