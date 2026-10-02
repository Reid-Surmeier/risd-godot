"""Outline of the native renders against the official photographs, in centimetres at the catalogue height.
Photographs are perspective views from slightly above with a cast shadow; read differences under about 0.7 cm as noise."""
import sys, json
import numpy as np, cv2
from PIL import Image
proj, out = sys.argv[1], sys.argv[2]
P = '/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction/docs/evidence/collection-reconstruction/opus-medieval-case-inventory-20261001/photos/virgin-and-child-15108-zoom-%d.jpg'
def photo_mask(i):
    a = np.array(Image.open(P % i).convert('RGB')).astype(float); h, w, _ = a.shape
    left = a[:, 5:25].mean(axis=1); right = a[:, -25:-5].mean(axis=1); t = np.linspace(0, 1, w)[None, :, None]
    bg = left[:, None, :] * (1 - t) + right[:, None, :] * t
    m = ((np.abs(a - bg).max(axis=2) > 38) | (a.max(axis=2) - a.min(axis=2) > 45)).astype('uint8')
    m = cv2.morphologyEx(m, cv2.MORPH_OPEN, np.ones((5, 5), 'uint8')); n, lab, stats, _ = cv2.connectedComponentsWithStats(m)
    return lab == 1 + np.argmax(stats[1:, 4])
def render_mask(name):
    a = np.array(Image.open('%s/%s.png' % (proj, name)).convert('RGB')).astype(int)
    return np.abs(a - a[5, 5]).max(axis=2) > 6
def table(m):
    ys = np.where(m.any(axis=1))[0]; top, bot = ys.min(), ys.max(); s = (bot - top) / 39.4; rows = {}
    for cm in range(1, 39, 2):
        xs = np.where(m[int(bot - cm * s - s / 2)])[0]; rows[cm] = (xs.min() / s, xs.max() / s)
    return rows
result = {}
for view, photo, kind in [('front-high', 0, 'front'), ('right-high', 2, 'side'), ('left-high', 3, 'side')]:
    a, b = table(photo_mask(photo)), table(render_mask(view)); rows = []
    if kind == 'front':
        ca = np.mean([sum(a[c]) / 2 for c in (33, 35, 37)]); cb = np.mean([sum(b[c]) / 2 for c in (33, 35, 37)])
        for c in a: rows.append({'y_cm': c, 'photo_left': round(a[c][0] - ca, 1), 'native_left': round(b[c][0] - cb, 1), 'photo_right': round(a[c][1] - ca, 1), 'native_right': round(b[c][1] - cb, 1)})
    else:
        # back line as reference; photo 2 faces right (back at low x), photo 3 faces left (back at high x)
        back = 0 if view == 'right-high' else 1; sign = 1 if back == 0 else -1
        ra = np.median([a[c][back] for c in (9, 11, 13, 15, 17, 19, 21)]); rb = np.median([b[c][back] for c in (9, 11, 13, 15, 17, 19, 21)])
        for c in a: rows.append({'y_cm': c, 'photo_back': round(sign * (a[c][back] - ra), 1), 'native_back': round(sign * (b[c][back] - rb), 1), 'photo_front': round(sign * (a[c][1 - back] - ra), 1), 'native_front': round(sign * (b[c][1 - back] - rb), 1)})
    result[view + ' vs official photo %d' % photo] = rows
    keys = [k for k in rows[0] if k.startswith('photo')]
    print(view); print('  y  ' + '  '.join('%s/%s' % (k[6:], 'native') for k in keys))
    for r in rows[::-1]: print('  %2d  ' % r['y_cm'] + '   '.join('%5.1f /%5.1f (%+.1f)' % (r[k], r['native' + k[5:]], r['native' + k[5:]] - r[k]) for k in keys))
json.dump(result, open(out, 'w'), indent=1)
