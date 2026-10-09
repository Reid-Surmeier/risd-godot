"""Outline of the native front and rear renders against official photographs 0 and 2, per 2.5 cm of height.
Photographs are perspective views with a cast shadow, so a centimetre is noise. x is centimetres from the middle of
each photograph's own outline, the saint's left positive. Usage: python3 silhouette.py <photos dir> <renders dir>"""
import json, sys
import numpy as np
from PIL import Image
from scipy import ndimage

def photo_rows(path, mirror):
    a = np.asarray(Image.open(path).convert("RGB")).astype(int)
    m = ndimage.binary_opening(((a[..., 0] - a[..., 2]) > 22) | (a.sum(2) < 150), iterations=2)
    lab, _ = ndimage.label(m)
    m = ndimage.binary_fill_holes(lab == np.argmax(np.bincount(lab.ravel())[1:]) + 1)
    ys = np.where(m.any(1))[0]
    xs = np.where(m.any(0))[0]
    return m, ys[-1], (xs[0] + xs[-1]) / 2, (ys[-1] - ys[0]) / 105.4, -1 if mirror else 1

def render_rows(path, mirror):
    a = np.asarray(Image.open(path).convert("RGB")).astype(int)
    m = np.abs(a - a[2, 2]).sum(2) > 6
    ys = np.where(m.any(1))[0]
    # check.gd: orthographic, 1.2 m over the image height, x=0 on the centre column.
    return m, ys[-1], a.shape[1] / 2, a.shape[0] / 120.0, -1 if mirror else 1

def edges(view, cm):
    m, bottom, centre, scale, sign = view
    row = np.where(m[int(round(bottom - cm * scale))])[0]
    pair = sorted([sign * (row[0] - centre) / scale, sign * (row[-1] - centre) / scale])
    return [round(float(v), 1) for v in pair]

out = {}
for name, index, mirror in [["front", 0, False], ["rear", 2, True]]:
    photo = photo_rows("%s/saint-roch-21398-zoom-%d.jpg" % (sys.argv[1], index), mirror)
    render = render_rows("%s/flat-%s.png" % (sys.argv[2], name), mirror)
    rows = []
    print("%s: y cm | photograph %d his right..left | mesh his right..left | mesh minus photograph" % (name, index))
    for cm in np.arange(2.5, 105, 2.5):
        p, r = edges(photo, cm), edges(render, cm)
        d = [round(r[0] - p[0], 1), round(r[1] - p[1], 1)]
        rows.append({"y_cm": float(cm), "photo": p, "mesh": r, "diff": d})
        print("%6.1f | %6.1f %6.1f | %6.1f %6.1f | %+5.1f %+5.1f" % (cm, *p, *r, *d))
    worst = max(rows, key=lambda row: max(abs(row["diff"][0]), abs(row["diff"][1])))
    mean = float(np.mean([abs(v) for row in rows for v in row["diff"]]))
    print("%s: mean |difference| %.2f cm, worst %.1f cm at y %.1f\n" % (name, mean, max(abs(worst["diff"][0]), abs(worst["diff"][1])), worst["y_cm"]))
    out[name] = {"mean_abs_cm": round(mean, 2), "worst": worst, "rows": rows}
json.dump(out, open("silhouette-vs-official.json", "w"), indent=1)
