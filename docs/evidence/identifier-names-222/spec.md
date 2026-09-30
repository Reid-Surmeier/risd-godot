## Problem Statement

Map149 verification still fails25authored tracked findings after219. Resolve only17identifier-style findings: nine implementation preload aliases and eight function-local geometry names, preserving behavior.

## Solution

Keep every runtime behavior, public function/error/acceptance contract and generated asset unchanged. Rename private implementation preload aliases `_Impl` to `_IMPL` and the existing geometry locals X/X0/X1/Y0/Y1 to lowercase equivalents in their own functions. Reject collisions; change only identifier tokens and their exact consumers.

## User Stories

1. As the owner, I want real verification to accept existing behavior without weakening lint or changing the experience.

## Implementation Decisions

Explicit frozen-file authority names ONLY the internal `_Impl` alias and its internal references in modules/atlas/interface.gd, modules/flowers_page/interface.gd, modules/playground_page/interface.gd, modules/sculpture_viewer/interface.gd, modules/shell/interface.gd, modules/sketchbook/interface.gd, modules/sound_cues/interface.gd, modules/tab_strip/interface.gd, modules/video_player/interface.gd. No public callable/signature/result/error/dependency/seam/acceptance value changes. Scope also names function-local X0/X1/Y0/Y1 in modules/shell/prototype/gallery_walk4/painting_asset.gd and the four existing function-local X declarations/consumers in modules/shell/prototype/gallery_walk4/walk4.gd. This exact-file exception is necessary under the project frozen-interface policy; no other frozen content is authorized.

## Testing Decisions / acceptance criteria

1. Read all consumers/callers and check destination identifier collisions before edits. One focused normalization/token check proves every file equals its baseline modulo only the explicitly mapped identifiers; function order/control flow/types/signatures/literals/comments/resource paths remain exact. Eleven native parses pass.
2. Run actual installed scripts/check.sh/tracked lint: expected25to8authored tracked findings, original3untracked failures retained. No rule exception, hidden skip, source asset or untracked edit. Verify protected12assets/museumrecords/square173 and git diff --check.
3. Reuse exact composed18browser input/window and33state/sevenTab/fourmain-hoverScan/fivefit checks. Inspect current exported pictures, publish private working build and fresh PR166images, update map149/checkpoint/buildv0.1.0 and read back before closure. Final162/ownerreview and automation remain open. Existing integrate-square-164, one writer, no ticketworktree. Start after219publication/readback; no approval pause for authorized reversible work.

## Out of Scope

Other8authored findings (four duplicate loads, three excessive-return functions, one file-length), function/API/error/seam/dependency/acceptance-value changes, initializer reorder, source/provenance/assets/museum metadata, owneruntracked/otherworktrees/main, generation/provider/spend/bake/hostedretry/settings/billing/publicredistribution/release/ownerapproval.

## Further Notes

Continuing owner149 implementation authority. Runtime6d126dbb is technically/visually verified in docs/evidence/pure-values-219 and delivered privately. Whole162 remains needs-work; currentfine-text/temporal/historical/rights/performance/ownerapproval findings remain honest.
