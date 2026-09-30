## Problem or desired outcome
After213, map149 still fails82line findings:74 authored literal cases and8third-party cases. This follow-through fixes only the74authored cases without changing any resulting text, embedded JavaScript/GLSL, museum record, public behavior or asset.

## Evidence or current behavior
Build07bde70c/runtimebd870c2d has193tracked findings (82line/111other). The74literal cases are recorded in docs/evidence/comment-wrap-211/remaining-lines.json. Existing213 preserves every literal token and cannot split these cases. A separately named scope is required for constant string decomposition, including the named acceptance/historical scripts.

## Expected behavior
Represent the same string values using parenthesized adjacent literal concatenation where required by existing100character lint. Preserve the exact resulting string bytes, including spaces/newlines/escapes, so JavaScript/shader inputs and displayed metadata remain identical. Do not reformat the contents of any embedded language or change museum wording.

## Acceptance criteria
1. Explicitly authorize constant-string expression decomposition only for the74recorded long-literal cases in the exact manifest below, including frozen acceptance/historical files. The normalized executable tree outside these decomposed literals, signatures, errors, declaration/initializer order, commentwords/types, assertion values and module seams remain unchanged. Each replaced literal's full evaluated String must be byte-identical under native Godot; no provider, runtime helper or dependency.
2. Keep one runnable focused preservation check with before/after hashes, exact native String equality and tree/comment preservation after collapsing only the recorded constant concatenations. Native Godot accepts all selected files. Reject unsafe outputs; literal chunk cuts must never split an escape sequence.
3. Remove all74authored literal line findings without adding lint categories/file-length violations or exceptions. Run installed-tool scripts/check.sh and git diff --check. Report the remaining8third-party/111other findings honestly; do not weaken rules or claim whole-gate PASS.
4. Preserve all12protected assets, museum/provenance files and square173; refresh exact native/private export proof with18Webwindow-input/sevenTabs/fourmain-hoverScans/fivefits. Inspect pictures and update build/v0.1.0, PR166/map149/checkpoint before closure. Full162 and final owner approval remain open; automation remains enabled.

## In scope
Only the74literal cases recorded at9864f723, carried unchanged throughbd870c2d/07bde70c, in:

```text
docs/evidence/floor-selection-186/restore.gd
docs/evidence/owner-world-177/passage-current/repair.gd
modules/collection_data/storage_adapter.gd
modules/flowers_page/flowers_embed.gd
modules/playground_page/arena_embed.gd
modules/playground_page/journal_window.gd
modules/playground_page/websurfer_window.gd
modules/sculpture_viewer/catalogue.gd
modules/sculpture_viewer/playtest/record_selection.gd
modules/sculpture_viewer/playtest/window_resize_check.gd
modules/shell/crt_display.gd
modules/shell/playtest/visitor174_capture.gd
modules/shell/playtest/visitor174_check.gd
modules/shell/prototype/gallery_walk4/walk4.gd
modules/shell/square_chrome.gd
modules/sketchbook/global_chatroom.gd
modules/sketchbook/painting_flow.gd
```

Plus narrow preservation/native/private proof. Constant concatenation syntax is newly named authority; interpreted/evaluated string content remains frozen. Existing GDScript parser/Godot tools and composed acceptance checks are reused.

## Out of scope
Changes to resulting string bytes, embedded-language formatting or behavior, museum metadata/PROVENANCE wording, recorded assets/source hashes, other literal cases,8third-party or111nonline findings, renames/declaration reorder/new dependencies/interfaces/errors/seams, UI changes, public redistribution, generation/provider/spend/bakes/settings/billing/hosted retries/releases, other worktrees.

## Verification
Pinned gdtoolkit4.5.0 lint; existing tree/comment checks plus native Godot equality for each decomposed constant, native check-only files/current import, protected hashes, installed scripts/check.sh, finalrange whitespace, exact shared export/Web state/image proof. Old historical artifact bytes remain available at the fixed commit.

## Platforms affected and sync authorization
Existing integrate-square-164 build/v0.1.0 and PR166 only, under owner's ongoing map149 full implementation authority. Main and square-containment-173 remain untouched.

## Dependencies and approvals
Follows completed213 and partial209/210. Reversible unpaid remediation is authorized by the continuing owner request; no repeated permission prompt. Whole162 remains needs-work; Reid must personally use and approve final integrated build, and automation stays enabled until verified map completion.
