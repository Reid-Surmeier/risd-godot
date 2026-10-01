"""Attach the room prototype to the unchanged saved Main Hall, with a separate bake.

Run: python3 prepare_main_build_extension.py MAIN_REFERENCE OUTPUT
MAIN_REFERENCE is produced by prepare_main_build_reference.py.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("main_reference", type=Path)
parser.add_argument("output", type=Path)
args = parser.parse_args()
source = Path(__file__).resolve().parent
out = args.output.resolve()
reference = args.main_reference.resolve()
main = json.loads((reference / "main-build-source.json").read_text())
original_imports = {}
for relative, digest in main["source_sha256"].items():
    if relative.endswith(".import"):
        # Godot rewrites renderer-specific import metadata in the comparison project.
        data = subprocess.check_output(["git", "-C", main["source_worktree"], "show", main["source_tip"] + ":" + relative])
        assert hashlib.sha256(data).hexdigest() == digest, relative
        original_imports[relative] = data
    else:
        assert hashlib.sha256((reference / relative).read_bytes()).hexdigest() == digest, relative
subprocess.run([sys.executable, str(source / "prepare_remodel.py"), str(out)], check=True)
manifest = json.loads((out / "manifest.json").read_text())
for relative, digest in main["source_sha256"].items():
    target = out / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    if relative in original_imports:
        target.write_bytes(original_imports[relative])
    else:
        shutil.copyfile(reference / relative, target)
        manifest["source_sha256"][str(reference / relative)] = digest
shutil.copyfile(reference / "main-build-source.json", out / "main-build-source.json")
shutil.copyfile(source / "retained_hall_room.gd", out / "retained_hall_room.gd")

def replace_checked(path, old, new):
    text = path.read_text()
    assert old in text, (path, old)
    path.write_text(text.replace(old, new))

# Keep the original Hall's node names and baked assets outside the new-room bake.
replace_checked(out / "remodel_room.tscn", 'path="res://remodel_room.gd"', 'path="res://retained_hall_room.gd"')
replace_checked(out / "remodel_room.gd", 'if not visitor.is_ancestor_of(surface):', 'if not visitor.is_ancestor_of(surface) and not surface.has_meta("retained_main_hall"):')
replace_checked(out / "remodel_bake.gd", 'if walk.visitor.is_ancestor_of(source) or', 'if source.has_meta("retained_main_hall") or walk.visitor.is_ancestor_of(source) or')
original_bake = "res://modules/shell/prototype/gallery_walk4/baked/"
for relative in ["remodel_room.gd", "remodel_bake.gd", "bake/plugin.gd"]:
    replace_checked(out / relative, original_bake, "res://addition_baked/")
(out / "addition_baked").mkdir()
manifest["main_build_attachment"] = {
    "source_tip": main["source_tip"], "main_hall_rebuilt": False,
    "unchanged_files": len(main["source_sha256"]), "native_meshes": 139,
    "placeholder_meshes_hidden": [f"Surface{i:03d}" for i in range(6, 12)],
    "separate_room_bake": "addition_baked/room.tscn",
    "production_collection_factory_integrated": False,
}
for path in [source / "retained_hall_room.gd", Path(__file__).resolve()]:
    manifest["source_sha256"][str(path)] = hashlib.sha256(path.read_bytes()).hexdigest()
for relative, digest in main["source_sha256"].items():
    assert hashlib.sha256((out / relative).read_bytes()).hexdigest() == digest, relative
assert "retained_main_hall" in (out / "remodel_bake.gd").read_text()
(out / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
print(json.dumps(manifest["main_build_attachment"]))
