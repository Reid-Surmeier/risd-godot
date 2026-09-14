---
name: collection_page
purpose: The Collection Tab's Tenant — prototype-81's Image Viewer desktop, the eight RO HUD windows and the Image Viewer with its seven artworks on the Page's white desktop, every window draggable and stacking by press; frozen with its Page, resumed intact
interface: modules/collection_page/interface.gd
errors: modules/collection_page/errors.gd
tests: modules/collection_page/playtest/harness.gd + modules/collection_page/playtest/verify.py
depends-on: [shell]
---

# collection_page

## What callers get

`CollectionPageInterface.create(deps)` returns a full-rect Control that satisfies the Shell's Tenant contract (`modules/shell/interface.gd`, ticket #24): it lays out from its own `size` / `resized`, never the root viewport, and `state()` is the harness probe. The Shell's demo registry maps `collection` to it. Every pixel file is checked before anything is built (a missing one returns `collection_page.asset_missing` with the path).

The Page is the prototype's whole desktop, as the owner's correction on map #23 asks (a Tab shows the prototype's whole desktop with all its windows, exactly as its reference screenshot): the eight RO HUD windows — equipment, options, Search filters, status, trade, Global Chatroom, party, the bottom bar — each the owner's own screenshot with its magenta border keyed out, and the Image Viewer window, whose header and footer ("number of works: 12") are patched from the reference sheet and whose body is a vertical-only, bar-less scroll of the seven artworks cut from that sheet at the prototype's fixed size (37.5 percent of the sheet). The desktop places every window at the layout reference's 1944x1280 review coordinates fitted to the Page (factor 0.786 at 1920x1006, 0.645 at the 1440x845 minimum) and re-fits on a Page resize. A press raises the topmost window under the pointer; a drag on its title bar (the bottom bar anywhere on its surface) moves it, stopping at the Page's edge; a drag on its body moves nothing; the viewer also resizes by its bottom-right corner (531x250 minimum) and the artworks keep their size. The controls drawn inside the windows are decorative, as in the prototype. No font is used.

Frozen while hidden: the Shell hides the Page (`visible = false`, `process_mode DISABLED`). Measured in the playtest: the `_process` and `_input` counters stand still, a title drag and a wheel aimed at the hidden windows change nothing, and on show every window, the stacking order and the scroll are exactly as left (pixels identical to before hiding).

## Frozen

`interface.gd`, `errors.gd`, the playtest harness and its verifier. Changing them is an Issue.

## Inside

`viewer.gd` is the Tenant node and the Image Viewer window; `desktop.gd` is the eight HUD windows, reparented under the Tenant so they stack with the viewer. Both come from `qwen-image-pipeline` `prototype/81-image-viewer` @ `5d55209`; `PROVENANCE.md` lists the 12 copied files with hashes and where the owner's pixels came from. Left behind: the always-hidden hint label, an unused rect constant, the JavaScriptBridge publishes (now `state()`), the one-node scene, the project settings. Changed: the Tenant samples its textures with the linear filter the prototype ran with (`texture_filter` on the root; the project default is nearest, which would alias the screenshots scaled to a fifth), and pointer positions are made local to the Page. The old JSON-card grid, its filters, labels, font and record file are gone: the prototype reads none of them.

The playtest (`scripts/playtest.sh collection_page`, on `testing/harness_base.gd`) builds the Shell with the desktop in the Collection Tab and nothing in the other Tabs, on an X display at 1920x1080, drives it with real mouse events through `Input.parse_input_event` (a title drag, a body drag, a drag of the party window over the viewer and a press on the viewer's uncovered title, the wheel over the artworks, the viewer's corner, a drag past the Page's corner, the Map and Collection tabs, a drag and a wheel while hidden) and reaches the desktop only through `ShellInterface.tenant_state`; `verify.py` re-hashes the screenshots, compares every window's pixels with its own screenshot file, the footer with the sheet's "number of works: 12" and the visible artworks with the sheet's cuts, and checks the logged states against the contract: every window at the reference's place, seven artworks at fixed size in flow order, moved by the drag and raised, body drag ignored, only the topmost window under the pointer taking the drag, scroll, resize in place, the edge clamp, frozen counters and unchanged state under hidden gestures, identical pixels on resume, the 1440x900 re-fit (57 checks). Evidence of the accepted run is in `docs/evidence/collection-page/`.

Known gaps: at 1920x1006 the viewer's body shows the first three artworks and the rest scroll (the prototype's fixed artwork size, the owner's `077f993`), where the reference screenshot shows all seven in two rows; no hover or pressed state on any window (no State Sets exist yet); the HUD screenshots have no rights record beyond "owner supplied"; no browser-rendered evidence of this desktop yet.
