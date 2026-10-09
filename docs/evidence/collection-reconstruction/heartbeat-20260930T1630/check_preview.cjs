const fs = require('fs');
const puppeteer = require('/home/reidsurmeier/promo-lab/node_modules/puppeteer-core');
(async () => {
  const out = __dirname;
  const url = 'https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/heartbeat-20260930T1630/';
  const browser = await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:'new',args:['--no-sandbox']});
  try {
    const page = await browser.newPage(), errors = [];
    page.on('pageerror', e => errors.push(String(e)));
    await page.setViewport({width:1200,height:900});
    const response = await page.goto(url,{waitUntil:'networkidle0',timeout:60000});
    const images = await page.evaluate(() => [...document.images].map(i => ({src:i.getAttribute('src'),loaded:i.complete && i.naturalWidth>0})));
    if (response.status() !== 200 || images.length !== 6 || images.some(i => !i.loaded) || errors.length) throw Error('Preview failed');
    await page.screenshot({path:out+'/preview.png',fullPage:true});
    fs.writeFileSync(out+'/preview-check.json',JSON.stringify({url,http:response.status(),images,errors,pass:true},null,2));
    console.log('HTTP200; six images loaded; no page errors.');
  } finally { await browser.close(); }
})().catch(e => {console.error(e);process.exitCode=1;});
