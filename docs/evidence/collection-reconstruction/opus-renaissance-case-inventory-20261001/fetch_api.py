"""Bounded RISD catalogue queries; raw bytes kept untouched with sha256. Same Scrapling Fetcher route as root's collection-v45-fragment-api.py.
Usage: fetch_api.py NAME=TERM[@onview][@pN] ...   (free public API, sequential, 1s apart)"""
import hashlib, json, sys, time, urllib.parse
from pathlib import Path
from scrapling.fetchers import Fetcher
out = Path(__file__).parent / 'api'; man_p = out / 'manifest.json'
man = json.loads(man_p.read_text()) if man_p.exists() else []
for arg in sys.argv[1:]:
    name, spec = arg.split('=', 1); term, *flags = spec.split('@')
    q = {'search_api_fulltext': term, 'has_images': '1', 'items_per_page': '25'}
    for f in flags:
        if f == 'onview': q['field_on_view'] = '1'
        elif f.startswith('p'): q['page'] = f[1:]
        elif f == 'id': q = {'id': term}
    url = 'https://risdmuseum.org/api/v1/collection?' + urllib.parse.urlencode(q)
    path = out / f'{name}.json'
    assert not path.exists(), path
    r = Fetcher.get(url); body = r.body
    rows = json.loads(body) if r.status == 200 else []
    assert isinstance(rows, list)
    path.write_bytes(body)
    man.append({'file': path.name, 'url': url, 'status': r.status, 'rows': len(rows), 'sha256': hashlib.sha256(body).hexdigest(), 'fetched_utc': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())})
    man_p.write_text(json.dumps(man, indent=1) + '\n')
    print(f'## {name} {r.status} rows={len(rows)}')
    for x in rows:
        print(f"  {x.get('objectNumber',''):13} ov={int(bool(x.get('onView')))} {x.get('datingYearFrom','')}-{x.get('datingYearTo','')} {x.get('title','')[:50]} | {x.get('primaryMaker','')[:28]} | {';'.join(x.get('medium') or [])[:38]} | {x.get('dimensions','')[:34]}")
    time.sleep(1)
