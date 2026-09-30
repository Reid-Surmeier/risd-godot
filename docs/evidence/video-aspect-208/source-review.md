# Focused208 source review

Fixed125927da; candidate36cb27af. Independent read-only Standards/Spec/Ponytail axes, live208 and repository standards.

## Standards
No verified breach/baseline smell. Native aspect/image over retained playback texture stays within video_player. Source selection/download completion share _select_video; player seek/play/loop/hidden/fullscreen input unchanged. Children ignore pointer input; full playback rectangle retained. Frozenfiles/media unchanged. NativeRED14fail/GREEN14aspectPASS independently inspected; browser/visual/build readiness pending at source review.

## Spec
No implementation defect/scope creep. Decodedsource proportions/grayblackopaqueletterbox/chrome/frozenstate preserved. Nativeaspect14PASSvs14RED. Initial interaction evidence gap: aspectfixture drives pause/seek/F but does not assert playback/hide; actual206focusregression18PASS and upcoming exported208play/source/hide checks supply that separately.480×244 source has0.055%sample-aspect metadata difference; fit follows decoded dimensions, not exact original display-aspect guarantee.

## Ponytail (ultra)
ponytail: 1 findings, 0 fixed, 1 accepted

Finding: full-rect TextureRect.STRETCH_KEEP_ASPECT_CENTERED could remove nativeAspectRatioContainer/manualratio(-5runtime lines).
Accepted: retain native container to expose actual source-fitted child bounds to private evidence without duplicating the fitting calculation; unchanged full playback/input rectangle, no custom math/dependency.

No focusedsource report establishes whole-map readiness/owner approval.
