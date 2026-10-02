# Collection checkpoint — 2026-09-30, 04:30 UTC tick

**Next action:** inspect registered IMG_6380 frame 484 against earlier registered
203–209 for a clearly visible matching physical jamb feature at the Grand
Gallery end of the corridor. Reserve fresh validation pixels before fitting.
If coverage remains insufficient, keep that geometric gap explicit. Do not
repeat the completed holdout/depth sweeps or the failed 490/495/492 matching.

1. Read live Git/files/processes, AGENTS/MODULES/module docs and #178/#181–183.
   Other Collection terminals were idle; another repository worker uses a
   separate checkout. Resumed this prototype branch with earlier dirty work
   preserved. Completed holdout was already present: 49/69 support and 46/69
   split-point passes. Frozen model hashes match; no rerun or independent
   survey claim. Collection only; 3D Viewer unchanged.
2. Frozen new outer-casing toe picks in frames 238/244 and reserved frame 239.
   Reused measurement helpers. Predictions: 1.995 / 2.243px; ray separation
   18.0 / 25.7°. Toe offsets from frozen corridor plane: 1.96 / 4.14 provisional
   cm. ±3px pick sensitivity: 7.57 / 5.17cm p95 displacement, omitting pose/scale.
   Inspected fit/reserved overlays. Only a small casing-side floor expansion
   is added; scale, floor levels, room extents and whole-room collision remain
   unaccepted. The measured toes refer to the existing decorative doorway.
3. Opposite-end 490/495/492 poses are absent from the model. Cached localization
   failed, then one targeted CUDA matching pass against 475 frozen references
   still failed the unchanged ≥20 odd-point pose-inlier gate. 32–57 matched 3D
   correspondences are insufficient. Picks, matching log/database and rejection
   remain in ingestion corridor-grand-extents-v1; no unsupported geometry.
4. Isolated doorway-walk-v7 passes all 24 native and Chrome movement/camera
   checks, including added floor support in both directions, plus real WASD
   crossing/return. RTX 4070 SUPER, Chrome 154, 1100×760: ready 2.343s; sampled
   p95 16.67ms; native 8.33ms. Inspected browser and native renders and plans.
   Tiny bounded scene, no final performance/bake acceptance. Reproduction:
   ingestion .venv/bin/python prepare_doorway_walk.py <new-dir>
   --corridor-extents, followed by Godot import/export and doorway_walk_browser.cjs.
5. Repository and diff checks pass; eight import ObjectDB leaks warned. Initial
   Shell playtest lost its X connection. Complete rerun has five failures,
   all among the preceding eight names; inspected resize image and retained
   logs/comparison. No Shell runtime or frozen acceptance files changed.

https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/heartbeat-20260930T0430/

Playable bounded study, reserved-pixel evidence, floor before/after and reports.

Evidence and hashes: docs/evidence/collection-reconstruction/heartbeat-20260930T0430/.
Existing Muse frame/sheet and rejected head v2 inspected; receipts remain $0.02
combined / unknown spend / never-resubmit. Paid spend this tick $0. Blockers:
opposite-door pose support, broader room coverage, independent scale, quality
contract #181, sculpture holes/rear coverage and UV/bake acceptance. #178 and
#181–183 remain open; no production integration. Automation
99695359-522b-46ce-bb00-078657d105ea verified enabled/reuseSession=true; retained
because the requested connected map remains incomplete. Existing share reused.
