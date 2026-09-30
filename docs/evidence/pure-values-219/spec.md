## Problem or desired outcome

Map #149 still fails 30 declaration-order findings after #217's safe moves. Their initialized public fields follow private fields; #217 correctly preserves the exact initializer sequence and leaves these cases unresolved.

## Evidence or current behavior

`6cb7e87e` records the 30 exact declarations in `docs/evidence/declaration-order-217/retained-order-findings.json`. Full installed check fails 58: 55 authored tracked plus three original untracked findings. The other 25 authored findings are outside this ticket.

## Expected behavior

Place public instance fields before private fields while preserving every initialized value and all observable behavior. This ticket explicitly permits changing the relative placement of side-effect-free literal, empty-container and built-in value initializers. It does not permit changing the order of node/resource allocations, calls into other scripts, or dependent field evaluation.

## Acceptance criteria

1. Inspect all initializers and their consumers before moving complete declaration/comment blocks. Record a focused before/after check proving exact declarations/function bodies/comments/signatures/value syntax, dependency order and the sequence of all effectful allocations/calls. Only pure value initializers may cross those operations. Reject an initializer whose purity or dependencies cannot be established; record it honestly.
2. A native before/after initial-state check must compare every declared field, including private fields and fresh object classes, without treating object IDs or temporary script paths as changed user data. Native parses/import and actual installed lint/check must show the real remaining counts. No rule exceptions, untracked-file edits or hidden skips.
3. Reuse exact composed acceptance: 18 browser window/input checks, 33 states/seven Tabs/four main-and-hover scans/five square fits, protected assets/museum metadata/square173 preservation. Inspect exported pictures. Update the existing build/v0.1.0, PR166/map149/checkpoint and private working build, with readback before closure. #217 remains open until its retained cases are verifiably addressed. #162 and final hands-on owner approval remain open; automation remains enabled.

## Exact file scope

- modules/playground_page/playground_page.gd
- modules/shell/crt_display.gd
- modules/sketchbook/desktop.gd
- modules/sketchbook/drawing_surface.gd
- modules/sketchbook/paintbox.gd

## Out of scope

Changes to initializer expressions/function bodies/names/public interfaces/errors/frozen acceptance values/seams/dependencies/assets/provenance/museum metadata; other 25 authored lint findings; private constructor-call reorder; generation/provider/spend/bakes; hosted retries/settings/billing; public redistribution/release/owner acceptance; main/other worktrees/owner untracked files.

## Verification and authorization

Continuing owner map149 implementation authority, existing integrate-square-164 worktree, one build writer and PR166. Start only after current #217 exact Web/picture/private publication/readback is finished. This named scope replaces #217's exact-initializer-sequence constraint only for independently proven pure-value interleaving; the original evidence remains historical.

