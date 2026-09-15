// PLAYWRIGHT_MODULE=/absolute/path/to/playwright/index.mjs node saves_browser.mjs URL OUT_DIR
import assert from 'node:assert/strict';
import {mkdirSync, rmSync, writeFileSync} from 'node:fs';

const {chromium} = await import(process.env.PLAYWRIGHT_MODULE || 'playwright');
const out = process.argv[3] || '/tmp/risd-saves-browser';
const profile = out + '/chrome-profile';
mkdirSync(out, {recursive: true});
rmSync(profile, {recursive: true, force: true});
const target = new URL(process.argv[2]);
target.searchParams.set('qa-crt', '1');
target.searchParams.set('crt', '0');
const reopenTarget = new URL(process.argv[4] || process.argv[2]);
reopenTarget.searchParams.set('qa-crt', '1');
reopenTarget.searchParams.set('crt', '0');
const errors = [];

const numbers = value => Array.isArray(value) ? value : String(value).match(/-?\d+(?:\.\d+)?/g).map(Number);
const point = (rect, state) => {
  const [x, y, width, height] = numbers(rect);
  return [(x + width / 2) / state.logical_size[0] * state.display_size[0],
    (y + height / 2) / state.logical_size[1] * state.display_size[1]];
};
const location = (rect, state, fx, fy) => {
  const [x, y, width, height] = numbers(rect);
  return [(x + width * fx) / state.logical_size[0] * state.display_size[0],
    (y + height * fy) / state.logical_size[1] * state.display_size[1]];
};
const state = page => page.evaluate(() => window.shellCrtQa);

function watch(page) {
  page.on('pageerror', error => errors.push(error.message));
  page.on('console', message => {
    const ignored = message.location().url.endsWith('/favicon.ico') || /2D MSAA|render_target_set_msaa/.test(message.text());
    if (message.type() === 'error' && !ignored) errors.push(message.text());
  });
}

async function ready(page, url = target) {
  watch(page);
  await page.goto(url.href);
  try {
    await page.waitForFunction(() => window.shellCrtQa?.shell.active === 4
      && window.shellCrtQa.tenant.search?.phase === 'results', null, {timeout: 90000});
  } catch (error) {
    console.error(JSON.stringify(await page.evaluate(() => ({shell: window.shellCrtQa, crt: window.crtQaState,
      squiggle: window.squiggleQaState, title: document.title}))));
    console.error(JSON.stringify(errors));
    throw error;
  }
  await page.keyboard.press('F9');
  await page.waitForFunction(() => window.squiggleQaState?.enabled === false);
}

async function openTab(page, index) {
  const current = await state(page);
  await page.mouse.click(...point(current.shell.tabs[index].rect, current));
  await page.waitForFunction(tab => window.shellCrtQa?.shell.active === tab && !window.shellCrtQa.shell.switching, index);
}

async function select(page, index) {
  const current = await state(page);
  const item = current.tenant.search.items[index];
  await page.mouse.click(...point(item.rect, current));
  await page.waitForFunction(id => window.shellCrtQa.tenant.search.selected === id
    && window.shellCrtQa.tenant.search.controls.SaveArtwork, item.id);
  return item.id;
}

async function save(page) {
  const current = await state(page);
  await page.mouse.click(...point(current.tenant.search.controls.SaveArtwork, current));
  await page.waitForFunction(() => ['saved', 'error'].includes(window.shellCrtQa.tenant.search.save_phase));
  const completed = await state(page);
  assert.equal(completed.tenant.search.save_phase, 'saved', JSON.stringify({search: completed.tenant.search, errors}));
}

const document = (page, replacement) => page.evaluate(value => new Promise((resolve, reject) => {
  const opened = indexedDB.open('risd-collection-browser', 1);
  opened.onerror = () => reject(opened.error);
  opened.onsuccess = () => {
    const db = opened.result;
    const tx = db.transaction('collection', value === undefined ? 'readonly' : 'readwrite');
    const request = value === undefined
      ? tx.objectStore('collection').get('saved')
      : tx.objectStore('collection').put(value, 'saved');
    request.onerror = () => reject(request.error);
    tx.onerror = () => reject(tx.error);
    tx.oncomplete = () => { db.close(); resolve(value === undefined ? request.result : value); };
  };
}), replacement);

