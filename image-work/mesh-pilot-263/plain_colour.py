"""Colour for plain white marble or white porcelain: no projected views. Free.
usage: plain_colour.py CATALOGUE_CUT.png AO.png OUT.png SIZE_PX [STRENGTH=0.35] [BLUR_PX=2] [BASE=bright|mid] [SHADE=grey|photo]
One base colour from the object in the catalogue photograph: the median of its brightest third (bright: the lit stone, not
its shadow) or of its middle third (mid: a marble whose lit parts are blown pale in the photograph). The occlusion baked from
the high mesh, blurred so no crease is a drawn line, shades it: towards black (grey), or towards the photograph's own shadow
colour, the median of its darkest sixth (photo: warm stone keeps warm hollows). Projected Muse views streaked these objects."""
import sys, numpy as np, cv2
from PIL import Image
cut, ao, out, size = sys.argv[1:5]; k = float(sys.argv[5]) if len(sys.argv) > 5 else 0.35; blur = float(sys.argv[6]) if len(sys.argv) > 6 else 2
which = sys.argv[7] if len(sys.argv) > 7 else "bright"; shade = sys.argv[8] if len(sys.argv) > 8 else "grey"
c = np.array(Image.open(cut).convert("RGBA")); px = c[..., :3][c[..., 3] > 200].astype(float); lum = px @ np.array([0.2126, 0.7152, 0.0722])
lo, hi = (67, 100) if which == "bright" else (33, 67)
base = np.median(px[(lum >= np.percentile(lum, lo)) & (lum <= np.percentile(lum, hi))], axis=0)
dark = np.median(px[lum <= np.percentile(lum, 17)], axis=0) if shade == "photo" else np.zeros(3)
a = np.array(Image.open(ao).convert("L").resize((int(size), int(size)), Image.LANCZOS)).astype(np.float32) / 255
a = cv2.GaussianBlur(a, (0, 0), blur * int(size) / 512); a = np.clip((a - np.percentile(a, 2)) / max(1e-3, np.percentile(a, 98) - np.percentile(a, 2)), 0, 1)
w = np.clip(1 - k + k * a, 0, 1)[..., None]  # 1 where open, 1 - k in the deepest hollow; a strength over 1 reaches the shade colour sooner
Image.fromarray((base[None, None, :] * w + dark[None, None, :] * (1 - w)).clip(0, 255).astype(np.uint8)).save(out)
print(f"plain colour: base ({which}) {np.round(base).astype(int).tolist()}, shade ({shade}) {np.round(dark).astype(int).tolist()}, occlusion {k} blurred {blur} px")
if __name__ == "__main__" and shade == "grey" and which == "bright":  # the one check: the accepted rule is unchanged
    assert np.allclose(dark, 0)
