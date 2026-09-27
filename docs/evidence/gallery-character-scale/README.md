# Character scale at 42°: isolated trial

**Keep the current production scale.** Increasing only the rig multiplier from `1.17` to `1.42` matches the owner's close Animal Crossing composition, but enlarges the body beyond the existing wall and doorway clearance. A scale-only integration does not meet the requirement to preserve visual collision fit. Production was not edited.

Worktree: `/home/reidsurmeier/orca/workspaces/risd-godot/gallery-character-scale`, branch `Reid-Surmeier/gallery-character-scale`, based on `9e1fbea`. The tested Web baseline is `22089e5`, whose `walk4.gd` and `rig/visitor.gd` are identical to the trial base. Candidate export `9e1fbea-dirty` contains the single multiplier change. No camera, art, room, collider, IK, pixel asset, or paid generation changes.

The [bounded clearance follow-up](../gallery-character-scale-clearance/README.md) was also rejected: its doorway steering corridor is only 20 cm wide with 1.5 cm sampled walking clearance. The scale-only source diff is retained in isolated commit `713fe4b`; runtime source was restored to base after both trials.

## Matched evidence

| View | Current | Larger rig |
| --- | --- | --- |
| Doorway, 1600 | [PNG](baseline-1600-entry.png) | [PNG](candidate-1600-entry.png) |
| Doorway, 720 | [PNG](baseline-720-entry.png) | [PNG](candidate-720-entry.png) |
| Warm room, 720 | [PNG](baseline-720-warm.png) | [PNG](candidate-720-warm.png) |
| Art wall, 720 | [PNG](baseline-720-art.png) | [PNG](candidate-720-art.png) |
| White room, 720 | [PNG](baseline-720-white.png) | [PNG](candidate-720-white.png) |
| Turn, 720 | [PNG](baseline-720-turn.png) | [PNG](candidate-720-turn.png) |
| Walk/turn replay, 720 | [WebM](baseline-720-motion.webm) | [WebM](candidate-720-motion.webm) |

The complete directory also contains every pose and the motion replay at 1600. Inspecting these shows clearer face and clothing at 720; the larger body fills substantially more of the doorway and occludes more of the art wall. Artwork edges retain their framing: all eight matched camera-transform/FOV records agree exactly, and all cases retain 23 paintings. Increasing aim height was unnecessary because the feet were already at the selected reference's line.

## Screen measurements

[Landmarks and arithmetic](measurements.json) use only the game viewport inside the gold frame, excluding the desktop and toolbar. Bounds enclose visible hat through shoe, excluding shadow. These are manual measurements with approximately ±2 px endpoint uncertainty, not automatic segmentation. Percentages are rounded below to avoid false precision.

| Source | Character height | Feet y |
| --- | ---: | ---: |
| Owner's exact reference | 33.4% ±2 points | 80.6% ±1 point |
| Existing integrated 1600 export | 27.6% | 80.4% |
| Existing camera-trial 720 export | 28.4% | 80.5% |
| Matched current, 1600 | 27.8% | 80.6% |
| Matched candidate, 1600 | 34.4% | 81.4% |
| Matched current, 720 | 28.4% | 80.5% |
| Matched candidate, 720 | 34.9% | 80.9% |

The larger rig is close to the [exact-reference measurement](../../research/animal-crossing-reference-composition.md), within its manual height uncertainty. The current rig is significantly smaller. Matching that close-room player size increases the visitor's actual posed world height from 1.945 m to 2.360 m in the existing measured museum; the far doorway remains 2.8 m high.

## Why the trial stays isolated

[clearance.gd](clearance.gd) evaluates actual skinned mesh vertices in idle poses, using the runtime skin and bone transforms. [The log](clearance.log) records the forward-facing rightmost vertex at 0.673 m from player centre currently, and 0.817 m with the larger rig. The room controller permits the centre 0.55 m from a wall. It also permits a doorway crossing at x=0.4 m in a doorway whose half-width is 0.95 m, leaving the same 0.55 m clearance. Thus these allowed positions can intersect the body envelope by **0.123 m currently and 0.267 m with the trial**. This is an existing clearance limitation made 0.144 m worse, not a newly discovered pathfinding failure. The test measures the mesh envelope; it does not claim the entire envelope intersects every wall during every walking pose.

Fixing this properly requires reconsidering body-aware wall and doorway clearance and checking all movement poses. Merely increasing the rig while retaining collision numbers cannot guarantee physical fit. Zooming the camera instead would change artwork framing. Both exceed this bounded scale-only study, so neither was attempted.

## Verification and limits

- The candidate-scale copy of the existing [rig check](rig-scale-check.gd) passes: 18 walking contacts, 24 stop phases, planted-sole drift below 0.000001 m, boot penetration below 0.000074 m, and smooth turns/gestures. [Log](rig.log).
- Existing navigation check passes arch and far keyboard/click roundtrips, drag/easing/pan/wheel/click/cancel, with zero failures. [Log](navigation.log). This verifies controller interactions, not full mesh clearance.
- [Baseline](baseline.json) and [candidate](candidate.json) browser runs use ANGLE D3D12 on RTX 4070 SUPER. Both sizes complete the 480-tick replay; median rAF is 16.7 ms and p95 at most 16.8 ms. Both contain the existing MSAA and `arrow_cursor` messages plus missing favicon. [Capture script](capture.cjs).
- `scripts/check.sh` and `git diff --check` pass. [Check log](check.log) includes existing resource/cleanup warnings; pass is the script's result, not a claim of warning-free startup.
- An [anonymous A/B packet](blind/README.md) is saved, with [mapping](blind-key.json) separate. **No independent blind review was available in this session** because the parent reported the agent-thread limit. This report's inspection is not presented as a blind verdict.

Temporary Chrome, Godot, and HTTP servers were stopped after testing. No production integration or public deployment occurred.
