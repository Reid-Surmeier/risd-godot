#!/usr/bin/env bash
# One paid Muse pass (0.01 USD): a catalogue photograph -> the same object, same viewpoint, alone on plain white.
# Call shape follows image-work/collection-room-remodel/european-case-passes/pass.sh.
# usage: muse_isolate.sh <key> <photo.jpg>     (write <key>/edit-prompt.txt first)
set -euo pipefail
root=$(cd "$(dirname "$0")" && pwd); key=$1; photo=$(realpath "$2"); d="$root/$key"
[ -f "$d/edit-prompt.txt" ] || { echo "write $d/edit-prompt.txt first"; exit 2; }
[ -f "$d/review/report.json" ] && { echo "$key: already run, not spending again"; exit 0; }
[ -d "$d/artifacts/image-generation/runs" ] && [ -n "$(ls "$d/artifacts/image-generation/runs")" ] && { echo "$key: a run record exists; inspect it, do not resubmit"; exit 4; }
mkdir -p "$d/references" "$d/review"
python3 - "$photo" "$d" <<'P'
import sys,hashlib,json
from PIL import Image
photo,d=sys.argv[1:3]
im=Image.open(photo).convert('RGB')
W,H=(1760,1440) if im.width/im.height>1.1 else (1440,1760)
s=min(W*0.92/im.width,H*0.92/im.height)
im=im.resize((round(im.width*s),round(im.height*s)),Image.LANCZOS)
c=Image.new('RGB',(W,H),'white'); c.paste(im,((W-im.width)//2,(H-im.height)//2)); c.save(d+'/references/catalogue.png')
h=lambda p:hashlib.sha256(open(d+'/'+p,'rb').read()).hexdigest()
json.dump({"attempts":[{"id":"001","prompt":"edit-prompt.txt","promptSha256":h('edit-prompt.txt'),"size":f"{W}x{H}",
 "inputs":[{"path":"references/catalogue.png","sha256":h('references/catalogue.png')}]}]},open(d+'/generation-preflight.json','w'),indent=2)
json.dump({"procedure":"edit","plan":"generation-preflight.json","attempt":"001"},open(d+'/recipe.json','w'))
P
cd "$d"
obj=$(~/Image-generation-pipline/bin/image-pipeline prepare --application . --recipe recipe.json --unit-cost 0.01 --budget 0.01 | python3 -c 'import json,sys;print(json.load(sys.stdin)["objective"])')
[ "${DRY:-}" = 1 ] && { echo "prepared objective $obj (DRY=1, nothing sent)"; exit 0; }
~/.claude/skills/access-bitwarden-secrets/scripts/stored_bws.sh run "OPENROUTER_API_KEY" OPENROUTER_API_KEY --alias "OpenRouter" -- \
  ~/Image-generation-pipline/bin/image-pipeline image --application . --objective "$obj" --execute > review/report.json 2> review/stderr.txt || { tail -5 review/stderr.txt; rm -f review/report.json; exit 3; }
python3 - "$d" "$key" <<'P'
import sys,json,hashlib
from PIL import Image
d,key=sys.argv[1:3]; r=json.load(open(d+'/review/report.json'))
Image.open(r['result'][0]['path']).convert('RGB').save(d+'/isolated.png')
print(key,'cost',r['cost'],r['runId'],hashlib.sha256(open(d+'/isolated.png','rb').read()).hexdigest())
P
