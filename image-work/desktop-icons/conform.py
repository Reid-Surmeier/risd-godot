"""Muse desktop icons -> game assets. Key the flat magenta to alpha (despilled), split the picture into
the icon and its label, and scale each so its black outline/stroke is STROKE game px wide: every icon
and label then sits on the same pixel size, as in the owner's screenshot. Restack icon over label."""
import json, numpy as np
from PIL import Image

STROKE = 1.5  # game px per drawn pixel; the screenshot's outlines and letters are about this wide
GAP = 3       # game px between icon and label
M = np.array([255.0, 0.0, 255.0])

def keyed(p):
    a = np.asarray(Image.open(p).convert('RGB')).astype(float)
    alpha = np.clip((np.linalg.norm(a - M, axis=2) - 60) / 120, 0, 1)
    rgb = np.clip((a - (1 - alpha[..., None]) * M) / np.maximum(alpha[..., None], 1e-3), 0, 255)
    return rgb, alpha

def stroke(rgb, alpha):  # median length of dark runs, rows and columns: one drawn pixel in source px
    dark = (rgb.mean(2) < 90) & (alpha > 0.5)
    runs = []
    for m in (dark, dark.T):
        for row in m:
            d = np.diff(np.r_[0, row.astype(int), 0]); s, e = np.nonzero(d == 1)[0], np.nonzero(d == -1)[0]
            runs += list(e - s)
    runs = np.array(runs); runs = runs[(runs >= 3) & (runs <= 60)]
    return float(np.median(runs))

def scaled(rgb, alpha, f):
    pre = Image.fromarray(np.dstack([rgb * alpha[..., None], alpha * 255]).astype(np.uint8), 'RGBA')
    pre = pre.crop(pre.getbbox())
    pre = pre.resize((max(1, round(pre.width * f)), max(1, round(pre.height * f))), Image.LANCZOS)
    b = np.asarray(pre).astype(float); al = b[..., 3:] / 255
    return Image.fromarray(np.dstack([np.clip(b[..., :3] / np.maximum(al, 1e-3), 0, 255), b[..., 3]]).astype(np.uint8), 'RGBA')

report = {}
for k, p in json.load(open('muse-outputs.json')).items():
    rgb, alpha = keyed(p)
    rows = np.nonzero(alpha.max(1) > 0.5)[0]
    gaps = np.diff(rows); cut = rows[np.argmax(gaps)] + gaps.max() // 2  # the widest empty band: icon above, label below
    if k in ('screensavers', 'do_not_open'):  # two-line labels: the widest band is between icon and first line only if bigger than line gap
        bands = sorted([(g, rows[i]) for i, g in enumerate(gaps) if g > 5], key=lambda t: t[1])
        cut = bands[0][1] + bands[0][0] // 2
    parts = []
    for sl in (slice(0, cut), slice(cut, None)):
        r, a = rgb[sl], alpha[sl]
        parts.append(scaled(r, a, STROKE / stroke(r, a)))
    icon, label = parts
    w = max(icon.width, label.width)
    out = Image.new('RGBA', (w, icon.height + GAP + label.height))
    out.alpha_composite(icon, ((w - icon.width) // 2, 0)); out.alpha_composite(label, ((w - label.width) // 2, icon.height + GAP))
    out.save(f'conformed/{k}.png')
    report[k] = {'museRun': p.split('/runs/')[1].split('/')[0], 'size': out.size, 'icon': icon.size, 'label': label.size}
json.dump(report, open('conformed/report.json', 'w'), indent=1)
for k, v in report.items(): print(k, v['icon'], v['label'])
