"""Draws built-plan.png from checks.json and emitted-geometry.json: what check_landing.gd read out of the
built scene, over the emitted rooms. North is up. A diagram, not a render; no metre here is accepted."""
import json
from pathlib import Path

from PIL import Image, ImageDraw

HERE = Path(__file__).parent
SCALE, X0, Z0 = 62, 3.6, 20.2
SIDES = {"west": (0, 2, 3), "east": (1, 2, 3), "north": (2, 0, 1), "south": (3, 0, 1)}
AXIS = 31.765


def at(x, z):
    return ((x - X0) * SCALE, 40 + (z - Z0) * SCALE)


def bar(draw, x0, z0, x1, z1, fill, pad=.06):
    draw.rectangle([at(min(x0, x1) - pad, min(z0, z1) - pad), at(max(x0, x1) + pad, max(z0, z1) + pad)], fill=fill)


def main():
    data = json.loads((HERE / "checks.json").read_text())
    built = data["built"]
    geometry = json.loads((HERE / "emitted-geometry.json").read_text())
    rooms = {r["label"]: r for r in geometry["rooms"]}
    image = Image.new("RGB", (920, 1190), "white")
    draw = ImageDraw.Draw(image)
    tints = {"Grand Gallery": (201, 211, 230), "dark medieval room": (185, 188, 196), "lion stair landing": (243, 239, 226),
             "modern painting gallery": (223, 233, 223), "white sculpture gallery threshold study limit": (236, 236, 230),
             "modern adjoining gallery threshold study limit": (236, 236, 230)}
    for label, tint in tints.items():
        b = rooms[label]["bounds"]
        draw.rectangle([at(b[0], b[2]), at(b[1], b[3])], fill=tint)
    for label in list(tints)[1:]:
        b = rooms[label]["bounds"]
        for side, (fixed, lo, hi) in SIDES.items():
            cuts = [b[lo]] + rooms[label]["openings"].get(side, []) + [b[hi]]
            for a, c in zip(cuts[::2], cuts[1::2]):
                bar(draw, *((b[fixed], a, b[fixed], c) if side in ("west", "east") else (a, b[fixed], c, b[fixed])), fill=(70, 70, 70))
    # One axis: tracery doorway (off the left edge), tall case, stair door.
    for x in range(8, 56):
        draw.line([at(3.6 + x * .14, AXIS), at(3.6 + x * .14 + .07, AXIS)], fill=(214, 45, 32), width=2)
    draw.text(at(3.7, AXIS - 1.0), "door axis z 31.765 (tracery doorway to the west)", fill=(214, 45, 32))
    cases = built["cases"]
    for key, text in [("tall", "tall case"), ("low", "low case")]:
        draw.rectangle([at(cases[key + "_x"][0], cases[key + "_z"][0]), at(cases[key + "_x"][1], cases[key + "_z"][1])], fill=(102, 103, 99))
        draw.text(at(cases[key + "_x"][0], cases[key + "_z"][1] + .08), text, fill=(60, 60, 60))
    for name, apostle in built["apostles"].items():
        bar(draw, 10.38, apostle["z"] - .21, 10.38, apostle["z"] + .21, fill=(150, 60, 40), pad=.05)
        draw.text(at(8.9, apostle["z"] - .12 + (.35 if apostle["z"] > AXIS else -.35)), name.replace("apostle-", "apostle "), fill=(150, 60, 40))
    void = rooms["lion stair landing"]["floor_void"]
    draw.rectangle([at(void[0] + .1, void[2]), at(void[1], void[3] - .1)], outline=(120, 120, 120), width=2)
    for patch in geometry["patches"]:
        if patch["label"].endswith("stair study"):
            xs = [v[0] for v in patch["vertices"]]
            zs = [v[2] for v in patch["vertices"]]
            draw.rectangle([at(min(xs), min(zs)), at(max(xs), max(zs))], fill=(214, 208, 190))
            draw.text(at(min(xs) + .05, min(zs) + 1.2), patch["label"].split()[0] + "\nflight", fill=(90, 90, 90))
    draw.text(at(void[0] + .2, void[3] - .75), "draft stair block, moved\nwith the door; unaccepted", fill=(90, 90, 90))
    for x, z, along_z in built["leaves"]:
        bar(draw, *((x, z - .45, x, z + .45) if along_z else (x - .45, z, x + .45, z)), fill=(200, 120, 0), pad=.03)
    lion = built["lion"]
    bar(draw, lion["x_span"][0], lion["position"][2] + .04, lion["x_span"][1], lion["position"][2] + .04, fill=(26, 156, 60))
    draw.text(at(lion["x_span"][0], lion["position"][2] + .25), "lion 34.652, faces south", fill=(26, 156, 60))
    for accession, work in built["paintings"].items():
        x, _, z = work["position"]
        half = work["outer_m"][0] / 2
        across = abs(work["faces"][1]) > .5
        bar(draw, *((x - half, z, x + half, z) if across else (x, z - half, x, z + half)), fill=(150, 60, 40), pad=.05)
        draw.text(at(x - .35 if across else x + .15, z + (.15 if z < 25 else -.3) if across else z - .08), accession, fill=(150, 60, 40))
    for x, _, z in built["windows"]:
        bar(draw, x, z - .67, x, z + .67, fill=(40, 120, 200))
        draw.text(at(x - 1.05, z - .08), "window", fill=(40, 120, 200))
    x, _, z = built["case"]["position"]
    bar(draw, x - .64, z - .31, x, z + .31, fill=(200, 150, 20), pad=0)
    draw.text(at(x - 2.9, z - .08), "Seated Woman 67.089", fill=(160, 110, 0))
    for text, x, z in [("Main Hall (retained)", 5.0, 24.0), ("medieval", 4.2, 29.0), ("lion stair landing", 13.9, 32.9), ("modern painting gallery", 11.6, 26.9),
                       ("white sculpture\nthreshold", 16.3, 30.2), ("adjoining\nthreshold", 15.2, 21.1), ("stair door", 11.6, 31.3),
                       ("modern door (north)", 11.0, 28.3), ("south: no opening", 13.8, 37.25)]:
        draw.text(at(x, z), text, fill=(0, 0, 0))
    draw.text((12, 8), "Built scene read back headless over the emitted rooms. Orange = door leaves, grey = wall spans. Every metre provisional.", fill=(0, 0, 0))
    image.save(HERE / "built-plan.png")


if __name__ == "__main__":
    main()
