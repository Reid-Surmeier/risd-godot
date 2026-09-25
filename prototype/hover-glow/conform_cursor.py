"""Retro-conformance reduction for the Muse cursor stills: key the flat magenta ground to alpha, crop to
the arrow, snap to the arrow's own pixel grid (measured from its runs), and emit the cursor at 2x grid.
The only code that touches the generated pixels; it never draws."""
import sys, numpy as np
from PIL import Image

def cell_size(mask):
    runs = []
    for row in mask[::7]:
        edges = np.flatnonzero(np.diff(row.astype(np.int8)))
        runs += list(np.diff(edges))
    runs = np.array([r for r in runs if r > 4])
    # the grid pitch is the most common short run, refined as the mean of runs near it
    base = np.bincount(runs).argmax()
    near = runs[(runs > base * 0.8) & (runs < base * 1.2)]
    return float(near.mean())

def conform(src, dst, scale=2):
    im = np.asarray(Image.open(src).convert("RGB")).astype(int)
    r, g, b = im[..., 0], im[..., 1], im[..., 2]
    ground = (r > 180) & (b > 180) & (g < 110)
    ys, xs = np.nonzero(~ground)
    y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    dark = (im[..., :].sum(-1) < 150) & ~ground
    c = cell_size(dark[y0:y1, x0:x1])
    w, h = round((x1 - x0) / c), round((y1 - y0) / c)
    out = np.zeros((h, w, 4), np.uint8)
    for j in range(h):
        for i in range(w):
            cy, cx = int(y0 + (j + 0.5) * c), int(x0 + (i + 0.5) * c)
            k = max(1, int(c * 0.25))
            patch = im[cy - k:cy + k, cx - k:cx + k].reshape(-1, 3)
            key = ground[cy - k:cy + k, cx - k:cx + k].reshape(-1)
            if key.mean() > 0.5:
                continue
            out[j, i, :3] = np.median(patch[~key], axis=0)
            out[j, i, 3] = 255
    img = Image.fromarray(out, "RGBA").resize((w * scale, h * scale), Image.NEAREST)
    img.save(dst)
    print(dst, "grid", round(c, 2), "cells", w, h, "->", img.size)

conform(sys.argv[1], sys.argv[2], int(sys.argv[3]) if len(sys.argv) > 3 else 2)
