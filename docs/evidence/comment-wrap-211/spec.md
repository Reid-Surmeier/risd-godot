## Problem or desired outcome
The complete map149 build cannot pass its repository lint gate. Scoped formatting210 preserves exact comment tokens, leaving166 long comments even though wrapping them changes no runtime behavior.

## Evidence or current behavior
At build5c721015/runtime78001be1 the tracked gate fails447 findings:336 line-length and111 other. Two new scratch harness trials still fail gdtoolkit4.5.0 stability through duplicated header comments; no trial source was accepted. This issue extends only comment layout, not frozen runtime behavior.

## Expected behavior
Wrap the166 standalone long comments in the exact manifest below to the existing100-character lint limit. Preserve the full ordered word sequence, comment type (# versus ##), punctuation, code references and documentation meaning; normalize only whitespace and repeated comment prefixes. Code, literals, callable signatures, initializer order, test assertions/inputs/outcomes, errors and module seams remain byte-equivalent except comment lines.

## Acceptance criteria
1. Explicitly scope comment-only reflow in the named files, including frozen interface/error/acceptance/support files. No runtime expression or literal changes, declaration moves, renames, helper, dependency or lint-rule exception.
2. Preserve each original comment's words and their order exactly, including punctuation and references. Compare normalized code trees and literal tokens across every changed file; execute native Godot parsing. Keep a runnable focused preservation check and before/after hashes.
3. Run installed-tool scripts/check.sh and git diff --check, report remaining tracked/full findings honestly; preserve metadata/GLBs/room/lightmaps/movies and square-containment-173. Do not count a baseline failure as PASS.
4. Refresh exact private Web proof, sevenTabs/four main-hover scans/fiveviewport fits/window-input checks, inspect images and update PR166/build/map149/checkpoint before considering closure. Full review162 and hands-on owner approval remain open; automation stays enabled.

## In scope
The166 standalone long comments in the exact files below, plus private testing/review evidence. This replaces210's exact-token restriction only for these comment lines;210's formatter constraints still apply to code changes.

```text
modules/atlas/errors.gd
modules/atlas/interface.gd
modules/atlas/playtest/harness.gd
modules/flowers_page/errors.gd
modules/flowers_page/flowers_embed.gd
modules/flowers_page/interface.gd
modules/playground_page/arena_embed.gd
modules/playground_page/interface.gd
modules/playground_page/journal_paper_turn.gd
modules/playground_page/playground_page.gd
modules/playground_page/playtest/harness.gd
modules/sculpture_viewer/desktop.gd
modules/sculpture_viewer/playtest/hover_turn.gd
modules/sculpture_viewer/viewer.gd
modules/shell/boot_loader.gd
modules/shell/demo.gd
modules/shell/desktop_icons.gd
modules/shell/hover_glow.gd
modules/shell/interface.gd
modules/shell/playtest/harness.gd
modules/shell/prototype/gallery_walk4/dollhouse_shot.gd
modules/shell/prototype/gallery_walk4/identity/native_render_check.gd
modules/shell/prototype/gallery_walk4/navigation_check.gd
modules/shell/prototype/gallery_walk4/painting_asset.gd
modules/shell/prototype/gallery_walk4/shot.gd
modules/shell/prototype/gallery_walk4/visitor_check.gd
modules/shell/prototype/gallery_walk4/walk4.gd
modules/shell/shell.gd
modules/shell/window_shadows.gd
modules/sketchbook/desktop.gd
modules/sketchbook/drawing_surface.gd
modules/sketchbook/errors.gd
modules/sketchbook/freehand.gd
modules/sketchbook/interface.gd
modules/sketchbook/paintbox.gd
modules/sketchbook/paper_turn.gd
modules/sketchbook/playtest/harness.gd
modules/sketchbook/sketchbook_window.gd
modules/tab_strip/interface.gd
modules/tab_strip/tab_strip.gd
modules/video_player/errors.gd
modules/video_player/video_player.gd
```

## Out of scope
Runtime/art changes, literal/JavaScript changes, other lint categories, all untracked owner files, generated and third-party sources, public redistribution, provider calls/spend/bakes/releases and frozen behavior changes.

## Verification
Existing native Godot parser, strict normalized-code/comment-word checks, installedgdtoolkit4.5.0 lint, existing full-app/browser input checks and current source-asset hashes. Use existing seams; no acceptance test changes beyond authorized comment wrapping.

## Platforms affected and sync authorization
Existing integrate-square-164 build/v0.1.0 only. Preserve every other worktree. Issue209 hostedCI diagnostics remain read-only.

## Dependencies and approvals
Follow-through of209/210 within owner-authorized full implementation of map149. Reversible unpaid formatting continues without another permission prompt. Final integrated-build hands-on approval remains Reid's explicit gate and is never inferred.
