"""Snapshot the existing Main Hall for comparison without rebuilding its geometry.

Run: python3 prepare_main_build_reference.py MAIN_BUILD OUTPUT
Then run its existing world_176_capture.gd against OUTPUT.
"""
import argparse
import hashlib
import io
import json
from pathlib import Path
import subprocess
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("main_build", type=Path)
parser.add_argument("output", type=Path)
args = parser.parse_args()
source = args.main_build.resolve()
out = args.output.resolve()
paths = ["modules/shell/prototype/gallery_walk4", "modules/shell/assets/collection_frame/page.png"]
tip = subprocess.check_output(["git", "-C", str(source), "rev-parse", "HEAD"], text=True).strip()
assert not subprocess.check_output(["git", "-C", str(source), "diff", "HEAD", "--", *paths]), "Main Hall has uncommitted tracked changes; retain them and choose a reviewed source"
archive = subprocess.check_output(["git", "-C", str(source), "archive", tip, *paths])
out.mkdir(parents=True, exist_ok=False)
with tarfile.open(fileobj=io.BytesIO(archive)) as snapshot:
    snapshot.extractall(out, filter="data")
hashes = {str(p.relative_to(out)): hashlib.sha256(p.read_bytes()).hexdigest()
          for p in out.rglob("*") if p.is_file()}
for relative, digest in hashes.items():
    assert hashlib.sha256((source / relative).read_bytes()).hexdigest() == digest, relative
(out / "evidence").mkdir()
(out / "project.godot").write_text(
    'config_version=5\n[application]\nconfig/name="Existing Main Hall reference"\n'
    'run/main_scene="res://modules/shell/prototype/gallery_walk4/doorway_prototype.tscn"\n'
    '[display]\nwindow/size/viewport_width=1600\nwindow/size/viewport_height=1600\n'
    '[rendering]\nrenderer/rendering_method="gl_compatibility"\n')
(out / "main-build-source.json").write_text(json.dumps({
    "source_worktree": str(source), "source_tip": tip,
    "source_sha256": hashes, "main_hall_rebuilt": False,
    "comparison_capture": "modules/shell/prototype/gallery_walk4/world_176_capture.gd",
    "viewer_included": False,
}, indent=2) + "\n")
assert len(hashes) > 100 and not (out / "modules/sculpture_viewer").exists()
print(json.dumps({"output": str(out), "tip": tip, "unchanged_files": len(hashes)}))
