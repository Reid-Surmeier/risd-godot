"""Free: small copies of every catalogue photograph of the given accessions, laid out numbered, to look at before any
description or view is chosen. Two steps, because Scrapling's Python has no Pillow:
    ~/.local/share/uv/tools/scrapling/bin/python look_views.py fetch DIR ACC [ACC ...]
    python3 look_views.py sheet DIR OUT.jpg ACC [ACC ...]"""
import sys, os, json, time, glob
mode, d = sys.argv[1], sys.argv[2]
if mode == "fetch":
    from scrapling.fetchers import Fetcher
    os.makedirs(d, exist_ok=True)
    for a in sys.argv[3:]:
        for n, i in enumerate(json.load(open(os.path.expanduser(f"~/risd-godot-ingestion/catalogue-masters/{a}/index.json"))), 1):
            f = f"{d}/{a}-{n:02d}.jpg"
            if os.path.exists(f): continue
            r = Fetcher.get(f"https://iiif.micr.io/{i['micrio']}/full/500,/0/default.jpg" if i.get("micrio") else i["zoom"], stealthy_headers=True, impersonate="chrome"); time.sleep(0.5)
            if r.status == 200: open(f, "wb").write(r.body)
else:
    from PIL import Image, ImageDraw
    out, rows = sys.argv[3], []
    for a in sys.argv[4:]:
        cells = []
        for f in sorted(glob.glob(f"{d}/{a}-*.jpg")):
            im = Image.open(f).convert("RGB"); im = im.resize((im.width * 300 // im.height, 300)); ImageDraw.Draw(im).text((4, 4), f"{a} #{int(f[-6:-4])}", fill=(255, 0, 255)); cells.append(im)
        rows.append(cells)
    W = max(sum(c.width for c in r) for r in rows); s = Image.new("RGB", (W, 300 * len(rows)), "white")
    for j, r in enumerate(rows):
        x = 0
        for c in r: s.paste(c, (x, j * 300)); x += c.width
    s.thumbnail((1950, 1500)); s.save(out, quality=85); print(out, s.size, [len(r) for r in rows])
