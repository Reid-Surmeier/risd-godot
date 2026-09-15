---
name: playground_page
purpose: The Playground Tab's Tenant — the owner's 2026-09-14 layout as a working desktop (PostPet window, options / Search filters / trade / Global Chatroom, the Nokia phone), every window draggable, laid out by the fill rule, frozen with its Page
interface: modules/playground_page/interface.gd
errors: modules/playground_page/errors.gd
tests: modules/playground_page/playtest/harness.gd + modules/playground_page/playtest/verify.py
depends-on: [shell]
---

# playground_page

## What callers get

`PlaygroundPageInterface.create(deps)` returns a full-rect Control that satisfies the Shell's Tenant contract (`modules/shell/interface.gd`): it lays out from its own `size` / `resized` and `state()` is the harness probe. Every pixel file is checked first; a missing one returns `playground_page.asset_missing` with its path.

The Page is the owner's layout picture (`docs/evidence/playground/layout-reference.png`, ticket #62) as a desktop: the Digital Playground (PostPet) window on the left; the options, Search filters and trade windows in a middle column with the Global Chatroom at the bottom; the Nokia phone on the right (the Phone Tab folded into this page). The four RO HUD windows are the Collection Tab's screenshots with their magenta border keyed out, as on the Collection page. A press raises the topmost window under the pointer; a drag on its title bar moves it (the phone drags by its whole surface), stopping at the Page's edge; a drag on a window's body moves nothing. The controls drawn inside the windows are decorative. No font is used.

Layout (ticket #63). The native desktop is 2171x1185 px (the windows' rects in the picture plus a 24 px margin). From the Page's size S, `factor = min(S.x / 2171, S.y / 1185)` scales every window uniformly. The leftover on the other axis goes to the PostPet window: its rect runs to the middle column on the right and to the bottom margin. It is a raster, so it is drawn band by band at the uniform scale, and only a one-pixel column per band (a column with no horizontal step inside that band) and one flat row take up the extra width and height. The middle column and the phone anchor to the right edge, the chat window to the bottom edge. Every resize re-lays out (drags reset), and at any aspect the desktop spans the page within the margin.

## Frozen

`interface.gd`, `errors.gd`, the playtest harness and its verifier. They were rewritten under the owner's correction of 2026-09-14 (ticket #62), when the draft mockup became this desktop.

## Inside

`playground_page.gd` is the Tenant: five TextureRects (the HUD windows with `remove-pink.gdshader`, the phone) and one Control that draws the PostPet bands, all sampled with the linear filter. The drag, raise and clamp work like collection_page's `viewer.gd`, but the code and four assets are copied, not shared: collection_page's interface exposes no window code, and its frozen verifier reads its own `assets/`. `PROVENANCE.md` has every file's origin and hash.

The playtest (`scripts/playtest.sh playground_page`, on `testing/harness_base.gd`) builds the Shell with this module in the Playground Tab and nothing in the other Tabs, on an X display at 1920x1080. It drives the desktop with real mouse and key events through `Input.parse_input_event`: the Playground tab, a title drag of the trade window, a body drag of options, the Map tab, a drag and a key while hidden, back, then window sizes giving 1920x1000 and 1440x820 pages, 1440x900 and 1920x1080. It reaches the desktop only through `ShellInterface.tenant_state`. `verify.py` re-reads the owner's layout picture and recomputes every window's place from the rects measured in it and the fill rule. It then compares each window's pixels in the screenshots with the picture at that place, with a shifted-crop control to prove the comparison discriminates. It also checks lazy creation, the drag and raise, body drag ignored, frozen counters and unchanged windows while hidden, identical pixels on resume, and at each size: windows at the rule's places, the desktop spanning the page on both axes within the margin, the main window never below native × factor, and pixels still matching (52 checks). Evidence of the accepted run is in `docs/evidence/playground/`.

Known gaps: the PostPet window is the RISD version (header "Collections page", "Info / Saved objects"). The owner's layout picture shows the PostPet original there ("PostPet セットアップ", the 特徴 box), so those two regions differ from the picture and the verifier compares the side columns and stickers only; swapping the art is one file. The magenta borders the picture shows are keyed out, as on the Collection page. A one-pixel dash from the header band stretches at the panel's top-right when the page is wider than native. No hover or pressed states exist.
