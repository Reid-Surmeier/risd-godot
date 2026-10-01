"""Replay main_build_walk.gd's plan rules (_room_at, _depth, _walkable, _slide, space swaps) in Python.

Run: python3 plan_check.py CURRENT_geometry.json PROPOSED_geometry.json OUT.json
No Godot. Furniture and door-leaf blocks are not in geometry.json, so only walls, openings and
floor voids are replayed; the leaves carry a room_wall owner and are never blocks in the walk.
"""
import json
import sys

L, ATTACH = 26.3, (-5.55, -28.1)
WALL_CLEAR, DOOR_CLEAR, BODY_CLEAR, SWAP_DEPTH = 0.35, 0.25, 0.3, 0.3
PORTAL_MOUTH, PORTAL_SIDE, DOOR_HALF, STEP = 2.2, 2.4, 0.95, 0.02
SIDES = {"west": (-1, 0), "east": (1, 0), "north": (0, -1), "south": (0, 1)}
FAR = ["Rockefeller", "purple elevator-5 connector", "grey French gallery",
       "Ionic marble-stair threshold study limit", "piano-stair threshold study limit",
       "Grand Gallery reveal threshold", "Rockefeller reveal threshold"]


def load(path, thresholds=True):
    plan, blocks = [], []
    for area in json.load(open(path))["rooms"]:
        if area["label"] == "Grand Gallery" or (area.get("reveal") and not thresholds):
            continue
        b = area["bounds"]
        openings = {s: [v + (ATTACH[1] if s in ("west", "east") else ATTACH[0]) for v in o]
                    for s, o in area["openings"].items()}
        plan.append({"label": area["label"], "far": area["label"] in FAR, "openings": openings,
                     "b": [b[0] + ATTACH[0], b[1] + ATTACH[0], b[2] + ATTACH[1], b[3] + ATTACH[1]]})
        if "floor_void" in area:
            v = area["floor_void"]
            blocks.append((v[0] + ATTACH[0], v[2] + ATTACH[1], v[1] - v[0], v[3] - v[2]))
    return plan, blocks


def depth(room, p):
    b = room["b"]
    return min(p[0] - b[0], b[1] - p[0], p[1] - b[2], b[3] - p[1])


def room_at(plan, p):
    found, deepest = -1, float("-inf")
    for i, room in enumerate(plan):
        d = depth(room, p)
        if d >= 0.0 and d > deepest:
            found, deepest = i, d
    return found


def walkable(plan, blocks, p, space):
    x, z = p
    if space == "far" and abs(x) <= 0.4 and -L - WALL_CLEAR < z <= -L + 0.2:
        return True
    if abs(x) < PORTAL_SIDE and -L < z < PORTAL_MOUTH:
        return False
    index = room_at(plan, p)
    if index < 0:
        return False
    b = plan[index]["b"]
    for side, (dx, dz) in SIDES.items():
        gap = {"west": x - b[0], "east": b[1] - x, "north": z - b[2], "south": b[3] - z}[side]
        if gap >= WALL_CLEAR:
            continue
        door = plan[index]["openings"].get(side, [])
        along = z if side in ("west", "east") else x
        if not door or along < door[0] + DOOR_CLEAR or along > door[1] - DOOR_CLEAR:
            return False
        reach = gap + WALL_CLEAR + 0.05
        if room_at(plan, (x + dx * reach, z + dz * reach)) < 0:
            return False
    for bx, bz, w, d in blocks:
        if bx - BODY_CLEAR <= x <= bx + w + BODY_CLEAR and bz - BODY_CLEAR <= z <= bz + d + BODY_CLEAR:
            return False
    return True


def walk(plan, blocks, start, space, heading, steps):
    """Hold one key: STEP per tick along heading, with the walk's clamp and space rules."""
    pos, log, spaces = start, [], [space]
    for _ in range(steps):
        want = (pos[0] + heading[0] * STEP, pos[1] + heading[1] * STEP)
        if space == "gallery":  # walk4._clamp, benches left out (none on these paths)
            doorway = abs(want[0]) <= 0.4
            want = (max(-4.45, min(4.45, want[0])), max(-L - 0.2 if doorway else -L + 0.55, min(-0.55, want[1])))
            pos = want
        elif walkable(plan, blocks, want, space):
            pos = want
        else:  # _slide: one axis at a time, else stay
            for q in ((want[0], pos[1]), (pos[0], want[1])):
                if q != pos and walkable(plan, blocks, q, space):
                    pos = q
                    break
        before = space
        if space == "gallery" and pos[1] < -L:
            space = "far"
        elif space == "far" and pos[1] > -L and abs(pos[0]) < DOOR_HALF:
            space = "gallery"
        elif space in ("arch", "far"):
            here = room_at(plan, pos)
            if here >= 0 and plan[here]["far"] != (space == "far") and depth(plan[here], pos) >= SWAP_DEPTH:
                space = "far" if plan[here]["far"] else "arch"
        if space != before:
            spaces.append(space)
            log.append({"to": space, "x": round(pos[0], 3), "z": round(pos[1], 3)})
        here = room_at(plan, pos)
    return {"end": [round(pos[0], 3), round(pos[1], 3)], "end_room": plan[here]["label"] if here >= 0 else "Hall",
            "spaces": spaces, "swaps": log}


