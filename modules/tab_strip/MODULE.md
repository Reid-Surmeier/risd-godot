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
- Labels are sliced source pixels, so only `windows_live`, `connecting` and `blank_page` exist; no font is used anywhere.

`open_new_tab`, `select_tab`, `state`, `stub_rect` are the programmatic seam; every one returns `{ ok, value, error }`.

## Frozen

`interface.gd`, `errors.gd`, the playtest harness and its verifier. Changing them is an Issue.

## Inside

Geometry is in source pixels (bar 3135x161); `demo.gd` scales the strip to the window width. A tab is left slice + 1 px middle column stretched + right slice, all RGBA cutouts over the exact bar background (`bar_background.png` is the source bar with the tab and stub erased by stripe-aligned copies). The stub's left edge sits on the first tab's right edge, as in the source, so the double slant between tabs is the source's own look.

The playtest (`scripts/playtest-tab-strip.sh`) runs the demo on an X display, drives it with real `InputEventMouseButton` events through `Input.parse_input_event`, screenshots each state, and `verify.py` re-hashes the screenshots and checks counts, labels, page visibility, timings and pixels independently of the harness's own report. Evidence of the accepted run is in `docs/evidence/tab-strip/`.

Known gap: the middle column stretch means very wide tabs keep a flat white face, which matches the source; there is no hover state because the source has none.
