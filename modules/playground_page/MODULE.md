---
name: playground_page
purpose: The Playground Tab's Tenant as a draft mockup — the owner's reference picture at native size, centred on a white Page, frozen with the Page
interface: modules/playground_page/interface.gd
errors: modules/playground_page/errors.gd
tests: modules/playground_page/playtest/harness.gd + modules/playground_page/playtest/verify.py
depends-on: [shell]
---

# playground_page

## What callers get

`PlaygroundPageInterface.create(deps)` returns a full-rect Control that satisfies the Shell's Tenant contract (`modules/shell/interface.gd`, ticket #24): a white surface with the owner's reference picture of the Digital Playground page (the RISD Museum "Collections page" window: header, saved objects, Info box) drawn at its native size (859x803) and centred, re-centred from its own `size` / `resized`, never from the root viewport. The picture is a byte-identical copy of `docs/evidence/collection-page/reference.png` (`PROVENANCE.md`); nothing in it is hand-drawn and nothing reacts to input. It exists because the owner made the Playground a Tab of its own shown as a draft mockup on white (map #23, owner correction 2026-09-13); what it will do is not yet specified on the map.

`state(tenant)` is the harness probe: the key, the `_process` and `_unhandled_input` counters (both stand still while the Page is frozen), the Tenant's size, the picture's native size and the rect it is drawn at. A missing or unloadable picture returns `playground_page.asset_missing` from `create`.

## Frozen

`interface.gd`, `errors.gd`, the playtest harness and its verifier. Changing them is an Issue.

## Inside

One ColorRect with one TextureRect (`STRETCH_KEEP`, so the project's nearest filter draws the picture pixel for pixel), positioned at the floor of the centred offset on every resize. The Web export carries the PNG as an imported resource.

The playtest (`scripts/playtest.sh playground_page`, on `testing/harness_base.gd`) builds the Shell with this module in the Playground Tab (index 5) and nothing in the other Tabs, on an X display at 1920x1080, clicks the Playground tab, another tab and back, presses a key and clicks the page area while hidden, and resizes to 1440x900 — all through real events, reaching the Tenant only through `ShellInterface.tenant_state`; `verify.py` re-reads `assets/reference.png` itself and checks the logged states and pixels against the contract: created on first show, the picture at native size centred in the Page and matching the reference composited over white pixel for pixel, white around it, counters frozen while hidden and resumed intact, identical pixels on resume, re-centred and still exact at 1440x900 (21 checks). Evidence of the accepted run is in `docs/evidence/playground-page/`.

Known gap: a mockup only — no keys, no screen, no way to reach objects (map #23 "Not yet specified").
