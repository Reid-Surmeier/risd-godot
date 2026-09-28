// Scratch export only; PLAYWRIGHT_PATH points at an existing installed package.
const {chromium} = require(process.env.PLAYWRIGHT_PATH || 'playwright');
const fs = require('node:fs');
(async () => {
  const browser = await chromium.launch({headless: true, args: ['--no-sandbox', '--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader']});
  const context = await browser.newContext({viewport: {width: 600, height: 600}, recordVideo: {dir: '/tmp/risd-171-browser', size: {width: 600, height: 600}}});
  const page = await context.newPage();
  await page.addInitScript(() => {
    window.wallSamples = [];
    let previous = -1;
    let clock;
    const sample = () => {
      const p = window.motionProgress;
      if (p && p.frame !== previous) {
        window.wallSamples.push({...p, wall_ms: performance.now()});
        previous = p.frame;
      }
      if (p && document.body) {
        if (!clock) {
          clock = document.createElement('div');
          clock.style = 'position:fixed;left:12px;top:62px;z-index:99999;color:black;background:#dadbd8;font:15px monospace;padding:3px';
          document.body.appendChild(clock);
        }
        const wall = ((window.motionComplete ? window.wallSamples.at(-1).wall_ms : performance.now()) - window.wallSamples[0].wall_ms) / 1000;
        clock.textContent = `${window.motionComplete ? 'COMPLETE ' : ''}WALL ${wall.toFixed(2)}s | DEMO ${p.demo_seconds.toFixed(2)}s`;
      }
      requestAnimationFrame(sample);
    };
    requestAnimationFrame(sample);
  });
  const errors = [];
  page.on('pageerror', e => errors.push(String(e)));
  page.on('console', m => { if (m.type() === 'error') errors.push(m.text()); });
  await page.goto('http://127.0.0.1:8171?view=gallery');
  const seconds = Number(process.env.TIMING_SECONDS || 0);
  if (seconds) {
    await page.waitForFunction(seconds => window.motionProgress?.demo_seconds >= seconds, seconds, {timeout: 120000});
  } else {
    await page.waitForFunction(() => window.motionMetrics, null, {timeout: 120000});
  }
  const metrics = await page.evaluate(() => window.motionMetrics || []);
  if (metrics.length) fs.writeFileSync('/tmp/risd-171-browser/metrics.json', JSON.stringify(metrics));
  const samples = await page.evaluate(() => window.wallSamples);
  const first = samples[0], last = samples.at(-1);
  const wallSeconds = (last.wall_ms - first.wall_ms) / 1000;
  const demoSeconds = last.demo_seconds - first.demo_seconds;
  const gaps = samples.slice(1).map((s, i) => s.wall_ms - samples[i].wall_ms).sort((a, b) => a - b);
  const timing = {wallSeconds, demoSeconds, ratio: demoSeconds / wallSeconds,
    intervalsMs: {median: gaps[Math.floor(gaps.length / 2)], p95: gaps[Math.floor(gaps.length * .95)], max: gaps.at(-1)}, samples};
  fs.writeFileSync('/tmp/risd-171-browser/timing.json', JSON.stringify(timing));
  fs.writeFileSync('/tmp/risd-171-browser/errors.json', JSON.stringify(errors));
  await page.screenshot({path: '/tmp/risd-171-browser/final.png'});
  await context.close();
  await browser.close();
  console.log(JSON.stringify({wallSeconds, demoSeconds, ratio: timing.ratio, frames: samples.length, intervalsMs: timing.intervalsMs}));
  if (Math.abs(timing.ratio - 1) > 0.05) throw new Error('Playback is not 1:1 with browser wall time');
  if ((!seconds && metrics.at(-1)?.time < 17.9) || errors.length) throw new Error(JSON.stringify({frames: metrics.length, errors}));
  console.log('PASS Web: wall-clock playback; no console or page errors');
})();
