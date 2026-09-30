# Character motion: contact, loop, look direction, and gameplay camera

Research for map #226 and pilot #231, 2026-09-30. This follows [the earlier route comparison](character-motion-228.md). Cost: $0. Provider originals and prior proof are preserved. The new measurements and throwaway candidate live in `image-work/character-pilot/iterations/motion-diagnosis/` on the prototype branch; no runtime module changed.

## What the existing asset actually does

Native Godot 4.7.2 sampled the normalized GLB (`9d566ae7413d209f9986b1ff53d486ba3535a59f498d686f169d7257e21cc804`) at 65 times including both endpoints. CPU skin evaluation uses imported inverse binds, current bone global poses, mesh weights, and the skeleton object transform. Feet are the vertices with more than 50% combined corresponding Foot/ToeBase weight. This is a reproducible shoe estimate, not a contact sensor. `probe.gd`, `run.py`, and `evidence.json` contain the implementation and all samples.

- The 24-bone walk lasts 1.066666722 seconds: 32 intervals at 30 FPS. Exact endpoints already agree to 0.90 micrometres maximum skinned-vertex displacement. Changing the period does not fix its ground contact.
- Dense sampling finds left/right minimum shoe Y of −0.08836/−0.09178 metres relative to the rest sole plane. These correspond to 7.34/7.68 cm penetration relative to the old review plane, which was placed 1.5 cm below that rest plane. The previous eight-pose review found only 3.6–6.0 cm penetration: it did not include these worst phases.
- The left shoe remains below the rest plane throughout. The right shoe reaches +1.28 cm at its highest sampled phase. Shoe centroid forward travel spans 52.87/47.87 cm. A global root lift can remove penetration, but cannot flatten a stance interval or match foot travel to controller motion.
- Idle normalization removed the uniform 17.6% size jump but left floating soles. Shoe weights leak outside Foot/ToeBase; the root agent separately measured and repaired head weights. Treat weights and motion as separate inputs to contact.

These findings are verified observations of this specific GLB. They are not acceptance of the mesh silhouette, joint deformation, or animation style.

## Smallest portable correction, and why direct imported-bone IK fails

The first Blender 4.3.2 API probe found correct joint heads but very long imported display tails: left thigh/shin lengths were 19.75/20.16 **metres**, while adjacent joint heads are approximately 20 **centimetres** apart. `blender-api-evidence.json` records both. Consequently, an IK constraint using those existing tails solves the wrong lengths. Changing their rest matrices or binding a new skeleton would hide the actual problem.

Two viable approaches retain the original 24 deform bones:

1. Create temporary two-bone control chains from actual hip, knee, and ankle **head positions**, then copy their solved rotations into the deform bones before visual baking. Put targets at the ankle height above the sole, not at ground level. Use `chain_count=2`, `use_tail=True`, `use_stretch=False`, a forward knee pole, and a separate Foot rotation target. These properties were verified in installed Blender 4.3.2. Blender's [IK manual](https://docs.blender.org/manual/en/latest/animation/constraints/tracking/ik_solver.html) documents chain length, target, pole, stretch, and solver ordering.
2. Solve those same two joint segments analytically and key the evaluated local poses directly. This needs no control-bone export and avoids reliance on bad display tails. Godot's [TwoBoneIK3D](https://docs.godotengine.org/en/stable/classes/class_twoboneik3d.html) uses joint locations in a deterministic two-circle solver; it requires a pole and warns against a collinear pole/forward direction. A runtime version still needs ground queries and a world-space contact state.

The implemented throwaway `correct.py` uses the second route. It retains every bone name, parent, and rest matrix exactly; rigidifies target-specific shoe vertices at rest height ≤20 cm to their Foot joint; keeps the source mesh positions, topology, and atlas; and consumes the root's separate `rigid-head.glb`. That height classifier is a pilot-specific choice requiring visual inspection, not a reusable asset segmentation rule.

The candidate intentionally contains corrected idle and walk only. Base/run remain in the original library. The walk controller contract is forward **+Z at 0.52 m/s**, duration **32/30 seconds**. Left stance is phase `[0.25,0.75)`; right stance is `[0.75,1.25)` across the wrap. Stance local forward travel compensates controller movement; swing uses an 8 cm smooth arc. The pelvis is lowered only when required to keep short legs reachable, with a small reach margin. This replaces generic leg motion with a measured chibi candidate; it does not claim that a generated generic gait was already correct.

For a planted foot, `world_sole(t) = root_world(t) + local_sole(t)` must remain constant during stance. Holding the **local** target constant while translating the actor makes the shoe slide. Turning, slopes, obstacles, different speeds, and locomotion blends require re-anchoring world targets or a runtime IK pass; this planar baked proof does not verify them.

## Baking and preserving the actual period

