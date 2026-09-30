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
    const own=++generationTicket;controller?.abort();controller=new AbortController();generation={mode:'loading'};
    const timeout=setTimeout(()=>controller.abort(),120000);
    try {
      const response=await fetch(new URL('api/portrait',document.baseURI),{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({id:crypto.randomUUID(),image}),signal:controller.signal});
      const result=await response.json();
      if(!response.ok)throw Error(result.error||'Generation unavailable.');
      if(own===generationTicket)generation={mode:'ready',image:result.image,run:result.run};
    }catch(e){if(own===generationTicket)generation={mode:'error',error:e.name==='AbortError'?'Generation timed out. This capture will not be retried automatically.':e.message};}
    finally {clearTimeout(timeout);}
  }
  function cancelGeneration(){++generationTicket;controller?.abort();controller=null;generation={mode:'idle'};}
  function generated(){return JSON.stringify(generation);}
  window.addEventListener('pagehide',cancelGeneration);
  return {start, stop, frame, status, generate, generated, cancelGeneration};
})();
