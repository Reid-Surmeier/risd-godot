const fs = require('fs'), path = require('path');
const puppeteer = require(path.join(require('os').homedir(), 'promo-lab/node_modules/puppeteer-core'));
(async () => {
  const out = process.argv[3]; fs.mkdirSync(out, {recursive: true});
  const browser = await puppeteer.launch({executablePath: '/usr/bin/google-chrome', headless: 'new', args: ['--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--no-sandbox']});
  const results = [];
  const views = process.argv[4] ? process.argv[4].split(',').map(Number) : [5, 6, 7];
  try {
    for (const width of [1600, 720]) for (const view of views) {
      const page = await browser.newPage(); await page.setViewport({width, height: width});
      const errors = [];
      page.on('console', m => {if (m.type() === 'error' && !m.text().startsWith('Failed to load resource')) errors.push(m.text());});
      page.on('pageerror', e => errors.push(String(e)));
      page.on('response', r => {if (r.status() >= 400 && !r.url().endsWith('/favicon.ico')) errors.push(`${r.status()} ${r.url()}`);});
      await page.goto(`${process.argv[2]}?view=${view}`, {waitUntil: 'load', timeout: 120000});
      await page.waitForFunction(() => [...document.querySelectorAll('canvas')].some(c => c.width > 0 && c.height > 0), {timeout: 120000});
      await page.waitForFunction(() => !document.getElementById('status'), {timeout: 180000});
      await new Promise(r => setTimeout(r, 500));
      await page.screenshot({path: path.join(out, `${width}-view-${view}.png`)});
      results.push({width, view, errors}); await page.close();
    }
  } finally {await browser.close();}
  fs.writeFileSync(path.join(out, 'browser.json'), JSON.stringify(results, null, 2));
  if (results.some(r => r.errors.length)) throw Error('Browser errors');
  console.log(`ARCHITECTURE_BROWSER ${results.length} captures, zero page errors`);
})().catch(e => {console.error(e); process.exit(1)});
