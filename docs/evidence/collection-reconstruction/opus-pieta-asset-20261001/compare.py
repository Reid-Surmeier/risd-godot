"""Lay the sources and the native renders side by side at one figure height, and measure the front outline.
Usage: python3 compare.py <photos dir> <frames dir> <renders dir> <out dir> [muse sheet, when texture_trial.gd has run]
The mesh is about 10 percent wider than photograph 0 on purpose: it is fitted to the catalogue width."""
import json, sys
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage

photos, frames, renders, out = sys.argv[1:5]
H = 760

def fit(image, mask, label):
    ys, xs = np.where(mask.any(1))[0], np.where(mask.any(0))[0]
    pad = int((ys[-1] - ys[0]) * .05)
    crop = image.crop((max(xs[0] - pad, 0), max(ys[0] - pad, 0), min(xs[-1] + pad, image.width), min(ys[-1] + pad, image.height)))
    crop = crop.resize((int(crop.width * H / crop.height), H), Image.LANCZOS)
    tile = Image.new("RGB", (max(crop.width, 380), H + 44), "white")
    tile.paste(crop, ((tile.width - crop.width) // 2, 44))
    ImageDraw.Draw(tile).text((8, 14), label, fill="black")
    return tile

def wood(a):
    m = ndimage.binary_opening((a[..., 0] - a[..., 2]) > 22, iterations=2)
    lab, _ = ndimage.label(m)
    return ndimage.binary_fill_holes(lab == np.argmax(np.bincount(lab.ravel())[1:]) + 1)

def photo(index, label):
    image = Image.open("%s/pieta-59128-zoom-%d.jpg" % (photos, index)).convert("RGB")
    a = np.asarray(image).astype(int)
    # Photograph 0 is colour; the others are grey or white, so they keep their whole frame.
    return fit(image, wood(a) if index == 0 else np.ones(a.shape[:2], bool), label)

def frame(seconds, box, label):
    image = Image.open("%s/IMG_6383-%s.jpg" % (frames, seconds)).convert("RGB").crop(box)
    return fit(image, np.ones((image.height, image.width), bool), label)

def render_mask(name):
    a = np.asarray(Image.open("%s/%s.png" % (renders, name)).convert("RGB")).astype(int)
    return np.abs(a - a[2, 2]).sum(2) > 6

def render(name, label):
    return fit(Image.open("%s/%s.png" % (renders, name)).convert("RGB"), render_mask(name), label)

rows = {
    "front": [photo(0, "official photograph 0 (colour front)"), render("front", "native front, flat source palette"), photo(2, "official photograph 2 (old black-and-white front)")],
    "installed": [frame("024.60", (180, 520, 720, 1220), "native IMG_6383 24.6 s, behind glass"), render("above-front", "native from above and in front"),
        frame("062.00", (440, 660, 640, 940), "native IMG_6383 62.0 s, in its wall case")],
    "quarters": [render("above-quarter-left", "above, viewer's left (no source)"), render("quarter-left", "35 deg to the viewer's left (no source)"),
        render("quarter-right", "35 deg to the viewer's right (no source)"), render("above-quarter-right", "above, viewer's right (no source)")],
    "rear": [photo(1, "official photograph 1: a white silhouette, NOT a rear"), render("rear", "plain closing back (no source)")],
    "sides": [render("left", "viewer's left side (no source)"), render("right", "viewer's right side (no source)"), render("rear-quarter", "rear quarter (no source)"),
        photo(3, "official photograph 3 (detail of Christ)")],
}
if len(sys.argv) > 5:
    sheet = Image.open(sys.argv[5]).convert("RGB")
    rows["muse"] = [fit(sheet, np.ones((sheet.height, sheet.width), bool), "root's Muse sheet (a modelling reference, not evidence)")]
    # texture_trial.gd: the Muse FRONT panel laid on the mesh, against the flat palette, at the angles a visitor sees.
    rows["texture"] = [render("quarter-right", "flat palette"), render("trial-projected-front", "Muse FRONT projected: front"),
        render("trial-projected-quarter-right", "projected: viewer's right"), render("trial-projected-above-front", "projected: above"),
        render("trial-facet-quarter-right", "one sample per face: viewer's right")]
for name, tiles in rows.items():
    strip = Image.new("RGB", (sum(t.width for t in tiles), H + 44), "white")
    x = 0
    for t in tiles:
        strip.paste(t, (x, 0))
        x += t.width
    strip.save("%s/compare-%s.jpg" % (out, name), quality=88)

# Front outline against photograph 0 every 2.5 cm of height. x is centimetres from the middle of each outline,
# viewer's right positive, both scaled so the full height is 45.7 cm. The mesh x is also shown divided by its
# catalogue-width stretch, which is the like-for-like comparison of shape.
def outline(mask):
    ys, xs = np.where(mask.any(1))[0], np.where(mask.any(0))[0]
    return mask, ys[-1], (xs[0] + xs[-1]) / 2, (ys[-1] - ys[0]) / 45.7, (xs[-1] - xs[0]) / (ys[-1] - ys[0]) * 45.7

def edges(view, cm, divide=1.0):
    mask, bottom, centre, scale, _ = view
    row = np.where(mask[int(round(bottom - cm * scale))])[0]
    return [round(float((row[0] - centre) / scale / divide), 1), round(float((row[-1] - centre) / scale / divide), 1)]

p = outline(wood(np.asarray(Image.open("%s/pieta-59128-zoom-0.jpg" % photos).convert("RGB")).astype(int)))
r = outline(render_mask("front"))
stretch = r[4] / p[4]
table = []
lines = ["photograph 0 outline %.1f cm wide at 45.7 cm high; mesh %.1f cm; stretch %.3f" % (p[4], r[4], stretch),
    "y cm | photograph left..right | mesh left..right | mesh / stretch | difference after removing the stretch"]
for cm in np.arange(1.5, 45, 2.5):
    a, b, c = edges(p, cm), edges(r, cm), edges(r, cm, stretch)
    d = [round(c[0] - a[0], 1), round(c[1] - a[1], 1)]
    table.append({"y_cm": float(cm), "photo": a, "mesh": b, "mesh_unstretched": c, "diff": d})
    lines.append("%5.1f | %6.1f %6.1f | %6.1f %6.1f | %6.1f %6.1f | %+5.1f %+5.1f" % (cm, *a, *b, *c, *d))
mean = float(np.mean([abs(v) for row in table for v in row["diff"]]))
worst = max(table, key=lambda row: max(abs(row["diff"][0]), abs(row["diff"][1])))
lines.append("mean |difference| %.2f cm, worst %.1f cm at y %.1f" % (mean, max(abs(worst["diff"][0]), abs(worst["diff"][1])), worst["y_cm"]))
# The rear render must be the mirror of the front one: a missing or inside-out back face would show the ground.
front, rear = render_mask("front"), render_mask("rear")[:, ::-1]
holes = int((front ^ rear).sum())
lines.append("rear outline against the mirrored front outline: %d of %d pixels differ" % (holes, int(front.sum())))
print("\n".join(lines))
open("%s/silhouette-vs-official.txt" % out, "w").write("\n".join(lines) + "\n")
json.dump({"photo_width_cm": round(p[4], 2), "mesh_width_cm": round(r[4], 2), "stretch": round(stretch, 4), "mean_abs_cm": round(mean, 2), "worst": worst,
    "rear_vs_mirrored_front_pixels": holes, "front_pixels": int(front.sum()), "rows": table}, open("%s/silhouette-vs-official.json" % out, "w"), indent=1)
