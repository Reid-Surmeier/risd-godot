---
name: shell
purpose: The one Control the game runs in — the tab strip along the bottom with seven fixed Tabs and the Page area above it, where each Tab's Tenant is created lazily, shown with a cross-fade and frozen while hidden
interface: modules/shell/interface.gd
errors: modules/shell/errors.gd
tests: modules/shell/playtest/harness.gd + modules/shell/playtest/verify.py
depends-on: [tab_strip, atlas, sketchbook, sculpture_viewer, video_player, playground_page, flowers_page, collection_data, sound_cues]
---

# shell

## What callers get

The playable demo uses the selected square Browser chrome from #156, integrated
under #164: a 1080×1080 logical stage with shared 54-pixel top/bottom bars and a
full-width 1080×972 Tenant area. `square_chrome.gd` composes the existing Shell,
hides its legacy raster bars, and delegates selection through the Shell seam.
The bottom strip uses the provenance-backed compact art at native spacing (307 px star/Start, seven 617 px tabs at 550 px pitch, and 124 px of Home); one uniform scale fits the 4348×186 band. This direct asset use is explicitly scoped by #173. Start opens all seven Tabs, Home selects Map, Previous/Next cycle Tabs, and the
top Search selects Playground then calls its public `show_page(..., "search")`.
The frozen standalone Shell fixture retains its legacy geometry and animations.
Shell omits its own desktop icons and window shadows for the Playground Page before
mounting it, so the Tenant retains its overlapping desktop with native browsing inside the Feng Shui window.
`playtest/square_capture.gd` separately checks the playable demo with real input
and exports all seven Tabs and four Playground pages to `docs/evidence/integration-164/`.

