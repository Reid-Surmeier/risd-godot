#!/usr/bin/env bash
# CPU-only scratch check: bash run_check.sh [root checkout]
# Throwaway Godot project from the root's two helper copies plus the new helper; Mesa llvmpipe on the shared Xvfb :99; exits with Godot's code.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/../../../.." && pwd)
root=${1:-/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction}
helpers=modules/shell/prototype/collection_reconstruction
scratch=$(mktemp -d "${TMPDIR:-/tmp}/medieval-pair-check.XXXXXX")
trap 'rm -rf "$scratch"' EXIT
touch "$scratch/project.godot"
cp "$root/$helpers/seated_woman_asset.gd" "$root/$helpers/medieval_metal_assets.gd" "$repo/$helpers/medieval_ceramic_ivory_assets.gd" "$here/check.gd" "$here"/decal-queens-*.png "$scratch/"
# Wayland is blocked so nothing opens on the desktop; software GL only, no Vulkan, no RTX.
env WAYLAND_DISPLAY=unavailable DISPLAY="${CHECK_DISPLAY:-:99}" LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe godot --display-driver x11 \
  --rendering-driver opengl3_es --rendering-method gl_compatibility --path "$scratch" -s check.gd -- "$here"
