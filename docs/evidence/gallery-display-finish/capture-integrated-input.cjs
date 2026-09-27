// Reproduce the integrated default visitor clip with real browser keyboard events.
// source /home/reidsurmeier/promo-lab/gpu-env.sh
// node capture-integrated-input.cjs <commit-named-export-url> <output-directory>
const fs=require('fs'), path=require('path');
const puppeteer=require(process.env.PUPPETEER_MODULE || path.join(require('os').homedir(),'promo-lab/node_modules/puppeteer-core'));
const wait=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
 const url=new URL(process.argv[2]);url.searchParams.set('render_qa','1');
 if(url.searchParams.has('character'))throw new Error('This evidence must use the default character route');
 const out=process.argv[3];fs.mkdirSync(out,{recursive:true});
 const browser=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:'new',args:['--use-gl=angle','--use-angle=gl-egl','--ignore-gpu-blocklist','--no-sandbox']});
 try {
  const page=await browser.newPage();await page.setViewport({width:1600,height:900});
  const events=[],errors=[],states=[];let entered=false;
  page.on('console',m=>{const t=m.text();if(t.includes('ENTRY_COMPLETE'))entered=true;if(/ENTRY_COMPLETE|NAV_SPACE/.test(t))events.push(t);if(m.type()==='error')errors.push(t);});
  page.on('pageerror',e=>errors.push(String(e)));
  await page.goto(url.href,{waitUntil:'load',timeout:120000});
  await page.waitForFunction(()=>window.loadPerf?.some(m=>m.name==='game-shown')&&window.galleryRenderCommand,{timeout:120000});
  for(let n=0;n<100&&!entered;n++)await wait(100);
  if(!entered)throw new Error('Default entrance did not complete');
  const gpu=await page.evaluate(()=>{const gl=document.createElement('canvas').getContext('webgl2'),e=gl.getExtension('WEBGL_debug_renderer_info');return e?gl.getParameter(e.UNMASKED_RENDERER_WEBGL):'unknown';});
  if(/llvmpipe|swiftshader|software|unknown/i.test(gpu))throw new Error('Hardware capture required: '+gpu);
  const state=async label=>{await page.evaluate(()=>window.galleryRenderCommand(JSON.stringify({action:'state'})));const s=await page.evaluate(()=>window.galleryRenderState);if(!s.visitor?.identity)throw new Error('Default red-cap identity is absent');states.push({label,wall_ms:Date.now(),state:s});return s;};
  await state('entry-complete');await page.screenshot({path:path.join(out,'entry.png')});
  const video=await page.screencast({path:path.join(out,'default-input-motion.webm'),fps:30});
  await page.mouse.click(800,500);
  await page.keyboard.down('s');await wait(1800);await page.keyboard.up('s');await wait(200);await state('room-walk');
  await page.keyboard.down('w');await wait(650);await state('W');
  await page.keyboard.down('d');await wait(650);await state('W+D');
  await page.keyboard.up('w');await page.keyboard.up('d');
  await page.keyboard.down('s');await wait(800);await page.keyboard.up('s');await wait(250);await state('S-reversal-stop');
  for(let n=0;n<5;n++){
   const s=await state('align-door');const x=s.position[0];if(Math.abs(x)<.15)break;
   const key=x<0?'a':'d';await page.keyboard.down(key);await wait(Math.min(600,Math.max(120,Math.abs(x)/1.2*1000)));await page.keyboard.up(key);await wait(200);
  }
  await page.keyboard.down('w');let inWhite=false;
  for(let n=0;n<36;n++){await wait(250);const s=await state('approach-white');if(s.space==='arch'){inWhite=true;break;}}
  await wait(650);await page.keyboard.up('w');await wait(500);
  if(!inWhite)throw new Error('Real W input did not cross into white room');
  await page.keyboard.down('d');await wait(450);await page.keyboard.up('d');await wait(250);
  await page.keyboard.down('a');await wait(450);await page.keyboard.up('a');await wait(500);
  await state('white-room-stop');await page.screenshot({path:path.join(out,'white.png')});
  await video.stop();
  await page.setViewport({width:720,height:486});await wait(500);await page.screenshot({path:path.join(out,'white-720.png')});
  fs.writeFileSync(path.join(out,'input-motion.json'),JSON.stringify({url:url.href,gpu,events,states,errors},null,2));
  console.log(JSON.stringify({gpu,events,states:states.length,white_room:inWhite}));
 } finally {await browser.close();}
})().catch(e=>{console.error(e);process.exit(1)});
