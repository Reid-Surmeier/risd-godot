import assert from 'node:assert/strict';
import {mkdir} from 'node:fs/promises';
import {chromium} from '/home/reidsurmeier/.npm-global/lib/node_modules/playwright/index.mjs';

const url = process.argv[2] ?? 'https://homework.reidsurmeier.wtf/';
const evidence = process.env.HOMEWORK_EVIDENCE ?? '/tmp/homework-review';
await mkdir(evidence, {recursive: true});
const browser = await chromium.launch({executablePath: '/usr/bin/google-chrome', args: ['--no-sandbox', '--enable-unsafe-swiftshader', '--host-resolver-rules=MAP *.reidsurmeier.wtf 104.21.36.62']});
try {
  const page = await browser.newPage();
  const errors = [];
  page.on('pageerror', error => errors.push(error.message));
  assert.equal((await page.goto(url)).status(), 200);
  assert.equal(await page.locator('style, link[rel="stylesheet"], [style]').count(), 0);
  assert.deepEqual(await page.locator('nav a').evaluateAll(links => links.map(link => link.getAttribute('href'))), [
    'https://shader.reidsurmeier.wtf/', 'https://ctchomework.reidsurmeier.wtf/', '/week-3/', '/week-4/'
  ]);
  await page.keyboard.press('Tab');
  assert.equal(await page.locator('nav a').first().evaluate(link => link === document.activeElement), true);
  for (const [name, width, height] of [['desktop', 1440, 1000], ['mobile', 390, 844]]) {
    await page.setViewportSize({width, height});
    assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true);
    await page.screenshot({path: `${evidence}/${name}.png`, fullPage: true});
  }
  assert.deepEqual(errors, []);
  if (url.startsWith('https:')) {
    for (const link of await page.locator('nav a').evaluateAll(links => links.map(link => link.href))) {
      const response = await page.goto(link);
      assert.equal(response.status(), 200, link);
      if (link.includes('shader.')) {
        await page.waitForFunction(() => document.querySelector('#code')?.value.includes('void main') && document.querySelector('canvas')?.width > 0);
        await page.waitForTimeout(1500);
        await page.screenshot({path: `${evidence}/week-1-shader.png`});
      }
    }
  }
  console.log('Homepage links, keyboard focus, desktop/mobile layout and destination responses passed.');
} finally { await browser.close(); }
