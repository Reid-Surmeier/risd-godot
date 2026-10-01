"""Build a LOCAL run copy of the full app whose Collection walk is main_build_walk.gd.

Run: python3 make_local_fullapp.py MAIN_BUILD EXTENSION ADAPTER OUTPUT
  MAIN_BUILD  the build/v0.1.0 checkout (read only; taken at its HEAD commit)
  EXTENSION   root's prepare_main_build_extension.py output (room project + Hall hashes)
  ADAPTER     main_build_walk.gd
  OUTPUT      new directory; must not exist

Nothing in MAIN_BUILD or EXTENSION is written. The copy leaves out docs/, image-work/,
build/ and repos/: the Web preset already excludes the first three and repos/ is read-only
vendored reference, so this is a run copy, not an export tree. Stdlib only.
"""
import argparse
import hashlib
import io
import json
from pathlib import Path
import re
import shutil
import subprocess
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
for name in ["main_build", "extension", "adapter", "output"]:
    parser.add_argument(name, type=Path)
args = parser.parse_args()
main, extension, adapter, out = (p.resolve() for p in [args.main_build, args.extension, args.adapter, args.output])
sha = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
git = lambda *command: subprocess.check_output(["git", "-C", str(main), *command])

tip = git("rev-parse", "HEAD").decode().strip()
reference = json.loads((extension / "main-build-source.json").read_text())
assert reference["source_tip"] == tip, "Room project was prepared against a different Hall commit"
left_out = {"docs", "image-work", "build", "repos"}
entries = [e for e in git("ls-tree", "--name-only", tip).decode().split() if e not in left_out]
out.mkdir(parents=True, exist_ok=False)
with tarfile.open(fileobj=io.BytesIO(git("archive", tip, *entries))) as snapshot:
    snapshot.extractall(out, filter="data")

# 1. The Hall in this copy is the Hall root snapshotted, file for file.
for relative, digest in reference["source_sha256"].items():
    assert sha(out / relative) == digest, relative

# 2. The room project goes under collection_rooms/: the app already has assets/ and web/.
rooms = out / "collection_rooms"
rooms.mkdir()
# Every root-level script and scene of the room project: remodel_room.tscn and whatever it loads.
scripts = sorted(p.name for p in extension.iterdir() if p.suffix in [".gd", ".tscn"])
assert {"doorway_walk.gd", "remodel_room.gd", "retained_hall_room.gd", "remodel_room.tscn"} <= set(scripts)
for name in scripts + ["geometry.json"]:
    shutil.copyfile(extension / name, rooms / name)
for folder in ["assets", "presentation", "textures", "addition_baked"]:
    shutil.copytree(extension / folder, rooms / folder, ignore=shutil.ignore_patterns("*.import", "*.uid"))
(rooms / "evidence").mkdir()  # the room scripts write their proofs here on native runs
# The native lightmap is binary and stores project-root texture paths. Let Godot
# serialize it as text before relocating paths; never edit binary resource bytes.
if (extension / "addition_baked/room.lmbake").exists():
    # EXR atlases must keep their Texture2DArray importer, rather than the default Texture2D.
    for metadata in (extension / "addition_baked").glob("*.exr.import"):
        (rooms / "addition_baked" / metadata.name).write_text(
            metadata.read_text().replace("res://addition_baked/", "res://collection_rooms/addition_baked/"))
    converter = Path(__file__).with_name("relocate_lightmap.gd")
    subprocess.run(["godot", "--headless", "--path", str(extension), "--script", str(converter),
                    "--", "res://addition_baked/room.lmbake", str(rooms / "addition_baked/room.tres")],
                   check=True, timeout=90)
    (rooms / "addition_baked/room.lmbake").unlink()
    for path in [rooms / "addition_baked/room.tscn", rooms / "addition_baked/room.tres"]:
        text = path.read_text().replace("room.lmbake", "room.tres")
        path.write_text(re.sub(r"res://(?!modules/)", "res://collection_rooms/", text))
    path = rooms / "remodel_room.gd"
    path.write_text(path.read_text().replace("addition_baked/room.lmbake", "addition_baked/room.tres"))
# The only source transformation: the room scripts' project-root paths move with them.
rewritten = {}
for name in scripts:
    text = (rooms / name).read_text()
    moved, count = re.subn(r"res://(?!modules/)", "res://collection_rooms/", text)
    (rooms / name).write_text(moved)
    rewritten[name] = {"paths_moved": count, "source_sha256": sha(extension / name), "sha256": sha(rooms / name)}
assert 'path="res://collection_rooms/retained_hall_room.gd"' in (rooms / "remodel_room.tscn").read_text()
assert not re.search(r"res://(?!modules/|collection_rooms/)", "".join((rooms / n).read_text() for n in scripts))

# 3. The adapter, and the one line of the composition root that loads the walk.
target = out / "modules/shell/prototype/collection_reconstruction/main_build_walk.gd"
target.parent.mkdir(parents=True, exist_ok=True)
shutil.copyfile(adapter, target)
demo = out / "modules/shell/demo.gd"
before = sha(demo)
old = 'load("res://modules/shell/prototype/gallery_walk4/walk4.gd").new()'
new = 'load("res://modules/shell/prototype/collection_reconstruction/main_build_walk.gd").new()'
text = demo.read_text()
assert text.count(old) == 1, "demo.gd no longer loads the walk on one line; review before substituting"
demo.write_text(text.replace(old, new))

# 4. Web preset of the copy: ship the room data files, not the native proofs.
presets = out / "export_presets.cfg"
text = presets.read_text()
anchor = "modules/shell/prototype/gallery_walk4/visitor/motion.json"
assert text.count(anchor + '"') == 1
text = text.replace(anchor + '"', anchor + ',collection_rooms/geometry.json,collection_rooms/assets/*.json"')
assert text.count('exclude_filter="docs/*,') == 1
presets.write_text(text.replace('exclude_filter="docs/*,', 'exclude_filter="collection_rooms/evidence/*,docs/*,'))

# 5. Still the same Hall after every edit above; demo.gd is the only changed tracked file.
for relative, digest in reference["source_sha256"].items():
    assert sha(out / relative) == digest, relative
blob = lambda data: hashlib.sha1(b"blob %d\0" % len(data) + data).hexdigest()
changed = []
for row in git("ls-tree", "-r", tip, *entries).decode().splitlines():
    meta, relative = row.split("\t", 1)
    mode, kind, digest = meta.split()
    if mode == "120000":  # a symlink: the archive carries it, compare where it points
        same = blob(str((out / relative).readlink()).encode()) == digest
    else:
        same = kind != "blob" or blob((out / relative).read_bytes()) == digest
    if not same:
        changed.append(relative)
assert changed == ["export_presets.cfg", "modules/shell/demo.gd"], changed
summary = {
    "main_build_tip": tip, "hall_files_unchanged": len(reference["source_sha256"]),
    "tracked_files_changed": changed, "demo_gd_sha256": {"before": before, "after": sha(demo)},
    "adapter_sha256": sha(target), "room_scripts": rewritten,
    "left_out": sorted(left_out), "production_collection_factory_integrated": False,
}
(rooms / "main-build-adapter.json").write_text(json.dumps(summary, indent=2) + "\n")
print(json.dumps(summary, indent=2))
