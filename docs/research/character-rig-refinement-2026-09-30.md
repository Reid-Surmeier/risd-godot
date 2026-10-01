# Character rig refinement: measured remaining defects

Research for [prototype #231](https://github.com/Reid-Surmeier/risd-godot/issues/231), 2026-09-30. The inspected footplant candidate is SHA-256 `536fb839572228d485fc27027a58506944f8285fcfef72f2f8a421e9d73214d9`, [preserved in the prior review commit](https://github.com/Reid-Surmeier/risd-godot/blob/6de38bcca63b8dc6bc7d70b712d2b327d5cdbb79/image-work/character-pilot/iterations/motion-diagnosis/footplant-candidate.glb). Native Blender 4.3.2, factory settings, CPU, no saved model changes and $0 paid calls. This is a diagnosis and a proposal for the next visual loop, not an exact Animal Crossing match.

## Findings that change the next iteration

The largest remaining motion defect is the provider **idle turn**, followed by asymmetric elbow placement and arm paths. The repaired upper head is rigid; the remaining lower-jaw region still has shoulder/arm weights. Neither arm stretch nor a global scale error explains these defects.

| Measured property | Result |
| --- | --- |
| Candidate | 24 bones, 5,640 imported vertices, 7,719 triangles; idle 4.0333333 s, walk 1.0666667 s |
| Walk upper-head rigid-fit RMS, maximum | 0.0067 mm over 129 sampled poses |
| Idle upper-head rigid-fit RMS, maximum | 0.0125 mm |
| Head forward excursion during walk | 6.084° maximum from its initial direction |
| Head forward excursion during idle | **130.045°**, independently confirmed in the original normalized provider idle |
| Idle shortest orientation change between adjacent samples | 18.84° per approximately 31.5 ms; this is not an Euler-angle wrap |
| Arm segment length variation during walk | At most approximately 0.0055 mm |
| Non-root local translation displacement from rest | At most 0.0013 mm after converting parent-local centimeters to world meters |
| All joint deformation singular values | Approximately 0.999959–1.000055 across both clips |

The head-forward check uses the actual `Head`→`headfront` joint-head vector. Idle quarter-cycle vectors point almost +X and then −X, while the start faces −Y. [The existing idle midpoint capture](https://github.com/Reid-Surmeier/risd-godot/blob/6de38bcca63b8dc6bc7d70b712d2b327d5cdbb79/image-work/character-pilot/iterations/motion-diagnosis/quintic-visual/idle-mid.png) visibly corroborates the turn. A second read-only import of `target-baked-normalized-idle.glb` produces the same 130.045° excursion; the footplant/seam repair did not introduce it.

## Arm proportions and a minimum repair

World rest joint heads in meters; **Arm is the upper-arm joint**, ForeArm is the elbow, Hand is the wrist. Shoulder is the medial clavicle joint, not the start of the two-segment arm solve. Blender's API defines `matrix_local` and `head_local` relative to the armature; world positions require the object matrix. [Blender Bone API](https://docs.blender.org/api/4.3/bpy.types.Bone.html#bpy.types.Bone.matrix_local).

| Joint | Left XYZ | Right XYZ |
| --- | --- | --- |
| Shoulder | (0.046192, 0.016425, 0.820255) | (−0.042284, 0.016539, 0.823271) |
| Arm | (0.221416, 0.016854, 0.820255) | (−0.220949, 0.017084, 0.823271) |
| ForeArm | (0.427008, 0.037790, 0.769514) | (−0.474472, 0.038553, 0.782338) |
| Hand | (0.621082, 0.038262, 0.752501) | (−0.588985, 0.037606, 0.760941) |

| Rest segment | Left | Right |
| --- | --- | --- |
| Upper arm | 0.212793 m | 0.257702 m |
| Forearm | 0.194819 m | 0.116499 m |
| Combined reach | 0.407612 m | 0.374201 m |

The right forearm is 40.2% shorter than the left; the right upper arm is 21.1% longer. Rest elbow mirror error is 4.92 cm and wrist mirror error is 3.32 cm. Whole-mesh nearest mirrored surface error is median 1.00 cm and 95th percentile 3.25 cm; this supports approximate visual symmetry, not a perfectly symmetric mesh.

Walk wrist forward/back span is **70.38 cm left versus 49.62 cm right**. Half-cycle mirrored wrist positions differ by 8.83 cm RMS, including the existing torso motion. Segment lengths remain effectively constant, so removing translation or scale channels will not solve this path mismatch.

The smallest useful pose experiment preserves all bind matrices and solves **mirrored wrist targets** with each arm's actual segment lengths. A shared down-pose radius around 0.34–0.35 m is reachable for both arms. A trial forward/back displacement ±0.14 m gives a 0.28 m span, substantially smaller than either current span. Use a reviewed forward elbow pole and bake rotations onto the unchanged deform bones. This is a tunable visual hypothesis, not a measured Nintendo parameter. Merely applying the same rotations to both sides cannot produce matching wrist paths with these unequal segment lengths.

Changing elbow rest positions is a separate rebind operation: glTF skinning combines joint world transforms with inverse-bind matrices. Moving a bind joint without reconciling the inverse bind and existing clips changes the deformation meaning. [Khronos skin specification](https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#skins).

## Head, jaw and upper-body motion

Canonical REST Head pivot is approximately (0, 0.007882, 0.800042), `headfront` is (0, −0.125060, 0.800040), and neck is (0.002482, 0.016328, 0.724117), in world meters. Head rest forward is approximately (0, −1, 0). Walk frame zero Head forward is (0.040871, −0.998421, −0.038529); applying neck deformation to canonical −Y gives (−0.039734, −0.995144, −0.090468).

Use the canonical rest world orientation as an explicit neutral reference for the next idle. The source idle starts already pitched downward about 13.9°, then turns far sideways. A forward-facing idle with small stated trial bob/tilt is a clearer experiment than smoothing its large yaw. Walk is already much more restrained: Head pivot height span 3.84 cm, lateral span 5.48 cm; Hips height span 4.23 cm. Walk Spine world deformation yaw spans 31.82°, neck 18.94°, Head 4.62°. These are candidate measurements, not desired game values. Attenuating torso twist and reviewing arm paths first avoids adding a speculative head lock to a reasonably stable walk.

The remaining crease is not solely faceted source geometry. Fifteen conservative front-jaw vertices with REST z 1.0–1.05 m, y < −0.10 m and |x| < 0.45 m still average Head **75.56%**, shoulders **16.54%** and arms **7.90%**. Their maximum rigid-fit RMS is **3.50 cm walk / 5.38 cm idle**, while the repaired upper head stays within micrometers. The narrower jaw region is intentionally separated from a broad collar mask, which contains shirt/neck geometry and legitimately bends.

The earlier inspected 1.0 m whole-height cutoff moved the transition without clearly improving the shaded jaw band; retain 1.05 m until a **complete anatomical jaw selection** is inspected. Mark candidate lower-jaw vertices in rest front/profile/quarter views, remove shoulder/arm influence only from verified face geometry, and leave the shirt/neck transition as an explicit blend region. Automatic proximity weights can assign overlapping influences that require manual correction; Blender documents this limitation. [Blender automatic weights](https://docs.blender.org/manual/en/4.3/animation/armatures/skinning/parenting.html#with-automatic-weights).

The follow-up dynamic selection test rejected the initially plausible REST selection. The narrow z≥0.95/y<−0.10/Head>0.4 set only covered 29 mouth/front-cheek vertices. A 135-vertex set with z≥0.85 and strict R>G>B included more jaw but tore at frame 24. Coincident-position closure added two vertices and removed the large opening, yet an omitted underside band still folded. Some real underside skin texels have G≈B or B>G, and chin vertices reach below z=0.85; skin color alone was an incomplete classifier.

The final inspected proposal contains **287 additional lower-jaw vertices**: world z 0.82–1.05 m, |x| <0.45 m, current Head weight >0.1, and atlas samples satisfying 0.50<R<0.82, 0.38<G<0.75, 0.30<B<0.68 and R>max(G,B)+0.06. Include **all coincident rest vertices within 10 µm** of this 262-vertex seed, adding 25 seam duplicates. REST front/profile/back markers cover the lower jaw/underside without visible shirt or arm markers. At frame 24, Head=1 removes the major diagonal jaw fold and the failed candidates' black openings; a thin head/collar contact line and source jaw facets remain. The selected-region walk rigid-fit RMS falls from **6.05 cm to 0.0075 mm**. All 95 coincident selected vertex pairs remain closed in the 32 sampled walk poses. Exact union IDs, rest coordinates and original weights are in `/tmp/character-jaw-full-validation.json`; markers `/tmp/character-jaw-full-selection-{front,profile,back}.png`, and explicit before/after views `/tmp/character-jaw-full-frame24-{before,after}-{front,profile}.png`. This is a target-specific reviewed repair proposal; the color rule is not a reusable anatomical classifier. Pure Head=1 guarantees rigidity only for the selected vertices, so the complete result still needs root's new torso/neck animation and runtime inspection.

A copied in-memory idle action keys neutral world Head/neck orientation at each sampled pose so the override survives Blender's render-time animation evaluation. Its 32-pose check also keeps all 95 coincident pairs closed; four inspected profile stills retain a forward-facing rigid jaw with no new opening. This diagnostic still retains the original torso motion and is not root's final neutral idle. Evidence: `/tmp/character-jaw-full-canonical-validation.json` and `/tmp/character-jaw-full-idle-{0,8,16,24}-profile.png`. No model was saved. An earlier unkeyed override was re-evaluated during rendering and is not evidence of a canonical idle.

The 239 left and 260 right vertices with Hand weight >0.9 have maximum walk rigid-fit error approximately 0.55 mm. ForeArm-dominant core error is approximately 2.6–2.8 mm. These errors do not justify making all mittens or forearms rigid; fix the gross arm pose before adding another weight mask. Anatomical hand shape and forearm/mitten proportions remain visual modeling questions.

## Knees, toes and import transforms

Walk knee internal angles range 79.0–145.3° left and 77.5–143.1° right, equivalently about 35–102° flexion. The resulting high bent-knee pose should be reviewed against visible reference contacts after wrist/torso changes. These angles alone do not establish incorrect knee direction.

Foot→ToeBase projected headings are about +8.5° left / −6.8° right, nearly constant through the corrected walk. Their direction also slopes downward about 33–35° because ToeBase lies closer to the sole than Foot; this anatomical vector must **not** be interpreted as a shoe pitched into the floor. Existing sole-plane contact evidence is the relevant ground test.

Mesh and armature object matrices are the same uniform 0.01 scale. Rest evaluated skin vertices differ from their undeformed world positions by at most 0.00027 mm, so there is no measured rest-bind offset requiring transform application. Imported display tails remain unsuitable IK lengths; use actual parent/child joint heads, as the earlier rig diagnosis established. Preserve this matched unit convention when solving poses and exporting.

## Reference evidence and limits

Reviewed the owner's source screenshot and the first 1.6 s of the official GameCube footage from [Nintendo's Animal Crossing page](https://www.nintendo.com/en-gb/Games/Nintendo-GameCube/Animal-Crossing-267719.html), supplied by root from [Nintendo's video asset](https://assets.nintendo.eu/video/private/kg4o3bbt6kagrl1gscnf.mp4). The available video is 350×262 at 25 FPS; the character is roughly 45–60 pixels high, changes direction and has overlapping limbs. Camera movement, projection and occlusion prevent a reliable world-meter arm swing, body bob or rig recovery from these frames. Upscaling increases display size without supplying the missing geometry. Exact screenshot/video matching is not established.

The screenshot also contains a held dark tool with a red handle across the body. That overlap is not evidence of a permanent belt or buckle; the generated body's buckle and repeated back design remain inferred. The generated cap/horns, mitten silhouette, face texture and jaw facets still require visual comparison independent of motion correctness.

Session evidence and reusable read-only probe: `/tmp/character-refinement-probe.py`, `/tmp/character-rig-refinement.json`, and the normalized-provider comparison `/tmp/character-rig-refinement-baseline.json`. The probe samples 129 poses per clip, measures actual joint heads and deformation matrices, converts parent-local displacement into meters, fits proper rigid rotations to vertex regions, and verifies the source hash is unchanged. These temporary files are not accepted runtime dependencies; capture them with the next prototype receipt if the checks are retained. No root scripts, source assets, model files, runtime files or module interfaces were edited by this research.
