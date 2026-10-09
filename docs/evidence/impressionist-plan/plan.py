"""Draws plan-compare.png: the Impressionist rooms as built beside the same rooms as filmed.

Notes diagram only, never a game texture. Run from the repo root:
    python3 docs/evidence/impressionist-plan/plan.py
Room-scene metres, x east, z south; top of the picture is -z, 26 px per metre,
the same scale and orientation as the orchestrator's plan-as-built.png.
"""
import json
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).parent
S, OX, OZ, W, H = 26, 38, 60, 960, 1420
FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans%s.ttf"
f10, f11, f13, f18 = (ImageFont.truetype(FONT % b, n) for b, n in (("", 10), ("", 11), ("-Bold", 13), ("-Bold", 18)))
INK, GREY, RED, GREEN, BLUE = "#222222", "#8a8a84", "#c62828", "#1b7f3b", "#2f6fd0"
FILL = {"ctx": "#e4e1d8", "hall": "#b9c7c5", "imp": "#f4c9a0", "bad": "#f3a6a0", "new": "#bfe3c4"}

geometry = json.loads(subprocess.check_output(
    ["git", "show", "HEAD:modules/shell/collection_rooms/geometry.json"]))
ROOMS = {r["label"]: r for r in geometry["rooms"]}
IMP = ["Impressionist passage", "Impressionist passage return", "Impressionist gallery A", "Impressionist gallery B"]


def P(x, z, ox=0):
    return (ox + OX + (x + 5.55) * S, OZ + (z + 10.76) * S)


