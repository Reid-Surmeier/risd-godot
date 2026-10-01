// Isolated #182 walk: engine collision checks plus real keyboard round trip.
const fs = require('fs'), path = require('path');
const puppeteer = require(path.join(require('os').homedir(), 'promo-lab/node_modules/puppeteer-core'));
const wait = ms => new Promise(resolve => setTimeout(resolve, ms));
(async () => {
  const [url, out, width = '1100', mode = 'doorway'] = process.argv.slice(2);
  const front = mode === 'room-front';
  fs.mkdirSync(out, {recursive: true});
  const browser = await puppeteer.launch({executablePath: '/usr/bin/google-chrome', headless: 'new',
    args: ['--no-sandbox', '--use-gl=angle', '--use-angle=gl-egl', '--ignore-gpu-blocklist']});
  const errors = [], report = {url, errors};
  try {
    const page = await browser.newPage();
    report.viewport = {width: Number(width), height: 760};
    await page.setViewport(report.viewport);
    page.on('pageerror', error => errors.push(String(error)));
    page.on('console', message => { if (/SCRIPT ERROR|RuntimeError|Failed loading/.test(message.text())) errors.push(message.text()); });
    const start = Date.now();
    await page.goto(url + '?qa=1', {waitUntil: 'load', timeout: 90000});
    await page.waitForFunction(() => window.doorwayState, {timeout: 90000});
    report.first_ready_ms = Date.now() - start;
    await page.waitForFunction(() => window.doorwayState.phase === 4 && window.doorwayState.elapsed > 2.6, {timeout: 30000});
    await page.screenshot({path: path.join(out, 'browser-return-jamb.png')});
    await page.waitForFunction(() => window.doorwayResult, {timeout: 120000});
    report.engine = await page.evaluate(() => window.doorwayResult);
    await page.screenshot({path: path.join(out, 'browser-jamb.png')});
    await page.goto(url, {waitUntil: 'load', timeout: 90000});
    await page.waitForFunction(() => window.doorwayState, {timeout: 90000});
    await wait(500);
    await page.click('#canvas');
    const hold = async (keys, ms) => {
      for (const key of keys) await page.keyboard.down(key);
      await wait(ms);
      for (const key of keys) await page.keyboard.up(key);
      await wait(200);
    };
    if (mode !== 'room' && !front) await hold(['w', 'a'], 560);
    await hold([front ? 's' : mode === 'room' ? 'a' : 'w'], mode === 'room' || front ? 1400 : 1150);
    report.keyboard_forward = await page.evaluate(() => window.doorwayState);
    await page.screenshot({path: path.join(out, 'browser-forward.png')});
    await hold([front ? 'w' : mode === 'room' ? 'd' : 's'], mode === 'room' || front ? 1400 : 1150);
    if (mode !== 'room' && !front) await hold(['s', 'd'], 560);
    report.keyboard_reverse = await page.evaluate(() => window.doorwayState);
    await page.screenshot({path: path.join(out, 'browser-reverse.png')});
    report.browser = await browser.version();
    report.webgl_renderer = await page.evaluate(() => {
      const gl = document.querySelector('canvas').getContext('webgl2');
      const info = gl && gl.getExtension('WEBGL_debug_renderer_info');
      return info ? gl.getParameter(info.UNMASKED_RENDERER_WEBGL) : 'unavailable';
    });
    report.memory = await page.evaluate(() => performance.memory ? {
      used_js_heap_bytes: performance.memory.usedJSHeapSize,
      total_js_heap_bytes: performance.memory.totalJSHeapSize,
      caveat: 'JS heap only; excludes complete process, GPU and WASM allocation accounting'
    } : null);
    report.pass = Object.values(report.engine.checks).every(Boolean)
      && (front ? report.keyboard_forward.position[2] > 0.0 : mode === 'room' ? report.keyboard_forward.position[0] < -3.0 : report.keyboard_forward.position[2] < -1) && report.keyboard_forward.on_floor
      && (front ? report.keyboard_reverse.position[2] < -.8 : mode === 'room' ? report.keyboard_reverse.position[0] > -2.4 : report.keyboard_reverse.position[2] > 0.5) && report.keyboard_reverse.on_floor
      && errors.length === 0;
    fs.writeFileSync(path.join(out, 'browser-result.json'), JSON.stringify(report, null, 2));
    console.log(JSON.stringify(report));
    if (!report.pass) process.exitCode = 1;
  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
