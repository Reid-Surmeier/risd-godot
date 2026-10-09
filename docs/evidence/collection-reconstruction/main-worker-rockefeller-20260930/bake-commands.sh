#!/bin/bash
set -euo pipefail
remodel_output=/home/reidsurmeier/risd-godot-ingestion/collection-expansion/lowpoly-room-v12
godot_bin=/home/reidsurmeier/.local/opt/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64
env -u LIBGL_ALWAYS_SOFTWARE GALLIUM_DRIVER=d3d12 MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA LD_LIBRARY_PATH=/usr/lib/wsl/lib DISPLAY=:0 "$godot_bin" --display-driver x11 --rendering-method gl_compatibility --path "$remodel_output" --script res://remodel_bake.gd > /tmp/remodel-v12-prepare.log 2>&1
python3 - <<'PY'
from pathlib import Path
p=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/lowpoly-room-v12/project.godot');p.write_text(p.read_text()+'\n[editor_plugins]\nenabled=PackedStringArray("res://bake/plugin.cfg")\n')
PY
VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json DISPLAY=:99 "$godot_bin" --display-driver x11 --editor --rendering-method mobile --max-fps 10 --path "$remodel_output" modules/shell/prototype/gallery_walk4/baked/room.tscn > /tmp/remodel-v12-bake.log 2>&1
rg 'BAKE_OK users=149' /tmp/remodel-v12-bake.log
python3 - <<'PY'
from pathlib import Path
p=Path('/home/reidsurmeier/risd-godot-ingestion/collection-expansion/lowpoly-room-v12/project.godot');s=p.read_text();s=s[:s.index('[editor_plugins]')];s=s.replace('renderer/rendering_method="mobile"','renderer/rendering_method="gl_compatibility"').replace('renderer/rendering_method="forward_plus"','renderer/rendering_method="gl_compatibility"');p.write_text(s)
PY
