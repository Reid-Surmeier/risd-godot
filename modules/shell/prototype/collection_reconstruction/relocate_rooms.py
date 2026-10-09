"""Turn a baked room project into a modules/shell/collection_rooms/ folder with adapted res:// paths.

Run: python3 relocate_rooms.py EXTENSION OUTPUT
  EXTENSION  baked output of prepare_main_build_extension.py (read only)
  OUTPUT     new directory that becomes modules/shell/collection_rooms/; must not exist

Section 2 of make_local_fullapp.py without the full-app copy, for a tree that already
tracks modules/shell/collection_rooms/. relocate_lightmap.gd must sit beside this file. Stdlib only.
"""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

extension, rooms = (Path(p).resolve() for p in sys.argv[1:3])
sha = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
move = lambda text: re.sub(r"res://(?!modules/)", "res://modules/shell/collection_rooms/", text)
scripts = sorted(p.name for p in extension.iterdir() if p.suffix in [".gd", ".tscn"])
assert {"doorway_walk.gd", "remodel_room.gd", "retained_hall_room.gd", "remodel_room.tscn"} <= set(scripts)
assert (extension / "addition_baked/room.lmbake").exists(), "Bake the room project first"
rooms.mkdir()
for name in scripts + ["geometry.json"]:
    shutil.copyfile(extension / name, rooms / name)
for folder in ["assets", "presentation", "textures", "addition_baked"]:
    shutil.copytree(extension / folder, rooms / folder, ignore=shutil.ignore_patterns("*.import", "*.uid"))
# EXR atlases must keep their Texture2DArray importer, rather than the default Texture2D.
for metadata in (extension / "addition_baked").glob("*.exr.import"):
    (rooms / "addition_baked" / metadata.name).write_text(
        metadata.read_text().replace("res://addition_baked/", "res://modules/shell/collection_rooms/addition_baked/"))
# Godot serializes the binary lightmap as text; the headless dummy renderer would drop the probes.
env = dict(os.environ, DISPLAY=":99", LIBGL_ALWAYS_SOFTWARE="1", GALLIUM_DRIVER="llvmpipe")
subprocess.run(["godot", "--display-driver", "x11", "--rendering-method", "gl_compatibility",
                "--path", str(extension), "--script", str(Path(__file__).with_name("relocate_lightmap.gd")),
                "--", "res://addition_baked/room.lmbake", str(rooms / "addition_baked/room.tres")],
               check=True, timeout=90, env=env)
(rooms / "addition_baked/room.lmbake").unlink()
for path in [rooms / "addition_baked/room.tscn", rooms / "addition_baked/room.tres"]:
    path.write_text(move(path.read_text().replace("room.lmbake", "room.tres")))
path = rooms / "remodel_room.gd"
path.write_text(path.read_text().replace("addition_baked/room.lmbake", "addition_baked/room.tres"))
rewritten = {}
for name in scripts:
    moved, count = re.subn(r"res://(?!modules/)", "res://modules/shell/collection_rooms/", (rooms / name).read_text())
    (rooms / name).write_text(moved)
    rewritten[name] = {"paths_moved": count, "source_sha256": sha(extension / name), "sha256": sha(rooms / name)}
assert 'path="res://modules/shell/collection_rooms/retained_hall_room.gd"' in (rooms / "remodel_room.tscn").read_text()
assert not re.search(r"res://(?!modules/|modules/shell/collection_rooms/)", "".join((rooms / n).read_text() for n in scripts))
reference = json.loads((extension / "main-build-source.json").read_text())
summary = {"main_build_tip": reference["source_tip"], "hall_files_unchanged": len(reference["source_sha256"]),
           "room_scripts": rewritten, "relocated_by": "relocate_rooms.py"}
(rooms / "main-build-adapter.json").write_text(json.dumps(summary, indent=2) + "\n")
print(json.dumps({k: v["paths_moved"] for k, v in rewritten.items()}))
