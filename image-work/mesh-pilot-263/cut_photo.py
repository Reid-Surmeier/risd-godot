"""Free isolate: cut the object out of its catalogue photograph (OpenCV GrabCut), no generation.
usage: cut_photo.py PHOTO OUT.png x,y,w,h [--key-sat N --outline OUTLINE.json] [--under R,G,B] [--open-below FRACTION[:KERNEL]]
--key-sat: a coloured object against a pale wall and floor (keeps saturation > N inside the measured outline).\n--outline FILE [--key NAME] alone: the outline is the cut (medieval/shapes.json with the matching <name>-cut.jpg).
--key-backdrop N: a pale object on a smooth studio backdrop (the backdrop is fitted from the border; keeps what differs by more than N).
--open-below: drop thin slivers of cast shadow in the bottom strip of the picture.
Writes an RGBA PNG (the photograph's own pixels, alpha = the cut) padded to a square, and OUT-preview.jpg on magenta.
The colour under the transparent pixels is a hedge: if a service drops alpha, the object still stands on a contrasting ground."""
import sys, json, argparse
import numpy as np, cv2
from PIL import Image
p = argparse.ArgumentParser(); p.add_argument('photo'); p.add_argument('out'); p.add_argument('rect')
p.add_argument('--outline'); p.add_argument('--key'); p.add_argument('--key-lum', type=int); p.add_argument('--key-white', type=int); p.add_argument('--keep-holes', action='store_true'); p.add_argument('--key-backdrop', type=int); p.add_argument('--iters', type=int, default=8); p.add_argument('--floor', type=float); p.add_argument('--under', default='255,255,255'); p.add_argument('--open-below'); p.add_argument('--key-sat', type=int)
a = p.parse_args()
im = cv2.imread(a.photo); h, w = im.shape[:2]
mask = np.zeros((h, w), np.uint8); bg = np.zeros((1, 65)); fg = np.zeros((1, 65))
if a.key_white:  # a Muse view on seamless white: keep everything that is not near-white
    m = cv2.morphologyEx((im.min(axis=2) < 255 - a.key_white).astype('uint8'), cv2.MORPH_OPEN, np.ones((3, 3), np.uint8))
elif a.key_sat:
    sat = cv2.cvtColor(im, cv2.COLOR_BGR2HSV)[..., 1]
    keep = sat > a.key_sat
    if a.key_lum: keep |= cv2.cvtColor(im, cv2.COLOR_BGR2GRAY) > a.key_lum  # and its pale highlights
    m = cv2.morphologyEx(keep.astype('uint8'), cv2.MORPH_CLOSE, np.ones((15, 15), np.uint8))
    if a.outline:  # the outline already measured on this photograph bounds the key
        pts = (np.array(json.load(open(a.outline))['outline']) * [w, h]).astype(np.int32)
        poly = np.zeros((h, w), np.uint8); cv2.fillPoly(poly, [pts], 1); m &= cv2.dilate(poly, np.ones((31, 31), np.uint8))
elif a.key_lum:  # a pale object against a dark studio ground: keep what is brighter than N
    m = cv2.morphologyEx((cv2.cvtColor(im, cv2.COLOR_BGR2GRAY) > a.key_lum).astype('uint8'), cv2.MORPH_CLOSE, np.ones((9, 9), np.uint8))
