#!/usr/bin/env bash
# One paid Muse pass ($0.01): a museum photograph -> one low polygon front view on magenta.
# Follows image-work/flowers-tab-label/pass.sh and the prompt of image-work/collection-room-remodel/*-prompt.txt.
# usage: pass.sh <key> <photo.jpg> <accession> <title> <material words for the texture>
set -euo pipefail
root=$(cd "$(dirname "$0")" && pwd); key=$1; photo=$2; accession=$3; title=$4; material=$5
d="$root/$key"
[ -f "$d/review/report.json" ] && { echo "$key: already run, not spending again"; exit 0; }
mkdir -p "$d/references" "$d/review"
cat > "$d/edit-prompt.txt" <<P
Reference 1 is the official RISD Museum photograph of $title, accession $accession. It is the sole design authority. Generate ONE complete front view of this exact object alone, facing the same direction as the reference, isolated on flat pure magenta #FF00FF with generous margins. Transform the photographed object into a clean low polygon game model: large flat planar facets, restrained readable $material texture and baked soft shading. Preserve its exact pose, silhouette, extremities, base, handles and ornament placement, and the distinct reference colours. Keep every handle, foot, lid, spout, rim and limb visible. Remove the photograph's grey studio backdrop, table surface and cast shadow entirely. Do not add any other object, prop, platform, floor, shadow beyond its silhouette, label or text. Do not rotate the subject relative to this reference. One view only, no sheet. This supplies UV colours for separately authored low polygon volume geometry.
P
python3 - "$photo" "$d" <<'P'
import sys,hashlib,json
from PIL import Image
photo,d=sys.argv[1:3]
im=Image.open(photo).convert('RGB')
W,H=(1760,1440) if im.width/im.height>1.1 else (1440,1760)
s=min(W*0.86/im.width,H*0.86/im.height)
im=im.resize((round(im.width*s),round(im.height*s)),Image.LANCZOS)
c=Image.new('RGB',(W,H),'white'); c.paste(im,((W-im.width)//2,(H-im.height)//2)); c.save(d+'/references/catalogue.png')
h=lambda p:hashlib.sha256(open(d+'/'+p,'rb').read()).hexdigest()
json.dump({"attempts":[{"id":"001","prompt":"edit-prompt.txt","promptSha256":h('edit-prompt.txt'),"size":f"{W}x{H}",
 "inputs":[{"path":"references/catalogue.png","sha256":h('references/catalogue.png')}]}]},open(d+'/generation-preflight.json','w'),indent=2)
json.dump({"procedure":"edit","plan":"generation-preflight.json","attempt":"001"},open(d+'/recipe.json','w'))
P
cd "$d"
obj=$(~/Image-generation-pipline/bin/image-pipeline prepare --application . --recipe recipe.json --unit-cost 0.01 --budget 0.01 | python3 -c 'import json,sys;print(json.load(sys.stdin)["objective"])')
~/.claude/skills/access-bitwarden-secrets/scripts/stored_bws.sh run "OPENROUTER_API_KEY" OPENROUTER_API_KEY --alias "OpenRouter" -- \
  ~/Image-generation-pipline/bin/image-pipeline image --application . --objective "$obj" --execute > review/report.json 2> review/stderr.txt || { tail -5 review/stderr.txt; rm -f review/report.json; exit 3; }
python3 - "$d" "$key" <<'P'
import sys,json
from PIL import Image
d,key=sys.argv[1:3]; r=json.load(open(d+'/review/report.json')); print(key,'cost',r['cost'],r['runId'])
Image.open(r['result'][0]['path']).convert('RGB').save(d+'/review/full.png')
P
