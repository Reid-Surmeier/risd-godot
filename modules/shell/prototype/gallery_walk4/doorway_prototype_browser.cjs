// Captures the exported Web scene, identical pose/size for before and after.
const fs = require('fs');
const puppeteer = require('/home/reidsurmeier/promo-lab/node_modules/puppeteer-core');
(async () => {
 const [url, out] = process.argv.slice(2); fs.mkdirSync(out, {recursive:true});
 const browser = await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:true,args:['--no-sandbox','--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist']});
 const errors=[];
 try {
  for (const width of [1600,720]) {
   const page=await browser.newPage(); await page.setViewport({width,height:Math.round(width*.75)});
   page.on('pageerror',e=>errors.push(String(e)));
   await page.goto(url, {waitUntil:'domcontentloaded',timeout:120000});
   await page.waitForFunction(()=>!document.querySelector('#status'),{timeout:120000});
   await new Promise(r=>setTimeout(r,1500));
   for (let i=0;i<4;i++) {
    await page.screenshot({path:`${out}/${width}-view-${i}.png`});
    await page.keyboard.press('ArrowRight'); await new Promise(r=>setTimeout(r,500));
   }
   await page.close();
  }
  fs.writeFileSync(`${out}/browser.json`,JSON.stringify({errors,widths:[1600,720],views:4},null,2));
  if(errors.length) throw Error(errors.join('\n'));
 } finally {await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});
