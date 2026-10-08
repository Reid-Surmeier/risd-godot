"""Blend several projected views into one colour texture (layers written by project_photo.py --layer).
usage: blend_views.py OUT.png [--ao AO.png:STRENGTH] LAYER_PREFIX[:PRIORITY] ...
Each texel is the average of the views that see it, weighted by how squarely they see it (squared) and by the view's
priority, so views cross-fade over a wide band instead of meeting at a seam. Texels no view saw are filled inward from
the colour around them, not left in the base colour; when more than a quarter of the texture was seen by none (a relief
with one view) they take the median seen colour instead. Free."""
import sys, numpy as np, cv2
from PIL import Image
args = sys.argv[1:]; out = args.pop(0); ao = None
if args[0] == "--ao": args.pop(0); ao = args.pop(0)
acc = wsum = used = None
for spec in args:
    pre, _, pr = spec.partition(":"); c = np.array(Image.open(pre + "-rgb.png").convert("RGB")).astype(np.float32)
    w = (np.array(Image.open(pre + "-w.png").convert("L")).astype(np.float32) / 255) ** 2 * float(pr or 1)
    acc = c * w[..., None] if acc is None else acc + c * w[..., None]; wsum = w if wsum is None else wsum + w
    used = np.array(Image.open(pre + "-used.png").convert("L")) > 0
seen = wsum > 0.02; col = np.zeros_like(acc); col[seen] = acc[seen] / wsum[seen][:, None]; col = col.clip(0, 255).astype(np.uint8)
unseen = used & ~seen; col[~seen] = 0; note = "filled from its surroundings"
if unseen.sum() > 0.25 * used.sum():
    # ponytail: one view of a relief leaves half the texture unseen, and on a reduced mesh a texel's neighbours in the
    # texture are not its neighbours on the surface, so filling inward streaks. Unseen and grazing texels take the median
    # of the squarely seen colour instead. The 0.25 and 0.5 are by eye on 69.196; a second real view removes the need.
    base = np.median(col[wsum > 0.5], axis=0); t = np.clip(wsum / 0.5, 0, 1)[..., None]
    col = np.where(used[..., None], col * t + base * (1 - t), 0).astype(np.uint8); seen = used; note = "given the median seen colour"
col = cv2.inpaint(col, (~seen).astype(np.uint8), 6, cv2.INPAINT_TELEA)  # unseen texels and the gutters between islands
if ao:
    path, _, k = ao.partition(":"); k = float(k or 0.25); a = np.array(Image.open(path).convert("L").resize(col.shape[1::-1], Image.LANCZOS)).astype(np.float32) / 255
    col = (col * (1 - k + k * a[..., None])).clip(0, 255).astype(np.uint8)
Image.fromarray(col).save(out); print(f"blended {len(args)} views; {100 * unseen.sum() / max(1, used.sum()):.1f}% of the used texture was seen by none and {note}")
