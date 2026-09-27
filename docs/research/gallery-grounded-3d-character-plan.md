# Grounded 3D visitor: asset, motion and lighting plan

Research for [#136](https://github.com/Reid-Surmeier/risd-godot/issues/136), 2026-09-26. This supersedes the sprite recommendation in [the earlier character study](gallery-character-motion-options.md). The owner now prioritizes a genuinely three-dimensional, grounded, room-lit character over retaining the generated red-cap identity. No generation, paid calls, runtime changes or commits were made for this report. Research spend: **$0**.

**Choose the CC0 KayKit Rogue GLB for the first grounded-motion prototype, hide its weapons and cape, and use its existing skeletal walk/idle/interact clips. Receive the room’s baked indirect illumination through LightmapGI probes on lit dynamic meshes.** This is a concrete test asset, not a claim of final Animal Crossing likeness. Record the character decision on #136 and finish the separate GameCube shader research before implementation, as the owner requested.

## What the reference actually requires

The supplied `Screenshot 2026-09-26 at 9.49.53 PM.png` shows the current rear-facing red-cap visitor against the parquet: its bright, flat body and small contact blob do not establish a convincingly room-lit volume. A screenshot cannot establish gait timing or prove foot sliding. The next comparison must include movement, turning, stops, shadow contact and changing illumination, not only a rear still.

The GameCube-era Animal Crossing decompilation describes a joint hierarchy with per-joint display-list geometry, translations and animation tables. `cKF_Skeleton_R_c` stores a joint table; `cKF_Animation_R_c` stores flags, data, keys, fixed values and frame count. Its frame controller includes time/speed and stop/repeat modes. These are custom runtime structures, not ready-made FBX or GLB downloads. This is direct implementation evidence for articulated 3D geometry; it does not establish that normal maps are responsible for the look. [Pinned keyframe definitions](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/include/c_keyframe.h).

The player renderer applies a head-angle adjustment in a head-joint callback and calculates foot-mark world positions after joint transformation. That supports reproducing independent head orientation and deriving contacts from animated feet rather than generated image changes. [Pinned player draw implementation](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_draw.c_inc).

The decompilation requires game data supplied separately; its source availability is not a freely redistributable Nintendo character pack. Use it as behavioral evidence. [Project instructions](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/README.md). Nintendo’s [GameCube human promotional reference](https://www.nintendo.co.jp/ngc/gaej/game/chara01.gif) remains useful for head/body proportion and silhouette, not as a downloadable rig.

## Obtainable assets inspected

| Candidate | Actual downloaded contents | Decision |
| --- | --- | --- |
| [KayKit Adventurers: Rogue](https://github.com/KayKit-Game-Assets/KayKit-Character-Pack-Adventures-1.0) | GLB, 3,616,284 bytes; one 41-joint skin; 76 animation entries. Main six body meshes total 4,263 triangles. The full asset includes weapons and a cape. Creator’s pinned license explicitly specifies CC0. | **First prototype.** Large head, short legs, simple eyes and compact hands are useful. Fantasy tunic, belt, boots and braided hair are a visual compromise; no claim that this is an Animal Crossing character. |
| [Tibo’s Godot Plush](https://github.com/gtibo/Godot-Plush-Character) | Downloaded 296,476-byte GLB; 3,384 triangles, one mesh, 16 joints, eight clips: fall, idle, run, tilt_l, tilt_r, up, walk, wave. MIT repository license. | Technically useful fallback with a real wave; robot/plush identity is less suitable for a human museum visitor. |
| [Quaternius Universal Base Characters](https://quaternius.com/packs/universalbasecharacters.html) | Creator offers humanoid base characters, but no archive was downloaded for this study. Current [license page](https://github.com/Quaternius/quaternius.github.io/blob/main/license.html) describes QAL v1.0 while the pack page displays CC0. | Do not silently treat every current download as CC0. Prefer the unambiguous pinned KayKit archive for this experiment. |

KayKit source revision: `672074b73ba276876a19e8816ecdc5241817ab47`. [Exact downloadable GLB](https://raw.githubusercontent.com/KayKit-Game-Assets/KayKit-Character-Pack-Adventures-1.0/672074b73ba276876a19e8816ecdc5241817ab47/addons/kaykit_character_pack_adventures/Characters/gltf/Rogue.glb). [Exact creator license](https://github.com/KayKit-Game-Assets/KayKit-Character-Pack-Adventures-1.0/blob/672074b73ba276876a19e8816ecdc5241817ab47/LICENSE.txt). The creator README advertises 75 animations; **76 is the inspected file count**, including its reference-pose entry, not 76 distinct locomotion behaviors.

| Download | SHA-256 |
| --- | --- |
| Rogue.glb | `e825437cd4d2ee9c1960b517a74a69101e33eb409ae7fa8cedc7134a998fbb7d` |
| KayKit LICENSE.txt | `ae322141814056dda0deea7540d74c41d87aee1da319977cd1bd84ee5a923629` |
| Plush GLB, revision `ea14840084df623a24351b4b2a92e4867b1f913c` | `265f0e525430b62a9530d306319626a4a570f1f40dec05f944b47695ce6228a9` |
| Plush license.md | `5d7ca73d3ecd9d528ff388eee0d75f9ff486349248a2df695a4dbf2773b15a06` |

The Rogue body consists of `Rogue_ArmLeft`, `Rogue_ArmRight`, `Rogue_Body`, `Rogue_Head`, `Rogue_LegLeft`, `Rogue_LegRight`. Keep those; omit `Knife`, `Knife_Offhand`, both crossbows, `Throwable` and `Rogue_Cape` in a derivative. Preserve the untouched original, license, source URL and derivative recipe. It has one embedded color atlas and material; its supplied metallic value is zero. Six separate body meshes can still cost six draws despite one material: measure before considering merging.

## Tool and animation verification

Installed and exercised: `/usr/bin/blender` **4.0.2** and `/home/reidsurmeier/bin/godot` **4.7.2.stable.official.ed1daf0bf**. A separate `/tmp` Godot project successfully imported and instantiated Rogue as a scene with a **41-bone Skeleton3D and 76 AnimationPlayer entries**. No project runtime was modified.

| Clip | Verified duration | Intended first use |
| --- | --- | --- |
| Idle | 1.066667 s | Neutral breathing/rest |
| Walking_A | 1.066667 s | Initial forward walk candidate |
| Walking_B | 1.066667 s | Comparison only if A’s arm action is unsuitable |
| Walking_C | 1.600000 s | Slower comparison candidate |
| Interact | 1.300000 s | Art-inspection hand action; do not rename it “wave” without checking the actual gesture |

Blender evaluation sampled root, feet and toes through Walking_A/B/C, Idle and Interact. The root stayed at `(0,0,0)` in all sampled clips: these are **in-place** animations. For Walking_A, the left toe’s local fore/aft range was approximately 0.513 source units and its vertical range 0.008–0.157; right values were similar. Idle feet were essentially stationary. This establishes animation content and rejects using extracted root translation as the walking displacement. It **does not certify planted world-space soles**: bone positions are not the mesh’s sole surfaces, and a translating controller can still cause sliding.

A temporary CPU-rendered identity was visually inspected at `/tmp/gallery-grounded-character/rogue-inspected.png`: real volume, coherent large head and short limbs, no weapons after hiding the accessory nodes. This was an eight-sample Blender render, not the target Godot/Web renderer or a motion review. Initial Workbench rendering failed because this environment lacked its GL context; CPU Cycles succeeded after disabling unavailable denoising. Do not mistake that render failure for an asset-import failure.

Reproducible local evidence is in `/tmp/gallery-grounded-character/`: untouched GLBs/licenses, parsed GLB JSON, `inspect_blender.py`, `rogue-motion-samples.json`, `blender-inspect.log`, `godot-import.log`, `godot-inspect.log`, and the temporary Godot project. Import inspection command:

```bash
godot --headless --path /tmp/gallery-grounded-character/godot --editor --import --quit
godot --headless --path /tmp/gallery-grounded-character/godot --script res://inspect.gd
```

These temporary files are research evidence, not committed deliverables. Preserve the source/license and necessary checks in the actual prototype when it is authorized to proceed.

## Moving-character illumination in Compatibility/Web

The current `gallery_walk4/bake/prepare.gd:138` explicitly uses `GENERATE_PROBES_DISABLED`; `walk4.gd:303` sets environment ambient energy to zero. **Simply replacing Sprite3D with a lit mesh will not provide the missing spatial lighting data.** The room must be rebaked with probes covering the walkable area, door thresholds and both white test rooms.

Godot’s probe contract requires a dynamic GeometryInstance3D and probes present before the bake. Automatic generation or manually placed LightmapProbe nodes are supported; adding nodes after baking is insufficient. Use `GI_MODE_DYNAMIC` on the visitor’s meshes and lit materials with ambient/lightmap response enabled. [LightmapProbe contract](https://docs.godotengine.org/en/stable/classes/class_lightmapprobe.html).

This is supported by the **installed version’s Compatibility implementation**, not an assumption from Forward+ screenshots. Its GLES3 shader evaluates nine spherical-harmonic coefficients against the world-space surface normal in `USE_LIGHTMAP_CAPTURE`, adding the result to ambient illumination. Thus zero generic environment ambient does not itself prevent probe illumination. [Pinned GLES3 shader](https://github.com/godotengine/godot/blob/ed1daf0bf/drivers/gles3/shaders/scene.glsl#L2499). The GLES3 renderer selects capture when a geometry instance has SH data and uploads the coefficients. [Pinned GLES3 renderer](https://github.com/godotengine/godot/blob/ed1daf0bf/drivers/gles3/rasterizer_scene_gles3.cpp).

The engine samples the probe field at each geometry instance’s transformed AABB center and rotates the SH data; it is a coarse spatial capture, not per-pixel ray-traced lighting. Surface normals still make head, limbs and body respond directionally. Overlapping capture volumes and threshold transitions require inspection. [Pinned scene culling implementation](https://github.com/godotengine/godot/blob/ed1daf0bf/servers/rendering/renderer_scene_cull.cpp#L2061).

The important limit: LightmapGI’s moving-object probes contain **indirect illumination**, not the baked direct-light pool visible on a static floor. A static UV2 lightmap cannot travel with a moving character and remain spatially correct. Web can render previously baked lighting but cannot perform the bake. Retaining runtime lights can supply direct illumination to dynamic objects, but that would reopen the project’s measured performance constraint. [Godot LightmapGI guide](https://docs.godotengine.org/en/stable/tutorials/3d/global_illumination/using_lightmap_gi.html).

**First test: probe-only indirect lighting, no realtime Light3D or shadows.** Bake adequate warm bounce from the lamp regions and neutral/cool ambient contributions in the same offline process as the room. Do not fake a successful probe test with a constant character tint or emissive/unshaded material. If actual lamp proximity remains insufficient after measurement, record that result; a separately specified inexpensive direct-light approximation would be a later decision, not an invisible exception. Retain a small floor contact blob as a depth cue if useful, clearly distinct from illumination and cast shadows. Do not introduce Compatibility-unsupported Decals as the solution.

## Smallest prototype and acceptance plan

1. **Import and scale.** Add the licensed GLB derivative under the gallery prototype, with a Node3D visitor adapter replacing its Sprite3D implementation. Preserve controller/navigation ownership and the existing `pose(...)` / gesture responsibilities; camera orbit must not rotate the model into a billboard. Calibrate the model’s evaluated sole plane to floor height and measure its visible height against the reference camera. Start with the existing 1.75 world-unit envelope, then choose scale from side-by-side images rather than declaring that value correct. Preserve museum layout and all paintings.
2. **Move, stop and turn.** Use real post-collision displacement to advance normalized walk phase. Derive cycle distance from the chosen clip’s stance-foot travel at the final scale, not an arbitrary timer or its toe’s total swing range. Normalize diagonal input. Keep phase continuous through key changes; smoothly rotate the mesh toward travel direction. For sharp reversals, decelerate/turn/reaccelerate rather than letting a stationary planted foot teleport around the root. Blend to idle over a short measured transition and add limited stance-foot correction only if contact tests expose residual sliding. No root-motion extraction for these in-place clips.
3. **Head and hands.** Use the existing head/chest/arm bones. A native AnimationTree can blend locomotion and an upper-body filtered Interact one-shot; aim the head within conservative yaw/pitch limits after evaluating the base pose. Avoid accumulating pose offsets every frame. Movement cancels art inspection, and the feet continue to use the grounded base pose. Godot provides filtered tracks and one-shot blending; a video generator does not supply these skeleton tracks. [AnimationTree documentation](https://docs.godotengine.org/en/stable/tutorials/animation/animation_tree.html).
4. **Probe lighting.** Rebake with a modest automatic probe subdivision plus local probes near lamp regions, portal thresholds and white rooms. Render the same frozen pose at contrasting positions and headings with identical exposure. Compare captures with probe reception disabled as a negative control. Require visible position-dependent illumination, directional shape and continuous doorway transitions; inspect for unlit black limbs, seams between mesh captures, leaking warm light and overbright skin. Repeat in Compatibility and the actual browser export before claiming support works in this scene.
5. **Measure and review.** Keep the new acceptance checks under #136, without changing unrelated frozen module contracts. Capture continuous straight/diagonal walks, key release at different gait phases, repeated left/right and 180° reversals, blocked movement, entrance, both portal roundtrips, and art interaction interrupted by movement. Record stance-sole world displacement and height, not just bone-animation changes. Proposed initial tolerances at 1.75-unit character height: <=0.02 units horizontal stance drift and <=0.01 floor penetration; calibrate contact windows from the clip and visually review them. Empty/static rig and deliberately mismatched cycle speed must fail the motion check. Tie footsteps to observed alternating contacts; silence while blocked/idle. Re-run the existing 23-artwork reachability checks and warm/cold Chrome timing route, reporting median/p95 and a matched-baseline frame-time regression target <=10%. Blind review must inspect actual continuous motion, not certify gait from contact sheets.

Remaining unknowns are explicit: final visual identity; the best walk variant at museum speed; sole-contact correction needed during transitions; actual probe quality/performance in this exported room; and the amount of direct lamp response that can be represented within the no-realtime-light constraint. The verified GLB removes the missing-rig problem. It does not remove those acceptance tasks.