async function expectSaveError(page, index, openError = '') {
  if (openError) await page.evaluate(name => {
    const prototype = Object.getPrototypeOf(indexedDB);
    window.__risdOriginalIndexedDbOpen = prototype.open;
    prototype.open = () => {
      const request = {};
      queueMicrotask(() => {
        Object.defineProperty(request, 'error', {value: new DOMException('Test storage failure', name)});
        request.onerror?.();
      });
      return request;
    };
  }, openError);
  try {
    await select(page, index);
    const current = await state(page);
    await page.mouse.click(...point(current.tenant.search.controls.SaveArtwork, current));
    await page.waitForFunction(() => window.shellCrtQa.tenant.search.save_phase === 'error');
    const failed = await state(page);
    assert.notEqual(failed.tenant.search.save_message, 'Saved');
  } finally {
    if (openError) await page.evaluate(() => {
      Object.getPrototypeOf(indexedDB).open = window.__risdOriginalIndexedDbOpen;
      delete window.__risdOriginalIndexedDbOpen;
    });
  }
}

const [viewportWidth, viewportHeight] = (process.env.RISD_VIEWPORT || '1920x1080').split('x').map(Number);
const args = {executablePath: '/usr/bin/google-chrome', headless: true,
  viewport: {width: viewportWidth, height: viewportHeight},
  args: ['--no-sandbox', '--use-angle=swiftshader', '--enable-unsafe-swiftshader']};
