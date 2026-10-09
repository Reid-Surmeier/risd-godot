"""Draws walk-on-map.png: the owner's filmed walk laid on the museum's Floor 5 map, in the map's
own orientation. Wall positions are pixel positions scanned from the museum's Floor5-map-121420.png;
the lines are redrawn, the museum's image is not copied. Notes diagram only.
    python3 docs/evidence/impressionist-plan/walk_on_map.py
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

K, OX, OY = 2.2, -640, -150
FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans%s.ttf"
f11, f13, f16 = (ImageFont.truetype(FONT % b, n) for b, n in (("", 12), ("-Bold", 13), ("-Bold", 17)))
INK, GREY, RED, GREEN, BLUE = "#222222", "#8a8a84", "#c62828", "#1b7f3b", "#2f6fd0"


def p(x, y):
    return (OX + x * K, OY + y * K)


img = Image.new("RGB", (1500, 1290), "#f6f3ec")
d = ImageDraw.Draw(img)
d.text((16, 12), "The filmed walk on the museum's Floor 5 map (map's own orientation, lines redrawn)", fill=INK, font=f16)
for (x0, x1, y0, y1), fill, label in (
        ((403, 865, 486, 570), "#e4e1d8", "European: long gallery (IMG_6384-6386)"),
        ((503, 781, 350, 486), "#b9c7c5", "European: Grand Gallery"),
        ((781, 865, 350, 486), "#e4e1d8", "medieval"),
        ((357, 420, 355, 395), "#d3d0c6", "stair to 4"),
        ((403, 503, 350, 440), "#e4e1d8", "           grey gallery"),
        ((405, 457, 440, 486), "#d3d0c6", "lift"),
        ((420, 503, 265, 350), "#e4e1d8", "       marble stair hall"),
        ((442, 482, 172, 265), "#ecead9", "on to Pendleton"),
        ((785, 865, 265, 350), "#e4e1d8", "lion stair landing"),
        ((865, 903, 265, 350), "#d3d0c6", "stair"),
        ((785, 865, 115, 265), "#ecead9", "Ancient Greek and Roman"),
        ((503, 596, 265, 350), "#f4c9a0", "A: Manet Le Repos, Monets, Degas"),
        ((596, 699, 265, 350), "#f4c9a0", "B: Gauguin, Monet, van Gogh, Cassatt"),
        ((699, 785, 265, 350), "#f4c9a0", "modern: Gleizes, Braque")):
    d.rectangle([p(x0, y0), p(x1, y1)], fill=fill, outline=GREY, width=2)
    words, line, lines = label.split(), "", []
    for w in words:
        if d.textlength(line + " " + w, font=f11) > (x1 - x0) * K - 10 and line:
            lines.append(line); line = w
        else:
            line = (line + " " + w).strip()
    lines.append(line)
    for i, t in enumerate(lines):
        d.text((p(x0, y0)[0] + 5, p(x0, y0)[1] + 4 + i * 14), t, fill=INK, font=f11)
for x0, x1, y0, y1 in ((420, 442, 265, 311), (482, 503, 265, 305)):
    d.rectangle([p(x0, y0), p(x1, y1)], fill="#c9c6ba", outline=GREY)
d.text(p(560, 180), "Radeke Garden", fill=BLUE, font=f16)
for x in (520, 560, 615, 655, 715, 755):
    d.line([p(x, 265), p(x + 22, 265)], fill=BLUE, width=6)
d.text(p(505, 246), "windows: planting and a brick wing outside (127.75, 217.5 s)", fill=BLUE, font=f11)
for a, b in (((503, 323), (503, 348)), ((503, 406), (503, 440)), ((596, 267), (596, 305)), ((699, 267), (699, 305)),
             ((785, 322), (785, 348)), ((781, 400), (781, 440)), ((812, 350), (862, 350)), ((800, 265), (850, 265))):
    d.line([p(*a), p(*b)], fill=GREEN, width=7)
route = [(600, 423, "IMG_6343 0 s: looks through the Grand Gallery's end door"), (462, 400, "3-80 s"), (462, 332, "84 s: stair hall"),
         (497, 336, "88 s: door, Le Repos ahead"), (550, 322, "91-153 s"), (588, 286, ""), (650, 300, "177-223 s"), (692, 286, ""),
         (745, 310, "226-260 s"), (780, 336, ""), (822, 320, "263 s: clip ends on the landing")]
pts = [p(x, y) for x, y, _ in route[1:]]
d.line(pts, fill=RED, width=4, joint="curve")
for (x, y, t), n in zip(route[1:], range(1, 20)):
    px, py = p(x, y)
    d.ellipse([px - 6, py - 6, px + 6, py + 6], fill=RED)
second = [p(822, 330), p(830, 400), p(770, 420), p(700, 420)]
d.line(second, fill="#8e24aa", width=4)
d.text(p(600, 432), "IMG_6344, 108 s later: landing, medieval room, stone portal, Grand Gallery (0-23 s)", fill="#8e24aa", font=f11)
d.text(p(420, 585), "Red: IMG_6343, one unbroken clip. 0 s grey gallery (the Grand Gallery seen through its end door), 84 s marble stair hall, 88 s the", fill=RED, font=f11)
d.text(p(420, 593.5), "door beside the stair, 91-153 s room A, 177-223 s room B, 226-260 s the modern room, 263 s out through fire doors onto the lion stair landing.", fill=RED, font=f11)
d.text(p(420, 606), "No step is crossed anywhere on the walk. The wall directory at the lion stair (IMG_6387 28.1 s) reads: 5, ON THIS FLOOR,", fill=INK, font=f11)
d.text(p(420, 614.5), "European: Medieval, Renaissa..., Impression..., Grand Gal...; Ancient Gree...; Decorative Ar...; American, Pendleton H...", fill=INK, font=f11)
d.text(p(420, 627), "Green: doorways. Each one drawn on the map is where a frame shows it.", fill=GREEN, font=f11)
img.save(Path(__file__).parent / "walk-on-map.png", optimize=True)
print(img.size)
