# Stone portal batch — independent visual FAIL

This is a separate, unintegrated #167 candidate after the accepted cornice
checkpoint `c424cb35`. Benches are unchanged. Source interpretation and
limits are recorded in [PORTAL-SOURCE.md](PORTAL-SOURCE.md).

The portal uses three nested stone orders, modeled radial joints, paired
rounded columns, plain capital masses, imposts and stepped bases within the
existing opening/depth constraints. The existing limestone texture is reused
without changing its pixels or making a paid request. Interior-block UV
sampling avoids rectangular mortar crossing the curved masonry. Source
capital carving and outer-band ornament are not fabricated or certified.
The blank gallery-side green rectangle now uses the existing EXIT lettering.

## Matched evidence

The baseline is freshly imported/exported cornice checkpoint `c424cb35`,
with only the final comparison cameras supplied to its isolated archive.
Views 8, 9 and 10 respectively show the gallery-side casing, full museum-side
stone portal, and close stone/support detail. Both sizes are square.

| Evidence | Before | Final |
| --- | --- | --- |
| Portal, 720/1600 views 8–10 | `portal-base-native/`, `portal-base-browser/` | `portal-native/`, `portal-browser/` |
| Cornice, 720/1600 views 5–7 | `smooth-native/`, `smooth-browser/` | `portal-cornice-native/`, `portal-cornice-browser/` |
| Far doorway, original 4:3 720/1600 views 0–3 | `smooth-doorway-native/`, `smooth-doorway-browser/` | `portal-far-native/`, `portal-far-browser/` |

Final gameplay approach/inside/return captures and keyboard roundtrip clips
are in `portal-walk-browser/`. The frozen image/bake hash list is
`PORTAL-SHA256.txt` (SHA-256
`67badd95541725ea06c2392360e2c11536e10206f8fd7fd742018ec40c062f3a`).
Intermediate rejected captures were moved, not deleted, to
`/tmp/risd-167-portal-intermediate.v4qe6z/`.

## Verified before review

The final bake took 113.92 seconds and printed `BAKE_OK users=120`, exit 0.
The existing editor teardown warnings followed the bake; fresh export and
runtime checks below passed independently. Saved assets:

- `room.tscn`: `5b2ac30f5af910f67acdeb7756d6aa796dcc22d08b1a596bdf88bc55270ed751`
- `room.exr`: `4aeecb8cfe79fa6ea0c715fffa9fe254fc70300ee67a2a7bda512fb16dcc428d`
- `room.lmbake`: `ea7d74e0d515b9b1c54a4cbe29f0a7f213caea2f149646b76e778e2893cab835`

`scripts/check.sh`, `git diff --check`, bake failure-recovery check, cornice
winding/tint check and far-door profile check all pass. Native navigation
passes route/key/click roundtrips through both portals and drag/easing/pan/
wheel/picking/cancel, retaining 23 paintings (`NAV_FAILURES 0`). The native
passage-floor check returns 9/9 for all eight cases. Exported 720/1600 arch
gameplay returns 9/9, then gallery→arch→gallery with empty error arrays.
All final portal/cornice/far-door browser capture error arrays are empty.

The extended backing floor initially obscured the flush navigation passage.
The existing checker caught that regression; the height-only fix and the
recorded 0/9→9/9 evidence are in
[PORTAL-FLOOR-REGRESSION.md](PORTAL-FLOOR-REGRESSION.md). Acceptance thresholds
and frozen module seams/tests were not changed.

These checks do not establish visual acceptance or motion timing. The
independent image-only gate failed; see
[the exact findings](BLIND-REVIEW-PORTAL-1.md). Do not integrate or close #167.
