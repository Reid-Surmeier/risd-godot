// PLAYWRIGHT_MODULE=/path/to/playwright/index.mjs node shell_browser.mjs URL OUT_DIR
import assert from 'node:assert/strict';
import {mkdirSync, writeFileSync} from 'node:fs';

const {chromium} = await import(process.env.PLAYWRIGHT_MODULE || 'playwright');
const out = process.argv[3]; mkdirSync(out, {recursive: true});
const browser = await chromium.launch({executablePath: '/usr/bin/google-chrome', args: ['--no-sandbox', '--use-angle=swiftshader', '--enable-unsafe-swiftshader']});
const errors = [], expected404 = [], results = [];

function screen(x, y, state) {
	const [w, h] = state.logical_size, [dw, dh] = state.display_size, aspect = h / w;
	const qx = (x / w - .5) / aspect, qy = y / h - .5, a = .018 * (qx * qx + qy * qy), c = 1 + .018 / 4;
	const k = 2 * c / (1 + Math.sqrt(1 + 4 * a * c));
	return [(qx * k * aspect + .5) * dw, (qy * k + .5) * dh];
}

try {
	const page = await browser.newPage({viewport: {width: 1920, height: 1080}});
	page.on('pageerror', error => errors.push(error.message));
	page.on('console', message => {
		const url = message.location().url;
		const favicon = message.text().includes('404') && url.endsWith('/favicon.ico');
		if (message.type() === 'error' && !favicon && !/2D MSAA|render_target_set_msaa/.test(message.text())) errors.push(`${message.text()} ${url}`);
	});
	page.on('response', response => {
		if (response.status() < 400) return;
		if (response.status() === 404 && response.url().endsWith('/favicon.ico')) expected404.push(response.url());
		else errors.push(`${response.status()} ${response.url()}`);
	});
	const url = new URL(process.argv[2]); url.searchParams.set('qa-crt', '1');
	await page.goto(url.href);
	const faviconUrl = new URL('/favicon.ico', url);
	const faviconResponse = await page.request.get(faviconUrl.href);
	assert.equal(faviconResponse.status(), 404, `expected ${faviconUrl.href} to return 404`);
	expected404.push(faviconUrl.href);
	await page.waitForFunction(() => window.shellCrtQa?.shell.active === 4 && !window.shellCrtQa.shell.switching, null, {timeout: 90000});
	await page.waitForFunction(() => window.shellCrtQa.tenant.search.images_loaded === 2);
	await page.keyboard.press('F9');
	await page.waitForFunction(() => window.squiggleQaState?.enabled === false);

	async function state() { return page.evaluate(() => window.shellCrtQa); }
	async function clickTab(index) {
		const s = await state(), [x, y, w, h] = s.shell.tabs[index].rect;
		await page.mouse.click(...screen(x + w / 2, y + h / 2, s));
		await page.waitForFunction(i => window.shellCrtQa.shell.active === i && !window.shellCrtQa.shell.switching, index);
	}

	for (const [width, height] of [[1920, 1080], [720, 486]]) {
		await page.setViewportSize({width, height});
		await page.waitForFunction(([w, h]) => window.shellCrtQa.display_size[0] === w && window.shellCrtQa.display_size[1] === h, [width, height]);
		const selected = [];
		for (const index of [0, 1, 2, 3, 4, 5, 4]) {
			await clickTab(index); selected.push(index);
		}
		const s = await state();
		assert.equal(s.shell.tabs.length, 6);
		assert.ok(s.shell.tabs.every(tab => Math.abs(tab.rect[2] / tab.rect[3] - 380 / 123) < .01),
			JSON.stringify(s.shell.tabs.map(tab => tab.rect.slice(2))));
		await page.screenshot({path: `${out}/selected-${width}x${height}.png`});
		results.push({width, height, selected, tabSourceWidths: s.shell.tabs.map(tab => tab.rect[2] * 123 / tab.rect[3]), active: s.shell.active});
	}

	await page.setViewportSize({width: 1920, height: 1080});
	await page.waitForFunction(() => window.shellCrtQa.display_size[0] === 1920 && window.shellCrtQa.display_size[1] === 1080);
	await clickTab(0);
	let s = await state(), [x, y, w, h] = s.shell.tabs[4].rect;
	const top = screen(x, y, s), bottom = screen(x + w, y + h, s);
	const clip = {x: Math.max(0, Math.floor(top[0]) - 4), y: Math.max(0, Math.floor(top[1]) - 4),
		width: Math.ceil(bottom[0] - top[0]) + 8, height: Math.ceil(bottom[1] - top[1]) + 8};
	await page.mouse.click(...screen(x + w / 2, y + h / 2, s));
	await page.waitForTimeout(300);
	const steady = await page.screenshot({path: out + '/reveal-steady.png', clip});
	await page.waitForTimeout(160);
	const held = await page.screenshot({clip});
	assert.ok(steady.equals(held), 'Selected blue endpoint must hold steady');

	assert.deepEqual(errors, []);
	const report = {status: 'pass', url: process.argv[2], results,
		motion: {generatedEntranceAvailable: false, browserEndpointSteady: true}, expected404: [...new Set(expected404)], errors};
	writeFileSync(out + '/browser-report.json', JSON.stringify(report, null, 2) + '\n');
	console.log(JSON.stringify(report));
} finally {
	await browser.close();
}
