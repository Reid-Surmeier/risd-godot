#!/usr/bin/env bash
# Regenerates modules/shell/collection_rooms/ from its sources: room project, lightmap bake, relocation, install.
# The steps and their traps are in docs/research/2026-10-01-museum-room-pipeline-runbook.md.
# usage: scripts/rebuild_rooms.sh [--draft]     --draft stops before the bake and leaves the
#        unbaked room project for looking at; nothing in the repo changes.
# Needs gallery_walk4 committed (the Hall snapshot is taken from HEAD), DISPLAY=:99, about 2 GB.
set -euo pipefail
# One rebuild on the host at a time: the bake is CPU-only under WSL, and eight at once took the load to 81 (2 Oct).
exec 9>/tmp/risd-rebuild-rooms.lock; flock 9
cd "$(dirname "$0")/.."
CK=$PWD
SRC=$CK/modules/shell/prototype/collection_reconstruction
T=${ROOMS_TRIAL:-/home/reidsurmeier/risd-godot-ingestion/collection-expansion/rebuild-$(git rev-parse --short HEAD)}
EXT=$T/extension
SW="env DISPLAY=:99 LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe"
LVP="$SW VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.json"
[ "$(df --output=avail -BG / | tail -1 | tr -dc 0-9)" -ge 20 ] || { echo "under 20 GB free: not rebuilding"; exit 3; }
rm -rf "$T" && mkdir -p "$T"
/usr/bin/python3 "$SRC/prepare_main_build_reference.py" "$CK" "$T/reference"
/usr/bin/python3 "$SRC/prepare_main_build_extension.py" "$T/reference" "$EXT"
godot --headless --editor --import --path "$EXT" > "$T/import.log" 2>&1
godot --headless --path "$EXT" --script "$SRC/architecture_check.gd" 2>&1 | grep "ARCHITECTURE_CHECK" || { echo "architecture check failed: see the room project at $EXT"; exit 1; }
if [ "${1:-}" = "--draft" ]; then echo "draft room project: $EXT"; exit 0; fi
$SW godot --path "$EXT" --display-driver x11 --rendering-method gl_compatibility --script res://remodel_bake.gd 2>&1 | grep "BAKE_PREPARE"
godot --path "$EXT" --headless --editor --import > /dev/null 2>&1
# The windowed editor can abort in its accessibility layer; a prime that died leaves the bake to fail
# 25 minutes later when it saves its atlas, so the layer is off and a dead prime stops the run here.
$LVP godot --path "$EXT" --editor --accessibility disabled --rendering-method mobile --quit-after 120 res://addition_baked/room.tscn > "$T/prime.log" 2>&1 || true
if grep -q "panicked" "$T/prime.log"; then echo "the prime step crashed: $T/prime.log; run again"; exit 1; fi
godot --path "$EXT" --headless --editor --import > /dev/null 2>&1
cp "$EXT/project.godot" "$T/project.godot.original"
printf '\n[editor_plugins]\nenabled=PackedStringArray("res://bake/plugin.cfg")\n' >> "$EXT/project.godot"
timeout 1700 $LVP godot --path "$EXT" --editor --accessibility disabled --rendering-method mobile > "$T/bake.log" 2>&1 || true
cp "$T/project.godot.original" "$EXT/project.godot"
grep "BAKE_OK" "$T/bake.log" || { echo "bake failed: $T/bake.log"; exit 1; }
/usr/bin/python3 "$SRC/relocate_rooms.py" "$EXT" "$T/collection_rooms"
# objects.json and representation.json are authored in the repo, not generated: keep them across the install.
rsync -a --delete --exclude='*.import' --exclude='*.uid' --exclude='objects.json' --exclude='representation.json' --exclude='assets/details/' "$T/collection_rooms/" "$CK/modules/shell/collection_rooms/"
godot --headless --editor --import --path "$CK" > "$T/repo-import.log" 2>&1
git -C "$CK" status --short modules/shell/collection_rooms | head -20
echo "installed; room project kept at $EXT (delete $T when done)"
