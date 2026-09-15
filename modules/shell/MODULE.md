---
name: shell
purpose: The one Control the game runs in — the tab strip along the bottom with six fixed Tabs and the Page area above it, where each Tab's Tenant is created lazily, shown with a cross-fade and frozen while hidden
interface: modules/shell/interface.gd
errors: modules/shell/errors.gd
tests: modules/shell/playtest/harness.gd + modules/shell/playtest/verify.py
depends-on: [tab_strip, atlas, sketchbook, sculpture_viewer, video_player, collection_page, playground_page, collection_data]
---

# shell

## What callers get

`ShellInterface.create(registry)` returns a full-rect Control: a white ground, the PageStack filling the window above the bar, and the TabStrip along the **bottom** of the window (owner correction on map #23), fitted to the Shell's width (the owner's reference bar, 4180 source px across the window with the icon cluster at 65 percent; re-fitted on `resized`). It opens the six fixed Tabs in launch order — `map`, `sketchbook`, `3d_viewer`, `video_player`, `collection`, `playground` — with Collection active. (Seven until 2026-09-14: the owner folded the Phone Tab into the Playground desktop, #62. tab_strip's `layout.json` keeps the `phone` label file; the Shell no longer opens it.) The strip's stub keeps opening Blank Pages, which close as before; a fixed Tab has no close button and `close_tab` on it returns `shell.tab_fixed`.

Motion. At launch the Collection tab grows in like a stub-opened tab (the strip's `grow_tab`: stub-sized with the pressed tint for 0.1 s, then the 0.4 s grow, its neighbours still) and its Page then fades in over `FADE_SECONDS` (0.2 s). On a tab click the strip dips the clicked tab (pressed tint, 6 source px down, 0.1 s) and the Shell cross-fades the new Page in over 0.2 s while the old one fades out; `switch_settled(index)` fires when the fade is done and the freeze rule has been applied. `state()` reports `switching` (a fade running; two Pages may be visible then), `pressed` (the strip's dipping tab or -1) and `bar_rect`.

`registry` maps a fixed key to its Tenant: a Script whose `static create(deps) -> {ok, value: Control, error}` builds it, or a Callable with the same signature. The Tenant is created on the Tab's first show (`deps = {"key": key}`) and added to that Tab's Page, a plain white surface; a key with no entry keeps the white Page (`tenant_state` says `shell.tenant_missing`); a `create` that fails leaves it white and records `shell.tenant_failed`. The Shell's show/hide rule (ticket #24): the visible Page runs; once a fade has settled every hidden Page is `visible = false`, `process_mode DISABLED` (no `_process`, no input callbacks, no tweens, no video) with any focus inside it released, and resumes with its state intact from the moment its fade-in starts.

The Tenant contract is written in `interface.gd`; `playtest/dummy_tenant.gd` is the worked example (a white surface counting its frames and input events). `select_tab`, `close_tab`, `tenant_state`, `state` are the programmatic seam; every one returns `{ ok, value, error }`.

## Frozen

`interface.gd`, `errors.gd`, the playtest harness and its verifier. Changing them is an Issue.

## Inside

The fixed Tabs are strip indexes 0..5 forever: opened before any stub tab and never closable, so a stub tab closing never shifts them. Every Page starts hidden and frozen; the launch `grow_tab` on Collection is followed by `select_tab` on the strip's `tab_settled`. A selection kills any running fade, re-shows the Pages still on their way out (the strip hid them), moves the target on top of the PageStack, tweens `modulate.a` on all of them, and applies the freeze rule in the tween's callback. `demo.tscn` is the game's main scene (`project.godot`): 1920x1080, resizable, stretch disabled (the CRT presentation below handles small windows); its registry maps `map` to the atlas module, `collection` to the collection_page module, `sketchbook`, `3d_viewer`, `video_player` to their ports, and `playground` to the playground_page desktop. The Tenant interfaces are the demo scene's only dependency beyond the strip; `shell.gd` itself knows no Tenant. Pixels: the strip's; the Shell draws nothing but white.

The playtest (`scripts/playtest.sh shell`, on `testing/harness_base.gd`) builds the Shell with its own registry — the dummy tenant in four Tabs, a grey Callable-built tenant in `playground` (so a cross-fade shows in pixels), nothing in `video_player` — on an X display at 1920x1080, drives it with real mouse and key events through `Input.parse_input_event`, films the launch and two switches frame by frame, and `verify.py` re-hashes the screenshots, re-reads the film's pixels and checks the logged states, signals and tenant counters independently: six fixed tabs in order along the bottom, the launch tab stub-sized then grown with its page shown only after the settle, `switch_settled` 0.55..1.0 s after mount, the pressed tint on the clicked tab within 100 ms and gone after 220 ms, the page blend through in-between greys, a switch settling 150..450 ms after the click, lazy creation, a hidden tenant's `_process` and input counters standing still and resuming, close refused by click and by call, the stub's blank page as the seventh tab, a resize to 1440x900 (48 checks). `playtest/browser_play.py` drives the Web export in headless Chrome. Evidence of the accepted run is in `docs/evidence/shell/`.

Known gap: the strip draws no active-tab difference (#45), so two white Pages look the same until a Tenant lives in them.


## CRT presentation (#64)

The demo scene presents the existing Shell through a SubViewport, with a final
Harrison Allen CC0 luminance-preserving CRT shader. Softer aperture-grille lines,
low colour separation and static fine grain follow the owner's reference. Curvature
is .018, with no border or vignette; pure whites remain white. The same warp maps
pointer input before it reaches the Shell. F8 toggles presentation without rebuilding
any tenant; `?crt=0` starts unfiltered. `?qa-crt=1` publishes read-only browser evidence.
The logical desktop is at least 1440x900 and scales uniformly to the browser size,
including smaller windows, with no minimum OS window size or letterboxing.
