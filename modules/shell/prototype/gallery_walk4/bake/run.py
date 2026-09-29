#!/usr/bin/env python3
"""Bake the prototype room using the installed Godot editor; restore project settings."""
from pathlib import Path
import subprocess
import argparse
import re
import threading

root = Path(__file__).resolve().parents[5]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--white', action='store_true', help='Bake the separate white navigation-room capture.')
name = 'white' if parser.parse_args().white else 'room'
prepare = 'res://modules/shell/prototype/gallery_walk4/bake/' + ('white_prepare.gd' if name == 'white' else 'prepare.gd')
project = root / 'project.godot'
original = project.read_text()
if '[editor_plugins]' in original:
    raise SystemExit('Existing editor plugin configuration: enable gallery bake plugin explicitly.')
baked = root / 'modules/shell/prototype/gallery_walk4/baked'
previous = {path: path.read_bytes() if path.exists() else None
            for path in (baked / (name + ext) for ext in ('.tscn', '.lmbake', '.exr', '.exr.import'))}
try:
    subprocess.run(['godot', '--path', str(root), '--rendering-method', 'gl_compatibility', '--script', prepare], check=True, timeout=120)
    project.write_text(original + '\n[gallery_bake]\nscene="' + name + '"\n\n[editor_plugins]\nenabled=PackedStringArray("res://modules/shell/prototype/gallery_walk4/bake/plugin.cfg")\n')
    command = ['godot', '--editor', '--path', str(root), '--rendering-method', 'mobile', '--max-fps', '10',
               'res://modules/shell/prototype/gallery_walk4/baked/' + name + '.tscn']
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    deadline = threading.Timer(1800, process.kill)
    deadline.start()
    saved = False
    try:
        for line in process.stdout:
            print(line, end='', flush=True)
            # Emitted only after the plugin validates users and saves the scene.
            saved |= re.fullmatch(r'BAKE_OK users=[1-9][0-9]*\n?', line) is not None
        code = process.wait()
    finally:
        deadline.cancel()
        if process.poll() is None:
            process.kill()
            process.wait()
    if not saved:
        raise RuntimeError(f'Editor exited {code} without a saved bake')
    if code:
        print(f'BAKE_EDITOR_EXIT {code} after save; retained outputs require rendered verification')
except BaseException:
    for path, content in previous.items():
        if content is None:
            path.unlink(missing_ok=True)
        else:
            path.write_bytes(content)
    raise
finally:
    project.write_text(original)
