// Actual exported gameplay roundtrip, visitor hidden by the prototype launcher.
const fs=require('fs'), puppeteer=require('/home/reidsurmeier/promo-lab/node_modules/puppeteer-core');
const wait=ms=>new Promise(resolve=>setTimeout(resolve,ms));
(async()=>{
 const [url,out]=process.argv.slice(2); fs.mkdirSync(out,{recursive:true});
 const browser=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:true,args:['--no-sandbox','--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist']});
 const results=[];
 try {
  for(const width of [1600,720]) {
   const page=await browser.newPage(); await page.setViewport({width,height:Math.round(width*.75)});
   await page.setRequestInterception(true);
   page.on('request',r=>new URL(r.url()).pathname==='/favicon.ico'?r.respond({status:204}):r.continue());
   const events=[],errors=[];
   page.on('console',m=>{if(/NAV_SPACE|DOORWAY_GAMEPLAY_READY/.test(m.text()))events.push(m.text());if(m.type()==='error')errors.push(m.text());});
   page.on('pageerror',e=>errors.push(String(e)));
   await page.goto(url+'?gameplay=1',{waitUntil:'domcontentloaded',timeout:120000});
   for(let i=0;i<240&&!events.some(e=>e.includes('READY'));i++)await wait(500);
   if(!events.some(e=>e.includes('READY')))throw Error('Gameplay did not start: '+errors.join('\n'));
   await wait(1000);
   const video=await page.screencast({path:`${out}/${width}-roundtrip.webm`,fps:20});
   await page.screenshot({path:`${out}/${width}-approach.png`});
   for(const [key,route,label] of [['w','gallery -> far','inside'],['s','far -> gallery','return']]) {
    await page.keyboard.down(key);
    for(let i=0;i<100&&!events.some(e=>e.includes(route));i++)await wait(100);
    await page.keyboard.up(key); await wait(600);
    await page.screenshot({path:`${out}/${width}-${label}.png`});
    if(!events.some(e=>e.includes(route)))throw Error('Missing portal transition '+route);
   }
   await video.stop(); results.push({width,events,errors}); await page.close();
  }
  fs.writeFileSync(`${out}/browser.json`,JSON.stringify(results,null,2));
  if(results.some(r=>r.errors.length))throw Error('Browser runtime errors');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});
