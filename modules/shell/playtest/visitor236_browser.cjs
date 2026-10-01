// #236: walks the exported Collection with real keys and records what the page really plays.
// node modules/shell/playtest/visitor236_browser.cjs <url> <out-dir>
// Writes stage pictures, walk.webm, audio.webm and timeline.json; uses the host's Puppeteer/Chrome.
const fs = require('fs');
const path = require('path');
const puppeteer = require(process.env.PUPPETEER_MODULE || path.join(require('os').homedir(), 'promo-lab/node_modules/puppeteer-core'));
const pause = ms => new Promise(r => setTimeout(r, ms));
(async () => {
  const [url, out] = process.argv.slice(2);
  fs.mkdirSync(out, { recursive: true });
  const browser = await puppeteer.launch({ executablePath: '/usr/bin/google-chrome', headless: 'new', args: ['--use-gl=angle', '--use-angle=gl-egl', '--ignore-gpu-blocklist', '--no-sandbox', '--autoplay-policy=no-user-gesture-required'] });
  const log = [], errors = [];
  try {
    const p = await browser.newPage();
    await p.setViewport({ width: 1080, height: 1080 });
    p.on('console', m => { log.push(m.text()); if (m.type() === 'error') errors.push(m.text()); });
    p.on('pageerror', e => errors.push(String(e)));
    // Tee everything the game sends to the speakers into a recorder: proof of real output.
    await p.evaluateOnNewDocument(() => {
      const connect = AudioNode.prototype.connect;
      AudioNode.prototype.connect = function (target, ...rest) {
        if (target instanceof AudioDestinationNode) {
          const context = target.context;
          if (!context.__tap) {
            context.__tap = context.createMediaStreamDestination();
            const recorder = new MediaRecorder(context.__tap.stream, { mimeType: 'audio/webm;codecs=opus' });
            const chunks = [];
            recorder.ondataavailable = e => chunks.push(e.data);
            window.__audio = { started: performance.now(), stop: () => new Promise(resolve => {
              recorder.onstop = async () => {
                const bytes = new Uint8Array(await new Blob(chunks).arrayBuffer());
                let text = ''; for (let i = 0; i < bytes.length; i += 32768) text += String.fromCharCode(...bytes.subarray(i, i + 32768));
                resolve(btoa(text));
              };
              recorder.stop();
            }) };
            recorder.start();
          }
          connect.call(this, context.__tap, ...rest);
        }
        return connect.call(this, target, ...rest);
      };
    });
    await p.goto(url, { waitUntil: 'load', timeout: 120000 });
    await p.waitForFunction(() => window.loadPerf?.some(mark => mark.name === 'game-shown'), { timeout: 180000 });
    const end = Date.now() + 20000;
    while (!log.some(line => line.includes('ENTRY_COMPLETE ')) && Date.now() < end) await pause(100);
    if (!log.some(line => line.includes('ENTRY_COMPLETE '))) throw new Error('entrance did not complete');
    await p.waitForFunction(() => window.__audio, { timeout: 20000 });
    const now = () => p.evaluate(() => (performance.now() - window.__audio.started) / 1000);
    const timeline = [];
    const stage = async (name, seconds, key) => {
      const start = await now();
      if (key) await p.keyboard.down(key);
      await pause(seconds * 500);
      await p.screenshot({ path: path.join(out, `web-${name}.png`) });
      await pause(seconds * 500);
      if (key) await p.keyboard.up(key);
      timeline.push({ name, key: key || null, start, end: await now() });
      await pause(600);
    };
    const recorder = await p.screencast({ path: path.join(out, 'walk.webm'), fps: 30 });
    const videoStart = await now();
    await stage('idle', 3);
    await stage('walk-right', 3, 'KeyD');
    await stage('stop', 2);
    await stage('walk-left', 3, 'KeyA');
    await stage('walk-away', 2, 'KeyW');
    await stage('idle-after', 2);
    await recorder.stop();
    // Another Tab: the Collection is frozen, so the same key must make no sound.
    await p.mouse.click(133, 1060);
    await pause(1500);
    await stage('hidden-tab', 3, 'KeyD');
    fs.writeFileSync(path.join(out, 'audio.webm'), Buffer.from(await p.evaluate(() => window.__audio.stop()), 'base64'));
    fs.writeFileSync(path.join(out, 'timeline.json'), JSON.stringify({ url, videoStart, timeline, errors }, null, 1));
    console.log(JSON.stringify({ stages: timeline.length, errors: errors.length }));
  } catch (e) { console.error(log.slice(-15).join('\n')); throw e; } finally { await browser.close(); }
})().catch(e => { console.error(e); process.exit(1); });
