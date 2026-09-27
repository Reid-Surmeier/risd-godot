# 42° dollhouse camera pitch trial (#130)

Question: does lowering the default dollhouse camera pitch from 45° to 42° make the room and visitor more readable at embedded size while retaining a steep view? Candidate `d857fa0` changes one camera constant. The integrated `105551c` is the exact baseline. Both keep 23° FOV, 14.2 m distance, 1.85 m aim height, all art and room geometry, visitor, mouse/trackpad orbit, and portal input.

| View | 45° baseline | 42° candidate |
| --- | --- | --- |
| Entry, 1600 | [PNG](baseline-1600-entry.png) | [PNG](candidate-1600-entry.png) |
| Warm, 1600 | [PNG](baseline-1600-warm.png) | [PNG](candidate-1600-warm.png) |
| Art wall, 1600 | [PNG](baseline-1600-art.png) | [PNG](candidate-1600-art.png) |
| Turn, 1600 | [PNG](baseline-1600-turn.png) | [PNG](candidate-1600-turn.png) |
| Entry, 720 | [PNG](baseline-720-entry.png) | [PNG](candidate-720-entry.png) |
| Warm, 720 | [PNG](baseline-720-warm.png) | [PNG](candidate-720-warm.png) |
| Art wall, 720 | [PNG](baseline-720-art.png) | [PNG](candidate-720-art.png) |
| Turn, 720 | [PNG](baseline-720-turn.png) | [PNG](candidate-720-turn.png) |
| 720 motion | [WebM](baseline-720-motion.webm) | [WebM](candidate-720-motion.webm) |

The candidate reduces the visible floor band by a few pixels and moves the doorway and paintings slightly lower within the frame. It retains the steep dollhouse look and the visitor's face remains visible. In the 720 warm view the doorway top and adjacent art are still cropped; the art wall and turn views show little practical improvement. The deterministic turn at replay tick 201–202 is distinct from the separate final-review corner screenshot with a large dark triangle; the exact-corner check below tests that defect. An independent [blind visual review](blind-verdict.md) narrowly preferred A, which maps to the 42° candidate, for a taller doorway and slightly less floor. It found the gain subtle at 720, the central artwork's top clearance slightly worse, and warm/turn clipping still present. The preference alone is narrow, but the exact-corner check below adds a measurable reduction in the exposed background. **I recommend integrating this one-line pitch change as an incremental improvement**, while tracking the remaining wall-top exposure and warm artwork clipping separately; do not iterate pitch further.

At the independently identified near-wall corner, a separate [native Compatibility pose harness](corner_pose.gd) rendered the same position `(-4.45, 0, -2.56)` and yaw `2.65` at 720: [45° baseline](corner-45/corner.png) and [42° candidate](corner-42/corner.png). It ran on Mesa llvmpipe, so the matched browser captures remain the RTX evidence. In the top-right crop x=380–538, y=94–249, pixels of the exact exposed background color `(32, 36, 41)` fall from **6,227 to 4,672** (−25%). At x=520, the background's last pixel moves from about y=185 to y=167. This makes the dark triangle smaller, without an obvious new artwork crop in the matched corner stills. The triangle remains visible because the finite wall ends below the camera's upper sightline; the pitch does not repair that geometry. [Logs](corner-42.log) record the camera position and the software renderer; the [baseline log](corner-45.log) does likewise.

The [baseline](baseline.json) and [candidate](candidate.json) browser runs report ANGLE D3D12 RTX 4070 SUPER, 23 paintings, a 480-tick completed motion replay at both sizes, and 120 frame samples per size. All medians are 16.7 ms; p95 is at most 16.8 ms. Sequential `game-shown` marks were 15.368 s and 14.282 s, not evidence of a load improvement. Compressed game packs are 93,920,495 and 93,921,680 bytes (+1,185 B). Both runs show existing GLES3 MSAA and `arrow_cursor` metadata messages; only baseline requested a missing favicon.

[Native navigation](native-navigation.log) passed arch/far keyboard and click roundtrips, orbit drag/easing, pan, wheel, floor click, and 23-painting count with zero failures. It used Mesa llvmpipe for input logic; RTX pixel evidence is above. `scripts/check.sh` and `git diff --check` passed. Production remains at 45° until the parent branch intentionally integrates this isolated candidate. No paid generation or new asset was used.
