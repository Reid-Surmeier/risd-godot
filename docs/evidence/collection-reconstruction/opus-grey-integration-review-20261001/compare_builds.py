"""Independent comparison of two dumps from dump_scene.gd: BEFORE (root's landing baseline) and AFTER
(the grey-register delivery), judged against the fit's plan.json and the source wall order.

    python3 compare_builds.py <before.json> <after.json> <plan.json> <out.json>

Exit 0 when nothing failed, 1 when a FAIL line was recorded. UNVERIFIED lines never change the exit code.
Every expectation is written here from plan.json and the source review, not read from the delivered scripts.
"""
import json, sys
from collections import Counter, defaultdict
from pathlib import Path

before, after, plan = (json.loads(Path(p).read_text()) for p in sys.argv[1:4])
out = {"passed": [], "failed": [], "unverified": [], "tables": {}}


def record(ok, text, detail=None):
    out["passed" if ok else "failed"].append(text if detail is None else {"check": text, "detail": detail})
    print(("PASS  " if ok else "FAIL  ") + text + ("" if ok or detail is None else "  -> " + json.dumps(detail)[:400]))


def unverified(text):
    out["unverified"].append(text)
    print("UNVER " + text)


def close(a, b, tol=1e-6):
    return len(a) == len(b) and all(abs(x - y) <= tol for x, y in zip(a, b))


rooms_a = {r["label"]: r for r in before["rooms"]}
rooms_b = {r["label"]: r for r in after["rooms"]}
GREY, CONNECTOR, ROCK, EURO = "grey French gallery", "purple elevator-5 connector", "Rockefeller", "adjacent gallery"
IONIC, PIANO, HALL = "Ionic marble-stair threshold study limit", "piano-stair threshold study limit", "Grand Gallery"

# 1. Emitted rooms against the plan.
step1, step2 = plan["step_1_register"], plan["step_2_wall_length"]
door = step1["door_clear_z"]
north = step2["grey_north_wall_z"]["value"]
expected = {
    GREY: ([3.85, 11.05, north, 1.8], {"west": door, "east": [north, 1.8], "north": [4.55, 6.55], "south": [4.55, 6.55]}),
    CONNECTOR: ([1.7, 3.85, door[0], door[1]], {"west": door, "east": door}),
    ROCK: ([-4.7, 1.7, -5.0, 1.8], {"south": [-3.5, -1.5], "east": door}),
    EURO: ([-5.55, 0.55, 1.8, 28.1], {"north": [-3.5, -1.5], "south": [-3.5, -1.5]}),
    IONIC: ([11.05, 12.65, north, 1.8], {"west": [north, 1.8]}),
    PIANO: ([4.55, 6.55, north - 1.6, north], {"south": [4.55, 6.55]}),
    HALL: ([0.55, 10.55, 1.8, 28.1], {"north": [4.55, 6.55], "south": [3.4355, 7.6645]}),
}
for label, (bounds, openings) in expected.items():
    got = rooms_b.get(label, {"bounds": [], "openings": {}})
    record(close(got["bounds"], bounds) and set(got["openings"]) == set(openings) and all(close(got["openings"][k], v) for k, v in openings.items()),
           "room '%s' equals the plan" % label, {"got": [got["bounds"], got["openings"]], "want": [bounds, openings]})
untouched = [l for l in rooms_a if l not in expected]
record(all(rooms_a[l] == rooms_b.get(l) for l in untouched), "the %d rooms outside the register change are identical to the baseline" % len(untouched),
       [l for l in untouched if rooms_a[l] != rooms_b.get(l)])
edge = {"west": 0, "east": 1, "north": 2, "south": 3}
opposite = {"west": "east", "east": "west", "north": "south", "south": "north"}
pairs, lonely = 0, []
for room in after["rooms"]:
    for side, span in room["openings"].items():
        partners = [o for o in after["rooms"] if o is not room and opposite[side] in o["openings"]
                    and abs(o["bounds"][edge[opposite[side]]] - room["bounds"][edge[side]]) < 1e-6 and close(o["openings"][opposite[side]], span)]
        pairs += len(partners) == 1
        if len(partners) != 1:
            lonely.append([room["label"], side, span, len(partners)])
