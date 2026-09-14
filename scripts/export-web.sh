#!/usr/bin/env bash
# Exports the game (the shell main scene) for the Web under a name unique to the commit, so a browser can never
# serve a stale cached build: build/web/<sha>.{html,js,pck,wasm} plus an index.html that
# forwards to it. The build's sha is in the page title.
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT_BIN="${GODOT_BIN:-$HOME/.local/opt/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64}"
SHA=$(git rev-parse --short HEAD)$( [ -n "$(git status --porcelain --untracked-files=no)" ] && echo "-dirty" || true )
export DISPLAY="${GODOT_DISPLAY:-${DISPLAY:-:99}}"; unset WAYLAND_DISPLAY
mkdir -p build/web && rm -f build/web/*
"$GODOT_BIN" --headless --path . --export-release "Web" "build/web/$SHA.html" 2>&1 | grep -E 'ERROR' || true
sed -i "s|<title>[^<]*</title>|<title>risd-godot shell build $SHA</title>|" "build/web/$SHA.html"
cat > build/web/index.html <<HTML
<!doctype html><meta charset="utf-8"><meta http-equiv="Cache-Control" content="no-store"><meta http-equiv="refresh" content="0; url=$SHA.html"><title>risd-godot shell build $SHA</title><a href="$SHA.html">build $SHA</a>
HTML
echo "exported build $SHA -> build/web/$SHA.html"
