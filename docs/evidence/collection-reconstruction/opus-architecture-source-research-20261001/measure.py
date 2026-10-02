"""Median colour of hand-placed patches, each compared with a white trim patch in the same image.

    python3 measure.py SCRATCH   # SCRATCH holds the fetched previews and the render run (see SOURCES.md)

Writes colours.json and patches.jpg (every patch drawn on its image). The ratio to the white trim
cancels most of the exposure and white balance of each camera; it is a comparison, not colorimetry.
"""
import json, sys
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw

here = Path(__file__).resolve().parent
scratch = Path(sys.argv[1])
fit = here.parent / "opus-grey-register-fit-20261001/frames"
root = Path("/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction/docs/evidence/collection-reconstruction/public-source-snapshots-20261001")
render, retained = scratch / "final2/new-plain-render/evidence", scratch / "final2/new-out-render/evidence"
# image: (path, what it is, {patch: (x0, y0, x1, y1)}); "white" is the trim reference.
IMAGES = {
    "owner 6380 38.3s grey gallery": (fit / "A1-6380-038.300.png", "owner video, 2026", {
        "white": (760, 1512, 840, 1536), "wall": (640, 1040, 820, 1140), "floor": (350, 1640, 850, 1800),
        "black": (340, 1200, 460, 1380), "casing_in_shade": (285, 1170, 298, 1290)}),
    "owner 6380 101.6s corner": (fit / "D1-6380-101.601.png", "owner video, 2026", {
        "white": (488, 700, 520, 1100), "wall": (410, 700, 460, 1100), "floor": (650, 1350, 1000, 1700), "black": (640, 600, 700, 900)}),
    "owner 6380 240.3s connector": (fit / "F1-6380-240.268.png", "owner video, 2026", {
        "white": (770, 700, 810, 1200), "wall": (900, 700, 1040, 1000), "floor": (150, 1350, 600, 1700), "black": (560, 650, 690, 900),
        "purple": (15, 700, 60, 1000)}),
    "owner 6380 120.0s connector": (scratch / "col/c-120.0.png", "owner video, 2026", {
        "white": (680, 750, 1000, 1250), "purple": (270, 400, 520, 950), "floor": (100, 1250, 500, 1550)}),
    "owner 6380 103.0s connector": (scratch / "col/c-103.0.png", "owner video, 2026", {
        "white": (880, 700, 930, 1300), "wall": (960, 650, 1060, 1400), "black": (20, 500, 120, 900), "floor": (300, 1100, 700, 1500)}),
    "official Grand Gallery photo": (root / "grand-gallery-event.jpg", "risdmuseum.org rent-museum, file dated 2017-10-05", {
        "white": (773, 285, 781, 370), "wall": (700, 220, 760, 290), "floor": (950, 480, 1020, 600), "cornice": (250, 62, 600, 80)}),
    "official European Galleries installation view": (here / "snapshots/european-galleries-installation-view.jpg", "risdmuseum.org european-galleries, on view from 2017-09-02", {
        "white": (1080, 700, 1140, 712), "wall": (400, 100, 800, 220), "floor": (1000, 820, 1300, 950), "platform": (400, 860, 900, 900)}),
    "render grey gallery (patched, unbaked)": (render / "grey-west-wall-source.png", "this prototype", {
        "white": (436, 200, 452, 500), "wall": (560, 250, 660, 500), "floor": (300, 700, 900, 750), "black": (230, 280, 300, 520), "leaf": (40, 300, 150, 330)}),
    "render connector (patched, unbaked)": (render / "rockefeller-connector-source.png", "this prototype", {
        "white": (86, 200, 110, 600), "purple": (540, 30, 620, 60), "black": (760, 200, 850, 600), "floor": (400, 700, 700, 750)}),
    "render Main Hall far door (retained bake)": (retained / "hall-wide-far.png", "actual Main Hall, saved bake", {
        "white": (396, 300, 410, 550), "wall": (200, 60, 350, 180), "floor": (300, 650, 800, 740), "baseboard": (100, 580, 350, 596)}),
    "Nintendo 420s art gallery": (scratch / "research/ytf-084.jpg", "Play Nintendo video ut0TNSximc4", {
        "wall": (20, 30, 55, 100), "floor": (125, 150, 225, 176)}),
    "Nintendo 395s art gallery": (scratch / "research/ytf-079.jpg", "Play Nintendo video ut0TNSximc4", {
        "wall": (20, 20, 110, 100), "frame": (132, 46, 138, 104)}),
}


def linear(c):
    c = np.asarray(c, float) / 255
    return np.where(c <= .04045, c / 12.92, ((c + .055) / 1.055) ** 2.4)


out, tiles = {}, []
for name, (path, what, patches) in IMAGES.items():
    image = Image.open(path).convert("RGB")
    pixels = np.asarray(image)
    row = {"file": str(path).replace(str(scratch), "SCRATCH"), "source": what, "patches": {}}
    white = None
    draw = ImageDraw.Draw(image)
    for patch, (x0, y0, x1, y1) in patches.items():
        rgb = np.median(pixels[y0:y1, x0:x1].reshape(-1, 3), axis=0)
        lum = float(linear(rgb) @ [.2126, .7152, .0722])
        white = lum if patch == "white" else white
        row["patches"][patch] = {"box": [x0, y0, x1, y1], "srgb": [int(v) for v in rgb], "hex": "%02x%02x%02x" % tuple(int(v) for v in rgb),
                                 "red_over_blue": round(float(rgb[0] / max(rgb[2], 1)), 2), "luminance": round(lum, 3)}
        draw.rectangle((x0, y0, x1, y1), outline="red", width=max(2, image.width // 400))
        draw.text((x0, max(0, y0 - 12)), patch, fill="red")
    if white:
        for patch in row["patches"].values():
            patch["luminance_vs_white_trim"] = round(patch["luminance"] / white, 2)
    out[name] = row
    image.thumbnail((520, 520))
    ImageDraw.Draw(image).text((4, 4), name, fill="yellow")
    tiles.append(image)
(here / "colours.json").write_text(json.dumps(out, indent=1) + "\n")
sheet = Image.new("RGB", (5 * 520, 3 * 520), "white")
for i, tile in enumerate(tiles):
    sheet.paste(tile, ((i % 5) * 520, (i // 5) * 520))
sheet.save(here / "patches.jpg", quality=85)
for name, row in out.items():
    print(name)
    for patch, v in row["patches"].items():
        print(f"   {patch:10s} #{v['hex']}  R/B {v['red_over_blue']:.2f}  vs white {v.get('luminance_vs_white_trim', '-')}")
