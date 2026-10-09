"""Three free live queries of the public RISD catalogue API, one per object, compared field by field with the inventory's cached records.
~/.local/share/uv/tools/scrapling/bin/python fetch_live.py [root checkout]   writes live/*.json (raw bytes) and live/manifest.json. A failed fetch is recorded, not hidden."""
import hashlib, json, sys, time, urllib.parse
from pathlib import Path
from scrapling.fetchers import Fetcher  # the inventory's route; plain urllib is refused with 403
here = Path(__file__).parent
review = Path(sys.argv[1] if len(sys.argv) > 1 else '/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction') / 'docs/evidence/collection-reconstruction/opus-renaissance-case-inventory-20261001'
QUERIES = {'1202276': 'Velvet Cover', '1201986': 'Woodcutters', '1591076': 'Saint Barbara and Saint Catherine'}
FIELDS = ['objectNumber', 'title', 'dimensions', 'medium', 'onView', 'datingYearFrom', 'datingYearTo', 'culture', 'url']
cached = {r['id']: r for r in json.loads((review / 'api/cached-records.json').read_text())}
(here / 'live').mkdir(exist_ok=True)
manifest = []
for ident, term in QUERIES.items():
    url = 'https://risdmuseum.org/api/v1/collection?' + urllib.parse.urlencode({'search_api_fulltext': term, 'has_images': '1', 'items_per_page': '25', 'field_on_view': '1'})
    row = {'catalogue_id': ident, 'url': url, 'fetched_utc': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())}
    try:
        reply = Fetcher.get(url)
        assert reply.status == 200, f'HTTP {reply.status}'
        body = reply.body
        (here / 'live' / f'{ident}.json').write_bytes(body)
        found = [r for r in json.loads(body) if r['id'] == ident]
        row.update({'status': 200, 'sha256': hashlib.sha256(body).hexdigest(), 'record_found': bool(found),
            'fields_differing_from_cache': [f for f in FIELDS if found and found[0].get(f) != cached[ident].get(f)],
            'live': {f: found[0].get(f) for f in FIELDS} if found else None})
    except Exception as error:
        row.update({'status': 'failed', 'error': str(error)[:200]})
    manifest.append(row)
    time.sleep(1)
(here / 'live/manifest.json').write_text(json.dumps(manifest, indent=1) + '\n')
print(json.dumps(manifest, indent=1))