Blender's [visual bake implementation at v4.3.2](https://github.com/blender/blender/blob/v4.3.2/scripts/modules/bpy_extras/anim_utils.py) reads the final pose and converts it from pose space to local bone space. This is what must be baked when constraints or modifiers produce the visible motion. `bpy.ops.nla.bake` on the installed build exposes frame start/end, step, visual keying, constraint removal, pose/object selection, and channel selection. Clear temporary constraints only on the export copy.

For this walk, the logical period is **0 through 32 inclusive at 30 FPS**: 32 time intervals and one duplicated terminal pose. The final candidate evaluates **0–64 at 60 FPS**, keeping exactly the same duration while improving interpolation between solved poses. Exporting only 0–31 shortens the motion. For idle, preserve **121/30 seconds**. The original idle also had a measured 2.21 mm geometric seam; the derived candidate explicitly duplicates its initial pose at the true terminal time.

`export_force_sampling=False` preserves the explicit baked curves in this tested exporter. Do not use it on an unbaked constraint rig. Blender's [glTF manual](https://docs.blender.org/manual/id/5.0/addons/import_export/scene_gltf2.html) warns that disabling sampling can export motion incorrectly. The pilot already observed a shortened duration when exporter sampling was allowed to define the range. The reliable gate is the imported Godot duration plus evaluated endpoints, not an export flag alone.

The imported clips have `loop_mode=LOOP_NONE` despite their cyclic geometry. Set looping deliberately in the player/import configuration. For endpoint measurement, use an independent copy with looping disabled so a seek to the exact duration does not merely wrap to zero. Godot's [Animation API](https://docs.godotengine.org/en/stable/classes/class_animation.html) exposes length, loop mode, interpolation, and key times.

A geometric seam test measures maximum/RMS skinned displacement and all joint transforms. A velocity seam test measures adjacent one-sided intervals as well. Matching endpoints establishes positional continuity, not smooth velocity. The provider's first body pose is held for an initial frame; the candidate tests resampling its moving source frames 1–32 over the unchanged 0–32 period. This changes body phase slightly, while preserving foot timing. The final candidate also makes the local translation/quaternion/scale tangents symmetric across the seam for every bone, after the leg solve. Swing uses quintic Hermite forward travel whose endpoint derivatives match stance travel and whose endpoint acceleration is zero, rather than smoothstep endpoints that stop suddenly at contact. Native velocity evidence remains recorded separately; do not label all motion seamless from a position-only result.

`validate.py` checks both candidate clips at 257 poses in isolated temporary Godot projects: 24 bones, original periods, <1 mm geometric endpoint error, <1 mm sampled stance floor error, and <1 mm sampled stance drift under the declared controller movement. Candidate verification measures vertices with >99.99% Foot weight; the raw diagnostic retained its broader Foot+ToeBase definition. It unwraps the right contact across the cycle. These are planar numerical gates; root-owned continuous films and owner reaction determine visual acceptance.

## Verified candidate and import precision requirement

The final candidate is `footplant-candidate.glb`, SHA-256 `c827ab8bb681c4e4d146c6f4407802b36dbf67dc61150f72d16faffdc254d96f`, generated from root rigid-head source `0f609ee4dfd7d0e645a15dbd8b47625dd95b0c13c4b59b624deecdd2eddeb487`. `correct.py` reproduces it in Blender4.3.2 and saves a compressed editable `.blend`; `validate.py` reproduces the portable Godot measurements. The numerical result is:

| Gate | Idle | Walk |
| --- | --- | --- |
| Imported seconds | 4.033333302 | 1.066666722 |
| Sampled stance sole error, max | 0.060 mm | 0.494 mm |
| Sampled stance world X/Z drift, max | 0.129 mm | 0.311 mm |
| Endpoint skinned displacement, max | 0.359 µm | 0.100 µm |
| Maximum joint velocity difference, one-sided 1 ms intervals | 0.0249 m/s | 0.00939 m/s |

The shrinking-delta final walk velocity check gives0.09451,0.02835,0.00939,0.00300m/s maximum joint difference for10,3,1,0.3ms respectively, supporting a matched loop tangent. A bounded cubic→quintic swing comparison reduced contact-boundary ankle velocity changes from0.196/0.201 to0.0701/0.0670m/s under native30fps interpolation while preserving stance gates. The final swing lift is `64 * height * u³ * (1−u)³`, retaining its8cm peak and zero endpoint velocity/acceleration. `quintic-comparison.json` preserves both candidate SHAs and metrics; native45degree poses were inspected without obvious new joint detachment in the shown views. These sampled pictures do not replace continuous visual acceptance. Do not claim every contact derivative is smooth from the loop test.

