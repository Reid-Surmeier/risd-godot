#!/usr/bin/env bash
# One batch object after its Tripo Multi-View run finished: steps 4 to 11 of RECIPE.md, unshaded batch size.
# CUT="--keep-holes" keeps an opening that goes through the object open in the flat views' cut-outs.
# AO=0.5 raises the baked occlusion in the colour from its 0.35 (a pale relief against a pale wall).
# usage: finish_object.sh ACCESSION GLB_URL CHARGED SETTING(floor|plinth|wall) SIZE_PX "view:turns:weight ..." -- <clay_mesh.py size options>
# Writes the mesh to modules/shell/prototype/mesh_pilot/meshes/<accession>/ (replacing what is there), a sheet to
# docs/evidence/mesh-pilot-263/batch/<accession>.jpg, and PROVENANCE.md. Run from the repository root.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd); acc=$1; url=$2; charged=$3; setting=$4; size=$5; specs=$6; shift 7; name=${acc//./-}
d=$here/batch/$acc; tmp=/tmp/mp263/batch/$name; mkdir -p "$tmp" docs/evidence/mesh-pilot-263/batch; dir=modules/shell/prototype/mesh_pilot/meshes/$acc
B=~/apps/blender-5.2.2/blender-5.2.2-linux-x64/blender; source ~/promo-lab/gpu-env.sh; export DISPLAY=:99; godot=$HOME/.local/opt/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64
[ -f "$tmp/low.glb" ] || { curl -sS -m 600 -o "$tmp/raw.glb" "$url"; rawsha=$(sha256sum "$tmp/raw.glb" | cut -c1-64); echo "$rawsha" > "$tmp/raw.sha256"; }
[ -z "${PLAIN:-}" ] && for spec in $specs; do v=${spec%%:*}; python3 "$here/cut_photo.py" "$d/flat-$v.png" "$d/flat-$v-cut.png" 0,0,0,0 --key-white 14 ${CUT:-} >/dev/null; done
[ -z "${PLAIN:-}" ] && python3 "$here/match_colour.py" "$d/cut.png" "$d/flat-front-cut.png" -matched $(for spec in $specs; do echo "$d/flat-${spec%%:*}-cut.png"; done) | cut -c1-120
if [ ! -f "$tmp/low.glb" ]; then
  turn=$(python3 "$here/project_photo.py" "$tmp/raw.glb" "$d/flat-front-cut.png" x.png --view-only --turns "$(seq -s, 0 15 345)" | tee "$tmp/view.txt" | sed -n 's/^view: turn \([0-9.]*\) deg.*/\1/p'); tail -1 "$tmp/view.txt"
  [ -n "${TURN:-}" ] && { turn=$TURN; echo "turn forced to $TURN: a slab's silhouette is the same from the back, and Tripo's front has been at 90 every time"; }
  LD_LIBRARY_PATH=/usr/lib/wsl/lib timeout 1800 $B --background --factory-startup --python "$here/clay_mesh.py" -- "$tmp/raw.glb" "$tmp/low.glb" --turn "$turn" --low 10000 --maps 512 --unshaded "$@" 2>&1 | grep -E "^CLAY|Error|assert" | cut -c1-330
  cp "${tmp}/low.json" "$tmp/low.json" 2>/dev/null || true; rm -f "$tmp/raw.glb"
