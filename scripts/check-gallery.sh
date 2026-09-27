#!/usr/bin/env bash
# Rendered prototype checks; needs an X display, like scripts/playtest.sh.
set -euo pipefail
cd "$(dirname "$0")/.."
python3 modules/shell/prototype/gallery_walk4/bake/test_run.py
for harness in final_render_check visitor_check navigation_check dollhouse_shot shot; do
  godot --rendering-method gl_compatibility --path . \
    --script "res://modules/shell/prototype/gallery_walk4/$harness.gd" \
    -- --out-dir="${1:-/tmp/gallery-check}/$harness"
done
