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

The earlier agent's measurements (USER-SUPPLIED; our measured baseline differs): engine started 4.0–4.3 s; engine started → Collection settled 32.9–33.1 s; other tabs warmed 7.3–7.6 s; exit 1.85 s; first picture 46.9–47.1 s; GPU read-back inclusive CPU time 8.7–9.5 s.

## Status

Jobs A and B are implemented. Three engine runs before/after, three browser runs before/after, the immediate-input probe, visual comparison and both rounds of required checks are complete. Job A is committed as `82adbc3e`. The two reconstruction checks have pre-existing failures confirmed below; pushing awaits an explicit exemption or passing integration of the interaction fixes, under the user's mandatory-check condition.

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

## Job B choice

Other Tabs are left lazy until their first click. VERIFIED from source: their Tenant factories and shader compilation are synchronous; selecting a Tab also switches the visible Page and freezes the previous one. INFERRED: moving that unchanged work into an idle callback would still pause Collection for the same hundreds of milliseconds or seconds. Invisible, smooth warming would require splitting those factories or changing renderer preparation, beyond this bounded boot-loader change. `launch-settled` remains the Collection readiness mark; two more frames draw Collection, then `tabs-deferred` records that the other Tabs were left cold. The browser overlay still owns `game-shown`, emitted after it is removed, when Collection can receive input. The gallery browser-check launcher now waits for `game-shown` instead of the removed `tabs-warm`, including when measuring an older baseline build.

Before measurements used the supplied live build. Each Godot invocation inside export-web.sh was wrapped by the task-specific timeout launcher.

## Jobs A + B browser results (VERIFIED)

| Measurement (seconds) | After 1 | After 2 | After 3 |
|---|---:|---:|---:|
| Engine started | 5.534 | 5.975 | 6.661 |
| Engine started → launch settled | 27.426 | 28.865 | 31.056 |
| Launch settled → tabs deferred | 0.026 | 0.026 | 0.029 |
| Tabs deferred → game shown | 1.860 | 1.845 | 1.857 |
| First usable picture (game-shown) | 34.846 | 36.711 | 39.603 |
| glGetBufferSubData CPU time | 2.355 | 2.595 | 3.390 |

| First Tab click (ms, includes fade) | After 1 | After 2 | After 3 | Median |
|---|---:|---:|---:|---:|
| map | 1416.6 | 1296.4 | 1524.6 | 1416.6 |
| sketchbook | 2666.0 | 2852.1 | 2904.2 | 2852.1 |
| 3d_viewer | 1780.4 | 2004.9 | 2118.4 | 2004.9 |
| video_player | 563.9 | 547.3 | 573.9 | 563.9 |
| collection | 389.4 | 402.0 | 380.0 | 389.4 |
| playground | 831.1 | 850.8 | 733.7 | 831.1 |
| flowers | 962.2 | 992.3 | 954.2 | 962.2 |

All three after runs verified hardware WebGL2 and zero script errors; each other Tab was physically clicked once and its Tenant reported ok after the switch settled. `browser-after.png` was inspected: Collection is visible under its frame and the loading overlay is absent. Raw milestone timestamps and profile summaries are in `browser-after-{1,2,3}.json`. The after page is served from this worktree on a loopback Python server; the before page used the supplied tailnet server, so download timings differ. Other agents also use this GPU.

`usable-collection.json` independently verifies the meaning of `game-shown`: Collection is active, the switch is settled, and the browser loading overlay is absent. A real S key press 135 ms after that mark moved the visitor 0.849 m into the Hall, then releasing it stopped movement. A two-second idle sample recorded 117 frames, a maximum gap of 33.4 ms and no gaps over 50 ms, with zero script errors. There is no background Tab warm-up to interrupt Collection. This is one readiness/idle probe, separate from the three timing runs.

