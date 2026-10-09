# Collection checkpoint — 2026-09-30, 05:00 UTC tick

**Next action:** use ingestion `grand-casing-revisit-v1/` (already decoded,
36 frames at 6 fps, 101–107 nominal seconds). Inspect full-resolution frames
24/26/28 for sharp corridor-return coverage; reserve a fresh query and its
pixels before fitting. Match selected samples against frozen 475-view references
with the existing calibrated IMG_6380 camera, GPU SIFT/matching and unchanged
≥20 odd-point support gate. Keep frames 9–11 excluded around the original
102.5s withheld sample. Do not rerun the completed holdout/depth jobs or cached
failed 210/211 and 490/495/492 sweeps. One casing toe is not an aperture.

1. Read live workers/Git/files/processes, AGENTS/MODULES/module docs and
   #178/#181–183. Previous Collection workers idle; other worker in another
   checkout. Resumed this prototype branch; earlier dirty work preserved.
   Frozen model hashes match: 475 views, 43,253 points, 0.639588px. Completed
   holdout remains 49/69 supported and 46/69 split-point passes; not independent
   survey accuracy. No rerun. Collection only; 3D Viewer unchanged.
2. Triangulated one white exterior casing toe from registered frames 203/205;
   reserved frame 204 error 0.799px, ray angle 11.94°. Local position
   [-0.932, 0.197, 4.157] provisional metres; ±3px pick p95 displacement 7.87cm,
   omitting pose/scale. Frozen floor extrapolation offset 7.16cm is comparable
   to uncertainty; no physical step, floor extension or collision added.
   Reverse frame 484 shows the opposite face and is excluded. The casing is
   at the Grand Gallery end of the corridor, separate from the adjacent
   blue-room doorway. Fit/reserved/contact visuals inspected.
3. Return frames 211/210 fail support: zero/two unique tracked 3D points.
   Cached CUDA feature/match pass preserved in `grand-casing-return-v1/`;
   no triangulation. Zero matches exposed a pycolmap TypeError. Added one
   shared minimum-correspondence guard; all callers traced. Old version crash
   reproduced; `ingestion .venv/bin/python .../measurements.py` now accepts
   supported withheld frame 206 and rejects 210/211. Fresh NVDEC/scale_cuda
   extraction completes, source/output hashes retained, contact inspected.
4. Existing doorway-walk-v7 revalidated: all 24 native and Chrome movement/
   camera checks and real WASD crossing/return pass. RTX 4070 SUPER, Godot
   4.7.2 / Chrome 154, 1100×760: ready 2.517s; sampled browser p95 16.67ms;
   native p95 8.33ms. JS heap 103.75MB excludes complete WASM/GPU/process memory.
   Inspected native and browser visuals. Initial native screenshots failed
   because the output directory was missing; final complete rerun passes and
   raw failure log remains. No new room scene or full-map performance claim.
5. Repository/Python/diff checks pass; eight ObjectDB leaks warned at import.
   Shell software run has five failures; GPU run has six, including two
   reappearing timing names. All six were in the earlier eight-name baseline;
   no runtime/frozen acceptance files changed. GPU resize image inspected;
   both verifiers and comparison retained. Not a green integrated build.

https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/heartbeat-20260930T0500/

Reserved-pixel measurement, fresh reference contact, existing walk and reports.

Evidence and provenance: docs/evidence/collection-reconstruction/heartbeat-20260930T0500/.
Muse frame/sheet and rejected head v2 inspected; $0.02 combined receipts and
unknown spend / never-resubmit unchanged. This tick spends $0. Blockers:
return-pose/room coverage, independent scale, owner quality contract #181,
sculpture holes/rear coverage and UV/bake acceptance. #178/#181–183 remain open;
no production integration. Automation 99695359-522b-46ce-bb00-078657d105ea is
enabled/reuseSession=true; retained because requested work remains incomplete.
Existing private share reused; no new share or heartbeat loop. Completed within
25 minutes; next scheduled tick resumes from this evidence.
