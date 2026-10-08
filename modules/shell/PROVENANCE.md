# Shell visual provenance

## Square chrome (#164)

Selected treatment A from `prototype/156-square-chrome` at `89b0e39c4e4451b2b6e7b7031412c52249320777`.
Accepted runtime copies live in `assets/square_chrome/`; their source/output SHA-256,
crop rectangles and binary-mask recipes remain in `assets/square_chrome/provenance.json`.
The reproducible recut source remains on that preserved prototype branch at
`modules/shell/prototype/chrome/recut.py`.

Seven transparent icons reuse the Muse compact toolbar icons. Start is a recut of
its stars, Home a recut of its house, and Search a recut of the owner's top-header
screenshot. Stripe/selected-face crops reuse the existing compact toolbar.
Historical generation: OpenRouter `meta/muse-image`, pass 16,
`run-b443ade33509293fc5b17b6b`, USD 0.01 for the output / USD 0.09 edit loop.
Flowers retains its separate record in `image-work/flowers-tab-label/`.
The complete stripe raster is also copied into Shell's runtime assets with its
source and output hash in the same manifest; chrome loads no other module's art.
No generation for this integration: 0 calls, USD 0.

The Collection frame remains `assets/collection_frame/page.png` with original
source records in `image-work/collection-frame/`; the old clock is covered by the
same white mask accepted in treatment A. Atlas owns its accepted MINI MAP label
and clock treatment internally. No runtime asset depends on prototype evidence.

## #167 selected architecture — September 29, 2026

