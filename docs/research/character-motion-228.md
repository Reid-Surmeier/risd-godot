# Reusable chibi rig, motion and effects

Research for [Research: a reusable chibi rig, motion library and animation effects](https://github.com/Reid-Surmeier/risd-godot/issues/228), child of [Map: repeatable Muse character assets with Blender baking and animation](https://github.com/Reid-Surmeier/risd-godot/issues/226). Investigated September 30, 2026. Spend: **$0**. No provider request, installation, runtime asset change, skeleton replacement or visual acceptance occurred.

## Recommendation and evidence status

**Prove one idle and one walk on one unchanged skeleton before building the animation library.** For the generated pilot, test Meshy's single-rig fal route after the mesh passes silhouette and separated-limb inspection. If its skinning fails, bind the accepted mesh to the local CC0 KayKit skeleton and reuse its clips. Use Rigify when animator controls are actually needed. None of these is yet verified on the supplied horned character, and no candidate becomes the canonical body or skeleton through this research.

Muse supplies identity and proposed unseen views. A T-pose image does not supply joint placement, weights, rest transforms or animation. The decisive artifacts are the skinned mesh and a continuous deformation recording. The map explicitly distinguishes these artifacts and keeps the selected Collection visitor unchanged. [Map Notes](https://github.com/Reid-Surmeier/risd-godot/issues/226)

| Route | Verified interface/evidence | Fit for this pilot |
| --- | --- | --- |
| Preserve KayKit skeleton, bind new mesh | Local 41-joint GLB, 76 animation entries; existing Blender recipe and Godot adapter | Smallest unpaid fallback. Skin weights still require work; its gait is a candidate, not authentic Animal Crossing motion. |
| Native Blender/Rigify | Installed Blender 4.0.2 generated a stock basic-human metarig into a control rig in a background process | Useful for authoring/correcting clips. Generates controls; does not solve mesh quality or skinning. |
| Meshy through fal | Documented GLB-to-rig plus multiple clips on the same rig | Cheapest in effort for a first candidate. Chibi success and cross-character skeleton compatibility remain unverified. |
| Mixamo | Adobe documents browser rigging/library for bipedal humanoids | Manual fallback; giant heads, short limbs and props hit documented restrictions. No publicly supported automation API verified here. |

## What already exists locally

The branch's starting tree is `2b0b015a57670d3e3d0928f43d70e02a05fe6c7d`. A Python parse of the actual GLB JSON chunks reverified these facts; this was file inspection, not a new visual or deformation pass:

| Local file | SHA-256 | Actual contents |
| --- | --- | --- |
| `modules/shell/prototype/gallery_walk4/visitor159/inputs/donor.glb` | `e825437cd4d2ee9c1960b517a74a69101e33eb409ae7fa8cedc7134a998fbb7d` | One 41-joint skin, 76 animations, including `Idle`, `Walking_A/B/C`, `Interact`, `T-Pose`. |
| `modules/shell/prototype/gallery_walk4/identity/visitor_identity.glb` | `8ae841b87653190979e198e43c7cc4aec45c8c6d66d43746d023cc03be1afe5c` | Original prototype skin on 41 joints; 76 animations. It is not the currently selected visitor. |
| `modules/shell/prototype/gallery_walk4/visitor159/inputs/character.glb` | `a2e6e0948dafb5b0ac10ffdc7359c64fbe04371038f0265d9cb1e1af390e54c4` | Two skins with 5 and 36 joints, no embedded animation. The existing Godot acceptance check expects the imported skeleton to contain 42 bones; skin-joint counts are not total skeleton-bone counts. |

The donor's creator-owned [pinned source](https://github.com/KayKit-Game-Assets/KayKit-Character-Pack-Adventures-1.0/blob/672074b73ba276876a19e8816ecdc5241817ab47/addons/kaykit_character_pack_adventures/Characters/gltf/Rogue.glb) and [CC0 license](https://github.com/KayKit-Game-Assets/KayKit-Character-Pack-Adventures-1.0/blob/672074b73ba276876a19e8816ecdc5241817ab47/LICENSE.txt) provide a concrete reusable motion source. Earlier local sampling established `Idle` and `Walking_A` at 1.066667 seconds, `Interact` at 1.3 seconds and a stationary root: they are in-place clips. This session did not resample their evaluated poses. [Earlier measurement](gallery-grounded-3d-character-plan.md)

The selected Hair36 adapter transfers donor rotation deltas relative to source rest, preserving target rest translations, then corrects soles. Its `hip_ratio`, root-height offset, knee pole, phase intervals and gait distance contain target-specific calibration. Its `play_gesture()` always returns false. Do not copy those constants onto a generated character or claim the selected visitor already has wave/look gestures. Its textures/body have separate private-use provenance. [Actual adapter](../../modules/shell/prototype/gallery_walk4/visitor159/visitor.gd), [provenance](../../modules/shell/prototype/gallery_walk4/visitor159/PROVENANCE.md), [acceptance check](../../modules/shell/playtest/visitor174_check.gd)

Existing lessons worth preserving:

- The original authored skin used rigid one-bone weights and could expose shoulder/elbow joins. Import success and animated bones did not prove pleasing deformation. [Identity study](gallery-character-identity-next.md), [Blender recipe](../../modules/shell/prototype/gallery_walk4/identity/build.py)
- Numerical grounding passed while independent visual review still found feet unreadable at the embedded camera. Judge feet and face at gameplay size. [Independent review](gallery-rig-blind-astra-review.md)
- The sole check skins actual vertices; contacts are world-space anchors. The later rendering check displaced contact patches by one metre as a negative control. Reuse these acceptance methods, not only ankle coordinates. Historical reported results are not new proof for this pilot. [Motion check](../../modules/shell/prototype/gallery_walk4/rig/check.gd), [contact evidence](../evidence/gallery-sole-contact/README.md)

## Exact automatable routes

### Meshy/fal

`fal-ai/meshy/rigging/multi-animation` accepts `model_url`, `height_meters`, `animation_action_ids` and the safety flag. It returns a rigged GLB/FBX, basic walk/run files and requested clips against the shared rig. It permits at most ten distinct preset IDs; save request IDs and outputs rather than resubmitting an ambiguous request. This research verified the published schema, not service execution or a quoted price. [fal endpoint/schema](https://fal.ai/models/fal-ai/meshy/rigging/multi-animation/api)

The provider's own requirements sharpen the input gate: textured humanoid GLB, clear limbs, face toward **+Z** when supplying `model_url`; other facing directions can fail pose estimation. Untextured and unclear-body models are unsuitable. The generated screenshot's giant head and compact legs still need a real trial. [Meshy rigging requirements](https://docs.meshy.ai/en/api/rigging)

Smallest proposed payload after that gate:

```json
{
  "model_url": "PUBLIC_TEXTURED_PILOT_GLB_URL",
  "height_meters": 1.75,
  "animation_action_ids": [0],
  "enable_safety_checker": true
}
```

`1.75` is an explicit proposed study height, inherited from existing local checks, not the character's true scale. ID `0` is `Idle`; `30` is `Casual_Walk`. Start with idle plus the basic walking output. If that basic walk is unsuitable, consider `30` only after inspecting it. The generic fal examples `[36,92]` request `Confused_Scratch` and `Double_Combo_Attack`, not idle/walk. [Current official catalog](https://docs.meshy.ai/en/api/animation-library)

A creator-owned implementation does exist: `blendi-remade/fal-3d-unreal`, pinned `454f56defb0f53f589bd870d6129701651b8f4dc`. Its [rig client](https://github.com/blendi-remade/fal-3d-unreal/blob/454f56defb0f53f589bd870d6129701651b8f4dc/fal3DDemo/Source/fal3DDemo/FalRigClient.cpp) submits one rig request and attaches IDs to returned clip URLs. Its [character code](https://github.com/blendi-remade/fal-3d-unreal/blob/454f56defb0f53f589bd870d6129701651b8f4dc/fal3DDemo/Source/fal3DDemo/fal3DDemoCharacter.cpp) loads clips onto the rig but includes per-motion size corrections, a 100x import compensation and direct single-animation switches. Source was read through GitHub's API. This proves an implemented integration route, not a solved chibi asset pipeline. Do not inherit its scale patches or assume smooth blending/contact quality.

### Native Blender

In the installed Blender **4.0.2**, an unpaid background probe enabled Rigify only in that process, added `armature_basic_human_metarig_add`, then called `pose.rigify_generate`. Result: **29 metarig bones → 222 generated bones, 35 marked deforming**. No file or preferences were saved. Rigify generates animator mechanisms/controls; mesh binding remains separate. Its basic-human preset is a starting shape, not correctly fitted to this character. [Rigify's first-party explanation](https://docs.blender.org/manual/en/5.3/addons/rigify/introduction.html), [installed Rigify operator source](/usr/share/blender/scripts/addons/rigify/ui.py)

Recommended native sequence: fit one existing deform skeleton to the accepted body; bind the body with automatic weights as an initial pass; inspect and correct joints. Rigid head/hat/horns can follow the head with deliberate weights, while torso/shoulder/elbow/knee transitions need graded weights and sufficient geometry. Keep held tools out of the rigging payload and attach them later. If manual animation needs IK controls, fit a saved Rigify metarig to the same accepted proportions and bake back to the chosen deform skeleton. This is a proposed procedure; no new body's weights were tested.

Blender MCP should execute the existing Blender Python API recipe, not act as a new rigging algorithm. Availability of Rigify, bake and GLB export was tested locally; a connected MCP session and deterministic invocation remain the tooling investigation's responsibility. No Mixamo HTTP endpoint should be inferred from browser network calls. Adobe's first-party documentation confirms humanoid restrictions, rejects heavily deformed proportions/large appendages and recommends a clean centered neutral mesh. [Adobe FAQ](https://helpx.adobe.com/creative-cloud/faq/mixamo-faq.html)

## Rest pose, deformation and reusable clips

For the proposed new asset contract, standardize **metres, Y-up, +Z facing, T-pose, identity object transforms**, origin on the floor between soles. Blender authoring is Z-up; its installed exporter maps `(x,y,z)` to `(x,z,-y)`, so Blender **-Y facing** becomes glTF +Z with `export_yup=True`. Apply rotation/scale before skin binding; changing them afterward requires rechecking bind matrices. `export_apply` applies mesh modifiers and is not an object-transform normalization switch. [Installed conversion source](/usr/share/blender/scripts/addons/io_scene_gltf2/blender/com/gltf2_blender_math.py:82), [exporter definitions](/usr/share/blender/scripts/addons/io_scene_gltf2/__init__.py:402)

Bone names alone do not establish clip compatibility. Godot's import retargeter uses `BoneMap`/`SkeletonProfileHumanoid`; its profile expects T-pose, Y-up/+Z forward, joint-local +Y toward the child and +X for contraction. Rotation/rest reconciliation and position-track normalization matter. Hips height controls normalized motion scale; a giant head's total height is a poor proxy for leg stride. Unimportant position tracks can distort a different body if retained. Axis overwrite and silhouette repair can damage a authored rest or feet; do not turn them on blindly. Shared bone-only libraries and accessory scenes need different remove-track choices. [Godot retarget contract](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/retargeting_3d_skeletons.html)

After the first rig passes, capture one skeleton fingerprint: names, parents, rest transforms, inverse binds, forward axis and units. Keep future characters on that exact template where proportions allow. A new provider rig per character has no verified guarantee of an identical fingerprint. For changed proportions, retarget and bake once onto the chosen target; then evaluate contacts. The local adapter demonstrates why scaling hip motion does not by itself solve knee direction or neutral stance.

Proposed deformation proof: head yaw/pitch, arms from T to sides and forward, elbow bend, knee lift, planted support and crouch. Inspect front/profile/back and the gameplay camera. Reject fused limbs, head-following shoulder vertices, collapsed knees, inverted knees, shoulder seams, hat/hair clipping and unexplained size changes between clips before expanding the library.

## Animation baking and GLB transfer

The installed `bpy.ops.nla.bake` exposes `frame_start`, `frame_end`, `step`, `only_selected`, `visual_keying`, `clear_constraints`, `clear_parents`, `use_current_action`, `clean_curves`, and `bake_types`. Its implementation keys final evaluated transforms when `visual_keying=True`. Bake on an export copy; preserve the editable rig and unbaked actions. The available API was checked, but no pilot animation was baked. [Installed bake implementation](/usr/share/blender/scripts/startup/bl_operators/anim.py:219), [evaluation helper](/usr/share/blender/scripts/modules/bpy_extras/anim_utils.py:117)

Proposed recipe: name target actions `Idle`/`Walk`; sample every frame at a recorded FPS; visual-key target bones; remove constraints only on the copy after bake; export the selected deform armature and mesh with `export_animations=True`, `export_animation_mode='ACTIONS'`, `export_force_sampling=True`, `export_frame_step=1`, `export_yup=True`. Rigify export may use `export_def_bones=True` with sampling, but verify required root/parent joints survive. Avoid scene mode unintentionally joining clips and avoid flattening hierarchy without evidence. Export flags and modes were queried on 4.0.2. [Installed exporter](/usr/share/blender/scripts/addons/io_scene_gltf2/__init__.py:435)

Reimport into scratch Blender and Godot; compare clip duration, poses, skeleton fingerprint, textures, evaluated bounds and both soles. Constraints/drivers and the editable control rig are authoring tools; the GLB proof must contain evaluated animation. Keep the high mesh, final low mesh, bind and UV layout stable through material baking. Texture baking does not repair a rig.

## Godot locomotion, interactions and effects

An isolated headless probe of **Godot 4.7.2** confirmed `AnimationTree`, `LookAtModifier3D`, `TwoBoneIK3D`, `SpringBoneSimulator3D`, `BoneAttachment3D` and `CPUParticles3D` exist. This verifies API availability, not the pilot's visual/performance quality.

Keep navigation/controller displacement authoritative for in-place clips. Advance gait from actual post-collision travel, not key-down time. Measure cycle distance from a stance sole's travel at final proportions; blocked movement must not advance footsteps. Start/stop can initially use two clips and a measured blend; turns can use eased facing plus calibrated stepping. Separate authored start/stop/turn clips only become necessary if that result fails visual review. Never extract displacement from a stationary root. For a later root-motion clip, remove its visual displacement and feed the extracted delta to collision movement once. [Root-motion API](https://docs.godotengine.org/en/stable/classes/class_animationtree.html), [local motion implementation](../../modules/shell/prototype/gallery_walk4/visitor159/visitor.gd)

Native `AnimationTree` supports locomotion blending, state transitions and a filtered upper-body `OneShot`. Start from idle/walk with a `TimeScale` or explicit phase, then add one interaction only after locomotion survives stops/reversals. Preserve deterministic rest/`RESET` values for properties absent from some clips. Do not promise that layering a hand action leaves planted legs unchanged without an actual test. [AnimationTree guide](https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html)

| Effect | Smallest proposed route and failure gate |
| --- | --- |
| Head look and hands | Limit head yaw/pitch with native [LookAtModifier3D](https://docs.godotengine.org/en/stable/classes/class_lookatmodifier3d.html); filter one hand gesture to upper-body tracks. A held tool follows [BoneAttachment3D](https://docs.godotengine.org/en/stable/classes/class_boneattachment3d.html). Reject head/hat clipping and unintended hip/foot changes. |
| Foot contact | Existing world-space sole checks first; native [TwoBoneIK3D](https://docs.godotengine.org/en/stable/classes/class_twoboneik3d.html) is available and requires a pole. Short legs need target-specific knee direction and reach limits. Retain the proven local solver until a comparison justifies replacement. |
| Secondary motion | Later, a small [SpringBoneSimulator3D](https://docs.godotengine.org/en/stable/classes/class_springbonesimulator3d.html) chain for soft hair/cloth, not a full-body ragdoll. It returns toward the animated pose and does not support branched chains. Test low FPS and teleports. The docs explicitly warn that scaled skeletons/bones misbehave. |
| Squash/stretch | Start with baked restrained torso/head motion; inspect soles and silhouettes. Do not scale the entire skeleton while expecting spring behavior to stay correct. Treat localized squash and spring compatibility as a later visual decision; rigid horns/tools should retain shape. |
| Face | For this visual style, propose a small blink/mouth texture set before a facial rig. If expression geometry needs morphs, Godot supports blend-shape animation tracks. No facial output is guaranteed by the humanoid rigging API. [Animation track types](https://docs.godotengine.org/en/stable/classes/class_animation.html) |
| Footsteps/dust/interaction sparks | Emit once on an actual alternating support transition, gated by movement and grounding; suppress on idle/blocked motion and reset after teleports. Imported GLB bone motion does not invent gameplay event callbacks. Godot supports method/audio tracks; simple dust may use [CPUParticles3D](https://docs.godotengine.org/en/stable/classes/class_cpuparticles3d.html). Existing `walk4.gd` already consumes `_kid.contacts`; reuse that model. New production audio behavior must respect `sound_cues`' frozen interface. [Existing event consumption](../../modules/shell/prototype/gallery_walk4/walk4.gd:2787) |

Skeleton modifications run after animation evaluation; measure final feet after contact/secondary modifiers rather than before them. Avoid pose-offset accumulation frame to frame. [SkeletonModifier3D ordering and signal](https://docs.godotengine.org/en/stable/classes/class_skeletonmodifier3d.html)

## First motion proof and stop conditions

1. Validate one textured T-pose mesh: silhouette, clear limbs, final height, axes and identity transforms. Record fingerprints and provenance before one rig request or native bind.
2. Show the same rig in idle and walk, front/profile/back, no spring/squash/prop effects. Inspect head size, knees, shoulders and all soles. Record continuous motion at the actual gameplay camera too.
3. Exercise straight/diagonal movement, blocked movement, starts/releases at several phases, 90/180-degree turns and teleport reset. Check skinned sole vertices. Proposed inherited tolerances at 1.75 m: horizontal stance drift ≤0.02 m and floor penetration ≤0.01 m; calibrate support windows to this clip rather than copying Hair36's values.
4. Require matching character scale/rest/skin across clips, readable alternating foot support, no contact event while idle/blocked and no duplicate event on loop crossing. A static skeleton and deliberately wrong stride must fail the check. Pictures alone do not settle motion.
5. If skin, silhouette, scale or contacts fail, repair that cause before buying gestures. After idle/walk survives, add one upper-body action, one prop, blink, a tiny contact effect, then secondary motion/squash separately. Owner reaction to actual evidence selects the reusable template.

Research resolves the route and acceptance method. It does **not** resolve the visual choice of canonical skeleton, certify provider rig quality on this character, establish a production animation library or replace the accepted visitor.
