"""Draws built-plan.png from checks.json: what check_modern.gd read out of the built scene. North is up."""
import json
from pathlib import Path

from PIL import Image, ImageDraw

HERE = Path(__file__).parent
SCALE, X0, Z0 = 105, 15.3, 28.2


def at(x, z):
    return ((x - X0) * SCALE, (z - Z0) * SCALE)


def box(draw, x, z, w, d, **style):
    draw.rectangle([at(x - w / 2, z - d / 2), at(x + w / 2, z + d / 2)], **style)


def main():
    data = json.loads((HERE / "checks.json").read_text())
    built = data["built"]
    image = Image.new("RGB", (900, 800), "white")
    draw = ImageDraw.Draw(image)
    bounds = data["geometry"]["modern"]["bounds"]
    draw.rectangle([at(bounds[0], bounds[2]), at(bounds[1], bounds[3])], fill=(250, 240, 214))
    stub = data["geometry"]["adjoining"]["bounds"]
    draw.rectangle([at(stub[0], stub[2]), at(stub[1], stub[3])], fill=(236, 236, 230))
    for tag, x, z, w, d in built["walls"]:
        box(draw, x, z, w, d, fill=(70, 70, 70))
    for x, z, w, d in built["tracks"]:
        box(draw, x, z, w, max(d, .04), fill=(190, 190, 190))
    for x, z, w, d in built["bench"]:
        box(draw, x, z, w, d, fill=(60, 56, 54))
        draw.text(at(x - .25, z - .08), "bench", fill=(255, 255, 255))
    for x, _, z in built["windows"]:
        box(draw, x, z, 1.34, .12, fill=(40, 120, 200))
        draw.text(at(x - .3, z - .32), "window", fill=(40, 120, 200))
    x, _, z = built["case"]["position"]
    box(draw, x, z - .335, .68, .67, fill=(200, 150, 20))
    draw.text(at(x - .55, z - .95), "Seated Woman 67.089", fill=(160, 110, 0))
    for accession, work in built["paintings"].items():
        x, _, z = work["position"]
        across = work["wall"] in ("north", "south")
        box(draw, x, z, work["outer_m"][0] if across else .1, .1 if across else work["outer_m"][0], fill=(150, 60, 40))
        offset = {"north": (-.3, .12), "west": (.12, -.06), "east": (-.72, -.06)}[work["wall"]]
        draw.text(at(x + offset[0], z + offset[1]), accession, fill=(150, 60, 40))
    draw.text(at(15.4, 29.95), "entry", fill=(30, 150, 70))
    draw.text(at(22.1, 33.85), "doorway", fill=(30, 150, 70))
    draw.text((12, 10), "Built scene, read back headless: modern painting gallery %.1f x %.1f m (provisional). Grey = wall spans, light grey = ceiling tracks." % (bounds[1] - bounds[0], bounds[3] - bounds[2]), fill=(0, 0, 0))
    image.save(HERE / "built-plan.png")


if __name__ == "__main__":
    main()
