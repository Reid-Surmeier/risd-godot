"""Plain public page fetches for edition research; raw bytes kept with url + sha256 in web/manifest.json.
Usage: fetch_web.py NAME=URL ..."""
import hashlib, json, sys, time
from pathlib import Path
from scrapling.fetchers import Fetcher
out = Path(__file__).parent / 'web'; man_p = out / 'manifest.json'
man = json.loads(man_p.read_text()) if man_p.exists() else []
for arg in sys.argv[1:]:
    name, url = arg.split('=', 1)
    try:
        r = Fetcher.get(url); body = r.body; status = r.status
    except Exception as e:
        body = b''; status = f'failed: {type(e).__name__}'
    if body: (out / name).write_bytes(body)
    man.append({'file': name if body else None, 'url': url, 'status': status, 'bytes': len(body), 'sha256': hashlib.sha256(body).hexdigest() if body else None, 'fetched_utc': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())})
    man_p.write_text(json.dumps(man, indent=1) + '\n')
    print(name, status, len(body)); time.sleep(1)
