#!/usr/bin/env bash
# CPU-only scratch check: bash run_check.sh [root checkout holding seated_woman_asset.gd]
# Builds a throwaway Godot project from the two helpers, renders with Mesa llvmpipe on Xvfb, exits with Godot's code.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/../../../.." && pwd)
root=${1:-/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction}
helpers=modules/shell/prototype/collection_reconstruction
scratch=$(mktemp -d "${TMPDIR:-/tmp}/medieval-metal-check.XXXXXX")
touch "$scratch/project.godot"
cp "$root/$helpers/seated_woman_asset.gd" "$repo/$helpers/medieval_metal_assets.gd" "$here/check.gd" "$scratch/"
trap 'rm -rf "$scratch"' EXIT
# The machine's shared Xvfb; a private one cannot start inside the worker sandbox. Wayland is blocked so nothing opens on the desktop.
env WAYLAND_DISPLAY=unavailable DISPLAY="${CHECK_DISPLAY:-:99}" LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe godot --display-driver x11 \
  --rendering-driver opengl3_es --rendering-method gl_compatibility --path "$scratch" -s check.gd -- "$here"
