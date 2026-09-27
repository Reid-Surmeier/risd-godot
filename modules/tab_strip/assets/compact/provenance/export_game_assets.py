"""Slice the rebuilt taskbar into tab_strip's compact-mode pieces (Issue #113), then compose the bar
from those pieces exactly as the strip does, once per selected-tab variation. Every pixel is copied
from Muse pass 16 through rebuild.py; nothing is drawn."""
import json
import os
import runpy

import cv2
import numpy as np
from PIL import Image

R = runpy.run_path("rebuild.py")
im, edges, fill, filler = R["im"], R["edges"], R["fill"], R["filler"]
TOP, CLEAN_BOT, PAD, GAP = R["TOP"], R["CLEAN_BOT"], R["PAD"], R["GAP"]
OUT = "game-assets"
os.makedirs(OUT, exist_ok=True)
KEYS = ["map", "sketchbook", "3d_viewer", "video_player", "collection", "playground"]
BAR_H = im.shape[0]
TAB_Y, TAB_H = 34, 146  # top outline (rows ~36-42) down to under the dotted baseline


def rgba(rgb, alpha):
    return Image.fromarray(np.dstack([rgb, alpha.astype(np.uint8)]), "RGBA")


def save(img, name):
    img.save(f"{OUT}/{name}.png")
    return img


# --- tab slices: one inner edge (Video Player's left edge), cut on its line --------------------
e = edges[3]
s0, s1 = int(e(R["BOT"])) - 10, int(e(TOP)) + 10
edge_w = s1 - s0
ys = np.arange(TAB_Y, TAB_Y + TAB_H)[:, None]
xs = np.arange(edge_w)[None, :]
line = e(ys) - s0  # the edge's x in slice coords, per row
right_face = R["clean_strip"](s0, s1, e, None, fill)[TAB_Y:TAB_Y + TAB_H]
left_face = R["clean_strip"](s0, s1, e, fill, None)[TAB_Y:TAB_Y + TAB_H]
save(rgba(right_face, (xs >= line - 6) * 255), "tab_left")   # a tab's left edge: its face is right of the line
save(rgba(left_face, (xs <= line + 6) * 255), "tab_right")   # a tab's right edge: its face is left of the line
save(rgba(filler[TAB_Y:TAB_Y + TAB_H], np.full((TAB_H, filler.shape[1]), 255)), "tab_mid")  # tiled, not stretched

# --- the grey new-tab stub, behind the last tab's right edge -----------------------------------
n0, n1 = R["n0"], R["NEWTAB_END"]
blk = im[TAB_Y:TAB_Y + TAB_H, n0:n1]
e6 = edges[6]
grey = (blk.min(2) > 212) & (blk.min(2) < 236) & (blk.max(2) - blk.min(2) < 6)
grey &= np.arange(n1 - n0)[None, :] > (e6(ys) - n0 + 8)  # the dashed edge leaks into Playground's grey face
n, lab, st, _ = cv2.connectedComponentsWithStats(grey.astype(np.uint8), connectivity=4)
face = lab == (1 + int(np.argmax(st[1:, cv2.CC_STAT_AREA])))
m = cv2.dilate(face.astype(np.uint8), np.ones((13, 13), np.uint8)).astype(bool)
m &= np.arange(n1 - n0)[None, :] >= (e6(ys) - n0 - 6)
m[:int(np.where(face.any(1))[0][0]) - 10] = False  # nothing above the stub's own top outline
stub_top = int(np.where(m.any(1))[0][0])  # the stub's own top line: a new tab grows from this box
stub = save(rgba(blk[stub_top:], m[stub_top:] * 255), "stub_idle")
save(stub, "stub_pressed")  # the press is the strip's grey modulate, as before

# --- left end, stripes, tray from the rebuilt bar ------------------------------------------------
out = np.array(Image.open("taskbar-rebuilt.png").convert("RGB"))
stars_w = R["pieces"][0].shape[1]


def ink_of(rgb):
    f = rgb.astype(int)
    m = (f.min(2) < 200) | (f.max(2) - f.min(2) > 40)
    return cv2.dilate(m.astype(np.uint8), np.ones((3, 3), np.uint8)).astype(bool)


# one stripe background for the whole bar: each column's median over the clean rows above the six
# tabs, repeated down (Muse's stripes are vertical), white above row 10 and below row 156 as in the tray
cols = np.median(im[14:31, 420:2820], 0).astype(np.uint8)
stripes = np.full((BAR_H, cols.shape[0], 3), 255, np.uint8)
stripes[10:156] = cols[None]
# the star + Start and the tray are cut-outs over that background
sp = out[:, :stars_w]
sa = ink_of(sp)
save(rgba(sp, sa * 255), "stars")
tray = R["tray"]
ta = np.zeros(tray.shape[:2], bool)
ink, sh = R["ink"], R["shift"]
iy, ix = np.where(ink)
keep = ix < ink.shape[1] - 14
ta[iy[keep] + sh, ix[keep]] = True
save(rgba(np.ascontiguousarray(out[:, -tray.shape[1]:]), ta * 255), "right_cluster")
save(Image.fromarray(np.ascontiguousarray(stripes)), "bar_stripes")

