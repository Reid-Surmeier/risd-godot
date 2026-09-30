// Browser adapter. No provider keys, uploads or persistence in this unpaid prototype.
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
  function frame() {
    if (mode !== 'camera' || !video || video.readyState < 2) return '';
    try { context.drawImage(video, 0, 0, 320, 240); return canvas.toDataURL('image/jpeg', 0.55).split(',')[1]; }
    catch (e) { error = e.name; mode = 'denied'; stopTracks(); return ''; }
  }
  window.addEventListener('pagehide', stop);
  return {start, stop, frame, status: () => JSON.stringify({mode, error})};
})();
