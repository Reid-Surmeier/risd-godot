import assert from 'node:assert/strict';
const { chromium } = await import(process.env.PLAYWRIGHT_MODULE || 'playwright');

const url = new URL(process.argv[2]);
url.searchParams.set('paintbox', 'anri');
url.searchParams.set('qa-crt', '1');
url.searchParams.set('crt', '0');

const browser = await chromium.launch({
  headless: true,
  executablePath: '/usr/bin/google-chrome',
  args: ['--no-sandbox', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'],
});
const page = await browser.newPage({ viewport: { width: 1920, height: 1080 } });
page.on('console', message => console.log(`browser console: ${message.text()}`));
page.on('pageerror', error => console.log(`browser error: ${error.message}`));
await page.goto(url.href, { waitUntil: 'domcontentloaded', timeout: 120_000 });
await page.waitForFunction(() => window.shellCrtQa?.shell?.tabs?.some(({ key }) => key === 'sketchbook'), null, { timeout: 120_000 });
await page.keyboard.press('F9');
await page.waitForFunction(() => window.squiggleQaState?.enabled === false);

let state = await page.evaluate(() => window.shellCrtQa);
const clickTab = async key => {
  const rect = (await page.evaluate(key => window.shellCrtQa.shell.tabs.find(tab => tab.key === key).rect, key)).map(Number);
  await page.mouse.click(rect[0] + rect[2] / 2, rect[1] + rect[3] / 2);
};
await clickTab('sketchbook');
await page.waitForFunction(() => window.shellCrtQa?.tenant?.chat_input_rect);
state = await page.evaluate(() => window.shellCrtQa.tenant);
const center = rect => [Number(rect[0]) + Number(rect[2]) / 2, Number(rect[1]) + Number(rect[3]) / 2];

await page.mouse.click(...center(state.chat_input_rect));
await page.keyboard.type('Hello from the browser');
await page.keyboard.press('Enter');
await page.waitForFunction(() => window.shellCrtQa?.tenant?.chat_text_posts === 1);

state = await page.evaluate(() => window.shellCrtQa.tenant);
const picker = page.locator('input[type="file"][aria-label="Post an image"]');
assert.equal(await picker.count(), 1, 'browser image picker is mounted');
const pickerBox = await picker.boundingBox();
const attachCenter = center(state.chat_attach_rect);
assert.ok(pickerBox && Math.abs(pickerBox.x + pickerBox.width / 2 - attachCenter[0]) < 3 && Math.abs(pickerBox.y + pickerBox.height / 2 - attachCenter[1]) < 3,
  'browser image picker covers the visible attach button');
const chooserPromise = page.waitForEvent('filechooser');
await picker.click();
const chooser = await chooserPromise;
await chooser.setFiles({
  name: 'blue-dot.png',
  mimeType: 'image/png',
  buffer: Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAIAAAACAQMAAABIeJ9nAAAAIGNIUk0AAHomAACAhAAA+gAAAIDoAAB1MAAA6mAAADqYAAAXcJy6UTwAAAAGUExURUt40f///5cMEIAAAAABYktHRAH/Ai3eAAAAB3RJTUUH6gkVETAPQ8G1vQAAAAxJREFUCNdjYGBgAAAABAABJzQnCgAAAABJRU5ErkJggg==', 'base64'),
});
await page.waitForFunction(() => window.shellCrtQa?.tenant?.chat_image_posts === 1);
await clickTab('collection');
await clickTab('sketchbook');
await page.waitForFunction(() => window.shellCrtQa?.tenant?.chat_text_posts === 1 && window.shellCrtQa?.tenant?.chat_image_posts === 1);

state = await page.evaluate(() => window.shellCrtQa.tenant);
assert.equal(state.chat_text_posts, 1, 'Enter posts text');
assert.equal(state.chat_image_posts, 1, 'image picker posts a thumbnail');
assert.ok(state.chat_message_count >= 6, 'posted content remains after a tab switch');
if (process.argv[3]) await page.screenshot({ path: process.argv[3] });
console.log('global chatroom browser: PASS');
await browser.close();
