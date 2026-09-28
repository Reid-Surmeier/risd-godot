// Exported-Web smoke and timing check for the one-scan hover trial (#157).
// PLAYWRIGHT_MODULE=/abs/playwright/index.mjs node browser_check.mjs URL OUT_DIR
import { mkdirSync, writeFileSync } from 'node:fs';
const { chromium } = await import(process.env.PLAYWRIGHT_MODULE || 'playwright');

const [url, out] = process.argv.slice(2);
mkdirSync(out, { recursive: true });
const browser = await chromium.launch({ executablePath: '/usr/bin/google-chrome', args: ['--no-sandbox', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'] });
const results = [];
try {
  for (const width of (process.env.RISD_157_WIDTHS || '720,1600').split(',').map(Number)) {
    const page = await browser.newPage({ viewport: { width, height: width }, deviceScaleFactor: 1 });
    page.setDefaultTimeout(120000);
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    const scaled = (x, y) => [x * width / 1080, y * width / 1080];
    const target = new URL(url);
    target.searchParams.set('qa-crt', '1');
    target.searchParams.set('crt', '0');
    await page.goto(target.href);
    await page.waitForFunction(() => window.shellCrtQa?.shell.active === 4 && !window.shellCrtQa.shell.switching, null, { timeout: 300000 });
    // QA state is published while tabs warm; the HTML loading overlay still intercepts input.
    await page.waitForFunction(() => document.getElementById('status') === null, null, { timeout: 300000 });
    const state = await page.evaluate(() => window.shellCrtQa);
    const screen = (a, b) => [a * width / state.logical_size[0], b * width / state.logical_size[1]];
    // The shared square chrome owns the visible strip; Shell.state exposes its hidden legacy strip.
    await page.mouse.click(...screen(417, 1053));
    await page.waitForFunction(() => window.shellCrtQa?.shell.active === 2 && !window.shellCrtQa.shell.switching, null, { timeout: 30000 });
    await page.waitForTimeout(1200);
    await page.mouse.move(...scaled(830, 299));
    await page.waitForTimeout(2000);
    await page.screenshot({ path: `${out}/${width}-hover-a.png` });
    const preview = { x: Math.round(184 * width / 1080), y: Math.round(746 * width / 1080), width: Math.round(214 * width / 1080), height: Math.round(207 * width / 1080) };
    const first = await page.screenshot({ clip: preview });
    await page.waitForTimeout(2200);
    await page.screenshot({ path: `${out}/${width}-hover-b.png` });
    const second = await page.screenshot({ clip: preview });
    if (first.equals(second)) throw new Error(`Scan preview did not rotate at ${width}px`);
    await page.mouse.move(...scaled(475, 950));
    await page.waitForTimeout(500);
    await page.screenshot({ path: `${out}/${width}-leave.png` });
    if (second.equals(await page.screenshot({ clip: preview }))) throw new Error(`Scan preview did not clear at ${width}px`);
    const performance = await page.evaluate(() => {
      const f = performance.getEntriesByType('resource').filter(r => /\.game\.pck/.test(r.name));
      return { resource: f.map(r => ({ name: r.name.split('/').pop(), durationMs: r.duration, bytes: r.transferSize })), heap: performance.memory?.usedJSHeapSize ?? null };
    });
    results.push({ width, rotated: true, cleared: true, errors, performance });
    await page.close();
  }
  writeFileSync(`${out}/browser.json`, JSON.stringify(results, null, 2));
  if (results.some(r => r.errors.length)) process.exitCode = 1;
  console.log(JSON.stringify(results));
} finally {
  await browser.close();
}
