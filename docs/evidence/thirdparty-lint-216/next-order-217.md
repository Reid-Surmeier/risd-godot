## Problem or desired outcome
Map149 still fails110authored lint findings after215/216. Resolve only85class-definitions-order findings using native-compatible declaration placement without changing behavior or asset/string values.

## Evidence or current behavior
Pinned gdtoolkit4.5.0 reports85order findings on5a213901 in the exact named files below. FullinstalledcheckFAIL113=110tracked authored+3owner-untracked. Current244 private runtime/native/Web evidence passes bounded checks; full162 remains needs-work.

## Expected behavior
Place declarations in existing lint order while preserving the exact executable bodies, initializer evaluation order, public declarations/signatures, errors, literal values, comment words/types and every cross-module seam. Move only complete declaration/comment blocks; do not sort variable initializers blindly. Reject a move that would change native declaration or initialization behavior, and retain the finding with evidence rather than weaken rules.

## Acceptance criteria
1. Explicit authority covers declaration-placement syntax only for85recorded order findings in these named files. Frozen interfaces/errors/tests are unchanged. Keep variable initializer sequence and all function bodies/executable tokens/value bytes identical; public signatures/dependencies/seams/assets remain frozen. Record one focused before/after declaration-aware preservation check and native parse results. No name/logic/category changes or rule exceptions.
2. Trace declaration consumers/initialization before applying minimal block moves. Verify lint reductions with actual installed scripts/check.sh and tracked-target lint; retain other25authored findings and3original untracked failures honestly. Any unsafely movable order case remains open, not guessed fixed. Finalrange git diff --check.
3. Reuse composed acceptance checks on exact changed runtime: native import/seams,18Webinput checks,33states/sevenTabs/fourmain-hoverScans/fivefits, protected12assets/museumrecords and square173 preservation. Inspect exported pictures; update existing build/v0.1.0, PR166/map149/checkpoint/private working build and read back before closure. Whole162 and actual hands-on owner approval stay open; automation stays enabled.

## Exact file scope

```text
modules/atlas/atlas_window.gd
modules/playground_page/playground_page.gd
modules/sculpture_viewer/viewer.gd
modules/shell/crt_display.gd
modules/shell/prototype/gallery_walk4/painting_asset.gd
modules/shell/prototype/gallery_walk4/render_diagnostics.gd
modules/shell/prototype/gallery_walk4/walk4.gd
modules/shell/shell.gd
modules/shell/window_shadows.gd
modules/sketchbook/desktop.gd
modules/sketchbook/drawing_surface.gd
modules/sketchbook/paintbox.gd
modules/sketchbook/sketchbook_window.gd
modules/tab_strip/tab_strip.gd
```

Exact85diagnostics are recorded in docs/evidence/thirdparty-lint-216/lint-owned.log and follow-through manifest; current classes/functions must be inspected before editing.

## Out of scope
Other25authored findings, renames, variable initialization reordering, changed function bodies/logic/public interfaces/errors/frozen acceptance values/comments/literal values, third-party source/rules/targets, assets/provenance/museum metadata, owner untracked files/otherworktrees/main, generation/provider/spend/bakes/hosted retries/settings/billing/public redistribution/release/owner acceptance.

## Platforms and authorization
Existing integrate-square-164 build worktree and one build/v0.1.0 PR166 under continuing map149 owner implementation authority. No duplicate writer or ticket worktree. Start only after finishing current215/216publication; final162 review/rights/temporal/readability/historical/owner gates remain explicit.
