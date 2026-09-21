#!/usr/bin/env bash
# Isolate actual module + fixture composition; never change the game's launch scene.
set -euo pipefail
cd "$(dirname "$0")/../../.."
mkdir -p build
stage=$(mktemp -d /tmp/risd-playground-stage.XXXXXX)
out="$PWD/build/playground-proof"
mkdir -p "$stage/modules/collection_data" "$out"
cp -R modules/playground_page "$stage/modules/"
cp modules/collection_data/*.gd "$stage/modules/collection_data/"
cp modules/playground_page/prototype/web-project.cfg "$stage/project.godot"
cp export_presets.cfg "$stage/"
godot --headless --path "$stage" --editor --import --quit > "$out/import.log" 2>&1
godot --headless --path "$stage" --export-release Web "$out/playground.html" > "$out/export.log" 2>&1
cp modules/playground_page/prototype/report.html "$out/index.html"
cp modules/playground_page/prototype/evidence/* "$out/"
printf '%s\n' "$out/playground.html"
