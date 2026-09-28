import assert from 'node:assert/strict';
import { mkdirSync, writeFileSync } from 'node:fs';
const { chromium } = await import(process.env.PLAYWRIGHT_MODULE || 'playwright');
const [url, out] = process.argv.slice(2);
mkdirSync(out, { recursive: true });
const browser = await chromium.launch({ executablePath: '/usr/bin/google-chrome', args: ['--no-sandbox', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'] });
const results = [];
try {
  for (const width of [720, 1600]) {
    const page = await browser.newPage({ viewport: { width, height: width }, deviceScaleFactor: 1 });
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    await page.goto(url);
    for (let index = 0; index < 9; index++) {
      await page.evaluate(index => { window.scan154Request = index; }, index);
      await page.waitForFunction(index => window.scan154Ready === index, index, { timeout: 120000 });
      await page.screenshot({ path: `${out}/${width}-${String(index).padStart(2, '0')}.png` });
    }
    await page.evaluate(() => { window.scan154Interactive = true; });
    await page.waitForFunction(() => window.scan154State);
    const card = i => [(468 + (i % 4) * 143 + 67) * width / 1080, (184 + Math.floor(i / 4) * 137 + 64) * width / 1080];
    for (let i = 0; i < 20; i++) {
      await page.mouse.click(...card(i));
      await page.waitForFunction(i => window.scan154State.selected === i && window.scan154State.hovered === i, i);
    }
    await page.mouse.move(...card(2));
    await page.waitForFunction(() => window.scan154State.hovered === 2 && window.scan154State.rendering === 4);
    const yaw = await page.evaluate(() => window.scan154State.yaw);
    await page.waitForTimeout(750);
    assert.notEqual(await page.evaluate(() => window.scan154State.yaw), yaw);
    await page.screenshot({ path: `${out}/${width}-hover.png` });
    await page.mouse.move(width * 1030 / 1080, width * 1010 / 1080);
    await page.waitForFunction(() => window.scan154State.hovered === -1 && window.scan154State.selected === 19 && window.scan154State.rendering === 0);
    await page.screenshot({ path: `${out}/${width}-leave.png` });
    assert.deepEqual(errors, []);
    results.push({ width, angles: 6, heldStates: 3, realCardClicks: 20, hoverRotates: true, leaveDisablesRenderer: true, selectionPreserved: true, errors });
    await page.close();
  }
  writeFileSync(`${out}/result.json`, JSON.stringify(results, null, 2));
} finally { await browser.close(); }
