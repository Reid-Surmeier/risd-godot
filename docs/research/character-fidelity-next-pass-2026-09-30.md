# Character fidelity: faster playtest and the next research frontier

Research and prototype synthesis for [issue 231](https://github.com/Reid-Surmeier/risd-godot/issues/231), child of [map 226](https://github.com/Reid-Surmeier/risd-godot/issues/226). The owner rejected the slow travel and overall fidelity on 2026-09-30. This pass supports that criticism. The earlier proofs verified repaired deformation and reliable curve/export playback; they did not verify the whole driven character against original-game movement.

## What changed visibly

The [live playtest](https://windows-wsl.taile06c45.ts.net/character-walk-01a0f3a2/) now travels three times faster: normal 3.15 and held sprint 5.4 Godot units/second. Normal WALK playback is 1.25×, shortening its cycle from 0.8 to 0.64 seconds. Sprint retains the existing approximately 0.467-second clip. These are owner-requested tuning choices, not recovered game speeds. Increasing travel threefold and cadence only 25% does not establish a matching stride or eliminate sliding. Keyboard and simultaneous two-finger direction/sprint checks passed with observed speeds 3.150000095 and 5.400000095, and the normal animation rate was 1.25. Desktop and phone screenshots were inspected.

The current v6 comparison had a real registration defect: a 230×260 target crop was resized to a square, widening it by 260/230 ≈ 1.1304 relative to uniform scaling. The shared comparison function now uniformly scales and letterboxes both crops. Front/profile v6 GIFs, MP4s and pose sheets were regenerated, inspected, and checked. This fixes about 13% horizontal distortion; it does not match camera yaw, physical scale or phase. Historical v4/v5 receipts remain historical.

## Why it still feels unlike the game

| Observed weakness | Stronger evidence from this pass | Consequence for the next prototype |
| --- | --- | --- |
| Slow or disconnected movement | The source controller couples analog input, heading, acceleration, phase and WALK/RUN/DASH selection. Ordinary full-stick RUN is the safer candidate; held dash is separate. | Add and compare RUN before tuning one WALK clip to cover every speed. Drive phase from actual movement/state rather than three unrelated constants. |
| Sideways skating while turning | Source movement follows actor heading, reduces desired speed by heading error, and uses bounded turning. Our actor translates directly along input while the mesh catches up. | Test starts, stops, corners and reversals with logged input, facing, displacement and phase. |
| The same angles produce a different silhouette | Source and target skeletal ratios differ: arm/leg 1.472 versus 1.021; hip/shoulder 0.778 versus 0.414. These are joint ratios, not visible silhouette measurements. | Validate a canonical body, rest transforms and pivots before further retargeting. Fix anatomy/mesh where rotation cannot. |
| Head/limb repairs look improved but not authentic | Head weight repair prevents collapse; arm weight repair reduces contraction. Original rendering uses matrix-assigned vertex batches and layered animation, rather than this generated weighted rig. | Judge head shape, sleeve volume, foot pivot and hand/tool overlays separately. Bone count alone is not a fidelity test. |
| Nice comparison loops hide driven-character errors | Following crops remove travel and background motion; current pairs still have unmatched phase and camera. | Use whole-viewport motion against static ground landmarks, plus a separately registered deformation crop. Freeze one camera/scale fit; retain real-time playback. |
| Effects and small interactions are generic | Source footsteps are phase- and surface-dependent, tools override selected arm/hand joints, and turns/stops/NPC approaches have their own behavior. | Validate interactions and grounded effects as independent cases, not as a side effect of a clean looping clip. |

The detailed [controller, rig and effects audit](character-locomotion-fidelity-audit-2026-09-30.md) follows the call routes and documents the calculations, source ranges and uncertainties. Source is a pinned community decompilation, not an official Nintendo source release: [ACReTeam/ac-decomp](https://github.com/ACreTeam/ac-decomp/tree/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c).

Under a supported but capture-unverified 60-update/second NTSC model, full normal input has an approximately **0.551-second RUN cycle**, and held dash approximately **0.444 seconds**. The velocity law alone accelerates to normal speed in about .150 seconds and brakes from it in .250 seconds; dash takes about .217/.383 seconds. Those are not complete input latency or recovered meters/second. Floating-point threshold behavior matters: ordinary full stick falls just below the RUN-to-DASH threshold in a binary32 reproduction, so assigning normal movement to DASH without a console trace is unjustified. [Source speed/phase calculation](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_main_walk.c_inc), [RUN gates](https://github.com/ACreTeam/ac-decomp/blob/09ca8e8b5b24e6ab44047ee980cf0088ad7ecb4c/src/game/m_player_main_run.c_inc).

Source units cannot simply become Godot meters. A leg-based scale gives a much faster candidate and an unresolved distance-per-cycle discrepancy; neither is accepted. Likewise, no examined world-foot anchor is not proof that original motion intentionally slides. Measure travel against the ground before imposing modern planted-foot IK as an authenticity fix.

## More direct gameplay evidence

Four additional uploaders were inspected, preserving compact timestamped contact sheets and metadata. The [expanded reference report](character-gameplay-reference-expansion-2026-09-30.md) explains each window and capture limitation.

1. [MaloDogfish, 10:42–10:54](https://www.youtube.com/watch?v=o7pRJ3Vhu7s&t=642s): front movement, ramp descent, turn and approach to Tortimer. Elevation/camera follow prevent one flat-ground speed fit.
2. [EmuRetro Gameplays, 10:01–10:13](https://www.youtube.com/watch?v=Fd0g57lSedA&t=601s): longer front traverse followed by a dialogue stop. Opening-job movement may be guided/scripted.
3. [Nintendo Utopia, 25:00–25:12](https://www.youtube.com/watch?v=OUMNiEiR1As&t=1500s), and [26:40–26:52](https://www.youtube.com/watch?v=OUMNiEiR1As&t=1600s): shop exit, snow travel/turn, NPC stop, item receipt and movement resumption. This is an independent creator, not Nintendo's official channel.
4. [PBGGameplay, 6:42–6:54](https://www.youtube.com/watch?v=RwWURstn4eQ&t=402s): house approach, entry transition and indoor resumption. Borders/editing make it qualitative corroboration.

Four main 12-second excerpts yielded 1,440 decoded frames at the selected streams' 30 fps. Encoded upload fps is not the simulation clock. No new clip matches the exact star hat, proves analog/B input, or gives a clean input-labelled reversal, collision press or equipped-tool locomotion. Different outfits, revisions, aspect handling and emulator enhancements remain uncertainties. We have more evidence, not an exact reference capture.

## Smallest credible route forward

This is the map's research/prototype frontier, not a production specification.

1. **Establish comparable evidence.** Pick an unobstructed flat sequence; fit viewport/aspect and one camera/body scale; track static ground landmarks. Save whole-view travel, real-time cadence and a single constant-phase aligned pose comparison. Reject per-frame resizing that hides drift.
2. **Repair the controller and gait selection.** Decode/retarget RUN on the existing trial, couple speed and phase, preserve phase when changing gaits, move along heading, and test braking/reversal/collision feedback. Keep source-unit scale explicit until footage calibrates it. Inspect lean at normal and held dash speeds.
3. **Validate one canonical chibi rig.** Compare front/profile silhouette, rest transforms, shoulder/hip widths, limb lengths, head attachment and boot pivots. Reuse that validated skeleton/body for subsequent assets. Muse remains the appearance reference for UV painting/baking; another generated rig cannot solve an incorrect rest shape. Godot's documentation explicitly distinguishes bone-name mapping from rest-transform alignment: [retargeting 3D skeletons](https://docs.godotengine.org/en/stable/tutorials/assets_pipeline/retargeting_3d_skeletons.html).
4. **Check the small interactions.** Forward start/stop, quarter turn, reversal, wall push/release, idle head/face motion, carried-tool arm/hand pose, NPC face/stop, and door transition each need their own observed sequence. Prioritize the tool silhouette in the owner's screenshot; exact tool identity is unverified.
5. **Match effects last.** Emit surface-appropriate footsteps/effects from actual foot events; dry dash dust, grass WALK/RUN suppression, indoor suppression, and rain/snow/water cases need separate evidence. Current shrinking white spheres are placeholder feedback, not matched original dust.

A fixed template plus source-informed controller is the recommended next experiment, inferred from the observed failures and retargeting requirements. Exact recovery is still open; the map should not be promoted to a production spec on these results alone.

## Evidence, cost and storage

The existing selected WALKv5/Fastv6 GLBs and all original Muse/provider inputs are unchanged. No provider call was added: **$0 this pass**, aggregate liability **$1.54** of the authorized $4. New reference sheets/metadata total about 431 KiB; scratch footage stayed below 20 MiB, with no complete longplays downloaded. Browser exports are ignored and regenerable. Current build stamp is `f15161043b57`; only the served current site needs retention for owner review.

`scripts/check.sh`, the keyboard/multitouch browser check and the corrected comparison receipt check passed. These prove the repository baseline, demo controls/tuning and export receipt integrity. They do not certify Animal Crossing fidelity. Current provenance and hashes bind the new evidence; visual acceptance remains open on issue 231.