elif a.key_backdrop:  # a pale object on a studio backdrop that is a smooth gradient: fit the backdrop from the picture's
    # border (a quadratic surface per channel) and keep what differs from it by more than N. No fixed brightness works here.
    f = im.astype(np.float32); yy, xx = np.mgrid[0:h, 0:w].astype(np.float32); yy /= h; xx /= w; b = max(8, min(h, w) // 25)
    ring = np.ones((h, w), bool); ring[b:h - b, b:w - b] = False  # all four borders: the backdrop runs seamlessly into the floor
    A = np.stack([np.ones_like(xx), xx, yy, xx * xx, yy * yy, xx * yy, yy ** 3, yy ** 4], -1); diff = np.zeros((h, w), np.float32)
    for ch in range(3):
        coef, *_ = np.linalg.lstsq(A[ring], f[..., ch][ring], rcond=None); diff = np.maximum(diff, np.abs(f[..., ch] - A @ coef))
    keep = diff > a.key_backdrop; y0 = h - int(h * .22); lum = f.mean(-1); floor = np.median(np.concatenate([lum[y0:, :b], lum[y0:, w - b:]], 1), 1)
    rough = cv2.GaussianBlur((lum - cv2.GaussianBlur(lum, (0, 0), 6)) ** 2, (0, 0), 6) ** .5  # local roughness
    keep[y0:] &= ~((lum[y0:] < floor[:, None] - 4) & (rough[y0:] < 6.0))  # bottom strip: darker than the floor beside it and smooth is the cast shadow
    m = cv2.morphologyEx(keep.astype('uint8'), cv2.MORPH_CLOSE, np.ones((9, 9), np.uint8)); m = cv2.morphologyEx(m, cv2.MORPH_OPEN, np.ones((5, 5), np.uint8))
elif a.outline:  # an outline already cut and checked by eye for this picture: use it as it is
    o = json.load(open(a.outline)); o = o[a.key] if a.key else o
    m = np.zeros((h, w), np.uint8); cv2.fillPoly(m, [(np.array(o['outline']) * [w, h]).astype(np.int32)], 1)
else:
    cv2.grabCut(im, mask, tuple(int(v) for v in a.rect.split(',')), bg, fg, a.iters, cv2.GC_INIT_WITH_RECT)
    m = ((mask == 1) | (mask == 3)).astype('uint8')
if a.floor: m[int(h * a.floor):] = 0  # the stand the object is photographed on
if a.open_below:  # FRACTION[:KERNEL] - below that height, keep only what lies within KERNEL px of a part at least KERNEL px thick
    frac, _, kk = a.open_below.partition(':'); y0 = int(h * float(frac)); k = np.ones((int(kk or 13),) * 2, np.uint8)
    m[y0:] &= cv2.dilate(cv2.morphologyEx(m[y0:], cv2.MORPH_OPEN, k), k)
n, lab, stats, _ = cv2.connectedComponentsWithStats(m)
m = (lab == 1 + np.argmax(stats[1:, cv2.CC_STAT_AREA])).astype('uint8')
m = cv2.morphologyEx(m, cv2.MORPH_CLOSE, np.ones((5, 5), np.uint8))
ff = np.ones((h + 2, w + 2), np.uint8) * 2 if a.keep_holes else np.pad(m, 1); cv2.floodFill(ff, np.zeros((h + 4, w + 4), np.uint8), (0, 0), 2); m[ff[1:-1, 1:-1] == 0] = 1  # fill enclosed holes; the pad lets the fill run round an object that touches the picture's edge
alpha = cv2.GaussianBlur(m * 255, (3, 3), 0)
ys, xs = np.where(m > 0); x0, x1, y0, y1 = xs.min(), xs.max() + 1, ys.min(), ys.max() + 1
rgb = cv2.cvtColor(im, cv2.COLOR_BGR2RGB)
under = np.array([int(v) for v in a.under.split(',')], np.uint8)
rgb = np.where(alpha[..., None] > 0, rgb, under)
cut = np.dstack([rgb, alpha])[y0:y1, x0:x1].astype(np.uint8)
side = int(max(cut.shape[:2]) * 1.12); canvas = np.zeros((side, side, 4), np.uint8); canvas[..., :3] = under
oy, ox = (side - cut.shape[0]) // 2, (side - cut.shape[1]) // 2
canvas[oy:oy + cut.shape[0], ox:ox + cut.shape[1]] = cut
Image.fromarray(canvas).save(a.out, optimize=True)
pv = canvas[..., :3].astype(float); al = canvas[..., 3:4] / 255.0
pv = (pv * al + np.array([255, 0, 255]) * (1 - al)).astype(np.uint8)
pi = Image.fromarray(pv); pi.thumbnail((1200, 1200)); pi.save(a.out.replace('.png', '-preview.jpg'), quality=88)
print(a.out, canvas.shape, 'object px', x1 - x0, 'x', y1 - y0, 'w/h %.3f' % ((x1 - x0) / (y1 - y0)))
