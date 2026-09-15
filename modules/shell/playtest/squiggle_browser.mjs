const {chromium} = await import(process.env.PLAYWRIGHT_MODULE || 'playwright');
import assert from 'node:assert/strict';
import {mkdirSync, writeFileSync} from 'node:fs';

const out = process.argv[3] || '/tmp/risd-squiggle';
mkdirSync(out, {recursive: true});
const browser = await chromium.launch({headless: true, args: ['--no-sandbox', '--use-angle=swiftshader', '--enable-unsafe-swiftshader']});
const page = await browser.newPage({viewport: {width: 1920, height: 1080}});
const errors = [];
page.on('pageerror', error => errors.push(error.message));
page.on('console', message => {
	const favicon404 = /404/.test(message.text()) && message.location().url.endsWith('/favicon.ico');
	if (message.type() === 'error' && !favicon404 && !/2D MSAA is not yet supported|at: render_target_set_msaa/.test(message.text())) errors.push(message.text());
});
const state = () => page.evaluate(() => window.shellCrtQa);
function screen(x, y, s) {
	const [w, h] = s.logical_size, [dw, dh] = s.display_size, aspect = h / w;
	const qx = (x / w - .5) / aspect, qy = y / h - .5, a = .018 * (qx * qx + qy * qy), c = 1 + .018 / 4;
	const k = 2 * c / (1 + Math.sqrt(1 + 4 * a * c));
	return [(qx * k * aspect + .5) * dw, (qy * k + .5) * dh];
}
async function openTab(index) {
	const s = await state(), [x, y, w, h] = s.shell.tabs[index].rect;
	await page.mouse.click(...screen(x + w / 2, y + h / 2, s));
	await page.waitForFunction(i => window.shellCrtQa?.shell.active === i && !window.shellCrtQa.shell.switching, index);
}
async function difference(a, b) {
	return page.evaluate(async ([left, right]) => {
		async function pixels(base64) {
			const image = new Image(); image.src = 'data:image/png;base64,' + base64; await image.decode();
			const canvas = document.createElement('canvas'); canvas.width = image.width; canvas.height = image.height;
			const context = canvas.getContext('2d'); context.drawImage(image, 0, 0);
			return context.getImageData(0, 0, canvas.width, canvas.height).data;
		}
		const [x, y] = await Promise.all([pixels(left), pixels(right)]);
		let changed = 0;
		for (let i = 0; i < x.length; i += 4) if (Math.abs(x[i] - y[i]) + Math.abs(x[i + 1] - y[i + 1]) + Math.abs(x[i + 2] - y[i + 2]) > 30) changed++;
		return changed / (x.length / 4);
	}, [a.toString('base64'), b.toString('base64')]);
}

const report = {status: 'pass', settings: {}, motion: {}, controls: {}, interactions: {}, errors};
try {
	await page.goto(process.argv[2] + '?qa-crt=1');
	await page.waitForFunction(() => window.shellCrtQa?.shell.active === 4 && window.squiggleQaState, null, {timeout: 90000});
	await page.waitForFunction(() => window.shellCrtQa.tenant.search.images_loaded === 2);
	report.settings = await page.evaluate(() => window.squiggleQaState);
	assert.deepEqual(report.settings, {enabled: true, strength_pixels: .45, fps: 3});
	assert.equal(await page.evaluate(() => window.crtQaState.enabled), true);

	const on = await page.screenshot({path: out + '/01-squiggle-on.png'});
	await page.keyboard.press('F9');
	await page.waitForFunction(() => window.squiggleQaState.enabled === false);
	assert.equal(await page.evaluate(() => window.crtQaState.enabled), true);
	const off = await page.screenshot({path: out + '/02-squiggle-off.png'});
	report.motion.on_off_changed_fraction = await difference(on, off);
	assert.ok(report.motion.on_off_changed_fraction > .002, 'Squiggle pass must visibly change the screen');

	await page.keyboard.press('F9');
	await page.waitForFunction(() => window.squiggleQaState.enabled === true);
	const frameA = await page.screenshot();
	await page.waitForTimeout(420);
	const frameB = await page.screenshot({path: out + '/03-next-held-frame.png'});
	report.motion.temporal_changed_fraction = await difference(frameA, frameB);
	assert.ok(report.motion.temporal_changed_fraction > .002, 'The 3 FPS held frame must advance');
	await page.keyboard.press('F8');
	await page.waitForFunction(() => window.crtQaState.enabled === false);
	assert.equal(await page.evaluate(() => window.squiggleQaState.enabled), true);
	await page.keyboard.press('F8');
	await page.waitForFunction(() => window.crtQaState.enabled === true);
	report.controls = {f8_independent: true, f9_independent: true};

	await openTab(2);
	let s = await state();
	let control = s.tenant.controls['play-pause'].match(/-?\d+(?:\.\d+)?/g).map(Number);
	await page.mouse.click(...screen(control[0] + control[2] / 2, control[1] + control[3] / 2, s));
	await page.waitForTimeout(250);
	s = await state();
	const beforeYaw = s.tenant.yaw, viewport = s.tenant.viewport_rect;
	const center = screen(viewport[0] + viewport[2] / 2, viewport[1] + viewport[3] / 2, s);
	await page.mouse.move(...center); await page.mouse.down(); await page.mouse.move(center[0] + 55, center[1] + 18, {steps: 8}); await page.mouse.up();
	await page.waitForFunction(yaw => window.shellCrtQa.tenant.yaw !== yaw, beforeYaw);
	await page.screenshot({path: out + '/04-sculpture-orbit.png'});
	report.interactions.sculpture_orbit = true;

	await openTab(1);
	s = await state();
	const beforeRect = s.tenant.window_rect, title = s.tenant.title_rect;
	const titlePoint = screen(title[0] + title[2] * .4, title[1] + title[3] * .5, s);
	await page.mouse.move(...titlePoint); await page.mouse.down(); await page.mouse.move(titlePoint[0] - 35, titlePoint[1] + 15, {steps: 10}); await page.mouse.up();
	await page.waitForFunction(rect => Math.abs(window.shellCrtQa.tenant.window_rect[0] - (rect[0] - 35)) < 2, beforeRect);
	report.interactions.window_drag = true;

	for (const [width, height, name] of [[1920, 1080, 'full'], [960, 540, 'half']]) {
		await page.setViewportSize({width, height});
		await page.waitForFunction(([w, h]) => window.shellCrtQa.display_size[0] === w && window.shellCrtQa.display_size[1] === h, [width, height]);
		s = await state();
		const strokes = s.tenant.strokes, pageRect = s.tenant.page_rect;
		const start = screen(pageRect[0] + pageRect[2] * .25, pageRect[1] + pageRect[3] * .35, s);
		const end = screen(pageRect[0] + pageRect[2] * .42, pageRect[1] + pageRect[3] * .45, s);
		await page.mouse.move(...start); await page.mouse.down(); await page.mouse.move(...end, {steps: 16}); await page.mouse.up();
		await page.waitForFunction(n => window.shellCrtQa.tenant.strokes === n + 1, strokes);
		await page.screenshot({path: `${out}/05-paint-${name}.png`});
	}
	report.interactions.paint_full_and_half = true;
	assert.deepEqual(errors, []);
	writeFileSync(out + '/report.json', JSON.stringify(report, null, 2) + '\n');
	console.log(JSON.stringify(report));
} finally {
	await browser.close();
}
