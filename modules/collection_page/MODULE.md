---
name: collection_page
purpose: The Collection Tab's Tenant — the RISD Museum "Collections page" look over one static record file, three working filters with a count, and a card click that emits a signal
interface: modules/collection_page/interface.gd
errors: modules/collection_page/errors.gd
tests: modules/collection_page/playtest/harness.gd + modules/collection_page/playtest/verify.py
depends-on: [shell]
---

# collection_page

## What callers get

`CollectionPageInterface.create(deps)` returns a full-rect Control that satisfies the Shell's Tenant contract (ticket #24): a white ground, the sliced header top-left, a filter row, a scrolling flow grid of cards, and the sliced Info box at the bottom; it lays itself out from its own `size` and re-lays on `resized`. It reads `data/collection.json` (or `deps.data_path`) once and refuses to build on a missing file (`collection_page.data_missing`), a malformed one (`collection_page.data_invalid`) or a missing pixel file or font (`collection_page.asset_missing`).

A card is one real record — `id, title, maker, department, medium, year, has_image, has_video, has_3d, thumbnail` — and the page never invents one (ticket #27). Sixteen records ship: the three cut-outs of the owner's reference, the Buddha scan (`has_3d`), the five RISD videos (`has_video`, titles from the issue-18 manifest) and the seven prototype-81 artworks as record-only cards. Where the words on a card come from is stated per record (`identity`: `manifest` or `descriptive`) and every pixel's source is in `PROVENANCE.md`; the museum media's rights are pending on #35.

The filters work: `medium` cycles All and every medium in the data, `sort` cycles none / newest / oldest (by `year`, ties by id), `has_image` toggles; the count reads "n of N objects". `set_filter(page, {…})` does the same from code and refuses an unknown key or value with `collection_page.filter_invalid`, changing nothing. A card click emits `card_selected(record)` and changes nothing else; opening the 3D Viewer or Video Player from a card is wired after the seam (map #23's cross-tab item). `state(page)` reports total, count, filter, mediums, the visible cards with their rects in the page's own pixels, and the three control rects, so a harness can click them with real events.

## Frozen

`interface.gd`, `errors.gd`, the playtest harness and its verifier. Changing them is an Issue.

## Inside

Sliced pixels are shown at 2x through the project's nearest filter (the reference window is 859 px wide; the page is 1440..1920). Cards are 280x296 plain Controls in an `HFlowContainer` inside a `ScrollContainer` (vertical only); text is Liberation Sans through theme overrides, black on white, clipped to the card (clip and wrap are set before the size, or a Label's minimum size grows to its text). The `has_video` / `has_3d` badge is the repository's MED-01 / MED-06 still. The grid is rebuilt on every filter change — sixteen cards, so no incremental update.

The playtest (`scripts/playtest.sh collection_page`, on `testing/harness_base.gd`) builds the Shell with this page in the Collection Tab and nothing in the other Tabs, at 1920x1080 on an X display, drives the filter controls, a card, the white ground and the Map and Collection tabs with real mouse events through `Input.parse_input_event`, and calls the interface once with an invalid filter; `verify.py` re-reads `collection.json` itself, re-hashes the screenshots and checks every state against the contract (41 checks). Evidence of the accepted run is in `docs/evidence/collection-page/`.

Known gaps: no hover or pressed state on cards or controls (no State Sets exist yet); the browser-rendered run (`browser_play.py`) is not written for this page; the descriptive records are not museum records.
