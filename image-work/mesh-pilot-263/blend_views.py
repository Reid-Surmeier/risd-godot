"""Blend several projected views into one colour texture (layers written by project_photo.py --layer).
usage: blend_views.py OUT.png [--ao AO.png:STRENGTH] LAYER_PREFIX[:PRIORITY] ...
Each texel is the average of the views that see it, weighted by how squarely they see it (squared) and by the view's
priority, so views cross-fade over a wide band instead of meeting at a seam. Texels no view saw are filled inward from
the colour around them, not left in the base colour. Free."""
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
unseen = used & ~seen; col[~seen] = 0
col = cv2.inpaint(col, (~seen).astype(np.uint8), 6, cv2.INPAINT_TELEA)  # unseen texels and the gutters between islands
if ao:
    path, _, k = ao.partition(":"); k = float(k or 0.25); a = np.array(Image.open(path).convert("L").resize(col.shape[1::-1], Image.LANCZOS)).astype(np.float32) / 255
    col = (col * (1 - k + k * a[..., None])).clip(0, 255).astype(np.uint8)
Image.fromarray(col).save(out); print(f"blended {len(args)} views; {100 * unseen.sum() / max(1, used.sum()):.1f}% of the used texture was seen by none and filled from its surroundings")
