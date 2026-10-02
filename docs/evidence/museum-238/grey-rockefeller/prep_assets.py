"""Derive the additions assets from catalogue photographs (no generation).
usage: prep_assets.py CATALOGUE_SCRATCH_DIR WORKTREE"""
import sys, json, os
import numpy as np, cv2
from PIL import Image
cat, wt = sys.argv[1], sys.argv[2]
app = os.path.join(wt, 'image-work/collection-room-remodel')
ic = os.path.join(app, 'inventory-catalogue')
grey = os.path.join(app, 'additions/grey'); rock = os.path.join(app, 'additions/rockefeller')
os.makedirs(grey, exist_ok=True); os.makedirs(rock, exist_ok=True)

def jpg(src, dst, box=None, q=86):
    im = Image.open(src).convert('RGB')
    if box: im = im.crop(box)
    im.thumbnail((1600, 1600), Image.LANCZOS)
    im.save(dst, quality=q, optimize=True)
    assert os.path.getsize(dst) < 600_000, dst
    return im.size

sizes = {}
sizes['gericault-43.539.jpg'] = jpg(f'{cat}/gericault-cart-43539-zoom-0.jpg', f'{grey}/gericault-43.539.jpg')
sizes['bannister-2023.53.jpg'] = jpg(f'{cat}/bannister-shepherdess-202353-zoom-0.jpg', f'{grey}/bannister-2023.53.jpg')
sizes['eastlake-56.099.jpg'] = jpg(f'{cat}/eastlake-celian-56099-zoom-0.jpg', f'{grey}/eastlake-56.099.jpg')
sizes['daubigny-73.120.jpg'] = jpg(f'{ic}/daubigny-grey-landscape-zoom-0.jpg', f'{grey}/daubigny-73.120.jpg', (13, 17, 1312, 749))
sizes['villeneuve-1998.35.jpg'] = jpg(f'{ic}/villeneuve-aqueduct-zoom-0.jpg', f'{grey}/villeneuve-1998.35.jpg', (49, 33, 1282, 963))
sizes['pannini-56.094.jpg'] = jpg(f'{ic}/pannini-colosseum-zoom-0.jpg', f'{grey}/pannini-56.094.jpg')
sizes['rodin-23.005.jpg'] = jpg(f'{ic}/rodin-hand-god-zoom-0.jpg', f'{grey}/rodin-23.005.jpg')
sizes['smirke-2016.80.89.jpg'] = jpg(f'{cat}/smirke-cloisters-wood-20168089-zoom-0.jpg', f'{rock}/smirke-2016.80.89.jpg', (172, 163, 1152, 814))
sizes['smirke-2016.80.91.jpg'] = jpg(f'{cat}/smirke-lady-park-20168091-zoom-0.jpg', f'{rock}/smirke-2016.80.91.jpg', (179, 179, 1121, 778))
sizes['textile-44.226.jpg'] = jpg(f'{cat}/apparel-textile-44226-zoom-0.jpg', f'{rock}/textile-44.226.jpg', (120, 45, 1250, 2170), q=80)
sizes['neptune-2017.74.31.1.jpg'] = jpg(f'{cat}/neptune-201774311-zoom-0.jpg', f'{rock}/neptune-2017.74.31.1.jpg')
sizes['amphitrite-2017.74.31.2.jpg'] = jpg(f'{cat}/amphitrite-201774312-zoom-0.jpg', f'{rock}/amphitrite-2017.74.31.2.jpg')

