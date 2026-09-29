// #173 owner regression: actual full-app export across the required resize matrix.
const fs = require('fs'), assert = require('assert/strict');
const puppeteer = require('/home/reidsurmeier/promo-lab/node_modules/puppeteer-core');
(async () => {
 const [url, out] = process.argv.slice(2); fs.mkdirSync(out,{recursive:true});
 const browser = await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:true,protocolTimeout:300000,args:['--no-sandbox','--use-angle=swiftshader','--enable-unsafe-swiftshader']});
 const page = await browser.newPage(), errors = [], rows = [];
 page.on('pageerror', e => errors.push(String(e)));
 page.on('console', m => {if(m.type()==='error' && !/404|2D MSAA|render_target_set_msaa/.test(m.text())) errors.push(m.text());});
 try {
  await page.setViewport({width:1080,height:1080});
  await page.goto(url+'?qa-crt=1', {waitUntil:'domcontentloaded',timeout:120000});
  await page.waitForFunction(()=>window.shellCrtQa?.shell.active===4 && !window.shellCrtQa.shell.switching && !document.getElementById('status'),{timeout:240000});
  for(const [width,height] of [[1080,1080],[1920,1080],[1080,1920],[720,486],[486,720]]) {
   await page.setViewport({width,height});
   await page.waitForFunction(([w,h])=>window.shellCrtQa?.display_size[0]===w && window.shellCrtQa?.display_size[1]===h,{},[width,height]);
   await new Promise(r=>setTimeout(r,1000));
   const state=await page.evaluate(()=>window.shellCrtQa);
   const side=Math.min(width,height);
   assert.deepEqual(state.stage_rect,[(width-side)/2,(height-side)/2,side,side]);
   await page.screenshot({path:`${out}/${width}x${height}.png`});
   rows.push({width,height,stage:state.stage_rect});
  }
  await page.setViewport({width:1080,height:1080});
  await page.keyboard.down('s'); await new Promise(r=>setTimeout(r,1200)); await page.keyboard.up('s');
  await page.screenshot({path:`${out}/walk.png`});
  assert.deepEqual(errors,[]);
  fs.writeFileSync(`${out}/browser.json`,JSON.stringify({rows,errors},null,2));
  console.log('COLLECTION_BROWSER PASS five viewport shapes and real movement input; inspect captures');
 } finally {await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});