def seg(d, a, b, colour, width=2, dash=0):
    (x0, y0), (x1, y1) = a, b
    if not dash:
        return d.line([a, b], fill=colour, width=width)
    n = max(1, int(((x1 - x0) ** 2 + (y1 - y0) ** 2) ** .5 // dash))
    for i in range(0, n, 2):
        d.line([(x0 + (x1 - x0) * i / n, y0 + (y1 - y0) * i / n),
                (x0 + (x1 - x0) * min(i + 1, n) / n, y0 + (y1 - y0) * min(i + 1, n) / n)], fill=colour, width=width)


def box(d, ox, b, fill, label="", outline=INK, dashed=(), font=f11):
    x0, x1, z0, z1 = b
    d.rectangle([P(x0, z0, ox), P(x1, z1, ox)], fill=fill)
    for side, a, c in (("north", (x0, z0), (x1, z0)), ("south", (x0, z1), (x1, z1)),
                       ("west", (x0, z0), (x0, z1)), ("east", (x1, z0), (x1, z1))):
        seg(d, P(*a, ox), P(*c, ox), outline, 2, 7 if side in dashed else 0)
    if label:
        d.text((P(x0, z0, ox)[0] + 4, P(x0, z0, ox)[1] + 3), label, fill=INK, font=font)


def opening(d, ox, b, side, span, colour, width=7):
    x0, x1, z0, z1 = b
    a, c = span
    ends = {"north": ((a, z0), (c, z0)), "south": ((a, z1), (c, z1)),
            "west": ((x0, a), (x0, c)), "east": ((x1, a), (x1, c))}[side]
    seg(d, P(*ends[0], ox), P(*ends[1], ox), colour, width)


def tag(d, ox, x, z, text, colour, font=f13, dx=0, dz=0):
    px, py = P(x, z, ox)
    px, py = px + dx, py + dz
    w = d.textlength(text, font=font)
    d.rectangle([px - 3, py - 2, px + w + 3, py + font.size + 3], fill="white", outline=colour)
    d.text((px, py), text, fill=colour, font=font)


def context(d, ox, skip=()):
    for label, room in ROOMS.items():
        if label in IMP or label in skip or "reveal threshold" in label:
            continue
        box(d, ox, room["bounds"], FILL["hall" if label == "Grand Gallery" else "ctx"], label.replace(" threshold study limit", " (stub)"), GREY, font=f10)
        for side, span in room.get("openings", {}).items():
            if label == "marble stair hall" and side == "east":
                continue
            opening(d, ox, room["bounds"], side, span, GREY, 5)


img = Image.new("RGB", (2 * W, H), "#f6f3ec")
d = ImageDraw.Draw(img)
d.line([(W, 0), (W, H)], fill=GREY, width=1)
d.text((16, 12), "AS BUILT (geometry.json at integration/next)", fill=INK, font=f18)
d.text((W + 16, 12), "AS FILMED (IMG_6343 83-229 s, IMG_6380 49/70 s, IMG_6387 68-70 s)", fill=INK, font=f18)

# ---- left: as built -------------------------------------------------------------------------
context(d, 0)
hall = ROOMS["marble stair hall"]["bounds"]
for label in IMP:
    room = ROOMS[label]
    box(d, 0, room["bounds"], FILL["bad" if "passage" in label else "imp"], label.replace("Impressionist ", ""), font=f13)
    for side, span in room["openings"].items():
        opening(d, 0, room["bounds"], side, span, RED if "passage" in label or (label.endswith("A") and side == "north") else INK)
seg(d, P(17.85, -2.51), P(17.85, -1.41), RED, 7)
seg(d, P(19.45, -2.51), P(19.45, -1.41), RED, 7)
seg(d, P(11.55, 1.04), P(13.31, 1.04), INK, 3)
tag(d, 0, 19.6, -4.6, "1  EXIT door under the stair opened;", RED, f11)
tag(d, 0, 19.6, -3.95, "passage built beyond the half-landing window wall", RED, f11)
tag(d, 0, 17.0, 3.25, "2  return passage: not in any frame", RED, f11)
tag(d, 0, 17.0, 4.6, "3  A entered at its east (window) end", RED, f11)
tag(d, 0, 11.3, -.15, "4  the real door: built shut", RED, f11)
tag(d, 0, 17.0, 16.5, "5  B: pictures on the wrong walls", RED, f11)
for z in (6.04, 10.64, 17.68, 21.14):
    seg(d, P(16.70, z - .8), P(16.70, z + .8), BLUE, 6)

# ---- right: as filmed -----------------------------------------------------------------------
context(d, W)
box(d, W, [17.85, 19.45, -2.51, -1.41], "#ecead9", "", GREY, dashed=("north", "south", "east"))
seg(d, P(17.85, -2.51, W), P(17.85, -1.41, W), GREY, 5)
tag(d, W, 19.7, -2.5, "X  EXIT door: a lit vestibule and a second", GREY, f11)
tag(d, W, 19.7, -1.85, "door seen through it; never entered. UNKNOWN", GREY, f11)
seg(d, P(19.45, -3.3, W), P(19.45, -.6, W), BLUE, 6)
tag(d, W, 19.7, -4.2, "half-landing window above (daylight, 86 s)", BLUE, f11)
box(d, W, [13.85, 19.45, -.56, 1.04], "#d9d6cc", "service stair (arch)", GREY, font=f10)

A, B, PASS = [10.55, 16.70, 3.04, 12.70], [10.55, 16.70, 12.70, 22.30], [11.45, 13.45, 1.04, 3.04]
box(d, W, PASS, FILL["new"], "")
box(d, W, A, FILL["imp"], "gallery A", dashed=("south",), font=f13)
box(d, W, B, FILL["imp"], "", dashed=("north",), font=f13)
d.text((P(12.4, 16.9, W)), "gallery B", fill=INK, font=f13)
opening(d, W, PASS, "north", [11.55, 13.31], GREEN)
opening(d, W, A, "north", [11.75, 13.15], GREEN)
opening(d, W, A, "south", [15.20, 16.30], GREEN)
opening(d, W, B, "south", [15.10, 16.40], GREEN)
seg(d, P(11.0, 28.1, W), P(12.7, 28.1, W), GREEN, 7)
seg(d, P(13.45, 1.6, W), P(13.45, 2.5, W), INK, 5)
for z in (6.04, 10.64, 17.68, 21.14, 24.2, 26.6):
    seg(d, P(16.70, z - .8, W), P(16.70, z + .8, W), BLUE, 6)
tag(d, W, 13.7, 1.12, "D1 stair hall south door  88.25 s; IMG_6380 49, 70 s", GREEN, f11)
tag(d, W, 13.7, 1.78, "service leaf, passage east wall  89.25 s", INK, f10)
tag(d, W, 13.7, 2.38, "D2 A north wall, west end  91.25 s; back 140.5 s", GREEN, f11)
tag(d, W, 17.0, 12.35, "D3  152.25 s; back 215.0 s", GREEN, f11)
tag(d, W, 17.0, 21.95, "D4  224.5 s; back IMG_6387 69.5 s", GREEN, f11)
tag(d, W, 12.9, 28.3, "D5 EXIT pair  227.5, 260 s", GREEN, f11)
tag(d, W, 17.0, 5.7, "windows: A 143 s, B 216.5 s, modern 226 s", BLUE, f11)
for x, z, text in (
        (10.7, 5.2, "Monet 42.219"), (10.7, 8.2, "Monet 57.236"), (10.7, 10.9, "Monet 1998.107"),
        (11.6, 12.05, "Manet Le Repos"), (14.3, 4.3, "Cézanne 41.012"), (14.6, 8.1, "Degas 23.072"),
        (13.3, 3.12, "Carolus-Duran  Manet Tuileries"),
        (10.7, 13.0, "Gauguin  Pissarro"), (10.7, 15.2, "Cézanne 33.053"), (10.7, 19.5, "Monet 44.541"),
        (10.7, 21.6, "Iris Morisot van Gogh"), (14.6, 19.3, "Cassatt 60.095")):
    d.text(P(x, z, W), text, fill="#5a4630", font=f10)
d.text(P(12.5, 9.6, W), "case", fill="#5a4630", font=f10)

# ---- legend ---------------------------------------------------------------------------------
y = H - 128
for i, (colour, text) in enumerate((
        (GREEN, "doorway seen in a frame at the time given (VERIFIED side and end of wall)"),
        (RED, "built doorway or room that no frame shows"),
        (BLUE, "window (an outside wall)"),
        (INK, "solid wall line: the wall, its side and what hangs on it are seen;  dashed: its position along the room is a fit, +-1.5 m"),
        (GREY, "neighbouring rooms as built, not re-surveyed here"))):
    d.line([(W + 16, y + 8 + i * 22), (W + 56, y + 8 + i * 22)], fill=colour, width=5)
    d.text((W + 64, y + i * 22), text, fill=INK, font=f11)
d.text((16, H - 40), "26 px per metre; top is -z (plan north), x grows to the right. Metres are room-scene metres.", fill=INK, font=f11)
img.save(HERE / "plan-compare.png", optimize=True)
print(HERE / "plan-compare.png", img.size)
