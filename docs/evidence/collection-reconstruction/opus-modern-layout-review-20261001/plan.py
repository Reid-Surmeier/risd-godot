"""Draws plan.png from layout-patch.json: authored layout beside the proposed one. North is up."""
import json
from pathlib import Path

from PIL import Image, ImageDraw

HERE = Path(__file__).parent
SCALE, X0, Z0 = 62, 9.9, 22.4  # pixels per metre and the world corner at the panel's top left
PANEL = (930, 960)
TONE = {"painting": (150, 60, 40), "window": (40, 120, 200), "case": (200, 150, 20), "opening": (30, 150, 70)}
LANDING = [10.55, 16.15, 28.1, 35.9]
# Authored today in remodel_room.gd build_lion_modern_rooms(): three east windows, no case.
AUTHORED = [("window", "east", 26.0, 1.34, "window"), ("window", "east", 28.0, 1.34, "window"), ("window", "east", 30.0, 1.34, "window"),
            ("painting", "west", 25.45, 3.122, "Fauconnier"), ("painting", "north", 17.45, .755, "Matisse"),
            ("painting", "north", 19.35, .947, "Cezanne"), ("painting", "south", 17.7, .881, "Braque"), ("painting", "south", 19.45, .630, "Villon")]
SECONDS = {"entry_door": "46.0 / 82.0-84.5s", "braque_48.248": "53.5 / 83.5s", "villon_70.058": "55.5-57.5s", "window_1": "58.5-62.0s",
           "seated_woman_case": "62.5-66.0s", "window_2": "66.5-67.5s", "adjoining_doorway": "68.0-69.5s", "cezanne_43.255": "69.5-72.5s",
           "matisse_57.037": "73.0-74.5s", "fauconnier_1995.043": "75.5-81.0s"}


def point(x, z, ox):
    return (ox + (x - X0) * SCALE, 60 + (z - Z0) * SCALE)


def room(draw, ox, bounds, fill, name):
    draw.rectangle([point(bounds[0], bounds[2], ox), point(bounds[1], bounds[3], ox)], fill=fill, outline=(60, 60, 60), width=3)
    draw.text(point(bounds[0] + 1.7, (bounds[2] + bounds[3]) / 2 - 1.15, ox), name, fill=(70, 70, 70))


def on_wall(draw, ox, bounds, kind, wall, centre, width, label):
    half = width / 2
    if wall in ("west", "east"):
        x = bounds[0] if wall == "west" else bounds[1]
        a, b = point(x, centre - half, ox), point(x, centre + half, ox)
        text = (b[0] + 10, (a[1] + b[1]) / 2 - 6) if wall == "west" else (b[0] - 12 - 6.2 * len(label), (a[1] + b[1]) / 2 - 6)
    else:
        z = bounds[2] if wall == "north" else bounds[3]
        a, b = point(centre - half, z, ox), point(centre + half, z, ox)
        text = ((a[0] + b[0]) / 2 - 3.1 * len(label), a[1] + 10) if wall == "north" else ((a[0] + b[0]) / 2 - 3.1 * len(label), a[1] - 22)
    draw.line([a, b], fill=TONE[kind], width=11 if kind != "opening" else 7)
    if kind == "opening":
        draw.line([a, b], fill=(255, 255, 255), width=3)
    draw.text(text, label, fill=TONE[kind])


def panel(draw, ox, title, modern, adjoining, things, doors):
    draw.text((ox + 20, 18), title, fill=(0, 0, 0))
    room(draw, ox, LANDING, (232, 230, 224), "lion stair landing")
    room(draw, ox, adjoining["bounds"], (240, 240, 236), "")
    room(draw, ox, modern["bounds"], (250, 240, 214), "modern painting gallery")
    # Lion panel on the landing face of the shared wall.
    draw.line([point(16.15 - .05, 33.15 - 1.22, ox), point(16.15 - .05, 33.15 + 1.22, ox)], fill=(110, 110, 110), width=5)
    draw.text(point(14.95, 33.05, ox), "lion 34.652", fill=(90, 90, 90))
    for side, span in modern["openings"].items():
        on_wall(draw, ox, modern["bounds"], "opening", side, sum(span) / 2, span[1] - span[0], doors[side])
    for kind, wall, centre, width, label in things:
        on_wall(draw, ox, modern["bounds"], kind, wall, centre, width, label)
    w, d = modern["bounds"][1] - modern["bounds"][0], modern["bounds"][3] - modern["bounds"][2]
    draw.text(point(modern["bounds"][0] + 1.7, (modern["bounds"][2] + modern["bounds"][3]) / 2 - .85, ox), f"{w:.1f} x {d:.1f} m, provisional", fill=(70, 70, 70))


def main():
    patch = json.loads((HERE / "layout-patch.json").read_text())
    modern = patch["rooms"]["modern painting gallery"]
    adjoining = patch["rooms"]["modern adjoining gallery threshold study limit"]
    image = Image.new("RGB", (PANEL[0] * 2, PANEL[1]), "white")
    draw = ImageDraw.Draw(image)
    panel(draw, 0, "AUTHORED TODAY (v48b): door and large painting share the west wall; three east windows", modern["current"], adjoining["current"], AUTHORED,
          {"west": "entry door", "east": "doorway"})
    proposed = []
    for item in patch["items"]:
        if item["kind"] == "opening":
            continue
        where = item["proposed"]
        centre = where.get("centre_x", where["position"][2 if item["wall"] in ("west", "east") else 0] if "position" in where else None)
        proposed.append((item["kind"], item["wall"], centre, item["framed_width_m"], f"{item['id'].split('_')[0].capitalize()} {SECONDS[item['id']]}"))
    panel(draw, PANEL[0], "PROPOSED from the 52.0-84.5s pan: door shares the Braque/Villon wall; two south windows", modern["proposed"], adjoining["proposed"], proposed,
          {"west": "entry door " + SECONDS["entry_door"], "east": "doorway " + SECONDS["adjoining_doorway"]})
    ox = PANEL[0]
    # Pan direction, read inside the room: west wall, south, east, north, back to the door.
    for (x, z), text in [((16.4, 31.2), "pan 52-58s  v"), ((18.4, 34.05), "58-67.5s  >"), ((20.75, 32.75), "^  68-75s"), ((18.6, 29.6), "<  75.5-82s")]:
        draw.text(point(x, z, ox), text, fill=(120, 120, 120))
    draw.text((20, PANEL[1] - 54), "North up, +X east, +Z south. Brown = painting, blue = window, gold = case, green = opening. Landing, its door and the lion are identical in both panels.", fill=(0, 0, 0))
    draw.text((20, PANEL[1] - 32), "The entry door, the cyclic order of everything round the room, and the floorboard direction are unchanged; only which wall each run sits on, and the room's proportions, move.", fill=(0, 0, 0))
    image.save(HERE / "plan.png")


if __name__ == "__main__":
    main()