let context = await chromium.launchPersistentContext(profile, args);
try {
  const first = context.pages()[0];
  const second = await context.newPage();
  await ready(first);
  await ready(second);
  const [firstId, secondId] = await Promise.all([select(first, 0), select(second, 1)]);
  assert.notEqual(firstId, secondId);
  await Promise.all([save(first), save(second)]);

  const committed = await document(first);
  let failureIndex = 1;
  for (const invalid of [
    {schema_version: 1, revision: -1, items: []},
    {schema_version: 2, revision: committed.revision, items: committed.items},
  ]) {
    await document(first, invalid);
    await expectSaveError(first, failureIndex);
    failureIndex = 1 - failureIndex;
    assert.deepEqual(await document(first), invalid);
    await document(first, committed);
  }
  for (const name of ['SecurityError', 'QuotaExceededError', 'AbortError']) {
    await expectSaveError(first, failureIndex, name);
    failureIndex = 1 - failureIndex;
    assert.deepEqual(await document(first), committed);
  }

  await openTab(first, 5);
  await first.waitForFunction(ids => ids.every(id => window.shellCrtQa.tenant.saved_ids?.includes(id))
    && window.shellCrtQa.tenant.saved_images_loaded === ids.length, [firstId, secondId]);
  const playground = await state(first);
  await first.screenshot({path: out + '/01-playground-saved.png'});

  await openTab(first, 1);
  await first.waitForFunction(ids => ids.every(id => window.shellCrtQa.tenant.saved_ids?.includes(id))
    && window.shellCrtQa.tenant.reference_cards?.length === 2
    && window.shellCrtQa.tenant.reference_cards.every(card => card.has_texture), [firstId, secondId]);
  let sketchbook = await state(first);
  const card = sketchbook.tenant.reference_cards.find(item => item.id === firstId);
  await first.mouse.click(...point(card.rect, sketchbook));
  await first.waitForFunction(id => window.shellCrtQa.tenant.selected_reference === id
    && window.shellCrtQa.tenant.reference_cards?.length === 2
    && window.shellCrtQa.tenant.reference_cards.every(item => item.has_texture), firstId);
  await first.screenshot({path: out + '/02-sketchbook-reference.png'});

  await context.close();
  context = await chromium.launchPersistentContext(profile, args);
  const reopened = context.pages()[0];
  await ready(reopened, reopenTarget);
  await select(reopened, 0);
  await reopened.waitForFunction(() => window.shellCrtQa.tenant.search.save_phase === 'saved');
  await openTab(reopened, 5);
  await reopened.waitForFunction(ids => ids.every(id => window.shellCrtQa.tenant.saved_ids?.includes(id))
    && window.shellCrtQa.tenant.saved_images_loaded === ids.length, [firstId, secondId]);
  await openTab(reopened, 1);
  await reopened.waitForFunction(ids => ids.every(id => window.shellCrtQa.tenant.saved_ids?.includes(id))
    && window.shellCrtQa.tenant.reference_cards.every(card => card.has_texture), [firstId, secondId]);
  sketchbook = await state(reopened);
  await reopened.screenshot({path: out + '/03-reopened-sketchbook.png'});

  let reference = sketchbook.tenant.reference_cards.find(item => item.id === firstId);
  await reopened.mouse.click(...point(reference.rect, sketchbook));
  await reopened.waitForFunction(id => window.shellCrtQa.tenant.selected_reference === id
    && window.shellCrtQa.tenant.reference_cards.every(item => item.has_texture), firstId);
  sketchbook = await state(reopened);
  const initialPigment = sketchbook.tenant.brush_color;
  await reopened.mouse.click(...point(sketchbook.tenant.wells[9], sketchbook));
  await reopened.waitForFunction(color => window.shellCrtQa.tenant.brush_color !== color, initialPigment);
  sketchbook = await state(reopened);
  await reopened.mouse.move(...location(sketchbook.tenant.page_rect, sketchbook, 0.25, 0.5));
  await reopened.mouse.down();
  await reopened.mouse.move(...location(sketchbook.tenant.page_rect, sketchbook, 0.35, 0.56), {steps: 10});
  await reopened.mouse.up();
  await reopened.waitForFunction(() => window.shellCrtQa.tenant.strokes === 1 && !window.shellCrtQa.tenant.drawing);
  const painted = await state(reopened);
  reference = painted.tenant.reference_cards.find(item => item.id === secondId);
  await reopened.mouse.click(...point(reference.rect, painted));
  await reopened.waitForFunction(id => window.shellCrtQa.tenant.selected_reference === id
    && window.shellCrtQa.tenant.reference_cards.every(item => item.has_texture), secondId);
  let retained = await state(reopened);
  assert.equal(retained.tenant.strokes, painted.tenant.strokes);
  assert.equal(retained.tenant.spread, painted.tenant.spread);
  assert.equal(retained.tenant.brush_color, painted.tenant.brush_color);
  await reopened.mouse.click(...point(retained.tenant.controls.next, retained));
  await reopened.waitForFunction(() => window.shellCrtQa.tenant.spread === 2 && window.shellCrtQa.tenant.turning === '');
  retained = await state(reopened);
  await reopened.mouse.click(...point(retained.tenant.controls.previous, retained));
  await reopened.waitForFunction(() => window.shellCrtQa.tenant.spread === 1
    && window.shellCrtQa.tenant.strokes === 1 && window.shellCrtQa.tenant.turning === '');
  await openTab(reopened, 0);
  await openTab(reopened, 1);
  await reopened.waitForFunction(() => window.shellCrtQa.tenant.reference_cards.every(item => item.has_texture));
  retained = await state(reopened);
  assert.equal(retained.tenant.selected_reference, secondId);
  assert.equal(retained.tenant.strokes, painted.tenant.strokes);
  assert.equal(retained.tenant.brush_color, painted.tenant.brush_color);
  await reopened.screenshot({path: out + '/04-sketchbook-painted.png'});

  assert.deepEqual(errors, []);
  const report = {status: 'pass', url: process.argv[2], reopened_url: process.argv[4] || process.argv[2],
    viewport: [viewportWidth, viewportHeight],
    saved_ids: [firstId, secondId], concurrent_windows: true, persisted_after_browser_restart: true,
    persisted_after_build_update: Boolean(process.argv[4]),
    rejected_without_overwrite: ['denied', 'quota', 'aborted', 'corrupt', 'newer-version'],
    drawing_state_retained: true,
    playground_ids: playground.tenant.saved_ids, sketchbook_ids: sketchbook.tenant.saved_ids, errors};
  writeFileSync(out + '/report.json', JSON.stringify(report, null, 2) + '\n');
  console.log(JSON.stringify(report));
} finally {
  await context.close();
}
