## Problem or desired outcome
Map149 still cannot pass repository lint. The integrated build should preserve all accepted behavior and artwork while meeting the existing checks.

## Evidence or current behavior
At runtime9864f723/builde0d6c301,281tracked findings remain:170line-length and111other. The86nonliteral code-layout findings concentrate in seven named files. Pinned gdtoolkit4.5.0 trials after211 still add duplicated comments in two harnesses, produce invalid native lambda indentation in square_pages, and expand Playground above the1000line limit. Trial outputs were rejected; sources untouched. Two inline comments are also overlong.

## Expected behavior
Resolve these86code-layout and twoinline-comment findings using native-compatible source layout. Preserve executable meaning, callable signatures, every string/literal, initializer order, errors, assertion inputs/outcomes and module seams. Keep Playground under the existing file-length limit. Do not accept formatter output merely because its own parser passes.

## Acceptance criteria
1. Explicitly authorize whitespace/parenthesization/line-continuation and comment-layout changes only in the exact named manifest, including frozen acceptance files. Preserve normalized executable trees, all literal values/tokens, callable signatures, declaration and initializer order, paths and assertion behavior. Inline comment words/order/punctuation/type remain unchanged after normalization; no duplication/loss.
2. Use the existing strict preservation and native Godot parser checks. The native parser must accept every selected output; check formatting changes against fixedpoint9864f723. Record hashes and one runnable focused check. Formatter output may guide manual wrapping where its own output violates native syntax/comment preservation/file length; no new dependency or runtime helper.
3. Remove the named88line findings without new lint categories, file-length violations or lint exceptions. Run actual installed-tool scripts/check.sh and git diff --check. Report the remaining74literal/8outside-scope and111other findings honestly. No whole-gate PASS while any fail remains.
4. Verify protected12assets/museumrecords and square173; refresh exact native/full private Web proof with18window-input/sevenTabs/fourmain-hoverScans/fivefits. Inspect results and update PR166/build/map149/checkpoint before closure. Full162review and hands-on owner approval remain open; automation stays enabled.

## In scope
Only the86nonliteral code-layout findings and twoinline comments recorded in docs/evidence/comment-wrap-211/remaining-lines.json at9864f723, plus private evidence, in:

```text
modules/playground_page/playground_page.gd
modules/playground_page/square_pages.gd
modules/playground_page/playtest/harness.gd
modules/sketchbook/playtest/harness.gd
modules/sculpture_viewer/viewer.gd
modules/sketchbook/painting_flow.gd
prototype/mr-baby-paint-audio/main.gd
modules/shell/prototype/gallery_walk4/walk4.gd
modules/tab_strip/tab_strip.gd
```

This replaces210's native-formatter-only constraint for these named layout cases; executable and frozen behavior restrictions remain binding. No interface/error file change or new seam is needed. Use existing highest composed application checks and existing preservation checks.

## Out of scope
Literal/embeddedJavaScript changes, nonline lint categories, third-party/generated and original untracked owner files, declaration reordering, renames, helpers/dependencies, UI/art/runtime behavior changes, providers/spend/bakes/settings/billing/hosted retries/releases/public redistribution. No changes in other worktrees.

## Verification
Existing strict normalized-tree/literal/comment checks, native Godot check-only parsing and composed full-build Web/window checks. Actual gdtoolkit4.5.0 check outputs before/after, existing protected hashes. Trials that fail native/comment preservation or increase lint are rejected rather than applied.

## Platforms affected and sync authorization
Existing integrate-square-164 build/v0.1.0 only, under the owner's full map149 implementation instruction. PR166 remains the single build PR; main and square-containment-173 remain untouched.

## Dependencies and approvals
Follow-through of209/210 after scoped211 completed. Reversible unpaid layout work is authorized by the existing continuation; no repeated permission prompt. Owner must personally approve the final integrated build; no approval inferred from silence or source checks. Whole162 remains needs-work.

