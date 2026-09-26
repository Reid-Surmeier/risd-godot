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
