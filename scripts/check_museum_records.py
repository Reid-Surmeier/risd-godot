#!/usr/bin/env python3
"""The museum's two recorded lists, checked without Godot. Run from scripts/check.sh.

1. The representation floor (modules/shell/collection_rooms/representation.json). Every work
   declares what it is in the museum and how the build shows it. A volume shown as a flat card,
   an extruded photograph, a one-view blob, a box or another object's mesh is below the floor; so
   is a relief whose face is a flat photograph. The works below it must be exactly the
   `shortfalls` list, and that list may never hold a key it did not hold when it was first
   committed: it only shrinks.
2. Acceptance records (modules/shell/prototype/collection_reconstruction/acceptance.json). Each
   says what was measured, from what, who reviewed it and at which commit, and names an evidence
   file that exists. architecture_check.gd matches the records to the flags in the room code.

Whether the declarations describe the built scene is representation_check.gd's half.
"""
import collections
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MANIFEST = "modules/shell/collection_rooms/representation.json"
ACCEPTANCE = "modules/shell/prototype/collection_reconstruction/acceptance.json"
FORMS = ["flat", "relief", "volume"]
KINDS = ["flat", "extruded_photo", "one_view_blob", "box", "profile", "modelled", "stand_in_mesh", "mesh"]
BELOW = {
    "flat": [],
    "relief": ["flat", "extruded_photo", "box", "stand_in_mesh"],
    "volume": ["flat", "extruded_photo", "one_view_blob", "box", "stand_in_mesh"],
}
RECORD_FIELDS = ["value", "measured_from", "evidence", "reviewed_by", "commit"]


def git(*args):
    return subprocess.run(["git", "-C", str(ROOT), *args], capture_output=True, text=True)


def floor(manifest, first_list):
    """Failures for one manifest; `first_list` is the shortfall list as first committed, or None."""
    failures = []
    objects = manifest["objects"]
    for key, row in objects.items():
        if row.get("form") not in FORMS or row.get("as") not in KINDS or not row.get("room"):
            failures.append(f"{key}: needs a room, a form in {FORMS} and an as in {KINDS}")
    below = sorted(k for k, row in objects.items() if row.get("as") in BELOW.get(row.get("form"), []))
    listed = manifest["shortfalls"]
    if len(set(listed)) != len(listed):
        failures.append("shortfalls lists a key twice")
    for key in sorted(set(below) - set(listed)):
        row = objects[key]
        failures.append(f"{key}: a {row['form']} shown as {row['as']} is below the floor; make it a mesh (it may not be added to shortfalls)")
    for key in sorted(set(listed) - set(below)):
        failures.append(f"{key}: listed as a shortfall but no longer below the floor; take it off the list")
    if first_list is not None:
        for key in sorted(set(listed) - set(first_list)):
            failures.append(f"{key}: added to shortfalls; the list only shrinks")
    return failures, below


def first_committed_list():
    """The shortfall list in the commit that first added the manifest; None before any commit."""
    added = git("log", "--diff-filter=A", "--format=%H", "--", MANIFEST).stdout.split()
    if not added:
        return None
    shown = git("show", f"{added[-1]}:{MANIFEST}")
    return json.loads(shown.stdout)["shortfalls"] if shown.returncode == 0 else None


def acceptance(records):
    failures = []
    for key, record in records.items():
        missing = [name for name in RECORD_FIELDS if not str(record.get(name, "")).strip()]
        if missing:
            failures.append(f"acceptance {key}: missing {', '.join(missing)}")
            continue
        path = record["evidence"]
        if not (ROOT / path).is_file() and git("cat-file", "-e", f"HEAD:{path}").returncode != 0:
            failures.append(f"acceptance {key}: evidence {path} is not in the repository")
        if git("cat-file", "-e", f"{record['commit']}^{{commit}}").returncode != 0:
            failures.append(f"acceptance {key}: reviewed commit {record['commit']} is not in the repository")
    return failures


def self_test():
    """The rule on four made-up works: the smallest thing that fails if the rule breaks."""
    objects = {
        "slab": {"room": "r", "form": "volume", "as": "extruded_photo"},
        "mesh": {"room": "r", "form": "volume", "as": "mesh"},
        "carving": {"room": "r", "form": "relief", "as": "flat"},
        "canvas": {"room": "r", "form": "flat", "as": "flat"},
    }
    assert floor({"objects": objects, "shortfalls": ["carving", "slab"]}, ["carving", "slab"]) == ([], ["carving", "slab"])
    assert len(floor({"objects": objects, "shortfalls": ["slab"]}, None)[0]) == 1  # a new shortfall, not listed
    assert len(floor({"objects": objects, "shortfalls": ["carving", "mesh", "slab"]}, None)[0]) == 1  # fixed, still listed
    assert len(floor({"objects": objects, "shortfalls": ["carving", "slab"]}, ["slab"])[0]) == 1  # the list grew
    assert acceptance({"x.placement_accepted": {"value": "0.43 m"}})  # a record without its evidence


def main():
    self_test()
    manifest = json.loads((ROOT / MANIFEST).read_text())
    failures, below = floor(manifest, first_committed_list())
    records = json.loads((ROOT / ACCEPTANCE).read_text())["records"]
    failures += acceptance(records)
    objects = manifest["objects"]
    rooms = collections.Counter(objects[key]["room"] for key in below)
    in_code = sum(1 for row in objects.values() if row.get("form") != "flat" and row.get("as") in ["profile", "modelled"])
    print("REPRESENTATION_FLOOR " + json.dumps({
        "works": len(objects), "shortfalls": len(below), "by_room": dict(rooms.most_common()),
        "meshes": sum(1 for row in objects.values() if row.get("as") == "mesh"),
        "modelled_or_turned_in_code": in_code}))
    print("ACCEPTANCE_RECORDS " + json.dumps({"records": len(records)}))
    for line in failures:
        print("museum records: " + line)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