def run(path, wall, thresholds=True):
    plan, blocks = load(path, thresholds)
    grey = next(r for r in plan if r["label"] == "grey French gallery")["b"]
    rock = next(r for r in plan if r["label"] == "Rockefeller")["b"]
    n = -L - wall  # the far rooms' south wall plane, Hall-local
    out = {"rooms": len(plan), "wall_m": wall}
    out["hall_to_grey"] = walk(plan, blocks, (0.0, -24.5), "gallery", (0, -1), 220)
    out["grey_to_hall"] = walk(plan, blocks, (0.0, n - 2.0), "far", (0, 1), 260)
    out["european_to_rockefeller"] = walk(plan, blocks, (-8.05, -24.5), "arch", (0, -1), 220)
    out["rockefeller_to_european"] = walk(plan, blocks, (-8.05, n - 2.0), "far", (0, 1), 260)
    out["off_axis_at_jamb_blocked"] = walk(plan, blocks, (0.8, n - 2.0), "far", (0, 1), 260)
    # Along the wall line the visitor may stand only in a door: within its clear span beside the wall,
    # and inside a reveal threshold room within the wall's thickness. The Hall's own 0.8 m strip is
    # walk4's and covers the last WALL_CLEAR at the Hall end.
    doors = [[v + (DOOR_CLEAR if i == 0 else -DOOR_CLEAR) for i, v in enumerate(r["openings"]["south"])]
             for r in plan if r["label"] in ("grey French gallery", "Rockefeller")]
    leaks, open_area = [], 0
    z = n - WALL_CLEAR + 0.01
    while z < -L + 0.2:
        x = rock[0]
        while x <= grey[1]:
            if walkable(plan, blocks, (x, z), "far"):
                open_area += 1
                if not any(lo - 1e-6 <= x <= hi + 1e-6 for lo, hi in doors) or (-L < z and abs(x) > 0.4 and x > -5.0):
                    leaks.append([round(x, 2), round(z, 2)])
            x += 0.05
        z += 0.05
    out["door_clear_spans_x"] = [[round(v, 2) for v in d] for d in doors]
    out["wall_line_leaks"], out["wall_line_open_samples"] = leaks, open_area
    c = [r for r in plan if r["label"] == "purple elevator-5 connector"][0]["b"]
    out["grey_sw_corner_to_connector_door_m"] = round(grey[3] - c[3], 3)
    out["grey_west_wall_m"] = round(grey[3] - grey[2], 3)
    out["rockefeller_south_equals_grey_south"] = abs(rock[3] - grey[3]) < 1e-9
    return out


def demo(result, wall):
    """The one check: both doors cross both ways, nothing else on the wall line opens."""
    assert result["hall_to_grey"]["end_room"] == "grey French gallery" and result["hall_to_grey"]["spaces"] == ["gallery", "far"]
    assert result["grey_to_hall"]["end_room"] == "Hall" and result["grey_to_hall"]["spaces"] == ["far", "gallery"]
    assert result["european_to_rockefeller"]["end_room"] == "Rockefeller" and result["european_to_rockefeller"]["spaces"] == ["arch", "far"]
    assert result["rockefeller_to_european"]["end_room"] == "adjacent gallery" and result["rockefeller_to_european"]["spaces"] == ["far", "arch"]
    assert result["off_axis_at_jamb_blocked"]["end_room"] == "grey French gallery"
    assert result["wall_line_leaks"] == [] and result["wall_line_open_samples"] > 0
    assert result["grey_sw_corner_to_connector_door_m"] == 0.3 and result["grey_west_wall_m"] == 6.0
    assert result["rockefeller_south_equals_grey_south"]


if __name__ == "__main__":
    current, proposed, target = sys.argv[1:4]
    wall = json.load(open(proposed))["hall_reveal"]["wall_m"]
    report = {"current": run(current, 0.0), "proposed": run(proposed, wall)}
    demo(report["current"], 0.0)
    demo(report["proposed"], wall)
    # Negative control: the same move without the two threshold rooms shuts both doors.
    blind = run(proposed, wall, False)
    assert blind["hall_to_grey"]["end_room"] == "Hall" and blind["grey_to_hall"]["end_room"] == "grey French gallery"
    assert blind["european_to_rockefeller"]["end_room"] == "adjacent gallery" and blind["rockefeller_to_european"]["end_room"] == "Rockefeller"
    report["far_group_moved_without_threshold_rooms"] = {k: blind[k] for k in ("hall_to_grey", "grey_to_hall", "european_to_rockefeller", "rockefeller_to_european")}
    report["all_metric_placement_map_fidelity_flags"] = False
    json.dump(report, open(target, "w"), indent=1)
    print(json.dumps(report, indent=1))
