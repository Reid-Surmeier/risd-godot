"""Bring Muse colour views to the catalogue photograph's exposure and white balance. Free.
usage: match_colour.py CATALOGUE_CUT.png FRONT_VIEW_CUT.png OUT_SUFFIX VIEW_CUT.png [VIEW_CUT.png ...]
The catalogue photograph is the ground truth for the stone's colour. The shift is measured once, between the
photograph and the Muse front view (mean and spread of L, a, b over the object), and the same shift is applied to
every view, so the views stay consistent with each other. Writes <view>OUT_SUFFIX.png beside each view."""
import sys, numpy as np, cv2
from PIL import Image
ref, front, suffix, views = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4:]
def lab(path):
    im = np.array(Image.open(path).convert("RGBA")); m = im[..., 3] > 200
    return im, m, cv2.cvtColor(im[..., :3], cv2.COLOR_RGB2LAB).astype(np.float32)
_, mr, lr = lab(ref); _, mf, lf = lab(front)
gain = lr[mr].std(0) / (lf[mf].std(0) + 1e-6); gain = np.clip(gain, 0.6, 1.6); shift = lr[mr].mean(0) - lf[mf].mean(0) * gain
print("L a b gain", np.round(gain, 3), "shift", np.round(shift, 1), "| catalogue mean", np.round(lr[mr].mean(0), 1), "Muse front mean", np.round(lf[mf].mean(0), 1))
for v in views:
    im, m, l = lab(v); out = np.clip(l * gain + shift, 0, 255).astype(np.uint8)
    im[..., :3] = np.where(m[..., None], cv2.cvtColor(out, cv2.COLOR_LAB2RGB), im[..., :3])
    Image.fromarray(im).save(v.replace(".png", suffix + ".png"))
