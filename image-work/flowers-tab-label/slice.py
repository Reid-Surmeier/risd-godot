"""Slice the Flowers icon and label out of Muse pass 01 and bring them to the game's scale, the way
modules/tab_strip/assets/compact/provenance/rebuild.py cut the other six: a darker-than-fill mask,
specks dropped, icon = first run of columns, label = the rest. Scale = Playground label width in the
pass / label_playground.png width. Every output pixel is resampled from the Muse output."""
import json
import cv2
import numpy as np
from PIL import Image

A = "../../modules/tab_strip/assets/compact/"
im = np.array(Image.open("pass-01/review/full.png").convert("RGB"))
TOP, BOT = 262, 450


def parts(x0, x1):
    region = im[TOP:BOT, x0:x1]
    local = np.median(region.min(2))
    mask = region.min(2) < min(238, local - 12)
    n, lab, stats, _ = cv2.connectedComponentsWithStats(mask.astype(np.uint8), connectivity=8)
    for k in range(1, n):
        if stats[k, cv2.CC_STAT_AREA] < 60:
            mask[lab == k] = False
    cols = np.where(mask.sum(0) >= 3)[0]
    split = int(np.where(np.diff(cols) > 12)[0][0])
    out = []
    for c0, c1, icon in ((cols[0], cols[split], True), (cols[split + 1], cols[-1], False)):
        m = mask[:, c0:c1 + 1].copy()
        if icon:  # keep the icon's light interior, drop only the outside
            m = cv2.morphologyEx(m.astype(np.uint8), cv2.MORPH_CLOSE, np.ones((9, 9), np.uint8))
            inv = np.pad(1 - m, 1, constant_values=1)
            cv2.floodFill(inv, None, (0, 0), 2)
            m = inv[1:-1, 1:-1] != 2
        rows = np.where(m.any(1))[0]
        r0, r1 = rows[0], rows[-1]
        rgba = np.dstack([region[r0:r1 + 1, c0:c1 + 1], (m[r0:r1 + 1] * 255).astype(np.uint8)])
        out.append((Image.fromarray(rgba, "RGBA"), x0 + c0, TOP + r0))
    return out


(_, _, _), (play_label, _, play_top) = parts(1160, 2150)
(icon, ix, iy), (label, lx, ly) = parts(2240, 3200)
ref = Image.open(A + "label_playground.png")
s = play_label.width / ref.width
print("scale", round(s, 4), "playground label", play_label.size, "->", ref.size)
fit = lambda p: p.resize((round(p.width / s), round(p.height / s)), Image.LANCZOS)
icon_g, label_g = fit(icon), fit(label)
icon_g.save("icon_flowers.png")
label_g.save("label_flowers.png")
L = json.load(open(A + "layout.json"))
pl = L["place"]["playground"]
icon_y = round(L["row_mid"] - icon_g.height / 2)
label_y = round(pl["label"][1] + (ly - play_top) / s)
place = {"icon": [58, icon_y], "label": [58 + icon_g.width + L["label_gap"], label_y]}
print("icon", icon_g.size, "label", label_g.size, "place", json.dumps(place))
