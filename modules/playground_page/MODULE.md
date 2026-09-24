---
name: playground_page
purpose: The Playground Tab's Tenant — the retained window layout with cleared interiors and browser-local RISD saves in the PostPet window
interface: modules/playground_page/interface.gd
errors: modules/playground_page/errors.gd
tests: modules/playground_page/playtest/harness.gd + modules/playground_page/playtest/verify.py
depends-on: [shell, collection_data]
---

# playground_page

## What callers get

`PlaygroundPageInterface.create(deps)` returns a full-rect Control that satisfies the Shell's Tenant contract (`modules/shell/interface.gd`): it lays out from its own `size` / `resized` and `state()` is the harness probe. Every pixel file is checked first; a missing one returns `playground_page.asset_missing` with its path.

The Page retains the six-window layout and frames from the owner's layout picture. The five desktop windows have cleared white interiors; the Nokia phone remains. The PostPet frame shows the shared browser-local RISD saves, including verified thumbnails and identity text. A press raises the topmost window under the pointer; title bars drag within the Page, and the phone drags by its whole surface.

Layout (ticket #63). The native desktop is 2171x1185 px (the windows' rects in the picture plus a 24 px margin). From the Page's size S, `factor = min(S.x / 2171, S.y / 1185)` scales every window uniformly. The leftover on the other axis goes to the PostPet window: its rect runs to the middle column on the right and to the bottom margin. It is a raster, so it is drawn band by band at the uniform scale, and only a one-pixel column per band (a column with no horizontal step inside that band) and one flat row take up the extra width and height. The middle column and the phone anchor to the right edge, the chat window to the bottom edge. Every resize re-lays out (drags reset), and at any aspect the desktop spans the page within the margin.

## Frozen

`interface.gd`, `errors.gd`, the playtest harness and its verifier. They were rewritten under the owner's correction of 2026-09-14 (ticket #62), when the draft mockup became this desktop.

## Inside

`playground_page.gd` owns the retained raster frames, clearing overlays, save cards, verified image loading, and the existing drag, raise and clamp behavior. In the main demo, the PostPet window uses the same collection-data seam and verified hash route for an Are.na-style masonry channel of 25 public-domain RISD paintings: full image ratios, hover identity, vertical scrolling and click-to-expand. The frozen fixture leaves that optional gallery off. `PROVENANCE.md` has every raster frame's origin and hash, while `docs/evidence/playground-gallery/` records the gallery metadata, rights evidence and image hashes.

The main demo also enables the approved WebSurfer raster as a seventh draggable Playground window. The unused gray source bands are cropped, and its baked bottom-right grip resizes the whole raster proportionally so its lettering and controls stay intact. All controls are invisible hit regions; button and scrollbar motion sample the source pixels without drawing replacement text. The frozen six-window acceptance fixture leaves this optional comparison window disabled.

The main demo adds the owner's journal screenshot as another draggable Playground window. Its invisible controls retain the source styling: the three journal tabs and dated entry open a diary, the arrows use the Sketchbook's 520 ms perspective paper turn while the rings remain above the sheet, the counter changes using numerals already present in the screenshot, the title controls are palette-conformed to black and white, the left entry rail scrolls, the title icon returns home, and X closes. Each journal has three memory-only editable pages; native text uses the source-matched PixelMplus font without antialiasing, the screenshot's gray shadow, the original page margins and wrapping, and a black caret. It scales proportionally and drags by its title bar. The frozen six-window acceptance fixture leaves this optional window disabled.

The playtest (`scripts/playtest.sh playground_page`, on `testing/harness_base.gd`) builds the Shell with this module in the Playground Tab and nothing in the other Tabs, on an X display at 1920x1080. It drives the desktop with real mouse and key events through `Input.parse_input_event`: the Playground tab, a title drag of the trade window, a body drag of options, the Map tab, a drag and a key while hidden, back, then window sizes giving 1920x1000 and 1440x820 pages, 1440x900 and 1920x1080. It reaches the desktop only through `ShellInterface.tenant_state`. `verify.py` re-reads the owner's layout picture and recomputes every window's place from the rects measured in it and the fill rule. It then compares each window's pixels in the screenshots with the picture at that place, with a shifted-crop control to prove the comparison discriminates. It also checks lazy creation, the drag and raise, body drag ignored, frozen counters and unchanged windows while hidden, identical pixels on resume, and at each size: windows at the rule's places, the desktop spanning the page on both axes within the margin, the main window never below native × factor, and pixels still matching (52 checks). Evidence of the accepted run is in `docs/evidence/playground/`.

With `show_fengshui` (on in the main demo) the Page follows the owner's layout picture of 2026-09-23 (`docs/evidence/playground-fengshui/layout-reference.png`): the Feng Shui window replaces PostPet on the left, the journal, WebSurfer and chat stack in the right column beside the Nokia, and options, filters and trade are hidden (in the picture they only peeked out from under other windows). The Feng Shui picture's title/menu/toolbar band and its element-panel band are drawn at the window's width; between them one row's side borders stretch. In the web build its client area carries the owner's Are.na profile, always in Are.na's light layout (`arena_embed.gd`: header, bio and the newest 24 blocks from the public API in two requests; the real page cannot be forced light inside an iframe), as HTML over the canvas, placed through the inverse of the CRT warp, laid out at 1200 px and scaled, cut away wherever a window above covers it, ignoring the pointer during a window drag and hidden with the Page. The desktop build leaves the client area white.

Prototype #106 adds saved-card selection into the trade window, an editable local filter, and a scrolling saved list. The throwaway `prototype/` scene uses explicit synthetic data and has native and browser input checks; the frozen interface and original acceptance tests remain unchanged. This is not a complete interaction inventory: phone keys, decorative gifts and window-close icons remain unimplemented.
