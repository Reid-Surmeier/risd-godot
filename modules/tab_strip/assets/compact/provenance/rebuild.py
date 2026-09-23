"""Deterministic re-layout of Muse pass 16: 1.5x wider tabs, even icon/label
placement, halo-free icons. Every output pixel is copied from pass 16; nothing is drawn."""
import cv2
import numpy as np
from PIL import Image

SRC = "../pass-16/review/band.png"
SCALE = 1.5
FILL_T = 238          # min channel >= FILL_T counts as tab fill / halo, not content
TOP, BOT = 46, 162    # rows between top outline and dotted baseline
CLEAN_BOT = 167       # Playground's gray fill runs down to the dotted baseline
# approximate (top-x at y=44, bottom-x at y=166) for 6 tab left edges + Playground right edge
EDGES0 = [(368, 314), (770, 719), (1184, 1135), (1573, 1521), (1999, 1949), (2439, 2389), (2838, 2789)]
NEWTAB_END = 3030     # right end of the shaded new-tab button block
TRAY_START = 3060     # Home icon (x~3093) onward

im = np.array(Image.open(SRC).convert("RGB"))
H, W, _ = im.shape
g = im.min(2)


def fit_edge(t, b):
    ys, xs = [], []
    for y in range(50, 161):
        x0 = t + (b - t) * (y - 44) / 122
        lo, hi = int(x0 - 14), int(x0 + 14)
        d = np.where(g[y, lo:hi] < 200)[0]
        if len(d):
            ys.append(y); xs.append(lo + d.mean())
    k, c = np.polyfit(ys, xs, 1)
    return lambda y: k * y + c


edges = [fit_edge(t, b) for t, b in EDGES0]
fill = np.median(im[100:140, 600:700].reshape(-1, 3), 0).astype(np.uint8)  # empty Map-tab body


def clean_strip(x0, x1, line, left_fill, right_fill):
    """Copy columns [x0,x1) keeping only pixels near the edge line inside the tab rows."""
    s = im[:, x0:x1].copy()
    for y in range(TOP, CLEAN_BOT + 1):
        xe = line(y) - x0
        for x in range(s.shape[1]):
            if x < xe - 7 and left_fill is not None: s[y, x] = left_fill
            elif x > xe + 7 and right_fill is not None: s[y, x] = right_fill
    return s


def content(i):
    """Icon and label crops (RGBA, halo removed) from tab i."""
    lo = int(edges[i](TOP)) + 8
    hi = int(edges[i + 1](TOP)) + 2
    region = im[TOP:BOT, lo:hi]
    local = np.median(region.min(2))  # Playground's fill is gray, the others near-white
    mask = region.min(2) < min(FILL_T, local - 12)
    for y in range(region.shape[0]):  # drop anything at or past the next tab's edge
        cut = int(edges[i + 1](TOP + y)) - 7 - lo
        mask[y, max(cut, 0):] = False
        cut = int(edges[i](TOP + y)) + 8 - lo
        mask[y, :max(cut, 0)] = False
    n, lab, stats, _ = cv2.connectedComponentsWithStats(mask.astype(np.uint8), connectivity=8)
    for k in range(1, n):  # drop isolated specks; keep letter parts like the dot of an i
        if stats[k, cv2.CC_STAT_AREA] < 30:
            mask[lab == k] = False
    cols = np.where(mask.sum(0) >= 3)[0]
    gaps = np.diff(cols)
    split = int(np.where(gaps > 1)[0][0])  # the icon is the first contiguous run of columns
    parts = []
    for c0, c1 in ((cols[0], cols[split]), (cols[split + 1], cols[-1])):
        m = mask[:, c0:c1 + 1].copy()
        if c0 == cols[0]:  # icon: keep its light interior, drop only the outside patch
            m = cv2.morphologyEx(m.astype(np.uint8), cv2.MORPH_CLOSE, np.ones((5, 5), np.uint8))
            inv = np.pad(1 - m, 1, constant_values=1)
            cv2.floodFill(inv, None, (0, 0), 2)
            m = (inv[1:-1, 1:-1] != 2)
        rows = np.where(m.any(1))[0]
        r0, r1 = rows[0], rows[-1]
        rgba = np.dstack([region[r0:r1 + 1, c0:c1 + 1], (m[r0:r1 + 1] * 255).astype(np.uint8)])
        parts.append((Image.fromarray(rgba, "RGBA"), TOP + r0))
    return parts


