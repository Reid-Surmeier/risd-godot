---
name: atlas
purpose: The Pixel Atlas as the Map Tab's Tenant — one draggable, resizable, collapsible map window on the Page's white desktop, whose SubViewport holds the zoomable pixel world; frozen with its Page, resumed intact
interface: modules/atlas/interface.gd
errors: modules/atlas/errors.gd
tests: modules/atlas/playtest/harness.gd + modules/atlas/playtest/verify.py
depends-on: [shell]
---

# atlas

## What callers get

`AtlasInterface.create(deps)` returns a full-rect Control that satisfies the Shell's Tenant contract (`modules/shell/interface.gd`, ticket #24): it lays out from its own `size` / `resized`, never the root viewport, and `state()` is the harness probe. The Shell's demo registry maps `map` to it (map #23: the atlas is the first port, proving the seam on the cheapest Tenant). The two data files are checked before anything is built (a missing one returns `atlas.asset_missing` with the path); a missing pixel sheet, font or shader is reported by `load()` as it is reached.

The Page is the atlas's desktop: one map window, the prototype's frame pixels sliced around a `SubViewportContainer`, opens centred at the largest 1158x954-proportioned rect that fits with a 24 px margin and re-fits on a Page resize. It drags by its title bar, resizes by its edges (300 px wide minimum), collapses by its left button and locks by its right one. Inside, the zoomable atlas is the prototype's `atlas.gd` unchanged in behaviour: drag pans, the wheel zooms at the pointer (x1.18 a notch), double-click zooms in, Home/Esc reset, + and - zoom, arrows pan, F shows the region's full sheet; the HUD picks a region; close-city names appear past 1.8x in PixelMplus (`fonts/LICENSE.txt`), coastline tiles past 1.65x.

Frozen while hidden: the Shell hides the Page (`visible = false`, `process_mode DISABLED`). Measured in the playtest: the window's `_process` and `_input` counters stand still, wheel and drag events aimed at the hidden map change nothing, the `SubViewportContainer` flips its SubViewport to `UPDATE_DISABLED` (mode 0) and the frame's draw calls fall back to the white-page count (38 against 62 with the map shown); on show it resumes with zoom, camera and window exactly as left (mode 4, pixels identical to before hiding).

## Frozen

`interface.gd`, `errors.gd`, the playtest harness and its verifier. Changing them is an Issue.

## Inside

`atlas_window.gd` is the window and the Tenant node; `atlas.gd` is the map inside its SubViewport (`gui_embed_subwindows`, `UPDATE_ALWAYS` as in the prototype — the container manages it from there). Both come from `qwen-pipeline-experiments` `prototype/atlas-5` @ `421f1cc`; `PROVENANCE.md` lists all 88 copied files with hashes and the ledgers their pixels come from. Left behind: the four desktop panels, the under-750-px phone layout, the clear-colour override, the JavaScriptBridge publishes (now `snapshot()` feeding `state()`, trimmed to the fields the probe documents), the touch, pinch and trackpad paths (a desktop-only Tenant), the two one-node scenes, `world.png` and the plain geography tiles (never loaded). One prototype bug fixed: a spare `Button.new()` that was never added to the tree leaked at exit. `export_presets.cfg` includes `modules/atlas/*.json` so the Web export carries the data. No project setting changed; the prototype's `gl_compatibility` and `emulate_mouse_from_touch` are not set here (see the open questions on the port's ticket).

The playtest (`scripts/playtest.sh atlas`, on `testing/harness_base.gd`) builds the Shell with the atlas in the Map Tab and nothing in the other Tabs, on an X display at 1920x1080, drives it with real mouse events through `Input.parse_input_event` (tab clicks, wheel, drag-pan, title-bar drag) and reaches the atlas only through `ShellInterface.tenant_state`; `verify.py` re-hashes the screenshots, re-reads pixels (sea and land colours in the map body, the title lettering, white outside the window) and checks the logged states against the contract: lazy creation, page fill, the window's fit, zoom x1.18^3 at the centre, camera moved by drag/zoom, frame moved by the drag, frozen counters, unchanged state under hidden events, update mode and draw calls while hidden, identical pixels on resume, the 1440x900 re-fit. Evidence of the accepted run is in `docs/evidence/atlas/`.

Known gaps: the prototype's keys (Home, Esc, arrows, F) are also claimed by other Tenants (map #23, cross-tab shortcuts); GeoNames attribution is not shown on screen; the window frame's rights record is "owner supplied" only.
