"""Lay the official photographs, the native renders and the Muse panels side by side at one figure height.
Usage: python3 compare.py <photos dir> <muse sheet> <renders dir> <out dir>"""
import sys
import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage

photos, sheet, renders, out = sys.argv[1:5]
H = 900

def fit(image, mask, label):
    ys, xs = np.where(mask.any(1))[0], np.where(mask.any(0))[0]
    pad = int((ys[-1] - ys[0]) * .04)
    box = (max(xs[0] - pad, 0), max(ys[0] - pad, 0), min(xs[-1] + pad, image.width), min(ys[-1] + pad, image.height))
    crop = image.crop(box)
    crop = crop.resize((int(crop.width * H / crop.height), H), Image.LANCZOS)
    tile = Image.new("RGB", (max(crop.width, 420), H + 44), "white")
    tile.paste(crop, ((tile.width - crop.width) // 2, 44))
    ImageDraw.Draw(tile).text((8, 14), label, fill="black")
    return tile

def photo(index):
    image = Image.open("%s/saint-roch-21398-zoom-%d.jpg" % (photos, index)).convert("RGB")
    a = np.asarray(image).astype(int)
    m = ndimage.binary_opening(((a[..., 0] - a[..., 2]) > 22) | (a.sum(2) < 150), iterations=2)
    lab, _ = ndimage.label(m)
    return fit(image, lab == np.argmax(np.bincount(lab.ravel())[1:]) + 1, "official photograph %d" % index)

def render(name, label):
    image = Image.open("%s/%s.png" % (renders, name)).convert("RGB")
    a = np.asarray(image).astype(int)
    return fit(image, np.abs(a - a[2, 2]).sum(2) > 6, label)

def panel(columns, label):
    image = Image.open(sheet).convert("RGB")
    mask = np.zeros((image.height, image.width), bool)
    mask[136:1292, columns[0]:columns[1]] = True
    return fit(image, mask, label)

rows = {
    "front": [photo(0), render("flat-front", "native, flat observed colours"), render("front", "native, Muse sheet"), panel((1, 579), "Muse FRONT panel")],
    "rear": [photo(2), render("flat-rear", "native, flat observed colours"), render("rear", "native, Muse sheet"), panel((1210, 1760), "Muse REAR panel")],
    "quarter-left": [photo(1), render("flat-quarter-left", "native 30 deg to his left, flat"), render("quarter-left", "native 30 deg to his left, Muse sheet")],
    "quarter-right": [photo(3), render("flat-quarter-right", "native 30 deg to his right, flat"), render("quarter-right", "native 30 deg to his right, Muse sheet")],
    "right": [panel((576, 867), "Muse RIGHT SIDE panel (no official profile exists)"), render("flat-right", "native his right side, flat"), render("right", "native his right side, Muse sheet")],
    "left": [panel((932, 1216), "Muse 'LEFT SIDE' panel: REJECTED, repeats the right"), render("flat-left", "native his left side, flat"), render("left", "native his left side: flat front/rear samples only")],
    "high": [render("flat-high", "native from above, flat"), render("high", "native from above, Muse sheet"), render("flat-rear-quarter-left", "native rear quarter, flat"), render("rear-quarter-left", "native rear quarter, Muse sheet")],
}
for name, tiles in rows.items():
    strip = Image.new("RGB", (sum(t.width for t in tiles), H + 44), "white")
    x = 0
    for t in tiles:
        strip.paste(t, (x, 0))
        x += t.width
    strip.save("%s/compare-%s.jpg" % (out, name), quality=88)
