#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../../.."
probe=$(mktemp -d /tmp/risd-search-probe.XXXXXX)
trap 'rm -rf "$probe"' EXIT
export_path="$PWD/build/web-search-probe/index.html"
mkdir -p build/web-search-probe
while IFS= read -r file; do
  cp --parents "$file" "$probe"
done < <(find modules/collection_data -type f \( -name '*.gd' -o -name '*.tscn' \))
cp --parents testing/interface.gd testing/errors.gd testing/collection_data_test.gd "$probe"
cat > "$probe/project.godot" <<'PROJECT'
config_version=5
[application]
config/name="RISD search connection probe"
run/main_scene="res://modules/collection_data/playtest/probe.tscn"
[display]
window/size/viewport_width=1440
window/size/viewport_height=972
[rendering]
renderer/rendering_method="gl_compatibility"
PROJECT
cp export_presets.cfg "$probe/export_presets.cfg"
godot --headless --path "$probe" --editor --quit
godot --headless --path "$probe" --export-release Web "$export_path"
