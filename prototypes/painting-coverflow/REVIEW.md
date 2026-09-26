# Review — issue 127

Scope: new `prototypes/painting-coverflow` files against build branch start `b41bfde`. Existing unrelated work in the checkout was excluded.

## Standards
One keyboard-focus defect was independently reproduced in Chromium: arrow navigation from a focused card left focus behind. Fixed by moving roving focus only when a painting already has focus; the regression is in browser acceptance. Catalog paths and museum URLs are restricted; metadata uses textContent. No frozen Godot files or API modules changed.

## Spec
The Apple guided tour was watched before building. Six original RISD painting images from the existing 3D scans catalog appear inside the supplied blue frame. Wheel, drag, touch, side-click, slider, keyboard and enlarged view were verified. This is a catalog snapshot and standalone browser viewer, not a live full-collection query or an embedded Godot module. Exact Apple timing was not measured; motion was tuned from inspected video.

## Ponytail (ultra)
Lean already. Native CSS transforms, native range and dialog, existing Effect dependency and catalog; no new API or runtime dependency.

ponytail: 0 findings, 0 fixed, 0 accepted

## Verification
Repository `scripts/check.sh`: passed. TypeScript typecheck: passed. Browser acceptance: six loaded images, input paths, first/last limits, dialog, keyboard focus, mobile and reduced motion passed. Extended motion checks verified intermediate frames, interrupted transitions, mouse drag and touch swipe. Desktop/mobile screenshots and a browser recording are in evidence.

Verdict: ready for browser review. This is not a release-wide ship verdict.

## Issue 128 follow-up

Reproduced actual side-face click failure on the shared viewer: selected index remained 2 after clicking the visible center of painting 1. Event tracing showed the transparent 3D scene received pointerdown rather than the visible button. Setting scene pointer-events to none and painting pointer-events to auto made both left/right center-face clicks pass without changing drag handling.

Removed the visible caption row and previous/next buttons; kept the scrubber, accessible announcement and enlarged-view metadata. Updated acceptance for the new layout and added the exact failed clicks. Full browser acceptance on the tailnet URL, TypeScript check, repository baseline and diff check passed. Desktop/mobile screenshots refreshed. No debug instrumentation was added to application code.

## Native Sketchbook integration — issue 129

Scope: this issue’s staged changes against `fb4f667`; unrelated Playground and Shell demo edits excluded. This is a prototype review, not a release-wide verdict.

### Standards
One finding fixed: catalogue and texture failures now return the existing `sketchbook.asset_missing` error through desktop creation before constructing the viewer. The original frame and every painting texture are validated; initial selection is clamped. The independent reviewer verified the correction. No remaining material standards findings.

### Spec
One finding fixed: horizontal wheel input was missing. Both horizontal directions now pass in the exported browser app. Godot Web maps positive browser deltaX to WHEEL_LEFT, confirmed in its [display server source](https://github.com/godotengine/godot/blob/master/platform/web/display_server_web.cpp) and with real browser input; the viewer follows the original browser prototype’s direction. The original asset hashes are unchanged, the book has no surrounding frame, and native drag/raise/tab lifecycle and soft shadows were visually checked.

### Ponytail (ultra)
Lean already. Native drawing, controls and the existing window-dragging path; no new dependency or API layer.

ponytail: 0 findings, 0 fixed, 0 accepted

### Verification
`scripts/check.sh` and `git diff --check` passed. `modules/sketchbook/playtest/coverflow.mjs` passed against the actual Tailscale export: painting clicks both directions, enlarge/Escape, keyboard, vertical and horizontal wheel, painting drag, slider endpoints, viewer movement, book drawing and page turns, book drag/resize, stacking, hidden-tab freeze/resume and viewport resize. The updated screenshots and result are in `evidence/native/`. The six museum-image hashes match the catalogue; the book PNG is byte-identical to the original. No new generation spend.
