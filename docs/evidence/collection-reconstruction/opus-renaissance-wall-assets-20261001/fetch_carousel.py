"""The carousel photographs the inventory did not download (it kept the first two per page): fetched from the URLs on the
inventory's cached catalogue pages so every official view is looked at before a back is called unobserved.
python3 fetch_carousel.py [root checkout]   writes live/carousel-*.jpg and live/carousel.json. Free public CDN, three requests at most."""
import gzip, hashlib, json, re, sys, time, urllib.request
from pathlib import Path
here = Path(__file__).parent
review = Path(sys.argv[1] if len(sys.argv) > 1 else '/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction') / 'docs/evidence/collection-reconstruction/opus-renaissance-case-inventory-20261001'
(here / 'live').mkdir(exist_ok=True)
rows = []
for slug in ['velvet-cover-23307x', 'woodcutters-29280', 'madonna-and-child-saint-barbara-and-saint-catherine-58196']:
    html = gzip.decompress((review / 'photos' / f'{slug}.html.gz').read_bytes()).decode()
    items = re.findall(r'data-asset-copyright="([^"]*)" data-zoom-url="([^"]+)"', html)
    row = {'page': slug, 'carousel_photos': len(items), 'already_in_inventory': min(2, len(items)), 'fetched': []}
    for i, (rights, url) in enumerate(items[2:], 2):
        try:
            body = urllib.request.urlopen(url, timeout=120).read()  # the CDN renders large images slowly on a first request
            name = f'carousel-{slug}-zoom-{i}.jpg'
            (here / 'live' / name).write_bytes(body)
            row['fetched'].append({'file': name, 'url': url, 'asset_copyright': rights, 'bytes': len(body), 'sha256': hashlib.sha256(body).hexdigest(),
                'fetched_utc': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())})
        except Exception as error:
            row['fetched'].append({'url': url, 'status': 'failed', 'error': str(error)[:200]})
        time.sleep(1)
    rows.append(row)
(here / 'live/carousel.json').write_text(json.dumps(rows, indent=1) + '\n')
print(json.dumps(rows, indent=1))
