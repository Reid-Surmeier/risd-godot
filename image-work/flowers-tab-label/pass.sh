#!/usr/bin/env bash
# One paid Muse pass ($0.01), adapted from image-work/taskbar-pixel-tabs-loop/pass.sh (main checkout).
# ref1 = input-seven-tabs.png (compose.py); ref2 = the rebuilt taskbar's first tabs (icon and font style).
set -euo pipefail
root=$(cd "$(dirname "$0")" && pwd); d="$root/pass-${1:-01}"
mkdir -p "$d/references" "$d/review"
cp "$root/prompt.txt" "$d/edit-prompt.txt"
python3 - "$root/input-seven-tabs.png" "$root/style-left-tabs.png" "$d" <<'P'
import sys,hashlib,json
from PIL import Image
ref1,ref2,d=sys.argv[1:4]
def pad(src,dst):
    im=Image.open(src).convert('RGB'); h=round(im.height*2048/im.width)
    c=Image.new('RGB',(2048,256),'white'); c.paste(im.resize((2048,h),Image.LANCZOS),(0,(256-h)//2)); c.save(dst)
pad(ref1,d+'/references/edit-target.png'); pad(ref2,d+'/references/style.png')
names=["references/edit-target.png","references/style.png"]
h=lambda p:hashlib.sha256(open(d+'/'+p,'rb').read()).hexdigest()
json.dump({"attempts":[{"id":"001","prompt":"edit-prompt.txt","promptSha256":h('edit-prompt.txt'),"size":"2048x256",
 "inputs":[{"path":p,"sha256":h(p)} for p in names]}]},open(d+'/generation-preflight.json','w'),indent=2)
json.dump({"procedure":"edit","plan":"generation-preflight.json","attempt":"001"},open(d+'/recipe.json','w'))
P
cd "$d"
obj=$(~/Image-generation-pipline/bin/image-pipeline prepare --application . --recipe recipe.json --unit-cost 0.01 --budget 0.01 | python3 -c 'import json,sys;print(json.load(sys.stdin)["objective"])')
~/.claude/skills/access-bitwarden-secrets/scripts/stored_bws.sh run "OPENROUTER_API_KEY" OPENROUTER_API_KEY --alias "OpenRouter" -- \
  ~/Image-generation-pipline/bin/image-pipeline image --application . --objective "$obj" --execute > review/report.json 2> review/stderr.txt || { tail -5 review/stderr.txt; exit 3; }
python3 - "$d" <<'P'
import sys,json
from PIL import Image
d=sys.argv[1]; r=json.load(open(d+'/review/report.json')); print('cost',r['cost'],r['runId'])
im=Image.open(r['result'][0]['path']).convert('RGB'); im.save(d+'/review/full.png')
P
