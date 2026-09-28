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

## Portal4 external failure and continuous-world repair

The fresh independent gate returned **FAIL**, recorded near-verbatim in
`BLIND-REVIEW-PORTAL-4.md` and issue comment 5862675822. In particular, the
white approach slab and blank inside frames invalidate the earlier 9/9
brightness and state-transition claims as visual acceptance evidence.

`portal_traversal_check.gd` drove the actual movement path and failed on the
old runtime: position `(0,0,-0.7)`, camera mask `1472`, lightmap hidden,
three failures. Arch crossing now retains the modeled world's coordinates,
movement and lighting. The far portal's QA room remains unchanged. The arch
no longer receives the unshaded white floor overlay. A visitor-height camera
shows the roofed recess instead of looking down through it from above.

The new private `portal_floor_probe.gd` temporarily assigns a magenta ID to
the actual flat passage-floor mesh, without changing triangles or depth.
Nine projected points must show that ID, so white overlay geometry cannot
pass. Normal-material screenshots and actual approach/inside/return walks
are still mandatory; this is an occlusion backstop, not a visual style gate.
The initial original+baked checks pass 9/9 at both test sizes; final matched
720/1600 native/Web recapture and independent review remain pending.

Intermediate self-check captures are recoverable in
`/tmp/risd-167-portal5-selfcheck.V3b97V/` and the named
`/tmp/risd-167-portal5-{closed,winding}-native/` folders. The first browser
turn probe assumed two separate settle events and a timed key hold; it was
replaced with observed world position and settled heading. The corrected
browser run at `/tmp/risd-167-portal5-closed-browser/` completed 720/1600,
entered the actual room to z=4.45/4.28, looked back at the portal and returned,
with empty error arrays. This fixes traversal, not the remaining art gate.

Rear-wall lighting investigation: disabling the hidden photo card's baked
occlusion did not alone fix dark edges. A broader winding change did not
help and worsened floor contrast, so it was reverted. The portal fill's
old 3.5-unit radius left the 6-wide rear wall's corners outside illumination;
the next bounded trial uses a 7-unit diffuse falloff. No gallery/far-door
light or frozen interface is changed. Side returns now meet the existing
end-wall plane, closing visible background triangles at the floor edges.

The ornament revision removes the repeated generic scrolls, samples each
of the four visible capital faces separately, and models the shallow
impost band. Existing portal opening/depth and bench geometry stay fixed.
Source limits and the new local data hash are in the owning provenance and
`image-work/architecture-167/README.md`; no additional paid generation.

The first impost trial (`portal6-native`, now preserved in the self-check
folder) was self-rejected: faceted relief and 192 triangle/normal disagreements.
Reducing the depth to 0.010, increasing tessellation and deriving smooth
normals from the actual surface brings the fast `portal_check.gd --source`
diagnostic to two stone meshes, zero disagreements and one passage floor.
The next bake completed in 116.53 seconds, `BAKE_OK users=120`, exit 0;
the inherited editor teardown warnings remain. Fresh export/import followed
before `portal7-native` and `portal7-walk-native` captures. Both 720/1600
native continuous walks pass, including inside look-back, return, and swept
jamb checks. Self-inspection sees the lit rear wall and softened impost
relief. Exported checks and the fresh independent gate are still required.

The adjacent space remains the existing bounded navigation recess, not a
new reconstruction of an entire neighboring gallery. No extra paintings,
new surveyed room dimensions, or bench changes are claimed.

## Portal7 frozen FAIL and portal8/9 source sampling repairs

The independent portal7 gate failed repeated impost decoration, mirrored-looking
capital pairs, stone stretching, architectural joins and floor continuity.
Exact findings: `BLIND-REVIEW-PORTAL-7.md`; immutable packet and technical
results: `PORTAL7-RESULT.md`. Checkpoint `cebb4089` preserves the full failed
packet and the continuous-world traversal repair; nothing is integrated.

The analytic six-period diamond function was the direct source of the
repeated impost decoration. It is replaced with separately sampled owner-
photo bands. Column UV aspect now uses matching circumference/height grain
density, and jambs use source-backed courses instead of a single stretched
patch. A tapered rear soffit meets the unchanged plaster doorway head.
The passage's crossing planks now replay the gallery's grain/tone RNG and
vertical-plank UV orientation; gallery geometry and material are untouched.

The first native preview of these repairs, `/tmp/risd-167-portal8-native`,
was self-rejected before a Web packet: stretched shafts improved, but relief
remained soft. Inspection found that signed-power x coordinates skipped
central source columns: at 128 angular samples, the old exponent 0.55 steps
roughly 0.19 across normalized face x near its center, versus 0.049 with
cosine x. The next trial retains a rounded-square outline while uniformly
sampling x, and reduces capital lighting texel size from 0.008 to 0.004.
The individually sampled impost relief uses 48 vertical rows and bounded
0.040 depth. No repeated ornament is fabricated, and no new paid call occurs.

An overly deep capital trial produced 11, then 4 triangle/normal disagreements.
Restoring 0.12 bounded displacement with a front-only taper removes those
folds; the next source check reports two stone meshes, zero disagreements,
one passage floor. Temporary diagnostic logging was removed. A fresh baked
preview and independent review are still required, not assumed to pass.

The public Shell playtest fails; an isolated pre-portal cornice checkpoint
reproduces its main failures. See `SHELL-BASELINE.md`. Frozen tests remain
unchanged, and no passing public baseline is claimed.

## Portal10: closer source changes the structural interpretation

The museum's own full-portal and capital-detail photographs resolve three
staggered shafts per side, including the narrow center shaft; the previous
two-support interpretation was incomplete. Source URLs, hashes and limits
are recorded in `PORTAL-CLOSER-SOURCES.md`. The raw photographs stay outside
runtime. No new paid generation occurred.

The next source trial uses six independently sampled capital fields, real
stepped impost sections, and a few long shaft courses. Original opening,
passage extent and gallery paintings remain fixed. The detailed photograph
needs a nine-pixel sampling footprint rather than the previous three-pixel
filter; otherwise its high-frequency stone grain aliases into spiky relief.

At carved ridges, micro-step analytic normals could oppose their finite mesh
faces even though both faced outward. Derivatives now follow mesh spacing,
and ridges over 60 degrees use their actual triangle planes. A separate
parameterized front/back winding check runs before shading, so changing
shading normals cannot waive a reversed relief face. Source output:

```text
PORTAL_SOURCE stone_meshes=2 reversed_triangles=0 relief_winding=0 passage_floor=1
```

Temporary diagnostic logging is removed. Portal10 bake/native self-check is
the next step; this source result is not visual acceptance.
