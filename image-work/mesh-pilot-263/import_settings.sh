#!/usr/bin/env bash
# Godot's defaults make an imported mesh three to six times larger than it needs to be. After the first import of
# the GLBs in DIR, set: texture lossy at 0.8 (the repository's setting for catalogue photographs); no tangents (no
# normal map), no LODs, no shadow meshes (the rooms are lightmapped). Then import again.
# usage: import_settings.sh DIR
set -euo pipefail
for f in "$1"/*.jpg.import; do sed -i 's#^compress/mode=0#compress/mode=1#; s#^compress/lossy_quality=0.7#compress/lossy_quality=0.8#' "$f"; done
for f in "$1"/*.glb.import; do sed -i 's#^meshes/ensure_tangents=true#meshes/ensure_tangents=false#; s#^meshes/generate_lods=true#meshes/generate_lods=false#; s#^meshes/create_shadow_meshes=true#meshes/create_shadow_meshes=false#' "$f"; done
