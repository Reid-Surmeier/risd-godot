# Character head deformation: measured cause and minimum repair

Research for the head/posing/motion follow-up to [Prototype: Muse-to-3D proof of the supplied horned character](https://github.com/Reid-Surmeier/risd-godot/issues/231), September 30, 2026. Scope: read the captured model and test hypotheses in RAM; the root agent owns exported variants and visual acceptance.

**The walking head warps because generated weights attach its surface to shoulders and arms.** For this model, assigning the head core entirely to `Head` removes the measured distortion. Resetting scale tracks does not. This is supported by the controlled comparisons below, not inferred from the appearance alone.

## Inputs and repeatable check

Inspected [the captured normalized GLB](https://github.com/Reid-Surmeier/risd-godot/blob/84768b81808d71cff1d3fcddeaba9533e4d1b044/image-work/character-pilot/target-baked-normalized-idle.glb), SHA-256 `9d566ae7413d209f9986b1ff53d486ba3535a59f498d686f169d7257e21cc804`, using installed Blender4.3.2 `32f5fdce0a0a`. The script selects the scene's actual skinned mesh, excluding the importer bone-display helper. It measures5,640 imported vertices and24bones, then samples24 evenly spaced subframes over the imported Walk action range `[0.8000000715,25.6000022888]`. The final endpoint is excluded to avoid counting the loop endpoint twice; this is a deformation study, not a new timing/loop verdict.

The reusable probe is `image-work/character-pilot/iterations/rig-diagnosis/probe.py`; its sanitized `diagnosis.json` contains input hash, rest joints, source weights, geometry slices,24pose records, and RAM-only hypothesis checks. Run from the prototype repository root:

```bash
/home/reidsurmeier/.local/opt/blender-4.3.2/blender \
  --background --factory-startup --threads 1 --python-exit-code 1 \
  --python image-work/character-pilot/iterations/rig-diagnosis/probe.py
```

No input mesh/rig/animation file is written. Variant weights and scale edits exist only in that process; the only outputs are the probe measurements. Its assertions require the observed baseline distortion, negligible benefit from a scale-only change, and sub-millimeter rigid-head residual.

## Evidence

A conservative head core is the **rest evaluated world** surface with `z >= 1.10m`:1,392vertices. Every vertex's dominant group is Head, but this does not make the binding rigid. Mean weights are Head90.515%, LeftShoulder4.329%, LeftArm2.181%, RightShoulder1.620%, RightArm1.177% and Spine0.179%.1,206of1,392vertices carry more than2% influence outside Head/neck/head-end/headfront. Even the upper cap/horn region `z >= 1.55m` averages only92.316% Head;858of996vertices have more than2% influence outside those groups. Source: the probe's original, unedited weight inventory.

Internal edge lengths in the1.10m head core change to0.7364–1.5078times their rest lengths over the24poses. After fitting only translation and a proper rigid rotation, maximum per-pose RMS shape error is4.455cm. The cap/horn-only region still has4.345cm maximum RMS. These measurements detect deformation independently of screen projection, head turn, camera distance or head position.

The Head skin deformation matrix `pose_matrix @ inverse(rest_matrix)` has singular values within approximately `0.9999982..1.0000349`; its largest normalized-axis dot product is `2.12e-5`. Neck and the Hips/Spine ancestors similarly remain near unit scale. Those errors are far smaller than the tens-of-percent edge deformation. The earlier provider Idle Hips1.17647problem is real, but it is a separate failure from this Walk head warp.

| RAM-only change | Maximum core RMS after rigid alignment | Internal edge ratio range |
| --- | --- | --- |
| Original normalized model |0.0445534m |0.736439–1.507795 |
| Force ancestor scale curves to1 |0.0445536m |0.736425–1.507793 |
| Clear other groups, Head weight1 for `z>=1.10` |0.00001414m |0.999827–1.000153 |
| Same operation starting at1.05 or1.00m |same1.10m core result |same1.10m core result |

The last two rows measure the **same conservative1.10m core**. They do not establish which lower collar threshold looks best, nor whether a hard cut creates a visible crease.

The mechanism matches documented behavior: Blender's Armature modifier uses weights in groups named for bones to control each bone's influence; multiple weighted joints can deform a surface as they rotate differently. Its PreserveVolume option changes the deformation method but does not make an accidentally shoulder-bound head a correctly bound rigid object. The portable minimal repair is the vertex weights themselves. [Blender4.3 Armature modifier](https://docs.blender.org/manual/en/4.3/modeling/modifiers/deform/armature.html), [Blender4.3 editing bone vertex groups](https://docs.blender.org/manual/en/4.3/sculpt_paint/weight_paint/usage.html).

glTF stores joint indices and weights in `JOINTS_0`/`WEIGHTS_0` with inverse-bind transforms. A single valid joint at weight1 describes a rigidly bound region without requiring a Blender-only modifier feature. Re-export and runtime checks still need to verify that the intended weights survive. [glTF2.0 skinning specification](https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#skins).

## Where to put the mask

The actual rest-world `neck` bone head is approximately `(0.002482,0.016326,0.724118)`; Head's pivot is `(-0.00000012,0.007881,0.800041)`. Using “everything above neck” selects3,298vertices, including arms and upper torso. Dominant-Head membership also extends down to `z=0.725873m` and sideways to about `|x|=0.64m`. Neither is a safe whole-head mask on its own.

Raw index connectivity is fragmented by exported UV/normal seams. Diagnostic welding at a10µm coordinate grid gives3,879unique positions: one main component of3,852positions covers almost the entire character; three tiny fragments cover15,9and3positions. There is no clean isolated head component to select. This diagnostic weld never alters the mesh or its UVs. It also means a component-size heuristic would choose almost the whole body.

Use evaluated REST world coordinates for the prototype's mask:

```python
rig.data.pose_position = "REST"
bpy.context.view_layer.update()
evaluated = skin.evaluated_get(bpy.context.evaluated_depsgraph_get())
head_ids = [
    v.index for v in evaluated.data.vertices
    if (evaluated.matrix_world @ v.co).z >= 1.10
]
for group in skin.vertex_groups:
    group.remove(head_ids)
skin.vertex_groups["Head"].add(head_ids, 1.0, "REPLACE")
```

The current mesh object has uniform world scale0.01;1.10is a **world-meter** threshold, not1.10in its local centimeter-sized data. Evaluation is important after switching from a posed action to REST; a stale posed bounding box produced a wrong framing measurement in the earlier bake.

Start the visible variants with core thresholds1.10and1.05m. Review the lower jaw/collar around1.00–1.10m in front, side and turning poses; some lower-face geometry reaches about1.0m, while upper-body fragments extend to1.0556m. A lower hard cut can rigidify part of the collar/shirt, while a higher one can leave jaw vertices on the original mixed binding. The shortest next step is to look at those two variants; adopt a hand-reviewed transition selection only if the seam is visible. These are source-specific coordinates, not a universal auto-rig rule.

A rigid mask fixes shape retention but does not prove that the provider's low Head pivot gives the desired head-turn path. Keep that as a separate posing question. Bone tails from the import's display heuristics are not an anatomical mask: their extreme displayed lengths do not describe the actual hat/head geometry.

## Hands, feet and motion are separate checks

The outer mitten region `|x|>0.69m,0.60<=z<=0.90m` has445vertices, all dominated by the appropriate Hand group; aggregate ForeArm leakage is only0.46%. It does not show the head's widespread shoulder leakage. A wrist transition still crosses Hand/ForeArm influences; do not apply a whole-arm rigid mask merely because the character has mitten hands.

The shoe region `z<=0.16m` has947vertices and substantial Foot, ToeBase and lower-leg contributions. Hand joints sit near `x=+0.621/-0.589,z=0.753/0.761m`; ankle/Foot heads are near `z=0.123/0.133m`, while ToeBase heads sit near `z=0.043/0.042m`. Thus “pin the Foot joint to floor0” would put the ankle on the floor; flattening all shoe weights to Foot would also change toe roll. The current probe does not resolve either repair. Separate stance/sole/contact evidence should choose the target offset and which shoe portion can be rigid.

The root motion investigation independently records the remaining Idle clearance and Walk penetration. A rigid head fix does not solve those, add a natural idle, retarget a different body type, accept a loop seam, or synchronize effects. Build those motion controls against the retained24-bone bind/rest skeleton and judge full-frame-rate footage at the intended camera. The root agent owns those variants.

The independently captured native [leg control probe](../../image-work/character-pilot/iterations/motion-diagnosis/blender-api-evidence.json) exposes another concrete trap: imported LeftUpLeg/LeftLeg world lengths are about19.75/20.16m on a1.90m character, while hip, knee and ankle **head positions** remain about0.20m apart. Do not feed those imported tails directly into an IK chain. A temporary control chain constructed between actual hip/knee/ankle heads can drive rotations onto the unchanged deform skeleton before a visual bake; the source bind/rest matrices should remain intact. This is the motion investigation's control proposal, not a completed grounding repair.

## Verification and limits

The final probe exited0 with its three diagnosis assertions passing. The GLB hash remains unchanged. No paid call, package install, renderer asset replacement, global configuration edit, or new runtime seam occurred. Official Blender pages were read through direct curl after the browser fetch returned402; the Khronos specification was read with browsing. The evidence proves the source of core-head deformation and the minimal binding repair. Collar appearance, hands/feet, skeletal pivot choices and full animation acceptance still need their own visual/runtime evidence.
