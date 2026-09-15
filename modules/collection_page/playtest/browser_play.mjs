// PLAYWRIGHT_MODULE=/absolute/path/to/playwright/index.mjs node browser_play.mjs URL OUT_DIR
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {mkdirSync, writeFileSync} from 'node:fs';

const {chromium} = await import(process.env.PLAYWRIGHT_MODULE || 'playwright');
const target = new URL(process.argv[2]);
target.searchParams.set('qa-crt', '1');
target.searchParams.set('crt', '0');
const out = process.argv[3] || 'docs/evidence/collection-page-search/browser';
mkdirSync(out, {recursive: true});
const browser = await chromium.launch({executablePath: '/usr/bin/google-chrome', args: ['--no-sandbox', '--use-angle=swiftshader', '--enable-unsafe-swiftshader']});

try {
  const page = await browser.newPage({viewport: {width: 1920, height: 1080}});
  const errors = [];
  page.on('pageerror', error => errors.push(error.message));
  page.on('console', message => {
    if (message.type() === 'error' && !message.location().url.endsWith('/favicon.ico')
      && !/404|2D MSAA|render_target_set_msaa/.test(message.text())) errors.push(message.text());
  });
  await page.goto(target.href);
  await page.waitForFunction(() => window.shellCrtQa?.shell.active === 4 && window.shellCrtQa.tenant.search?.phase === 'results');
  await page.waitForFunction(() => window.shellCrtQa.tenant.search.images_loaded === 2);

  const state = () => page.evaluate(() => window.shellCrtQa);
  const numbers = value => Array.isArray(value) ? value : String(value).match(/-?\d+(?:\.\d+)?/g).map(Number);
  const screen = (rect, current) => {
    const [x, y, width, height] = numbers(rect);
    const [logicalWidth, logicalHeight] = current.logical_size;
    const [displayWidth, displayHeight] = current.display_size;
    return [(x + width / 2) / logicalWidth * displayWidth, (y + height / 2) / logicalHeight * displayHeight];
  };
  const clickControl = async name => {
    const current = await state();
    await page.mouse.click(...screen(current.tenant.search.controls[name], current));
  };

  let current = await state();
  const initialRequests = current.tenant.search.requests;
  assert.deepEqual(current.tenant.search.applied, {category: 'All', has_image: true, page: 1, q: '', sort: 'date_asc'});
  await clickControl('Query');
  await page.keyboard.press('Control+A');
  await page.evaluate(() => {
    const ime = document.querySelector('.ime');
    ime.focus();
    ime.dispatchEvent(new CompositionEvent('compositionstart', {data: ''}));
    ime.dispatchEvent(new CompositionEvent('compositionupdate', {data: '雪'}));
    ime.textContent = '雪';
    ime.dispatchEvent(new InputEvent('input', {data: '雪', inputType: 'insertCompositionText', isComposing: true, bubbles: true}));
    ime.dispatchEvent(new CompositionEvent('compositionend', {data: '雪'}));
    ime.dispatchEvent(new InputEvent('input', {data: '雪', inputType: 'insertText', bubbles: true}));
    document.querySelector('#canvas').focus();
  });
  await page.waitForFunction(() => window.shellCrtQa.tenant.search.draft.q === '雪');
  assert.equal((await state()).tenant.search.requests, initialRequests, 'typing dispatches no request');
  await page.keyboard.press('Escape');
  await page.waitForFunction(() => window.shellCrtQa.tenant.search.draft.q === '');

  await clickControl('Query');
  await page.keyboard.type('Monet');
  await page.keyboard.press('Tab');
  await page.waitForFunction(() => window.shellCrtQa.tenant.search.focus_owner === 'Sort');
  await page.keyboard.press('Space');
  await page.waitForFunction(() => window.shellCrtQa.tenant.search.sort_popup.visible);
  await page.keyboard.press('Escape');
  await page.waitForFunction(requests => !window.shellCrtQa.tenant.search.sort_popup.visible
    && window.shellCrtQa.tenant.search.draft.q === 'Monet'
    && window.shellCrtQa.tenant.search.requests === requests, initialRequests);
  await page.keyboard.press('Space'); await page.keyboard.press('ArrowDown'); await page.keyboard.press('Enter');
  await page.keyboard.press('Tab');
  await page.waitForFunction(() => window.shellCrtQa.tenant.search.focus_owner === 'Category');
  await page.keyboard.press('Space'); await page.keyboard.press('ArrowDown'); await page.keyboard.press('ArrowDown'); await page.keyboard.press('Enter');
  await page.keyboard.press('Tab');
  await page.waitForFunction(() => window.shellCrtQa.tenant.search.focus_owner === 'HasImage');
  await page.keyboard.press('Space');
  await page.waitForFunction(() => !window.shellCrtQa.tenant.search.draft.has_image);
  await page.keyboard.press('Space'); await page.keyboard.press('Tab');
  await page.waitForFunction(() => window.shellCrtQa.tenant.search.focus_owner === 'OK');
  await page.keyboard.press('Enter');
  await page.waitForFunction(requests => window.shellCrtQa.tenant.search.phase === 'results'
    && window.shellCrtQa.tenant.search.requests === requests + 1
    && window.shellCrtQa.tenant.search.response.total === 2
    && window.shellCrtQa.tenant.search.images_loaded === 2, initialRequests);
  current = await state();
  assert.deepEqual(current.tenant.search.applied, {category: 'Painting', has_image: true, page: 1, q: 'Monet', sort: 'date_desc'});
  const full = await page.screenshot({path: out + '/01-browser-filtered-1920x1080.png'});

  const selectedRequests = current.tenant.search.requests;
  await page.mouse.click(...screen(current.tenant.search.items[0].rect, current));
  await page.waitForFunction(() => window.shellCrtQa.tenant.search.selected !== '');
  const selectedId = (await state()).tenant.search.selected;
  assert.equal((await state()).tenant.search.requests, selectedRequests, 'selection dispatches no request');

  // Exercise failure retention and pinned pagination in the exported Web origin.
  const baseResponse = structuredClone(current.tenant.search.response);
  const pageRecords = Array.from({length: 25}, (_, index) => {
    const record = structuredClone(baseResponse.items[index % baseResponse.items.length]);
    record.web_id = `${record.web_id}-${index + 1}`;
    record.id = `risd:${record.web_id}`;
    record.title = `${record.title} ${String(index + 1).padStart(2, '0')}`;
    return record;
  });
  const routed = [];
  await page.route('**/api/collection/search?**', async route => {
    const url = new URL(route.request().url());
    if (url.searchParams.get('q') === 'outage') {
      routed.push('outage');
      await route.fulfill({status: 200, contentType: 'application/json', body: JSON.stringify({ok: false, value: null,
        error: {code: 'collection_data.unavailable', detail: 'Browser acceptance outage'}})});
      return;
    }
    if (url.searchParams.get('q') === 'pages') {
      const query = {q: 'pages', category: url.searchParams.get('category'), sort: url.searchParams.get('sort'),
        has_image: url.searchParams.get('has_image') === 'true', page: Number(url.searchParams.get('page'))};
      if (url.searchParams.has('snapshot')) query.snapshot = url.searchParams.get('snapshot');
      const start = (query.page - 1) * 20;
      routed.push(`page-${query.page}`);
      await route.fulfill({status: 200, contentType: 'application/json', body: JSON.stringify({ok: true, error: null, value: {
        query, query_id: 'b'.repeat(64), corpus: {...baseResponse.corpus, snapshot: 'a'.repeat(64), count: 25,
          coverage: 'Deterministic browser pagination corpus'}, total: 25, page: query.page, page_size: 20,
        items: pageRecords.slice(start, start + 20), categories: baseResponse.categories}})});
      return;
    }
    await route.continue();
  });

  await clickControl('Query');
  await page.keyboard.press('Control+A'); await page.keyboard.type('outage'); await page.keyboard.press('Enter');
  await page.waitForFunction(() => window.shellCrtQa.tenant.search.phase === 'error');
  const outage = await state();
  assert.equal(outage.tenant.search.response.query.q, 'Monet', 'outage keeps successful results');
  await page.keyboard.press('Escape');
  await page.waitForFunction(() => window.shellCrtQa.tenant.search.phase === 'results'
    && window.shellCrtQa.tenant.search.focus_owner.startsWith('Card_'));

  await clickControl('Query');
  await page.keyboard.press('Control+A'); await page.keyboard.type('pages'); await page.keyboard.press('Enter');
  await page.waitForFunction(() => window.shellCrtQa.tenant.search.phase === 'results'
    && window.shellCrtQa.tenant.search.response.total === 25);
  await clickControl('Query');
  await page.keyboard.press('Control+A'); await page.keyboard.type('unsent');
  await clickControl('Next');
  await page.waitForFunction(() => window.shellCrtQa.tenant.search.phase === 'results'
    && window.shellCrtQa.tenant.search.response.page === 2);
  const paged = await state();
  assert.equal(paged.tenant.search.draft.q, 'unsent');
  assert.equal(paged.tenant.search.applied.q, 'pages');
  assert.equal(paged.tenant.search.applied.snapshot, 'a'.repeat(64));
  await page.unroute('**/api/collection/search?**');

  await clickControl('Query');
  await page.keyboard.press('Control+A'); await page.keyboard.type('Monet'); await page.keyboard.press('Enter');
  await page.waitForFunction(() => window.shellCrtQa.tenant.search.phase === 'results'
    && window.shellCrtQa.tenant.search.response.total === 2
    && window.shellCrtQa.tenant.search.images_loaded === 2);

  await page.setViewportSize({width: 720, height: 486});
  await page.waitForFunction(() => window.shellCrtQa.display_size[0] === 720 && window.shellCrtQa.display_size[1] === 486);
  await page.waitForTimeout(350);
  const compact = await page.screenshot({path: out + '/02-browser-filtered-720x486.png'});
  const darkEdges = await page.evaluate(async encoded => {
    const image = new Image(); image.src = 'data:image/png;base64,' + encoded; await image.decode();
    const canvas = document.createElement('canvas'); canvas.width = image.width; canvas.height = image.height;
    const context = canvas.getContext('2d'); context.drawImage(image, 0, 0); const pixels = context.getImageData(0, 0, canvas.width, canvas.height).data;
    const black = (x, y) => { const offset = (y * canvas.width + x) * 4; return Math.max(pixels[offset], pixels[offset + 1], pixels[offset + 2]) < 24 ? 1 : 0; };
    return [Array.from({length: canvas.width}, (_, x) => black(x, 0)), Array.from({length: canvas.width}, (_, x) => black(x, canvas.height - 1)),
      Array.from({length: canvas.height}, (_, y) => black(0, y)), Array.from({length: canvas.height}, (_, y) => black(canvas.width - 1, y))]
      .map(edge => edge.reduce((sum, value) => sum + value, 0) / edge.length);
  }, compact.toString('base64'));
  assert.ok(darkEdges.every(value => value < 0.30), 'no black bars: ' + JSON.stringify(darkEdges));

  const documentHtml = await (await page.request.get(target.href)).text();
  const config = JSON.parse(documentHtml.match(/const GODOT_CONFIG = (\{.*?\});/s)[1]);
  const assetNames = [config.executable + '.js', ...Object.keys(config.fileSizes)];
  const assets = assetNames.map(name => new URL(name, target).href);
  const served = {};
  for (const url of [target.href, ...assets]) {
    const response = await page.request.get(url);
    const bytes = await response.body();
    served[new URL(url).pathname.split('/').pop()] = {status: response.status(), sha256: createHash('sha256').update(bytes).digest('hex'), bytes: bytes.length};
  }
  assert.ok(Object.values(served).every(asset => asset.status === 200 && asset.bytes > 0));
  assert.deepEqual(errors, []);
  const finalState = await state();
  const report = {status: 'pass', url: process.argv[2], initial_requests: initialRequests,
    applied: finalState.tenant.search.applied, selected: selectedId, routed,
    outage: {phase: outage.tenant.search.phase, retained_query: outage.tenant.search.response.query.q},
    pagination: {page: paged.tenant.search.response.page, draft: paged.tenant.search.draft.q,
      applied: paged.tenant.search.applied.q, snapshot: paged.tenant.search.applied.snapshot},
    totals: {results: finalState.tenant.search.response.total, images_loaded: finalState.tenant.search.images_loaded},
    viewports: [{width: 1920, height: 1080}, {width: 720, height: 486, dark_edge_fraction: darkEdges}],
    screenshot_sha256: {full: createHash('sha256').update(full).digest('hex'), compact: createHash('sha256').update(compact).digest('hex')},
    served, errors};
  writeFileSync(out + '/report.json', JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify(report));
} finally {
  await browser.close();
}
