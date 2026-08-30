"""Reduce every delivered candidate to 64 px and lay them out for the vision gate.

The still is not the deliverable and never was: a 1K Qwen candidate looks far too smooth
to be a sprite, and `snap_and_lock` at grid 64 against the anchor palette is what turns
it into one. So the sheet shows what will actually ship, not what came back.
"""
import os, sys, glob
sys.path.insert(0, "/home/reidsurmeier/.qwen-icon-states-wt/seedance/src")
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from seedance_icons.retro import snap_and_lock
from set_palette import set_palette_image

RUNS = sys.argv[1]
ANCH = "/home/reidsurmeier/Qwen-3-pro-Pipeline/artifacts/references/risd-icon-anchors-v001"
OUT  = sys.argv[2]
COLS = int(sys.argv[3]) if len(sys.argv) > 3 else 8
SCALE = 4

# Declared, not sampled. The grammar allows at most one gold element per icon, so gold
# is always a minority colour and median-cut always drops it: sampling the bust anchor
# turned a 16,850-pixel gold star into grey.
palette = set_palette_image()

tiles, labels = [], []
for d in sorted(glob.glob(os.path.join(RUNS, "*/"))):
    imgs = sorted(glob.glob(os.path.join(d, "image-*.png")))
    if not imgs:
        continue
    name = os.path.basename(d.rstrip("/"))
    for i, p in enumerate(imgs):
        red = snap_and_lock(Image.open(p).convert("RGB"), palette, 64)
        tiles.append(red.resize((64 * SCALE, 64 * SCALE), Image.NEAREST))
        labels.append(f"{name} #{i+1}")

if not tiles:
    print("nothing delivered yet"); raise SystemExit(0)

cell = 64 * SCALE
gap, pad = 10, 22
rows = (len(tiles) + COLS - 1) // COLS
sheet = Image.new("RGB", (COLS * cell + (COLS - 1) * gap, rows * (cell + pad)), (250, 250, 248))
for i, t in enumerate(tiles):
    x = (i % COLS) * (cell + gap)
    y = (i // COLS) * (cell + pad)
    sheet.paste(t, (x, y))
sheet.save(OUT)
print(f"{len(tiles)} candidates from {len(set(l.split(' #')[0] for l in labels))} icons -> {OUT} ({sheet.size[0]}x{sheet.size[1]})")
for l in sorted(set(l.split(' #')[0] for l in labels)):
    print("   ", l)
