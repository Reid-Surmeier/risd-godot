#!/usr/bin/env bash
# Copies the live Web export to the CM3588, one folder per build, so a WSL crash cannot take the
# builds with it. Run after scripts/export-web.sh. Unchanged files are hard-linked to the last copy.
# usage: scripts/backup-build.sh
set -euo pipefail
cd "$(dirname "$0")/.."
SHA=$(grep -o 'url=[^"]*\.html' build/web/index.html | sed 's/^url=//; s/\.html$//')
DEST=/srv/dev-disk-by-uuid-80554d85-84c3-4b8a-b6a2-17b0bf09ad9c/Storage/risd-godot-builds
ssh -o ConnectTimeout=15 cm3588 "mkdir -p '$DEST/$SHA'"
rsync -a --partial --link-dest=../latest/ \
  --include="$SHA.*" --include=index.html --include='media/***' --include='flowers/***' --include='museum-images/***' --exclude='*' \
  build/web/ "cm3588:$DEST/$SHA/"
ssh cm3588 "cd '$DEST' && ln -sfn '$SHA' latest && echo \"backed up $SHA: \$(du -sh '$SHA' | cut -f1), \$(df -h . | tail -1 | awk '{print \$4}') free on the CM3588\""
