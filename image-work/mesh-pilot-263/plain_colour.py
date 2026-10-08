"""Colour for plain white marble or white porcelain: no projected views. Free.
usage: plain_colour.py CATALOGUE_CUT.png AO.png OUT.png SIZE_PX [STRENGTH=0.35] [BLUR_PX=2]
One base colour, the median of the brightest third of the object in the catalogue photograph, darkened only by the occlusion
baked from the high mesh, blurred so no crease is a drawn line. Projected Muse views streaked these objects."""
import sys, numpy as np, cv2
from PIL import Image
cut, ao, out, size = sys.argv[1:5]; k = float(sys.argv[5]) if len(sys.argv) > 5 else 0.35; blur = float(sys.argv[6]) if len(sys.argv) > 6 else 2
c = np.array(Image.open(cut).convert("RGBA")); px = c[..., :3][c[..., 3] > 200].astype(float); lum = px @ np.array([0.2126, 0.7152, 0.0722])
base = np.median(px[lum >= np.percentile(lum, 67)], axis=0)  # the brightest third: the lit marble, not its shadow
a = np.array(Image.open(ao).convert("L").resize((int(size), int(size)), Image.LANCZOS)).astype(np.float32) / 255
a = cv2.GaussianBlur(a, (0, 0), blur * int(size) / 512); a = np.clip((a - np.percentile(a, 2)) / max(1e-3, np.percentile(a, 98) - np.percentile(a, 2)), 0, 1)
Image.fromarray((base[None, None, :] * (1 - k + k * a[..., None])).clip(0, 255).astype(np.uint8)).save(out)
print(f"plain colour: base {np.round(base).astype(int).tolist()}, occlusion {k} blurred {blur} px")
