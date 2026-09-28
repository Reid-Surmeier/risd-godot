# Cornice batch checkpoint — 2026-09-28 UTC

**Visible cornice batch PASS**, independently reviewed by fresh external
GPT-6 Astra medium, image-only. See [the scoped verdict](BLIND-REVIEW-SMOOTH.md).
The stone arch/portal and both benches remain open; #167 is not complete.

This is the isolated `prototype/167-cornice` trial, based on the selected #160 doorway prototype at `ef4d8b76`. No part of this batch is in the build branch. The arch/portal and two benches are unchanged and remain open under #167.

## Source and treatment

The RISD doorway crops show a pale upper molding. The skylight crop confirms the adjacent vault context but does not resolve the corner profile. These are photographic references, not survey dimensions:

| Reference | SHA-256 |
| --- | --- |
| [`door-far-crop.png`](reference/door-far-crop.png) | `f27b73f89da8bb6cda3718f9c6e71c5d4f6ab7fc3ae825fc002c87290f41622c` |
| [`door-arch-crop.png`](reference/door-arch-crop.png) | `6db20b89ef019e278646ae736268f5ff2e77d9a378d71d4c87ea8e7232bcf858` |
| [`skylight-crop.png`](reference/skylight-crop.png) | `1870aa6fc6576a4b3d5f17380106a34c294c2535ecaeba8f950a39b8cccd0091` |

The existing two upper boxes and sloped fascia were replaced by the already proven doorway `_trim_profile` extrusion on all four walls. The section has UV1 in metres. The original record incorrectly claimed 25 mm lightmap texels: the renamed cornice texture actually missed the doorway-only condition and received 120 mm texels. The repair below corrects that condition. The hand-authored [`cornice-ivory.svg`](../../../modules/shell/prototype/gallery_walk4/textures/cornice-ivory.svg) derives from the accepted doorway ivory SVG with paler colors; SHA-256 `35595107453dbded8fa66610d0e6d759e8650c32dc6129c83fffcfbeb0adaa76`. Material emission is isolated to this new texture in the saved-room bake. Provider: local manual SVG edit; count: one; cost: USD 0. No Muse call.

The rejected `3a968c20` bake hashes were `room.tscn` `9dfd7a4ec946f3a8f82f411d719b22f32339f0dbcb935f92dbd9b55e0026ee1c`, `room.exr` `530d815ebfce06813297d9d0f9ba42419d6b5807f42a7a244b8cead9e37a19cd`, and `room.lmbake` `95b92e91fd77afd3ac4528bfeffec69dd5db9246a6a54c17800cd9621c334f4b`.

## Visual evidence and review

[`before/`](before/) and [`browser-finish/`](browser-finish/) contain matched 720 and 1600 square views of the long wall and both upper corners; [`finish/`](finish/) contains the native Godot views. [`index.html`](index.html) is a side-by-side browser sheet. Three independent GPT-6 Astra medium image-only reviews saw only the reference crops and each candidate's final captures:

1. Initial candidate **FAIL**: high severity, both end-wall corners stopped against flat bands; medium, tan trim with strong dark stripes.
2. Continuous-profile repair **FAIL**: corners aligned and readable at 720, but the brown finish and wide dark bands still failed reference fidelity.
3. Pale SVG plus small emission **FAIL**: all six views remain too brown and too close to the ceiling color; long-wall views read as alternating flat stripes rather than softer molded plaster. Corner continuity and 720 readability pass. This trial is preserved at `3a968c20` and in `finish/` / `browser-finish/`.

## Repair diagnosis and current candidate

Five isolated visual trials followed the reproduced failure. Correcting the ceiling-tint override and 120 mm UV unwrap alone made the plaster only slightly lighter. Correcting its reversed triangle winding improved the corner lighting. Replacing the angular steps with a sampled roll and cove removed the broad flat bands. A neutral cornice-only fill addresses remaining warm contamination from the vault bake. Self-inspection then found cross-run bands at the arch corner: horizontal albedo lines followed the perpendicular wall's extrusion UVs and read as masonry joints. Those lines were removed while retaining the ivory base. Final SVG SHA-256: `69a315944cfca068373c0220beda9134b87df87b272607deb6bb48e736264bff`.

