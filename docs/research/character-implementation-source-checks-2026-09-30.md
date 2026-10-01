# Character implementation source checks — 2026-09-30

Implementation support for [issue 231](https://github.com/Reid-Surmeier/risd-godot/issues/231). Inspected narrow public source files pinned to ACreTeam/ac-decomp `09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c`; reused the existing decoder, without a ROM, original mesh, paid call, or dependency install. This is a community reconstruction, not a captured console execution. The 60-update assumption below remains separate from footage encoding rate. See the [full controller audit](character-locomotion-fidelity-audit-2026-09-30.md) for calibration limits.

## RUN and transition implementation

RUN1 is authored in the same file as WALK1 and DASH1. It spans source frames 1–17, hence 16 phase intervals. The existing decoder already supports `--animation run1`; no new parser is needed. This pass decoded 129 samples and asserted 26 source joints. The reconstructed RUN root Y spans 1000–1175 model units. Source scale, skeleton proportions, actor transform and camera registration must be handled separately. [Authored RUN arrays](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/data/model/player_anim.c#L92-L136), [decoder](character-video-reference/decode_walk.py).

```bash
python3 docs/research/character-video-reference/decode_walk.py \
  --source-dir /tmp/character-fidelity-source --animation run1 \
  --output /tmp/character-fidelity-source/run-implementation-analysis.json
```

RUN delegates movement, cadence and surface effects to WALK. Gait setup retains the outgoing keyframe's current source frame. Keep one shared phase through WALK/RUN/DASH switches; selecting a new clip and starting it at zero loses this property. Source morphing also advances against the incoming pose, so a generic crossfade is an adaptation. [RUN setup/delegation](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_main_run.c_inc#L16-L59).

At 60 updates/s on aligned flat ground, computed cadence candidates are:

| Source velocity | Phase/update | Full cycle | Target actor lean |
| --- | ---: | ---: | ---: |
| 3.525, WALK/RUN threshold | 0.411339 | 0.648289 s | 0.215584° |
| 4.875, ordinary full input | 0.483735 | 0.551266 s | 1.508377° |
| 7.5, held dash | 0.600000 | 0.444444 s | 19.999984° |

Cadence is `max(.22, .59999996 * sqrt(velocity/7.5))`; cycle is `16/(60*cadence)`; lean is `min(20,20*(cadence²/.36)^6)`, eased separately. Source RUN→DASH selection uses `cadence²/.048 >= 4.875`; binary32 reconstruction puts ordinary full input just below that equality. Therefore RUN is the safer ordinary full-input candidate. These values are formulas, not accepted meters/second or footage measurements. [Cadence](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_main_walk.c_inc#L78-L105), [gate](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_main_run.c_inc#L95-L103), [lean](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_common.c_inc#L2165-L2188).

## Heading, velocity and skid

At full input, turn fraction is `1-sqrt(.5)`, with wrapped signed-16-bit angular error, integer truncation, minimum step 50 and maximum 2500 binary-angle units per update. Below full input, compute `mod=.01` at magnitude ≤.05, otherwise `.01+.5157895*(magnitude-.05)`, then fraction `1-sqrt(1-mod)`. Target velocity is 4.875 or 7.5 times input magnitude, multiplied by `max(cos(input-heading_error),0)`. Acceleration is .60899997/update, braking .32625002/update. Translation follows actor heading, at half its velocity per update. Reproduce this coupling rather than moving immediately along input while rotating the mesh afterward. [Movement](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_main_walk.c_inc#L131-L194), [integer angle helper](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_lib.c#L554-L593), [translation](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_actor.c#L43-L62).

DASH requests TURN_DASH at angle error ≥18204, about 100°. Its helper compares actor yaw against `90° + controller_move_angle`; preserve the input convention when adapting this threshold. TURN_DASH uses **RUN_SLIP1, a static two-frame pose**, not a 17-frame locomotion loop. It brakes .261/update along the old actor heading while turning visual shape yaw separately. It returns to WAIT only after both zero velocity and completed visual turn; on settle it copies shape yaw into actor yaw. It also emits turn effects and a slip sound. Do not substitute a longer RUN loop and label it the source skid. [DASH request](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_main_dash.c_inc#L178-L186), [angle convention](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_common.c_inc#L2261-L2269), [TURN_DASH](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_main_turn_dash.c_inc), [static pose](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/data/model/player_anim.c#L851-L861).

## Carried-tool layer

The per-joint table selects locomotion layer 0 versus tool layer 1. Zero-indexed source skeleton masks are **axe 14–20**, **net/pickup 17–20**. Base translation stays with locomotion. AXE1 and NET1 are static two-frame arrays: parse three root translation values followed by 26 XYZ triples, then multiply rotation values by .1°. Compose in the source rest basis before retargeting; directly assigning these Euler angles to differently oriented target bones is incorrect. Hand joint 20 is an item attachment transform, not automatically identical to the generated RightHand bone. The hand/item callback retains its matrix. [Masks](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/data/player/BOY_part_data.c#L43-L132), [axe pose](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/data/model/player_anim.c#L81-L90), [net pose](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/data/model/player_anim.c#L1292-L1301), [attachment callbacks](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_draw.c_inc#L80-L137).

| Joint | Axe XYZ degrees | Net XYZ degrees, applied only 17–20 |
| --- | --- | --- |
| 14, LeftShoulderBase | 0,0,-90 | excluded |
| 15, LeftUpperArm | 30,-15,-65 | excluded |
| 16, LeftForearm | 0,-80,0 | excluded |
| 17, RightShoulderBase | 0,0,90 | 0,0,90 |
| 18, RightUpperArm | -30,-40,71 | -30,-13,32 |
| 19, RightForearm | 0,-80,0 | -80,-129,104 |
| 20, hand | 92,30,-13.5 | 47.5,-35,-24.5 |

The screenshot's tool identity remains unresolved. Expose explicit unarmed/axe/net review choices rather than claiming one inferred tool is correct. Rod movement has a distinct item route. [Moving-item selection](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_common.c_inc#L3936-L3951).

## Face and effects

Normal blink scheduling uses `pattern=[0,0,0,0,1,1,2,2,2,2,2,2,1,1,0,0]`, a countdown index, random 60–120-update intervals and 0–3 repeat counts. Traverse the countdown rather than blindly playing the table forward; at 60 updates the 16-update blink sequence is about .267 s and gap 1–2 s. Head prerender applies additional X/Y angles, but this narrow source set contains no verified writer of `head_angle`. Avoid invented moving gaze labelled as original behavior; animation curves plus an explicitly marked interaction adaptation are reviewable. [Blink](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_common.c_inc#L900-L931), [head callback](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_draw.c_inc#L1-L15).

Foot events are source phase 0 and .5, at source frames 1 and 9, from recorded left/right foot matrices. WALK/RUN ordinary grass has no generic dust. DASH dry terrain creates white textured dust, indoor floor none, sand a sand splash, water/rain a water splash, winter grass snow and bushes leaves/snow. Dust argument 8 begins backward velocity −2 and upward +1 with acceleration `(0,-.05,.075)` in source effect units/update; timer 18 means about .30 s under 60. New procedural textures or synthesized footsteps are adaptations, not recovered Nintendo assets. Suppressing births while physically blocked is a deliberate demo improvement that must not be presented as a measured source collision trace. [Foot schedule](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_main_walk.c_inc#L108-L128), [WALK effects](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/effect/ef_walk_asimoto.c), [DASH dispatcher](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/effect/ef_dash_asimoto.c#L43-L155), [dust](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/effect/ef_dust.c#L57-L141).

## Verification and limits

The RUN decoder command passed its complete channel-consumption and 26-joint assertions. Tool arrays each contain 81 signed scalar entries; the values above were extracted with an 81-entry assertion. Timing calculations were evaluated with Python `math.sqrt`. This pass changes only this research note; the parent implementation owns controller tests, generated asset receipts and visual review. Bone corrections, effect shape, pose registration, precise controller trace and screenshot tool identity are still distinct verification questions.

## Follow-up: wide arms in the fixed EmuRetro comparison

The parent implementation observed excessive arm spread against EmuRetro 602–604 s after applying canonical proportions and RUN curves. This follow-up inspected all **141 public `src/game/m_player*` files**, 1,224,837 bytes in temporary storage, plus `sys_matrix.c` at the same pinned commit. It does not identify the recording's active animation or controller input.

**The ordinary locomotion route has no active rotation-difference table.** WALK/RUN/DASH call `Player_actor_InitAnimation_Base1`, which passes `NULL` as that parameter to both animation layers. `cKF_SkeletonInfo_R_init` writes the supplied pointer, and combine applies corrections only when it is nonnull. Searching the broader player files found no direct `rotation_diff` writer. This rules out that generic correction mechanism as a supported explanation in the examined ordinary locomotion route; it does not prove every possible scripted state is identical. [Player initializer](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_common.c_inc#L1849-L1876), [pointer assignment](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/c_keyframe.c#L345-L355), [conditional correction](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/c_keyframe.c#L1041-L1055).

**There is no arm prerender correction in the player callback table.** Its sole nonnull entry is head joint 24. Arm callbacks record post-render hand matrices/positions rather than modifying the pose. Broader source head-angle writers appear in creature release, which supports an explicit interaction-specific head adjustment rather than assumed ordinary walking gaze. The renderer's `Matrix_softcv3_mult` applies translation then Z, Y, X rotations, matching the decoder's `T*Rz*Ry*Rx`. No rotation-order mismatch was found. [Callbacks](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_draw.c_inc#L19-L60), [matrix operations](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/system/sys_matrix.c#L384-L469), [creature release head updates](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_main_release_creature.c_inc#L99-L140).

**Gait identity is an actual alternative, particularly for guided movement.** `DEMO_WALK` explicitly selects WALK1, calculates cadence using the WALK function, and follows its scripted target without normal WALK→RUN→DASH selection. Thus scripted movement can retain WALK even at a pace that would suggest RUN in ordinary player-controlled movement. The opening-job upload may show such a route; that remains an inference, not a verified video state. Do not fit RUN to it solely because the character appears to move quickly. [Scripted gait selection](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_main_demo_walk.c_inc#L19-L66), [scripted controller](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_main_demo_walk.c_inc#L77-L220).

Measured reconstructed positions across 128 samples per cycle, divided by the source thigh-plus-shin length **850**, give:

| Frontal projected landmark distance | WALK1 range | RUN1 range |
| --- | ---: | ---: |
| Shoulder-to-shoulder horizontal width | 1.051–1.059 | 1.058–1.059 |
| Elbow-to-elbow horizontal width | 1.986–2.182 | 2.092–2.183 |
| Symmetric wrist-proxy horizontal width | 2.753–3.245 | 3.276–3.460 |
| Wrist-proxy width, cycle mean | 2.979 | 3.368 |
| Wrist relative to its shoulder, screen vertical at 45° pitch | −1.159 to −0.088 | −0.520 to +0.074 |

The projection assumes frontal actor yaw and orthographic `screen_x=X`, `screen_y=(Y−Z)/sqrt(2)`. Camera pitch does not alter horizontal width under that assumption; yaw does. Positive screen Y is upward. The right proxy is source hand-joint 20; the left is a **symmetric local-X 625 extension from forearm joint 16**, because no matching left wrist joint exists. This is a skeleton proxy, not a measured mesh hand center. The source's *interaction* left-hand callback instead uses local X 1100, while the right callback records joint 20's origin: these asymmetric interaction anchors must not be treated as symmetric visible wrists. Original vertex batches and hand shapes were not recovered here. [Skeleton offsets](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/data/model/boy_model.c#L396-L425), [left anchor](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_draw.c_inc#L80-L97), [right anchor](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_draw.c_inc#L128-L137).

RUN's wrist proxy is about **13% wider on average** than WALK's. Gait selection can therefore explain part of the observed spread, but this calculation cannot explain or certify the complete silhouette mismatch. Skeleton rest ratios alone do not establish rendered anatomy: source arm display lists mix parent and child matrix vertex batches, while our generated mesh uses weighted deformation. A retarget that correctly preserves joint trajectories can still produce a wider visible arm contour through mesh volume, wrist placement or rest-basis fitting. Compare WALK and RUN under the same fixed camera/body scale before adding a global inward-arm correction; record any such correction as a visual adaptation. [Arm matrix batches](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/data/model/boy_model.c#L108-L211).

Reproduce the table using the existing decoder outputs in temporary storage:

```python
import json, math
from pathlib import Path
for gait in ("walk", "run"):
    data = json.loads(Path(f"/tmp/character-fidelity-source/{gait}-implementation-analysis.json").read_text())
    widths, projected = [], []
    for sample in data["samples"][:-1]:
        joints = sample["global_joint_positions"]
        matrix = sample["global_matrices_row_major"][16]
        left = [matrix[i][3] + 625 * matrix[i][0] for i in range(3)]
        right = joints[20]
        widths.append(abs(left[0] - right[0]) / 850)
        for point, shoulder in ((left, joints[14]), (right, joints[17])):
            projected.append(((point[1] - shoulder[1]) - (point[2] - shoulder[2])) / math.sqrt(2) / 850)
    assert len(widths) == 128 and all(math.isfinite(v) for v in widths + projected)
    print(gait, min(widths), max(widths), sum(widths) / len(widths), min(projected), max(projected))
```

## Follow-up: joint length cannot select visible-arm geometry

**626+625 is justified as a right-arm hierarchy distance, not as the visible arm's measured length.** The skeleton gives shoulder→forearm pivot 626, then forearm pivot→hand attachment joint 625; the latter joint has no display list. Left forearm has no child wrist joint. Its rendering continues through vertex batches, and its interaction callback uses local X1100. Neither attachment anchor establishes where rendered skin or a palm ends. Consequently `(626+625)/(450+400)=1.471765` is an attachment-chain/leg-chain ratio, not a validated visible anatomy ratio. The earlier skeletal measurement remains reproducible, but choosing the generated arm extension solely from that number was not justified. [Joint hierarchy](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/data/model/boy_model.c#L396-L425), [interaction anchor](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_draw.c_inc#L80-L97).

Public source defines `boy_1_v` through `#include "assets/boy_1_v.inc"`; that include is absent from the pinned repository tree. The README confirms game assets are not included. Display lists expose which vertex batches and matrices are used, but not their vertex coordinates. Exact rendered arm extent therefore cannot be recovered from this public source set without additional geometry evidence. No ROM or external ripped mesh was retrieved. [Missing vertex include](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/data/model/boy_model.c#L34-L36), [repository asset policy](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/README.md#L15-L17).

The player has uniform .01 scale on all axes, applied before its joint renderer. Uniform scale cancels when measuring arm/leg ratios. Boy and girl models have identical shoulder, arm and leg offsets; their feel-anchor offsets differ. Thus ordinary actor scale or choosing the other gender's skeleton does not explain this relative arm mismatch. [Actor scale](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player.c#L511-L513), [scale application](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_actor.c#L252-L259), [model selection](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_lib.c#L1278-L1287), [girl skeleton](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/data/model/girl_model.c).

**Recommendation, inferred from the evidence:** retain the source-ratio rig as a rejected or diagnostic candidate when fixed-camera visual comparisons disagree. Preserve source joint-motion timing and separately fit visible shoulder/wrist/palm contours to several gameplay views. Choose the geometry candidate from that visual evidence, record it as a calibrated adaptation, and avoid equating a hand/item attachment joint with the mesh wrist center. This resolves the evidence conflict without pretending the unavailable source vertices have been measured.