VERIFIED: median first picture is 40.564 → 36.711 s; median sampled GPU read-back time is 6.758 → 2.595 s. The five-tab warm-up barrier, including the return to Collection, was 6.210–6.391 s; after it is replaced by 0.026–0.029 s for two Collection frames. Engine-start → launch-settled is 26.296–29.369 s before and 27.426–31.056 s after, so the observed total improvement is smaller than simply adding removed read-back and warm-up costs. INFERRED: differences in shared-machine contention, transfer/engine-start time and where pending GPU work settles contribute; no isolated causal estimate of that difference is claimed. Added rooms still build at launch on this branch.

Remaining renderer reads exist in the forbidden `main_build_walk.gd` Hall-fixture clipping and the added-room generator. Those files were not edited. The retained Hall source arrays are available for a later change there, and the separate room-loading work still needs integration.

Web export count: exactly 1; pack size 255 MB, within the 260 MB budget.

CPU profile `before-2.cpuprofile.gz`: original SHA-256 `e996b2ddf2d5a2ced6b00feeda61f8973305dd4f5206a205fd5b983212eaceee`, compressed size 250155 bytes.

CPU profile `after-2.cpuprofile.gz`: original SHA-256 `9eba2de040a2a9074ccdeb1942113f61e00b1fee10c4432c0b358b65187d4cac`, compressed size 215738 bytes.

## Final checks and cleanup (VERIFIED)

| Check | Jobs A + B |
|---|---|
| scripts/check.sh | PASS, exit 0; no Godot ERROR or SCRIPT ERROR; gdlint absent from PATH |
| git diff --check | PASS |
| visitor174_check.gd | PASS, #236 and #259 |
| museum --only=doors | PASS, all 38 crossings, no failures or script errors |
| click_route_check.gd | Same baseline failure: floor-pick-grey-hall; 15/16 pass; exit 1 |
| main_build_check.gd | Same 10 baseline visibility failures; exit 1 |
| Node syntax checks | PASS, gallery-browser-check.cjs and usable_collection.cjs |

`doors-B.json`, `visitor-B.log`, `repository-checks-B.log` and `reconstruction-checks-B.log` retain the final evidence. Only one Web export was performed. The Python server on port 8871 was stopped, its listener verified absent, and `/home/reidsurmeier/orca/workspaces/risd-godot/wt-grey-rockefeller/build/web` was deleted by exact path. Superseded raw CPU profiles were deleted by exact path; the two compressed median-run originals remain in this evidence folder. Initial unrelated untracked files were preserved.

## Engine summary (VERIFIED, medians of three, seconds)

| Call | Before | After |
|---|---:|---:|
| _build_room | 4.898 | 4.132 |
| _merge_static | 1.716 | 0.185 |
| _build_kid | 1.862 | 0.250 |
| _set_lighting | 1.023 | 2.033 |
| _build_paintings | 0.413 | 0.300 |
| Sum of these calls per run | 9.871 | 6.835 |

`_set_lighting` includes the untouched reconstruction adapter's Hall-fixture clipping; it still reads renderer mesh data. INFERRED: removing earlier synchronous reads shifts some pending GPU work into that later call, so individual call savings must not be added as if they were independent. The measured sum still falls from 9.871 to 6.835 s.

## Reproduce

Copy `engine_probe.gd.txt` and `timed_walk.gd.txt` to `build/hall-launch-281b/engine_probe.gd` and `timed_walk.gd`. Source `~/promo-lab/gpu-env.sh`, set `DISPLAY=:99`, then run:

```bash
timeout 300 "$HOME/.local/opt/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64" \
  --path . --display-driver x11 --rendering-driver opengl3 --fixed-fps 60 \
  --script res://build/hall-launch-281b/engine_probe.gd \
  -- --picture=docs/evidence/hall-launch-281b/hall-after.png
```

`browser_probe.cjs URL before|after` runs three new GPU Chrome processes, disables cache, captures the marks/CPU profile, then physically clicks all six other Tabs and returns to Collection. It reads Puppeteer from `~/promo-lab/node_modules` and maps click coordinates through the square displayed stage. It expects the scratch/evidence directories used here. The native checks use the commands in AGENTS.md and the museum-playtest rules; `click_route_check.gd` additionally requires its output-directory positional argument after `--`.
