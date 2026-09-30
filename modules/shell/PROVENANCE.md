# Shell visual provenance

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
