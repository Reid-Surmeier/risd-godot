import { createHash } from 'node:crypto';
import { Effect } from 'effect';

type Fault = {code: string; detail: string};
export type Query = {q: string; category: string; sort: string; has_image: boolean; page: number; snapshot?: string};
type Rights = {status: string; evidence_url: string | null; observed_at: string | null};
export type Artwork = {id: string; web_id: string; title: string; makers: string[]; dating: string; year_from: number | null; accession: string; category: string; materials: string; source_url: string; credit: string; rights: Rights; image: null | {id: string; source_url: string; evidence_url: string; sha256: string; mime: string; width: number; height: number; verified_at: string; rights: Rights}; upstream_checked_at: string; availability: string};
type Snapshot = {records: Artwork[]; coverage: string; fetched_at: string; retained_at: number};
export type Store = {snapshots: Map<string, Snapshot>; latest: string; upstream_status: string; now: () => number; media: Map<string, {bytes: Uint8Array; mime: string}>};
const sorts = ['date_asc', 'date_desc', 'title_asc', 'title_desc'];
const canonical = (value: unknown): string => JSON.stringify(value, (_key, entry) => entry && typeof entry === 'object' && !Array.isArray(entry) ? Object.fromEntries(Object.keys(entry).sort().map(key => [key, entry[key]])) : entry);
const hashPattern = /^[a-f0-9]{64}$/;
const sha = (value: string | Uint8Array) => createHash('sha256').update(value).digest('hex');
const fault = (code: string, detail: string): Fault => ({code: `collection_data.${code}`, detail});
const check = (condition: unknown, code: string, detail: string): void => {if (!condition) throw fault(code, detail);};
const capture = <T>(fn: () => T, code = 'invalid_record'): Effect.Effect<T, Fault> => Effect.try({try: fn, catch: e => e && typeof e === 'object' && 'code' in e && String(e.code).startsWith('collection_data.') ? e as Fault : fault(code, 'Invalid collection data')});
const text = (s: unknown, limit = 4096): s is string => typeof s === 'string' && Buffer.byteLength(s) <= limit && !/[\u0000-\u0008\u000b\u000c\u000e-\u001f\u007f]/u.test(s);
const timestamp = (s: unknown) => typeof s === 'string' && /^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(?:\.\d{3})?Z$/.test(s) && Number.isFinite(Date.parse(s));
const object = (v: unknown): v is Record<string, any> => !!v && typeof v === 'object' && !Array.isArray(v);
function url(value: unknown, media = false): boolean {
  if (!text(value, 2048)) return false;
  try {const u = new URL(value); return u.protocol === 'https:' && !u.username && !u.password && !u.port && !u.hash && !u.search && (media ? u.hostname === 'risdmuseum.cdn.picturepark.com' && /^\/v\/[a-zA-Z0-9_-]+\/$/.test(u.pathname) : u.hostname === 'risdmuseum.org' && /^\/art-design\/collection\/[a-zA-Z0-9_-]+$/.test(u.pathname));} catch {return false;}
}
function validRights(r: unknown): boolean {
  return object(r) && ['public_domain', 'licensed', 'unknown'].includes(r.status) && (r.evidence_url === null || url(r.evidence_url)) && (r.observed_at === null || timestamp(r.observed_at)) && (r.status === 'unknown' || (r.evidence_url !== null && r.observed_at !== null));
}
function record(v: unknown): Artwork {
  check(object(v), 'invalid_record', 'Artwork must be an object');
  const a = v as Artwork;
  check(text(a.web_id, 128) && a.web_id.length > 0 && !/[\s/\\?#]/u.test(a.web_id) && a.id === `risd:${a.web_id}`, 'invalid_record', 'Invalid artwork identity');
  check(['title','dating','accession','category','materials','credit'].every(k => text((a as any)[k])), 'invalid_record', 'Invalid artwork text');
  check(Array.isArray(a.makers) && a.makers.length <= 32 && a.makers.every(x => text(x)), 'invalid_record', 'Invalid makers');
  check(a.year_from === null || Number.isSafeInteger(a.year_from), 'invalid_record', 'Invalid year');
  check(url(a.source_url) && validRights(a.rights) && timestamp(a.upstream_checked_at) && ['available','unavailable','unknown'].includes(a.availability), 'invalid_record', 'Invalid provenance');
  if (a.image !== null) {
    const i = a.image;
    check(object(i) && text(i.id) && i.id.length > 0 && url(i.source_url, true) && i.evidence_url === a.source_url && hashPattern.test(i.sha256) && ['image/jpeg','image/png','image/webp'].includes(i.mime) && Number.isSafeInteger(i.width) && i.width > 0 && Number.isSafeInteger(i.height) && i.height > 0 && timestamp(i.verified_at) && validRights(i.rights) && i.rights.status !== 'unknown', 'invalid_record', 'Unverified image');
  }
  check(Buffer.byteLength(JSON.stringify(a)) <= 65536, 'invalid_record', 'Artwork too large');
  return structuredClone(a);
}

export function parseQuery(raw: string): Effect.Effect<Query, Fault> {
  return capture(() => {
    check(Buffer.byteLength(raw) <= 4096, 'invalid_query', 'Query too large');
    try {decodeURIComponent(raw.replace(/\+/g, ' '));} catch {throw fault('invalid_query', 'Invalid encoding');}
    const params = new URLSearchParams(raw), allowed = ['q','category','sort','has_image','page','snapshot'];
    for (const key of params.keys()) check(allowed.includes(key) && params.getAll(key).length === 1, 'invalid_query', 'Unknown or repeated parameter');
    const q = (params.get('q') ?? '').trim().replace(/\s+/gu, ' '), category = params.get('category') ?? 'All';
    const sort = params.get('sort') ?? 'title_asc', has_image = params.get('has_image') ?? 'false', page = params.get('page') ?? '1';
    check([...q].length <= 256 && text(q) && text(category, 128) && category.length > 0 && sorts.includes(sort) && ['true','false'].includes(has_image) && /^[1-9][0-9]*$/.test(page) && Number(page) <= 50000, 'invalid_query', 'Invalid query value');
    const query: Query = {q, category, sort, has_image: has_image === 'true', page: Number(page)};
    if (params.has('snapshot')) {check(hashPattern.test(params.get('snapshot')!), 'invalid_query', 'Invalid snapshot'); query.snapshot = params.get('snapshot')!;}
    return query;
  }, 'invalid_query');
}

export function publish(store: Store, input: unknown, coverage: string, fetched_at: string): Effect.Effect<string, Fault> {
  return capture(() => {
    check(Array.isArray(input) && input.length <= 10000 && text(coverage) && coverage.length > 0 && timestamp(fetched_at), 'invalid_record', 'Invalid corpus');
    const records = (input as unknown[]).map(record).sort((a, b) => compare(a.id, b.id));
    check(new Set(records.map(x => x.id)).size === records.length, 'invalid_record', 'Duplicate identity');
    const hash = sha(canonical({records, coverage, fetched_at}));
    store.snapshots.set(hash, {records, coverage, fetched_at, retained_at: store.now()});
    store.latest = hash;
    // ponytail: a bounded refresh scope keeps in-memory snapshots small; disk index if the corpus grows.
    const keys = [...store.snapshots.keys()];
    for (const key of keys.slice(0, -2)) if (store.now() - store.snapshots.get(key)!.retained_at >= 3600000) store.snapshots.delete(key);
    return hash;
  });
}
const compare = (a: string, b: string): number => {
  const left = [...a], right = [...b];
  for (let i = 0; i < Math.min(left.length, right.length); i++) {const delta = left[i].codePointAt(0)! - right[i].codePointAt(0)!; if (delta) return delta;}
  return left.length - right.length;
};

export function search(store: Store, query: Query) {
  return capture(() => {
    const key = query.snapshot ?? store.latest, snapshot = store.snapshots.get(key);
    check(snapshot, query.snapshot ? 'snapshot_expired' : 'unavailable', query.snapshot ? 'Apply the search again; this snapshot expired' : 'RISD search is unavailable; no cached corpus');
    const {records, coverage, fetched_at} = snapshot!;
    const categories = [...new Set(records.map(x => x.category))].sort(compare);
    check(query.category === 'All' || categories.includes(query.category), 'invalid_query', 'Unknown category');
    const words = query.q.toLowerCase().split(' ').filter(Boolean);
    const items = records.filter(a => (query.category === 'All' || a.category === query.category) && (!query.has_image || a.image !== null) && words.every(word => [a.title, ...a.makers, a.accession, a.dating, a.materials].join(' ').toLowerCase().includes(word)));
    items.sort((a, b) => {
      let order = 0;
      if (query.sort.startsWith('date')) {
        if (a.year_from === null || b.year_from === null) return a.year_from === b.year_from ? compare(a.id, b.id) : a.year_from === null ? 1 : -1;
        order = a.year_from - b.year_from;
      } else order = compare(a.title.toLowerCase(), b.title.toLowerCase());
      return (query.sort.endsWith('desc') ? -order : order) || compare(a.id, b.id);
    });
    return {query: structuredClone(query), query_id: sha(canonical({...query, snapshot: key})), corpus: {snapshot: key, count: records.length, coverage, fetched_at, upstream_status: store.upstream_status}, total: items.length, page: query.page, page_size: 20, items: structuredClone(items.slice((query.page - 1) * 20, query.page * 20)), categories};
  }, 'invalid_response');
}

export function refresh(store: Store, load: () => Promise<{records: unknown; coverage: string; fetched_at: string}>): Effect.Effect<string, Fault> {
  return Effect.tryPromise({try: load, catch: () => fault('unavailable', 'Museum refresh unavailable; cached records retained')}).pipe(
    Effect.flatMap(data => publish(store, data.records, data.coverage, data.fetched_at)),
    Effect.tap(() => Effect.sync(() => {store.upstream_status = 'fresh';})),
    Effect.tapError(() => Effect.sync(() => {store.upstream_status = 'unavailable';}))
  );
}

export function image(store: Store, hash: string): Effect.Effect<{bytes: Uint8Array; mime: string}, Fault> {
  return capture(() => {
    const media = hashPattern.test(hash) ? store.media.get(hash) : null;
    check(media, 'invalid_query', 'Unknown image');
    check(media!.bytes.byteLength <= 20 * 1024 * 1024 && sha(media!.bytes) === hash, 'invalid_response', 'Cached image failed verification');
    return media!;
  });
}
