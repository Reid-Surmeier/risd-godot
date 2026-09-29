const fs=require('fs'),assert=require('assert'),puppeteer=require('/home/reidsurmeier/promo-lab/node_modules/puppeteer-core');
(async()=>{
const browser=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:true,args:['--no-sandbox','--use-angle=swiftshader','--enable-unsafe-swiftshader']});
try {
const page=await browser.newPage(); await page.setViewport({width:720,height:720});
const errors=[];page.on('pageerror',e=>errors.push(String(e)));
await page.goto('https://windows-wsl.taile06c45.ts.net/risd-portal-latest-01a0e95d/?view=9&loader=2',{waitUntil:'domcontentloaded',timeout:120000});
await page.waitForFunction(()=>window.loaderProgress>0,{timeout:120000});
assert(await page.$('#loading-frag')); assert(await page.$('#status'));
await page.screenshot({path:'/mnt/c/Temp/risd-portal-loader-visible.png'});
await page.waitForFunction(()=>!document.getElementById('status'),{timeout:180000});
await page.screenshot({path:'/mnt/c/Temp/risd-portal-loader-finished.png'});
assert.deepEqual(errors,[]);
console.log('PASS shared portal: custom loader visible, completes, zero page errors');
}finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});
