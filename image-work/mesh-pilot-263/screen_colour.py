"""The fireplace's fire screen (83.152): pull the flat view's pink sheet to a given colour. Free, no generation.
usage: screen_colour.py FLAT_AS_MADE.png OUT.png R,G,B
The sheet is found by its own hue around the middle of the firebox and filled; its pixels are shifted in Lab so their
median becomes R,G,B, keeping the sheet's own soft variation. R,G,B is the colour the flat view needs so that, after the
pipeline's colour match and in-scene lift, the screen renders at the copper measured in the catalogue photograph's firebox
(two renders gave the pipeline's slope per channel; the numbers are in batch/83.152/made.json)."""
import sys, numpy as np, cv2
src, out, rgb = sys.argv[1], sys.argv[2], [int(v) for v in sys.argv[3].split(",")]
f = cv2.imread(src); lab = cv2.cvtColor(f, cv2.COLOR_BGR2LAB).astype(np.float32)
obj = (f.min(-1) < 241).astype(np.uint8); ys, xs = np.where(obj > 0); x0, x1, y0, y1 = xs.min(), xs.max(), ys.min(), ys.max(); W, H = x1 - x0, y1 - y0
sx0, sx1, sy0, sy1 = int(x0 + .42 * W), int(x0 + .58 * W), int(y0 + .68 * H), int(y0 + .86 * H); med = np.median(lab[sy0:sy1, sx0:sx1].reshape(-1, 3), 0)
m = ((np.linalg.norm((lab - med)[..., 1:], axis=-1) < 9) & (np.abs(lab[..., 0] - med[0]) < 45) & (obj > 0)).astype(np.uint8)
m = cv2.morphologyEx(m, cv2.MORPH_OPEN, np.ones((5, 5), np.uint8)); n, lb, st, _ = cv2.connectedComponentsWithStats(m); m = (lb == lb[(sy0 + sy1) // 2, (sx0 + sx1) // 2]).astype(np.uint8)
m = cv2.morphologyEx(m, cv2.MORPH_CLOSE, np.ones((31, 31), np.uint8)); ff = np.pad(m, 1); cv2.floodFill(ff, None, (0, 0), 2); m[ff[1:-1, 1:-1] == 0] = 1
tgt = cv2.cvtColor(np.uint8([[rgb[::-1]]]), cv2.COLOR_BGR2LAB)[0, 0].astype(np.float32)
res = cv2.cvtColor(np.clip(lab + (tgt - med) * cv2.GaussianBlur(m.astype(np.float32), (0, 0), 2)[..., None], 0, 255).astype(np.uint8), cv2.COLOR_LAB2BGR); cv2.imwrite(out, res)
assert 0.1 < m.sum() / (W * H) < 0.2, "the screen should be about a seventh of the object's box"
print("screen px", int(m.sum()), "median RGB now", np.median(res[m > 0], 0)[::-1].round().tolist())
