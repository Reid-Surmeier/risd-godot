#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p build/web
godot --headless --editor --import --path . > build/import.log 2>&1
if rg -n 'ERROR|SCRIPT ERROR' build/import.log; then exit 1; fi
godot --headless --path . --export-release Web build/web/index.html > build/export.log 2>&1
if rg -n 'ERROR|SCRIPT ERROR' build/export.log; then exit 1; fi
cp camera.js build/web/camera.js
python3 - <<'PY'
from pathlib import Path
p=Path('build/web/index.html')
p.write_text(p.read_text().replace('</head>', '<script src="camera.js"></script></head>'))
PY
