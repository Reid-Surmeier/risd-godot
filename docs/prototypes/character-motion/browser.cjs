// Scratch export only; PLAYWRIGHT_PATH points at an existing installed package.
const {chromium} = require(process.env.PLAYWRIGHT_PATH || 'playwright');
const fs = require('node:fs');
(async () => {
  const browser = await chromium.launch({headless: true, args: ['--no-sandbox', '--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader']});
  const context = await browser.newContext({viewport: {width: 600, height: 600}, recordVideo: {dir: '/tmp/risd-171-browser', size: {width: 600, height: 600}}});
  const page = await context.newPage();
  const errors = [];
  page.on('pageerror', e => errors.push(String(e)));
  page.on('console', m => { if (m.type() === 'error') errors.push(m.text()); });
  await page.goto('http://127.0.0.1:8171?view=gallery');
  await page.waitForFunction(() => window.motionMetrics, null, {timeout: 120000});
  const metrics = await page.evaluate(() => window.motionMetrics);
  fs.writeFileSync('/tmp/risd-171-browser/metrics.json', JSON.stringify(metrics));
  fs.writeFileSync('/tmp/risd-171-browser/errors.json', JSON.stringify(errors));
  await page.screenshot({path: '/tmp/risd-171-browser/final.png'});
  await context.close();
  await browser.close();
  if (metrics.length !== 540 || errors.length) throw new Error(JSON.stringify({frames: metrics.length, errors}));
  console.log('PASS Web: 540 sampled poses; no console or page errors');
})();
