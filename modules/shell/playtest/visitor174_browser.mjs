// #174 runtime smoke and visual proof in the exported Web build.
import assert from 'node:assert/strict';
import {mkdirSync, writeFileSync} from 'node:fs';
const {chromium} = await import(process.env.PLAYWRIGHT_MODULE || 'playwright');
const out = 'docs/evidence/character-174';
mkdirSync(out, {recursive: true});
const browser = await chromium.launch({executablePath: process.env.CHROMIUM_PATH || '/usr/bin/google-chrome', args: ['--no-sandbox', '--use-angle=swiftshader', '--enable-unsafe-swiftshader']});
const page = await browser.newPage({viewport: {width: 1080, height: 1080}});
const errors = [];
page.on('pageerror', e => errors.push(e.message));
page.on('console', m => { if (m.type() === 'error' && !/404|2D MSAA|render_target_set_msaa/.test(m.text())) errors.push(m.text()); });
try {
	const url = new URL(process.argv[2]);
	url.searchParams.set('qa-crt', '1');
	url.searchParams.set('variant', 'gallery');
	await page.goto(url.href);
	await page.waitForFunction(() => window.shellCrtQa?.shell.active === 4 && !window.shellCrtQa.shell.switching, null, {timeout: 240000});
	await page.waitForFunction(() => !document.getElementById('status'), null, {timeout: 120000});
	await page.waitForTimeout(4000);
	const idle = await page.screenshot({path: `${out}/visitor-web-front-idle.png`});
	await page.keyboard.press('q');
	await page.waitForTimeout(700);
	await page.screenshot({path: `${out}/visitor-web-profile.png`});
	await page.keyboard.press('q');
	await page.waitForTimeout(700);
	await page.screenshot({path: `${out}/visitor-web-back.png`});
	for (let turn = 0; turn < 2; turn++) { await page.keyboard.press('q'); await page.waitForTimeout(700); }
	await page.keyboard.down('s'); // move away from the arch and into the room from its initial pose
	await page.waitForTimeout(900);
	const walk = await page.screenshot({path: `${out}/visitor-web-walk.png`});
	await page.keyboard.up('s');
	await page.waitForTimeout(500);
	const stop = await page.screenshot({path: `${out}/visitor-web-stop.png`});
	await page.keyboard.down('s');
	await page.keyboard.down('d');
	await page.waitForTimeout(900);
	await page.screenshot({path: `${out}/visitor-web-diagonal.png`});
	await page.keyboard.up('s');
	await page.keyboard.up('d');
	await page.waitForTimeout(500);
	await page.screenshot({path: `${out}/visitor-web-diagonal-stop.png`});
	url.searchParams.set('variant', 'original');
	await page.goto(url.href);
	await page.waitForFunction(() => window.shellCrtQa?.shell.active === 4 && !window.shellCrtQa.shell.switching, null, {timeout: 240000});
	await page.waitForFunction(() => !document.getElementById('status'), null, {timeout: 120000});
	await page.waitForTimeout(4000);
	await page.screenshot({path: `${out}/visitor-web-turn-0.png`});
	for (let turn = 0; turn < 2; turn++) { await page.keyboard.press('ArrowLeft'); await page.waitForTimeout(700); }
	await page.screenshot({path: `${out}/visitor-web-turn-90.png`});
	for (let turn = 0; turn < 2; turn++) { await page.keyboard.press('ArrowLeft'); await page.waitForTimeout(700); }
	await page.screenshot({path: `${out}/visitor-web-turn-180.png`});
	const changedPixels = async (before, after) => page.evaluate(async ([a, b]) => {
		const decode = async data => { const image = new Image(); image.src = `data:image/png;base64,${data}`; await image.decode(); const canvas = document.createElement('canvas'); canvas.width = image.width; canvas.height = image.height; canvas.getContext('2d').drawImage(image, 0, 0); return canvas.getContext('2d').getImageData(460, 430, 280, 250).data; };
		const [x, y] = await Promise.all([decode(a), decode(b)]); let changed = 0;
		for (let i = 0; i < x.length; i += 4) if (Math.max(Math.abs(x[i] - y[i]), Math.abs(x[i + 1] - y[i + 1]), Math.abs(x[i + 2] - y[i + 2])) > 16) changed++;
		return changed;
	}, [before.toString('base64'), after.toString('base64')]);
	const idleToWalkPixels = await changedPixels(idle, walk), walkToStopPixels = await changedPixels(walk, stop);
	assert.ok(idleToWalkPixels > 50 && walkToStopPixels > 50, 'visitor gameplay crop did not change across walk and release');
	assert.deepEqual(errors, []);
	writeFileSync(`${out}/web-report.json`, JSON.stringify({url: 'local scratch export; no owner-facing URL', screenshots: ['visitor-web-front-idle.png', 'visitor-web-profile.png', 'visitor-web-back.png', 'visitor-web-turn-90.png', 'visitor-web-turn-180.png', 'visitor-web-walk.png', 'visitor-web-stop.png', 'visitor-web-diagonal.png', 'visitor-web-diagonal-stop.png'], controls: ['gallery view plus Q orbit for front/profile/back views', 'gallery view S (walk away from arch) for straight/diagonal movement', 'original third-person view ArrowLeft ×2 for 90° and ×2 more for 180° turns'], gameplay_crop_changed_pixels: {idle_to_walk: idleToWalkPixels, walk_to_stop: walkToStopPixels}, errors}, null, 2) + '\n');
	console.log('PASS #174 Web: visitor screenshots front/profile/back and walking stop, no browser errors');
} finally {
	await browser.close();
}
