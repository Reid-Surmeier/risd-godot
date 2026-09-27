"""The owner's NextRooms retro reduction (2026-09-15, ~/muse-runs/nextrooms-gallery), as a script.

Muse output -> match each channel's mean/spread to a real photo -> shrink to a low resolution ->
96 colours with Floyd-Steinberg dither -> nearest-neighbour back up -> faint scanlines.

usage: python3 degrade.py in.png out.png [--match photo.png] [--low 480] [--colors 96] [--scan 0.95] [--out-w 1440]
"""
import argparse
import numpy as np
from PIL import Image

ap = argparse.ArgumentParser()
ap.add_argument("src")
ap.add_argument("dst")
ap.add_argument("--match")
ap.add_argument("--low", type=int, default=480)
ap.add_argument("--colors", type=int, default=96)
ap.add_argument("--scan", type=float, default=0.95)
ap.add_argument("--out-w", type=int, default=1440)
ap.add_argument("--aspect", type=float, default=1.5)  # the Collection frame's opening is 3:2
a = ap.parse_args()

im = Image.open(a.src).convert("RGB")
# centre-crop to the target aspect
w, h = im.size
if w / h > a.aspect:
    nw = round(h * a.aspect); im = im.crop(((w - nw) // 2, 0, (w - nw) // 2 + nw, h))
else:
    nh = round(w / a.aspect); im = im.crop((0, (h - nh) // 2, w, (h - nh) // 2 + nh))
x = np.asarray(im).astype(np.float32)
if a.match:
    ref = np.asarray(Image.open(a.match).convert("RGB")).astype(np.float32)
    for c in range(3):
        x[..., c] = (x[..., c] - x[..., c].mean()) / (x[..., c].std() + 1e-6) * ref[..., c].std() + ref[..., c].mean()
im = Image.fromarray(np.clip(x, 0, 255).astype(np.uint8))
low = im.resize((a.low, round(a.low / a.aspect)), Image.LANCZOS)
low = low.quantize(colors=a.colors, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.FLOYDSTEINBERG).convert("RGB")
out = np.asarray(low.resize((a.out_w, round(a.out_w / a.aspect)), Image.NEAREST)).astype(np.float32)
out[1::2] *= a.scan
Image.fromarray(np.clip(out, 0, 255).astype(np.uint8)).save(a.dst)
