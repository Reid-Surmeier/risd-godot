// Real entry and both portal roundtrips at desktop and narrow browser sizes.
const fs=require('fs'),path=require('path');
const puppeteer=require(path.join(require('os').homedir(),'promo-lab/node_modules/puppeteer-core'));
const wait=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
 const out=process.argv[3];fs.mkdirSync(out,{recursive:true});
 const browser=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:'new',args:['--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist','--no-sandbox']});
 const results=[];
 try{
 for(const width of [1600,720]){
  const p=await browser.newPage();await p.setViewport({width,height:900});const events=[],errors=[];
  p.on('console',m=>{if(/NAV_SPACE|ENTRY_COMPLETE/.test(m.text()))events.push(m.text());if(m.type()==='error')errors.push(m.text());});p.on('pageerror',e=>errors.push(String(e)));
  await p.goto(process.argv[2],{waitUntil:'load',timeout:120000});await p.waitForFunction(()=>window.loadPerf?.some(m=>m.name==='game-shown'),{timeout:120000});
  const record=await p.screencast({path:path.join(out,width+'-entry-portal.webm'),fps:30});
  await wait(700);await p.screenshot({path:path.join(out,width+'-entry.png')});await wait(2000);
  await p.screenshot({path:path.join(out,width+'-idle.png')});
  const hold=async(k,ms)=>{await p.keyboard.down(k);await wait(ms);await p.keyboard.up(k);await wait(300);};
  await hold('w',2700);await p.screenshot({path:path.join(out,width+'-white-arch.png')});
  await hold('s',1100);await p.screenshot({path:path.join(out,width+'-return-arch.png')});await record.stop();
  await hold('a',2000);await hold('w',23500);await hold('d',2000);await hold('w',1200);
  await p.screenshot({path:path.join(out,width+'-white-far.png')});await hold('s',1100);await p.screenshot({path:path.join(out,width+'-return-far.png')});
  for(const route of ['gallery -> arch','arch -> gallery','gallery -> far','far -> gallery'])if(!events.some(e=>e.includes(route)))throw Error(width+' missing '+route);
  results.push({width,events,errors});await p.close();
 }
 fs.writeFileSync(path.join(out,'browser.json'),JSON.stringify(results,null,2));
 if(results.some(r=>r.errors.some(e=>/SCRIPT ERROR|RuntimeError|Failed loading/.test(e))))throw Error('new runtime error');
 console.log('DOORWAY_BROWSER both portal roundtrips passed at1600 and720');
 }finally{await browser.close()}
})().catch(e=>{console.error(e);process.exit(1)});