fi
place() {  # put a GLB in the mesh folder and import it clean with the lean settings
  if [ -d "$dir" ]; then for f in $(ls "$dir"); do case $f in PROVENANCE.md) ;; *) rm -f "${dir:?}/${f:?}";; esac; done; fi
  mkdir -p "$dir"; cp "$1" "$dir/$name.glb"; cp "$tmp/low.json" "$dir/$name.json"
  for f in .godot/imported/$name.glb-* .godot/imported/${name}_*; do rm -f "$f"; done
  timeout 900 "$godot" --headless --path . --import >/dev/null 2>&1 || true
  "$here/import_settings.sh" "$dir"; sed -i 's#^meshes/ensure_tangents=true#meshes/ensure_tangents=false#' "$dir/$name.glb.import"
  for f in .godot/imported/$name.glb-* .godot/imported/${name}_*; do rm -f "$f"; done
  timeout 900 "$godot" --headless --path . --import 2>&1 | grep -E "^ERROR" | head -2 || true
}
shot() { timeout 120 "$godot" --path . --rendering-driver opengl3 --resolution 960x642 res://modules/shell/prototype/mesh_pilot/pilot.tscn -- "res://$dir/$name.glb" "$setting" "$1" "$tmp/$1.png" unshaded 2>&1 | grep -E "ERROR|SCRIPT" | head -2 || true; }
if [ -n "${PLAIN:-}" ]; then  # plain white marble or porcelain: PLAIN="strength blur", no projected views
  [ -f "$tmp/pre.colour.png" ] && [ -f "$tmp/front.png" ] && [ ! -f "$tmp/front-projected.png" ] && cp "$tmp/front.png" "$tmp/front-projected.png"  # only when a projected colour was really built first
  python3 "$here/plain_colour.py" "$d/cut.png" "$tmp/low.ao.png" "$tmp/final.colour.png" "$size" $PLAIN
else
  POSE=$(python3 -c "import json,sys; l=json.load(open(sys.argv[1])); s=l['scale']; print(f\"{s['width_against_height']},{s['depth_against_height']},{l['lean_removed_deg']}\" if 'lean_removed_deg' in l else '')" "$tmp/low.json"); export POSE
  "$here/colour_mesh2.sh" "$tmp/low.glb" "$d" "$tmp/pre.glb" "$size" -cut-matched "${AO:-0.35}" flat "$specs" | grep -E "^[a-z]+: view|blended|Error" | cut -c1-110
  place "$tmp/pre.glb"; shot front
  python3 "$here/match_in_scene.py" "$d/cut.png" "$tmp/front.png" "$tmp/pre.colour.png" "$tmp/final.colour.png" | cut -c1-160
fi
LD_LIBRARY_PATH=/usr/lib/wsl/lib timeout 600 $B --background --factory-startup --python "$here/set_texture.py" -- "$tmp/low.glb" "$tmp/final.colour.png" "$tmp/final.glb" 2>&1 | grep -E "Error|assert" || true
place "$tmp/final.glb"; for v in front threequarter side; do shot $v; done
for y in 0 90 180; do :; done; (cd /tmp && CLAY=1 timeout 900 blender --background --factory-startup --python "$here/preview_mesh.py" -- "$tmp/low.glb" "$tmp/grey" 0,90,180 420 2>&1 | grep -E "Error" || true)
scn=$(stat -c%s .godot/imported/$name.glb-*.scn); tex=0; for f in .godot/imported/${name}_*.ctex; do tex=$((tex+$(stat -c%s "$f"))); done
PLAIN="${PLAIN:-}" AO="${AO:-0.35}" CLAY_VIEWS="${CLAY_VIEWS:-}" python3 - "$acc" "$name" "$d" "$tmp" "$dir" "$scn" "$tex" "$charged" "$specs" <<'P'
import sys, json, io, os, hashlib
from PIL import Image, ImageDraw, ImageFont
acc, name, d, tmp, dir_, scn, tex, charged, specs = sys.argv[1:10]; scn, tex = int(scn), int(tex); here = os.path.dirname(d.rstrip('/')).rsplit('/batch', 1)[0]
font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 13); h = 300; fit = lambda im: im.resize((max(1, im.width * h // im.height), h), Image.LANCZOS)
sz = json.load(open(f'{tmp}/low.json'))['size_m_width_height_depth']; wide = sz[0] > sz[1]  # a wide object needs wide crops
CC, GC, SC = ((40, 400, 1400, 1360), (0, 60, 420, 360), (150, 150, 810, 600)) if wide else ((250, 100, 1190, 1660), (80, 10, 340, 410), (270, 30, 690, 610))
views = json.load(open(f'{d}/views.json'))['views']; made = json.load(open(f'{d}/made.json')); order = os.environ.get('CLAY_VIEWS', '').split() or [s.split(':')[0] for s in specs.split()][::-1]  # CLAY_VIEWS: clay views to show when the mesh used more than the colour did
cells = [('Catalogue photograph', fit(Image.open(os.path.expanduser(views['front']['file'])).convert('RGB')))]
cells += [(f'Clay: {v}' + ('' if 'photograph' in made[f'clay-{v}']['from'] else ' (inferred)'), fit(Image.open(f'{d}/clay-{v}.png').convert('RGB').crop(CC))) for v in order]
cells += [(f'Grey mesh: {n}', fit(Image.open(f'{tmp}/grey-{y}.png').convert('RGB').crop(GC))) for y, n in (('000', 'front'), ('090', 'side'), ('180', 'back'))]
if os.path.exists(f'{tmp}/front-projected.png') and os.environ.get('PLAIN'): cells += [('Projected colour (rejected)', fit(Image.open(f'{tmp}/front-projected.png').convert('RGB').crop(SC)))]
cells += [(f'Coloured, unshaded: {n}', fit(Image.open(f'{tmp}/{v}.png').convert('RGB').crop(SC))) for v, n in (('front', 'front'), ('threequarter', '3/4'))]
rows = [cells[:4], cells[4:]] if wide else [cells]; W = max(sum(c.width + 6 for _, c in r) for r in rows); s = Image.new('RGB', (W, (h + 22) * len(rows)), 'white'); dr = ImageDraw.Draw(s)
for j, r in enumerate(rows):
    x = 0
    for label, im in r: dr.text((x + 2, 4 + j * (h + 22)), label, fill='black', font=font); s.paste(im, (x, 22 + j * (h + 22))); x += im.width + 6
if W > 1800: s = s.resize((1800, s.height * 1800 // W), Image.LANCZOS)
b = io.BytesIO(); s.save(b, 'JPEG', quality=86, optimize=True); open(f'docs/evidence/mesh-pilot-263/batch/{acc}.jpg', 'wb').write(b.getvalue())
low = json.load(open(f'{tmp}/low.json')); o = json.load(open(f'{here}/batch/objects.json')); mf = o[acc]['muse_first']; run = mf['run']; run['charged'] = float(charged)
if os.path.exists(f'{tmp}/raw.sha256'): run['sha256'] = open(f'{tmp}/raw.sha256').read().strip()
mf['imported'] = {'mesh': scn, 'colour': tex, 'total': scn + tex}; json.dump(o, open(f'{here}/batch/objects.json', 'w'), indent=1, ensure_ascii=False)
rj = mf.get('rejected_run'); rejected = f"| Rejected mesh | {rj['model']}, run `{rj['id']}`; views {rj['views']}. {rj['why']} | quoted {rj['quote']:.2f}, charged {rj['charged']:.2f} USD |\n" if rj else ''
n_muse = len(made); sha = hashlib.sha256(open(f'{dir_}/{name}.glb', 'rb').read()).hexdigest()
rows = '\n'.join(f"| `{k}` | {v['from']}{'; ' + v['note'] if v.get('note') else ''} |" for k, v in made.items())
text = f"""# {acc} {o[acc]['title'].split('*')[1]}

{o[acc]['title']} RISD Museum {acc}.

Made on the Muse-first route (`image-work/mesh-pilot-263/RECIPE.md`), 8 October 2026. Not placed in a room.

| Step | What | Cost |
| --- | --- | --- |
| References | the museum's catalogue photographs, deep-zoom source at up to 2400 px, in `~/risd-godot-ingestion/catalogue-masters/{acc}/` (outside git); which photograph backs which view: `image-work/mesh-pilot-263/batch/{acc}/views.json` | free |
| Muse views | {n_muse} images (OpenRouter, `meta/muse-image`): clay and flat colour, prompts in `image-work/mesh-pilot-263/batch/{acc}/` | {n_muse * 0.01:.2f} USD |
| Mesh | Flora, RISD EDU Workspace, {run['model']}, {run['params']}; views {mf['views']}; run `{run['id']}`; raw GLB `{run.get('sha256', '')[:16]}…` ({low['raw_triangles']:,} triangles, not kept) | quoted {run['quote']:.2f}, charged {float(charged):.2f} USD |
{rejected}| Blender 5.2.2 | `clay_mesh.py`: reduced to {low['triangles']:,} triangles, occlusion baked from the high mesh; made {low['as_made_m_at_catalogue_height']['width']} m wide and {low['as_made_m_at_catalogue_height']['depth']} m deep at the catalogue height, {('after a ' + str(low['lean_removed_deg']) + '° lean was rotated out (`--upright`), ') if 'lean_removed_deg' in low else ''}set to {low['size_m_width_height_depth']} m (width, height, depth){'. ' + mf['size_note'] if mf.get('size_note') else ''} | free |
| Colour | {'`plain_colour.py`: one base colour from the lit areas of the catalogue photograph, with the baked occlusion blurred (strength and blur: ' + os.environ['PLAIN'] + '); no projected views, which streaked this white object' if os.environ.get('PLAIN') else '`colour_mesh2.sh`: flat views matched to the photograph, cross-faded, occlusion ' + os.environ['AO'] + (' (the sides and back, which the one view never shows, take the median colour of the front)' if len(specs.split()) == 1 else '') + '; `match_in_scene.py` lift for unshaded drawing'} | free |

| View | Came from |
| --- | --- |
{rows}

`{name}.glb` (`{sha[:16]}…`): {low['triangles']:,} triangles, one colour texture, no normal map, for drawing unshaded. In the pack: {(scn + tex) // 1024} KB (mesh {scn // 1024}, colour {tex // 1024}).
"""
open(f'{dir_}/PROVENANCE.md', 'w').write(text); print(f"DONE {acc}: {low['triangles']} triangles, {low['size_m_width_height_depth']} m, in the pack {(scn + tex) // 1024} KB (mesh {scn // 1024}, colour {tex // 1024}); sheet docs/evidence/mesh-pilot-263/batch/{acc}.jpg {b.tell() // 1024} KB")
P