# --- per-tab icons and labels (halo-free cut-outs), placed relative to the left edge -----------
place = {}
for i, key in enumerate(KEYS):
    (ic, _), (lb, _) = R["contents"][i]
    save(ic, "icon_" + key)
    save(lb, "label_" + key)
    iy = R["icon_mid"] - ic.height // 2
    ix = int(round(e(iy) - s0)) + PAD
    place[key] = {"icon": [ix, iy - TAB_Y], "label": [ix + ic.width + GAP, R["label_top"] - TAB_Y]}

k = float(np.polyfit([0.0, 1.0], [e(0) - s0, e(1) - s0], 1)[0])
layout = {
    "bar_height": BAR_H, "bar_width": int(out.shape[1]),
    "tab": {"y": TAB_Y, "height": TAB_H, "left_w": edge_w, "right_w": edge_w,
            "full_width": R["tab_w"], "first_tab_x": stars_w},
    "tab_pitch": R["tab_w"] - edge_w,
    "stub": {"y": TAB_Y + stub_top, "w": n1 - n0, "h": TAB_H - stub_top, "gap_from_tab_right": -edge_w},
    "bar_background": [0, 0, int(out.shape[1]), BAR_H], "tab_min_width": 270, "fixed_tab_width": R["tab_w"],
    "right_cluster_icons_offset": int(np.where(ta.any(0))[0][0]),
    "stars": [0, 0, stars_w, BAR_H], "right_cluster_w": int(tray.shape[1]),
    "edge_line": [k, float(e(TAB_Y) - s0)],  # the left edge's x = k*y + c, y in tab-local rows
    "icon_pad": PAD, "label_gap": GAP, "place": place,
    "row_mid": R["icon_mid"] - TAB_Y, "label_baseline": R["label_top"] - TAB_Y + 36,  # cap height of the labels
}
json.dump(layout, open(f"{OUT}/layout.json", "w"), indent=1)


# --- compose the bar the way tab_strip does, for each selected-tab variation --------------------
def tex(name):
    return Image.open(f"{OUT}/{name}.png").convert("RGBA")


def mult(img, f):
    a = np.array(img).astype(float)
    a[..., :3] *= f
    return Image.fromarray(a.clip(0, 255).astype(np.uint8), "RGBA")


def tab_image(key, width, face=1.0):
    t = Image.new("RGBA", (width, TAB_H), (0, 0, 0, 0))
    mid = tex("tab_mid")
    for x in range(edge_w, width - edge_w, mid.width):
        t.alpha_composite(mid.crop((0, 0, min(mid.width, width - edge_w - x), TAB_H)), (x, 0))
    t.alpha_composite(tex("tab_left"), (0, 0))
    t.alpha_composite(tex("tab_right"), (width - edge_w, 0))
    t = mult(t, face)
    p = place[key]
    t.alpha_composite(tex("icon_" + key), tuple(p["icon"]))
    t.alpha_composite(tex("label_" + key), tuple(p["label"]))
    return t


def compose(active, face, lift=0):
    W = layout["bar_width"]
    bar = Image.new("RGBA", (W, BAR_H))
    st = tex("bar_stripes")
    for x in range(0, W, st.width):
        bar.alpha_composite(st, (x, 0))
    bar.alpha_composite(tex("stars"), (0, 0))
    rc = tex("right_cluster")
    bar.alpha_composite(rc, (W - rc.width, 0))
    xs_ = [stars_w + i * layout["tab_pitch"] for i in range(6)]
    last_right = xs_[-1] + R["tab_w"]
    bar.alpha_composite(tex("stub_idle"), (last_right - edge_w, layout["stub"]["y"]))  # behind every tab
    for i in reversed(range(6)):  # left tabs in front of their right neighbours
        dy = -lift if i == active else 0
        bar.alpha_composite(tab_image(KEYS[i], R["tab_w"], face if i == active else 1.0), (xs_[i], TAB_Y + dy))
    return bar.convert("RGB")


os.makedirs("variants", exist_ok=True)
stub_grey = float(np.median(blk[face].min(1))) / float(fill[0])
variants = {
    "A-stub-grey": dict(face=stub_grey),
    "B-light-grey": dict(face=1 - (1 - stub_grey) / 2),
    "C-stub-grey-raised": dict(face=stub_grey, lift=6),
    "D-deeper-grey": dict(face=stub_grey - 0.05),
}
compose(-1, 1.0).save("variants/none-selected.png")
for name, v in variants.items():
    compose(4, **v).save(f"variants/{name}.png")
print("stub grey factor", round(stub_grey, 3), "edge_w", edge_w, "tab_w", R["tab_w"], "stub", n1 - n0)
print(json.dumps(place))
