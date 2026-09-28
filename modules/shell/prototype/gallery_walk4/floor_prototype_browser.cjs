// #168 throwaway exported-Web capture: same square poses as native floor capture.
const fs = require('fs');
const path = require('path');
const puppeteer = require('/home/reidsurmeier/promo-lab/node_modules/puppeteer-core');

(async () => {
  const [url, output] = process.argv.slice(2);
  fs.mkdirSync(output, { recursive: true });
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/google-chrome', headless: 'new',
    args: ['--no-sandbox', '--use-gl=angle', '--use-angle=gl-egl', '--ignore-gpu-blocklist'],
  });
  const errors = [];
  try {
    for (const width of [720, 1600]) {
      for (const view of [0, 1]) {
        const page = await browser.newPage();
        await page.setViewport({ width, height: width });
        page.on('pageerror', error => errors.push(String(error)));
        page.on('response', response => {
          if (response.status() >= 400 && !response.url().endsWith('/favicon.ico')) {
            errors.push(`${response.status()} ${response.url()}`);
          }
        });
        page.on('console', message => {
          // Chrome emits a generic console error for a missing favicon; the
          // response handler above keeps actual failed resource URLs visible.
          if (message.type() === 'error' && !message.text().startsWith('Failed to load resource:')) errors.push(message.text());
        });
        const target = new URL(url);
        target.searchParams.set('gameplay', '1');
        target.searchParams.set('floor_view', String(view));
        await page.goto(target.href, { waitUntil: 'load', timeout: 120000 });
        await page.waitForFunction(() => document.querySelector('canvas') !== null, { timeout: 120000 });
        await new Promise(resolve => setTimeout(resolve, 2500));
        await page.screenshot({ path: path.join(output, `${width}-view-${view}.png`) });
        await page.close();
      }
    }
    fs.writeFileSync(path.join(output, 'browser.json'), JSON.stringify({ widths: [720, 1600], views: [0, 1], errors }, null, 2));
    if (errors.length) throw Error(errors.join('\n'));
  } finally {
    await browser.close();
  }
})().catch(error => { console.error(error); process.exit(1); });
