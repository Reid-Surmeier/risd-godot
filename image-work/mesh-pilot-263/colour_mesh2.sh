#!/usr/bin/env bash
# The corrected colour pass: colour-matched views, cross-faded, unseen texels filled. Replaces colour_mesh.sh.
# usage: colour_mesh2.sh IN.glb VIEWS_DIR OUT.glb SIZE_PX [VIEW_SUFFIX=-cut-matched] [AO_STRENGTH=0.25] [VIEW_PREFIX=colour] ["view:turns:weight ..."]
# With flat-lit views (VIEW_PREFIX=flat) the occlusion baked from the high mesh is the only shading in the texture.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd); in=$1; views=$2; out=$3; size=$4; suf=${5:--cut-matched}; k=${6:-0.25}; pre=${7:-colour}; tex=${out%.glb}.colour.png; tmp=${out%.glb}.layer; layers=()
specs=${8:-"left:90,270:1 threequarter:30,45,60,300,315,330:1 back:180:1.5 front:0:2"}  # view:turns to try:weight, least trusted first
for spec in $specs; do
  IFS=: read -r v turns prio <<<"$spec"
  python3 "$here/project_photo.py" "$in" "$views/$pre-$v$suf.png" "$tmp-scratch.png" --size "$size" --turns "$turns" --no-flow --ramp 0.02,0.75 --layer "$tmp-$v" | grep -E "^view" | sed "s/^/$v: /"
  layers+=("$tmp-$v:$prio")
done
ao=${in%.glb}.ao.png; aoarg=(); [ -f "$ao" ] && aoarg=(--ao "$ao:$k")
python3 "$here/blend_views.py" "$tex" "${aoarg[@]}" "${layers[@]}"
for f in "$tmp"-*; do rm -f "$f"; done
LD_LIBRARY_PATH=/usr/lib/wsl/lib timeout 600 ~/apps/blender-5.2.2/blender-5.2.2-linux-x64/blender --background --factory-startup --python "$here/set_texture.py" -- "$in" "$tex" "$out" 2>&1 | grep -E "^TEXTURED|Error|assert"