def cutout(src, dst, size_m, rect, floor_y=None, rows=24):
    """GrabCut the object from its studio background; write an RGBA cut-out and the row silhouette."""
    im = cv2.imread(src); h, w = im.shape[:2]
    mask = np.zeros((h, w), np.uint8); bg = np.zeros((1, 65)); fg = np.zeros((1, 65))
    cv2.grabCut(im, mask, rect, bg, fg, 6, cv2.GC_INIT_WITH_RECT)
    m = ((mask == 1) | (mask == 3)).astype('uint8')
    if floor_y: m[floor_y:] = 0
    n, lab, stats, _ = cv2.connectedComponentsWithStats(m)
    m = (lab == 1 + np.argmax(stats[1:, cv2.CC_STAT_AREA])).astype('uint8')
    m = cv2.morphologyEx(m, cv2.MORPH_CLOSE, np.ones((9, 9), np.uint8))
    ys, xs = np.where(m > 0); x0, x1, y0, y1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
    rgb = cv2.cvtColor(im, cv2.COLOR_BGR2RGB)[y0:y1, x0:x1].copy(); a = m[y0:y1, x0:x1]
    rgb[a == 0] = np.median(rgb[a > 0], axis=0).astype('uint8')  # neutral edge tone, no fringe
    out = Image.fromarray(np.dstack([rgb, a * 255])); out.thumbnail((768, 768), Image.LANCZOS); out.save(dst, optimize=True)
    hh, ww = a.shape; prof = []
    for r in range(rows):
        yy = int(round((hh - 1) * r / (rows - 1))); on = np.where(a[yy] > 0)[0]
        if len(on) == 0: on = np.where(a[min(hh - 1, yy + 3)] > 0)[0]
        prof.append([round(float(on.min()) / ww, 4), round(float(on.max() + 1) / ww, 4)])
    json.dump({'size_m': size_m, 'rows': prof, 'aspect_px': [int(ww), int(hh)], 'source': os.path.basename(src),
               'rear': 'front photograph repeated on the back; depth from the catalogue record, section assumed elliptical'},
              open(dst.replace('.png', '.json'), 'w'), indent=1)
    print(os.path.basename(dst), 'silhouette w/h %.3f' % (ww / hh), 'catalogue w/h %.3f' % (size_m[0] / size_m[1]), os.path.getsize(dst))

cutout(f'{ic}/rodin-hand-god-zoom-0.jpg', f'{grey}/rodin-23.005-cut.png', [0.826, 1.003, 0.68], (200, 40, 960, 1085), floor_y=1108)
cutout(f'{cat}/neptune-201774311-zoom-0.jpg', f'{rock}/neptune-2017.74.31.1-cut.png', [0.27, 0.298, 0.24], (180, 60, 960, 1080))
cutout(f'{cat}/amphitrite-201774312-zoom-0.jpg', f'{rock}/amphitrite-2017.74.31.2-cut.png', [0.28, 0.298, 0.19], (150, 60, 1000, 1100))
print(json.dumps(sizes))

# The Rodin stands on a dark studio ground: a brightness cut is cleaner than GrabCut there.
def rodin():
    src = f'{ic}/rodin-hand-god-zoom-0.jpg'; dst = f'{grey}/rodin-23.005-cut.png'
    im = cv2.imread(src); h, w = im.shape[:2]
    v = cv2.cvtColor(im, cv2.COLOR_BGR2HSV)[:, :, 2]
    m = (cv2.GaussianBlur(v, (0, 0), 2) > 128).astype('uint8'); m[1106:] = 0
    m = cv2.morphologyEx(m, cv2.MORPH_CLOSE, np.ones((31, 31), np.uint8))
    n, lab, stats, _ = cv2.connectedComponentsWithStats(m)
    m = (lab == 1 + np.argmax(stats[1:, cv2.CC_STAT_AREA])).astype('uint8')
    ff = m.copy(); cv2.floodFill(ff, np.zeros((h + 2, w + 2), np.uint8), (0, 0), 2); m[ff == 0] = 1  # fill holes
    ys, xs = np.where(m > 0); x0, x1, y0, y1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
    rgb = cv2.cvtColor(im, cv2.COLOR_BGR2RGB)[y0:y1, x0:x1].copy(); a = m[y0:y1, x0:x1]
    rgb[a == 0] = np.median(rgb[a > 0], axis=0).astype('uint8')
    out = Image.fromarray(np.dstack([rgb, a * 255])); out.thumbnail((512, 512), Image.LANCZOS); out.save(dst, optimize=True)
    hh, ww = a.shape; prof = []
    for r in range(24):
        yy = int(round((hh - 1) * r / 23)); on = np.where(a[yy] > 0)[0]
        prof.append([round(float(on.min()) / ww, 4), round(float(on.max() + 1) / ww, 4)])
    json.dump({'size_m': [0.826, 1.003, 0.68], 'rows': prof, 'aspect_px': [int(ww), int(hh)], 'source': os.path.basename(src),
               'rear': 'front photograph repeated on the back; depth from the catalogue record, section assumed elliptical'},
              open(dst.replace('.png', '.json'), 'w'), indent=1)
    print('rodin w/h %.3f' % (ww / hh), os.path.getsize(dst))
rodin()
for f in [f'{rock}/neptune-2017.74.31.1-cut.png', f'{rock}/amphitrite-2017.74.31.2-cut.png']:
    im = Image.open(f); im.thumbnail((512, 512), Image.LANCZOS); im.save(f, optimize=True); print(os.path.basename(f), os.path.getsize(f))
