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
await page.goto(url.href, { waitUntil: 'domcontentloaded', timeout: 120_000 });
await page.waitForFunction(() => window.shellCrtQa?.shell?.tabs?.some(({ key }) => key === 'sketchbook'), null, { timeout: 120_000 });
await page.keyboard.press('F9');
await page.waitForFunction(() => window.squiggleQaState?.enabled === false);

let state = await page.evaluate(() => window.shellCrtQa);
const tab = state.shell.tabs.find(({ key }) => key === 'sketchbook').rect;
await page.mouse.click(tab[0] + tab[2] / 2, tab[1] + tab[3] / 2);
await page.waitForFunction(() => window.shellCrtQa?.tenant?.palette_rect, null, { timeout: 30_000 });
state = await page.evaluate(() => window.shellCrtQa);
const palette = state.tenant.palette_rect;
const initialBrushColor = state.tenant.brush_color;
const point = ([x, y]) => [palette[0] + x * palette[2], palette[1] + y * palette[3]];
const tray = {
  x: palette[0] + 0.035 * palette[2],
  y: palette[1] + 0.2 * palette[3],
  width: 0.292 * palette[2],
  height: 0.285 * palette[3],
};

assert.equal(state.tenant.wells.length, 32, 'all palette wells have hit targets');
await page.mouse.click(...point([0.068 + 0.058 * 15, 0.115]));
await page.waitForFunction(color => window.shellCrtQa?.tenant?.brush_color !== color, initialBrushColor);
await page.mouse.move(800, 900);
const before = await page.screenshot({ clip: tray });
await page.mouse.click(...point([0.068 + 0.058 * 10, 0.115]));
await page.mouse.move(tray.x + 8, tray.y + tray.height / 2);
await page.mouse.down();
await page.mouse.move(tray.x + tray.width - 8, tray.y + tray.height / 2, { steps: 12 });
await page.mouse.up();
await page.mouse.click(...point([0.068 + 0.058 * 5, 0.63]));
await page.mouse.move(tray.x + tray.width / 2, tray.y + 8);
await page.mouse.down();
await page.mouse.move(tray.x + tray.width / 2, tray.y + tray.height - 8, { steps: 12 });
await page.mouse.up();
await page.mouse.move(800, 900);
await page.waitForTimeout(250);
const after = await page.screenshot({ clip: tray });
state = await page.evaluate(() => window.shellCrtQa.tenant);
const parkedBrush = state.parked_brush_rect;
const paintbox = state.paintbox_rect;
const paletteToBrushGap = parkedBrush[1] - (palette[1] + palette[3]);
const paletteTopRatio = (palette[1] - paintbox[1]) / paintbox[3];

assert.ok(state.paint_pixels > 0, 'tray records paint');
assert.ok(state.mix_count > 0, 'tray records mixed pigment');
assert.notDeepEqual(after, before, 'mixed paint is visible on the tray');
assert.ok(Math.abs(palette[2] / palette[3] - 398 / 365) < 0.01, 'palette keeps its original aspect');
assert.ok(paletteTopRatio >= 0.44, `white gap above palette is preserved (${paletteTopRatio})`);
assert.ok(paletteToBrushGap >= 12, `brush clears palette by 12 px (${paletteToBrushGap})`);
if (process.argv[3]) await page.screenshot({ path: process.argv[3] });
console.log(`anri browser: PASS (${state.paint_pixels} painted pixels, ${state.mix_count} mixes)`);
await browser.close();