`ShellInterface.create(registry)` returns a full-rect Control: a white ground, the PageStack filling the window above the bar, and the TabStrip along the **bottom** of the window (owner correction on map #23), fitted to the Shell's width (the owner's reference bar, 4180 source px across the window with the icon cluster at 65 percent; re-fitted on `resized`). It opens the seven fixed Tabs in launch order — `map`, `sketchbook`, `3d_viewer`, `video_player`, `collection`, `playground`, `flowers` — with Collection active. (Flowers joined after Playground on 2026-09-25 at the owner's request. Six from 2026-09-14, when the owner folded the Phone Tab into the Playground desktop, #62; tab_strip's `layout.json` keeps the `phone` label file; the Shell no longer opens it.) The strip's stub keeps opening Blank Pages, which close as before; a fixed Tab has no close button and `close_tab` on it returns `shell.tab_fixed`.

Motion. At launch the Collection tab grows in like a stub-opened tab (the strip's `grow_tab`: stub-sized with the pressed tint for 0.1 s, then the 0.4 s grow, its neighbours still) and its Page then fades in over `FADE_SECONDS` (0.2 s). On a tab click the strip dips the clicked tab (pressed tint, 6 source px down, 0.1 s) and the Shell cross-fades the new Page in over 0.2 s while the old one fades out; `switch_settled(index)` fires when the fade is done and the freeze rule has been applied. `state()` reports `switching` (a fade running; two Pages may be visible then), `pressed` (the strip's dipping tab or -1) and `bar_rect`.

`registry` maps a fixed key to its Tenant: a Script whose `static create(deps) -> {ok, value: Control, error}` builds it, or a Callable with the same signature. The Tenant is created on the Tab's first show (`deps = {"key": key}`) and added to that Tab's Page, a plain white surface; a key with no entry keeps the white Page (`tenant_state` says `shell.tenant_missing`); a `create` that fails leaves it white and records `shell.tenant_failed`. The Shell's show/hide rule (ticket #24): the visible Page runs; once a fade has settled every hidden Page is `visible = false`, `process_mode DISABLED` (no `_process`, no input callbacks, no tweens, no video) with any focus inside it released, and resumes with its state intact from the moment its fade-in starts.

The Tenant contract is written in `interface.gd`; `playtest/dummy_tenant.gd` is the worked example (a white surface counting its frames and input events). `select_tab`, `close_tab`, `tenant_state`, `state` are the programmatic seam; every one returns `{ ok, value, error }`.

## Frozen

`interface.gd`, `errors.gd`, the playtest harness and its verifier. Changing them is an Issue.

## Inside

The fixed Tabs are strip indexes 0..6 forever: opened before any stub tab and never closable, so a stub tab closing never shifts them. Every Page starts hidden and frozen; the launch `grow_tab` on Collection is followed by `select_tab` on the strip's `tab_settled`. A selection kills any running fade, re-shows the Pages still on their way out (the strip hid them), moves the target on top of the PageStack, tweens `modulate.a` on all of them, and applies the freeze rule in the tween's callback. `boot_loader.tscn` is the project's main scene: the loading screen (four noise-driven dots and a bar drawn live into a SubViewport slightly smaller than the window, `tape_screen.gdshader` for a light colour bleed and edge halo), which on the Web mounts the game pack the page downloaded, loads `demo.tscn` under itself, waits for Collection to settle and draw, and lets the dots drift outward and fade. Other Tabs are created on their first click (#281): their synchronous factories and shader compilation would pause the visible Collection if warmed afterwards. `launch-settled` is retained; `tabs-deferred` replaces the unused `tabs-warm` milestone, and `game-shown` still comes from removal of the browser loading overlay. `demo.tscn` is the game: 1920x1080, resizable, stretch disabled (the CRT presentation below handles small windows); its registry maps `map` to the atlas module, `collection` to the owner's framed page (`assets/collection_frame/page.png`, a TextureRect built in `demo.gd`), `sketchbook`, `3d_viewer`, `video_player` to their ports, `playground` to the playground_page desktop, and `flowers` to flowers_page. The Tenant interfaces are the demo scene's only dependency beyond the strip; `shell.gd` itself knows no Tenant. Pixels: the strip's; the Shell draws nothing but white.

The playtest (`scripts/playtest.sh shell`, on `testing/harness_base.gd`) builds the Shell with its own registry — the dummy tenant in four Tabs, a grey Callable-built tenant in `flowers` (so a cross-fade shows in pixels), nothing in `video_player` or `playground` — on an X display at 1920x1080, drives it with real mouse and key events through `Input.parse_input_event`, films the launch and two switches frame by frame, and `verify.py` re-hashes the screenshots, re-reads the film's pixels and checks the logged states, signals and tenant counters independently: seven fixed tabs in order along the bottom, the launch tab stub-sized then grown with its page shown only after the settle, `switch_settled` 0.55..1.0 s after mount, the pressed tint on the clicked tab within 100 ms and gone after 220 ms, the page blend through in-between greys, a switch settling 150..450 ms after the click, lazy creation, a hidden tenant's `_process` and input counters standing still and resuming, close refused by click and by call, the stub's blank page as the eighth tab, a resize to 1440x900 (48 checks). `playtest/browser_play.py` drives the Web export in headless Chrome. Evidence of the accepted run is in `docs/evidence/shell/`.

Each compact fixed tab has a reviewed blue selected still, so the active Page remains identifiable even when two Pages are white.


## CRT presentation (#64)

The demo scene presents the existing Shell through a SubViewport, with a final
Harrison Allen CC0 luminance-preserving CRT shader. Softer aperture-grille lines,
low colour separation and static fine grain follow the owner's reference. Curvature
is .018, with no border or vignette; pure whites remain white. The same warp maps
pointer input before it reaches the Shell. F8 toggles presentation without rebuilding
any tenant; `?crt=0` starts unfiltered. `?qa-crt=1` publishes read-only browser evidence.
The logical desktop is 1080×1080. It scales uniformly by the smaller browser dimension and is centered inside a plain-white exterior. The displayed rect drives mouse, touch, drag and gesture mapping, including terminal releases for drags started inside. Flowers uses that same square fit for its HTML overlay.

The tentabrobpy CC0 Squigglevision shader is the final screen pass after that CRT. It
uses a seamless 256×256 FastNoiseLite texture, a 0.45-pixel displacement and held
3 FPS frames. F9 toggles it independently without changing F8, the Shell or a Tenant.

Collection artwork preview (#189) temporarily hides the outer game frame and fits only the selected painting and its own frame to the Page. X or Escape restores the original frame and visitor position. The shared header uses native browser/window fullscreen; the square desktop scales uniformly. Dollhouse framing brings the visitor closer. Main-gallery white baseboards receive the same material-fill treatment as the cornice, without changing baked geometry or lightmaps. `playtest/collection_preview_check.gd` exercises the private composition with real clicks.


## Proportional windows (#193)

The Collection frame has a corner grip that scales the complete frame uniformly. Opening an artwork temporarily restores full Page scale; closing it restores the chosen frame scale. CRT remains visible over Collection, and Squigglevision starts enabled. F8 and F9 still toggle the effects independently. Private input and shader checks live in `docs/evidence/window-effects-193/`; the frozen historical layout fixtures are unchanged.

## Private review adapter (#199)

With `qa-crt=1` only, `crt_display.gd` inspects visible generic `ProportionalResize` Controls and their parent rect/scale to publish browser pointer-check geometry. #199 explicitly scopes this diagnostic seam exception across the composed Tenants; it supplies no production behavior, and no Tenant interface/error/acceptance file changes. Ordinary gameplay returns before traversal. Collection uniform scaling uses its center as the pivot, including artwork-preview return.

## Accepted character package (#235)

`character/` holds the owner-selected #231 horned visitor's six compatible rigged
profiles, corrected hand atlas and module-local playtest code. It is prepared
for replacing the Collection visitor (done in #236, below).
`scripts/character_package.py` imports only the accepted
package, runs movement/pose/contact/audio checks and exports the Web playtest.
Sound uses contact/action events and native polyphonic playback; original-sample
identification and remaining sound limits are recorded in its provenance and
the dated #235 research note. No Shell public interface/error/frozen acceptance
file changes.

## Collection visitor (#236)

The Collection walks the accepted character. `character/visitor.gd` is a private
adapter with the surface `walk4.gd` already drove (`world_height`, `layers`,
`contacts`, `pose`, `reset_contacts`, `sole_positions`, `sole_support`,
`play_gesture`); the museum still owns position, collision, navigation and camera.
The adapter reuses the package's rig, idle and walk clips, face and hand material,
blink, speed-to-cadence coupling and captured house footsteps, which play when a
foot actually lands. It adds one light that reaches only the visitor and stays on
the viewer's side, because the museum's baked light alone renders the character
much darker than the accepted playtest. Shift sprints and Space jumps in the museum;
tools and doors remain playtest-only. The accepted clips are not
IK-locked, so the late-stance foot slide seen in the playtest is unchanged.
`visitor159/` is no longer loaded. `playtest/visitor174_check.gd` and
`visitor174_capture.gd` now assert this visitor. No Shell interface, error or
frozen harness file changed.
