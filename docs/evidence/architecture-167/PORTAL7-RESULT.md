# Portal7 checkpoint — visual FAIL, not selected

This unintegrated #167 candidate fixes the white slab and white-room teleport.
The independent image-only gate still fails ornament repetition, stone mapping,
construction joins and floor-pattern continuity. See BLIND-REVIEW-PORTAL-7.md.
Benches are unchanged. Issue #167 stays open.

## Frozen evidence

`PORTAL7-SHA256.txt` SHA-256:
`ebb97a23d450603d670d23f951c36e9ea6917f441b0675a2d1168892c3425577`.
The packet includes matched 720/1600 native and exported-browser portal,
cornice and far-door views, real arch approach/inside/look-back/return images
and browser roundtrip clips. Final export PCK SHA-256:
`55a06a97d91555a51dc39b0b291cc7576ec528321d965b1c5e9b674c8e73c266`.

## Verified technical results

- Repository checks, diff whitespace, bake recovery, cornice winding/tint,
  source and baked portal mesh checks pass. Both stone meshes have zero
  triangle/normal disagreements; the modeled passage floor is present.
- Native actual floor depth-ID sampling is 9/9 in original/baked at both
  sizes. Injecting the exact old white overlay fails 0/9 in every arch case
  (expected exit 1), while the far-door cases remain 9/9. This replaces the
  previous brightness-only false positive, not the independent visual gate.
- Native navigation retains 23 paintings, both portal routes, keys/clicks,
  drag/easing/pan/wheel/picking/cancel. Continuous arch traversal retains real
  world position and lighting, looks back, returns and checks swept jambs.
- Final browser capture error arrays are empty. Actual W/S walk reaches
  positive-z recess positions, turns toward the gallery and returns. Clips
  are functional evidence, not performance or wall-clock certification.
- The frozen Shell public playtest has not yet been rerun for this candidate;
  rendering is held for another agent's isolated timing check. No frozen
  Shell interface, errors or acceptance tests were changed.

The bounded adjacent space is a recess, not an asserted reconstruction of
the neighboring gallery. Source relief is a bounded luminance-derived cue,
not measured depth. The rejected Muse guide remains outside runtime. No
additional paid generation was performed in this repair.
