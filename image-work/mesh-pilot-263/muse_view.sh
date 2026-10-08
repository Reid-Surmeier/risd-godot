#!/usr/bin/env bash
# One paid Muse edit (0.01 USD): reference photograph(s) -> one view of the object, in the otani style.
# usage: muse_view.sh DIR KEY REF.jpg [REF2.jpg]      (write DIR/KEY.prompt.txt first; result DIR/KEY.png)
set -euo pipefail
d=$(realpath "$1"); key=$2; shift 2; app="$d/.muse-$key"
[ -f "$d/$key.png" ] && { echo "$key: already made"; exit 0; }
[ -d "$app/artifacts/image-generation/runs" ] && [ -n "$(ls "$app/artifacts/image-generation/runs")" ] && { echo "$key: a run record exists; inspect it, do not resubmit"; exit 4; }
mkdir -p "$app/references"; cp "$d/$key.prompt.txt" "$app/edit-prompt.txt"
python3 - "$app" "$@" <<'P'
import sys, hashlib, json
from PIL import Image
app, refs = sys.argv[1], sys.argv[2:]; W, H = 1440, 1760; inputs = []
for i, r in enumerate(refs):
    im = Image.open(r).convert('RGB'); s = min(W * 0.92 / im.width, H * 0.92 / im.height)
    im = im.resize((round(im.width * s), round(im.height * s)), Image.LANCZOS)
    c = Image.new('RGB', (W, H), 'white'); c.paste(im, ((W - im.width) // 2, (H - im.height) // 2)); p = f'references/ref-{i + 1}.png'; c.save(f'{app}/{p}')
    inputs.append({"path": p, "sha256": hashlib.sha256(open(f'{app}/{p}', 'rb').read()).hexdigest()})
h = hashlib.sha256(open(f'{app}/edit-prompt.txt', 'rb').read()).hexdigest()
json.dump({"attempts": [{"id": "001", "prompt": "edit-prompt.txt", "promptSha256": h, "size": f"{W}x{H}", "inputs": inputs}]}, open(f'{app}/generation-preflight.json', 'w'), indent=1)
json.dump({"procedure": "edit", "plan": "generation-preflight.json", "attempt": "001"}, open(f'{app}/recipe.json', 'w'))
P
cd "$app"
obj=$(~/Image-generation-pipline/bin/image-pipeline prepare --application . --recipe recipe.json --unit-cost 0.01 --budget 0.01 | python3 -c 'import json,sys;print(json.load(sys.stdin)["objective"])')
~/.claude/skills/access-bitwarden-secrets/scripts/stored_bws.sh run "OPENROUTER_API_KEY" OPENROUTER_API_KEY --alias "OpenRouter" -- \
  ~/Image-generation-pipline/bin/image-pipeline image --application . --objective "$obj" --execute > report.json 2> stderr.txt || { echo "$key FAILED: $(tail -2 stderr.txt)"; exit 3; }
python3 - "$app" "$d/$key.png" "$key" <<'P'
import sys, json, hashlib
from PIL import Image
app, out, key = sys.argv[1:4]; r = json.load(open(app + '/report.json'))
Image.open(r['result'][0]['path']).convert('RGB').save(out)
print(key, 'cost', r['cost'], r['runId'], hashlib.sha256(open(out, 'rb').read()).hexdigest()[:16])
P
