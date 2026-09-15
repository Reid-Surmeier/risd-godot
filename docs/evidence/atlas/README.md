# atlas playtest evidence (build/v0.1.0, the Pixel Atlas desktop as the Map Tenant, filling the Page per #63)

Produced by `scripts/playtest.sh atlas` on Godot 4.7.2 (X display :99, OpenGL ES fallback, window 1920x1080, then 1440x900, then pages of 1920x1000 and 1440x820). The harness (`modules/atlas/playtest/harness.gd`) builds the Shell with the atlas in the Map Tab, drives it with real mouse and key events through `Input.parse_input_event`, and reaches the atlas only through `ShellInterface.tenant_state`. `modules/atlas/playtest/verify.py` re-hashes every screenshot, re-reads pixels and checks the logged states; `verify.json` is the verdict (78/78 pass), `report.json` the harness log.

The layout (owner correction #63): one uniform scale s = min(page / 1950x1280) for all the raster art; panels anchored to the page edges nearest them; the map window takes the leftover, running to the page's top and right edges minus the desktop's native margin.

- `01-map` — the 1920x1006 page, s 0.786: minimap 325x292 at (8, 57), itinerary 312x435 at (14, 350), chat 424x197 at (8, 808), notification 214x62 at (1703, 943), the map window 1563x749 at (354, 46) (native x s would be 910x750); nothing overlaps.
- `02-panel-moved` — the notification dragged 700x700 px onto the map body, now at (1003, 243) and on top; a wheel over it leaves the zoom alone.
- `03-zoomed`, `04-panned` — three wheel notches (x1.18^3) and a drag-pan.
- `05-window-moved` — a -70x15 px title-bar drag (frame at (284, 61)).
- `06-window-clamped` — a drag past the bottom-right corner stops flush with the page's edges.
- `07-window-resized` — the bottom-right corner dragged in: 1413x649, position kept, the map body following.
- `08-collapsed` — collapsed to the title bar. Then lock, keys (`+`, Right, F, F, Home): `09-key-home`.
- `10-before-hidden`, `11-hidden`, `12-resumed` — frozen while hidden (ticks, inputs, update mode 0, draw calls at the white-page count), pixel-identical on resume.
- `13-resized` — the 1440x900 window (page 1440x845): frame 1140x630 at (297, 38), panels re-anchored. `14-restored` — back at 1920x1080.
- `15-fill-1920x1000` — page 1920x1000: frame 1565x746 at (352, 45); the desktop's gaps to the page, left/top/right/bottom 8/45/3/0 px, all within the native margins x s.
- `15-fill-1440x820` — page 1440x820 (s 0.64): frame 1149x611 at (288, 37); gaps 6/37/3/0.5 px.
