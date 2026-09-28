import assert from 'node:assert/strict';
import { mkdirSync, writeFileSync } from 'node:fs';
const { chromium } = await import(process.env.PLAYWRIGHT_MODULE || 'playwright');
const [url, out] = process.argv.slice(2);
mkdirSync(out, { recursive: true });
const browser = await chromium.launch({ executablePath: '/usr/bin/google-chrome', args: ['--no-sandbox', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'] });
const errors = [];
try {
  for (const width of [720, 1600]) {
    const page = await browser.newPage({ viewport: { width, height: width }, deviceScaleFactor: 1 });
    page.on('pageerror', error => errors.push(error.message));
    await page.goto(url);
    for (let index = 0; index < 9; index++) {
      await page.evaluate(index => { window.scan154Request = index; }, index);
      await page.waitForFunction(index => window.scan154Ready === index, index, { timeout: 120000 });
      await page.screenshot({ path: `${out}/${width}-${String(index).padStart(2, '0')}.png` });
    }
    await page.close();
  }
  assert.deepEqual(errors, []);
  writeFileSync(`${out}/result.json`, JSON.stringify({ angles: [0,60,120,180,240,300], unavailable: [0,1,3], widths: [720,1600], errors }, null, 2));
} finally { await browser.close(); }
