#!/usr/bin/env bash
# Lay Muse colour views onto a mesh made by clay_mesh.py (front already at glTF +Z), one view at a time, then put
# the painted texture into the GLB. The views most to be trusted go on last and win where views overlap.
# No optical-flow nudge here: the mesh starts in one flat colour, so there is nothing for the photograph to be matched to
# (with the nudge on, the first try came out streaked).
# usage: colour_mesh.sh IN.glb VIEWS_DIR OUT.glb SIZE_PX      (VIEWS_DIR holds colour-{left,threequarter,back,front}-cut.png)
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd); in=$1; views=$2; out=$3; size=$4; tex=${out%.glb}.colour.png; prev=()
for spec in "left:90,270" "threequarter:30,45,60,300,315,330" "back:180" "front:0"; do
  v=${spec%%:*}; turns=${spec##*:}
  python3 "$here/project_photo.py" "$in" "$views/colour-$v-cut.png" "$tex" --size "$size" --turns "$turns" --no-flow "${prev[@]}" | grep -E "^view|^repainted" | sed "s/^/$v: /"
  prev=(--atlas "$tex")
done
ao=${in%.glb}.ao.png
[ -f "$ao" ] && python3 - "$tex" "$ao" <<'P'
import sys, numpy as np
from PIL import Image
tex, ao = sys.argv[1:3]; c = np.array(Image.open(tex).convert('RGB')).astype(float); a = np.array(Image.open(ao).convert('L').resize(c.shape[1::-1], Image.LANCZOS)).astype(float) / 255
Image.fromarray((c * (0.75 + 0.25 * a[..., None])).clip(0, 255).astype('uint8')).save(tex); print('occlusion: folded into the colour at 25 %')
P
LD_LIBRARY_PATH=/usr/lib/wsl/lib timeout 600 ~/apps/blender-5.2.2/blender-5.2.2-linux-x64/blender --background --factory-startup --python "$here/set_texture.py" -- "$in" "$tex" "$out" 2>&1 | grep -E "^TEXTURED|Error|assert"
