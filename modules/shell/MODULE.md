---
name: shell
purpose: The one Control the game runs in — the tab strip with six fixed Tabs and the Page area, where each Tab's Tenant is created lazily and frozen while hidden
interface: modules/shell/interface.gd
errors: modules/shell/errors.gd
tests: modules/shell/playtest/harness.gd + modules/shell/playtest/verify.py
depends-on: [tab_strip]
---

# shell

## What callers get

`ShellInterface.create(registry)` returns a full-rect Control: a white ground, the PageStack, and the TabStrip fitted to the Shell's width (the owner's reference bar, 4180 source px across the window with the icon cluster at 65 percent; re-fitted on `resized`). It opens the six fixed Tabs in launch order — `map`, `sketchbook`, `3d_viewer`, `video_player`, `collection`, `phone` — with Collection active (map #23, ticket #28). The strip's stub keeps opening Blank Pages, which close as before; a fixed Tab has no close button and `close_tab` on it returns `shell.tab_fixed`.

`registry` maps a fixed key to its Tenant: a Script whose `static create(deps) -> {ok, value: Control, error}` builds it, or a Callable with the same signature. The Tenant is created on the Tab's first show (`deps = {"key": key}`) and added to that Tab's Page, a plain white surface; a key with no entry keeps the white Page (`tenant_state` says `shell.tenant_missing`); a `create` that fails leaves it white and records `shell.tenant_failed`. The Shell's show/hide rule (ticket #24): the visible Page runs; every hidden Page is `visible = false`, `process_mode DISABLED` (no `_process`, no input callbacks, no tweens, no video) with any focus inside it released, and resumes with its state intact on show.

The Tenant contract is written in `interface.gd`; `playtest/dummy_tenant.gd` is the worked example (a white surface counting its frames and input events). `select_tab`, `close_tab`, `tenant_state`, `state` are the programmatic seam; every one returns `{ ok, value, error }`.

## Frozen

`interface.gd`, `errors.gd`, the playtest harness and its verifier. Changing them is an Issue.

## Inside

The fixed Tabs are strip indexes 0..5 forever: opened before any stub tab and never closable, so a stub tab closing never shifts them. `demo.tscn` is the game's main scene (`project.godot`): 1920x1080, resizable, 1440x900 minimum, stretch disabled; its registry holds the dummy tenant for five keys until the ports land (map #23 port order), and nothing for `phone`, so its Page is white. Pixels: the strip's; the Shell draws nothing but white.

The playtest (`scripts/playtest-shell.sh`) runs the main scene on an X display at 1920x1080, drives it with real mouse and key events through `Input.parse_input_event`, and `verify.py` re-hashes the screenshots and checks the logged states and tenant counters independently: six fixed tabs in order, Collection active, lazy creation, a hidden tenant's `_process` and input counters standing still and resuming, close refused by click and by call, the stub's blank page, a resize to 1440x900. `playtest/browser_play.py` drives the Web export in headless Chrome. Evidence of the accepted run is in `docs/evidence/shell/`.

Known gap: the strip draws no active-tab difference, so two white Pages look the same until a Tenant lives in them; the Muse title for `phone` is #34.
