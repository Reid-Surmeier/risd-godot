const fs=require('fs'),assert=require('assert/strict');
const puppeteer=require('/home/reidsurmeier/promo-lab/node_modules/puppeteer-core');
const wait=ms=>new Promise(r=>setTimeout(r,ms));
(async()=>{
 const [url,out]=process.argv.slice(2);fs.mkdirSync(out,{recursive:true});
 const b=await puppeteer.launch({executablePath:'/usr/bin/google-chrome',headless:true,protocolTimeout:300000,args:['--no-sandbox','--use-angle=swiftshader','--enable-unsafe-swiftshader']});
 try {
  const page=await b.newPage(),errors=[];await page.setViewport({width:800,height:600});
  page.on('pageerror',e=>errors.push(String(e)));
  page.on('console',m=>{if(m.type()==='error'&&!/404|2D MSAA|render_target_set_msaa/.test(m.text()))errors.push(m.text())});
  await page.goto(url+'?qa-crt=1&render_qa=1',{waitUntil:'domcontentloaded',timeout:120000});
  await page.waitForFunction(()=>window.galleryRenderCommand&&window.shellCrtQa?.shell.active===4&&!window.shellCrtQa.shell.switching&&!document.getElementById('status'),{timeout:240000});
  await page.setViewport({width:1080,height:1080});await wait(1500);
  const command=action=>page.evaluate(action=>window.galleryRenderCommand(JSON.stringify(action)),action);
  for(const scene of ['bench','floor','skylight','portal','warm']){await command({action:'pose',scene});await wait(700);await page.screenshot({path:out+'/'+scene+'.png'})}
  const state=async()=>{await command({action:'state'});return page.evaluate(()=>window.galleryRenderState)};
  await command({action:'pose',scene:'warm'});await command({action:'release'});await wait(250);const before=await state();
  await page.keyboard.down('s');await wait(850);const held=await state();await page.keyboard.up('s');await wait(700);const released=await state();await wait(400);const stopped=await state();
  const distance=(a,b)=>Math.hypot(...a.position.map((v,i)=>v-b.position[i]));
  assert(distance(before,held)>.2);assert(distance(released,stopped)<.01);assert.equal(before.camera_fov,held.camera_fov);assert.equal(before.visitor.identity,held.visitor.identity);assert.equal(stopped.paintings,23);assert.deepEqual(errors,[]);
  await page.screenshot({path:out+'/gameplay.png'});
  fs.writeFileSync(out+'/results.json',JSON.stringify({url,before,held,released,stopped,errors},null,2));
  console.log('WARM187 full-app captures, movement/release, fixed FOV, retained visitor and 23 paintings PASS');
 }finally{await b.close()}
})().catch(e=>{console.error(e);process.exitCode=1});
