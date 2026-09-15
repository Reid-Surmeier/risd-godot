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
- Every stub-opened tab carries a close button (a Muse-drawn "x" in the toolbar's grey, `assets/icon_close.png`); clicking it folds the tab back into a stub over 0.3 s (contents fade, then the shape reverses the grow), removes the tab and its page, slides the remaining tabs and the stub to their new places over 0.2 s, and makes the left neighbour active. Every such tab can close, the last one too; with no tabs the stub sits at the first tab's place and opens a fresh one.
- `open_fixed_tab(strip, key, page)` (seam Issue #39) opens a titled tab at once, no animation: the page icon plus the Muse-drawn title `label_<key>.png` from the `labels` map in `layout.json` (`map`, `sketchbook`, `3d_viewer`, `video_player`, `collection`, `playground`, `phone` — seven Muse passes, 0.01 USD each, recorded in `~/muse-runs/ie7-newtab/final/README.md`; a key with no label shows the icon alone, with a warning in the log). The tab owns the caller's `page` Control, added hidden to the PageStack and shown by `select_tab`. A fixed tab draws no close button, `state()` gives it an empty `close_rect`, and `close_tab` on it returns `TAB_FIXED`. The Shell module opens the seven fixed tabs this way.
- A click on any tab dips it (seam Issue #39, second segment): the stub's pressed tint and a 6 source px drop for `PRESS_SECONDS`, then it sits back; `state()` reports the dipping tab in `pressed` (-1 when none). `select_tab` from code does not dip. `grow_tab(strip, index)` replays the open gesture on a tab already in the row, in place — stub-sized with the pressed tint for `PRESS_SECONDS`, then the grow to its own width over `GROW_SECONDS`, its neighbours and the stub still — emitting `tab_opened` then `tab_settled` and selecting nothing; the Shell uses it for the launch tab.
- The active tab is tinted (Issue #45): its face carries the atlas sea blue `#83e5f7` at 12 percent (`SEA_BLUE`, `ACTIVE_TINT`), fading in over `FADE_SECONDS` (0.2 s) when a tab becomes active (click, `select_tab`, a new tab settling, the neighbour after a close) and out on the tab it leaves. It is a `self_modulate` on every piece of the tab (the icon and label cutouts are opaque on white, so they take it with the face); no node, no shader. `state()` reports each tab's `tint`, 0 to 1.
- `set_bar_width` makes the bar any width: the stars stay left, the icon cluster stays right, the pinstripes fill the middle from a clean 700 px patch, and tabs take the room between. `demo.gd` fits it to the window and re-fits on resize; the bar is 4180 source px fitted to the window (icon cluster at 65 percent, the reference proportion), so seven shrunk tabs and a stub-opened eighth fit.

`open_new_tab`, `open_fixed_tab`, `select_tab`, `close_tab`, `set_bar_width`, `state`, `stub_rect` are the programmatic seam; every one returns `{ ok, value, error }`.

## Frozen

`interface.gd`, `errors.gd`, the playtest harness and its verifier. Changing them is an Issue.

## Inside

Geometry is in source pixels (bar 3135x161); `demo.gd` scales the strip to the window width. A tab is left slice + 1 px middle column stretched + right slice, all RGBA cutouts over the exact bar background (`bar_background.png` is the source bar with the tab and stub erased by stripe-aligned copies). Tab and stub cutouts follow the real outline pixels (face plus slant outline) and end just above the bar's bottom border, so the slants run unbroken down to the line and the line itself is the background's, one piece from end to end; the active tab covers it with a white opening into its page, as IE7 does. The bar's top and bottom borders in the three background sprites are flattened to one row profile (the Muse drawing's line wobbled in thickness). Tabs are drawn left-in-front and the stub behind all of them, as the source draws its stub behind the tab: a growing or folding tab is always behind its left neighbour, so the neighbour's corner never protrudes and the join is one line.

The playtest (`scripts/playtest.sh tab_strip`, on `testing/harness_base.gd`) runs the demo on an X display, drives it with real `InputEventMouseButton` events through `Input.parse_input_event`, screenshots each state, and `verify.py` re-hashes the screenshots and checks counts, labels, page visibility, timings and pixels independently of the harness's own report. Evidence of the accepted run is in `docs/evidence/tab-strip/` (29 checks; 36 since the fixed-tab segment of #39; 44 since the active tint of #45).

Known gap: the middle column stretch means very wide tabs keep a flat white face, which matches the source; there is no hover state because the source has none.
