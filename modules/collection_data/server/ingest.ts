import { Effect } from 'effect';
import { type Artwork } from './adapter.ts';

const error = (detail: string) => ({code: 'collection_data.unavailable', detail});
const allowed = (u: URL) => u.protocol === 'https:' && !u.username && !u.password && !u.port && !u.hash && ((u.hostname === 'risdmuseum.org' && (u.pathname === '/api/v1/collection' || /^\/art-design\/collection\/[a-zA-Z0-9_-]+$/.test(u.pathname))) || (u.hostname === 'risdmuseum.cdn.picturepark.com' && /^\/v\/[a-zA-Z0-9_-]+\/$/.test(u.pathname) && !u.search));

export function fetchOfficial(address: string, media = false): Effect.Effect<Uint8Array, {code: string; detail: string}> {
  return Effect.tryPromise({try: async () => {
    let url = new URL(address);
    const timeout = AbortSignal.timeout(15000), max = (media ? 20 : 5) * 1024 * 1024;
    for (let redirects = 0; redirects <= 3; redirects++) {
      if (!allowed(url)) throw Error('Unapproved upstream URL');
      if (url.pathname === '/api/v1/collection') {
        for (const [key, value] of url.searchParams) {
          if (!['id','search_api_fulltext','items_per_page','page','has_images'].includes(key) || url.searchParams.getAll(key).length !== 1 || value.length > 256) throw Error('Invalid upstream parameter');
          if (key === 'items_per_page' && !['5','10','15','20','25'].includes(value)) throw Error('Invalid page size');
          if (key === 'page' && !/^[0-9]{1,3}$/.test(value)) throw Error('Invalid page');
          if (key === 'has_images' && !['0','1'].includes(value)) throw Error('Invalid image filter');
        }
      } else if (url.search) throw Error('Unexpected upstream query');
      const response = await fetch(url, {redirect: 'manual', signal: timeout, headers: {accept: media ? 'image/*' : 'application/json, text/html;q=0.9'}});
      if ([301,302,303,307,308].includes(response.status)) {
        const location = response.headers.get('location'); await response.body?.cancel();
        if (!location) throw Error('Invalid redirect');
        url = new URL(location, url); continue;
      }
      if (!response.ok || !response.body) {await response.body?.cancel(); throw Error('Upstream unavailable');}
      if (Number(response.headers.get('content-length')) > max) {await response.body.cancel(); throw Error('Upstream too large');}
      const reader = response.body.getReader(), chunks: Uint8Array[] = []; let size = 0;
      try {
        while (true) {const next = await reader.read(); if (next.done) break; size += next.value.length; if (size > max) throw Error('Upstream too large'); chunks.push(next.value);}
      } finally {await reader.cancel();}
      return Buffer.concat(chunks);
    }
    throw Error('Too many redirects');
  }, catch: () => error('Museum request unavailable; no automatic retry')});
}

const decode = (value: unknown): string => {
  if (value == null) return '';
  if (typeof value !== 'string') throw Error('Non-text museum field');
  const names: Record<string,string> = {amp:'&',quot:'"',apos:"'",lt:'<',gt:'>',nbsp:' ',ndash:'–',mdash:'—',eacute:'é',aacute:'á',ouml:'ö',uuml:'ü'};
  return value.replace(/<[^>]*>/g, ' ').replace(/&(#x[0-9a-f]+|#\d+|[a-z]+);/gi, (_all, code: string) => {
    if (!code.startsWith('#')) {if (!(code in names)) throw Error('Unsupported text entity'); return names[code];}
    const n = code[1].toLowerCase() === 'x' ? parseInt(code.slice(2), 16) : Number(code.slice(1));
    if (n < 1 || n > 0x10ffff || (n >= 0xd800 && n <= 0xdfff)) throw Error('Invalid Unicode entity');
    return String.fromCodePoint(n);
  }).replace(/\s+/g, ' ').trim();
};

export function normalize(input: unknown, observed: string): Effect.Effect<Artwork[], {code: string; detail: string}> {
  return Effect.try({try: () => {
    if (!Array.isArray(input) || input.length > 25) throw Error('Invalid official page');
    return input.map(raw => {
      if (!raw || typeof raw !== 'object' || typeof raw.id !== 'string' || !Array.isArray(raw.type) || !Array.isArray(raw.medium) || !Array.isArray(raw.makers)) throw Error('Invalid official record');
      const category = decode(raw.type[0]), year = raw.datingYearFrom === '' || raw.datingYearFrom == null ? null : Number(raw.datingYearFrom);
      const source_url = raw.url;
      if (typeof source_url !== 'string') throw Error('Missing object URL');
      const rights = {status: raw.publicDomain === true ? 'public_domain' : 'unknown', evidence_url: raw.publicDomain === true ? source_url : null, observed_at: raw.publicDomain === true ? observed : null};
      return {id: `risd:${raw.id}`, web_id: raw.id, title: decode(raw.title), makers: raw.makers.map((m: {name: unknown}) => decode(m.name)), dating: decode(raw.dating), year_from: year, accession: decode(raw.objectNumber), category: category.toLowerCase() === 'paintings' ? 'Painting' : category.toLowerCase() === 'sculpture' ? 'Sculpture' : category, materials: raw.medium.map(decode).join('; '), source_url, credit: `${decode(raw.credit)}. Courtesy of the RISD Museum, Providence, RI.`, rights, image: null, upstream_checked_at: observed, availability: 'available'};
    });
  }, catch: () => ({code: 'collection_data.invalid_record', detail: 'Official response is malformed; previous corpus retained'})});
}
