// The setup grid's hover turn in the exported Web build (Issue #110), with real mouse moves.
// PLAYWRIGHT_MODULE=/abs/playwright/index.mjs node modules/sculpture_viewer/playtest/hover_turn_browser.mjs URL CELLS_JSON OUT_DIR
// CELLS_JSON is the hover-turn.json the Godot playtest (hover_turn.gd) wrote at the same 1920x1080 page.
import {mkdirSync, readFileSync, writeFileSync} from 'node:fs';
const {chromium} = await import(process.env.PLAYWRIGHT_MODULE || 'playwright');
const [url, cellsPath, out] = process.argv.slice(2);
mkdirSync(out, {recursive: true});
const cells = JSON.parse(readFileSync(cellsPath, 'utf8')).cells;
const browser = await chromium.launch({executablePath: '/usr/bin/google-chrome', args: ['--no-sandbox', '--use-angle=swiftshader', '--enable-unsafe-swiftshader']});
const results = [];
try {
  const page = await browser.newPage({viewport: {width: 1920, height: 1080}, deviceScaleFactor: 1});
  const errors = [];
  page.on('pageerror', e => errors.push(e.message));
  await page.goto(url);
  await page.waitForFunction(() => window.crtQaState !== undefined, null, {timeout: 300000});  // the Shell is up
  await page.waitForTimeout(3000);
  await page.mouse.click(569, 1054);  // the 3D Viewer tab on the taskbar
  await page.waitForTimeout(6000);    // first show creates the Tenant and loads the scan
  const park = [1700, 900];
  await page.mouse.move(...park);
  await page.waitForTimeout(800);
  await page.screenshot({path: `${out}/web-00-rest.png`});
  const grab = async (r) => page.screenshot({clip: {x: Math.round(r.x), y: Math.round(r.y), width: Math.round(r.w), height: Math.round(r.h)}});
  const diff = async (a, b) => page.evaluate(async ([a, b]) => {
    const px = async (s) => { const i = new Image(); i.src = 'data:image/png;base64,' + s; await i.decode();
      const c = document.createElement('canvas'); c.width = i.width; c.height = i.height; const x = c.getContext('2d'); x.drawImage(i, 0, 0);
      return x.getImageData(0, 0, c.width, c.height).data; };
    const [p, q] = await Promise.all([px(a), px(b)]); let t = 0;
    for (let i = 0; i < p.length; i++) if (i % 4 !== 3) t += Math.abs(p[i] - q[i]);
    return t / (p.length / 4 * 3);
  }, [a.toString('base64'), b.toString('base64')]);
  for (const c of cells) {
    // The build's animated CRT / squiggle overlay moves pixels on its own: measure that floor with no hover.
    const idleA = await grab(c.rect);
    await page.waitForTimeout(2600);
    const before = await grab(c.rect);
    const floor = await diff(idleA, before);
    await page.mouse.move(c.rect.x + c.rect.w / 2, c.rect.y + c.rect.h / 2, {steps: 4});
    await page.waitForTimeout(1300);
    const during = await grab(c.rect);
    if (['turn-07-bull', 'turn-04-gold-couch', 'turn-1487831'].includes(c.cell)) await page.screenshot({path: `${out}/web-${c.cell}-hover.png`});
    await page.mouse.move(...park, {steps: 4});
    await page.waitForTimeout(1300);
    const after = await grab(c.rect);
    const changed = await diff(before, during), residual = await diff(before, after);
    const pass = changed > floor + 2 && residual <= floor + 1;
    results.push({cell: c.cell, floor: +floor.toFixed(2), changed: +changed.toFixed(2), residual: +residual.toFixed(3), pass});
    console.log(`${pass ? 'PASS' : 'FAIL'}  ${c.cell.padEnd(24)} idle floor ${floor.toFixed(2)}  change on hover ${changed.toFixed(2)}  after leave ${residual.toFixed(2)}`);
  }
  writeFileSync(`${out}/hover-turn-web.json`, JSON.stringify({url, results, errors}, null, 1));
  console.log(`VERDICT ${results.every(r => r.pass) ? 'PASS' : 'FAIL'}  ${results.filter(r => r.pass).length}/${results.length}  page errors ${errors.length}`);
} finally {
  await browser.close();
}
