#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p build/web
godot --headless --editor --import --path . > build/import.log 2>&1
if rg -n 'ERROR|SCRIPT ERROR' build/import.log; then exit 1; fi
godot --headless --path . --export-release Web build/web/index.html > build/export.log 2>&1
if rg -n 'ERROR|SCRIPT ERROR' build/export.log; then exit 1; fi
cp camera.js controls.js build/web/
cp assets/camera-frame.png build/web/camera-frame.png
cp tracking-worker.js build/web/tracking-worker.js
mkdir -p build/web/tracking
cp tracking/vision_bundle.js tracking/face_landmarker.task tracking/LICENSE tracking/pins.json build/web/tracking/
cp -r tracking/wasm build/web/tracking/
python3 - <<'PY'
from pathlib import Path
from hashlib import sha256
p=Path('build/web/index.html')
controls_version=sha256(Path('controls.js').read_bytes()).hexdigest()[:12]
text=p.read_text().replace('</head>', f'<script src="camera.js"></script><script src="controls.js?v={controls_version}"></script></head>')
text=text.replace('user-scalable=no, ','')
p.write_text(text)
PY