The existing 0.50 m height and 0.22 m projection envelope are retained; these are inherited prototype proportions, not dimensions measured from the photographs. No doorway profile, painting asset, room light, arch or bench geometry changed. The lined intermediate is retained in `plaster-native/` and `plaster-browser/`; it was caught before independent review and is not the final candidate.

The new private `cornice_check.gd` diagnostic was run against the committed saved scene extracted from `3a968c20`: it failed with **5,400 reversed triangles and one tinted plaster material**. The corrected saved geometry passes with zero of either defect. This is a concrete regression check, not a substitute for visual acceptance. Intermediate native captures remain under `/tmp/risd-167-repair-{before,tint,winding,rounded}`. Final evidence is `smooth-native/` and `smooth-browser/`, with all capture/bake hashes in `SMOOTH-SHA256.txt`.

The arch crop is too coarse to establish stone joints or a reliable recess profile; the supplied crops do not resolve bench construction. Those batches remain open, with no invented dimensions and no new generated assets or paid calls.

Final smooth-plaster bake: 89.10 seconds, `BAKE_OK users=120`, process exit 0. The same existing editor teardown messages followed the bake. Current hashes:

- `room.tscn`: `eca83ab34f7f854d22f9f282f5ad8154d9ae71adbffc9add903bfbceaf2a436b`
- `room.exr`: `e81f38e513cd346fa26ca4f04a7b5fe7b4869efd84d4aaef5094296b352f1811`
- `room.lmbake`: `a6f6d52df6b0496dab5a548de0d958e21a58052cebf5a0893303d766dbf67dae`

## Final cornice checks and evidence

`smooth-native/` and `smooth-browser/` contain all six matched square views
(720/1600, views 5–7), captured after the final bake was freshly imported and
exported. `smooth-doorway-native/` and `smooth-doorway-browser/` preserve the
existing four doorway comparison angles at their original 4:3 aspect; the
browser folder also includes the wider context angle. `smooth-navigation/`
and `smooth-doorway-check/` record native traversal and passage visibility.
`smooth-browser-walk/` records the exported far-door keyboard roundtrip at
both widths; it is a traversal check, not a timing or motion-quality gate.

Verified after the final smooth-plaster bake:

- `scripts/check.sh`, `git diff --check`, and bake failure-recovery test pass.
- `cornice_check.gd`: one cornice mesh, zero reversed triangles, zero tinted materials.
- Doorway profile check: zero failures. Passage visibility: eight cases, 9/9 samples each.
- Native navigation: both portal roundtrips by route, real keys and real clicks; drag/easing/pan/wheel/picking/cancel pass, 23 paintings, `NAV_FAILURES 0`.
- Exported browser: six cornice squares, eight doorway views plus two context views, and two far-door gameplay roundtrips, all with empty error arrays.

Independent image review passes the visible cornice only. Slight broad-profile
softness at 720 remains a caveat. The reviewer did not see EXIT lettering in
the cornice angles and did not certify motion shimmer or unseen viewpoints.
No part of this work has been integrated into the build branch. Arch/portal
and benches need their own source-backed batches and independent gates.

## Original rejected trial checks and next gate

The last complete run before the final material trial passed `scripts/check.sh`, `git diff --check`, and the gallery navigation check (`NAV_FAILURES 0`, 23 paintings). Each saved-room bake printed `BAKE_OK`; the editor also printed its existing teardown errors, so the exported Web comparison was checked independently. The final exported Web trial produced six square captures at 720/1600 with zero page errors (the only 404 in an earlier run was an unneeded favicon). Technical checks do not establish visual acceptance. Keep #167 open. Next falsifiable repair: raise the cornice-only material's pale diffuse contribution enough to separate broad faces from the ceiling, and round or bevel the dominant projecting edge to narrow the dark bands. Recapture these exact views and seek a fresh blind review before selecting or integrating it. The arch and benches remain separate batches with their own sources and reviews.
