#!/usr/bin/env bash
# Exports the game (the shell main scene) for the Web under a name unique to the commit, so a browser can never
# serve a stale cached build: build/web/<sha>.{html,js,pck,wasm} plus an index.html that
# forwards to it. The build's sha is in the page title. The five videos go beside it under media/
# (the Web video player downloads each on first play; they are not in the .pck). The Flowers Tab's
# SWFs and self-hosted Ruffle go beside it under flowers/ (modules/flowers_page/web). The page's own
# .pck is only the loading scene (preset "Web"); the game is <sha>.game.pck (preset "Web Game"),
# which modules/shell/boot_loader.gd downloads and mounts. The .wasm and both packs get a .gz twin:
# the page and the loading scene fetch those and unzip them in the browser.
# The build is made in build/web-next and swapped in only when complete, and the build that was
# live stays beside the new one: a page already loading it (or its cached index.html) can finish.
set -euo pipefail
cd "$(dirname "$0")/.."
GODOT_BIN="${GODOT_BIN:-$HOME/.local/opt/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64}"
SHA=$(git rev-parse --short HEAD)$( [ -n "$(git status --porcelain --untracked-files=no)" ] && echo "-dirty" || true )
export DISPLAY="${GODOT_DISPLAY:-${DISPLAY:-:99}}"; unset WAYLAND_DISPLAY
OUT=build/web; NEXT=build/web-next
rm -rf "$NEXT" && mkdir -p "$NEXT/media"
"$GODOT_BIN" --headless --path . --export-release "Web" "$NEXT/$SHA.html" 2>&1 | grep -E 'ERROR' || true
"$GODOT_BIN" --headless --path . --export-pack "Web Game" "$NEXT/$SHA.game.pck" 2>&1 | grep -E 'ERROR' || true
sed -i "s|<title>[^<]*</title>|<title>risd-godot shell build $SHA</title>|" "$NEXT/$SHA.html"
# The pack is the whole download: it went 120 -> 450 MB in five days unseen. Raise the budget on purpose, never by drift.
MB=$(( $(stat -c%s "$NEXT/$SHA.game.pck") / 1048576 )); echo "game pack: $MB MB (budget ${PACK_BUDGET_MB:=260} MB)"
[ "$MB" -le "$PACK_BUDGET_MB" ] || { echo "game pack over budget: import big textures lossy, or raise PACK_BUDGET_MB and say why"; exit 1; }
cat > "$NEXT/index.html" <<HTML
<!doctype html><meta charset="utf-8"><meta http-equiv="Cache-Control" content="no-store"><meta http-equiv="refresh" content="0; url=$SHA.html"><title>risd-godot shell build $SHA</title><a href="$SHA.html">build $SHA</a>
HTML
# Full zoom photographs are fetched only when their painting opens (#278).
mkdir -p "$NEXT/museum-images"
cp modules/shell/prototype/gallery_walk4/zoom/*.jpg "$NEXT/museum-images/"
cp modules/shell/assets/impressionist/zoom/*.jpg "$NEXT/museum-images/"
cp modules/video_player/media/*.ogv "$NEXT/media/"
cp -r modules/flowers_page/web "$NEXT/flowers" && rm -f "$NEXT/flowers/.gdignore"  # the Flowers game and its Ruffle build
for f in "$NEXT/$SHA".{wasm,pck,game.pck}; do gzip -9 -k -f "$f"; done
LIVE=$(grep -o 'url=[^"]*\.html' "$OUT/index.html" 2>/dev/null | sed 's/^url=//; s/\.html$//' || true)
if [ -n "$LIVE" ] && [ "$LIVE" != "$SHA" ]; then cp -n "$OUT/$LIVE".* "$NEXT/" 2>/dev/null || true; fi
rm -rf "$OUT" && mv "$NEXT" "$OUT"
echo "exported build $SHA -> $OUT/$SHA.html (kept $LIVE beside it)"
