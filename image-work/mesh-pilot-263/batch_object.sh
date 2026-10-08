#!/usr/bin/env bash
# One batch object, after its paid run finished: fetch the GLB, build the accepted mesh, write PROVENANCE.md,
# render a review sheet. Reads batch/objects.json. Run from the repository root.
# usage: batch_object.sh ACCESSION GLB_URL CHARGED_USD [SETTING=plinth|wall] [NOTE]
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd); acc=$1; url=$2; charged=$3; setting=${4:-plinth}; note=${5:-}; name=${acc//./-}
dl=/tmp/mp263/dl/$name; mkdir -p "$dl" /tmp/mp263/batch
[ -f "$dl/raw.glb" ] || curl -sS -m 300 -o "$dl/raw.glb" "$url"
read -r photo size opts < <(python3 -c "
import json; o=json.load(open('$here/batch/objects.json'))['$acc']; print('' if o['photo'] else '--no-photo', o['size'], o['prepare'])" | sed 's/^ /- /')
[ "$photo" = - ] && photo=""
log=$("$here/accept_mesh.sh" "$acc" "$dl/raw.glb" "$here/batch/$acc/cut.png" "$size" $photo -- $opts); echo "$log"
python3 - "$here/batch/objects.json" "$acc" "$charged" "$dl/raw.glb" "$(echo "$log" | grep '^view' | sed 's/^view: //')" <<'P'
import json, sys, hashlib
f, acc, charged, glb, view = sys.argv[1:6]; o = json.load(open(f))
o[acc]["run"].update(charged=float(charged), sha256=hashlib.sha256(open(glb, "rb").read()).hexdigest(), view=view)
json.dump(o, open(f, "w"), indent=1, ensure_ascii=False); open(f, "a").write("\n")
P
python3 "$here/write_provenance.py" "$acc" "$note"
source ~/promo-lab/gpu-env.sh; export DISPLAY=:99; godot=$HOME/.local/opt/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64
for v in front threequarter side; do timeout 120 "$godot" --path . --rendering-driver opengl3 --resolution 960x642 res://modules/shell/prototype/mesh_pilot/pilot.tscn -- "res://modules/shell/prototype/mesh_pilot/meshes/$acc/$name.glb" "$setting" $v "/tmp/mp263/batch/$name-$v.png" 2>&1 | grep -E "ERROR|SCRIPT" | head -2 || true; done
python3 - "$name" "$here/batch/$acc/cut-preview.jpg" <<'P'
import sys
from PIL import Image
name, cut = sys.argv[1:3]
ims = [Image.open(cut).convert('RGB').resize((400, 400))] + [Image.open(f'/tmp/mp263/batch/{name}-{v}.png').convert('RGB').crop((130, 0, 830, 642)).resize((436, 400)) for v in ('front', 'threequarter', 'side')]
s = Image.new('RGB', (sum(i.width for i in ims), 400)); x = 0
for i in ims: s.paste(i, (x, 0)); x += i.width
s.save(f'/tmp/mp263/batch/{name}-sheet.jpg', quality=85); print('sheet', f'/tmp/mp263/batch/{name}-sheet.jpg')
P
