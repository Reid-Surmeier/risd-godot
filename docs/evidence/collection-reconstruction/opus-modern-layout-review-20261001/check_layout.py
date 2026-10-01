"""Opening-pair and non-overlap check for layout-patch.json. CPU only, standard library only.

python3 check_layout.py [geometry.json]
Default geometry: the v48b native project in ingestion. Applies the proposed rooms to it, then checks
room pairs, room overlap, and that nothing on a modern-gallery wall overlaps or leaves the pan order.
"""
import copy
import json
import sys
from pathlib import Path

HERE = Path(__file__).parent
DEFAULT = Path.home() / "risd-godot-ingestion/collection-expansion/lowpoly-room-v48b-modern-frames/geometry.json"
MODERN = "modern painting gallery"
# Same pairs prepare_remodel.py asserts, by label.
PAIRS = [("dark medieval room", "east", "lion stair landing", "west"), ("lion stair landing", "east", MODERN, "west"),
         ("lion stair landing", "south", "white sculpture gallery threshold study limit", "north"),
         (MODERN, "east", "modern adjoining gallery threshold study limit", "west")]
SIDE = {"west": 0, "east": 1, "north": 2, "south": 3}
CASING = .16  # door architrave either side of an opening, as moulding() draws it
CLEAR = .15  # least wall left between two things, and between a thing and a corner
ORDER = {"west": "west_north_to_south", "south": "south_west_to_east", "east": "east_north_to_south", "north": "north_west_to_east"}


def problems(rooms, patch):
    found = []
    by = {r["label"]: r for r in rooms}
    for a, side, b, other in PAIRS:
        ra, rb = by[a], by[b]
        span = ra["openings"].get(side)
        if span is None or span != rb["openings"].get(other):
            found.append(f"opening pair differs: {a}:{side} {span} / {b}:{other} {rb['openings'].get(other)}")
            continue
        if abs(ra["bounds"][SIDE[side]] - rb["bounds"][SIDE[other]]) > 1e-8:
            found.append(f"paired rooms do not share a wall line: {a}:{side} / {b}:{other}")
        for r in (ra, rb):
            lo, hi = (r["bounds"][2], r["bounds"][3]) if side in ("west", "east") else (r["bounds"][0], r["bounds"][1])
            if span[0] < lo - 1e-8 or span[1] > hi + 1e-8:
                found.append(f"opening {span} runs past the wall of {r['label']} [{lo}, {hi}]")
    for i, a in enumerate(rooms):
        for b in rooms[i + 1:]:
            aa, bb = a["bounds"], b["bounds"]
            if min(aa[1], bb[1]) - max(aa[0], bb[0]) > 1e-8 and min(aa[3], bb[3]) - max(aa[2], bb[2]) > 1e-8:
                found.append(f"rooms overlap: {a['label']} / {b['label']}")
    bounds = by[MODERN]["bounds"]
    width, depth = bounds[1] - bounds[0], bounds[3] - bounds[2]
    if max(width, depth) / min(width, depth) > 1.25:
        found.append(f"modern gallery is stretched: {width:.2f} x {depth:.2f} m against a near-square source room")
    for wall, key in ORDER.items():
        along_z = wall in ("west", "east")
        lo, hi = (bounds[2], bounds[3]) if along_z else (bounds[0], bounds[1])
        placed = []
        for item in patch["items"]:
            if item["wall"] != wall:
                continue
            if item["kind"] == "opening":
                # An opening is whatever the room says it is, so a moved doorway cannot hide behind the item list.
                span = by[MODERN]["openings"].get(wall)
                if span is None:
                    found.append(f"{item['id']}: the room has no {wall} opening")
                    continue
                placed.append((span[0] - CASING, span[1] + CASING, item["id"]))
                continue
            proposed = item["proposed"]
            centre = proposed.get("centre_x", proposed["position"][2 if along_z else 0] if "position" in proposed else None)
            placed.append((centre - item["framed_width_m"] / 2, centre + item["framed_width_m"] / 2, item["id"]))
            if "position" in proposed and item["kind"] != "case":
                line = bounds[SIDE[wall]] + (.08 if wall in ("west", "north") else -.08)
                if abs(proposed["position"][0 if along_z else 2] - line) > 1e-6:
                    found.append(f"{item['id']} is not hung on the {wall} wall line")
        placed.sort()
        if [p[2] for p in placed] != patch["wall_order_from_pan"][key]:
            found.append(f"{wall} wall order {[p[2] for p in placed]} differs from the pan")
        edges = [(lo, lo, "corner")] + placed + [(hi, hi, "corner")]
        for left, right in zip(edges, edges[1:]):
            gap = right[0] - left[1]
            if gap < (CLEAR if "corner" not in (left[2], right[2]) else 0) - 1e-8:
                found.append(f"{wall} wall: {left[2]} and {right[2]} overlap or touch ({gap:.2f} m apart)")
    return found


def main():
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT
    rooms = json.loads(path.read_text())["rooms"]
    patch = json.loads((HERE / "layout-patch.json").read_text())
    authored = problems(copy.deepcopy(rooms), patch)
    for room in rooms:
        if room["label"] in patch["rooms"]:
            room.update(patch["rooms"][room["label"]]["proposed"])
    proposed = problems(rooms, patch)
    # The check must be able to fail: put the doorway back beside the old windows, and hang a painting over it.
    moved = copy.deepcopy(rooms)
    next(r for r in moved if r["label"] == MODERN)["openings"]["east"] = [23.5, 25.1]
    hung = copy.deepcopy(patch)
    next(i for i in hung["items"] if i["id"] == "cezanne_43.255")["proposed"]["position"][2] = 33.6
    assert problems(moved, patch), "an unpaired doorway must fail"
    assert any("overlap" in p for p in problems(rooms, hung)), "a painting across the doorway must fail"
    report = {"geometry": str(path), "proposed_problems": proposed, "passed": not proposed,
              "authored_rooms_against_proposed_items": authored}
    (HERE / "check-layout.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))
    sys.exit(1 if proposed else 0)


if __name__ == "__main__":
    main()
