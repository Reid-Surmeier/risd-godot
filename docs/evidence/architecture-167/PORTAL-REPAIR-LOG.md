# Portal repair after the first independent FAIL

The first external gate remains a failure, preserved in
`BLIND-REVIEW-PORTAL-1.md`. No later candidate is independently accepted.
Intermediate `portal2-*` and `portal3-*` folders below are preserved outside
the committed packet at `/tmp/risd-167-portal-intermediate.v4qe6z/`.

1. `portal2-*`: rounded modeled capitals and thicker supports, bevels and
   narrower stone joints, material patch variation, and modeled passage
   parquet. Self-inspection rejected per-face texture resets on dense
   column/capital geometry: they produced a visible checker pattern. The
   passage also had excessive contrast. Native and exported navigation,
   passage 9/9 and 23-painting checks passed; visual quality did not.
2. `portal3-*`: continuous column/capital UVs; the passage reuses the existing
   gallery oak shader with its own z range. Original-photo low-relief cue
   replaces dependence on the invented Muse guide detail. Self-inspection
   finds the capital still too soft; a shared coarse stone lightmap is a
   plausible cause, not an established visual fix. The saved-scene winding,
   9/9 doorway, both-portal navigation, far profile and repository checks
   pass. Browser portal captures and real-key arch roundtrip have no errors.
3. Next isolated probe: denser capital front geometry and 0.008-scene-unit
   lighting texels, keeping the capital as a separate mesh. Source review
   caught `_merge_static()` combining it with the arch and discarding its
   metadata. The capital now opts out of that merge. `portal_check.gd` must
   find two stone meshes, no reversed triangles, and one correctly ranged
   passage floor before new visual review. Final capture and verdict pending.

The diagnostic was run against the merged saved scene before the corrected
rebake and exits 1:

```text
PORTAL_BAKE stone_meshes=1 reversed_triangles=0 passage_floor=1
```

This is a reproducible metadata/separation failure, separate from subjective
visual acceptance. Command: `godot --headless --path . --script
modules/shell/prototype/gallery_walk4/portal_check.gd`.

The corrected bake (153.51 seconds, `BAKE_OK users=121`, exit 0) preserves
the capital mesh and its 0.008 texel setting. The same diagnostic exits 0:

```text
PORTAL_BAKE stone_meshes=2 reversed_triangles=0 passage_floor=1
```

Final probe captures use the new `portal4-*` folders, leaving the earlier
failed packet untouched. The capital detail is materially clearer after the
separation fix; independent visual acceptance is still required. Native
all-eight-case 9/9 passage visibility, 23-painting/both-portal navigation,
far-door profile, cornice winding/tint, repository and bake recovery checks
all pass again. Browser verification and immutable hash list follow.

Final exported `portal4` browser captures and 720/1600 real-key arch
roundtrips pass with empty error arrays and 9/9 passage samples. The frozen
capture/bake list is `PORTAL4-SHA256.txt`, SHA-256
`a7dd658f6bd398c3a8a56ada3df760ba9c70574a63aba43f02e2a37efb2b8a42`.
This checkpoint is pending a fresh external image-only gate, not selected
runtime art. The reviewer receives source/style and captures only.

The Muse guide is not loaded by runtime code. One OpenRouter request,
declared/reported USD 0.01, actual spend reconciliation unknown; full record
and source/guide limitations are in `image-work/architecture-167/README.md`.
No paid retry. Neither the portal nor benches have been integrated.
