# Hall launch #281b results

Baseline commit: `abf8858504a8f79fc124613bd60e8350231fd88c`.
Measured on 8 October 2026 with Godot 4.7.2, Compatibility/OpenGL ES through Mesa d3d12 on the NVIDIA RTX 4070 SUPER. Three fresh processes, fixed 60 FPS, 1080 × 1080; times are milliseconds. Other agents also use this machine/GPU, so wall times may include contention.

## Engine baseline (VERIFIED)

| Build call | Before 1 | Before 2 | Before 3 |
|---|---:|---:|---:|
| _build_room | 4898.434 | 4789.251 | 5551.440 |
| _build_floor | 38.896 | 30.670 | 60.734 |
| _far_end | 528.622 | 558.221 | 581.351 |
| _merge_static | 1700.499 | 1719.617 | 1715.633 |
| _build_kid | 1862.323 | 1472.185 | 2002.227 |
| _set_lighting | 991.738 | 1022.661 | 1132.547 |
| _build_paintings | 418.321 | 399.015 | 413.248 |
| _build_test_room | 10888.700 | 10292.981 | 11202.144 |

The probe subclasses the actual integrated Collection and times the inherited build calls; `_build_room` includes `_build_floor` and `_far_end`. It makes no changes to production scripts. `hall-before.png` is a fixed-camera baseline.

## Browser baseline

Three fresh GPU headless Chrome processes measured the supplied live `abf88585` build. CPU sampling starts before navigation and stops at `game-shown`; the first click on each Tab follows that mark. Cache is disabled in every run.

The earlier agent's measurements (USER-SUPPLIED, not yet independently verified here): engine started 4.0–4.3 s; engine started → Collection settled 32.9–33.1 s; other tabs warmed 7.3–7.6 s; exit 1.85 s; first picture 46.9–47.1 s; GPU read-back inclusive CPU time 8.7–9.5 s.

## Status

Job A implementation, three engine after runs and the required playtests are complete. The two reconstruction checks have pre-existing failures confirmed below; pushing awaits resolution of the user's mandatory-check condition. Job B and the final browser measurement remain.

## Browser baseline measured here (VERIFIED)

| Measurement (seconds) | Before 1 | Before 2 | Before 3 |
|---|---:|---:|---:|
| Engine started | 4.404 | 4.768 | 4.223 |
| Engine started → launch settled | 26.296 | 27.694 | 29.369 |
| Launch settled → tabs warm | 6.391 | 6.210 | 6.362 |
| Tabs warm → game shown | 1.858 | 1.893 | 1.842 |
| First usable picture (game-shown) | 38.950 | 40.564 | 41.796 |
| glGetBufferSubData CPU time | 6.130 | 6.758 | 7.860 |

This baseline is faster than the user-supplied 47 s profile; comparisons use the three runs measured here. All three verified hardware WebGL2 (ANGLE/D3D12 NVIDIA RTX 4070 SUPER) and zero script errors. The initial exploratory click probe timed out because logical coordinates were not scaled; all three recorded runs use the displayed stage and complete.

| First Tab click (ms, includes fade) | Before 1 | Before 2 | Before 3 |
|---|---:|---:|---:|
| map | 296.6 | 413.6 | 314.8 |
| sketchbook | 430.4 | 415.0 | 403.6 |
| 3d_viewer | 416.5 | 398.9 | 417.7 |
| video_player | 411.6 | 402.4 | 411.1 |
| collection | 321.3 | 325.7 | 285.3 |
| playground | 426.7 | 400.6 | 412.5 |
| flowers | 819.8 | 792.5 | 803.4 |

## Job A engine results (VERIFIED)

| Build call (ms) | After 1 | After 2 | After 3 |
|---|---:|---:|---:|
| _build_room | 4150.346 | 3954.558 | 4131.778 |
| _build_floor | 26.759 | 26.520 | 32.869 |
| _far_end | 251.057 | 253.189 | 253.427 |
| _merge_static | 177.696 | 209.348 | 185.446 |
| _build_kid | 250.379 | 249.136 | 1268.304 |
| _set_lighting | 2142.568 | 2033.082 | 923.806 |
| _build_paintings | 300.251 | 389.184 | 293.815 |
| _build_test_room | 8818.880 | 9045.504 | 9750.571 |

The fixed-camera engine pictures `hall-before.png` and `hall-after.png` were inspected and are pixel-identical: zero changed pixels, confirmed by `hall-comparison.json`. Hall construction and camera position, all 23 painting records, mesh grouping/layers, and visitor animation code are preserved.

Job A retains SurfaceTool arrays before upload for the floor, portal floor, panels, trims, seats, stone and painting frames. Far-end winding and static grouping/merging consume those arrays. Native primitive arrays (60 exact configurations, 13,962 bytes compressed) and the visitor's face/hand mesh plus 460 left/512 right rigid sole points (232,648 bytes compressed) are extracted offline by `prepare_cpu_geometry.gd`. `visitor.gd` loads the same geometry and duplicates the animated material per visitor. The old face/sole mesh reads no longer run at launch. No `get_faces` or `create_trimesh_collision` call exists in these two launch scripts at this commit; the measured read-backs that remain in added-room code belong to the other agent.

The first implementation probe found uncached painting-frame meshes; their private `_mesh` builder now retains its source arrays too. That failed exploratory run was discarded; all three reported after runs have no script errors.

## Job A required checks (VERIFIED)

| Check | Starting Hall code | Job A |
|---|---|---|
| scripts/check.sh | not separately rerun | PASS |
| git diff --check | clean | PASS |
| visitor174_check.gd | not separately rerun | PASS, #236 and #259 locomotion/contact/cadence |
| museum --only=doors | not separately rerun | PASS, 38 crossings, zero failures or script errors |
| click_route_check.gd | FAIL, floor-pick-grey-hall (15/16 pass) | Same failure (15/16 pass) |
| main_build_check.gd | FAIL, 10 visibility/cutaway expectations | Same 10 failures; 430 probes and 1,298 clipped demo triangles |

The starting-code comparison loads `git show abf88585` copies of walk4.gd, main_build_walk.gd and demo.gd from ignored scratch, replacing the Content script before the scene enters the tree. Tests and room generator are unchanged. The click test also reports the same native lightmap-null error on exit in both versions. No production input/click/camera/Other-wall or room-generator code was edited. These failures are outside this ticket part and must be addressed by the interaction work or explicitly exempted before push.
