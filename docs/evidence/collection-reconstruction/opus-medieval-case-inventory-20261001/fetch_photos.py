"""Official catalogue page + carousel photographs for named accessions found in api/*.json. Raw bytes kept, sha256 recorded.
Usage: fetch_photos.py ACCESSION ...   (free public pages; same route as root's collection-v45-villon-source.py)"""
import glob, gzip, hashlib, json, re, sys, time, urllib.request
from pathlib import Path
from scrapling.fetchers import Fetcher
here = Path(__file__).parent; out = here / 'photos'; man_p = out / 'manifest.json'
man = json.loads(man_p.read_text()) if man_p.exists() else []
rec = {x['objectNumber']: x for f in sorted(glob.glob(str(here / 'api' / '*.json'))) if not f.endswith('manifest.json') for x in json.loads(Path(f).read_text())}
for acc in sys.argv[1:]:
    x = rec[acc]; slug = x['url'].rsplit('/', 1)[1]
    r = Fetcher.get(x['url']); assert r.status == 200, (acc, r.status)
    html = r.html_content.encode()
    (out / f'{slug}.html.gz').write_bytes(gzip.compress(html, mtime=0))
    items = re.findall(r'data-asset-copyright="([^"]*)" data-zoom-url="([^"]+)"', r.html_content)
    entry = {'accession': acc, 'id': x['id'], 'page': x['url'], 'page_sha256': hashlib.sha256(html).hexdigest(), 'photos': []}
    for i, (rights, u) in enumerate(items[:4]):
        b = urllib.request.urlopen(u, timeout=30).read(); p = out / f'{slug}-zoom-{i}.jpg'; p.write_bytes(b)
        entry['photos'].append({'file': p.name, 'url': u, 'asset_copyright': rights, 'bytes': len(b), 'sha256': hashlib.sha256(b).hexdigest()})
    man.append(entry); man_p.write_text(json.dumps(man, indent=1) + '\n')
    print(acc, slug, len(items), 'carousel photos;', len(entry['photos']), 'saved', flush=True)
    time.sleep(1)
