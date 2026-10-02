"""Compare two dump_scene.gd outputs: what stayed, what moved north by the wall, what is new.

Run: python3 compare_dumps.py BASE.json NEW.json WALL_M OUT.json
"""
import json
import sys

base, new = (json.load(open(p)) for p in sys.argv[1:3])
wall = float(sys.argv[3])
FAR_BASE = [(-4.7, 1.7, -5.0, 1.8), (1.7, 3.85, -0.34, 1.5), (3.85, 12.65, -4.2, 1.8), (4.55, 6.55, -5.8, -4.2)]


def far(x, z):
    return any(a - .2 <= x <= b + .2 and c - .2 <= z <= d + .001 for a, b, c, d in FAR_BASE)


def split(old, now):
    """Greedy match within 2 mm: identical first, then the same thing wall metres north."""
    left = [tuple(item) for item in now]

    def take(item, dz):
        for i, other in enumerate(left):
            if all(abs(a - b) <= .002 for a, b in zip(item[:2] + (item[2] - dz,) + item[3:], other)):
                return left.pop(i)
        return None

    same, moved, lost, rest = [], [], [], []
    for item in map(tuple, old):
        (same if take(item, 0.0) else rest).append(item)
    for item in rest:
        (moved if take(item, wall) else lost).append(item)
    return same, moved, lost, left


same, moved, lost, added = split(base["meshes"], new["meshes"])
body = lambda b: tuple(b["at"]) + tuple(b["size"])
bsame, bmoved, blost, badded = split([body(b) for b in base["bodies"]], [body(b) for b in new["bodies"]])
report = {
    "wall_m": wall,
    "meshes": {"base": len(base["meshes"]), "new": len(new["meshes"]), "unchanged": len(same), "moved_north_by_wall": len(moved), "base_only": len(lost), "new_only": len(added)},
    "bodies": {"base": len(base["bodies"]), "new": len(new["bodies"]), "unchanged": len(bsame), "moved_north_by_wall": len(bmoved), "base_only": len(blost), "new_only": len(badded)},
    "moved_meshes_outside_far_rooms": [m for m in moved if not far(m[0], m[2])],
    "unchanged_meshes_inside_far_rooms": [m for m in same if far(m[0], m[2]) and m[2] < 1.7],
    "base_only_meshes": lost, "new_only_meshes": added, "base_only_bodies": blost, "new_only_bodies": badded,
    "new_reveal_bodies": [b for b in new["bodies"] if "reveal threshold" in b["wall"]],
    "new_opaque_ceilings": [c for c in new["opaque_ceilings"] if "reveal" in c["label"]],
    "start": {"base": base["start"], "new": new["start"]},
    "inventory_hall_reveal": new["inventory_hall_reveal"],
}
json.dump(report, open(sys.argv[4], "w"), indent=1)
print(json.dumps({k: v for k, v in report.items() if k in ("meshes", "bodies", "start", "new_reveal_bodies", "new_opaque_ceilings")}, indent=1))
for key in ("moved_meshes_outside_far_rooms", "unchanged_meshes_inside_far_rooms", "base_only_meshes", "new_only_meshes", "base_only_bodies", "new_only_bodies"):
    print(key, len(report[key]), report[key][:14])
