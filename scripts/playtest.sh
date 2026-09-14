#!/usr/bin/env bash
# Plays one module's playtest harness with real input on an X display and verifies the run independently.
# usage: scripts/playtest.sh <module> [out-dir]     (module: tab_strip | shell | atlas | collection_page)
set -euo pipefail
cd "$(dirname "$0")/.."
MODULE="${1:?usage: scripts/playtest.sh <module> [out-dir]}"
[ -f "modules/$MODULE/playtest/harness.gd" ] || { echo "no playtest harness for module '$MODULE'"; exit 2; }
GODOT_BIN="${GODOT_BIN:-$HOME/.local/opt/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64}"
OUT="${2:-$(mktemp -d "/tmp/$MODULE-playtest-XXXXXX")}"; mkdir -p "$OUT"
export DISPLAY="${GODOT_DISPLAY:-${DISPLAY:-:99}}"
unset WAYLAND_DISPLAY
"$GODOT_BIN" --path . --script "res://modules/$MODULE/playtest/harness.gd" \
  --display-driver x11 --rendering-driver opengl3 -- "--out-dir=$OUT" 2>&1 | tee "$OUT/godot.log" | grep -vE '^\s*$' | tail -20
if grep -qiE "SCRIPT ERROR|^ERROR" "$OUT/godot.log"; then echo "Godot reported errors, see $OUT/godot.log"; exit 1; fi
python3 "modules/$MODULE/playtest/verify.py" "$OUT"
echo "evidence: $OUT"
