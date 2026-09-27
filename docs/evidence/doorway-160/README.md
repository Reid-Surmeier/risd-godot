# #160 — doorway and baseboard prototype

Question: can the far rectangular doorway's casing, plinth, and viewer-right
baseboard become a coherent reference-led asset with real profile geometry,
UV material, offline lighting and exported-browser evidence?

This is `prototype/160-doorway`, isolated from `main` and the build branch.
It is not a full-gallery pass. No character is instantiated by the showcase.

## Observation and implementation

The doorway crop shows a flat ivory casing with narrow inner relief, a broad
head and overhanging cap, a cream recess, and baseboard terminating against
the plinth. Its resolution does not establish exact molding radii or survey
measurements. The adjacent bench and upper room cornice are context, not
new assets in this experiment. Existing 1.9 × 2.8 m opening is retained.

The initial model used rectangular white blocks. The candidate extrudes an
11-point casing section and 9-point skirting section, with a shaped head cap
and beveled plinth, closed ends, meter-based UV1, authored ivory albedo and
lightmap UV2. The existing Muse wall/oak materials supply style continuity.
The far wall is tinted blue and a broad neutral offline lamp separates the
ivory from the warm floor. This is a deterministic reference-derived material
study, not a new Muse image. Spend: USD 0.

## Evidence and reproducibility

1. `browser-before/`: original saved asset, four matched exported Web views
   at 1600×1200 and 720×540. `before/` is the corresponding native capture.
2. `after/`: rejected first native candidate. Mirrored normals caused black
   trim. `corrected/` and `browser-after/`: fixed normals/closed caps, before
   the last color/light correction. These are retained as failure evidence.
3. Final evidence and validation are recorded below after capture. The
   showcase uses the actual saved room and native materials. It excludes the
   visitor and shell; it is not a screenshot of the complete game interface.

Run `godot --path . --rendering-method gl_compatibility` to inspect the saved
scene. Left/right switches four detail views and one wider context view. Browser export:
`godot --headless --path . --export-release 'Doorway Prototype' build/doorway/index.html`.
The capture command is
`godot --path . --rendering-method gl_compatibility --script modules/shell/prototype/gallery_walk4/doorway_prototype_capture.gd -- /tmp/doorway-captures`.
It checks that both mirrored casing fronts receive light, catching the
observed black-side failure. Re-bake after source changes with
`python3 modules/shell/prototype/gallery_walk4/bake/run.py`.

## Original candidate limits (see repair below)

The inherited recess photo card and neutral threshold remain visible in the
saved-room showcase; the live gameplay viewer hides the card and overlays its
navigation-room passage. Therefore the static showcase alone cannot pass the
full traversal appearance gate. It also does not establish a new arch-end,
bench, or upper-cornice treatment. These limits must remain in the blind-review
and decision record; a successful profile check is not visual acceptance.

## First candidate result and verification

`final/` and `browser-final/` contain the final four angles at both sizes.
The close corner has continuous baseboard-to-plinth contact, closed profile
ends, and lit casing faces. The final wall is visibly blue; its saturation
and mottling still require comparison with the softer reference. The flat
gray threshold is inherited and remains a visual weakness. No passing variant
is selected yet: independent Astra-medium visual review remains pending.

Verified on 2026-09-27:

- `scripts/check.sh`: passed; `git diff --check`: passed.
- Native profile capture: `DOORWAY_PROFILE failures=0` at both sizes.
- Existing doorway floor check: all eight cases 9/9 visible samples,
  `DOORWAY_FAILURES 0`.
- Existing navigation check: both portal roundtrips, drag/orbit/pan/wheel,
  artwork picking and cancellation passed, `NAV_FAILURES 0` (23 paintings).
- Exported Chrome capture: eight final images, zero recorded page errors.
  This static export does not claim a browser traversal video.

Final bake: 51.81 seconds, `BAKE_OK users=120`, saved scene and lightmap.
The editor also printed a list-erase condition and an absolute-path lookup
error on teardown; its process exited 0 and the saved asset rendered in
native Compatibility and Chrome. The full gallery/visitor regression suite
was not run; only the relevant doorway/navigation checks were run.

Final SHA-256:

- `baked/room.tscn`: `0f6ddc63fa283fd89ca70032c3d2ba860fd20d09b57ee674b75966ec2865804f`
- `baked/room.exr`: `e04d4d0b099cbf4e3b4963d65306195e3aa87d13610f31268cba56d9c6d6c174`
- `baked/room.lmbake`: `a0b4c11cc9075e8c37deec9b427069eef717ec1164b2a089dc63e534d857a3d4`

The later batch should reuse profile extrusion → UV1 material → UV2 unwrap
→ saved bake → identical native/Web cameras → independent reference review.
Do not propagate this candidate until the recess/threshold and full-game
appearance have passed that last step.

## Repair after independent review

The first Astra-medium blind review failed the full slice; see
`BLIND-REVIEW-1.md`. The accepted profile geometry was retained. The repair
removes the photographic backplate, models the rear paneled doorway, adds
returning baseboard profiles, and uses textured cream surfaces and a warm oak
floor. Reversed ceiling/floor normals caused missing baked illumination in
the inherited recess; those normals are now inward/upward respectively.
The duplicate live-game white recess is removed at the far door, so the
gameplay passage and showcase use the same saved geometry. Blue-wall
saturation is reduced, local recess lighting is baked, and the EXIT signs
use explicit vector lettering.

`repair-native/` and `repair-browser/` contain the new matched four-view
captures. `repair-gameplay/` contains 1600- and 720-width approach/return
screenshots and real keyboard-driven browser roundtrip videos. The prototype
launcher hides the inherited visitor and its contact shadow; no character
asset is changed. The destination remains the existing white navigation test
room; this issue does not redesign that separate room.

The rear-door panel details and molding dimensions are an interpretation of
the low-resolution reference, not a surveyed reconstruction. The arch end,
benches and upper room cornice remain outside this small slice. A second
independent visual verdict is still required; these repairs do not constitute
self-approval.

Repair validation: repository check, profile/backplate/floor-light check,
doorway floor check, and both native portal roundtrips passed again.
Exported browser gameplay completed `gallery -> far` and `far -> gallery`
at both widths with zero recorded console or page errors. The videos decode
to 174 frames at 1600×1200 and 99 frames at 720×540. The return camera faces
back into the gallery, following the existing gameplay behavior.

The additional `repair-browser/*-context.png` views show the unchanged bench
and upper room cornice in relation to the far doorway. The nearest existing
bench remains centered at z=-17 m, 9.3 m from the far wall. These context
assets are shown for spatial judgment, not certified by this doorway repair.

Repair bake: 56.55 seconds, `BAKE_OK users=119`. The same two Godot editor
teardown messages occurred; subsequent native and browser renders succeeded.
Source and outputs are retained. Repair SHA-256:

- `baked/room.tscn`: `45b10c5e4f761d82fbda4b636538a3aa13c2ef2a12eb8ab89de2e94ca25a6e05`
- `baked/room.exr`: `9c2ec24469763f204f7ee548e73cd5794268ced1dded18372b457bb13cf779b3`
- `baked/room.lmbake`: `5b34664c81462cf5695c120774e3fe9ccba998541f3d629e2c20aa5468a79068`

Browser traversal can be reproduced with
`node modules/shell/prototype/gallery_walk4/doorway_prototype_walk.cjs <served-export-url> <output-folder>`.
The launcher uses `?gameplay=1`; its default is the saved-asset inspection.
