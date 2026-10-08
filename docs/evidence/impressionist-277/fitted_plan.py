"""Review-only metre plan from the prepared geometry.json; no runtime dependency.

python3 fitted_plan.py <draft-extension>/geometry.json
"""
import json
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

data = json.loads(Path(sys.argv[1]).read_text())
paper = "#f3f1eb"
ink = "#303830"
canvas = Image.new("RGB", (1180, 1640), paper)
draw = ImageDraw.Draw(canvas)
font_path = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
title = ImageFont.truetype(font_path, 28)
body = ImageFont.truetype(font_path, 20)
small = ImageFont.truetype(font_path, 17)


def point(x, z):
    return (70 + (x - 10) * 39, 200 + (z + 5) * 39)


draw.text((35, 25), "#277 — fixed-door fit; physical museum plan INFERRED", font=title, fill=ink)
draw.text((35, 72), "Room-scene metres. Existing stair and modern endpoints stay fixed.", font=body, fill=ink)
draw.text((35, 108), "Looking south (+z): east windows and end doors appear on screen LEFT.", font=body, fill=ink)
selected = {
    "marble stair hall": ("Existing marble hall", "#d8d5ce"),
    "Impressionist passage": ("Passage", "#e1dbcd"),
    "Impressionist passage return": ("Fitted return", "#e1dbcd"),
    "Impressionist gallery A": ("A\n6.15 × 9.66 m\nh 3.69 m", "#cbd1d0"),
    "Impressionist gallery B": ("B\n6.15 × 9.60 m\nh 3.50 m", "#c7ced1"),
    "modern painting gallery": ("Existing modern", "#d8d2c6"),
}
for room in data["rooms"]:
    if room["label"] not in selected:
        continue
    label, fill = selected[room["label"]]
    x0, x1, z0, z1 = room["bounds"]
    draw.rectangle([point(x0, z0), point(x1, z1)], fill=fill, outline="#61675f", width=2)
    centre = point((x0 + x1) / 2, (z0 + z1) / 2)
    if room["label"] in ["Impressionist gallery A", "Impressionist gallery B"]:
        centre = point(12.65, (z0 + z1) / 2)
    box = draw.multiline_textbbox((0, 0), label, font=body, spacing=6, align="center")
    draw.multiline_text((centre[0] - box[2] / 2, centre[1] - (box[3] - box[1]) / 2), label, font=body, fill=ink, spacing=6, align="center")
    for side, edges in room.get("openings", {}).items():
        a, b = [point(x, z0 if side == "north" else z1) for x in edges] if side in ["north", "south"] else [point(x0 if side == "west" else x1, z) for z in edges]
        draw.line([a, b], fill=paper, width=6)

for z in [6.04, 10.64, 17.68, 21.14]:
    draw.line([point(16.70, z - .80), point(16.70, z + .80)], fill="#5d929a", width=7)
draw.line([point(*p) for p in data["impressionist_route_waypoints"]], fill="#b56c49", width=3)
draw.line([point(16.85, -1.96), point(20.45, -1.96)], fill="#b56c49", width=3)
for x, z in [(17.85, -1.96), (15.75, 22.30)]:
    px, py = point(x, z)
    draw.ellipse((px - 6, py - 6, px + 6, py + 6), fill="#8e4533")
for x in range(10, 23, 2):
    draw.text((point(x, -5)[0] - 10, 166), str(x), font=small, fill=ink)
for z in range(0, 29, 4):
    draw.text((28, point(10, z)[1] - 9), str(z), font=small, fill=ink)

notes = """FIXED ENDPOINTS
Stair inner: x17.85 / z−1.96
Modern far: x15.75 / z22.30

Measured depths (INFERRED)
Passage 2.0 ± .4 m
A 9.6 ± 1.5 m
B 8.8 ± 1.8 m

Longitudinal gap: 3.86 m
Fit adds: passage +3.00 m,
A +.06 m and B +.80 m.

Extra lateral return: 8.90 m
This is not observed in the clip.
No adjoining room moves.

OPENINGS
Stair clear width: 1.10 m
A entry: 1.30 m
A–B: 1.10 m at z12.70
Modern: 1.30 m retained

Blue: four windows
Orange: reciprocal sampled route
White gaps: cased openings

Offsets, depths and exact
physical layout are unaccepted.
See NOTES for source frames,
measurement errors and all
door/trial coordinates."""
draw.multiline_text((590, 215), notes, font=body, fill=ink, spacing=10)
draw.text((35, 1550), "Prepared source plan, not a calibrated museum survey. No footage pixels enter the game.", font=small, fill=ink)
target = Path(__file__).with_name("fitted-plan.jpg")
canvas.save(target, quality=72, optimize=True)
assert target.stat().st_size < 150000
print(target.name, target.stat().st_size)
