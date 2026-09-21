// PLAYWRIGHT_MODULE=/installed/playwright/index.mjs node browser.mjs URL OUTPUT_DIR
import assert from 'node:assert/strict';
import {mkdirSync, writeFileSync} from 'node:fs';
const {chromium} = await import(process.env.PLAYWRIGHT_MODULE || 'playwright');
const out = process.argv[3];
mkdirSync(out, {recursive:true});
const browser = await chromium.launch({executablePath:'/usr/bin/google-chrome', headless:true,
  args:['--no-sandbox', '--enable-unsafe-swiftshader']});
const page = await browser.newPage({viewport:{width:1920,height:1080}});
const errors = [];
page.on('pageerror', error => errors.push(error.message));
page.on('console', message => {
  if (message.type() === 'error' && !message.location().url.endsWith('favicon.ico')) errors.push(message.text());
});
try {
  const url = new URL(process.argv[2]); url.searchParams.set('qa','1');
  await page.goto(url.href);
  await page.waitForFunction(() => window.playgroundProof?.count === '12 / 12 saved works', null, {timeout:90000});
  const center = async key => page.evaluate(key => {
    const [x,y,w,h] = window.playgroundProof.controls[key]; return [x+w/2,y+h/2];
  },key);
  await page.screenshot({path:out+'/browser-before.png'});
  await page.mouse.click(...await center('first'));
  await page.waitForFunction(() => window.playgroundProof.detail.includes('Prototype Vase 00'));
  await page.mouse.click(...await center('SavedQuery'));
  await page.keyboard.type('Drawing');
  await page.waitForFunction(() => window.playgroundProof.count === '6 / 12 saved works');
  await page.keyboard.press('Control+A'); await page.keyboard.type('no matches');
  await page.waitForFunction(() => window.playgroundProof.count === '0 / 12 saved works');
  await page.mouse.click(...await center('ClearFilter'));
  await page.waitForFunction(() => window.playgroundProof.count === '12 / 12 saved works');
  await page.mouse.move(...await center('SavedScroll')); await page.mouse.wheel(0,900);
  await page.waitForFunction(() => window.playgroundProof.scroll > 0);
  await page.screenshot({path:out+'/browser-after.png'});
  assert.deepEqual(errors, []);
  writeFileSync(out+'/browser.json', JSON.stringify({passed:true, checks:['selection','filter','no matches','clear','wheel','no browser errors'],
    state:await page.evaluate(() => window.playgroundProof), errors},null,2));
  console.log('PASS browser: selection, filter, no matches, clear, wheel, no errors');
} finally { await browser.close(); }