Architecture is source-led authored geometry, not a scan or surveyed reconstruction. Official RISD portal photographs, source crops/hashes, rejected trials and all independent review records remain on [prototype/167-cornice at 1e42d5a5](https://github.com/Reid-Surmeier/risd-godot/tree/1e42d5a5/docs/evidence/architecture-167). The recipe and generation records are retained in `image-work/architecture-167/`.

- Cornice, ivory trim and EXIT artwork: local Godot/SVG authoring, USD0. Independent native/browser review accepted pale molded profile and continuous joins.
- Portal: six source-led supports, carved relief fields and continuous stone UVs. Local authored geometry, no image-derived displacement. Rejected Muse modeling guide is excluded from runtime. Recorded modeling guide call: OpenRouter meta/muse-image, one image, reported USD0.01; actual reconciliation unknown. Official source links and photo hashes: prototype `PORTAL-CLOSER-SOURCES.md`; authored relief source: `portal_sculpt_relief_prepare.gd` and `portal-capital-relief.json`.
- Bench cloth: OpenRouter `meta/muse-image`, one image, run `run-88c6ecd80fdd005ff1c6ce34`. Reported reservation/cost USD0.010000; reconciliation unknown, no blind resubmission. Cloth SHA256 `4e87afbd59fec5004a36506934a30b62cc0f58500e07829572a9007ac13ffe51`. Prompt, ordered source references/hashes and recipe: `image-work/architecture-167/bench-material/`. Soft tufts, cushion edges and slender frame are local authored geometry; source proportions are visual interpretation.
- Bake8: 127 lightmap users; runner exited0. Both bench/native browser batches accepted at720/1600. Vault end normals face inward; no additional image generation. Final evidence in `docs/evidence/architecture-167/owner-repairs/bake8/`.
- Doorway camera retains selected perspective/FOV. A transient opaque dissolve avoids Compatibility renderer Alpha Hash failure; original materials return at full opacity. Private rendered regression checks actual background coverage. Floor cutaway removes baked shadows belonging to culled stone. No source texture/lightmap modified by this repair.

Historical #167 assets at that integration (later updates below supersede the room files):

| Runtime asset | SHA-256 |
| --- | --- |
| `baked/room.tscn` | `fa1bd9ad9c1ef89279225e91bfcfb30990c9fc5d85949e37d4256cd5a514923c` |
| `baked/room.lmbake` | `87529c49d38174870633da01f8654c2eceafdc2c8da40fd1be3a096914a130e7` |
| `baked/room.exr` | `19ec1364ff612f120b336de96f3f84ed7d4f67b62ab863a546d45c8a250abbbb` |
| `portal-capital-relief.json` | `25c7f5b414e6f519d81c29a2d6c0434a4a683a5b72dfb222b323a7af1574ec1b` |

Owner final hands-on acceptance remains separate and pending. No paid calls for integration or the dissolve repair.

Additional authored source hashes for the selected architecture:

| Source | SHA-256 |
| --- | --- |
| `textures/cornice-ivory.svg` | `69a315944cfca068373c0220beda9134b87df87b272607deb6bb48e736264bff` |
| `textures/ivory-trim.svg` | `89a3ccde5dfb4d78c4023e35e1ae9b3cc457ecb240b67994ba3af7612951c776` |
| `textures/exit-sign.svg` | `7f15231b789fb9539d2affcb90fcc593735f446191877a9427179ddfec9a1e07` |
| `portal_sculpt_relief_prepare.gd` | `88b95549164040aae8758c34ed79286b39fdf0ce8112247a6941c9bd2395bbeb` |


## Surface update #168

Current architecture source comes from build c9d2985c; see its architecture-167 records for unchanged portal, cornice, bench and visitor sources. Reconciled floor aa144f72/7f0d9f6c failed fresh close-detail review. One new OpenRouter meta/muse-image source-guided atlas request: run3d3e631edf2e83b935bb12cb, count1, actual recorded USD0.01, counted spent despite spendStateunknown; neverresubmit. Ordered Site Specific gallery2456/2447 reference URLs/hashes retained in image-work/floor-168-board-v2/README.md, new prompt/plan/receipt in image-work/floor-168-board-v3. Native atlas2240×1120 SHA25665ba2455f048c900562678cc42dcc55d89b608deef763e5e35e7d708e3d8a9ff, runtime textures/oak-board-atlas-168-v3.webp byte-identical. Unequal rows handled in UV crop, no edited image pixels. Final saved-bake native/browser floor review PASS at720/1600; exact records in docs/evidence/surfaces-168-current. Selected for build integration after source macro dependency removal.

## Native wall and skylight candidate #168

See docs/evidence/surfaces-168-current/README.md. Wall now uses native matte #6f83a3 with no image dependency. Skylight SVG is authored vector source, SHA256 fe3627efa8da494eaeba99fbd9c9e1182c023dc640cfd491be348950093ae50b, source-led from the recorded Site Specific gallery2447/2456 photos; 8×8 thin pale grid, square UV scale, stepped modeled surround. Provider none/count0/USD0 for this group. Floor macro texture dependency removed. All three separate saved-bake native/browser visual gates PASS at720/1600; recorded caveats remain in docs/evidence/surfaces-168-current.

## #176 final world correction (2026-09-29)

Source candidate2670002d corrects portal supports/joins, bench upholstery/underframes and photo-visible wall vents, joints and caption plates. Uses the existing recorded gallery photographs and accepted textures; no generation or additional spend. Rounded bench geometry and correct side UVs; flush wall divisions; closed portal relief edges and circular collar transitions. Both benches retain their locations; all23paintings and traversable openings retained. Third saved bake137users. Separate independent Astra medium image-only re-reviews: bench/walls PASS on secondcandidate, portalPASS onthird. Exact records and remaining fidelity limits in docs/evidence/world-176. No museum measurement or final owner approval is implied.

## #177 owner-selected appearance restoration (2026-09-29)

Owner-uploaded screenshot exactly matches6bdf721c architecture-167/owner-repairs/bake8/browser-12.png (SHA25624b88e74f55d557735c31b0df77f67ecba369539fac48ebbf6d1a96acbbeb969). Restore existing oak-muse.webp and wall-muse.webp with that floor mapping/plank size and slimmer cushion crown/rails. Existing bench-cloth-muse.webp retained; no new generation or spend. Later UV/rim correctness, portal/cutaway, character and containment repairs retained. Owner visual selection supersedes the later agent-selected floor/wall/cushion appearance.


## #177 browser floor edge repair — 2026-09-29

The restored warm parquet had rasterization holes at plank T-junctions. A magenta-background Web control exposed the same floor pixels as background. Each authored plank now has matching split edges, with shared lattice vertices quantized to 0.1 mm before world rotation. The saved floor ArrayMesh alone was retessellated; interpolated source colors, texture UVs and lightmap UVs remain. The existing lightmap, materials, source textures and scan hashes are unchanged. No rebake, provider request or spend. `floor_edges_check.gd` rejects the old mesh (6062 unmatched interior edges) and passes the repaired mesh (0). Browser/native matched close-ups and independent image review are recorded under `docs/evidence/owner-world-177/floor-repair/`.

## #186 lighter floor selection (2026-09-29)

Owner screenshot SHA256488e207d35b839603ee3d35cf1630f62a23bc800f4a03eadba61c862237b4a3f exactly matches world-176/integrated/details/bench.png, runtime c614b5ed. This supersedes #177's warm floor only. Restore existing oak-board-atlas-168-v3.webp, floor_oak.gdshader and 1.9×0.36 herringbone layout with #177's conformed shared edges. Current couch/walls/passage and lighting remain. Saved floor lighting UVs verified against the existing world-space mapping; lightmap EXR/LMBake hashes unchanged. No new generation, spend or bake. Evidence: docs/evidence/floor-selection-186.

## #187 warm floor and room light (2026-09-29)

Owner requested the older honey tone on the accepted #186 grain/layout, warmer lamp light and less skylight. Existing atlas pixels and 1.9×0.36 plank layout retained; floor shader tint adjusted, baked daylight reduced from 0.8 to 0.35, fill warmed and increased from 0.4 to 0.55, painting spots from 6.0 to 6.8. Doorway reveal and passage-facing normals corrected; shared panel winding now agrees with supplied normals. New offline lightmap is authored from this geometry and lighting. No image generation/provider calls or spend. Evidence and bake device/timing: `docs/evidence/warm-room-187/`.

Current #187 saved lightmap hashes (unchanged by #189):

| Runtime asset | SHA-256 |
| --- | --- |
| `baked/room.exr` | `e68c711f84cf22d1563475686d5359bc6b8d676aa9a7bf6e9288e9bcaab3eea2` |
| `baked/room.lmbake` | `6679c1971971046501aa48dcfd82aea7e4038d1897ace19226f3af5dc7de1bdf` |

Local Godot 4.7.2 offline bake on llvmpipe: 333.80 seconds, 137 lightmap users, provider none, USD0. Source geometry/lighting is recorded in runtime `dbfe2393` and `docs/evidence/warm-room-187/bake-final.log`.

## #189 white baseboard visibility (2026-09-29)

Owner screenshot `Screenshot 2026-09-29 at 3.39.58 PM.png` showed the left wall baseboard disappearing into shadow. Existing board geometry retained; its two saved merged materials now receive neutral emission fill (0.55), matching the cornice treatment. Source recipe remains in bake/prepare.gd, keyed by baseboard metadata. Saved room SHA256 `cec2c8fc7c555b46115c40a4752ae03bb1f40ff23129b8770dfd27c4c1f027a1`. All139 mesh geometry/normal/UV arrays and transforms match #187; EXR/LMBake unchanged. No generation, provider, spend or rebake. Native left-board luminance rises from0.272 to0.605; visual evidence in docs/evidence/collection-interaction-189.


### #177 passage-floor shared edges — September30

The current saved passage Surface010 had two visible interior Web pixels that changed from dark to magenta with only the background changed. Native edge check measured989 unmatched interior edges. Shared endpoint canonicalization/subdivision reduces that to0; the720/1600 Web background comparisons have0 interior background pixels. New source generation uses the same local passage helper; it preserves UV/color/UV2 interpolation. Only four serialized ArrayMesh data lines change, retaining all other scene bytes, materials/textures and saved EXR/LMBake hashes. No new generation, provider action, bake or spend (USD0).

Current `baked/room.tscn` SHA256 `0fe3d246ec52d848d3ba8a686b12dc831dabc85da4f85216dcb5254f93b1a9a8`. Source input is build477b34b5; reproducible source-geometry/private checks, rejected first repair and fixture-packaging failure are recorded under `docs/evidence/owner-world-177/passage-current/`. The passage-only quadratic scan measured200536µs in a native invocation; this is not a startup-performance acceptance. Full-app review and final hands-on owner approval remain required.

## Collection entry-floor coverage — September 30, 15:30 UTC heartbeat

Local pycolmap/NumPy/Pillow CPU diagnostics, ffmpeg CUDA NVDEC/scale_cuda,
Godot 4.7.2 and Chrome on RTX 4070 SUPER; **$0**, no paid calls.
[Source selections, raw results, decoder logs and hashes](../../docs/evidence/collection-reconstruction/heartbeat-20260930T1530/provenance.json).

Saved wall-only entry 206 pose predicts one cached casing/floor contact at 2.108 px;
source crops do not identify an interior wood knot. Interior masks yield zero
matches against 244/505. Native 206 remains blurred; new full-stream native 244/505
and reserved 246/506 frames are prepared without fitting reserved floor pixels.
No plane, scale, opening or collision extension accepted. Historical bounded
native/browser walk passes 24 checks each and real WASD crossing/return. Initial
native run lost its X connection; separate final run passes. Shell retains four
known failures. Earlier pending work, original videos, frozen models/holdouts,
Muse receipts and rejected sculpture meshes preserved. No runtime/Viewer edits,
production integration, paid generation or ticket closure.

## Collection expansion prototype — issues #178, #183

The new frame trial lives outside runtime dependencies in
[`image-work/collection-expansion-frame`](../../image-work/collection-expansion-frame/README.md).
It is not an accepted game asset.

- Source: user Proton museum video IMG_6386.MOV, 2 fps sample 122 (nominal 60.5 s),
  CUDA-decoded native frame, canvas-plane rectification. Source hash and transform:
  `image-work/collection-expansion-frame/source.json`.
- Provider/model: OpenRouter / `meta/muse-image`; one output; recorded actual cost
  **$0.010000**, run `run-ed0aaab20f6b84b6db0db31b`. Retain the run's unknown spend
  state and never-resubmit flag; no additional request was made.
- Exact existing Grand Gallery source-preserving frame prompt SHA256:
  `8857d37da73e411814c24d8e9d449a1182fe8e6116af6cf6e7eed67273346949`.
- Native result SHA256:
  `66c667d5786e50dc2a786f01e0435aee65b188f496d5814bf9687a6eb6ebbb76`.
- The separate authentic painting is RISD 35.786, *Arabs Traveling*;
  [museum source](https://risdmuseum.org/art-design/collection/arabs-traveling-35786).
  Image hash/rights evidence appears in the anchor research and trial review.
- Keying, texture, catalogue scale and geometry hashes are in the trial's
  `review.json`. Full run records are archived with reconstruction evidence.
- Visual state: trial inspected in Godot on RTX 4070 SUPER. No batch acceptance,
  measured frame depth, room lighting bake, sculpture generation or finished
  connected-map claim. Existing assets retain their existing adjacent records.

## Collection sculpture appearance trial — issue #183

Source: RISD accession 59.131, *Head of Christ or a Saint*, official front/rear
photographs and IMG_6382 obliques. See
[reference research](../../docs/research/collection-sculpture-anchor.md) for exact
image URLs, rights fields and catalogue dimensions. Credit: Courtesy of the RISD
Museum, Providence, RI. This is a trial outside runtime dependencies.

OpenRouter `meta/muse-image`, one output, actual recorded cost **$0.010000**;
run `run-5ac877552e2b1979a8edb87c`, unknown spend state / never-resubmit retained.
Native output SHA256:
`0325b88fba070b85c957a6991623c843c1515b83c508b37dc09cc43b8906064f`.
Prompt, source/output hashes, ordered references and review are in
`image-work/collection-expansion-sculpture/`. Full run archive is stored with
reconstruction evidence. No complete mesh, exact ornament preservation,
pedestal calibration, global placement or lighting-bake acceptance is implied.

Owner approved the shown frame direction on September 29: “yeah these look good
continue dont ask for permissions.” That feedback is recorded in the frame
trial review; remaining physical/navigation/bake checks remain separate.

## Collection doorway validation — September 29, 20:35 UTC heartbeat

Local COLMAP CUDA 4.2.1 / RTX 4070 SUPER, zero paid calls, **$0** this tick.
Source: frozen `sfm-calibrated-doorway-v1/sparse/0` and withheld Proton video
samples in the ingestion workspace. The model hashes, per-frame results,
source paths and artifact hashes are recorded in
[`heartbeat-20260929T2035/provenance.json`](../../docs/evidence/collection-reconstruction/heartbeat-20260929T2035/provenance.json)
and its `audit.json`. Generator sources are `calibrated_audit.py` and
`doorway_geometry.py` beside the existing reconstruction prototype helpers.

49/69 held-out views meet the original support rule; 46/69 pass the disjoint
fit/test point diagnostic. The corrected 61-view CUDA depth trial fused 19,815
points. The casing-plane surface trial **failed**, including a 0.501 provisional
metre corner/floor discrepancy. Images are diagnostic evidence, not runtime
textures, accepted geometry, collision surfaces or a completed museum map.
Bookcase scale remains provisional; the independent canvas trial found no
supported views. Existing Muse receipts and never-resubmit flags are unchanged.

## Collection multiview measurements — September 29, 21:00 UTC heartbeat

Local NumPy / pycolmap CPU pose and ray calculations; zero paid calls, **$0**.
Source: unchanged calibrated sparse model, cached withheld-frame matches and
Proton video pixels. No additional CUDA feature/matching/depth run was needed.
[Evidence provenance](../../docs/evidence/collection-reconstruction/heartbeat-20260929T2100/provenance.json)
records generator, input and artifact hashes; the adjacent doorway/bookcase
reports retain the exact manual annotations and source-model/image hashes.

Doorway held-out errors **2.22 / 9.18 px** fail the exploratory 8 px diagnostic.
Bookcase extrema predict all four reserved pixels within **3.85 px**, with width
and height scale estimates **1.76%** apart. Scale remains provisional. Neither
trial accepts collisions, room topology, runtime geometry or final quality
criteria. Existing paid appearance trials and their provenance remain unchanged.

## Collection aperture and floor patches — September 29, 22:00 UTC heartbeat

Local NumPy/pycolmap/Pillow calculations on cached CUDA depth; **$0**, no paid
calls and no new depth sweep. Recovered the interrupted 21:30 aperture trial,
verified its frozen source hashes and reran cached pose/measurement assertions.
New floor-patch generator: `prototype/collection_reconstruction/floor_patches.py`.
[Inputs, outputs and hashes](../../docs/evidence/collection-reconstruction/heartbeat-20260929T2200/provenance.json)
include the reserved doorway overlay and both floor coverage images.

Four aperture corners predict the new reserved frame within 4.11 px; the older
9.18 px failure remains. Separating near/far floor masks exposes only 0.4%
near-floor depth in the original view. A reviewed later view improves near
coverage to 66.5%, but the two normals differ 3.96 degrees and extrapolated
levels disagree. These are diagnostic images, not runtime surfaces or accepted
collisions. Bookcase scale, sculpture rear coverage and lighting remain open.

## Collection floor cross-view check — September 29, 22:30 UTC heartbeat

Local NumPy/pycolmap/Pillow on cached CUDA depth; **$0**, zero paid calls.
Generator: `prototype/collection_reconstruction/floor_crossview.py`.
[Sources, hashes and evidence](../../docs/evidence/collection-reconstruction/heartbeat-20260929T2230/provenance.json)
record frozen frame-18 plane projection into four distinct other depth views;
one duplicate image/depth pair is explicitly excluded. All overlays inspected.
Near-floor coverage remains 3.8–18.6% in other usable views, with no sparse
floor points in those footprints. Far-floor discrepancies reach 7.3 provisional
cm at the 90th percentile. This does not accept collisions, a step, a slope,
metric scale or room navigation. No new paid generation or CUDA sweep.

## Collection threshold landmarks — September 29, 23:00 UTC heartbeat

Local NumPy/pycolmap/Pillow triangulation, **$0**, zero paid calls. Three
native-resolution reference frames were also decoded with CUDA on RTX 4070
SUPER; no new feature, matching or depth sweep. Generator:
`prototype/collection_reconstruction/threshold_landmarks.py`.
[Sources, annotations, hashes and evidence](../../docs/evidence/collection-reconstruction/heartbeat-20260929T2300/provenance.json).

Five landmarks predict reserved frame 15 within 3.40 px, but the knot is
4.75 provisional cm off the four-corner plane and ±3 px pick sensitivity
produces a 21.05-degree 95th-percentile normal deviation. These are nearby
same-video checks. Narrow threshold measurements do not accept a level floor,
a physical step, room collisions, metric scale or navigation. Existing Muse
receipts and failed sculpture meshes remain unchanged.

## Collection bounded doorway traversal — September 30, 00:00 UTC heartbeat

Local Godot 4.7.2, pycolmap/NumPy and Chrome on RTX 4070 SUPER; **$0**, no paid
calls. Recovered the interrupted `corridor-floor-v2` result and preserved its
source. The new narrower-baseline wall-floor comparison is retained as weaker
evidence, not substituted for that measurement.

[Source, input and output hashes](../../docs/evidence/collection-reconstruction/heartbeat-20260930T0000/provenance.json)
cover the isolated doorway scene, original visitor, measured aperture, floor
patches, browser export and screenshots. Native and real browser keyboard
round trips pass; the right jamb blocks the capsule. Casing visuals cut away
when they obstruct the visitor, while collision stays active.

This accepts only the bounded experimental traversal checks. Floor interpolation,
metric scale, room extents, whole-room collisions, final camera behavior and
baking remain unresolved. Existing Muse receipts and failed sculpture meshes
are unchanged. No production integration or 3D Viewer changes.

## Collection doorway clearance/camera — September 30, 04:00 UTC heartbeat

Local Godot 4.7.2 / Chrome 154 on RTX 4070 SUPER; **$0**, no paid calls.
[Source, input and output hashes](../../docs/evidence/collection-reconstruction/heartbeat-20260930T0400/provenance.json)
cover ten movement trials, camera sampling and real browser keyboard round trips
at 720px and 1100px. Both jambs block from both sides; clear paths cross and
return. Inspected before/after shows the intermediate shoulder-ray cutaway
removing casing overlap while collision stays active. Existing floor geometry,
provisional scale and visitor remain unchanged. These are bounded prototype
checks, not whole-room or runtime acceptance. Initial trial failures and an X
interruption remain recorded; final native/browser checks pass. Existing Muse
receipts and failed sculpture meshes are unchanged.


## Collection casing support — September 30, 04:30 UTC heartbeat

Local COLMAP CUDA / NumPy / Pillow / Godot 4.7.2 / Chrome 154, **$0**, no paid
calls. RTX 4070 SUPER matching/rendering; pose fitting CPU. Generator:
`prototype/collection_reconstruction/corridor_extents.py`.
[Source, annotations, outputs and hashes](../../docs/evidence/collection-reconstruction/heartbeat-20260930T0430/provenance.json)
include the reserved image, before/after floor plan and inspected GPU renders.

Two decorative doorway outer toes predict reserved pixels within 2.25px.
Only a small casing-side floor extension is added to the isolated study,
using the frozen corridor plane; measured toe offsets remain 2–4 provisional
cm. All 24 native/browser movement and camera checks plus real WASD round
trips pass. This is bounded study evidence, not complete rooms or surveyed
floors. Three opposite-door poses fail the unchanged support gate even after
targeted CUDA matching; they are excluded from geometry. Existing Muse
receipts and rejected sculpture meshes are unchanged.

## Collection Grand-end casing diagnostic — September 30, 05:00 UTC heartbeat

Local pycolmap/NumPy/Pillow, COLMAP CUDA, ffmpeg NVDEC/scale_cuda, Godot 4.7.2
and Chrome 154 on RTX 4070 SUPER; **$0**, no paid calls. Pose fitting CPU.
[Annotations, source/output hashes and evidence](../../docs/evidence/collection-reconstruction/heartbeat-20260930T0500/provenance.json).

One exterior casing toe predicts reserved frame 204 within 0.80px; ±3px picking
sensitivity reaches 7.87 provisional cm. Reverse casing face is excluded.
This does not define an aperture or new collision geometry. Return poses with
zero/two tracked points fail support; the empty-match helper crash is fixed
and verified with supported and rejected cached queries. Thirty-six fresh
GPU reference samples are prepared, with the original withheld-time exclusion.
Existing bounded traversal passes all 24 native/Chrome checks and real WASD
round trips. Shell remains failing (six GPU checks, prior failure names).
Existing Muse receipts and rejected sculpture meshes are unchanged.

## Collection Grand-return rejection — September 30, 05:30 UTC heartbeat

Local COLMAP CUDA / NumPy / Pillow / Godot 4.7.2 / Chrome 154; **$0**, no paid
calls. RTX 4070 SUPER matching/native/browser rendering; absolute pose CPU.
[Sources, annotations, outputs and hashes](../../docs/evidence/collection-reconstruction/heartbeat-20260930T0530/provenance.json).

Fresh return samples 24/26/28 remain unsupported (0/0/5 tracked points), even
with verified frozen camera #5 at 594.33px. Default-camera and assertion-failed
trials remain recorded. AUTO camera mode preserves the existing calibration;
PER_FOLDER replaces it. New header corner predicts reserved pixels at 8.230px
and fails the unchanged 8px gate. No geometry or collision extension accepted.
All 24 native/Chrome doorway checks and real WASD round trips pass; Shell has
five previously observed failures. Native timings excluded due to overlap.
Existing Muse receipts and rejected sculpture meshes remain unchanged.

## Collection right-casing diagnostic — September 30, 06:00 UTC heartbeat

Local COLMAP CUDA / NumPy / Pillow / Godot 4.7.2 / Chrome 154; **$0**, no paid
calls. RTX 4070 SUPER feature/matching/native/browser rendering; pose CPU.
[Sources, frozen annotations, output hashes and evidence](../../docs/evidence/collection-reconstruction/heartbeat-20260930T0600/provenance.json).

Two new samples have 36/79 pose inliers and pass unused-point checks, but the
reserved right-toe error is 19.963px: rejected by the unchanged 8px gate.
Exterior toe separation is not accepted opening width. Camera-report enum/
array serialization fixed; no matching retry, geometry or collision extension.
All 24 native/RTX Chrome doorway checks and real WASD round trips pass. Initial
llvmpipe browser result retained; Shell has six previously observed failures.
Existing Muse receipts and rejected sculpture meshes remain unchanged.

## Collection native casing coverage — September 30, 06:30 UTC heartbeat

Local ffmpeg NVDEC/scale_cuda / pycolmap / NumPy / Pillow / Godot 4.7.2 / Chrome
154; **$0**, no paid calls. RTX 4070 SUPER decode/final rendering; no new
feature matching, reconstruction or optimization.
[Sources, original marks, outputs and hashes](../../docs/evidence/collection-reconstruction/heartbeat-20260930T0630/provenance.json).

Separate outer-mitre candidate fails its reserved view at 14.895px under the
unchanged 8px gate. Inspected marks may identify different bevel endpoints;
failed trial retained, no retuning or new floor/collision. Only one fitted
track is shared near the three marks; this is local coverage evidence, not
independent corner accuracy. Eight native frames use full-stream fps indexing.
Final native/RTX Chrome walk passes all 24 checks and real keyboard round trips;
initial failed capture invocation and integrated-GPU browser run retained.
Shell has seven previously observed failure names. Existing Muse receipts and
rejected sculpture meshes unchanged; no production integration or Viewer edit.


## Collection decoded sampling correction — September 30, 07:00 UTC heartbeat

Local ffmpeg CUDA NVDEC/scale_cuda, NumPy/pycolmap CPU diagnostics, Godot 4.7.2
and Chrome 154 D3D12 RTX 4070 SUPER; **$0**, no paid calls.
[Commands, raw decoder logs, source/output hashes and guard checks](../../docs/evidence/collection-reconstruction/heartbeat-20260930T0700/provenance.json).

New left plinth shoulder predicts reserved pixels at 4.677px; opposite shoulder
fails at 10.118px. No floor/collision extension accepted. Actual source-sample
checks reveal registered exit references 18/48 inside the declared held-out
0.2s exclusion. Historical 49/69 and 46/69 reports remain preserved; 44/69 after
excluding affected queries is conservative accounting, not a rebuilt result.
Entry reference 12 also violates actual separation. Guards stop affected trials
before fitting/matching or overwriting reports; 473-image reconstruction
allowlist prepared. Final bounded native/browser walk passes all 24 checks;
Shell has four previously observed failures. No production or Viewer change.
Existing Muse receipts and rejected sculpture meshes remain unchanged.

## Collection exclusion-corrected model — September 30, 07:30 UTC heartbeat

Local pycolmap 4.2.1 from cached CUDA matches; Ceres CPU fallback recorded;
Godot 4.7.2 / Chrome 154 D3D12 RTX4070SUPER. **$0**, no paid calls.
[Inputs, outputs, raw logs and preservation checks](../../docs/evidence/collection-reconstruction/heartbeat-20260930T0730/provenance.json).

Fresh allowlist reconstruction: 473 views, 43,042 points, 0.640691px fitted
error, no old points/poses seed. Video intrinsics remain provisional.
45/69 nearby withheld views pass disjoint-point diagnostics; this is not
independent capture/metric validation. Old reports/models preserved.
Original casing picks pass; opening loses sufficient ray separation.
New bottom toes fail reserved pixels (14.342/9.428px); no picks retuned,
floor/collision extension or full opening accepted. Native/browser bounded
walk checks pass on historical provisional surfaces; Shell retains six
previous failure names. Visuals inspected, fresh cloud exported without old
dense geometry. No runtime/Viewer edits, integration, paid generation or closure.
Existing Muse receipts and rejected sculpture meshes remain unchanged.


## Collection native threshold diagnosis — September 30, 08:00 UTC heartbeat

Local ffmpeg CUDA NVDEC/scale_cuda, NumPy/pycolmap CPU diagnostics, Godot 4.7.2
and Chrome 154 D3D12 RTX4070SUPER; **$0**, no paid calls.
[Source marks, commands, outputs and raw logs](../../docs/evidence/collection-reconstruction/heartbeat-20260930T0800/provenance.json).

New native threshold splice/casing crease fail reserved pixels at 8.274/8.414px
under the unchanged 8px gate; neither retuned. Two-view cached-track diagnosis
has 157/157 below 8px (median 1.066px); alternate disjoint-point pose does not
rescue manual marks. Two threshold features remain potential anchors; cabinet/
pedestal shadow candidates are insufficient to define a floor plane. No floor,
collision, metric scale or camera accepted. Historical/fresh models, ten originals
and completed holdouts verified unchanged. Existing historical bounded walk passes
24 native/browser checks and real WASD round trip. Shell has four prior failures;
repository/pose/diff checks pass. Existing Muse receipts and rejected meshes
preserved. No runtime/Viewer edit, paid generation, integration or ticket closure.


## Collection corrected-model floor hypothesis — September 30, 08:30 UTC heartbeat

Local pycolmap CUDA / NumPy / Pillow / Godot 4.7.2 / Chrome 154; **$0**.
[Source selections, frozen floor masks, raw logs and hashes](../../docs/evidence/collection-reconstruction/heartbeat-20260930T0830/provenance.json).

Three source-visible floor features from corrected cameras 13/19; reserved 21/25
each lack one track. Earlier visit 245 predicts all three within 0.63/1.64/4.95px,
an exploratory same-video diagnostic. Triangle-normal pixel sensitivity p95
17.93 degrees: no collision acceptance. New six-view RTX 4070SUPER CUDA depth
excludes reserved 21/25; near/far valid fractions 38.62/87.48 percent, candidate
normal difference 3.16 degrees. No old scale or floor geometry transplanted.
Block residuals are correlated and expressed in world units; cross-view depth
checks remain outstanding. Planar/negative/camera-round-trip checks pass.
Existing historical bounded walk passes 24 native/Chrome checks and real WASD
round trip; timings excluded from acceptance due to overlapping work. Initial
missing native capture directory error retained, corrected run inspected.
Isolated Shell retains four prior failures; repository checks pass with eight
ObjectDB leak warnings. Ten originals and completed models/holdouts preserved.
Muse receipts and rejected sculpture meshes unchanged. No runtime/Viewer edit,
production integration, paid generation or ticket closure.

## Collection withheld floor transfer — September 30, 12:30 UTC heartbeat

Local NumPy/pycolmap/Pillow CPU diagnostics and Godot 4.7.2 / Chrome 154
on D3D12 RTX 4070 SUPER; **$0**, zero paid calls or new reconstruction sweeps.
[Sources, results and hashes](../../docs/evidence/collection-reconstruction/heartbeat-20260930T1230/provenance.json).
Recovered the interrupted 09:00 strict-model cross-view/withheld-point evidence;
its original files and frozen source models remain unchanged. New generator
option: `floor_holdout.py --photometric`, preserving the upper-image-only pose
and reserved floor-feature exclusions.

Far-plane image transfer in reserved 246 distinguishes the fixed ±5% camera-depth
normal offsets, but the near patch has no common visible pixels there. Reserved
506 has weaker discrimination: shifted controls score better for both patches.
No plane optimization, retuning, collision extension or physical acceptance.
Subpixel sampling, plane projection assertions and exact previous-result replay
pass. Historical bounded native/browser walk passes all 24 engine checks and
real WASD round trips; Shell retains four known failures. Museum topology, scale,
whole-room collisions, sculpture coverage and bake remain open. No runtime/Viewer
edit, production integration, ticket closure or new paid generation.


## Collection wider-floor and entry-pose diagnostic — September 30, 15:00 UTC heartbeat

Local NumPy/pycolmap/Pillow/Godot 4.7.2/Chrome 154; **$0**, no paid calls or
new reconstruction sweep. RTX 4070 SUPER native/browser rendering; poses CPU.
[Selections, inputs, outputs and hashes](../../docs/evidence/collection-reconstruction/heartbeat-20260930T1500/provenance.json).

Wider floor triangle has missing reserved anchors and 13.79-degree p95 normal
sensitivity. Reverse queries remain unsupported. Source-reviewed entry206 wall
mask passes 68 fit inliers and 59 unused points; original cutoff failure retained.
Shifted floor controls still score better; no floor/collision acceptance.
Native/browser bounded walk checks pass; Shell has seven previously seen failures.
Default replay, rejection guards and camera serialization pass; ten originals and
prior pending work preserved. Existing Muse receipts and rejected sculpture meshes
unchanged. No runtime/Viewer edit, production integration or ticket closure.


## Collection native floor coverage — September 30, 16:00 UTC heartbeat

Local pycolmap CUDA / NumPy / Pillow / Godot 4.7.2 / Chrome 154 on RTX 4070 SUPER;
**$0**, no paid calls. Four existing native frames, frozen strict sparse model
and upper-wall-only reserved poses; CPU pose/ray algebra. Generator:
`prototype/collection_reconstruction/native_floor_tracks.py`.
[Inputs, commands, outputs and hashes](../../docs/evidence/collection-reconstruction/heartbeat-20260930T1600/provenance.json).

One native interior-floor candidate predicts reserved 506 at 6.330px; no match
in 246. Identity remains tentative. Combining it with frozen threshold tracks
has 15.975-degree p95 normal sensitivity; shifted controls still score better
in 506. No plane, metric scale or collision acceptance. Reserved views reused,
not independent capture. Supported cameras serialize opt-in without changing
default diagnostic results; exact replay and negative controls pass.
All 24 native/RTX Chrome bounded-walk checks and real WASD round trip pass;
Shell retains five prior failures. Original inputs/pending work preserved;
Muse receipts and rejected head meshes unchanged. No runtime/Viewer edit,
production integration, paid retry or ticket closure.

## Collection near-floor coverage limit — September 30, 16:30 UTC heartbeat

Local pycolmap CUDA / ffmpeg NVDEC / NumPy / Pillow / Godot4.7.2 / Chrome154
on RTX4070SUPER; **$0**, zero paid calls; CPU pose/ray algebra.
[Sources, commands, checks and hashes](../../docs/evidence/collection-reconstruction/heartbeat-20260930T1630/provenance.json).

Frozen exit 13/19 near-floor masks contain zero shared sparse or native SIFT
matches (54/91 floor detections,318 raw source-pair matches). No triangle fitted.
Explicitly opted-in registered 21/25 query cameras are globally fitted diagnostics;
original wall-only setup remains checked. Source freeze, camera round trips,
registered-scope and overwrite guards pass. Legacy raw image caption is corrected
only in derived evidence; original outputs preserved. Existing floor anchors have
no cross-clip tracks. Supplemental IMG_6384 doorway source context inspected, without
new connection or surface acceptance. All 24 native/Chrome bounded-walk checks and
real WASD round trip pass; repository passes, Shell has eight previously observed
failure names. Earlier pending work and frozen inputs preserved. Muse sheet and
rejected head-v2 remain unchanged. No runtime/Viewer edit, collision extension,
production integration, paid retry or ticket closure.


## Collection supplemental doorway contact — September 30, 17:00 UTC main worker

Local ffmpeg CUDA NVDEC / scale_cuda, pycolmap / NumPy CPU ray and camera algebra,
Godot4.7.2 / Chrome154 D3D12 RTX4070SUPER; **$0**, no paid calls.
[Inputs, outputs, commands and hashes](../../docs/evidence/collection-reconstruction/heartbeat-20260930T1700/provenance.json).

Owner stopped scheduled Collection heartbeat; disabled receipt verified. Existing
holdout retained. Two source-visible left jamb/floor marks yield1.57/1.54px fit
residuals,4.16-degree viewing angle. Reserved206 wall-only pose has72 fit inliers
and77 unused points below4px. Approximate same-worker visual residual5.48px is
not blind annotation or an independent capture. Depth perturbation p95=11.29%
of camera distance; no floor, metric scale, opening width or collision acceptance.
Nominal-time native seeks rejected; full-stream fps2 restores survey correspondence.
24 native/Chrome bounded-walk checks and real WASD round trip pass on RTX4070SUPER;
repository/diff pass, GPU Shell retains four known failures. Initial software and
failed cleanup trials retained. Pending work/frozen models preserved. Muse sheet
and rejected head-v2 inspected, unchanged. No runtime/Viewer edit, production
integration, paid retry or ticket closure. Next: separated opening views.

### 2026-09-30 — main worker room route and inferred head closure (#182/#183)

- Sources: hash-pinned strict sparse model, two IMG_6380 bookcase views plus a third manual-pixel check, cached CUDA depth `dense-expanded-v1`, and the unchanged Muse front/rear sheet SHA256 `0325b88fba070b85c957a6991623c843c1515b83c508b37dc09cc43b8906064f`.
- Provider: local NumPy/pycolmap geometry, Godot 4.7.2 and Chrome on RTX4070 SUPER. Appearance reuses OpenRouter `meta/muse-image`, run `run-5ac877552e2b1979a8edb87c`, source cost $0.01, unknown reservation / never-resubmit. No new paid calls; map total recorded $0.02.
- Outputs: isolated `room-route-walk-v3` and inferred `head-closure-v6`, under ingestion root; generated screenshots, source/result hashes and checks in `docs/evidence/collection-reconstruction/main-worker-20260930T1835/manifest.json`. Neither is a runtime dependency.
- Review: room native/browser checks and keyboard round trip pass; model scale, floor/door proxies and full room limits remain unaccepted. Head position mesh closed and UV background sampled clean; front/rear profile seam and inferred side/top/underside remain unaccepted. Not a complete scan or map.

### 2026-09-30 — source-only capture validation and blended inferred head (#182/#183)

- Inputs: fresh IMG_6380-only `sfm-capture-split-v1` with nominal freely refined intrinsics, excluded IMG_6384 camera queries, corrected bookcase endpoint pixels, and unchanged Muse texture SHA256 `0325b88fba070b85c957a6991623c843c1515b83c508b37dc09cc43b8906064f`. Hashes and full reports: `docs/evidence/collection-reconstruction/main-worker-20260930T1917/manifest.json`.
- Provider/cost: local NumPy/pycolmap/Godot/Chrome; cached CUDA features/depth, documented Ceres CPU BA fallback, RTX4070 SUPER render checks. No new paid generation; existing OpenRouter `meta/muse-image` sheet cost $0.01 and unknown/never-resubmit reservation retained. Total map generation remains recorded $0.02.
- Outputs: `room-route-walk-v5`, `head-closure-v7` and five exported sculpture views, kept as trials under ingestion, with screenshot evidence in the dated folder. Head shader blends source front/rear UVs without changing the source image. Closed topology/background sampling passes; side shape and photographic fidelity remain inferred/unaccepted.
- Correction: the source left "jamb" pixel is an open door leaf edge. New labels identify it; clearance boxes are experiments, not fixed architectural collisions. Three excluded-capture views pass pose support; separate floor correspondence validation fails and does not authorize physical floors. Full rooms/map and production integration remain unfinished.

## 2026-09-30 — Collection low polygon room remodel (#182/#183)

Owner correction: authored low polygon rooms with Muse assets; captured spacing is a guide, not a point-cloud presentation. Bookcase 2017.74.9, source gilt mirror and sofa cloth: OpenRouter `meta/muse-image`, one output each, new recorded $0.03; map total $0.05. Run IDs, source/prompt/output SHA256, paid receipts and immutable archive: `image-work/collection-room-remodel/{sources.json,review.json,trial/muse-runs.tar.gz}`. Each dispatch counts spent, unknown reconciliation / never-resubmit. Earlier frame/sheet costs unchanged; no sculpture retry.

Low polygon shelf/cabinet/leg geometry, mirrored outline extrusion, walls/trim, boards and provisional furniture assembled in a standalone two-room walk. Existing approved frame/authentic painting and Main Hall visitor159 reused; visitor inputs/code/provenance unchanged, private only. Native Muse rasters untouched; keyed transparent RGB receives neutral edge padding. Rejected wall intersections, integer-collapsed solids, repeated atlas bands and trim occlusion corrected. Placements, mirror pair/scale, hidden profiles, sofa/vessels, remaining artwork and offline UV2 room bake are unverified.

Final native/Chrome RTX4070 SUPER walk: 12/12 checks each, real W/S round trip, five inspected native asset/room views; p95 native17.70ms/browser16.67ms. Repo/diff checks pass; isolated Shell retains four known failures. Evidence/hash manifest: `docs/evidence/collection-reconstruction/main-worker-remodel-20260930T2023/manifest.json`; dated checkpoint: `docs/research/collection-room-remodel-20260930.md`. Prior pending files preserved; Collection automation disabled. No Viewer changes, production integration, ticket closure or full-map claim.

## Collection Rockefeller room trials — 2026-09-30, #182/#183

Six additional one-output OpenRouter `meta/muse-image` passes: catalogue-matched
settee 2017.74.5, chairs 2017.74.7.1 and 2017.74.12, mirror 2017.74.4.2,
tureen 2017.74.39.18a-c and source-rectified frame for Constable 58.197.
Each actual receipt records **$0.010000**; new recorded spend **$0.060000**,
map cumulative **$0.110000**. All retain unknown spend / never-resubmit.
Prompt, ordered references, original provider pixels, receipt/run IDs, SHA256
and agent visual verdicts: `image-work/collection-room-remodel/review.json`;
complete sanitized run archive: `trial/muse-rockefeller-runs.tar.gz` there.
Untouched official API/catalogue photos and their hashes: `catalogue/`.
Mrs. Edwards canvas remains the authentic catalogue image, separate from Muse
frame carving. Catalogue credit: Courtesy of the RISD Museum, Providence, RI.
Private prototype trials; rights flags retained, no runtime acceptance implied.

Exact latest inspected Main Hall page/clock, screen/floor shaders, selected
floor atlas, wall-grain source and painting helper are recorded by source SHA256
in `presentation-reuse.json`. Ivory wall paint derives deterministically from
that grain to match this gallery video. UV2/native LightmapGI bake and dynamic
actor probes reuse the Hall workflow; preview RTX, bake software Vulkan in WSL.
Source transforms, asset geometry limitations and object match evidence:
[room research](../../docs/research/collection-rockefeller-remodel.md).
Visual/checkpoint evidence: `docs/evidence/collection-reconstruction/`
`main-worker-rockefeller-20260930/`. Hidden profiles, remaining porcelain,
room metrics and full connected museum remain unfinished; no 3D Viewer change.

## Collection inventory and Muse architecture trials — 2026-09-30, #181/#182/#183

Sole main worker; owner stopped the Collection heartbeat and explicitly extended the goal to all ten supplied videos. Collection map prototypes only; 3D Viewer, frozen interfaces and acceptance tests untouched. No production integration or issue closure.

49 new successful one-output **OpenRouter `meta/muse-image`** runs cover catalogue-matched bookcase objects, porcelain service components, bust front/rear, sconces, writing table, secretary, Romany frame and three architectural assets (ivory plaster, architrave, baseboard). Each authenticated receipt reports $0.010000: **$0.490000 new actual**, **$0.600000 map cumulative actual**. The distinct combined Vincennes pair run `run-7b018ec98c334a45ef16e681` has no reconciled provider result/ID; reserve $0.010000 as possibly spent, giving **$0.610000 conservative ceiling**. It was not resubmitted. The successful labelled ecuelle received one deliberate cleanup pass; the original and changed output remain separate. Residual paper/string fidelity remains a finding.

Native rasters, source/reference/prompt hashes, recipes, Objectives, sanitized receipts and per-object verdicts remain in `image-work/collection-room-remodel/`. Full new Run Records including ordered embedded source bytes: `docs/evidence/collection-reconstruction/main-worker-inventory-20260930/inventory-muse-{objects,services}-runs.tar.gz`, indexed by `inventory-muse-archives.json`. Exact API/HTML responses are in `inventory-catalogue/official-responses.tar.gz`, with `source-manifest.json`; original downloaded photographs remain locally retained, and selected generation reference pixels are inside the run archives. API public-domain flags/credit are preserved; no blanket rights claim. Authentic catalogue canvases remain separate from Muse frames. Catalogue credit: Courtesy of the RISD Museum, Providence, RI.

The application's existing immutable Tool Lock is still artifact `e6d0a4befe3533e90a257d927c449f035dcdd7fc0e8824d1f432854d279b8075`, release v0.3.0, commit `8683520ce90e1df15ba5be0344141d2e01e013ea`. During architecture planning the global CLI advanced to a different artifact, so the unpaid plan stopped before reservation. New architecture calls deliberately use the retained exact matching distribution `.tool-builds/1790783219515/scripts/image-pipeline.js` with its normal gates; no lock bypass or update of old runs.

Owner correction and native wide videos reject v15's same-wall gallery door/sofa arrangement. v17 moves the gallery connection to the perpendicular wall and revises cases, sconces, entrance chair, table and bust spacing. The provisional portrait-plane camera fit uses four annotated canvas corners and inferred focal length; its residual is fit evidence, not independent room acceptance. Native reverse-entry comparisons are inspected separately. New Muse plaster receives explicit contrast restraint and mirrored edge assembly; architrave/baseboard strips exclude generated end caps and are applied to native shallow stepped profiles. Video is reference/measurement only, never final room albedo. Case supports, furniture bodies, roof tracks and deep door reveals are native geometry. Depths, exact room dimensions and hidden anatomy remain provisional; the unused head v1/v2 failures are not called finished.

v17 native and Chrome on RTX4070 SUPER: **18/18 collision/camera checks each**, plus real S/W gallery-door round trip. Native/browser p95 **30.30/30.56ms** does not establish 60fps acceptance. Main Hall visitor/frame/screen/floor and UV2 lighting workflow retained. 279 lightmap users baked in 28.76s via software Vulkan because the NVIDIA Vulkan ICD probe fails in this WSL host; native/browser rendering uses verified D3D12 RTX. Repository/diff checks pass; Shell playtest is 44/48 with the four existing layout/pixel failures. Dated checkpoint, native/web proof, source comparison, maps, all-ten-video frontier and SHA256 evidence: `docs/evidence/collection-reconstruction/main-worker-architecture-20260930T2115/`. Whole reconstruction remains active and incomplete.

## Collection wide-shot refinement — 2026-09-30, v19 (#178/#182/#183 prototype)

The corrected perpendicular gallery doorway, two-wall cases and furniture spacing remain the v17 study. v19 adds Arabesque Wallpaper 34.912 / API ID 1240221, matched by diamond/birds/figure/garlands to native IMG_6380 at 210.25s. The official raster and API dimensions (56 × 114.5 cm) are preserved in `image-work/collection-room-remodel/inventory-catalogue/arabesque-wallpaper*`. White mount dimensions and metric placement remain provisional. Source-video pixels never become room albedo.

Bust 37.201 uses distinct saved Muse front/rear UVs, excluding their differing generated socles/display stands. Its body has 320 outward-wound triangles/480 paired edges; the connected native marble socle retains 60.6 cm total height. Front/rear Godot views inspected; side profile/seam provisional. No new sculpture charge; native Muse rasters unchanged.

Fetti's *Christ Ministered To by the Angels*, 36.003 / API ID 1534546, matches IMG_6386 32.25/33.75s. One OpenRouter `meta/muse-image` frame pass: run `run-ebee8724fca764b64861e626`, count 1, actual $0.010000, native SHA-256 `948eaa974aa00b2fc701d5fb6f993bd70da2a19f4282222ef265e06e3a500f35`. Ordered references, recipe and matching retained Tool Lock preserved; sanitized full Run is `docs/evidence/collection-reconstruction/main-worker-wide-20260930T2140/fetti-muse-run.tar.gz`. Four-mesh frame plus authentic catalogue image inspected in three Godot views. Trial only: canvas crop/depth/room pose/bake unverified. Native source raster unchanged.

Expansion: 50 successful new outputs, $0.50 actual; prior map $0.11; map $0.61 actual, $0.62 conservative including the unreconciled central pair. The possibly-spent pair was not resubmitted.

Evidence is `docs/evidence/collection-reconstruction/main-worker-wide-20260930T2140/`. Native/Chrome RTX4070 SUPER checks 18/18 each plus real S/W door round trip, p95 31.94/32.57 ms, not 60fps acceptance. 287 lightmap users; software Vulkan bake. Repo/diff checks pass. Shell 42/48 then 41/48: four known layout/pixel failures plus varying pressed/dip timing failures; raw logs retained, frozen Shell/Tab unchanged. Earlier pending bytes preserved; Viewer untouched; tickets open, no production integration. Remaining rooms/objects, brown textile/four prints, exact spacing and hidden profiles incomplete.


## 2026-09-30 — main worker: complete long-gallery survey and v21 doorway study (#178/#182/#183)

All 497 cached 2fps frames across IMG_6384/6385/6386 visually inspected as 21 orientation-corrected contact sheets. Ordered lower-bound inventory in `image-work/collection-room-remodel/european-gallery-inventory.json`: 24 long-wall groups, one further far-corner painting, nine display/furniture groups. Images are references only, not room albedo. Full all-ten-video reconstruction remains incomplete.

One new OpenRouter `meta/muse-image` output for the black/gold 61.006 frame; run `run-d3202a36f847df0bc6a9c777`, count 1, actual $0.01. Native 1440x1760 raster SHA256 `4ec50fbf65f473b9fda5b27d57dd87fa97863c6451c1c9955845f084361f105e`. Saved recipe, ordered source, prompt/plan/hash, locked-tool objective, receipt and full sanitized run archive retained. Bands exaggerate source width; three native assembled views inspected, trial rejected for room integration pending deterministic compression. No retry. Expansion 51 successful outputs/$0.51; map actual $0.62, conservative$0.63 including unresolved central-pair reservation. Head v1/v2 remain failed, central run unreconciled.

RISD API IDs 1552761(61.006),1461686(16.237),1545731(69.197),1411831(06.057) and official native photographs matched to video; gallery assets pending except already generated 36.003 Fetti frame now installed. Fetti official photo deterministic canvas crop (38,28,1289,1469) excludes photographed gilt edge; original untouched, catalogue canvas 781 × 895 mm retained, crop aspect checked. Cuyp 62.019 rejected for the blue-cloud painting. Raw primary responses in evidence archive; originals/hashes in application/prototype manifests.

v21 authors two source-observed east-wall piers and the far end doorway crossed in IMG_6386, with open panelled leaves and only 1.6m walkable threshold beyond. All metric room/pier/object positions provisional; successor sculpture room unfinished. Existing Muse plaster/trim and Main Hall frame/shader/visitor reused. LightmapGI 333 users on CPU software Vulkan, RTX native/browser rendering; 22/22 native and Chrome154 camera/collision checks, real Rockefeller keyboard roundtrip, no browser errors, p95~30.95ms (not 60fps). Owning Shell 46/50 with four existing layout/pixel failures; module doc 48 count stale. scripts/check.sh and gitdiff checks pass. Evidence: `docs/evidence/collection-reconstruction/main-worker-gallery-20260930T2200/`. No Viewer or frozen interface/acceptance changes; heartbeat remains disabled.

## 2026-10-01 · Collection sculpture-room layout / Muse stone architecture prototype

- Sources: all 226 IMG_6382 and 147 IMG_6383 survey frames, 17 ordered contact sheets; `image-work/collection-room-remodel/sculpture-room-inventory.json` records 27 display/artwork groups, unresolved identities and source-confirmed wall/door relations. Long gallery → light Renaissance room → perpendicular Gothic doorway → dark medieval room; medieval long axis joins Gothic/stairs doors, round portal on adjacent long wall. Every metric room extent/object offset remains provisional.
- OpenRouter `meta/muse-image`: one output each, $0.01 each ($0.02 total). Romanesque Portal 40.014/API1588546, run `run-02d8d914fc368baa9f3889da`, native SHA256 `a66a3fb3f663b619a165df5e672225c005c4643528e06e0775a2af36f2738ccd`. Tracery Arch 40.156.1/API1428171, run `run-113954426fe4ae8221b77d16`; native SHA256 `394384a5c0bb3094fa91b58db948f000b274270752f464a94c5b085b50a08805`; ordered official/video references in its source/geometry records. Pinned saved pipeline/Tool Lock retained. Map actual $0.64; conservative $0.65 including unresolved central-deities reservation; no ambiguous or failed-head retries.
- `architecture-assemble.py` retains original rasters, keys magenta and extrudes silhouettes into native closed meshes (9,280/12,356 stone triangles; every quad edge paired twice). Separate wall infill keeps walk-through/carved holes open. Portal depth .45m inferred; tracery top fragment 1.410×1.092×.273m catalogue-based; shafts separate. Constant-depth carving, stepped edges, column relief, rear appearance and whole-object fidelity remain incomplete. Native UV2/LightmapGI, visitor, frame and shaders follow saved Main Hall recipe. Shared wall inward faces prevent light/dark material flicker. Existing vents join ceiling cutaway after actual browser inspection. Medieval herringbone uses existing lattice; clipped plank area asserted equal to room area.
- Saved Goltzius61.006 frame compressed from native 19.25s corner estimates, crosschecked 18.25s (margin disagreement up to 28.35mm). All blank-opening pixels and original Muse hash preserved. Authentic painting remains separate; fifth painting in provisional observed wall order. Gold facets, frame depth/pose are unaccepted. No paid call.
- Evidence/checks: `docs/evidence/collection-reconstruction/main-worker-room-layout-20260930T2230/`. Native v25: 36/36 collision/camera checks, RTX4070SUPER, p95 30.771ms; browser36/36 plus real keyboard round trip, p95 29.630ms, no JS/runtime errors. Bake 417 users via software Vulkan CPU (31.93s); known editor quit errors after BAKE_OK retained; runtime renders on RTX. Shell 44/50 twice (four existing layout/pixel plus pressed/dip timing failures); repository check and diff check passed. Full map/performance acceptance remains incomplete. Main Hall/stairs are only short threshold limits, most sculpture/gallery displays absent. Heartbeat stays disabled; sole main worker, Viewer untouched.

### Collection room v26 — wide-shot corrections and full survey (2026-10-01)

Owner-directed low-polygon prototype only, issues #178/#181/#182/#183. All ten videos surveyed: 2,485 extracted 2fps frames, including 1,615 newly reviewed frames across 70 archived sheets. Six new catalogue identities and 11 observed connections recorded; surveyed rooms not yet integrated. Reciprocal wide views corrected settee alignment and gold-case solid pedestal. Added purple-plaster Muse via OpenRouter `meta/muse-image`, run `run-f044332d91c6c643c123a27c`, objective `muse-b135ab280d1bbe2d2aff`, one output $0.01, SHA256 `b93be3c69cd85bdef675e4aa096196f5c76c8ac3835f82bac27962f526efc08a`; native output preserved, contrast reduced to 12% with mirrored tile edges asserted. Provider receipt/source/prompt/references retained in `image-work/collection-room-remodel/`; sanitized run archived in this checkpoint. Cumulative map actual $0.65/conservative $0.66 includes unresolved submission; no paid retry. Exact wall colour and room geometry remain provisional.

Evidence: `docs/evidence/collection-reconstruction/main-worker-full-survey-20261001T0315/`. Native RTX 38/38 and Chrome RTX ANGLE 38/38 plus keyboard round trip; p95 30.00ms/29.63ms (below 60fps acceptance). Software browser separately retained. LightmapGI 413 surfaces, 32.36s CPU Vulkan. Native/browser screenshots inspected, 105 input hashes verified; repository and diff checks passed. Shell 45/50 includes four prior layout/pixel mismatches and dip timing. Heartbeat disabled; 3D Viewer/frozen tests unchanged. Missing rooms/objects/back surfaces and measured placements remain unfinished. Stable owner preview `/risd-frame-review-01a0ee18/progress/`.

### Collection room v31 — grey gallery and architectural faces (2026-10-01)

Owner-directed low-polygon prototype only, issues #178/#181/#182/#183. Reciprocal wide shots put the Ionic opening directly across from purple connector, with piano and Grand Gallery doors on adjoining walls. Added provisional grey room, three closed threshold limits, herringbone floor, source-aligned connector boards and distinct Courbet/Corot frames around authentic RISD images. Muse door panels assembled at unequal heights around native stiles/rails; generated extra jamb excluded. Room walls and black panels now render inward faces only; panel children follow owning wall cutaway. Original native Muse files preserved; source-fitted frame bands retain opening pixels exactly.

courbet-frame: OpenRouter meta/muse-image, run-7e028b981f18c5b78af63cab, one output $0.01, SHA256 11c5cf4d300dec8d93f60cd19bb9337d0fcb5e46ac611ceaa74658f3124abc32
corot-frame: OpenRouter meta/muse-image, run-8902003cc69f35806e2c3472, one output $0.01, SHA256 f9eb7545c390eaa57834237830e5ee3d788a13d5b7f5651ab94724cb6e8e5780
white-panel-door: OpenRouter meta/muse-image, run-e7b18db5374fdc5e0b548a35, one output $0.01, SHA256 bdb409892fa25e41b6ec0942329f32c3a975c3e6e19e54152f378e69434f1546

New spend $0.03; cumulative map $0.68 actual/$0.69 conservative including unresolved submission. No paid retry. Exact wall palette, support-versus-frame dimensions, hidden profiles, moulding relief, door hardware/reverse and measured room/object placement remain unaccepted. Villeneuve1998.35, Daubigny73.120 and Pannini56.094 newly matched to native source and official RISD images; remaining source candidates not falsely accepted.

Evidence: `docs/evidence/collection-reconstruction/main-worker-grey-gallery-20261001T0340/`. Native RTX54/54, p95 30.56ms; Chrome154 RTX ANGLE54/54 plus actual keyboard round trip, p95 29.63ms. These exceed a60fps frame budget. LightmapGI561 users, 46.78s CPU Vulkan bake; editor cleanup errors retained, no runtime/JS errors in browser. 111 source hashes and three paid output hashes verified. Source/wide/detail/native/browser images inspected. Repository/diff checks pass; Shell44/50 retains four layout/pixel failures and two timing failures. Original50 pending files preserved; Viewer/frozen Shell unchanged, heartbeat disabled. Full Grand Gallery loop, stairs, Ionic detail, Rodin sculpture, most paintings and other surveyed rooms remain unfinished. Preview `/risd-frame-review-01a0ee18/progress/`.

### Collection room v34 — source-guided Muse Ionic capitals (2026-10-01)

Issues #178/#181/#182/#183; owner-directed low-polygon Collection prototype only. One Muse twin-scroll capital, OpenRouter meta/muse-image, run-db146fcf707e6f70e45cd014, one output $0.01. Original1760x1440 retained intact; SHA256 a05e91afda0907daf0b737a0c767d4a9f6fd9f18e5ade9d8e445d663e8f55481. Reference native6380:34.25s capital/context and saved Main Hall style. Reused existing closed silhouette assembly:1928 triangles, every mesh edge paired twice, provisional0.72x0.40x0.32m. Two capitals parented to existing columns; ordinary door trim removed from column openings after close-up showed it crossed the capitals. Entablature remains a plain beam; scroll relief, side/rear and exact scale remain unaccepted.

New spend$0.01; cumulative map$0.69 actual/$0.70 conservative,58 successful expansion outputs plus prior$0.11 baseline. Unresolved river-deities submission reserved separately; no retry. JSON numbers versus integer-array equality stopped v32 scratch construction; corrected the closure guard and added a bake-wrapper check for complete grey-gallery inventory before baking. Partial scratch output never published.

Evidence: `docs/evidence/collection-reconstruction/main-worker-ionic-20261001T0400/`. Native RTX54/54, p9530.30ms; Chrome RTX54/54 plus actual keyboard round trip, p9528.70ms. LightmapGI545 users,44.81s CPU Vulkan bake, original GLES renderer config restored. Known editor cleanup errors retained; no runtime/JS browser errors.113 source hashes and native paid hash verified. Native source, front, oblique, wider room and browser renders inspected. Repository/diff checks pass; most recent owning Shell44/50 retains four layout/pixel failures and two timing failures; frozen Shell unchanged. Original50 pending files preserved.

Wide-view review found current grey and medieval Hall entrance centres offset4.60m laterally and17.05m along the prototype axis; this does not fit saved authored Hall26.3m long with aligned doors. Recorded in loop-spacing-check.json; no invented connector added. All room/object metric fits, most objects and full Hall/stair reconstruction remain unfinished. Viewer unchanged, heartbeat disabled. Preview `/risd-frame-review-01a0ee18/progress/`.

### Collection wide-view scale study — 2026-10-01

Unpaid native CUDA source captures and two independent end-wall canvas-plane checks, preserved in `docs/evidence/collection-reconstruction/main-worker-wide-scale-20261001T0430/`. Official RISD API id1361921, Lawrence Portrait of Lady Sarah Ingestre60.039,235.1x142.9cm, visually matched to both source views and the existing Hall record. Raw response/image hashes retained. Red annotations and measurement crops are review evidence only, never runtime textures. No new Muse spend; map remains$0.69 actual/$0.70 conservative.

Rough widths9.384m and10.659m assume a centred doorway and approximate floor corner. Saved10m Hall width is compatible; Hall length and adjoining geometry remain unverified. Canvas spans47–50 native pixels; small corner changes destabilize pose. Corrected lower canvas-edge marks after inspecting overlays; rejected low-residual poses with impossible heights before correction and inconsistent horizontal positions afterward. Larger side-wall Barbier-Walbonne family painting2003.105 /id1581546 matches source and official image; partly occluded canvas prevents accepted joint fit. fit.py uses no focal estimate, point cloud or reconstructed mesh; explicit scale/cross-view checks pass. Width sensitivity to2px annotation changes is recorded, not a confidence interval or metric acceptance. Runtime remains published v34; original50 pending bytes and Viewer/frozen Shell preserved. Next fit near/far and European/Renaissance/medieval offsets before full Hall reuse.

### Collection European/Renaissance door correction — 2026-10-01 05:08 UTC

Wide native IMG_6386 at102.75/104.75s reveals two unequal recessed panels and swing into Renaissance. Corrected the prior three-panel/backwards leaves in the isolated Collection prototype v35. New OpenRouter meta/muse-image output run-d6f87926e37f8ad942651a4e, one$0.010000, native1440x1760 WebP SHA256cdef0be96028f04b58069c294796f6cabeb7ba43c001fd3175617814b68036ed. Muse invented a narrow middle strip; deterministic Assembly uses only the two large panel regions, retains native bytes and excludes the strip/generated knob. Native thickness, shallow moulding, mirrored leaves and simple knobs; authored metric extent/swing angle and dark palette unaccepted. Recipe, references, receipt, full run archive and reproducible crop/hash check retained. Cumulative map$0.70 actual/$0.71 conservative; prior ambiguous charge and failed heads still unresolved.

Evidence: docs/evidence/collection-reconstruction/main-worker-european-door-20261001T0500/. Source116 hashes; CPU LightmapGI583 users46.21s, RTX native58/58 p9530.556ms; Chrome154 RTX ANGLE58/58 plus actual keyboard round trip, p9530.200ms, cold ready5011ms, errors[]. First software browser saved separately and rerun on required RTX. Repository checks pass; owning Shell44/50 recorded failures, frozen tests untouched. Native front/reverse/detail/wide, both leaf collisions and Chrome renders inspected. Room/global layout, full Hall loop, most Renaissance/medieval contents and60fps target remain unfinished. 3D Viewer untouched, heartbeat disabled; original50 pending bytes preserved, only prototype scope checkpointed.

### Collection v36 — reciprocal-wide medieval case arrangement (2026-10-01)

Issues #178/#181/#182/#183, sole main worker; Collection prototype only. Native IMG_6382 78.25/88.75/96.25s show a broad low relief case south-west of the smaller taller case near the stair doorway. Added two empty native case shells: grey solid bases, white trays, different glass heights, inset rims and glass lids. Existing Muse architecture/Main Hall presentation retained; no new image generation or paid spend. Cumulative $0.70 actual/$0.71 conservative; ambiguous river-deities and failed head trials unchanged. Exact case size/offset and room extents unaccepted; case contents and all room contents explicitly incomplete.

Evidence: `docs/evidence/collection-reconstruction/main-worker-medieval-cases-20261001T0525/`. Rebuilt LightmapGI589 users,46.46s CPU Vulkan fallback, GLES configuration restored. Native RTX66/66, p9529.906ms; RTX Chrome66/66 plus keyboard round trip, p9528.788ms, no browser errors. Initial seven-metre timed route could only travel3.75m; source case geometry was not blocking it. Retained65/66 first result and corrected the stairs-aisle test to2.7m within its time budget, then reran.116 input hashes verified. Owning Shell44/50 retains four layout/pixel and two timing failures; frozen Shell untouched. Native two-direction case views/four walking views, Shell resize and browser images inspected. Repo/diff checks pass, original50 pending bytes preserved.

Clear native6380 106.75s shows the grey-to-Hall door meeting blue Hall immediately; do not import the older2.6m vestibule. Small painting on adjacent pier is still unmatched, not Pannini56.094; do not use that accession to scale this pier. Hall entrance4.60m lateral discrepancy remains unresolved. Full reconstruction unfinished, 3D Viewer untouched, heartbeat disabled.

### Collection v38 — source-matched Bertin and neutral grey-room fill (2026-10-01)

Collection-only prototype, issues #178/#181/#182/#183, sole main worker. Native IMG_6380 90.25/91.25s matches RISD API1296426, Jean-Victor Bertin, Tivoli56.214, canvas48.9x65.1cm: three falls, distant bridge, right trees and foreground figures. Added official canvas with one OpenRouter meta/muse-image frame output, run6c7677a64b663135844fdbcb, $0.010000, native SHA2565e82e83b9907e8bd32f110543265906e76dd1dbfe3911f56af0185e0712f9da1. Cumulative map $0.71 actual/$0.72 conservative. Generated corner steps, leaf proportions, rear9cm profile and gold tone remain unaccepted. Placement on Hall-door wall between Villeneuve and Pannini is source-relative; exact offset unaccepted. Superseded unpaid objective muse-e1887d3ec429de350796 hit an immutable-reference hash gate before provider execution; original bytes restored, never execute it. Distinct muse-b4baba9916aad86a02e8 executed once; no paid retry. Full run/provenance archived.

Native before/after inspection found warm plaster texture plus amber fill made grey walls brown. Reused existing Muse plaster grain with neutral RGB228 target, neutral local grey/medieval fill, and existing Main Hall ambientCBD4E1/.22. Warm painting spots, oak and presentation shaders retained. Improved visible cast; exact source brightness/colour still unaccepted.593-user bake44.93s CPU Vulkan fallback, renderer config restored. RTX native66/66 p9530.303ms; RTX Chrome66/66 plus keyboard round trip p9528.571ms, browser errors[]. Owning Shell46/50; 4 frozen layout/pixel checks fail, full output archived. Repository/diff checks pass. Evidence `docs/evidence/collection-reconstruction/main-worker-bertin-20261001T0555/`; native before/after, source and browser views inspected. Original50 pending bytes preserved.

Small grey doorway-pier painting remains unmatched; it is not nearby Pannini. Hall entry lateral4.60m/axial17.05m discrepancy unresolved. No room shifts or fabricated connector made. Old centered end-door assumption is unverified; a possible offset-door fit must be checked against reciprocal source views, not accepted because coordinates close. Existing Hall26.3m length is provisional; 23 catalogued canvases alone total13.32m west/13.039m east. Inferred frame bands and assumed0.4m gaps imply19.989/19.565m before end clearance, not measured room length. Full reconstruction incomplete; 3D Viewer/frozen seams untouched, heartbeat disabled.

### Collection v39 — Renaissance source reference and repeatable bake (2026-10-01)

Collection-only prototype, issues #178/#181/#182/#183. Sole main worker; heartbeat remains disabled. Native IMG_6383 35.75/63.75/64.75s identifies Pietro Perugino Madonna and Child16.236, RISD API1546096, support57.5x39.1cm. Mother/child, raised hand/apple, church and hills matched to official photo. One OpenRouter meta/muse-image architectural-frame pass, runf55959297094d15b07761914, $0.010000 actualCostUsd in run state; native1440x1760 SHA256c860540d122863589663a2892cde31b59153f0700eafdb4590823fe5e8b73f95.61 outputs plus prior$0.11 give cumulative$0.72 actual/$0.73 conservative. Receipt spendState unknown retained alongside state costState actual; no resubmission. Native output unchanged and full run archived. Blue recessed-band hue95..125/saturation>20 remapped to source-brown hue17 at retained value/saturation in runtime derivative. Generated facet strength, residual blue, exact bands,9cm depth/back and mounted support cropping remain unaccepted. Reused native nine-slice/frame/shaders, separate authentic catalogue panel. Source-relative centre1.48/1.55/18.93m, offsets unaccepted.

Renaissance warm ivory corrected to neutral light grey using existing Muse plaster grain and neutral local fill; source-relative shallow north-door vent added. First darker render retained, then tint lightened after inspection. Main Hall lighting/material/presentation recipe retained. Native detailed/wide/corner and376x252 walking views inspected. Small painted opening is frame-covered; affine source63.75/64.75 doorway-height estimates2.433/2.803m disagree, and5/6inlier wide SIFT matches collapsed to invalid quadrilaterals. Rejected metric fit. Doorway2.0x2.74m and global room extents unchanged, provisional. Clear original Hall177.50s places end door at wall fraction0.477, contradicting an offset-door workaround. RISD current floor-five guide's2020 schematic supports parallel European/Hall topology, not physical dimensions or current object hang.4.60m lateral/17.05m axial Hall closure remains unresolved; no fabricated connector/side door.

Rebuild diagnosis: prior native baked meshes loaded during bake preparation doubled603 surfaces to1205. Stopped owned CPU bake, retained failed-preparation logs, wrapper restored editor config. Bake preparation now tags its scene; shared load_bake returns before cached meshes are loaded, and preparation asserts no native_lightmap_users. Repeat with existing bake returns603 authored surfaces; final603-user bake44.46s CPU Vulkan fallback. Cache duplication fix verified; known engine editor teardown warnings retained. RTX native66/66 p9529.630ms; RTX Chrome66/66 plus keyboard round trip p9528.788ms, errors[]. An initial software-browser pass retained separately; GPU environment explicitly corrected before final RTX run. Owning Shell46/50; 4 frozen checks fail, full output/film archived. Repository/diff checks pass. Original50 pending hashes preserved. Evidence `docs/evidence/collection-reconstruction/main-worker-hall-join-20261001T0620/`; full reconstruction,60fps performance, Hall integration and missing objects remain unfinished; Viewer/frozen seams unchanged.

### Collection v40 — wide-shot correction and connected Hall (2026-10-01)

Collection-only prototype, issues #178/#181/#182/#183; sole main worker, heartbeat disabled. Native6382 85.25/86.25/87.25/89.25s locates two gold panels on the medieval north wall; the projecting display beside the portal is not a room corner. Coupled authored loop retains the original Hall10x26.3x6m, centres both Hall doors and joins Rockefeller/European/Renaissance/medieval/Grand/French rooms through the source-evidenced openings. All metres and offsets remain unaccepted; purple connector2.15m inferred from the authored closure. No new connection is presented as measured fact. Reused all23 existing gallery_walk4 paintings, Muse frames, vault, skylight, cornices, benches and lights.13-line adapter replaces its standalone photo cards/vestibules with shared colliding room walls/floors. Bench proxies and dynamic clipped parquet now cover the translated rooms; original0.03m² coverage tolerance retained.33 circuit segments and32 consecutive transitions without reset, in addition to44 other collision/camera trials.

Material review caught a culled portal front: existing quad winding plus back-face culling hid the carving. Restored the shared two-sided material; closed plain reverse occludes front texture from the Hall side. Source-facing Muse carving visible again; plain reverse/depth/intrados silhouette still unaccepted. Native face/angle/wide and376x252 walking views inspected. Hall palette still too dark/warm and white moulding too golden against native source; mounting heights/offsets remain unaccepted. Reused Main Hall PS1-to-native bake conversion, normal generation,5 diffuse/23 painting lights and skylight handling; final769-user bake200.66s on CPU Vulkan fallback, RTX4070SUPER for render/QA. First failed texture reimport retained; explicit import before baking resolves it. Repeat preparation rejects old baked-user duplication. Browser's extended360s wait exposed the180s CDP protocol timeout; launch protocolTimeout450s now covers the full circuit.

Six further medieval official API/photo/video appearance matches: angel37.114/API1550566; Bartolo Madonna20.207/API1580756; Virgin of Annunciation57.301/API1549126; Mary Magdalene21.250/API1411936; Taking of Saint Peter22.047/API1461611; Saint Anthony Abbot16.243/API1539001. Corrected three mistaken subject descriptions and two wall labels. All six remain unbuilt/unplaced; rejected57.300 against the actual gabled source. Photos, API JSON, compressed HTML and source survey frames retained with hashes. No paid calls this pass;61 existing outputs plus earlier$0.11: cumulative$0.72 actual/$0.73 conservative. River-deities ambiguous$0.01 and failed headv1/v2 unchanged; never resubmit blindly.

RTX native154/154,p9531.481ms; RTX Chrome154/154 plus keyboard round trip,p9530.200ms,errors[]. Owning Shell repeat46/50, 4 frozen failures; first run43/50 with7 failures included3 timing failures that did not recur. Both complete films/logs archived. Repository/diff checks pass. Original50 pending hashes preserved. Evidence `docs/evidence/collection-reconstruction/main-worker-connected-loop-20261001T0735/`; all ten video surveys previously reviewed at2fps, full room/object/metric reconstruction and60fps target unfinished. Viewer/frozen seams unchanged.

### Medieval north-wall frame trial — 2026-10-01

One new Muse edit through OpenRouter `meta/muse-image`, run `run-512ec3442058ba2c246e9eea`, actual cost$0.010000, native SHA256 `bd670d7b3ea010abbd34950260e075dfa29227612004ed5f295000501d550ad6`. Official21.250 photo, native6382 72.75s and previous game-frame references retained with exact hashes, prompt/recipe, pinned-tool identity and sanitized durable Run Record. Exact existing Tool Lock/build1790783219515 used; current default build differs and was not substituted. Paid reservation was not retried.

Visually rejected for installation: source outer gable/crockets and rope columns survived, but Muse inserted a second inner chevron, shortened the actual painted pentagonal opening and invented blue wear. Original output untouched. Subjective provider gate remains unverified; this local verdict does not give owner approval.62 outputs now, plus earlier$0.11: cumulative$0.73 actual/$0.74 conservative (ambiguous river-deities$0.01 still counted conservatively). Failed headv1/v2 remain incomplete. `image-work/collection-room-remodel/magdalene-frame-review.json` records the failure and next geometry-preserving edit.

A separately planned targeted correction used an explicit blank source pentagon and the owner-approved gold style reference (the first pass mistakenly used the earlier blue Perugino trial for style). OpenRouter Muse `run-56e0a4ec22f715cd28886116`, one output,$0.010000, native SHA256 `292f6d3434227b00d7db908fa33105ffac432a811ae23f073855a7fd6b132ebf`. Corrected opening/crocket count/blue wear visually verified, but source proportions, frame relief and in-game result unaccepted; candidate remains outside runtime until fitted. Unpaid v2 draft with wrong source count was preserved and never submitted; exact corrected v2b request/receipts retained. Both durable runs archived.63 outputs plus earlier$0.11: cumulative$0.74 actual/$0.75 conservative. No blind retry of a request or ambiguous run.

Three verified medieval originals20.207/57.301/22.047 installed as thin exposed wood panels with integral gilt borders;57.301 source silhouette62 vertices. Grey supports, thicknesses except catalogue3.2cm and all positions remain provisional. Native6382 66.75/70.25/72.75/75.25/85.75/86.75 retained. Local planar54x38.7cm22.047 ruler places centre1.388/1.509m from west corner; held-out87.25 only relative Magdalene/Peter0.871m. Unknown intrinsics, manual picks and different mounting planes do not establish room metrics. Display projection and upper/lower vents added; 794 surfaces baked. Explicit Mobile scene priming fixes new painting texture3D reimport during bake. Dark initial render rejected; three missing neutral art spots added using existing Hall light recipe. Final bake646.39s CPU Vulkan fallback, RTX native detail/wide renders inspected; usual engine cleanup errors retained. Grey wall/support colour, source offsets and portal reverse still unaccepted.

RTX Chrome154/154 plus keyboard round trip,p9530.000ms,errors[]. No new native performance claim. Owning Shell repeat46/50,4 existing frozen failures; first44/50 had2 additional animation timing failures that did not recur; full film and exact raw logs archived, readable log copies trimmed at line ends. scripts/check.sh and git diff --check passed. All183 runtime source hashes and50 original pending hashes preserved. Evidence `docs/evidence/collection-reconstruction/main-worker-medieval-panels-20261001T0845/`. Corrected frame candidate remains outside runtime. Next: fit gabled frame closed geometry and source-correct painting separately, then refine reciprocal wide placement/architecture. Full reconstruction and60fps target unfinished. Heartbeat remains disabled; Viewer/frozen seams untouched.

### Collection v42 — source-fitted gabled frame (2026-10-01)

No new paid calls: reuse OpenRouter Muse corrected run56e0a4ec22f715cd28886116, native original unchanged. Total63 outputs plus previous$0.11:$0.74 actual/$0.75 conservative; ambiguous river-deities and failed headv1/v2 unchanged. Museum21.250 original crop pixels verified equal; source pentagon and117-vertex silhouette fit the generated gold by row-wise bands. Simplified outline/source mask overlap0.993992964. Initial threshold cut dark wood and nearest sampling exposed magenta: lower external mask threshold, small close and source-constrained nearest valid gold correct both; failed attempts were unpaid. Four native simple bands, closed front/back/outer/inner geometry:244 vertices,488 triangles,732 edges each paired with opposite winding; area0.03760449m²,positive volume0.001316157m³. Original painting separate and1cm inset.3.5cm frame depth, painted-panel interpretation22.5x49.5cm, plain sides/back, carving relief and placementx1.18/y1.55/z28.30 remain provisional/unaccepted. Source-shaped full frame0.2960x0.5848m.

799 native users baked390.81s CPU Vulkan fallback; RTX4070SUPER close/front/oblique/wide views inspected. Original Main Hall23 works, six-room circuit and visitor retained. Chrome154/154 plus real keyboard round trip,p9530.100ms,errors[]. No new native performance claim. Owning Shell repeat46/50,4 failures; first44/50 had2 additional animation timing failures. Both complete films/exact logs archived; readable logs trimmed at line ends. scripts/check.sh and git diff --check pass. All190 prepared source hashes and50 original pending hashes verified. Viewer/frozen seams untouched; no production integration or ticket closure.

Native6382 12.25/13.25/14.25/88.75 confirms tall spiral ironwork on plinth right of portal, adjacent stone fragment and flat off-white ceiling. API searches/candidate photos retained;27.184 square gilt bronze with figure/floral ornament rejected,53.085 small clock grille does not establish the video installation. Grille identity remains unmatched. Root cause of erroneous skylight at eye height: room builder intentionally omits opaque ceilings for the elevated gallery camera; existing camera/ceiling visibility can retain opaque ceilings for source eye-level renders. Not fixed this pass. Next fix those ceilings, validate reciprocal wide/top-down views, then grille/east wall/stair doorway assets. Full rooms/placements/objects/lighting/stairs/auditorium/modern reconstruction and60fps target unfinished. Sole main worker, heartbeat disabled. Evidence `docs/evidence/collection-reconstruction/main-worker-gabled-frame-20261001T0925/`.

### Collection v43 — source-observed flat room ceilings (2026-10-01)

IMG_6382 88.75s and new native CUDA-decoded6383 2.25/38.25/62.25s inspected. Source medieval/Renaissance ceilings are flat pale plaster with track spots. The deliberate omission of opaque ceilings exposed the unrelated Hall skylight at eye height. Two native low polygon slabs now reuse existing Muse neutral-plaster texture and presentation material;3.5/4.25m heights remain provisional. Existing ceiling visibility hides slabs above3.4m and keeps them visible during bake preparation. Native assertion verifies both authored meshes and their baked copies visible at1.65m, hidden at5.3m. Eye-level and actual elevated walking views inspected; track count/positions, room/door/object metrics, case contents and remaining architecture remain incomplete. Main Hall23 paintings retained; Viewer/frozen seams untouched.

Initial ceiling bake too dark compared with source;2.5m room fill emitters overlap the slabs. Final enclosed-room fill uses.12m emitter with positive clearance assertion and neutral energy1.1; exact track/spot positions remain provisional.801 native surfaces baked with the existing CPU Vulkan fallback and renderer configuration restored; RTX4070SUPER native visual review and Chrome154/154 plus real keyboard round trip,33 continuous circuit segments,p9530.303ms,errors[]. Owning Shell final46/50,4 failures; initial lighting trial44/50 included two recurring animation timing failures. Both full films and exact raw logs retained. Repository checks and git diff --check pass. No new native performance claim;60fps target unresolved. All190 prepared source hashes and50 original pending hashes match. One OpenRouter meta/muse-image grille run6d9f3b3e3a4b26e3c758f21c,$0.01,immutable original/hash/receipt/reservation archived. Source7 columns vs generated8: rejected direct installation; row count,handedness,missing curl and spacing unverified. No blind retry. Total64 outputs plus prior$0.11:$0.75 actual/$0.76 conservative. Existing Muse plaster reused. Exact native source frames/hash manifest retained in ingestion;540x960 JPEG review derivatives in evidence.

Full reconstruction remains unfinished. Next fit medieval grille, east-wall stone fragment, stair door and track lighting from reciprocal wide shots, then remaining rooms/objects/case contents. Grille catalogue identity unmatched; do not substitute rejected27.184 or clock53.085. Failed headv1/v2 remain unaccepted. Sole main worker, heartbeat disabled. No production integration or ticket closure. Evidence `docs/evidence/collection-reconstruction/main-worker-ceilings-20261001T0945/`.

### Collection v44 — native open iron grille study (2026-10-01 10:40 UTC)

Reciprocal native6382 12.25/12.375/88.75s inspected: grille beside north-wall portal, low plinth, top rear brace, separate east-wall fragment/stair doorway. Seven columns observed;17 rows,alternating handedness,uniform scrolls,profile,metres,plinth,braces and placement provisional. Original Muse run6d9f3b3e3a4b26e3c758f21c,OpenRouter meta/muse-image,$0.01 recorded in v43:8-column sheet remains rejected as geometry. Only its iron-post pixels are reused,source hash50dfca1c60c1039936fad34f3d3777f8a5b265af2859460255068ed64520981c,patch[413,250,419,1550]. New native7-column geometry uses119 closed low polygon coils; independent native proof10472 vertices,20468triangles,30702paired opposite-winding edges,positive volume. This validates individual coil solids,not a boolean union/historical fidelity. Visitor collision blocks the grille and preserves east aisle.825 native surfaces baked with existing CPU Vulkan fallback; final native front/oblique/wide and walking views inspected,ceilings/Main Hall23 paintings retained. RTX Chrome158/158 plus keyboard round trip,33 continuous circuit segments,p9530.000ms,errors[]. Owning Shell46/50,4 failures archived. scripts/check.sh and git diff --check pass after byte-identical previous evidence source copies were named.gd.txt instead of.gd; no runtime seam changes. All192 prepared source hashes and50 original pending hashes match. Native/source metric and60fps acceptance remain open.

RISD API100-result searches returned invalid empty lists;25-result positive known-ID/Monet controls work. Valid25-result broad searches retained,first pages not exhaustive. Identity remains unmatched; rejected27.184 square grill/53.085 clock are not matches. No paid calls this pass;total$0.75 actual/$0.76 conservative. Failed headv1/v2 remain unaccepted;no blind retry. Full reconstruction unfinished. Next: Compare reciprocal wide shots for all rooms, source-fit medieval east-wall fragment/stair doorway and track lights, then refine remaining door/object positions and room contents. Sole main worker,heartbeat disabled,Viewer/frozen seams untouched,no production integration/ticket closure. Evidence `docs/evidence/collection-reconstruction/main-worker-iron-grille-20261001T1040/`.

### Collection v45 — medieval stair-door group (2026-10-01 11:08 UTC)

Native CUDA6382 15.75..27.25/77.75/78.75/82.75s and6387 reciprocal wides inspected. Official RISD API/front/side photos identify left Apostle41.046(.267x.826m width/height) and right Apostle41.045(.254x.864m); turned head/halo/diagonal arm/lower fracture versus missing face/crossed hands/feet. Both placed on wall brackets/backplates at provisionalx10.38,z28.75/31.50,bottom1.04m; mount dimensions/.12m nominal relief depth(max.138m),metres and offsets unaccepted. Existing faceted volume builder adds wall-backed slab profile; each162 vertices/320triangles/480opposite paired edges,positive volume independently checked from prepared native asset bytes. Front Muse UVs and plain Muse stone side/back swatch fix initial stretched facial bands. Open stair double leaves,push bars,black hinges/closers and green EXIT added; existing Muse ivory panel crops reused. Actual landing beyond remains threshold stub,source track layout/lighting and adjacent sculptures/case contents unfinished. No room extents or frozen seams changed. Main Hall23 works retained.

Two OpenRouter meta/muse-image outputs,$0.01 each: run-d3f8116583dea973b1b4a81b(hash596e35d1f8ae020237f7110fa79c52d865a0b0af289284b77490f9abe3053214) and run-54d9c9f23373622b070af56e. Immutable native/prompt/reference/receipt/reservation evidence archived. Generated face/robe repairs differ from damaged originals; both are provisional style/geometry studies,not accepted source-preserving sculptures and not finished. No blind retry.66 outputs plus prior$0.11:$0.77 actual/$0.78 conservative. Failed heads and ambiguous river-deities unchanged.900 native surfaces baked152.62s CPU Vulkan fallback; renderer restored. Final RTX native close/wide/walking renders inspected. Chrome158/158 plus keyboard round trip/33 circuit segments,p9531.250ms,errors[]. Owning Shell46/50,4 failures archived. scripts/check.sh/git diff --check pass. All194 prepared source hashes and50 original pending hashes match;21 original PROVENANCE lines remain unstaged. No new native performance claim;60fps unresolved.

6387 modern wides separately confirm straight boards,central bench,three windows,window-wall deeper doorway; landing has three distinct doors. Villon Head of a Woman70.058 visually matched to6387:113 and official zoom photograph;54.8x46cm,vertical oval inside white square frame. Other artist candidates remain unmatched. Next: Build the source-constrained lion landing/modern-gallery connection from6387 reciprocal wides, retain three distinct doorways and correct floor/window/bench positions; continue missing room objects, tracks, sculptures/cases and auditorium. Full reconstruction unfinished;sole main worker,heartbeat disabled,Viewer untouched,no production integration/ticket closure. Evidence `docs/evidence/collection-reconstruction/main-worker-stair-wall-20261001T1100/`.

### Collection v46 — connected lion landing and modern gallery (2026-10-01 11:48 UTC)

32 CUDA-native6387 wides and full far-wall sequence inspected; three distinct doors retained. Capped medieval stair threshold replaced by provisional landing, alternating square parquet, physical floor void, initial ascending/descending ramp/tread studies and iron/wood balustrades. Modern doorway opposite medieval, white ancient sculpture room on adjacent wall remains a threshold; deeper modern opening likewise threshold only. Room handedness corrected after reciprocal review: entry/large painting west, three blinded windows east; Braque/Villon south beside entry; pumpkin/Cézanne north far wall. Native window/radiator bases,bench,track fixtures,cornice and door leaves reuse saved Muse architectural textures. Flight curve/rails/destinations, all metres/offsets and unseen interiors unaccepted. Lion34.652,large figurative painting,seated gold sculpture and chair rack still missing; full object coverage false. Main Hall23 preserved; no point cloud/Viewer/frozen seam changes.

Catalogue correction: prior41.012 six-apple source match was wrong.6387:148-151 instead matches Henri Matisse The Green Pumpkin57.037(id1539041,.645x.800m); red table,one ribbed green pumpkin,white dish/window mullion/village. Landscape matches Paul Cézanne On the Banks of a River43.255(id1538666,.737x.610m),blue river,red left roof,yellow/white village/right foreground rail. Seated gold sculpture identity independently matched to Raymond Duchamp-Villon Seated Woman67.089(id1552686,bronze/gold wash,71.1x20.3x24.1cm) using native64.25/66.25s and inspected official photos0/1; asset/case still absent. Four modern originals installed,including Braque48.248(.721x.464m) and Villon70.058(.460x.548m,48-sided oval crop). Three rectangular museum JPEGs copied byte-identically; Villon review crop from preserved official photo. White frame and Matisse frame reuse unaccepted; painted images never generated.

Two OpenRouter meta/muse-image outputs,$0.01 each: Braque frame run-9aee0790a3bad9ca3dc7bb83(hash3b1f9bcf18c98976d2c0ab2e4aa502cc2afc634f255c2a175818fe682a135753),Cézanne frame run-65e26c80ff7874d3634914a4(hashf9efa0ebd05a5f348c014ad3d3b7540ec57231a0025032c40bf6a5d847b6fd0f). Broad cream/gold bands and grey-bronze nested rails visually inspected; fine ornament/profile and frame band metres unaccepted. Cézanne reference right edge cropped,symmetric restoration inferred; square generated aperture corrected by existing nine-slice. No blind retry.68 outputs plus prior$0.11:$0.79 actual/$0.80 conservative; ambiguous river-deities/failed heads/Apostle damage remain unchanged/unaccepted.1472 native surfaces baked CPU Vulkan fallback in6m09.94s; renderer restored. Final RTX native wide/close/walking images inspected. Chrome174/174 including8 new door/bench/guard trials,keyboard round trip/33 loop segments,p9534.722ms,errors[]. Three authored/baked ceilings follow cutaway. Owning Shell46/50,4 failures archived. First Shell42/50 had four additional animation-timing failures; repeated with browser closed and both films/logs retained. scripts/check.sh/git diff --check pass;201 prepared/50 original pending hashes verified,21 prior PROVENANCE lines remain unstaged.60fps/full native performance acceptance unresolved.

Next: Generate/install source-preserving lion34.652; identify/capture large figurative painting; generate Duchamp-Villon Seated Woman67.089 from inspected official front/oblique photos and video, rear shape unverified, dedicated Matisse/Villon frames; refine source stair curve/rails/flight destinations, overly bright modern spotlight pools and held-out room/object offsets, then remaining rooms and auditorium. Goal active/unfinished;sole worker,heartbeat disabled,no production integration/ticket closure. Evidence `docs/evidence/collection-reconstruction/main-worker-connected-modern-20261001T1135/`.

### Collection v47 — source-protected lion and Muse plaster (2026-10-01 12:20 UTC)

Collection-only prototype, issues178/181/182/183; sole main worker,heartbeat disabled. Reviewed native6387 reciprocal wides: lion between modern door and adjacent corner. Installed original RISD34.652 front at catalogue2.286x1.041m with inferred.08m closed slab,8vertices/12triangles/18pairededges. Original JPEG byte-identical; atlas front exactly equals deterministic resized source,zerochangedpixels. First native trial caught existing catalogue group's-1.95m shift leaving lion floating; authorx18.02 compensates,actualdrawn world(16.07,1.18,33.15),yaw-PI/2 independently asserted. Bracket/lips/vent inferred. Exact metres/offsets,individualbrickrelief and slabdepth remain unaccepted.

Two OpenRouter meta/muse-image outputs,$0.01 each. Lion run-49b57942e799e34216bc2687,nativeSHA2564db83425d72b5a349276c11644efb5720f111740b7ba408af2f7e8584257a3c8; generatedaspect1.4596versuscatalogue2.196,cracks/erodeddamagealtered,frontREJECTED,no blindretry. Official front protected; Museochreswatch only supplies inferred sides/back. Plaster run-20fa6fddf9fc645f616f8335,nativeSHA256c58b89f37f64f619bb4e97975f97241a32c360e7a120c72b0040958bfa059bad; quiet warmgrey wallstudy with existing.15contrast/mirrorededges,only landing/modern walls. Full sourcecolour/facetfidelity unaccepted. MainHall23artworks/lighting retained. Modern fourpainting spotenergy5to1.2/angle28to40; baked native pools visibly reduced.70outputs plus prior$0.11:$0.81actual/$0.82conservative. Nativeoriginals,prompts,refs,receipts/fullrunarchives retained; failedheads/Apostlesdamage/ambiguousriverdeities unchanged.

1486native surfaces baked CPUVulkanfallback in5m53.93s,rendererrestored; finalRTXfront/oblique/wide/walking inspected. Chrome174/174,keyboardroundtrip/33loopsegments,p9534.367ms,errors[]. Three existing opaqueceilings followcutaway; landingroofaroundstairvoid remains missing. OwningShell46/50,4priorfailures/fullfilm archived. First45/50 had one additional pressed-animationtimingfailure; repeated afterbrowserclosed,bothfilms/logs retained. scripts/check.sh/gitdiffcheck pass;205preparedsourcehashes and50originalpendinghashes verified,21originalPROVENANCElines remain unstaged. Fullnative60fps/metricgeometry unverified.

Next: Generate/capture Duchamp-Villon Seated Woman67.089 and its case from inspected catalogue/video; install verified Le Fauconnier Mountaineers1995.043 with source frame and dedicate Matisse/Villon frame passes; verify landing roof/stair void, source stair curve/rails/destinations and held-out room/object offsets; continue remaining rooms, case contents and auditorium. Large painting independently matched to Le Fauconnier Mountaineers Attacked by Bears1995.043,RISD API1557106,dimensions239.6x305.4x4.4cm using official photograph and native80.25s; original/API archived, installation next. Other research first-page queries do not prove absence. No externalblocker; allobjects/fullmap unfinished. Viewer/frozenseams untouched,no productionintegration/ticketclosure. Evidence `docs/evidence/collection-reconstruction/main-worker-lion-plaster-20261001T1220/`.

### Collection v48 — modern frame trials, validation pending (2026-10-01 12:38 UTC)

Three single-output OpenRouter meta/muse-image passes from inspected native6387 references; no paid retries. fauconnier: run-8064d5d53520fe1718913a50, native SHA256 16ec2f626c9883dbe23167d3d6a8ac1810e9f9421c511a84660baa37a434ee22, $0.010000; matisse: run-deb3fa4494d2aa2914b50c96, native SHA256 f49b40e2f1b3849366617c04d652b20c18121c57cb34671a586c37d21be1aab0, $0.010000; villon: run-ba6714836ba8a52640c99be9, native SHA256 bf97aec0c0ab01c74a307966c69fbef7b450bbd694ad862f266ddeb99dece9ae, $0.010000.73 outputs plus prior$0.11 give cumulative$0.84 actual/$0.85 conservative. Prompt/reference hashes, reservations, receipts and immutable native images retained in image-work/collection-room-remodel.

Native v48b installs original Le Fauconnier1995.043 and dedicated Matisse57.037/Villon70.058 frames using existing nine-slice geometry;209 prepared sources. Original rectangular artwork JPEGs copied byte-identically; Villon ellipse pixels retained in lossless crop/white-backing assembly. Frame widths/profile/ornament and room offsets unaccepted. First preparation failed the rectangular aperture width gate for Villon; unpaid preparation adjusted for narrow oval332px and succeeded. Erroneous import on that partial project was cancelled; failed output/log retained. No provider retry.

Import/native render/scripts/check passed. Native images inspected: Villon has an incorrect rectangular border from assembly; correct before baking/publication. Bake and browser checks remain pending; published walkable build stays tested v47. Dated report with working build link, local drafts and remaining scope: docs/evidence/collection-reconstruction/main-worker-progress-report-20261001T1238/. Next: correct border, bake/inspect/playtest five-painting modern room; then gold figure/case and source stair/doorway/layout refinement. Full ten-video goal unfinished;sole main worker,heartbeat disabled,Viewer/frozen seams untouched.

### Collection v49/v50 trial — actual Main Hall, modern interior and sculpture (2026-10-01 13:53 UTC)

Collection-only prototype for issues178/181/182/183; heartbeat disabled, main session owns implementation. Corrected earlier Main Hall preservation claim: v47/v48 reused a stale stripped Hall. Actual build/v0.1.0 at317b8f3b8dac0f9811d396bcb0260c7187f93f11 is now the reference;362 original Hall files checked byte-identical,139 native baked meshes retained by full-app adapter,23 artworks. Real demo.tscn Collection factory rendered Hall/medieval/grey/pre-correction-modern with original controls, frame, clock, tabs, character and shaders. Software native capture exits0 with no runtime errors. Production checkout remains tracked-clean and untouched.

Actual Claude Opus5.5 workers reviewed Main Hall, delivered one adapter, corrected Villon oval backing, built a SeatedWoman/case trial, reviewed the6387 interior pan and delivered its four-file layout patch. Exact BASE/result hashes and delivery evidence verified before applying. Headless adapter retains Hall geometry/material/layers/lightmap/camera/control behavior and walks19legs;78/87 prior trials agree,9 discrepancies retained (native portal posts and far vestibule transition),no claim of continuous metric connectivity. Headless harness reports teardown resource leaks; ordinary full-app native capture is clean. Root modern interior check passes; unchanged BASE fails34 checks. Root inspected new native two-window wall/case/second-doorway views. Landing anchor remains wrong: independent9.5/43.5s wides show perpendicular doorway planes; source identity/order review active, refit next. Exact metres, rear sculpture coverage, frame fidelity and all-objects flags remain false. No point clouds used.

New single-output OpenRouter meta/muse-image bronze surface for catalogue67.089, run-aa2645a69d7e5d2d83b1f306, objective muse-eee9d65045609a306d10, native SHA2561de65113068b8523bf9f5b5ccdf231f47c93eaf481b9b0938d8bc14523983c9d, actual$0.010000. Official front photographs0/1 supplied; bronze/gold-wash medium and71.1x20.3x24.1cm checked. Quiet ochre patina visually inspected and installed on closed14-shell/344-triangle catalogue-bounded blockout; rear/pose depth unaccepted. Provider returned1600square despite1024 request; no exact-size claim, no retry. Run state confirms actual cost; compact receipt spendState unknown retained verbatim.74 new outputs plus prior$0.11:$0.85 actual/$0.86 conservative. Three v48 frame receipts/native outputs/full archives also checkpointed; Villon official oval pixels protected, obsolete rectangular reveal removed, rim/profile fidelity provisional.

Repository scripts/check.sh and diff checks pass. Owning Shell46/50 with four recorded prior failures; full film/log saved. RTX D3D12 device removal also occurred with MSAA off; unresolved, software fallback verified. Added-room bake and new browser export not yet verified. Addition-only bake paths exclude native Hall; full-app copy recipe now relocates text-serialized lightmap paths and preserves EXR array importer, conversion checked against1486-user existing data. No production integration, ticket closure or full map completion. All50 original pending paths rechecked unchanged; original21 PROVENANCE lines remain unstaged. Next: correct landing wall order from wide-video evidence, bake additions separately, inspect full-app native/browser traversal, then remaining room/object/video coverage. Evidence docs/evidence/collection-reconstruction/main-build-attachment-review-20261001/ and Opus review folders.

## 2026-10-01 — medieval case Virgin15.108 reference sheet

OpenRouter `meta/muse-image`, one output, actual $0.01; run `run-45b7430ae44f28051bb2b9a2`, objective `muse-f06f51d1eeeb2f58f287`. Source RISD API id1388871 and three official photos plus IMG_6382 105.70s rear crop; exact source/input hashes in `image-work/collection-room-remodel/virgin-child-15108-sources.json`. Native WEBP SHA256 `a14ab275b107b2b8a2e97455ef9b150b68fc347eba4b06df6b694ea6b57c96fd`. Prompt, plan, recipe, receipt, durable state and reservation retained. Credential503 stopped before provider submission; recovered execution made one request. Front/side sheet inspected; rear hair/paint partly inferred, fidelity and placement unaccepted. Reference evidence only, no accepted runtime asset. Cumulative $0.86 actual / $0.87 conservative.


### 2026-10-01 — God Save the Queens preliminary Muse modelling sheet

Source: official RISD 2020.55 photos0/1/2; sources, PNG conversions and hashes in image-work/collection-room-remodel/queens-202055-sources.json. OpenRouter meta/muse-image,1output,actual $0.010000,run run-2ee4b0d0613d42f31ef80703. Native SHA256 1e3cd72922649181dc3620f6f0160182cc0c04f01628ba97e056e132958ec8ab. Prompt/plan/receipt/review saved with sources. Root inspected: front and boat guidance usable; invented floral rear rejected, fine shapes and western surface unverified. No installed/runtime asset acceptance. Cumulative $0.87actual / $0.88conservative; ambiguous prior spend stays counted.

## 2026-10-01 — case installation and primary-source architecture corrections

Collection-only prototype for178/181/182/183. Seven existing closed tall-case helpers and two original-video paper proxies installed under their case owners; geometry bounds checks pass, all identity/placement/fine-fidelity completion flags remain false. Existing Muse native files and paid receipts retained; no new generation or paid scraping in this pass (cumulative actual$0.87/conservative$0.88).

Original owner6380video and primary museum/Nintendo sources inspected; source/hashes/date/access limits in docs/evidence/collection-reconstruction/public-source-snapshots-20261001/SOURCES.md and Opus source research folders. Architecture23delivery hashes, paper79delivery hashes verified. Emblem book2023.17 identity/opening matched, two paper candidates remain probable. Historical2020map/list and2017photos do not establish current hang/metres.

Existing Muse door/architrave/baseboard rasters remain archived unchanged; derivatives use neutral RGB230/228/222 and0.16 luminance contrast. Prototype adds continuous black connector face, plain cream column beam/end pilasters,0.10m casings and white label proxies; removes only piano west leaf, preserving both Hall leaves. Exact profiles, dentils and all metres unaccepted. Actual MainHall362files/139saved meshes/23artworks retained; frozen support harness copied byte-exact from main commit317b8f3 into isolated authoring copy for editor review-script imports. No production Collection or3DViewer edits.

Proof: docs/evidence/collection-reconstruction/medieval-case-install-20261001/ and source-architecture-fixes-20261001/. Case bounds7+2, floor1617/0wrong normals, trim5derivatives and source-style checks pass; older negative control fails as expected. Parse/check timeout and initial missing-harness bake failure preserved. Addition-only bake and fresh actualCollection visual review pending at15:55UTC; complete-map/fine-fidelity flags stay false.

## 2026-10-01 — independent source review and corrected doorway prototypes

No new paid calls. Existing Muse assets retained; research and native/software checks cost$0. Opus closer footage6380 14-15/100-107s shows leaves folded into reveals. Root moves only piano east leaf into its north threshold; protruding generated Hall-side copies omitted. Actual MainHall remains unchanged; its source-correct reveal leaves are still unbuilt. Connector south baseboard now black, north uses existing Muse purple-plaster raster.

Frozen prototype sources and fresh v49h/v50h proof: docs/evidence/collection-reconstruction/source-architecture-fixes-20261001/. Addition bake1274users==surfaces,3m32s; two editor cleanup errors retained. Native capture and style checkexit0; older v49g negativeexit1. Initial import-order and baked ArrayMesh checker failures retained with corrected checks. Corrected grey doorway camera inspected; incorrectly labelled Rockefeller angle excluded. Keyboard8/10 strict endpoints pass, including both piano directions; Hall endpoint0.10/0.40m failures retained despite correct space transitions. Shell43/50 frozen baseline failures documented; scripts/check.sh passes. Webdiagnostics fail during boot warm-up on gl-egl/SwiftShader; no workingWeb/fullmap/lighting/finefidelity acceptance.

First-party museum API confirms emblem book2023.17 without an image; two medieval paper identities remain probable. SaintRoch catalogue supplies four views including rear and height105.4cm for the next Muse asset; width/depth unlisted. Unbuilt Renaissance objects, Hall connected-view visibility/entry behaviour, connector details and room metrics remain next work. Independent final scoped report pending at16:26UTC.

## 2026-10-01 — source research checkpoint verified

Final independent Opus report accepts seven source corrections in kind, with five Hall/view/lighting/lift-ownership/casing-scope findings open. All82 current evidence/source/app/original-frame hashes verified; exact report copied to docs/evidence/collection-reconstruction/opus-grey-integration-review-20261001/. Sources in public-source-snapshots-20261001/SOURCES.md; fresh native views and dated next actions in source-architecture-fixes-20261001/CHECKPOINT.md. Final scripts/check.sh and both whitespace checks pass; Shell43/50 and native keyboard8/10 remain partial, Web boot unaccepted. All50 original pending files and owner provenance additions preserved. No new paid generation; full reconstruction and178/181/182/183 remain open.

## 2026-10-01 — reciprocal Hall views, probe-preserving copy and Saint Roch study

Collection prototype only,178/181/182/183. Native v49j addition bake1217users/352probes/1661tetrahedra; actual fullapp v50l preserves362Main Hall source files at317b8f3. Real Compatibility renderer replaces dummy-headless lightmap conversion, verifies exact saved probe arrays. Visitor uses only its room's probe field. Render-only adapter clips1298obsolete closed-demo tunnel triangles, skips native shader-clipped planks, preserves threshold and reassigns saved lightmap users after changed mesh resources. Camera draws the reciprocal Hall/grey doorway; crossing preserves held input, heading and position. One inward casingface per room, lift panels/number5 follow northwall cutaway, piano panel faces belong to their remaining leaf. Opus5.5 independently accepted this frozen rendering/lighting scope; two further camera defects, source-fit reveal/leaves, complete map and browser remain open. Frozen10sources in contiguous-hall-fixes-20261001/frozen-source-v50l.tar.gz. All ten verified video masters rehashed against intake. CPU captures; no real GPU performance acceptance. Native checks exit0,10keyboard crossings within unchanged0.08m. Shell owning playtest42/50 with existing UI failures retained; scripts/check.sh passes. Failed empty-probe and black/sawtooth-floor trials preserved, not approved.

One paid Muse sheet for Saint Roch21.398: OpenRouter,meta/muse-image,1output,run-b13a93b2b883bac8562b552d,actual$0.010000/costStateactual/spendStateunknown; never resubmit. OutputSHA256179cb21bc084a90ff6eb46c27599cbe7c5f9aa25d70f413b4a9e364f531c2273. Saved pipelinev0.3.0/8683520 release1790783219515. Four official photographs retained with source hashes, photograph2is actualrear. Muse LEFT SIDE duplicates RIGHT SIDE and is rejected. Front/rear form usable for modelling; paint/damage/dog/back fidelity, width/depth and placement unaccepted. Opus builder delivered40closedsolids/1446triangles/1.054m official height, reusing existing seated-woman shell helpers; missing side inferred conservatively, no blind paid retry. Root verified49delivered evidence hashes and reran closed-mesh check. Standalone report/negativecontrols in opus-saint-roch-asset-20261001. Cumulative actual$0.88/conservative$0.89 under$5map ceiling. No productionCollection or3DViewer changes; no ticket closure or full-map completion claim.

Further follow-up v49k/v50m: flat Saint Roch installed with colliding white floorplinth and five transparenthoodfaces before existing shuttered westwindow (original6383 18.3/62.0s). The Muse texture is not used because independent reviewer rejected its offaxis black wedges/streaks; padded source and failed texture trials remain in builder evidence. Addition-only bake1229users/352probes succeeded with two known editorcleanup errors retained; no script errors. New checks cover installation/falseflags and reproduce seven camera/group-crossing failures on oldv50l. Native finalreview pending; Hallreveal/leaves, other16Renaissance artworks/fourcases, source-relative roommetres and browser remain open.

v50m independent Opus follow-up confirmed four movement/camera/flat-model improvements but found a render-layer doorway pop-in. Finalv49l/v50n adds both roomgroups to the camera and ray cutaways, restores unbaked near-room ambient0.6, and gives Renaissance northgrille/slats their northheader owner. v50m ray proof identifies the orphan grille at(-8.05,3.2,.09); corrected v49l owner check passes with identical sourcepose after9.25shift. Geometry rebaked1229users; fine/statue/hood/roommetres stillfalse. v50m12keyboardchecks pass; teardown12resources warning retained. Source/runtime12files frozen for independent finalreview; final captures pending.

Final rootv50n evidence:18 native views, seven follow views, three offset views and12 strictkeyboard crossings all exit0; unchanged0.08m tolerance and input release. Both Rockefeller directions show adjoining interior; historical-heading/fresh grey views equal. Grille removed from visitor sightline; nearest rayhit is actor, then floor. Main-build regression and scripts/check.sh pass. Keyboard teardown24ObjectDB/12resources error retained; map/source-fit/modelcompletion stillunaccepted. Final Opusreview pending.

Independent final Opus5.5 review task3bb46fa61d0e/ctx75f29b8e4d02:60 output hashes and12 frozen source files verified by root plus all read build/source/proof hashes; report opus-follow-view-review-20261001/REPORT.md. Scoped acceptance v49l/v50n camera/movement and provisional flat Saint install only. 362 Hall files and352 probes verified; independent four held-key traces maxstep0.04m/no flash, plinth blocks0.30–0.33m. Reviewer released after validation, transcript archived. Hood likely too short, stepped foot/front label missing; Hall reveal/leaves, map metres/likeness/browser and all completion flags remain false.

## 2026-10-01T18:44Z — Hall reveal refinement and Pietà source-guided study

One paid Muse modelling sheet for Pietà59.128: OpenRouter/meta/muse-image,1output, actual$0.010000/costStateactual/spendStateunknown, run-0b38abf3159fe7bf6b3761b5, never-resubmit. NativeSHA256378a734d84325fe2189675539814a9c6b8641b9973fa15e27b4f1b3c82a824b2. Pinned toolv0.3.0/8683520/e6d0a4 release1790783219515;11exact runfiles archived pieta-59128-run.tar.gz with file/archive hashes. Two ordered PNGrefs: official colourfront and original verified6383 at24.6s. All source/prompt/plan/recipe/objective/run receipts retained inside application. Root inspected4panels: FRONT and ABOVE FRONT useful modelling studies; LEFT THREE-QUARTER duplicates front, rejected as observed side; RIGHT is near fullprofile, inferred only. Rear unobserved. API cached record1312736 plus official page/photo/video establish Linden wood andH/W/D.457/.381/.132m; new API query403 retained as unsuccessful, datefields1480-1510 conflict source/page1515-1525, no invented label. Cumulative map actual$0.89/conservative$0.90 under$5 ceiling. Actual Opus5.5 builder taskb5edadc1a393/ctx6ade578ccd80 delivered66hash-verified asset/helper/source/output entries; root reran CPU native closure/normals/bounds check,39solids1622triangles2433edgepairs,0failures; open-base negativecontrol exits1. Flat official-photo palette kept; Muse projected/face-sampled textures rejected offaxis. Original outline ratio conflicts width:9.4% modelx widening to catalogue38.1cm, not resolved. Sides/back inferred, likeness unaccepted. Root installs prototype wall-hung case west/north of shuttered window, owns cutawaywestwall; v49o fresh architecturecheck passes1case. Worker transcript archived/released; no extra spend.

Saint Roch hood/plinth revision from6383 18.3/62.0s: hood now1.45m tall/top2.09m and three stepped white plinth pieces/front blank label shape; figure base remains.68/catalogue height1.054. Case dimensions stillbyeye/unaccepted. v49m fresh geometry check passes casings19/grille1/leaf1/liftfeatures3/Saint1; final native render and independent review pending. Hall reveal builder task49a9e91833a3/ctx46f8124de215 reads original6343/6344/6380, reuses saved106.25Muse three-panel asset. No room-group shift authorised as measured, source Hall immutable. Every map/metre/fidelity/completion flag false.

Triptych2021.131 uses authentic official front AND actual rear photograph crops,3closed gabled panels via existing Painting helper plus explicit observed rear; depth.018m/wingangle.20rad and shelf/hood offsets provisional. No Muse call required for flat catalogue art. Six RGBcrops and manualsource contours,photo/video/crop hashes retained triptych-2021131-geometry.json; repro collection-prepare-triptych.py. Root v49n geometrypass3panels and open-rearnegativecontrol exits1 with3expectedfailures;3unbakedauthoringnativeviews inspected. v49o checks includeall3panels,1Pietàcase,1Saint,1grille,19casings,1pianoleaf,3liftfeatures. Final connected bakedfullapp stillpendingHallproposal; no metre/placement/fidelity/completion acceptance.

Hall proposal integrated from actual Opus5.5 task49a9e91833a3/ctx46f8124de215:29output hashes,6base/proposal hashes and4mastervideo hashes checked; root independently redecodedall8sourceJPEGs byteexact. Leaves.95m, room shift.76m (existing frame stands.19m proud); 5farrooms move together,2thresholdrooms bridgegap, Main362sourcefiles immutable. Reused existing Muse three-panel textures; moulding stretch/headheight/panelledsoffit and Rockefellerleaf remain open. Root preserved new triptych/Pietà/hood hunks in three-way merge. Incomplete v49p trial preparation failed retainedHall naming assertion; retained, correctedfreshv49q preparation succeeds. Rootv49q architecturecheck0failures:19casings,2Hallleaves,2Rockefellerlinings,1pianoleaf,3liftfeatures,1Saint,1grille,3triptychpanels,1Pietàcase,8narrowdarkcase-toprails. Rootplanreplay4crossings plus blindshiftnegativecontrol pass. Addition rebake/fullapp/nativekeys/followviews/review pending. Root owningShellplaytest43/50,7existingUI/timingchecks fail; inspected exportedCollection screenshot; noUI/Viewer changes.

## 2026-10-01T20:08Z — Native review and eleven Renaissance case objects

Fresh v49q bake1282users/350probes and fullappv50o: complete probe dictionary preserved in GL conversion. Root inspected20native+7followviews,12actual-keycrossings pass unchanged.08m limit; grey-historyframes byte-identical;362/362Mainfiles unchanged. Actual Opus5.5 independent task5df5a91ccc6b/ctx0050727add1c delivered38hash-verified proof files: F1 missing Hall leaves from cutaway confirmed and fixed by exact Grand Gallery:prefix in separatelyfrozenv50p. Reviewer accepts scoped provisional source-order sculpture installs and straight dollhouse passages only; fullmap/metres/placement/likeness/browser/GPU stillfalse. F2triptychcase .123m wallgap, F3jambcutaway, F4follow grey->Hall stall, F5diagonal .53m jump found; knownHall-linehairbrightnessstep and followcameraHallobstruction retained. Root v50q fixes8followfixtures,8diagonal stillfail: Vector3 .4roundsabove parent exact.4doorway predicate. Correctedv50r cap.399 passesall16actual root-keyfixtures (8followforward/backward,8diagonalbothways/modes), maximumstep.040001m; oldv50p negativefails10fixtures, same.08m limit. Original12actualkeycrossings stillPASS. New19filefreeze/archive and pending independent sameOpus reviewer89fd685e55b6/d4dd2732818a retained. Nothing beyond scoped fixes accepted.

One new Muse external cleric45.042 frame: OpenRouter/meta/muse-image,1output,$0.010000actual,run-e9a0d2ad84fd2506632eb4b4,11byte-exact runfiles archived; nativeSHA06fd8563acabbecaf05704c5c1348d1ff05db36410f9faeeadc251b133efde2c. Official painting nevergenerated. Sourceoriginal6383 49.80s crop+provisional planarfit. Root inspectednative frontal grey-brown moulding/whiteopening; output useful provisional, broad facets/shape unaccepted. Worker later corrected bands from twoframes: sides.044m, top/bottom.050m, outer.234x.322m. Savedoutput deterministically fitted via fit-cleric-45042-frame.py; replay byteexact SHA03dadd3e6395644af35daa03ace7c04798f3acec85c39ef056369d71ca595386. No second call; cumulative map actual$0.90/conservative$0.91. Woman34.861 engaged frame retains authentic photo; catalogue-relative portrait size conflict explicitly unresolved.

Actual Opus5.5 Case A task31175d5e5202/bc370ebdd3d1:92outputhashes andoriginal6383master/reusedhelper hashesverified,6objects93closedparts. Case B task10b78168da26/6f40adab9065:31output/18sourcehashesverified,5objects12closedparts. Bothworkersarchived/released. RootindependentlyreranCPUchecks:both0failures; Aopennegativeexit1. RootB firstrecheck failedmissingoutputdirectory (143ownedprocessstopped), correctedfreshrecheckexit0, failurelogretained. Sources/API/photo/video and honestunobservedback/size/profileflags retained. CaseAemblem2023.17usesactual filmed emblem15 pages; comparativecopy notsubstituted. CaseBenamel34.024remainsprobable. Authenticart/photoscopiedunchanged to owningapplication inputs; no extra paid calls.

Separate provisional east-case proposal follows6383 41.2/49.8 and55.6/56.0s; sixobjects north of tracery door, five south, catalogue-sized. Wallcase/metres/offsets/tilts/smallmounts/labelsblankunaccepted. v49r trial architecturecounts passbutvisualinspection catchesempty Case B textures (wrongrootdirectory); rejected, correctedproposal to textures/subdirectory. CaseAloader nowreusesimported ResourceLoader path withrawscratchfallback, geometryunchanged, avoidsrawImage exportwarning. Freshv49s geometrycheck0failures (2cases11uniqueobjects, allpreviousarchitectureretained), no imageerrors; unbakedauthoringfront/quartercaptures inprogress, nofinalbake/independentcaseacceptance. Proposalflushes triptychback .007mfromnorthface; currentfrozenmovementbuildgeometry unchanged. Remainingthree south/westwallassets actualOpus71cacd9c4673/6a8d5527ca19 workingfrom originalvideo+RISDrecords,0spend. Everyfullmap/metre/placement/fidelityflagfalse; no3DViewer/interface/error/frozenmoduleacceptancetest changes, no ticketclosed. Owneroriginal50pendingpaths preserved. Heartbeat remainsdisabled; main-sessionworkcontinues.

### 2026-10-01 20:26 UTC — cases, crossing targets and Madonna frame

- Root installed two source-guided east cases with eleven closed studies and fitted Cleric Muse frame; v49s six unbaked native exports inspected. v49t/v50s authoring/full-app copies retained. Triptych back-pane gap reduced from0.123m to0.007m. Header cutaway now tests child mesh boxes separately; six cameras pass. Old v50r negative detects two drawn occluding jambs: first assert suspended script/timeout124 retained, corrected verifier exits1. Main Hall source unchanged; its own wall still limits side-on views.
- Actual Claude Opus5.5 v50r movement review delivered18 verified output hashes:34 held-key walks pass at0.040m, Hall-leaf cutaway retained, bake350probes/1282users and362Main files unchanged. Found short-tap and floor-target stalls. Root v50t first target guard regressed Hall-to-grey by1.13m (2/16held and2/12target failures retained). Root v50u shares doorway-strip walkability across gallery/far:16held+12target tests pass at0.0400009155m and same0.08m limit. Six taps use real delivered/released root keys; six floor targets exercise native planner, no mouse ray-picking. Same Opus independent follow-up active; cases still unbaked.
- One saved Muse/OpenRouter meta/muse-image58.196 frame-only pass: run-e9664c5bbab320779c1133e6, reported$0.010000, native1600x1600WEBP sha256 ace672e922caa71f86c4c9b2b3429b3c0ffa6a2f67128a10c2bcaf68db7e541d, exact11-file run archive retained. Tool summary spendState unknown/retryState never-resubmit; no retry. Generated bands too wide and bevels lighter/gold-coloured versus source's thin light bead. Four880x64strips fit existing provisional .018/.029/.030m bands through saved fit-madonna-58196-frame.py; byte-equal replay proved. Native and fitted frame remain trial for source/native comparison, no acceptance. Official artwork pixels untouched. Source/ref/prompt/recipe/review/hash records kept in owning image-work app. Cumulative reported actual$0.91/conservative$0.92.
- Three Renaissance wall assets/research still being delivered by actual Opus in its separate folder, no paid calls/shared edits. Original50pending paths preserved; no3D Viewer/public frozen contract change; heartbeat disabled; no ticket closed. Next: validate wall delivery and generated/source frame comparison, fresh integrated bake, independent native review/fix loop. Follow camera blocking, visitor brightness step and all museum metres/placements/likeness remain open.

### 2026-10-01 20:48 UTC — Renaissance wall works and new baked full app

- Actual Opus5.5 wall builder task71cacd9c4673/ctx6a8d5527ca19 delivered43 hash-verified outputs, zero paid calls/generated pixels. Root inspected all3 source/model/video sheets, copied byte-exact closed-helper and10textures/geometry into owning module/application. Catalogue/API1202276/1201986/1591076 rechecked live against cache without differences. Official Velvet23.307X rear newly fetched (third public official catalogue photograph, sha256eac340d0…), root visually inspected salmon lining/tag/fringes and accepted source for prototype in separate owning source record; frozen inventory ledger unchanged. Every object acceptance flagfalse; photograph/catalogue/video proportion conflicts retained. Native helper asset sizes/closure positive and negative proof preserved; no metric/likeness completion.
- Added3 wall works, clear velvet hood5panes and2blank source-observed label stands to actual Renaissance south/west wall cutaway owners. Corrected platform.54m to provisional.16m, source-wide south gap~.4945m. Rootv49u firstpreparedhelper failed siblingPaintingpreload resolution; failure retained, owningprepare now flattens bothB/wall relativePaintingpreloads. Freshv49v architectureexit0:3wallworks/11caseobjects/5hoodpanes/2stands/1lowcollidingplatform. Six unbakednative andsixbakednative exports all inspected. Textiles stilltoo highaboveplatform againstsource: independentoriginal-video fit pending, placementfalse. All18lower-bound Renaissanceinventoryslots nowrepresentedby prototypes (one probableidentity34.024), not allmuseumobjects/fidelitycomplete. Runtime Madonnaframe uses originalvideostrips: $.01 Museframe rejected for broadgoldband, no retry. Cumulative actualreported$.91/conservative$.92.
- Freshv49v bake1358users/350probes, configrestored/Mainbakepreserved; fullappv50w conversion Main362sourcefilesunchanged andfullprobe dictionarypreserved. Native20actual Collectionfactory views exported, rootinspectedall20contact+Renaissancefullnative. Mainintegrationcheckexit0;16realheld-key+12tap/floor-target checksPASS same.08m maximumstep threshold. ActualOpus movementtaska76c334f7ddf/fa9b20c01976 delivered22hashverifiedfiles:34held/16tap/headercutaway23side-on+17head-on scopedPASS,7933positions nojump/flash/wallcrossing. Floorclickoffcenter andbench-routingremainopen; nomouseray-pickingclaimed. SameactualOpus reused for installedRenaissance independentsource/layoutreview, pending.
- Camera-onlyv50vproposal6numericPASS vs4oldnegativefailures, but rootvisualREJECTS near-wall hairfillingview; notinstalled. Firstbakedwallcapturefailedmissingoutputfolder/assertsuspended, ownfailedprocessSIGTERM143 andlogretained; savedcapturecreatesfolder, correctedsecondexit0. Bakedcapturestdoutstaleunbakedword documented; actual1358users andmetadata provebaked. Repo scripts/check.sh firstexit1 fromsupersededprivateprototype.gd underdocs; all7exactsourcefiles archived/hashverified thenremovedrunnablecopies, checkexit0. gitdiffcheckclean; Shellplaytest42/50 current8UI/timingfailures vsprior43/50, resizefailureadded/causeunverified, frozenharness/UIunchanged. Known8ObjectDBexitleakwarnings remain. Owner50pending paths SHAequal; heartbeatdisabled;3DViewer/publiccontracts/issueclosuresunchanged. Next sourceheightcorrection, native/bakecomparison andindependentreview; wholemap/metres/likeness/browser/GPUstillopen.

### 2026-10-01 20:56 UTC — Original-video placement correction loop

Actual Opus install review task_ad82b2cbf489/ctx_cb11600fbded redecoded original6383 and independently fetched live RISD records. Confirmed helper43outputs/10textures byte-equal and sourcewall order/caseobjects unchanged, triptych northgap1mm, textiles edgegap.495m matches~.48m video. Found H1 three wall works40–47cm too high against sourceplane; H2 platform too shallow/long; H3 labels intersecting stands/sill; H4 west window bottom~45cm too high. Root source-plane fixes: Velvetcentre1.31m/Wood1.35/Madonna1.22 (catalogue dimensions unchanged); platform4.30x.95x.16 with endpoints-.95/-5.25m byeye, not survey; Madonnaauthz24.10/label besideframe atmidheight; textilelabels onstandtops; Pietàcase40mm closerwest. v49w sourceheight/native checkpass and oldv49v negativefails5findings. v49x adds sourceblind .63..3.00m and sill .51.. .63, both owned bywestwallcutaway, actualworldmesh height/privategeometrycheck0failures andsixcentrednativeviews allrootinspected. Opus independentconfirmation pending. Source readings±.06m; platformdepthdepends onassumed1.4–1.5m cameraheight, endpointsbyeye, globalmetres/fidelityfalse. v49w bake1358users/350probes complete; finalv49x bake inprogress. Existingnativefullappv50w preserved as priorplacement/bakedlighting evidence; finalfullapp pendingx. No newpaid action, original50pendingpaths unchanged,3DViewer untouched, no tickets closed.
### 2026-10-01 21:04 UTC — Final source-relative Renaissance checkpoint

Actual Claude Opus 5.5 task_ad82b2cbf489 / ctx_cb11600fbded accepted H1–H4 source-relative artwork, platform, label and window proportions against original IMG_6383 footage on unbaked v49x. Root SHA-verified all 22 delivered review outputs; original report, source comparison sheets, raw capture/log archives preserved. No independent baked-lighting acceptance, global metre acceptance or fine-model acceptance. Corner-to-window span and label stand depth remain open. Reviewer private copy logged four unrelated missing imported textures; root's final clean import and native runs do not have those errors.

Fresh v49x bake completed with 1,358 surfaces. Root individually inspected six final baked wall views, plus five final v50x actual Collection/Hall views. Native capture and integration check exit 0; 350 probes and new textile platform collision pass. 362 original Main source files SHA-equal; the current movement adapter is exact reviewed v50u SHA ca218f3e2a7f3aa15aa432f09e91c7fa840dc9648999a4e1882216e577dfaa86. Earlier movement/target results retained; off-centre floor clicks, bench routing, camera and brightness step still open. Scene UID fallback warning uses text paths. Final scripts/check.sh exit 0 with eight ObjectDB exit warnings; Shell playtest remains 42/50, eight UI/timing failures including additional resize failure of unverified cause. Final progress gallery is HTTP 200 and shows baked wall details plus actual app. All 50 pre-existing pending paths verified SHA-equal after stripping only this session's matched provenance append. All this-turn Opus workers released; heartbeat disabled. No new paid call: cumulative reported $0.91 / conservative $0.92; rejected Madonna Muse frame never retried. No 3D Viewer, frozen public interface, acceptance-test, ticket or production-build changes. Next: existing off-centre click routing, then original-video corner/window span and Hall camera/light refinement.

### 2026-10-01T21:39:52.330801+00:00 — Local floor-route candidate, rendered review pending

Collection prototype Issues #178/#182 only. Added a narrow `_walk_to` override for the evidenced Main Hall/grey gallery connection: route through the existing doorway and reuse unchanged Main Hall bench planning for the Hall leg. Preserve current position and camera while planning a Hall destination from its entry. Starts/targets already inside the passage avoid backtracking. No other room planner or native Hall source changed. New `click_route_check.gd` reproduces five of nine initial failures and passes sixteen final cases, including both native floor-ray handlers, passage-edge cases, bench detours and click replacement; no real pointer-event or CRT-coordinate claim. Max step 0.041588068 m, no wall or bench crossing. Headless copies of existing checks omit only image export lines: sixteen held-key and twelve tap/target checks pass; original checks stay byte-unchanged. Repository check and diff check pass. Final rendered check remains pending: the native integration check's probe assertion sees zero under headless mode on both original and patched adapters. Shell playtest could not initialize any display; Xvfb could not create sockets. Orca Opus runtime and tailscaled are unavailable here; no worker substitute, paid call, new preview publication, commit, push, ticket closure or full-museum completion claim. Git metadata is outside writable roots. Evidence and replayable patch: docs/evidence/collection-reconstruction/navigation-loop-20261001. Existing original Main source 362 hashes remain equal; owner pending files preserved. Heartbeat remains disabled. Next: rendered host playtest and independent Opus review of this candidate, then camera/lighting and remaining source-guided architecture/models.

### Collection viewer export and west-wall source fit — 2026-10-01

Original IMG_6383 60.60/61.00/62.00s reviewed; native lossless CPU-decoded frames and intake-matched video SHA recorded in `docs/evidence/collection-reconstruction/west-wall-source-fit-20261001/measurements.json`. Wall spans remain source-relative; global metre and visual placement acceptance false. No paid generation ($0). Optional native proof writes now tolerate read-only packaged resources; topology assertions retained. Web export preserves both baked room scenes and lightmap data byte-for-byte; hashes in `docs/evidence/collection-reconstruction/viewer-export-20261001/`. Browser rendering/publication unverified: HTTP sockets and browser approval blocked; tailscaled unavailable. Main Hall/3D Viewer unchanged.

## Catalogue photographs at measured game sizes (#278, 2026-10-08)

Provider: RISD Museum catalogue / museum-linked Micrio image service. No generation, video frames or upscaling. Cost: USD 0. Originals are retained outside git at `~/risd-godot-ingestion/catalogue-masters/`.

Measured in the mounted 1080×1080 Shell: the framed 3D view renders at 695×465; Hall painting long sides in the closest inspection shot are 158–319 native pixels. Wall copies are rounded to 64 px above 1.25× that coverage (256–448 px). Fitted zoom pictures cover at most 702 px; 896 px packed copies include the same filtering headroom. At 6× zoom the picture covers 4087–4210 logical pixels; full copies reach that size or the museum original’s canvas crop, whichever is smaller.

All full zoom photographs are in `prototype/gallery_walk4/zoom/` with `.gdignore`; `scripts/export-web.sh` copies them to `museum-images/` beside the pack. The private catalogue adapter requests one photograph on opening, retains the packed copy until it arrives, and cancels on close. The added rooms use the same ignored directory and beside-pack adapter; captions are looked up by work key because room records normalize their fields. Packed copies fit the initial page; full zooms are fetched individually.

Derivative recipe: crop the stated rectangle of the fetched photograph, preserve aspect, resize down with Pillow Lanczos; JPEG quality 90 for packed source files, quality 80 for external zoom JPEGs. Godot import: mode 1, lossy quality 0.8. Embedded Adobe RGB TIFF profiles are converted to sRGB before resizing. W6 wall crop is fitted to its existing 1024:1751 UV extent and clipped by the official silhouette (largest filled contour of grey <150) plus the retained mesh outline; its zoom uses the complete museum photograph. No room geometry, lightmap, bake, or frozen interface changes.

Source photograph URLs, downloaded pixel sizes and hashes:

| Work | Source URL | Downloaded pixels | Crop (left, top, right, bottom) | Source SHA-256 |
| --- | --- | --- | --- | --- |
| S1 / 56.096 | https://iiif.micr.io/pYSwJ/full/!4320,4320/0/default.jpg | 3326 × 4320 | [0, 4, 3326, 4310] | `c96c19e4113cb329ef111febf247a2467a9c1a39a3a387bfe16fc1f570ce9343` |
| S2 / 57.227 | https://iiif.micr.io/gSjbS/full/!3640,3640/0/default.jpg | 2518 × 3640 | [0, 0, 2518, 3640] | `98571d91e17b5e77279c2113bed9455b5bb4c922960a12344e755ba61cf7a4e3` |
| W1 / 23.332 | https://iiif.micr.io/KdQCn/full/!4080,4080/0/default.jpg | 4080 × 3357 | [124, 177, 3913, 3131] | `83c087a2eda36ee4e38ea29cf5520d874d7d076517713f076b8fc84ec591ae17` |
| W2 / 56.177 | https://iiif.micr.io/UePLq/full/!3200,3200/0/default.jpg | 1884 × 3200 | [0, 0, 1884, 3200] | `596a15f588daa8b829b4d83ed37f5800795ee7b62bc3ce72073530b8cd47cec7` |
| W3 / 62.019 | https://iiif.micr.io/YMave/full/!3354,3354/0/default.jpg | 2516 × 3354 | [7, 0, 2507, 3354] | `f0d37f047a382b7f60b9361aa414d6411ba20bed4deff20cf3285aa2c5558ccf` |
| W4 / 60.009 | https://iiif.micr.io/rHtZH/full/!3552,3552/0/default.jpg | 3071 × 3552 | [0, 0, 3071, 3552] | `82cbe01bc6d27ae6189eb977a3ed4c0c0eff2221d3bb1cff59b35bac58699d0b` |
| W5 / 57.157 | https://iiif.micr.io/FHmCS/pct:2.77,1.782,94.87,96.088/!4210,4210/0/default.jpg | 3373 × 4210 | [0, 0, 3373, 4210] | `12db9a048eed27a11c01a84d4bcd2931330b938ac7e5fefcd68481728e7eba28` |
| W6 / 32.246 | https://iiif.micr.io/fpRoz/full/!4320,4320/0/default.jpg | 2695 × 4320 | [142, 86, 2594, 4104] | `2a20cd1512457945b704f6aca18e1e8a653a44b6af9b7f46975bfddfd446ccbd` |
| W7 / 44.161 | https://iiif.micr.io/YUKcR/full/!3524,3524/0/default.jpg | 3524 × 2295 | [0, 9, 3524, 2295] | `c9d8a78f2dd8985f3242e91fb42d375cfd8088bd13209e4e13b9e5a0fb321ab1` |
| W8 / 55.152 | https://iiif.micr.io/TZjOv/full/!4320,4320/0/default.jpg | 2364 × 4320 | [0, 0, 2364, 4320] | `3317881e91d5b6383994250e99700551aca1b400fa3cdfa2cae6dba8f1f0dfbf` |
| W9 / 62.058 | https://iiif.micr.io/REqmU/full/!3480,3480/0/default.jpg | 3480 × 2246 | [0, 0, 3470, 2246] | `c4fed4134b3a3520070f61d35da81e0ca1da937876ff17189d6f83a5a1053a27` |
| W10 / 60.107 | https://iiif.micr.io/vyQLy/full/!3478,3478/0/default.jpg | 3478 × 2586 | [0, 0, 3478, 2586] | `fd40de43cd4aa9c6ffaa3e49320536a37f9c758a0a6b47fd15cf6145d33f3fe3` |
| N1 / 42.283 | https://iiif.micr.io/mUJpR/full/!3708,3708/0/default.jpg | 2238 × 3708 | [61, 66, 2169, 3653] | `d043bf6da1356fe3c8f72f1badaeff5fda446e9116c99e8e75c18d6cf915e352` |
| N2 / 60.039 | https://iiif.micr.io/cutDc/full/!3668,3668/0/default.jpg | 2207 × 3668 | [0, 0, 2207, 3668] | `63a19bacaf8f3e14eddc51747fda732013520e99069a15896c896d852ca148b9` |
| E1 / 63.061 | https://iiif.micr.io/ArtoN/full/!3715,3715/0/default.jpg | 3715 × 2626 | [3, 7, 3715, 2626] | `04f9475641062fa800b19586c9b50587d9d6d378c0e92e99fc3da4f711c1504f` |
| E2 / 18.264 | https://risdmuseum.cdn.picturepark.com/d/XwkGLpUY/ | 8192 × 10321 | [93, 62, 8144, 10225] | `66b4875e79f8b0086a60b2154789daf01de14ef8b4f69c3962e7eda258d1601b` |
| E3 / 51.506 | https://iiif.micr.io/wWpds/full/!3250,3250/0/default.jpg | 3250 × 2664 | [0, 0, 3250, 2664] | `5b87f3ee58afb0704a026a822254c6cd2d98eff0878742e0da8c66448c1add81` |
| E4 / 1987.056 | https://iiif.micr.io/gCgVB/full/!3618,3618/0/default.jpg | 3618 × 2730 | [2, 2, 3617, 2730] | `cd742b44ae6e158ebb0d2233675e34e5933534ce75a6bc2951f5fbc63d5f799a` |
| E5 / 2003.105 | https://iiif.micr.io/khjbX/full/!4260,4260/0/default.jpg | 3314 × 4260 | [0, 0, 3296, 4257] | `7ab1f1013659f8b73598c5a7aade65e40e5cc14c3b6fa76fb0d84de173e0e70f` |
| E6 / 37.104 | https://iiif.micr.io/KACyN/full/!4320,4320/0/default.jpg | 4320 × 3380 | [0, 0, 4317, 3377] | `92a4e39d2eeb24402fa00d3447c32ef55a55f55fba8c535f5240f3a3cd340f5e` |
| E7 / 33.204 | https://iiif.micr.io/RTosR/full/!3297,3297/0/default.jpg | 3297 × 2230 | [14, 15, 3292, 2230] | `606bc7c914438ef0ad9f6a71ad4f8392aa0b3dd7211dc42a54bbe017ac8b98fe` |
| E8 / 62.064 | https://iiif.micr.io/yVNUh/full/!4320,4320/0/default.jpg | 2388 × 4320 | [0, 0, 2388, 4320] | `265076bfa5a414ada98184d64b4386c3c8f379df610f35349d17cba7bac3cafa` |
| E9 / 18.096 | https://iiif.micr.io/qqLJy/full/!3245,3245/0/default.jpg | 3245 × 2513 | [0, 0, 3242, 2513] | `4d33cf7597d27fe7ca325be495638000a86fba4a42300daf5a2359f8f325da3b` |
| 34.016 / 34.016 | https://iiif.micr.io/twNLL/full/!4064,4064/0/default.jpg | 4064 × 3068 | [0, 0, 4064, 3068] | `6f46132e90e6de6a872c5c60806fadb78c442bfb157abf33f6faca30a9cf0b35` |
| 84.198.1032 / 84.198.1032 | https://risdmuseum.cdn.picturepark.com/d/EJ98DUcc/ | 8176 × 6132 | [955, 410, 6980, 5330] | `b3ea57d4dd3529af3656f15d4c84dfc1d96b601870190acd678cf95f66d70d88` |
| 2016.124 / 2016.124 | https://iiif.micr.io/HCHvB/554,256,3900,3655/3900,/0/default.jpg | 3900 × 3655 | [0, 0, 3900, 3655] | `aee953cf3e33a67147c2a146e4b6f9f5a78eccf8a7f25f2f3afb020a8a00005e` |
| 75.023 / 75.023 | https://risdmuseum.cdn.picturepark.com/d/9SdyghEI/ | 4954 × 4081 | [422, 455, 4485, 3695] | `5bbbc6e960c16b203ec2825b622caeba219b9db145ae3c0cdf732372116d9eaa` |
| 54.186 / 54.186 | https://iiif.micr.io/TpFJT/full/!4320,4320/0/default.jpg | 4320 × 3256 | [1, 0, 4314, 3251] | `a08e7d2fa9df32e4ca39aec92cb6c652755abec44f4974da4ef7cdfcb7f51258` |
| 2017.46 / 2017.46 | https://iiif.micr.io/AanBB/296,516,4932,3372/4087,/0/default.jpg | 4087 × 2794 | [0, 0, 4087, 2794] | `2b27cc22caa3cb1c82fb08202d75b1baff4bf0eec1f5c114e61f5e2811675057` |
| 2016.62 / 2016.62 | https://iiif.micr.io/WbOow/full/!4204,4204/0/default.jpg | 4204 × 3837 | [1, 1, 4198, 3831] | `e44a886153117b350bbb363f38a630c91c5487701ef0283a0be82198fbfcdd0b` |
| 2016.102.2 / 2016.102.2 | https://iiif.micr.io/OrxRm/full/!4320,4320/0/default.jpg | 4320 × 3209 | [3, 0, 4315, 3204] | `1bcfd64036f01ecb21b77476be5a4838e96d305005017ab2fc42b8f544307594` |
| 35.703 / 35.703 | https://iiif.micr.io/FFpLf/full/!3974,3974/0/default.jpg | 3974 × 3814 | [1, 1, 3968, 3808] | `d83f297a8c110b5c3218d0d0c0f9528af49b1da677728d0bd05cc34775349e73` |
| 57.167 / 57.167 | https://risdmuseum.cdn.picturepark.com/d/4riJdlMT/ | 2841 × 3750 | [0, 0, 2837, 3746] | `b0296a1c87c76938736729e33aab910e890a3f5cfb768ad23e519d5632abe64f` |
| 69.197 / 69.197 | https://risdmuseum.cdn.picturepark.com/d/ONg27DnH/ | 3432 × 4080 | [323, 271, 3120, 3898] | `df0081b6c544606baadb3c627500050e53c078d814b430d843f18f05bf5dc1b0` |
| 34.1371 / 34.1371 | https://risdmuseum.cdn.picturepark.com/d/7LKFoHBR/ | 2672 × 3258 | [0, 0, 2667, 3254] | `a11820e548b6a90853945c2561669f55c41359cc8710b820ebb01ce15570b8c2` |
| 57.281 / 57.281 | https://iiif.micr.io/ydRVU/full/!4320,4320/0/default.jpg | 3184 × 4320 | [0, 1, 3179, 4315] | `47f34934bc55484caa9079d9e7a7de13c0f765c49c068ad1bfe230ce86c1f778` |
| 53.349 / 53.349 | https://iiif.micr.io/gystV/full/!4320,4320/0/default.jpg | 3292 × 4320 | [0, 0, 3287, 4316] | `146b1c03c69db175c786f25c9a37a2c0d326620a10ec95cf48bdec228e3572df` |
| 43.539 / 43.539 | https://risdmuseum.cdn.picturepark.com/d/O2HkOSxN/ | 6054 × 4927 | [0, 0, 6049, 4923] | `a3a44c9d8c6f79f5b78de06fc9f33d96a7b438465926c96e7f7c2365df835ad6` |
| 2023.53 / 2023.53 | https://iiif.micr.io/XTtXT/full/!4320,4320/0/default.jpg | 4320 × 3196 | [0, 0, 4317, 3193] | `8c0acc53c13a3a80b856b8c664387ba6247c795ac61f09b95b1fc8a74f868e6d` |
| 73.120 / 73.120 | https://iiif.micr.io/fBwZF/full/!4320,4320/0/default.jpg | 4320 × 2491 | [42, 55, 4278, 2442] | `d26502b0547b5ecd5a902352035cbd658532a10c3cf5bc9cb5f72121c033beb5` |
| 56.099 / 56.099 | https://iiif.micr.io/QfFha/full/!3723,3723/0/default.jpg | 3723 × 2750 | [0, 0, 3720, 2747] | `6d76cadd28158270b748d63c65149b38fcf38bc6f0bfb805c0d0f9c587d19338` |
| 56.094 / 56.094 | https://iiif.micr.io/joeAV/full/!3806,3806/0/default.jpg | 3806 × 2067 | [0, 0, 3803, 2064] | `a38169129bbc62a09e4cae5f7c004861690b4d8872e9000d96c3f7617f65df02` |
| 1998.35 / 1998.35 | https://iiif.micr.io/kphad/200,134,5032,3797/4087,/0/default.jpg | 4087 × 3084 | [0, 0, 4087, 3084] | `8700e9d6ca1fc12fc299e42e6ada9029099ddfbf69ec0cae3259ceed7dc4cd5c` |

Every replaced runtime file (the work key joins to its source above):

| Work | Role / file (relative to Shell) | Pixels | SHA-256 |
| --- | --- | --- | --- |
| S1 | wall: `prototype/gallery_walk4/canvas/S1.jpg` | 247 × 320 | `4fb79815a94f568fb5e7d8c5c034822c8ce3a05ab36f23809b423bc3a155c847` |
| S1 | detail: `prototype/gallery_walk4/detail/S1.jpg` | 692 × 896 | `09796c7154f0b0757136d768b7374b5d046951f82da54ef0872a15bed085edfe` |
| S1 | zoom_external: `prototype/gallery_walk4/zoom/S1.jpg` | 3252 × 4210 | `c8558fe615b17545bf74c07f0fa21c561047cb332b9b1b4795586d2ac98d72db` |
| S2 | wall: `prototype/gallery_walk4/canvas/S2.jpg` | 266 × 384 | `563aa9b24367e078a82b8a593d225e51c2df13b606a6a28e680878b356eb070e` |
| S2 | detail: `prototype/gallery_walk4/detail/S2.jpg` | 620 × 896 | `0027d6dd5d69a24fb1967580f9c523e1d64918f231651c2a1669679e7c3b18f8` |
| S2 | zoom_external: `prototype/gallery_walk4/zoom/S2.jpg` | 2518 × 3640 | `9946983bde2c5f8d7d23f6e969509e4f19d3447899385e04339a524d067485c9` |
| W1 | wall: `prototype/gallery_walk4/canvas/W1.jpg` | 320 × 249 | `a6fe3dfbe2001868a1e4462e864581eb28dd32bb832e0bbc42a312a0a81fdfb8` |
| W1 | detail: `prototype/gallery_walk4/detail/W1.jpg` | 896 × 699 | `bafd353fea83212f1656984013b3f15595a3a41031c80fd8ef58ac75ecac15e3` |
| W1 | zoom_external: `prototype/gallery_walk4/zoom/W1.jpg` | 3789 × 2954 | `8ceb5fc73dac3f28318cd2822c7d83320df64d74278803f601c44fad8b42dd61` |
| W2 | wall: `prototype/gallery_walk4/canvas/W2.jpg` | 188 × 320 | `5d399706a01da3e61a81d8b9720e2c21c581828dbf5669107a221b7f4c28b5d5` |
| W2 | detail: `prototype/gallery_walk4/detail/W2.jpg` | 528 × 896 | `b00ccfaa5efe7fe2bce494d7b9f82acb4cdf9db97a264ed09251154f905e5423` |
| W2 | zoom_external: `prototype/gallery_walk4/zoom/W2.jpg` | 1884 × 3200 | `89981679da4a66a41a6737f628e38e6460294c75c63c9488aefa0dc1789c7ed4` |
| W3 | wall: `prototype/gallery_walk4/canvas/W3.jpg` | 191 × 256 | `4165788609b145dca3a38702601d763fec4747e00d1518b0e7fc873b255180cf` |
| W3 | detail: `prototype/gallery_walk4/detail/W3.jpg` | 668 × 896 | `828ef8ba640a24d4321c011cb2af765fbbead103d0e6c84c4a61d250a2b8a3ff` |
| W3 | zoom_external: `prototype/gallery_walk4/zoom/W3.jpg` | 2500 × 3354 | `300179fb51ffc081c8a9db4a4483ea79fef130647b5670054c7cbb5da129161b` |
| W4 | wall: `prototype/gallery_walk4/canvas/W4.jpg` | 221 × 256 | `6839232005e984bebce325dc73b1033954cbb9453ce7c9cba9486bd049cde291` |
| W4 | detail: `prototype/gallery_walk4/detail/W4.jpg` | 775 × 896 | `1c2a4e8f0eab6459f0297c5b3535e703f07f9b8e8d5caf729a1d3c047c1b7188` |
| W4 | zoom_external: `prototype/gallery_walk4/zoom/W4.jpg` | 3071 × 3552 | `63227a32ba9502df67ac62373d3dcb0cecd41c5c5ac4231db7fb27a3c37b04cf` |
| W5 | wall: `prototype/gallery_walk4/canvas/W5.jpg` | 256 × 320 | `c500edfa69565351a0fd995ca381b0451f79405ba0f4192fd7ac98207e7c30e9` |
| W5 | detail: `prototype/gallery_walk4/detail/W5.jpg` | 718 × 896 | `138cd98f3ad3e12a508fd9659f936a8f1541852b34b709487775abcc80652d04` |
| W5 | zoom_external: `prototype/gallery_walk4/zoom/W5.jpg` | 3373 × 4210 | `5e5bf0ddd2578f16ca8361fcbfce7925ff323bf13cc5d6c66a9de10aa980d189` |
| W6 | wall: `prototype/gallery_walk4/frames/W6-shaped.png` | 262 × 448 | `bb8dac4dedc81068d54bf8ecaeb0e096d9db6e7b47970acd1175ec1366c09435` |
| W6 | detail: `prototype/gallery_walk4/detail/W6.jpg` | 559 × 896 | `d391795aa73ccb3c1d6ff830f2b1984347da995429370fb5c590934397b08580` |
| W6 | zoom_external: `prototype/gallery_walk4/zoom/W6.jpg` | 2626 × 4210 | `6f2d666413af871f1bda139e11488ddd454c584740b61430641e492d7b674307` |
| W7 | wall: `prototype/gallery_walk4/canvas/W7.jpg` | 320 × 208 | `bc60b155dfd733b1d107554acd71fe775934f241d3764a03e2d0161eeb5adc47` |
| W7 | detail: `prototype/gallery_walk4/detail/W7.jpg` | 896 × 581 | `df068d3b409ea7732459b34a3228c106a9c22aed9657ed593e1ecf3a9a1de5dd` |
| W7 | zoom_external: `prototype/gallery_walk4/zoom/W7.jpg` | 3524 × 2286 | `07816131bf7401edf78fe722c4e9ad8590942eade116922afe53655ce3ecbcb6` |
| W8 | wall: `prototype/gallery_walk4/canvas/W8.jpg` | 175 × 320 | `fe14a274dc4536d8387df5b19e2ca6dedb236a70ed7a88db8d8b107876c43098` |
| W8 | detail: `prototype/gallery_walk4/detail/W8.jpg` | 490 × 896 | `284aed39ec3f6694d3d5a4ff05aa9dd5516ad22505bdffc1475ff32b0bac4676` |
| W8 | zoom_external: `prototype/gallery_walk4/zoom/W8.jpg` | 2304 × 4210 | `4f0bdfaeacff6cf1a4355e37460e3a16697ea4d5ca052ad89ef50985b564d47a` |
| W9 | wall: `prototype/gallery_walk4/canvas/W9.jpg` | 384 × 249 | `f61721b5775253a61c4e770a0993596e1e1771b0b0c113008700dc2355dde5a5` |
| W9 | detail: `prototype/gallery_walk4/detail/W9.jpg` | 896 × 580 | `99eb91c64fc2877c29d1409a70cd1a87065b9fdd88667c163de814e11ab8b7a8` |
| W9 | zoom_external: `prototype/gallery_walk4/zoom/W9.jpg` | 3470 × 2246 | `a3a5622a44fe590d4d6bf624ae8a215829abe4204f4b3ffc880c81d6add83092` |
| W10 | wall: `prototype/gallery_walk4/canvas/W10.jpg` | 320 × 238 | `f224a06f9e8394259329d491cfa4ddebdc3726286d758f9f0d9fb26123709af2` |
| W10 | detail: `prototype/gallery_walk4/detail/W10.jpg` | 896 × 666 | `73b10c2defa2d7574ef41ae86b062bcd65175857b1b82f6b0655910703ed8be6` |
| W10 | zoom_external: `prototype/gallery_walk4/zoom/W10.jpg` | 3478 × 2586 | `e97356fc3a33161c03b4db510e61949256a85796c048aa19e2f728fe64dd15fc` |
| N1 | wall: `prototype/gallery_walk4/canvas/N1.jpg` | 188 × 320 | `e836f738157db9e20916c4d0372988c1a619730d938e20a62c76195f30c18cb7` |
| N1 | detail: `prototype/gallery_walk4/detail/N1.jpg` | 527 × 896 | `828cdfd27dc01c399e78781f413b35db1aba3fefbd1e22d2cb67748c03bb548b` |
| N1 | zoom_external: `prototype/gallery_walk4/zoom/N1.jpg` | 2108 × 3587 | `50f96a06d132147be210c296e44055cf5db732e0be47245d602e5d3721d494ae` |
| N2 | wall: `prototype/gallery_walk4/canvas/N2.jpg` | 193 × 320 | `7645301bf419a427b2e2f064fd66522affd5e2294ad58f45f7af280a4fe2b007` |
| N2 | detail: `prototype/gallery_walk4/detail/N2.jpg` | 539 × 896 | `4b93a5e9f8e9bd5ea9322c17cdcd1f1be52cdcd47deaceb6cbb1ffbd96762433` |
| N2 | zoom_external: `prototype/gallery_walk4/zoom/N2.jpg` | 2207 × 3668 | `9182219352a929d9587c54469c5bf58d4e773e52a0ab65bb87d7cb143baec4db` |
| E1 | wall: `prototype/gallery_walk4/canvas/E1.jpg` | 384 × 271 | `de8f1a49779281c5152fb5f26858c8d513a787d62e8a583dffa081a9e4321e0c` |
| E1 | detail: `prototype/gallery_walk4/detail/E1.jpg` | 896 × 632 | `c91f128fc6fe4c8611b4a0e105268cd54e6358a00e4bf7fbf94f87bd8666b98d` |
| E1 | zoom_external: `prototype/gallery_walk4/zoom/E1.jpg` | 3712 × 2619 | `f59fc887274cd8b7bd1281eeccc58d32575f7b6d49a33622af2e6eb9c363d630` |
| E2 | wall: `prototype/gallery_walk4/canvas/E2.jpg` | 203 × 256 | `a58b10cf000900c18cf76d94492dcf56fdd15a059dbd880ba0febd6a62bdb2ee` |
| E2 | detail: `prototype/gallery_walk4/detail/E2.jpg` | 710 × 896 | `30365436fe8681a6dc7669a0e24c93a03bd5fe0638d076d7045d64a6b96f9635` |
| E2 | zoom_external: `prototype/gallery_walk4/zoom/E2.jpg` | 3335 × 4210 | `6545a2e182ba0f26c4dbef4c32b867789de5badf9c52d71814d770e7cb95ad48` |
| E3 | wall: `prototype/gallery_walk4/canvas/E3.jpg` | 256 × 210 | `65ad136a213568dc8b9cb987d435947750a46c6198f242c3e4fceb56e049bb12` |
| E3 | detail: `prototype/gallery_walk4/detail/E3.jpg` | 896 × 734 | `63ebc5f29f6096b53e8bf9798373b50a44a2acb58e88da568a5efa7035c001b9` |
| E3 | zoom_external: `prototype/gallery_walk4/zoom/E3.jpg` | 3250 × 2664 | `dd5771a305350f6c81c11c5a4d8a3effc5cf3225f828df018d08dd3246d43607` |
| E4 | wall: `prototype/gallery_walk4/canvas/E4.jpg` | 320 × 241 | `7240080bbcf297da2e67da785dff2b7e49e20ae7de2d320eb4c945c8ddb1e251` |
| E4 | detail: `prototype/gallery_walk4/detail/E4.jpg` | 896 × 676 | `de0c488108dbcee44d1b633a5920c435cd5267b7c3051e94386ce9ad83ea97f4` |
| E4 | zoom_external: `prototype/gallery_walk4/zoom/E4.jpg` | 3615 × 2728 | `cd62baefa086e556a6203a26bee645ce5abba3eaf50cd7d09363fd1611328f46` |
| E5 | wall: `prototype/gallery_walk4/canvas/E5.jpg` | 248 × 320 | `3c05c0f9adb09fbfbe1e289a1d75d63662867dd9dbdefa19c520d4a360b59d42` |
| E5 | detail: `prototype/gallery_walk4/detail/E5.jpg` | 694 × 896 | `55633ce0b5c8414ff4eac1dcc6a24a9de8396ad119d4b93f95a45436062c5f43` |
| E5 | zoom_external: `prototype/gallery_walk4/zoom/E5.jpg` | 3260 × 4210 | `d79a27a86e6655e3a2969f4ac4266e74eda73332492a9d25a8f5ff9353aa5d09` |
| E6 | wall: `prototype/gallery_walk4/canvas/E6.jpg` | 320 × 250 | `1c07ebd43f334da8c2e97525e51486a2d2957dca636c1a68ece44563d71a995a` |
| E6 | detail: `prototype/gallery_walk4/detail/E6.jpg` | 896 × 701 | `a4cdfbe184fb170b4a82366bbec47ab9a92e7c1e9ad8082f629db2e380ac93c5` |
| E6 | zoom_external: `prototype/gallery_walk4/zoom/E6.jpg` | 4087 × 3197 | `ff78243256f13bb0003fbf57b965e8af0dd2f8af01a36c8d0a05f9333f130ce6` |
| E7 | wall: `prototype/gallery_walk4/canvas/E7.jpg` | 320 × 216 | `1e07c0b6558a12364c2859d195ccf2baf84355c7eda254cb5e86b19e7311c211` |
| E7 | detail: `prototype/gallery_walk4/detail/E7.jpg` | 896 × 605 | `50835afb3e4e93aa5f619d97044f0b5e7fc89cef8ee4ef3b7893043ae50fbf76` |
| E7 | zoom_external: `prototype/gallery_walk4/zoom/E7.jpg` | 3278 × 2215 | `28bfb6c7c3e51c43da25073f5708eb8ce56be5548f7551be137e7b2d0861f98f` |
| E8 | wall: `prototype/gallery_walk4/canvas/E8.jpg` | 177 × 320 | `64efc4c0c561d79372699c5ece6008e313d3ae350d0721d09f3efd46cb1cdac1` |
| E8 | detail: `prototype/gallery_walk4/detail/E8.jpg` | 495 × 896 | `234d930af8641f25183e085a50bdde623213df82a785afb31f243284a6eabbf5` |
| E8 | zoom_external: `prototype/gallery_walk4/zoom/E8.jpg` | 2327 × 4210 | `f8444bfee2935f824c417d8e369743e837ddc0e3a8502cbca2c60538201a3822` |
| E9 | wall: `prototype/gallery_walk4/canvas/E9.jpg` | 320 × 248 | `61ad878cbb819e8644a3185016496a37ca53b2b3a3c33eaac3dabb02de1a627d` |
| E9 | detail: `prototype/gallery_walk4/detail/E9.jpg` | 896 × 695 | `45047810e6e1eda82d33f8fb17e8d23a199f3ac5a7680d19398d596f840b9ada` |
| E9 | zoom_external: `prototype/gallery_walk4/zoom/E9.jpg` | 3242 × 2513 | `881d5ebdc2f1cfbeb0abc5d6ddaaa42f2e73103f171ea9b56320f11a8dae92d1` |
| 34.016 | wall rectification quad in source pixels: [[1289.1839599609375, 1395.93994140625], [1927.637939453125, 622.8040161132812], [3692.592041015625, 1509.4560546875], [3115.528076171875, 2377.699951171875]] | transform | n/a |
| 34.016 | wall: `collection_rooms/assets/renaissance-case-a/textures/bookcover-board.png` | 157 × 256 | `5bebcc82a2ec4842e69f6ee55727f86a225ab0de15717e027c8a08ea22e3c90d` |
| 34.016 | detail: `collection_rooms/assets/details/34.016-preview.jpg` | 896 × 676 | `453b077ba5dd77de93c9d121b8a9ca34b4ab248b998c047f1b6adda05bc68aea` |
| 34.016 | zoom_external: `prototype/gallery_walk4/zoom/34.016.jpg` | 4064 × 3068 | `cd3c72481a895bd8f08b86a1f2f27e8afb6de2ca17ea16b8573661519b5c481b` |
| 84.198.1032 | wall: `collection_rooms/assets/additions/european-east/print-84.198.1032.jpg` | 256 × 209 | `f5ef9670d7e541d7501191ba048597bdd80f5666386c37572bb857ed010a60d0` |
| 84.198.1032 | detail: `collection_rooms/assets/details/84.198.1032-preview.jpg` | 896 × 732 | `d15d5fc598c572b80b014079458f376a037d8247b57608b7ccb660ea23a77204` |
| 84.198.1032 | zoom_external: `prototype/gallery_walk4/zoom/84.198.1032.jpg` | 4087 × 3337 | `a244fc418a95ef7ee47121d7e97f7f73dc4c9e20330ebb82933afdacf2e88c87` |
| 2016.124 | wall: `collection_rooms/assets/additions/european-east/basket-2016.124.jpg` | 256 × 240 | `a08333c9f1c749ed0a3fe217a00dea3308b1c3ca801638ccf7300c2c68ea93ed` |
| 2016.124 | detail: `collection_rooms/assets/details/2016.124-preview.jpg` | 896 × 840 | `1574f8888da509b39b188b8f9d0fa1603afd17b8bdcd7c9666c4d1a9d08eb173` |
| 2016.124 | zoom_external: `prototype/gallery_walk4/zoom/2016.124.jpg` | 3900 × 3655 | `e4cf6ac918fe8270eea96870b47eadcfe65dde7b7cb8779150aec9f1c5a5a504` |
| 75.023 | wall: `collection_rooms/assets/additions/european-east/cabinet-75.023.jpg` | 256 × 204 | `8c5446e639449bf3cbcbef89d66d956458e72d15dbbb64dc0c64218d3ee262fd` |
| 75.023 | detail: `collection_rooms/assets/details/75.023-preview.jpg` | 896 × 715 | `9aac3aed9bc88a7d2d6b99d66680a441e8d89243000aa7166eac807df6a309bc` |
| 75.023 | zoom_external: `prototype/gallery_walk4/zoom/75.023.jpg` | 4063 × 3240 | `5b0047f3aa25ef9f143d90821e5bc84a7260f90408afa9c184564abaab2a1292` |
| 54.186 | wall: `collection_rooms/assets/additions/european-east/painting-54.186.jpg` | 320 × 241 | `0d1e9d8709c4a0c4505db5ca66730f1d7636ae8b1755974f4000f6274b20646d` |
| 54.186 | detail: `collection_rooms/assets/details/54.186-preview.jpg` | 896 × 675 | `74730c18acdd7d3e48568db0cd2330d2a38f9cce39f832a7d1a553835e405ac5` |
| 54.186 | zoom_external: `prototype/gallery_walk4/zoom/54.186.jpg` | 4087 × 3081 | `8da20430cacb3be665c8dfef57a7c175130a533ca16a16d9eb103fc6a5c9f73a` |
| 2017.46 | wall: `collection_rooms/assets/additions/european-east/commode-2017.46.jpg` | 320 × 219 | `e5c279606310d8331c6ec3c02467729c2be246381588dca8f76f5db4f106da7b` |
| 2017.46 | detail: `collection_rooms/assets/details/2017.46-preview.jpg` | 896 × 613 | `443734fd1d2ad31fbbd958d1b6694a073dc1ebe96ef028fdea962e69322ac249` |
| 2017.46 | zoom_external: `prototype/gallery_walk4/zoom/2017.46.jpg` | 4087 × 2794 | `c10e358c0ee7265360ba97d98a289dcce076a58909387e2a5042ac7148c73e47` |
| 2016.62 | wall: `collection_rooms/assets/additions/european-east/plate-2016.62.jpg` | 256 × 234 | `db097e9826f0b08ea5f6ba32bbcb8beed29b7e1c298c35f93f95555c58b5a771` |
| 2016.62 | detail: `collection_rooms/assets/details/2016.62-preview.jpg` | 896 × 818 | `3ae7686e75996aee4dc70eafcb8e48236b2a188dd62c0b8f912cb58cc28810d0` |
| 2016.62 | zoom_external: `prototype/gallery_walk4/zoom/2016.62.jpg` | 4087 × 3730 | `d01562f23b393a92afc1c7d58e173cc91085b8c42187b0d08660ea9a765c97a9` |
| 2016.102.2 | wall: `collection_rooms/assets/additions/european-east/plate-2016.102.2.jpg` | 384 × 285 | `cc2cff3e1ca50014a3b7d28d8a64989afc292fc4b9b440c2c561efc7942d94be` |
| 2016.102.2 | detail: `collection_rooms/assets/details/2016.102.2-preview.jpg` | 896 × 666 | `e7ecb786aafdabbd131985776e9a0d30da436bb460fd4b919030cf2b59d4d858` |
| 2016.102.2 | zoom_external: `prototype/gallery_walk4/zoom/2016.102.2.jpg` | 4087 × 3037 | `e354cd87ba3702d155920c6a7cb2504617b08d832faf0ca8269eee61764eaed9` |
| 35.703 | wall: `collection_rooms/assets/additions/european-east/plate-35.703.jpg` | 256 × 246 | `73b92df624b7221f91d442b723dccaa0c176799fcfc6d5bcb1b38d142c4548f2` |
| 35.703 | detail: `collection_rooms/assets/details/35.703-preview.jpg` | 896 × 860 | `809d7d63589a034b1f36f133ca00e871dfdd456b62c0b5a4962c6527f3bc79c8` |
| 35.703 | zoom_external: `prototype/gallery_walk4/zoom/35.703.jpg` | 3967 × 3807 | `e0087ab9a8b77b9e23e155daec845ba75f579c775bc4a22bc72faa22c5719590` |
| 57.167 | wall: `collection_rooms/assets/additions/european-east/painting-57.167.jpg` | 194 × 256 | `d37bceef30ebe3648571d50626d37e7843047078e6b7ef6d1a40c7b364edccd7` |
| 57.167 | detail: `collection_rooms/assets/details/57.167-preview.jpg` | 679 × 896 | `d9fc4b45913e4667400d6edee5458863fe45bbd4f1edd3930e988a3f7db1bf48` |
| 57.167 | zoom_external: `prototype/gallery_walk4/zoom/57.167.jpg` | 2837 × 3746 | `c9b22aef746f9ed3866bd62d796b02e7fec24cdc4f004eb1ab21be61709cc103` |
| 69.197 | wall: `collection_rooms/assets/additions/european-east/painting-69.197.jpg` | 247 × 320 | `ed787c3a5eae762449fe556fad914180750e0c984d9566f5dab660b7761d3097` |
| 69.197 | detail: `collection_rooms/assets/details/69.197-preview.jpg` | 691 × 896 | `898bc66c1d9753afb7a2169b8df9bbf72bc4a8ba64c93165e9681bfdb8d6123c` |
| 69.197 | zoom_external: `prototype/gallery_walk4/zoom/69.197.jpg` | 2797 × 3627 | `731bd48ca5b151463832f559766ba8ae608d002f5102717af048d91d1abb58f3` |
| 34.1371 | wall: `collection_rooms/assets/additions/european-east/painting-34.1371.jpg` | 210 × 256 | `f3ba00a12762f299328146e5f36e08325649a515734de5caf64ff0f871650865` |
| 34.1371 | detail: `collection_rooms/assets/details/34.1371-preview.jpg` | 734 × 896 | `16aa32894e7ce1042b85d0e45142a7c7174d558c416c04ce5e324640445eaf04` |
| 34.1371 | zoom_external: `prototype/gallery_walk4/zoom/34.1371.jpg` | 2667 × 3254 | `0fa4b5b3bd2e0e9685945ec432f3cee4464f2308e67d9e83ba73dbe21e0c68db` |
| 57.281 | wall: `collection_rooms/assets/additions/european-east/painting-57.281.jpg` | 236 × 320 | `463c0d844edef3512d3f49e804b64fefedce689667277e680f5da89cab65c04b` |
| 57.281 | detail: `collection_rooms/assets/details/57.281-preview.jpg` | 660 × 896 | `b671076abccf92772af16461fedf9d4a111d7ce17e46a12bd167952eb240ce8f` |
| 57.281 | zoom_external: `prototype/gallery_walk4/zoom/57.281.jpg` | 3102 × 4210 | `5e4c04f0788f0187e9615cff8ea33308e679bb2026e4ce047a82d15ce9dcabbd` |
| 53.349 | wall: `collection_rooms/assets/additions/european-east/painting-53.349.jpg` | 195 × 256 | `9798270fa905b82a9bce7f40dd43a76ed161e6ac2dcd4ff1de48969b9c0ae41f` |
| 53.349 | detail: `collection_rooms/assets/details/53.349-preview.jpg` | 682 × 896 | `4ea59ba1d1266724c9febef1e63da2470dd750d133c4fb389cf13cd72cde1486` |
| 53.349 | zoom_external: `prototype/gallery_walk4/zoom/53.349.jpg` | 3206 × 4210 | `80a3d730303ab39a28cc0fc372cd7557a04f53cb91e85e7d0ebe12506f0ac109` |
| 43.539 | wall: `collection_rooms/assets/additions/grey/gericault-43.539.jpg` | 256 × 208 | `69e970a8b3b5f1e31ec22a793bcdc798207d72016572afc22c5cb610387ed904` |
| 43.539 | detail: `collection_rooms/assets/details/43.539-preview.jpg` | 896 × 729 | `1469680c579b462fa818f612eb9165f8359dcbacb54f1375ec5d2eaf93c13e4b` |
| 43.539 | zoom_external: `prototype/gallery_walk4/zoom/43.539.jpg` | 4087 × 3326 | `8f6f8e2443b4c98d966449a15b2fe999907d719091529b2bd6827aefa15231fa` |
| 2023.53 | wall: `collection_rooms/assets/additions/grey/bannister-2023.53.jpg` | 192 × 142 | `c9eaed194c9b7eea7dd7f71ba6cac49147b8f863b2298e46a0f97727b2518d74` |
| 2023.53 | detail: `collection_rooms/assets/details/2023.53-preview.jpg` | 896 × 663 | `f4cb49119007507dbbb5adb91e699eabec9afd5feaadff5093e2b56fa21677a5` |
| 2023.53 | zoom_external: `prototype/gallery_walk4/zoom/2023.53.jpg` | 4087 × 3023 | `4f5a83cdde94b8fc9c383d107326b0b49799feb1b8467148a2ec94c6d229a35f` |
| 73.120 | wall: `collection_rooms/assets/additions/grey/daubigny-73.120.jpg` | 320 × 180 | `8aec12616703aa220e4756fc48e74e626f1029e92a0d60b839052d755fb39d2e` |
| 73.120 | detail: `collection_rooms/assets/details/73.120-preview.jpg` | 896 × 505 | `499f9b65b5dd47d6bec9d76149f8c450f60308d6b1c786fe3b2d6c4aca455f2e` |
| 73.120 | zoom_external: `prototype/gallery_walk4/zoom/73.120.jpg` | 4087 × 2303 | `5a24f697f6c9ed260b72394cefcc6206ce8fe0696c89b9a860161878b817fa42` |
| 56.099 | wall: `collection_rooms/assets/additions/grey/eastlake-56.099.jpg` | 256 × 189 | `5bbd0476d49a9767e6a3b95b9c483317a1779c5f270de078d1b13f72656d6b13` |
| 56.099 | detail: `collection_rooms/assets/details/56.099-preview.jpg` | 896 × 662 | `d100f7f49b991985b176b183999fea3b3bd45d8b8cb94e17b13bac5ca2fab74e` |
| 56.099 | zoom_external: `prototype/gallery_walk4/zoom/56.099.jpg` | 3720 × 2747 | `61d43cffe5c03231ea01fb31d5f12a49e8125aebfd7e36acf01d9309c6f0d484` |
| 56.094 | wall: `collection_rooms/assets/additions/grey/pannini-56.094.jpg` | 256 × 139 | `a3f5386c8249007a795ab0d8fd0c0585d58f455f2371625e41e867c5c272f3c9` |
| 56.094 | detail: `collection_rooms/assets/details/56.094-preview.jpg` | 896 × 486 | `afc407f2d6e73ce9bca968ec281f6341e136f21ec4f4cef44aecec99dd0aa568` |
| 56.094 | zoom_external: `prototype/gallery_walk4/zoom/56.094.jpg` | 3803 × 2064 | `6775afcfa50021af7437bbb8ed9a019a4bd94d660448e15463bc18add132c570` |
| 1998.35 | wall: `collection_rooms/assets/additions/grey/villeneuve-1998.35.jpg` | 192 × 145 | `83c8ebda7ff40b5905b0d0157249fa4e977b358fbe880cadb967de1c7bc379be` |
| 1998.35 | detail: `collection_rooms/assets/details/1998.35-preview.jpg` | 896 × 676 | `158d2a69da93c7cd2d03de1b2cb3a243c95181ad8f8f845bcbf4388669d0fcae` |
| 1998.35 | zoom_external: `prototype/gallery_walk4/zoom/1998.35.jpg` | 4087 × 3084 | `2871e1e86148acd2cc7c0c4c49acf236244bd064daf07a9e141753fe161630b4` |

#278 final measurement note: six French canvases cover 126–211 native pixels in the mounted Shell and use 192–320 px wall copies. These are measured on the mesh carrying the wall photograph, excluding its frame and blank label. Other added-room `work_render_px` values are conservative complete-work extents where current camera orientation prevents a face-on canvas measurement. All full zoom files are external, and all fitted previews are 896 px.

### 2026-10-08 — Rooms rebuilt for place_mesh(); no placed mesh ships (#264)

`scripts/rebuild_rooms.sh` on the merged tree: 1554 surfaces, 430 probes, no generation, USD 0.
`collection_rooms/addition_baked/room.exr` is byte-identical to the #258 bake
(`f3bf79f555332076928ee7339b4673113966a9cbb4842f192ce214e1714ee264`): nothing a visitor sees changed.
The proof pictures in `docs/evidence/mesh-placing-264/` were taken at commit `2432986c` with a
6,000-triangle copy of the owner's scan of Portrait of Hadrian (59.050) standing in for the Head of
Christ (59.131). That copy is not in the build. The check's fixture is the visitor's own model,
`character/walk.glb`, placed only when the check asks.

## Launch geometry prepared locally (#281)

`native_cpu_arrays.res` is a deterministic extraction of Hall native primitives built by walk4.gd and painting_asset.gd with Godot 4.7.2, prepared by `modules/shell/prototype/gallery_walk4/prepare_cpu_geometry.gd`. Provider: local Godot; model: none; count: one extraction; cost: $0; no paid generation. Source revision: `abf8858504a8f79fc124613bd60e8350231fd88c`. SHA-256: `d91c30dfb4d8ae71d3630103a1327fb9e49905ef30d555cb2ca1ea12e9827a9f`; size: 13962 bytes. Regenerate after changing the source geometry or face/hand skin gates. No artwork, shader appearance or animation is redesigned.