The ordinary Godot import optimizer discarded compensation keys: a 485-key exported idle Foot rotation became 106 keys. That produced more than 1 mm drift despite the analytic solver residual being below 0.05 µm. Native verification passes only after preserving import precision. The supported setting is on the **AnimationPlayer subresource**, not a top-level `animation/optimizer/enabled` property. Godot's [scene importer implementation](https://github.com/godotengine/godot/blob/master/editor/import/3d/resource_importer_scene.cpp) applies `optimizer/enabled` from the animation-node settings; its default is true. The installed importer was empirically verified with this exact sequence:

1. Import the GLB normally to create its `.import` metadata.
2. In `[params]`, set `_subresources={"nodes":{"PATH:AnimationPlayer":{"optimizer/enabled":false}}}`. For a differently named/path player, use its actual import node identifier. Advanced Import Settings → AnimationPlayer → Optimizer → Enabled off is the UI equivalent.
3. Delete only this disposable project's corresponding `.godot/imported/target.glb-*` files and reimport. Preserve the imported metadata in review evidence.
4. Keep `animation/fps=30` for the tested setting. The importer resamples the denser GLB animation at this FPS even when source bake FPS is60.

This is a per-asset precision requirement to carry forward if the candidate is accepted. Do not silently optimize the curves again without repeating the contact checks. A future asset-specific optimizer may reduce data while preserving world-space shoe residuals; that is not verified here.

Root's earlier AnimationPlayer 0.2 s blend trial reported 16.17 mm penetration on the preceding candidate. Independent planted source poses do not guarantee a planted interpolated pose. Recommendation for this prototype: record unclamped penetration, apply an additional visual-root lift only during the blend, and record the resulting floor clearance; disable contact dust during that interval. A lift is penetration prevention, not stance lock. A proper later contact-preserving transition solves shared world-space foot targets **after** blending. Root owns the final continuous blend and event proof, and the owner's visual acceptance remains pending.

## Head look uses the measured axis

The rest-space Head→headfront direction expressed in Head local coordinates is approximately `(0.031415, 0.167491, 0.985369)`. It is near +Z but tilted about 9.8° upward, rather than exact local +Z. The measurement uses bone rest transforms, independent of a guessed Blender Euler axis.

Godot's [LookAtModifier3D](https://docs.godotengine.org/en/stable/classes/class_lookatmodifier3d.html) aims a selected local axis. It can work relative to the animated pose or replace it relative to rest; parent modifiers must precede child modifiers. Its `duration` handles documented target changes/axis flips, so it should not be assumed to smooth every continuous target update. Recommendation: preserve the measured face-forward offset, start with limited yaw/pitch, and test a front/up/right target trio. Do not use a moving child attachment as the look origin, because its own displacement feeds back into the solver. This note does not implement or verify runtime head look.

## Camera: a source-supported default, not screenshot calibration

The source PNG was inspected. It shows an outdoor ground plane, tree tops, and a character from above. The old asset proof's camera offset was `(-0.55,0.25,2.5)`, giving only **5.58°** elevation; it was an inspection camera.

Animal Crossing's [camera source pinned to 09ca8e8](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_camera2.c#L431) supplies normal direction −135°. Its [polar conversion](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_camera2.c#L78) adds 180° and evaluates sine/cosine, yielding a **45° downward view**. The [initial perspective](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_camera2.c#L2625) uses **20° vertical FOV**, 4:3 aspect. Outdoor swing and adjustment routines can change the normal pose.

Recommendation: first try 45° depression, 20° perspective, 4:3 framing; fit camera distance to character/ground scale. Compare 35° and 55° only if the silhouette or face reads poorly. Orthographic is a useful controlled comparison but is not the source's default projection. No single screenshot determines exact camera distance, pitch, and projection uniquely; the constants above are a verified game default, not a calibration of this screenshot. Include a visible ground patch and shoe contact when comparing cameras.

## Dust is a contact event, not a particle timer

The candidate's event manifest specifies Left at **8/30 s** and Right at **24/30 s**; expected rate is two events per loop, **1.875 events/s** at speed 1.0. Emit at the sole's world contact position, then leave the particle burst in world space as the shoe advances. Idle should emit zero events. A slowed clip should slow event cadence with its phase; a stationary character should not keep emitting walk dust.

Godot [Animation method tracks](https://docs.godotengine.org/en/stable/classes/class_animation.html) can carry those events. The existing fixture proved one authored callback/particle burst and no idle repeats; it did not establish physical contact. [AnimationPlayer seeking](https://docs.godotengine.org/en/stable/classes/class_animationplayer.html) skips intermediate events, so seeking samples is not an event-rate test. Root's continuous proof must play multiple loops and check counts.

Recommendation: represent event crossings over unwrapped phase, each once, including wrap and a large delta. Do not put the same event at both time 0 and duration. On entry to idle, freeze/clear the walk event source. Test three complete loops after a defined entry phase: six events, alternating feet, plus zero in subsequent idle. A teleport or re-anchor should reset outstanding contacts rather than emit a backlog. Dust can pass its event-count test while contact fails; preserve both results separately.
