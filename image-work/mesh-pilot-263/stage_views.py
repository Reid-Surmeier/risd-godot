"""Run one object's Muse views (paid, 0.01 USD an image) with every real photograph that helps attached.

    python3 stage_views.py ACCESSION clay|flat [VIEW ...]

Reads batch/<accession>/views.json. clay: the front first, from its photograph; every other view from the photograph
of that direction where one exists (primary), the clay front (authority for material and light) and the front
photograph; a direction with no photograph gets the clay front and every real photograph. flat: the clay view
(layout), the photograph of that direction or the front photograph (colour), and the flat front once it exists.
Skips a view already made. Writes a contact sheet to /tmp/mp263/batch/<accession>-<kind>.jpg and per-view provenance
(real photograph or inferred) to batch/<accession>/made.json."""
import sys, os, json, subprocess
from PIL import Image
here = os.path.dirname(os.path.abspath(__file__)); acc, kind = sys.argv[1], sys.argv[2]; d = f"{here}/batch/{acc}"
V = json.load(open(f"{d}/views.json"))["views"]; photo = {v: os.path.expanduser(x["file"]) for v, x in V.items() if isinstance(x, dict)}
order = ["front"] + [v for v in V if v != "front"]; todo = sys.argv[3:] or order; made = json.load(open(f"{d}/made.json")) if os.path.exists(f"{d}/made.json") else {}
for v in order:
    if v not in todo: continue
    if kind == "clay":
        refs = [photo["front"]] + [p for k, p in photo.items() if k != "front"][:1] if v == "front" else \
               ([photo[v], f"{d}/clay-front.png", photo["front"]] if v in photo else [f"{d}/clay-front.png"] + list(photo.values())[:3])
    else:
        refs = [f"{d}/clay-{v}.png", photo.get(v, photo["front"])] + ([f"{d}/flat-front.png"] if v != "front" else [])
    r = subprocess.run([f"{here}/muse_view.sh", d, f"{kind}-{v}"] + refs, capture_output=True, text=True); print((r.stdout.strip() or r.stderr.strip()[-300:]))
    made[f"{kind}-{v}"] = {"from": "photograph of this direction" if v in photo else "inferred by Muse from the other views", "references": [os.path.relpath(x, here) if x.startswith(here) else x.replace(os.path.expanduser("~"), "~") for x in refs]}
json.dump(made, open(f"{d}/made.json", "w"), indent=1)
ims = [Image.open(f"{d}/{kind}-{v}.png").convert("RGB") for v in order if os.path.exists(f"{d}/{kind}-{v}.png")]
if ims:
    ims = [i.resize((i.width * 420 // i.height, 420)) for i in ims]; s = Image.new("RGB", (sum(i.width for i in ims), 420), "white"); x = 0
    for i in ims: s.paste(i, (x, 0)); x += i.width
    os.makedirs("/tmp/mp263/batch", exist_ok=True); s.save(f"/tmp/mp263/batch/{acc}-{kind}.jpg", quality=84); print("sheet", f"/tmp/mp263/batch/{acc}-{kind}.jpg", [v for v in order if os.path.exists(f"{d}/{kind}-{v}.png")])
