#!/usr/bin/env bash
# Build one accepted mesh into modules/shell/collection_rooms/assets/meshes/<accession>/, import it with the lean
# settings, and print what it costs in the pack. Run from the repository root.
# usage: accept_mesh.sh ACCESSION RAW.glb CUTOUT.png SIZE_PX [--no-photo] -- <prepare_mesh.py options>
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd); acc=$1; shift; name=${acc//./-}
dir=modules/shell/collection_rooms/assets/meshes/$acc; mkdir -p "$dir"
"$here/build_mesh.sh" "$1" "$2" "$dir/$name.glb" "${@:3}" | grep -E "^view|^repainted|Error|Traceback|assert" || true
[ -f "$dir/$name.glb" ] || { echo "no mesh written"; exit 1; }
source ~/promo-lab/gpu-env.sh; export DISPLAY=:99; godot=$HOME/.local/opt/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64
rm -f "$dir"/*.import "$dir"/*.jpg  # a rebuild: let Godot write the texture out afresh
for f in .godot/imported/$name.glb-*; do rm -f "$f"; done
timeout 900 "$godot" --headless --path . --import >/dev/null 2>&1 || true
"$here/import_settings.sh" "$dir"
for f in .godot/imported/$name.glb-* .godot/imported/${name}_*.jpg-*; do rm -f "$f"; done  # Godot does not always notice the changed settings
timeout 900 "$godot" --headless --path . --import 2>&1 | grep -E "^ERROR|SCRIPT ERROR" | head -3 || true
scn=$(stat -c%s .godot/imported/$name.glb-*.scn); tex=$(stat -c%s .godot/imported/${name}_*.jpg-*.ctex)
python3 - "$dir/$name.json" "$scn" "$tex" <<'P'
import json, sys
f, scn, tex = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]); r = json.load(open(f))
r["imported"] = {"mesh_bytes": scn, "texture_bytes": tex, "total_bytes": scn + tex}; json.dump(r, open(f, "w"), indent=1); open(f, "a").write("\n")
o = r["out"]; print(f"ACCEPTED {f}: {o['triangles']} triangles, {o['size_m_width_height_depth']} m, glb {o['bytes'] // 1024} KB, imported {(scn + tex) // 1024} KB ({scn // 1024} + {tex // 1024})")
P
