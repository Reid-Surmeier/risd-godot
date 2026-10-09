#!/usr/bin/env bash
# CPU-only scratch check: bash run_check.sh [root checkout holding the helpers and the inventory]
# 1. prep.py --verify: ledger and video hashes, every texture rebuilt from its source and compared byte for byte.
# 2. check.gd in a throwaway Godot project on Mesa llvmpipe: closure, finite bounds, catalogue size, hardware fit, mapping, flags, negative controls, views.
# 3. make_compare.py: the comparison sheets. Exits non-zero if any step fails. Writes only into this folder.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
root=${1:-/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction}
helpers=modules/shell/prototype
asset=${ASSET:-$here/renaissance_wall_assets.gd} # ASSET=<file> runs a sabotaged copy for a negative control
python3 "$here/prep.py" --verify "$root"
scratch=$(mktemp -d "${TMPDIR:-/tmp}/renaissance-wall-check.XXXXXX")
trap 'rm -rf "$scratch"' EXIT
touch "$scratch/project.godot"
# Same layout as the repository, so the asset's relative preloads resolve as they will once the root installs it.
mkdir -p "$scratch/$helpers/gallery_walk4" "$scratch/$helpers/collection_reconstruction"
cp "$here/check.gd" "$scratch/"
cp "$root/$helpers/collection_reconstruction/seated_woman_asset.gd" "$scratch/$helpers/collection_reconstruction/"
cp "$asset" "$scratch/$helpers/collection_reconstruction/renaissance_wall_assets.gd"
cp "$root/$helpers/gallery_walk4/painting_asset.gd" "$root/$helpers/gallery_walk4/ps1.gdshader" "$scratch/$helpers/gallery_walk4/"
# The machine's shared Xvfb; a private one cannot start inside the worker sandbox. Wayland is blocked so nothing opens on the desktop.
# A script error leaves Godot idling, so the run is stopped after five minutes and counts as failed.
env WAYLAND_DISPLAY=unavailable DISPLAY="${CHECK_DISPLAY:-:99}" LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe timeout 300 godot --display-driver x11 \
  --rendering-driver opengl3_es --rendering-method gl_compatibility --path "$scratch" -s check.gd -- "${OUT:-$here}" "$here/textures/"
[ -n "${OUT:-}" ] || python3 "$here/make_compare.py" "$root"
