const {chromium} = require(process.env.PLAYWRIGHT_PATH || 'playwright');
const fs = require('node:fs');
(async () => {
  const browser = await chromium.launch({headless:true,args:['--no-sandbox','--use-gl=angle','--use-angle=swiftshader','--enable-unsafe-swiftshader']});
  const dir = '/tmp/risd-159-evidence/browser';
  fs.mkdirSync(dir,{recursive:true});
  const context = await browser.newContext({viewport:{width:720,height:720},recordVideo:{dir,size:{width:720,height:720}}});
  const page = await context.newPage();
  const errors=[];
  page.on('pageerror',e=>errors.push(String(e)));
  page.on('console',m=>{if(m.type()==='error')errors.push(m.text());});
  await page.addInitScript(()=>{
    window.visitor159Samples=[];
    let previous=-1,clock;
    const tick=()=>{
      if(window.visitor159Ready){
        const demo=window.visitor159Demo||0;
        const wall=((window.visitor159Complete||performance.now())-window.visitor159Start)/1000;
        if(demo!==previous){window.visitor159Samples.push({demo,wall});previous=demo;}
        if(!clock){clock=document.createElement('div');clock.style='position:fixed;top:62px;left:12px;z-index:99999;background:#eee;color:#111;font:15px monospace;padding:4px';document.body.appendChild(clock);}
        clock.textContent=`${window.visitor159Complete?'COMPLETE ':''}WALL ${wall.toFixed(2)}s | DEMO ${demo.toFixed(2)}s`;
      }
      requestAnimationFrame(tick);
    };requestAnimationFrame(tick);
  });
  await page.goto('http://127.0.0.1:8159?capture');
  await page.waitForFunction(()=>window.visitor159Report,null,{timeout:180000});
  const data=await page.evaluate(()=>({report:window.visitor159Report,samples:window.visitor159Samples,start:window.visitor159Start,end:window.visitor159Complete}));
  fs.writeFileSync(dir+'/metrics.json',JSON.stringify(data));
  fs.writeFileSync(dir+'/errors.json',JSON.stringify(errors));
  await page.screenshot({path:dir+'/final.png'});
  const video=page.video();
  await context.close();
  await video.saveAs(dir+'/normal-speed.webm');
  await browser.close();
  const gaps=data.samples.slice(1).map((s,i)=>(s.wall-data.samples[i].wall)*1000).sort((a,b)=>a-b);
  const wall=(data.end-data.start)/1000;
  const summary={wall,demo:data.report.demo_seconds,ratio:data.report.demo_seconds/wall,frames:data.samples.length,medianMs:gaps[Math.floor(gaps.length*.5)],p95Ms:gaps[Math.floor(gaps.length*.95)],maxMs:gaps.at(-1),errors,detail:data.report.detail_seen,penetration:data.report.max_penetration,drift:data.report.max_planted_vertex_drift};
  fs.writeFileSync(dir+'/summary.json',JSON.stringify(summary,null,2));
  console.log(JSON.stringify(summary));
  if(errors.length||Math.abs(summary.ratio-1)>.05||!summary.detail||summary.penetration>.01||summary.drift>.02)process.exitCode=1;
})();
