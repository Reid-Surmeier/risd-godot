// Browser camera and ephemeral generation adapter. Provider keys stay on the server.
window.booth = (() => {
  let video, stream, error = '', mode = 'none', ticket = 0;
  const canvas = document.createElement('canvas');
  canvas.width = 320; canvas.height = 240;
  const context = canvas.getContext('2d');
  async function start() {
    const request = ++ticket;
    stopTracks(); error = ''; mode = 'requesting';
    const timeout = setTimeout(() => {
      if (request === ticket) { ++ticket; stopTracks(); error = 'Timeout'; mode = 'denied'; }
    }, 15000);
    try {
      const incoming = await navigator.mediaDevices.getUserMedia({video: {width: 640, height: 480}, audio: false});
      if (request !== ticket) { incoming.getTracks().forEach(t => t.stop()); return; }
      stream = incoming;
      video = document.createElement('video');
      const playback = video;
      playback.muted = true; playback.playsInline = true; playback.srcObject = stream;
      await playback.play();
      if (request === ticket) mode = 'camera';
    } catch (e) {
      if (request === ticket) { stopTracks(); error = e.name; mode = 'denied'; }
    } finally { clearTimeout(timeout); }
  }
  function stopTracks() { stream?.getTracks().forEach(t => t.stop()); stream = null; video = null; }
  function stop() { ++ticket; stopTracks(); mode = 'none'; error = ''; }
  function status() {
    if (mode === 'camera' && !stream?.getVideoTracks().some(t => t.readyState === 'live')) {
      stopTracks(); error = 'CameraEnded'; mode = 'denied';
    }
    return JSON.stringify({mode, error});
  }
  function frame() {
    status();
    if (mode !== 'camera' || !video || video.readyState < 2) return '';
    try { context.drawImage(video, 0, 0, 320, 240); return canvas.toDataURL('image/jpeg', 0.55).split(',')[1]; }
    catch (e) { error = e.name; mode = 'denied'; stopTracks(); return ''; }
  }
  window.addEventListener('pagehide', stop);
  let generation = {mode:'idle'}, generationTicket=0, controller;
  async function generate(image) {
    const own=++generationTicket;controller?.abort();controller=new AbortController();generation={mode:'loading',completed:0};
    const timeout=setTimeout(()=>controller.abort(),700000);
    const id=crypto.randomUUID();const signal=controller.signal;
    try {
      let response=await fetch(new URL('api/portrait',document.baseURI),{method:'POST',headers:{'Content-Type':'application/json',Prefer:'respond-async'},body:JSON.stringify({id,image}),signal});
      while(response.status===202){
        const pending=await response.json();if(own!==generationTicket)return;
        const completed=pending.progress?.completed;
        if(pending.progress?.total===4&&Number.isInteger(completed)&&completed>=0&&completed<4)generation={mode:'loading',completed:Math.max(generation.completed??0,completed)};
        await new Promise(resolve=>setTimeout(resolve,1000));
        if(own!==generationTicket)return;
        response=await fetch(new URL('api/portrait/status',document.baseURI),{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({id}),signal});
      }
      const result=await response.json();
      if(!response.ok)throw Error(result.error||'Generation unavailable.');
      if(own===generationTicket)generation={mode:'ready',image:result.image,run:result.run,completed:4};
    }catch(e){if(own===generationTicket)generation={mode:'error',error:e.name==='AbortError'?'Generation timed out. This capture will not be retried automatically.':e.message};}
    finally {clearTimeout(timeout);}
  }
  function cancelGeneration(){++generationTicket;controller?.abort();controller=null;generation={mode:'idle'};}
  function generated(){return JSON.stringify(generation);}
  let worker, trackingTimer, trackingToken=0, trackingBusy=false, trackingState={mode:'idle',face:false}, baseline;
  function stopTracking(){++trackingToken;clearInterval(trackingTimer);worker?.terminate();worker=null;trackingBusy=false;baseline=null;trackingState={mode:'idle',face:false};}
  function startTracking(image){
    stopTracking();const token=trackingToken;trackingState={mode:'loading',face:false};
    worker=new Worker(new URL('tracking-worker.js',document.baseURI));
    worker.onerror=()=>{if(token!==trackingToken)return;trackingBusy=false;trackingState={mode:'unavailable',face:false};clearInterval(trackingTimer)};
    worker.onmessage=({data})=>{
      if(data.token!==trackingToken)return;
      trackingBusy=false;
      if(data.type==='ready')trackingState={mode:'ready',face:false,anchors:data.anchors};
      else if(data.type==='unavailable'){trackingState={mode:'unavailable',face:false};clearInterval(trackingTimer);}
      else if(data.type==='frame'){
        if(!data.face){trackingState={...trackingState,face:false,timestamp:data.timestamp};return;}
        baseline??={values:data.values,pose:data.pose};
        const values=Object.fromEntries(Object.entries(data.values).map(([key,value])=>[key,Math.max(0,Math.min(1,(value-baseline.values[key])/Math.max(0.1,1-baseline.values[key])))]));
        const bound=(n,min,max)=>Math.max(min,Math.min(max,n));
        trackingState={...trackingState,face:true,timestamp:data.timestamp,values,pose:{x:bound((data.pose.x-baseline.pose.x)*0.3,-0.025,0.025),y:bound((data.pose.y-baseline.pose.y)*0.3,-0.025,0.025),angle:bound(data.pose.angle-baseline.pose.angle,-0.12,0.12)},landmarks:data.landmarks};
      }
    };
    worker.postMessage({type:'portrait',token,image,base:new URL('tracking/',document.baseURI).href});
    trackingTimer=setInterval(async()=>{
      status();
      if(!video||mode!=='camera'){trackingState={...trackingState,face:false};return;}
      if(trackingBusy||trackingState.mode!=='ready'||video.readyState<2)return;
      trackingBusy=true;
      try{
        const bitmap=await createImageBitmap(video);
        if(token!==trackingToken){bitmap.close();return;}
        worker.postMessage({type:'frame',token,bitmap,timestamp:performance.now()},[bitmap]);
      }catch{if(token===trackingToken){trackingBusy=false;trackingState={...trackingState,face:false};}}
    },100);
  }
  function tracking(){return JSON.stringify({...trackingState,face:trackingState.face&&performance.now()-(trackingState.timestamp??0)<500});}
  window.addEventListener('pagehide',()=>{cancelGeneration();stopTracking()});
  let pendingAction='';
  function action(value){if(['camera','capture','reset'].includes(value))pendingAction=value;}
  function consumeAction(){const value=pendingAction;pendingAction='';return value;}
  return {action, consumeAction, start, stop, frame, status, generate, generated, cancelGeneration, startTracking, stopTracking, tracking};
})();
