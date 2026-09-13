---
name: tab_strip
purpose: The Windows Live / IE7 toolbar with tabs you can open by clicking the blank New Tab stub; each tab owns a page
interface: modules/tab_strip/interface.gd
errors: modules/tab_strip/errors.gd
tests: modules/tab_strip/playtest/harness.gd + modules/tab_strip/playtest/verify.py
depends-on: []
---

# tab_strip

## What callers get

`TabStripInterface.create(page_stack)` returns a Control that draws the toolbar from sliced source pixels (the Muse-generated flat toolbar in `assets/`, mapped by `layout.json`; nothing is hand-drawn) and behaves like a 2008 tab strip:

- Click the blank stub: it shows its pressed face, then grows into a full tab over 0.4 s (cubic ease-out) with the fresh stub riding on its right edge; the page icon and "Connecting..." fade in as it opens; 0.95 s later the label swaps to "Blank Page" in one frame. Signals: `tab_opened`, `tab_settled`, `tab_titled`, `tab_selected`.
- Every tab owns one page in the caller's `page_stack`; opening a tab shows its page; clicking a tab shows its page.
- When the row is full, tabs shrink together and labels clip (IE7 behaviour); when even the minimum width will not fit, `open_new_tab` returns `NO_ROOM` and nothing changes.
- Labels are sliced source pixels, so only `windows_live`, `connecting` and `blank_page` exist; no font is used anywhere. A label that does not fit is cut at the last whole glyph and followed by the source's own "..." glyph; a tab never cuts a glyph in half, and `tab_min_width` keeps room for icon, two glyphs and the dots.
- The active tab carries a close button (a Muse-drawn "x" in the toolbar's grey, `assets/icon_close.png`); clicking it folds the tab back into a stub over 0.3 s (contents fade, then the shape reverses the grow), removes the tab and its page, slides the remaining tabs and the stub to their new places over 0.2 s, and makes the left neighbour active. The last tab cannot be closed.
- `set_bar_width` makes the bar any width: the stars stay left, the icon cluster stays right, the pinstripes fill the middle from a clean 700 px patch, and tabs take the room between. `demo.gd` fits it to the window and re-fits on resize; tabs are drawn at 0.55 of source size.

`open_new_tab`, `select_tab`, `close_tab`, `set_bar_width`, `state`, `stub_rect` are the programmatic seam; every one returns `{ ok, value, error }`.

## Frozen

`interface.gd`, `errors.gd`, the playtest harness and its verifier. Changing them is an Issue.

## Inside

Geometry is in source pixels (bar 3135x161); `demo.gd` scales the strip to the window width. A tab is left slice + 1 px middle column stretched + right slice, all RGBA cutouts over the exact bar background (`bar_background.png` is the source bar with the tab and stub erased by stripe-aligned copies). Tabs are drawn left-in-front and the stub behind all of them, as the source draws its stub behind the tab: a growing or folding tab is always behind its left neighbour, so the neighbour's corner never protrudes and the join is one line.

The playtest (`scripts/playtest-tab-strip.sh`) runs the demo on an X display, drives it with real `InputEventMouseButton` events through `Input.parse_input_event`, screenshots each state, and `verify.py` re-hashes the screenshots and checks counts, labels, page visibility, timings and pixels independently of the harness's own report. Evidence of the accepted run is in `docs/evidence/tab-strip/` (27 checks).

Known gap: the middle column stretch means very wide tabs keep a flat white face, which matches the source; there is no hover state because the source has none.