record(not lonely, "every opening has exactly one partner on a shared wall line (%d paired openings, %d pairs)" % (pairs, pairs // 2), lonely)
overlaps = []
for i, p in enumerate(after["rooms"]):
    for q in after["rooms"][i + 1:]:
        a, b = p["bounds"], q["bounds"]
        if min(a[1], b[1]) - max(a[0], b[0]) > 1e-8 and min(a[3], b[3]) - max(a[2], b[2]) > 1e-8:
            overlaps.append([p["label"], q["label"]])
record(not overlaps, "no two rooms overlap in plan", overlaps)
g = rooms_b[GREY]["bounds"]
measures = {"corner return to clear opening": (1.8 - door[1], step1["corner_return_to_clear_edge_m"]["range"]),
            "door clear width": (door[1] - door[0], step1["clear_width_m"]["range"]),
            "grey west wall length": (g[3] - g[2], step2["grey_west_wall_length_m"]["range"])}
for name, (value, (lo, hi)) in measures.items():
    record(lo - 1e-9 <= value <= hi + 1e-9, "%s %.2f m is inside the fit's range %.2f..%.2f" % (name, value, lo, hi))
flags = after.get("grey_register") or {}
record(all(flags.get(k) is False for k in ["metric_accepted", "calibrated_room_metric", "physical_loop_accepted", "connector_length_accepted"]),
       "grey_register flags: every metric and loop flag is false", flags)

# 2. Floors and the retained Hall.
fa, fb = before["floors"], after["floors"]
out["tables"]["floors"] = {"before": {k: fa[k] for k in fa if k != "down_examples"}, "after": {k: fb[k] for k in fb if k != "down_examples"}}
record(fb["meshes"] > 1000 and fb["front_faces_down"] == 0 and fb["stored_normal_down"] == 0 and fb["no_normals"] == 0,
       "every floor triangle (%d in %d meshes) has an upward clockwise front and an upward stored normal" % (fb["triangles"], fb["meshes"]), out["tables"]["floors"]["after"])
record(fa["front_faces_down"] > 0 and fa["stored_normal_down"] > 0, "negative control: the baseline floors fail that same test (%d wrong fronts, %d down or missing normals)" % (fa["front_faces_down"], fa["stored_normal_down"]))
hb = after["hall"]
record(hb["retained_meshes"] == 139 and len(hb["retained_work_tags"]) == 23 and hb["retained_work_tags"] == hb["works_json_tags"] and hb["inventory"]["main_hall_rebuilt"] is False
       and hb["files_listed"] == 362 and hb["non_import_files_hash_equal"] == hb["non_import_files"] and hb["script"].endswith("retained_hall_room.gd")
       and close(hb["position"], before["hall"]["position"], 1e-5),
       "retained Main Hall: 139 meshes; frame or canvas textures for all 23 works listed in its works.json are on retained meshes; %d of %d non-import source files hash-equal; same attachment point" % (hb["non_import_files_hash_equal"], hb["non_import_files"]), hb)


# 3. What moved. Match every authored node of the baseline to a node with the same signature in the delivery.
def centre(n):
    b = n["box"]
    return ((b[0] + b[3]) / 2, (b[1] + b[4]) / 2, (b[2] + b[5]) / 2)


def signature(n):
    b = n["box"]
    tag = n["tag"] if not n["tag"].startswith("wall=") else "wall"
    return (n["kind"], n["look"], tag)


def size(n):
    b = n["box"]
    return (b[3] - b[0], b[4] - b[1], b[5] - b[2])


def region(c):
    x, _, z = c
    if 1.69 <= x <= 3.86 and -2.95 <= z <= -1.05:
        return "connector"
    if -4.85 <= x <= 1.86 and z <= -0.25:
        return "Rockefeller"
    if -5.7 <= x <= 0.7 and -0.25 < z <= 28.25:
        return "European gallery"
    if 3.7 <= x <= 12.8 and -7.6 <= z <= 1.95:
        return "grey gallery and thresholds"
    if 0.4 <= x <= 10.7 and 1.6 < z <= 28.3:
        return "Main Hall footprint (authored extras)"
    return "elsewhere (medieval, Renaissance, landing, modern)"


index = defaultdict(list)
for n in after["nodes"]:
    index[signature(n)].append([centre(n), False, n])
CANDIDATES = [0.0, 2.2, 2.58, 2.7, 2.46, 1.6, 1.29, 0.8]
moves = defaultdict(Counter)
odd_rockefeller = []
unmatched_before = defaultdict(list)
for n in before["nodes"]:
    c, hit = centre(n), None
    for dz in CANDIDATES:
        for item in index.get(signature(n), []):
            if not item[1] and abs(item[0][0] - c[0]) < 2e-3 and abs(item[0][1] - c[1]) < 2e-3 and abs(item[0][2] - c[2] - dz) < 2e-3 and close(size(item[2]), size(n), 3e-3):
                item[1], hit = True, dz
                break
        if hit is not None:
            break
    where = region(c)
    wall_or_floor = n["tag"].startswith("wall=") or "floor_oak" in n["look"] or (n["look"] == "81735cff" and n["box"][4] - n["box"][1] < 0.01)
    moves[where]["%s moved +%.2f z" % ("wall or floor piece" if wall_or_floor else "object", hit) if hit is not None else ("wall or floor piece rebuilt" if wall_or_floor else "object not found at any expected shift")] += 1
    if hit is not None and not wall_or_floor and where == "Rockefeller" and abs(hit - 2.2) > 1e-6:
        odd_rockefeller.append({"look": n["look"], "tag": n["tag"], "centre": [round(v, 3) for v in c], "moved_z": hit})
    if hit is None and not wall_or_floor:
        unmatched_before[where].append({"kind": n["kind"], "look": n["look"], "tag": n["tag"], "centre": [round(v, 3) for v in c], "size": [round(v, 3) for v in size(n)]})
unmatched_after = defaultdict(list)
for sig, items in index.items():
    for c, used, n in items:
        if not used and not n["tag"].startswith("wall=") and "floor_oak" not in n["look"] and not (n["look"] == "81735cff" and n["box"][4] - n["box"][1] < 0.01):
            unmatched_after[region((c[0], c[1], c[2]))].append({"kind": n["kind"], "look": n["look"], "tag": n["tag"], "centre": [round(v, 3) for v in c], "size": [round(v, 3) for v in size(n)]})
out["tables"]["moves_by_baseline_region"] = {k: dict(v) for k, v in moves.items()}
out["tables"]["baseline_objects_not_found"] = unmatched_before
out["tables"]["delivery_objects_without_a_baseline_match"] = unmatched_after
print(json.dumps(out["tables"]["moves_by_baseline_region"], indent=1))
elsewhere = moves["elsewhere (medieval, Renaissance, landing, modern)"]
record(set(elsewhere) <= {"object moved +0.00 z", "wall or floor piece moved +0.00 z"}, "nothing outside the four changed rooms moved (%d nodes)" % sum(elsewhere.values()), dict(elsewhere))
hall_extras = moves["Main Hall footprint (authored extras)"]
record(set(hall_extras) <= {"object moved +0.00 z", "wall or floor piece moved +0.00 z", "wall or floor piece rebuilt"} and not unmatched_before["Main Hall footprint (authored extras)"],
       "authored extras inside the Hall footprint did not move (%d nodes)" % sum(hall_extras.values()), dict(hall_extras))
rock = moves["Rockefeller"]
# The one allowed exception is the vent over the east door, which belongs to the door (+2.58).
door_vent = [o for o in odd_rockefeller if abs(o["moved_z"] - 2.58) < 1e-6 and abs(o["centre"][0] - 1.48) < 0.2 and o["centre"][1] > 2.9]
out["tables"]["rockefeller_objects_not_moved_2.20"] = odd_rockefeller
record(rock["object moved +2.20 z"] > 100 and len(odd_rockefeller) == len(door_vent) <= 1 and not rock["object not found at any expected shift"] and not unmatched_before["Rockefeller"],
       "every Rockefeller object moved exactly +2.20 m with its room (%d objects); only the vent over the east door moved with the door (+2.58)" % rock["object moved +2.20 z"], {"counts": dict(rock), "odd": odd_rockefeller})

# 4. Coupled objects against the plan and the source wall order.
nodes = after["nodes"]


def find(pred):
    return [n for n in nodes if pred(n)]


courbet = find(lambda n: n["look"].endswith("painting-43.571.jpg"))
corot = find(lambda n: n["look"].endswith("painting-24.089.jpg"))
bertin = find(lambda n: n["look"].endswith("painting-56.214.jpg"))
lo, hi = step2["courbet_centre_z"]["range"]
record(len(courbet) >= 1 and lo <= centre(courbet[0])[2] <= hi and abs(centre(courbet[0])[0] - 3.85) < 0.15,
       "Courbet 43.571 hangs on the west wall with its centre inside the fit's range %.2f..%.2f" % (lo, hi), [centre(n) for n in courbet][:1])
if courbet:
    lo, hi = step2["courbet_centre_from_nw_corner_m"]["range"]
    record(lo <= centre(courbet[0])[2] - g[2] <= hi, "Courbet centre is %.2f m from the north-west corner (fit %.2f..%.2f)" % (centre(courbet[0])[2] - g[2], lo, hi))
record(len(corot) >= 1 and abs(centre(corot[0])[2] - g[2]) < 0.15 and g[0] < centre(corot[0])[0] < g[1], "Corot 24.089 rides the moved north wall", [centre(n) for n in corot][:1])
record(len(bertin) >= 1 and abs(centre(bertin[0])[2] - 1.8) < 0.15, "Bertin 56.214 stays on the Hall-door wall", [centre(n) for n in bertin][:1])
c = rooms_b[CONNECTOR]["bounds"]
panels = find(lambda n: n["kind"] == "mesh" and n["look"].startswith("28262b") and abs((n["box"][3] - n["box"][0]) - 0.49) < 1e-3)
record(len(panels) == 4 and all(c[0] < centre(n)[0] < c[1] and 0 < c[3] - centre(n)[2] < 0.12 for n in panels),
       "four black panels sit on the connector's south wall face", [centre(n) for n in panels])
lifts = find(lambda n: n["kind"] == "mesh" and close([n["box"][3] - n["box"][0], n["box"][4] - n["box"][1], n["box"][5] - n["box"][2]], [0.49, 2.7, 0.045], 1e-3))
five = find(lambda n: n["kind"] == "label" and n["look"] == "5")
record(len(lifts) == 2 and all(c[0] < centre(n)[0] < c[1] and 0 < centre(n)[2] - c[2] < 0.12 for n in lifts) and len(five) == 1 and 0 < centre(five[0])[2] - c[2] < 0.15,
       "lift doors and the '5' sit on the connector's north wall face, as in the baseline", {"lifts": [centre(n) for n in lifts], "five": [centre(n) for n in five]})
unverified("the '5' on the connector's north side is supported by IMG_6380 103.0 s (a large 5 on a pale surface on the purple side); the lift doors themselves are not seen in any frame reviewed here. "
           "The black south wall also carries a screen with a small 5, a black door, a fire pull and an extinguisher (101.6, 104.0, 240.3, 246.0 s), none of them built. Not part of this change.")
columns = find(lambda n: n["kind"] == "mesh" and close([n["box"][3] - n["box"][0], n["box"][4] - n["box"][1]], [0.36, 2.8], 2e-3))
col_z = sorted(round(centre(n)[2], 3) for n in columns)
record(len(columns) == 2 and all(g[2] + 0.3 < z < g[3] - 0.3 for z in col_z) and all(abs(centre(n)[0] - g[1]) < 0.01 for n in columns),
       "two free columns stand in the Ionic opening, clear of both ends", col_z)
unverified("column spacing: the delivery puts them at z %s (1.6 m from each end of a 6.0 m opening). The fit did not measure it; nothing here does either." % col_z)
leaves = find(lambda n: n["kind"] == "body" and close([n["box"][3] - n["box"][0], n["box"][4] - n["box"][1], n["box"][5] - n["box"][2]], [0.06, 2.7, 0.95], 1e-3) and g[0] < centre(n)[0] < g[1])
want = sorted([(4.51, round(north + 0.45, 3)), (6.59, round(north + 0.45, 3)), (4.51, 1.35), (6.59, 1.35)])
got = sorted((round(centre(n)[0], 2), round(centre(n)[2], 3)) for n in leaves)
record(got == want, "grey gallery door leaves: two at the piano door on the moved north wall, two at the Hall door", {"got": got, "want": want})
barn = [n for n in nodes if "barn" in n["look"].lower()]
record(not barn and flags.get("barn_painting_built") is False, "the barn painting is not built and is flagged as not built")
# Hall-door west leaf against the connector doorway: a visitor on the door axis must clear it.
west_leaf = [n for n in leaves if abs(centre(n)[0] - 4.51) < 0.01 and centre(n)[2] > 0]
if west_leaf:
    clearance = west_leaf[0]["box"][2] - ((door[0] + door[1]) / 2 + 0.22)
    out["tables"]["hall_door_leaf_vs_connector_axis"] = {"leaf_z_range": [west_leaf[0]["box"][2], west_leaf[0]["box"][5]], "door_clear_z": door, "visitor_edge_to_leaf_m": round(clearance, 3),
                                                         "leaf_overlaps_doorway_by_m": round(door[1] - west_leaf[0]["box"][2], 3), "leaf_stands_off_west_wall_m": round(west_leaf[0]["box"][0] - 3.85, 3)}
    record(clearance > 0, "a visitor walking the connector axis clears the Hall door's open west leaf (%.3f m)" % clearance)
# European gallery: the order along the west wall from the Rockefeller door must survive a partial shift.
euro = rooms_b[EURO]["bounds"]
order = [("secretary", find(lambda n: n["tag"] == "catalogue_asset=secretary" or "secretary" in n["look"])), ("Delacroix 35.786", find(lambda n: n["look"].endswith("painting-35.786.jpg"))),
         ("Fetti 36.003", find(lambda n: n["look"].endswith("painting-36.003.jpg"))), ("Goltzius 61.006", find(lambda n: n["look"].endswith("painting-61.006.jpg")))]
zs = [(name, round(min(centre(n)[2] for n in found), 3) if found else None) for name, found in order]
out["tables"]["european_west_wall_order_z"] = zs
present = [z for _, z in zs if z is not None]
record(present == sorted(present) and all(euro[2] < z < euro[3] for z in present) and len(present) >= 3, "European gallery west wall keeps the source order from the Rockefeller door and everything is inside the room", zs)
outside = []
for n in nodes:
    if n["tag"].startswith("wall=") or "floor_oak" in n["look"]:
        continue
    x, y, z = centre(n)
    if -5.55 < x < 0.55 and 1.8 - 0.9 < z < 1.8 + 0.02 and not (rooms_b[ROCK]["bounds"][0] < x < rooms_b[ROCK]["bounds"][1] and n["box"][5] <= 1.8 + 0.07):
        outside.append([n["kind"], n["look"], n["tag"], [round(v, 2) for v in (x, y, z)]])
out["tables"]["nodes_straddling_the_new_rockefeller_european_wall"] = outside
unverified("Fetti, both piers, Goltzius and the far door leaves keep their old z by the delivery's own choice; their distance from either end of the gallery is unmeasured in every source reviewed.")

# Vacated space: nothing authored may be left where the rooms used to be.
left = []
for n in nodes:
    x, y, z = centre(n)
    in_old_connector = 1.75 < x < 3.8 and -2.9 < z < -0.45
    north_of_rockefeller = -4.8 < x < 1.75 and z < -5.1
    north_of_grey = 3.8 < x < 12.7 and z < -4.3 and not (4.5 < x < 6.6 and z > -5.9)
    if in_old_connector or north_of_rockefeller or north_of_grey:
        left.append([n["kind"], n["look"], n["tag"], [round(v, 2) for v in (x, y, z)]])
record(not left, "nothing authored is left in the vacated connector slot or north of the moved Rockefeller and grey north walls", left[:8])

# Sight lines from the delivery's own source-view cameras (recorded; judged below as findings, not as pass/fail,
# because the camera positions are the implementer's approximations, not measured).
blocked = [s for s in after.get("sight_lines", []) if s["blocked_by"]]
out["tables"]["sight_lines"] = after.get("sight_lines", [])
out["tables"]["sight_lines_blocked"] = blocked
if after.get("sight_lines"):
    unverified("sight lines: %d of %d wall points that are in plain view in the two source frames are hidden by a door leaf from the delivery's own source-view cameras (camera positions are approximations): %s"
               % (len(blocked), len(after["sight_lines"]), sorted({(s["view"], s["wall_point"], s["blocked_by"]) for s in blocked})))

# 5. Walk trials.
if after.get("walk") and before.get("walk"):
    ra, rb = before["walk"]["results"], after["walk"]["results"]
    names = [k for k in rb if not k.endswith("_camera")]
    regress = [k for k in names if ra.get(k) is True and rb[k] is not True]
    fixed = [k for k in names if ra.get(k) is False and rb[k] is True]
    still = [k for k in names if ra.get(k) is False and rb[k] is not True]
    new_fail = [k for k in names if k not in ra and rb[k] is not True]
    rows_a = {r[0]: r for r in before.get("trial_rows", [])}
    changed = [r[0] for r in after.get("trial_rows", []) if r[0] in rows_a and rows_a[r[0]] != r]
    out["tables"]["walk"] = {"trials": len(names), "passed": sum(rb[k] is True for k in names), "regressions": regress, "newly_passing": fixed, "failing_before_and_after": still,
                             "new_trials_failing": new_fail, "rows_changed": changed, "final_positions_of_failures": {s["trial"]: [round(v, 2) for v in s["position"]] for s in after["walk"]["samples"] if rb.get(s["trial"]) is not True}}
    record(not regress and not new_fail, "walk: no trial that passed on the baseline fails on the delivery (%d of %d pass; %d rows re-aimed)" % (out["tables"]["walk"]["passed"], len(names), len(changed)),
           {"regressions": regress, "new_trials_failing": new_fail})
    if still:
        unverified("walk trials failing on the baseline and on the delivery alike (retained-Hall portal guard and similar): %s" % still)
    must = ["purple_grey_out", "purple_grey_back", "right_door_out", "right_door_back", "grey_piano_out", "grey_piano_back", "grey_ionic_out", "grey_ionic_back", "grey_grand_out", "grey_grand_back", "gallery_door_out", "gallery_door_back"]
    record(all(rb.get(k) is True for k in must), "walk: connector, Rockefeller east door, piano door, Ionic opening, Hall door and European door pass both ways", {k: rb.get(k) for k in must if rb.get(k) is not True})
    loop = [k for k in names if k.startswith("loop_")]
    record(loop and all(rb[k] is True or ra.get(k) is False for k in loop), "walk: every loop leg that passed on the baseline passes (%d of %d legs pass)" % (sum(rb[k] is True for k in loop), len(loop)), [k for k in loop if rb[k] is not True])
else:
    unverified("walk trials were not run for both builds")

# 6. Review cameras named in remodel_review.gd, as placed by that file's own moved().
va = {v["name"]: v for v in before.get("views", [])}
changed_views, bad = [], []
for v in after.get("views", []):
    old = va.get(v["name"])
    if old is not None and close(old["eye"], v["eye"], 1e-4) and close(old.get("target", []), v.get("target", []), 1e-4):
        continue
    changed_views.append(v["name"])
    x, y, z = v["eye"]
    inside = [r["label"] for r in after["rooms"] if r["bounds"][0] < x < r["bounds"][1] and r["bounds"][2] < z < r["bounds"][3]]
    row = {"name": v["name"], "new": old is None, "eye": [round(c, 2) for c in v["eye"]], "eye_room": inside, "eye_inside_bodies": v["eye_inside_bodies"]}
    if "target" in v:
        row.update(target=[round(c, 2) for c in v["target"]], first_hit=v["first_hit"], first_hit_fraction=v["first_hit_fraction"])
    out["tables"].setdefault("changed_review_views", []).append(row)
    if not inside or v["eye_inside_bodies"] or (y < 3.4 and "target" in v and v["first_hit_fraction"] < 0.5):
        bad.append(row)
if after.get("views"):
    record(len(changed_views) > 10 and not bad, "review cameras: each of the %d changed or new views stands inside a room, outside every solid, with a clear first half of its sight line" % len(changed_views), bad)
    unverified("review cameras were placed by arithmetic here too; nothing was rendered, so framing and what each view shows are not checked")
else:
    unverified("review cameras were not extracted")

# 7. Bake lights, when remodel_bake.gd was run headless on both projects (UV2 prepare only, no lightmap).
if len(sys.argv) > 6:
    def lights(path):
        import re
        rows = []
        for m in re.finditer(r'\[node name="([^"]+)" type="(OmniLight3D|SpotLight3D|LightmapProbe)"[^\]]*\]\n((?:(?!\n\[).)*)', Path(path).read_text(), re.S):
            t = re.search(r"transform = Transform3D\(([^)]*)\)", m.group(3))
            v = [float(q) for q in t.group(1).split(",")] if t else [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0]
            rows.append((m.group(2), [round(q, 3) for q in v[9:]]))
        return rows
    la, lb = lights(sys.argv[5]), lights(sys.argv[6])
    heights = {r["label"]: r.get("height", 3.5) for r in after["rooms"]}
    stray = []
    for kind, p in lb:
        homes = [r["label"] for r in after["rooms"] if r["bounds"][0] < p[0] < r["bounds"][1] and r["bounds"][2] < p[2] < r["bounds"][3]]
        if not homes or (kind == "OmniLight3D" and p[1] >= heights[homes[0]] and homes[0] not in (HALL,)):
            stray.append([kind, p, homes])
    moved_lights = Counter()
    pool = [list(x) + [False] for x in lb]
    for kind, p in la:
        hit = None
        for dz in [0.0, 2.2, 2.58, 0.8, 1.6]:
            for item in pool:
                if not item[2] and item[0] == kind and abs(item[1][0] - p[0]) < 2e-3 and abs(item[1][1] - p[1]) < 2e-3 and abs(item[1][2] - p[2] - dz) < 2e-3:
                    item[2], hit = True, dz
                    break
            if hit is not None:
                break
        moved_lights["%s | %s | %s" % (region(p), kind, "moved +%.2f z" % hit if hit is not None else "no match: " + str(p))] += 1
    out["tables"]["bake_lights"] = {"counts_before": dict(Counter(k for k, _ in la)), "counts_after": dict(Counter(k for k, _ in lb)), "moves": dict(moved_lights),
                                    "after_without_baseline_match": [[k, p] for k, p, used in pool if not used], "outside_every_room_or_above_ceiling": stray}
    record(not stray and Counter(k for k, _ in la) == Counter(k for k, _ in lb), "bake lights: same count of every kind as the baseline, each inside a room and below its ceiling", {"stray": stray})
    elsewhere_lights = [k for k in moved_lights if k.startswith("elsewhere") and "moved +0.00" not in k]
    record(not elsewhere_lights, "bake lights outside the changed rooms did not move", elsewhere_lights)
else:
    unverified("bake light positions were not read back")

out["summary"] = {"passed": len(out["passed"]), "failed": len(out["failed"]), "unverified": len(out["unverified"])}
Path(sys.argv[4]).write_text(json.dumps(out, indent=1) + "\n")
print(json.dumps(out["summary"]))
sys.exit(1 if out["failed"] else 0)
