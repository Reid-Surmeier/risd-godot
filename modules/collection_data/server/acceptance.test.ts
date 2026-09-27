// Frozen #78 acceptance: public adapter results, full-corpus semantics and safe I/O.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { Effect } from 'effect';
import { parseQuery, publish, search, refresh, image, type Store } from './adapter.ts';

const run = <A, E>(effect: Effect.Effect<A, E>) => Effect.runPromise(effect);
const failure = async (effect: Effect.Effect<unknown, unknown>, code: string) => {
  const result = await run(Effect.either(effect));
  assert.equal(result._tag, 'Left');
  if (result._tag === 'Left') assert.equal((result.left as {code: string}).code, `collection_data.${code}`);
};
const now = '2026-09-15T16:00:00.000Z';
const rights = {status: 'unknown', evidence_url: null, observed_at: null};
const records = Array.from({length: 25}, (_, i) => ({
  id: `risd:${100 + i}`, web_id: String(100 + i), title: i < 2 ? 'Equal' : `Work ${String(i).padStart(2, '0')}`,
  makers: ['Example Maker'], dating: '1900', year_from: i < 2 ? null : 1900 + i % 3,
  accession: `A${i}`, category: i % 2 ? 'Sculpture' : 'Painting', materials: i % 2 ? 'bronze' : 'Oil on canvas',
  source_url: `https://risdmuseum.org/art-design/collection/example-${i}`, credit: 'Fixture only', rights,
  image: null, upstream_checked_at: now, availability: 'available'
}));
const store = (): Store => ({snapshots: new Map(), latest: '', upstream_status: 'cached', now: () => Date.parse(now), media: new Map()});

test('whole corpus filtering, four orders, unknown dates/ties and pinned page two', async () => {
  const s = store(); const snap = await run(publish(s, records, 'Fixture corpus: 25 records', now));
  const page = await run(search(s, await run(parseQuery(''))));
  assert.equal(page.total, 25); assert.equal(page.items.length, 20);
  assert.deepEqual(page.categories, ['Painting', 'Sculpture']);
  const second = await run(search(s, await run(parseQuery(`page=2&snapshot=${snap}`))));
  assert.equal(second.items.length, 5);
  assert.equal(new Set([...page.items, ...second.items].map(x => x.id)).size, 25);
  for (const sort of ['date_asc', 'date_desc']) {
    const last = await run(search(s, await run(parseQuery(`sort=${sort}&page=2`))));
    assert.deepEqual(last.items.slice(-2).map(x => x.id), ['risd:100', 'risd:101']);
    const first = await run(search(s, await run(parseQuery(`sort=${sort}`))));
    assert.equal(first.items[0].year_from, sort === 'date_asc' ? 1900 : 1902);
  }
  const titles = await run(search(s, await run(parseQuery('sort=title_asc'))));
  assert.deepEqual(titles.items.slice(0, 2).map(x => x.id), ['risd:100', 'risd:101']);
  const reverse = await run(search(s, await run(parseQuery('sort=title_desc'))));
  assert.equal(reverse.items[0].id, 'risd:124');
  const filtered = await run(search(s, await run(parseQuery('q=maker+oil&category=Painting'))));
  assert.equal(filtered.total, 13); assert.equal(filtered.corpus.count, 25);
  assert.equal((await run(search(s, await run(parseQuery('has_image=true'))))).total, 0);
  assert.equal((await run(search(s, await run(parseQuery('q=no-match'))))).total, 0);
  await run(publish(s, records.slice(0, 1), 'New partial corpus', '2026-09-15T16:01:00.000Z'));
  assert.equal((await run(search(s, await run(parseQuery(`snapshot=${snap}&page=2`))))).total, 25);
});

test('invalid wire parameters and records are errors, never empty success', async () => {
  for (const q of ['page=0','page=1.5','page=50001','page=01','q=x&q=y','has_image=1','sort=random','snapshot=abc','url=https://example.com','q=%FF','q=%','q='+ 'x'.repeat(257)]) {
    await failure(parseQuery(q), 'invalid_query');
  }
  const s = store(); await failure(search(s, await run(parseQuery(''))), 'unavailable');
  await run(publish(s, records, 'Partial fixture', now));
  await failure(search(s, await run(parseQuery('category=bronze'))), 'invalid_query');
  await failure(search(s, await run(parseQuery('snapshot='+'a'.repeat(64)))), 'snapshot_expired');
  for (const bad of [{...records[0], id: 'wrong'}, {...records[0], title: 6}, {...records[0], source_url:'https://evil.example/x'}, {...records[0], image:{sha256:'bad'}}]) {
    await failure(publish(s, [bad], 'Invalid', now), 'invalid_record');
  }
  assert.equal((await run(search(s, await run(parseQuery(''))))).total, 25);
});

test('challenged/malformed refresh retains valid corpus; images are manifest-only and hash-verified', async () => {
  const s = store(); const snap = await run(publish(s, records, 'Partial fixture', now));
  await failure(refresh(s, async () => {throw Error('403 challenge');}), 'unavailable');
  assert.equal(s.latest, snap); assert.equal(s.upstream_status, 'unavailable');
  await failure(refresh(s, async () => ({records: 'HTML', coverage: 'bad', fetched_at: now})), 'invalid_record');
  assert.equal(s.latest, snap);
  for (const hash of ['../secret', 'https://localhost/', 'b'.repeat(64)]) await failure(image(s, hash), 'invalid_query');
});
