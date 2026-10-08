#!/usr/bin/env bash
# A generator's GLB -> a game mesh: lay the catalogue photograph over its front, then the Blender clean-up.
# usage: build_mesh.sh RAW.glb CUTOUT.png OUT.glb SIZE_PX [--no-photo] -- <prepare_mesh.py options: --height M [--wall-depth M] [--width M]>
# Prints project_photo.py's view line (turn, silhouette IoU) and prepare_mesh.py's record.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd); raw=$1; cut=$2; out=$3; size=$4; shift 4
photo=1; [ "${1:-}" = --no-photo ] && { photo=0; shift; }; [ "${1:-}" = -- ] && shift
tex=${out%.glb}.texture.png
# the view is found either way: it says which way the mesh faces
log=$(python3 "$here/project_photo.py" "$raw" "$cut" "$tex" --size "$size"); echo "$log" | grep -E "^view|^nudge|^repainted"
turn=$(echo "$log" | sed -n 's/^view: turn \([0-9]*\) deg.*/\1/p')
extra=(); [ "$photo" = 1 ] && extra=(--texture-image "$tex")
timeout 900 blender --background --factory-startup --python "$here/prepare_mesh.py" -- "$raw" "$out" --turn "$turn" --texture "$size" "${extra[@]}" "$@" 2>&1 | grep -E "^PREPARED|Error|Traceback|assert" | cut -c1-900
rm -f "$tex"
