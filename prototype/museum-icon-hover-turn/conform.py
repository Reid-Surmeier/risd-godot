"""Reduce a Seedance take to hover frames in the icon's own 180x180 tile (Issue #110).

usage: conform.py ICON RUN_DIR FIRST LAST
Takes decoded frame 1 (the locked rest pose) then RUN_DIR/raw/FIRST..LAST (1-based, inclusive), shrinks each back onto the
tight-crop box the anchor was cut from, and writes frames/ICON/000.png... Reduction only: resize
down and paste onto the tile's white. No pixel is drawn.
"""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent
GROUND = 12  # pixels this close to white (euclidean, 0-255) are ground


def snap_ground(frame):
    a = np.asarray(frame).astype(np.int32)
    near = np.sqrt(((255 - a) ** 2).sum(-1)) < GROUND
    a[near] = 255
    return Image.fromarray(a.astype(np.uint8))


icon, run, first, last = sys.argv[1], Path(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4])
box = json.loads((ROOT / "source" / "tight-crop-boxes.json").read_text())[icon]
out = ROOT / "frames" / icon
out.mkdir(parents=True, exist_ok=True)
for old in out.glob("*.png"):
    old.unlink()
size = (box[2] - box[0], box[3] - box[1])
for n, i in enumerate(dict.fromkeys([1, *range(first, last + 1)])):
    frame = Image.open(run / "raw" / f"{i:03}.png").convert("RGB").resize(size, Image.LANCZOS)
    # palette lock of the ground only: the video's near-white becomes the tile's exact white
    frame = snap_ground(frame)
    tile = Image.new("RGB", (180, 180), "white")
    tile.paste(frame, (box[0], box[1]))
    if i == 1:  # the rest pose is the approved icon itself, byte for byte
        tile = Image.open(ROOT / "source" / f"{icon}.png").convert("RGB")
    tile.save(out / f"{n:03}.png")
(out.parent / f"{icon}.json").write_text(json.dumps({"run": run.name, "frames": [first, last], "box": box}))
print(icon, n + 1, "frames ->", out)
