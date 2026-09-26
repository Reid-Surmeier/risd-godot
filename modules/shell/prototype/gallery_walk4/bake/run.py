#!/usr/bin/env python3
"""Bake the prototype room using the installed Godot editor; restore project settings."""
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[5]
prepare = 'res://modules/shell/prototype/gallery_walk4/bake/prepare.gd'
project = root / 'project.godot'
original = project.read_text()
if '[editor_plugins]' in original:
    raise SystemExit('Existing editor plugin configuration: enable gallery bake plugin explicitly.')
baked = root / 'modules/shell/prototype/gallery_walk4/baked'
previous = {path: path.read_bytes() if path.exists() else None
            for path in (baked / name for name in ('room.tscn', 'room.lmbake', 'room.exr', 'room.exr.import'))}
try:
    subprocess.run(['godot', '--path', str(root), '--rendering-method', 'gl_compatibility', '--script', prepare], check=True, timeout=120)
    project.write_text(original + '\n[editor_plugins]\nenabled=PackedStringArray("res://modules/shell/prototype/gallery_walk4/bake/plugin.cfg")\n')
    subprocess.run(['godot', '--editor', '--path', str(root), '--rendering-method', 'mobile', '--max-fps', '10'], check=True, timeout=600)
except BaseException:
    for path, content in previous.items():
        if content is None:
            path.unlink(missing_ok=True)
        else:
            path.write_bytes(content)
    raise
finally:
    project.write_text(original)
