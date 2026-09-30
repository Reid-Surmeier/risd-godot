# Arm weight repair: independent native review

Unpaid research for [character prototype #231](https://github.com/Reid-Surmeier/risd-godot/issues/231), 2026-09-30. Native Blender 4.3.2; no runtime files, paid calls, bind-joint positions or mesh geometry changed by this research. Source references are the [glTF skinning specification](https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#skins), which defines weighted joint/inverse-bind deformation, and the installed Blender 4.3.2 glTF exporter source described below. Numeric conclusions come from importing and sampling the actual pilot GLBs, rather than inferring a rig from screenshots.

## Smallest reviewed edit

The imported model gives some biceps vertices Hips and UpLeg influence, even when Arm has over 75% of their weight. In the reviewed set, combined Hips/UpLeg influence reaches 21.61%. This explains why a rigidly rotating bone can still squash skin. The repair squares each existing weight and then normalizes their sum once. It adds no influence and preserves the original maximum four influences per vertex.

The target-specific selection is **739 vertices**: 282 LeftArm and 457 RightArm vertices with original Arm weight >0.75. Search all rest positions for coincident seam mates within 10 micrometers; this particular import adds zero vertices because those mates already meet the threshold. The 261 selected coincident pairs remain closed across 129 poses of each reviewed clip. The earlier lost scratch count of 758 was not reproduced and is not the selected recipe.

The mask records IDs, world rest coordinates, original weights and resulting weights. Against root's original `rigid-head.glb`, these IDs agree within **3.07 micrometers** and original weights within **1.2e-7**. Apply the recorded weights after verifying this contract; do not square an already repaired model again. Jaw and rigid-shoe selections are separate.

## Measured final result

The portable native check samples 129 normalized phases per clip, re-identifies the same original regions after GLB import, and compares principal point-cloud extents to their rest extents. These are shape measures, **not mesh-volume or collision proofs**.

| Clip | Baseline maximum extent contraction | Selected maximum extent contraction |
| --- | ---: | ---: |
| Fast locomotion | 11.3313% | **1.0641%** |
| Neutral idle | 10.2314% | **1.3749%** |

Baseline Fast v4 SHA-256: `49c6c0b63814f74497898f0fc9966095fc17c9c0b8149d1b4d59aeb9d17dcc45`. Selected Fast v6 SHA-256: `9153b2c29799677d5d93a6cddc46a147b751987c77bdfd9669fe9ff4c5767f20`. Their periods differ, 0.4 seconds versus 14/30 seconds; normalized phase comparisons isolate the arm deformation from the cadence change. Both retain 24 bones and 7,719 triangles. The fast clip temporarily occupies the prototype's `walk` slot; its name is not proof that the footage depicts Nintendo's WALK1 state.

Before/after front and profile renders at phases 0.25 and 0.75 show coherent arm shapes with no new visible opening or basis flip. The biceps change is subtle at game scale. The jaw remains closed in these images. This is limited visual sampling, not exhaustive self-intersection verification. Existing asymmetric segment lengths, hands, shoulder/collar joins and inferred model proportions remain different from the game.

## GLB roundtrip and replay

A separate corrected scratch export retains 24 bones and 7,719 triangles. Selected rest positions agree after roundtrip within **4.63 micrometers**, while weights differ by at most **0.00019054**. The installed exporter explains this: `4.3/scripts/addons_core/io_scene_gltf2/blender/exp/primitive_extract.py`, method `__get_bone_data`, sets `min_influence = 0.0001` and omits smaller weights before export. The native check allows at most 0.0004 per influence, then verifies the actual final GLB shape rather than assuming in-memory weights survived identically.

The first scratch export also caught time rounding at Blender's default 24 FPS. Scaling imported fractional action-key times by ten and exporting at 240 FPS preserved 0.400000016-second fast motion and 4.03333346-second idle. Root's existing 240 FPS bake is the reusable path; the standalone scratch GLB is not the chosen runtime asset.

Evidence lives under `image-work/character-pilot/iterations/video-match/independent-review/arms/`; the mask is `../../arm-weight-mask.json`. The portable `audit_pair.py` takes exactly four arguments after Blender's `--`:

```bash
blender --threads 1 --background --factory-startup --python audit_pair.py -- \
  baseline.glb selected.glb arm-weight-mask.json selected-pair-receipt.json
```

It asserts unchanged topology, region identity and weight agreement; samples both real imported clips; and fails if selected arm contraction exceeds 2%. It never modifies either input. The original review, core receipt, roundtrip receipt and eight before/after renders remain separate from this final selected-pair receipt.

## Remaining foot question

No foot-neutral basis change is justified by this arm experiment. Correctly transferred source ankle rotations can still produce different visible sole contact when the generated shoes and ankle-to-sole offsets differ. The source-contact event labels, actual target sole contact, and world-space stance lock need separate evidence. A standing-foot reference may be a useful future controlled trial, but no unsupported basis correction was accepted here. Exact matching to game video remains unverified.
