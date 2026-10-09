"""Fetch one public page or image and record it. Public URLs only; no login, no bypass.

    ~/.local/share/uv/tools/scrapling/bin/python fetch.py URL NAME     # NAME under snapshots/
HTML is stored gzipped; the manifest keeps URL, status, UTC time and sha256 of the body as served.
"""
import gzip, hashlib, json, sys
from datetime import datetime, timezone
from pathlib import Path
from scrapling.fetchers import Fetcher

here = Path(__file__).resolve().parent
url, name = sys.argv[1], sys.argv[2]
page = Fetcher.get(url, timeout=40)
body = page.body if isinstance(page.body, bytes) else str(page.body).encode()
path = here / "snapshots" / name
binary = name.rsplit(".", 1)[-1] in ("jpg", "jpeg", "png", "webp", "json")
if page.status == 200:
    path.write_bytes(body) if binary else gzip.open(str(path) + ".gz", "wb").write(body)
manifest = here / "snapshots" / "manifest.json"
rows = json.loads(manifest.read_text()) if manifest.exists() else []
rows = [r for r in rows if r["name"] != name] + [{"url": url, "name": name + ("" if binary else ".gz"), "http_status": page.status,
        "retrieved_utc": datetime.now(timezone.utc).isoformat(timespec="seconds"), "bytes": len(body), "sha256": hashlib.sha256(body).hexdigest()}]
manifest.write_text(json.dumps(rows, indent=1) + "\n")
print(page.status, len(body), name)
