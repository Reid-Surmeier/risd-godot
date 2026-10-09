# Movable, proportional scan windows — #192

Runtime `8694316e`. The player, selection panel, Global Chatroom and friends panel drag and raise independently. Every bottom-right grip scales its whole window uniformly, with a minimum size and a desktop fit limit. Adjusted placement survives page fitting and tab changes. Focus loss cancels active gestures.

The chat and friends panels remain their existing display-only raster content, cropped at runtime from the existing setup image through AtlasTexture. No model/raster generation or spend. Scan orbit/zoom and card selection retain their input paths. The transient hover preview follows its card.

- `native/`: initial, adjusted and page-resized screenshots from real InputEvent drags. All four windows shrink/grow, move and raise; X/Y scales stay equal. Selection/orbit, retained placement and focus-loss cancellation pass (`native.log`).
- `module/`: unchanged module acceptance harness/verifier; 20 selections, metadata, animated hover, hidden input, return and pixel checks.
- `web/`: complete exported app; real browser drags on all four windows. Player/panel rects independently verify proportional shrink/grow/move; scan selection/orbit, tab return and narrow-screen fit checked. Chat/friends movement reviewed in screenshots and asserted natively.
- `baseline.log`: repository checks. Existing ObjectDB shutdown warning remains.

Run:

```bash
DISPLAY=:99 godot --path . --rendering-method gl_compatibility --script res://modules/sculpture_viewer/playtest/window_resize_check.gd -- --out-dir=/tmp/scan-windows
node docs/evidence/scan-windows-192/browser.cjs http://127.0.0.1:8787/8694316e.html /tmp/scan-windows-web
scripts/check.sh
git diff --check
```
