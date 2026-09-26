#!/usr/bin/env python3
"""Bake the prototype room using the installed Godot editor; restore project settings."""
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[5]
prepare = 'res://modules/shell/prototype/gallery_walk4/bake/prepare.gd'
subprocess.run(['godot', '--path', str(root), '--rendering-method', 'gl_compatibility', '--script', prepare], check=True, timeout=120)
project = root / 'project.godot'
original = project.read_text()
if '[editor_plugins]' in original:
    raise SystemExit('Existing editor plugin configuration: enable gallery bake plugin explicitly.')
try:
    project.write_text(original + '\n[editor_plugins]\nenabled=PackedStringArray("res://modules/shell/prototype/gallery_walk4/bake/plugin.cfg")\n')
    subprocess.run(['godot', '--editor', '--path', str(root), '--rendering-method', 'mobile', '--max-fps', '10'], check=True, timeout=600)
finally:
    project.write_text(original)
