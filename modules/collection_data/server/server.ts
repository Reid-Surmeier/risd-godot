import { createServer } from 'node:http';
import { createReadStream } from 'node:fs';
import { readFile, writeFile, rename, mkdir, stat } from 'node:fs/promises';
import { resolve, extname, sep } from 'node:path';
import { Effect } from 'effect';
import { parseQuery, publish, search, refresh, image, type Store } from './adapter.ts';
import { fetchOfficial, normalize } from './ingest.ts';

const base = resolve(import.meta.dirname, 'cache'), seed = resolve(import.meta.dirname, '../../../docs/evidence/collection-search'), root = resolve(process.argv[2] ?? 'build/web-crt-refined');
const store: Store = {snapshots: new Map(), latest: '', upstream_status: 'cached', now: Date.now, media: new Map()};
const run = Effect.runPromise;
const result = async <A, E>(effect: Effect.Effect<A, E>) => {
  const value = await run(Effect.either(effect));
  return value._tag === 'Right' ? {ok: true, value: value.right, error: null} : {ok: false, value: null, error: value.left};
};
await mkdir(base, {recursive: true});
try {
  const local = JSON.parse(await readFile(resolve(seed, 'corpus.json'), 'utf8'));
  const minimumImages = local.records.filter((artwork: {image: unknown}) => artwork.image).length;
  const candidates = [local];
  try {candidates.push(JSON.parse(await readFile(resolve(base, 'corpus.json'), 'utf8')));} catch {}
  candidates.sort((a, b) => Date.parse(b.fetched_at) - Date.parse(a.fetched_at));
  for (const cached of candidates) {
    if (cached.records?.filter((artwork: {image: unknown}) => artwork.image).length < minimumImages) continue;
    const staging: Store = {snapshots: new Map(), latest: '', upstream_status: 'cached', now: store.now, media: new Map()};
    try {
      await run(publish(staging, cached.records, cached.coverage, cached.fetched_at));
      for (const artwork of staging.snapshots.get(staging.latest)!.records) if (artwork.image) {
        let verified = false;
        for (const path of [resolve(base, artwork.image.sha256), resolve(seed, 'images', `${artwork.image.sha256}.jpg`)]) try {
          const bytes = await readFile(path);
          staging.media.set(artwork.image.sha256, {bytes, mime: artwork.image.mime});
          await run(image(staging, artwork.image.sha256));
          verified = true; break;
        } catch {}
        if (!verified) throw Error('No verified local image bytes');
      }
      store.snapshots = staging.snapshots; store.latest = staging.latest; store.media = staging.media;
      store.upstream_status = cached.upstream_status === 'unavailable' ? 'unavailable' : 'cached';
      break;
    } catch {}
  }
  if (!store.latest) console.info('No complete bundled/cached corpus and images; search reports availability honestly.');
} catch {console.info('No complete bundled/cached corpus and images; search reports availability honestly.');}
if (process.argv.includes('--refresh')) {
  const updated = await result(refresh(store, async () => {
    // One documented page per explicit process refresh; never a per-keystroke request.
    const url = 'https://risdmuseum.org/api/v1/collection?search_api_fulltext=monet&has_images=1&items_per_page=25';
    const bytes = await run(fetchOfficial(url)), observed = new Date().toISOString();
    const records = await run(normalize(JSON.parse(Buffer.from(bytes).toString('utf8')), observed));
    // Keep previously verified media only when the official identity AND object URL agree.
    const previous = store.snapshots.get(store.latest)?.records ?? [];
    for (const artwork of records) artwork.image = previous.find(x => x.id === artwork.id && x.source_url === artwork.source_url)?.image ?? null;
    const corpus = {records, coverage: 'Partial RISD corpus: first Monet query page, maximum 25 records; not the whole museum', fetched_at: observed};
    // Validate before replacing the durable last valid corpus.
    const staging: Store = {...store, snapshots: new Map(store.snapshots)};
    await run(publish(staging, records, corpus.coverage, observed));
    await writeFile(resolve(base, 'corpus.next'), JSON.stringify(corpus));
    await rename(resolve(base, 'corpus.next'), resolve(base, 'corpus.json'));
    await writeFile(resolve(base, `official-${observed.replace(/[:.]/g, '-')}.json`), bytes);
    return corpus;
  }));
  console.info(JSON.stringify({refresh: updated}));
}
const mime: Record<string,string> = {'.html':'text/html; charset=utf-8','.js':'application/javascript','.wasm':'application/wasm','.pck':'application/octet-stream','.png':'image/png','.ico':'image/x-icon','.json':'application/json','.glb':'model/gltf-binary'};
const server = createServer(async (request, response) => {
  const headers = {'cross-origin-opener-policy':'same-origin','cross-origin-embedder-policy':'require-corp','x-content-type-options':'nosniff'};
  const send = (status: number, body: unknown) => {response.writeHead(status, {...headers, 'content-type':'application/json', 'cache-control':'no-store'}); response.end(JSON.stringify(body));};
  try {
    if (request.method !== 'GET') {send(405, {ok:false,value:null,error:{code:'collection_data.invalid_query',detail:'GET required'}}); return;}
    const url = new URL(request.url ?? '/', 'http://localhost');
    if (url.pathname === '/api/collection/search') {
      const reply = await result(parseQuery(url.search.slice(1)).pipe(Effect.flatMap(q => search(store, q))));
      const code = (reply.error as {code?: string} | null)?.code;
      send(reply.ok ? 200 : code?.endsWith('invalid_query') ? 400 : code?.endsWith('snapshot_expired') ? 409 : code?.endsWith('unavailable') ? 503 : 502, reply); return;
    }
    if (url.pathname.startsWith('/api/collection/image/')) {
      if (url.search) {send(400, {ok:false,value:null,error:{code:'collection_data.invalid_query',detail:'Unexpected image query'}}); return;}
      const reply = await result(image(store, url.pathname.slice('/api/collection/image/'.length)));
      if (!reply.ok || !reply.value) {send(400, reply); return;}
      response.writeHead(200, {...headers, 'content-type':reply.value.mime, 'cache-control':'public, max-age=31536000, immutable'}); response.end(reply.value.bytes); return;
    }
    const path = resolve(root, '.' + decodeURIComponent(url.pathname === '/' ? '/index.html' : url.pathname));
    const stats = path.startsWith(root + sep) && mime[extname(path)] ? await stat(path).catch((error: NodeJS.ErrnoException) => {
      if (error.code === 'ENOENT') return null;
      throw error;
    }) : null;
    if (!stats?.isFile()) {send(404, {ok:false,value:null,error:{code:'collection_data.invalid_query',detail:'Not found'}}); return;}
    response.writeHead(200, {...headers, 'content-type':mime[extname(path)], 'cache-control':'no-store'});
    const file = createReadStream(path); file.on('error', () => response.destroy()); file.pipe(response);
  } catch {if (!response.headersSent) send(502, {ok:false,value:null,error:{code:'collection_data.invalid_response',detail:'Collection route failed'}}); else response.destroy();}
});
server.listen(Number(process.env.RISD_SEARCH_PORT ?? 8128), '127.0.0.1', () => console.info('RISD same-origin search and game server ready'));