# filler: an empty vertical slice of the Map tab body (top line, fill, dotted baseline)
FILL_X0, FILL_W = 600, 100  # 585-715 is empty in the source
filler = im[:, FILL_X0:FILL_X0 + FILL_W].copy()
filler[TOP:BOT + 1] = np.where(filler[TOP:BOT + 1].min(2, keepdims=True) < FILL_T, filler[TOP:BOT + 1], fill)


def body(width):
    reps = -(-width // FILL_W)
    return np.concatenate([filler] * reps, 1)[:, :width]


tops = [e(44) for e in edges]
tab_w = int(round(np.mean(np.diff(tops)) * SCALE))
contents = [content(i) for i in range(6)]
icon_box = max(ic.width for (ic, _), _ in contents)
icon_mid = int(np.median([y + ic.height / 2 for (ic, y), _ in contents]))
label_top = int(np.median([ly for _, (lab, ly) in contents]))  # every label starts with a capital
PAD, GAP = 14, 26  # icon's top-left corner to the edge; icon to label

pieces = [im[:, :int(edges[0](BOT)) - 10]]
x = pieces[0].shape[1]
placements = []
for i in range(6):
    s0, s1 = int(edges[i](BOT)) - 10, int(edges[i](TOP)) + 10
    left = fill if i else None  # left of the first edge is striped background
    pieces.append(clean_strip(s0, s1, edges[i], left, fill))
    bw = tab_w - (s1 - s0)
    pieces.append(body(bw))
    (ic, _), (lab, ly) = contents[i]
    iy = icon_mid - ic.height // 2
    ix = int(round(edges[i](iy) - s0 + x)) + PAD  # output x of this edge at the icon's top row
    placements.append((ic, ix, iy))
    placements.append((lab, ix + ic.width + GAP, label_top))
    x += tab_w

# new-tab block (Playground's right edge + shaded new tab), Playground side forced to white fill
n0 = int(edges[6](BOT)) - 10
nt = clean_strip(n0, NEWTAB_END, edges[6], fill, None)
orig = im[:, n0:NEWTAB_END]
for y in range(TOP, CLEAN_BOT + 1):  # right of the edge keep original (shaded new tab)
    xe = int(edges[6](y)) - n0
    nt[y, xe + 8:] = orig[y, xe + 8:]
pieces.append(nt)
pieces.append(im[:, NEWTAB_END:TRAY_START])
src = im[:, TRAY_START:W - 12]  # drop Muse's black bar on the far right edge
dark = np.where((src.min(2) < 150).sum(1) > 5)[0]  # icon rows; skips the thin separator
shift = icon_mid - (dark[0] + dark[-1]) // 2
# background: the stripe-only rows under the icons, tiled over the whole striped height
tray = src.copy()
stripe = src[118:148]
for y0 in range(10, 156, 30):
    tray[y0:min(y0 + 30, 156)] = stripe[:min(30, 156 - y0)]
g0 = 4420 - TRAY_START  # Muse's corner grip sits in the stripe rows here; borrow stripes from the left
tray[:, g0:] = tray[:, g0 - 60:tray.shape[1] - 60]
# move only icon/clock pixels (dark or coloured), leaving the pale box behind
f = src.astype(int)
ink = (f.min(2) < 200) | (f.max(2) - f.min(2) > 40)
ink = cv2.dilate(ink.astype(np.uint8), np.ones((3, 3), np.uint8)).astype(bool)
ink[:dark[0] - 6] = False; ink[dark[-1] + 6:] = False
ink[100:, g0:] = False  # the grip under the clock stays out
ys, xs = np.where(ink)
tray[ys + shift, xs] = src[ys, xs]
tray = np.concatenate([tray[:, :-14], tray[:, -120:-100]], 1)  # breathing room before the clock's M meets the edge
pieces.append(tray)
print("tray shift", shift)

out = Image.fromarray(np.concatenate(pieces, 1))
for part, px, py in placements:
    out.paste(part, (px, py), part)
out.save("taskbar-rebuilt.png")
print("size", out.size, "tab width", tab_w, "icon box", icon_box)
for i, ((ic, _), (lab, _)) in enumerate(contents):
    print(i, "icon", ic.size, "label", lab.size)
