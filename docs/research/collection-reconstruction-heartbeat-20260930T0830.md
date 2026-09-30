# Collection checkpoint — 2026-09-30, 08:30 UTC tick

**Next action:** freeze source-visible near/far floor masks in corrected-depth
views exit13 and earlier visit 245, then compare those cached maps against source 19
candidate planes with spatial coverage and cross-view residuals. Use
`strict_depth_floor.py <new-trial-directory>` with frozen `annotations.json`.
Do not rerun completed depth, matching, holdouts, retune failed marks or transplant
historical floor/collision coordinates. The current source 19 planes remain hypotheses.

1. Live Git/files/processes, Orca sessions, AGENTS/MODULES/module docs and
   map #178/tickets #181–183 checked; earlier workers idle. Owner-authorized prototype
   workspace reused, no nested agents or build integration. Original 49/69 holdout
   remains complete; corrected model 473 views / 43,042 points / 0.640691px and
  45/69 nearby withheld results preserved. These are correlated same-video checks,
   not independent capture or metric validation. Ten original video hashes checked.
2. Triangulated source-visible threshold tracks 13116/13515 plus interior wood
   feature 14326 from corrected training 13/19. Adequate angles 5.51–9.13 degrees.
   Reserved 21/25 have missing tracks, so neither passes the complete-triangle gate.
   Earlier visit 245 provides all three at 0.629/1.635/4.950px; selected after the
   primary result, explicitly exploratory. Candidate normal sensitivity p95
  17.932 degrees under ±2 camera pixels: no plane/collision acceptance.
3. New six-view 640px RTX4070SUPER CUDA PatchMatch/fusion from corrected model;
   query 21/25 excluded, 2,568 fused points, no old geometry transplant. Frozen
   source 19 near/far masks yield 13,310/8,710 valid samples (38.62/87.48 percent).
   Untrimmed SVD candidates differ 3.164 degrees; block-test p90 residuals
  0.011651/0.014189 world units. Metric scale and cross-view planarity unverified.
   Planar recovery, displaced-plane negative control, camera round trip and exact
   frozen-result equivalence pass. Full dense artifacts retained in ingestion.
4. Historical doorway-walk-v7 passes 24 native/RTX Chrome collision/camera checks
   and real WASD crossing/return; source/render images inspected. Native initial
   missing-output-directory error retained; corrected capture succeeds. Timings
   excluded from acceptance due to concurrent diagnostic work. Shell initial seven
   failures all historically observed; isolated rerun has the four failures from
   prior tick. Repository check passes; eight ObjectDB leaks warned. No full-room
   navigation or integrated-build acceptance.
5. Muse frame/sheet and rejected head-v2 image reviewed; combined recorded spend
   remains $0.02, unknown/never-resubmit receipts unchanged. Tick $0. Original dirty
   work preserved except this tick's append-only provenance. No Viewer/runtime
   changes, ticket closures or production integration. Automation 99695359-522b-46ce-
   bb00-078657d105ea enabled/reuseSession=true; map incomplete. Real blockers:
   independent scale, floor/opening/room coverage, #181 quality contract, sculpture
   rear/holes and UV/bake acceptance. No unfinished reconstruction jobs left.

Evidence: `docs/evidence/collection-reconstruction/heartbeat-20260930T0830/`.
Local corrected depth: ingestion `dense-strict-floor-v1/`; floor candidates
`strict-depth-floor-v1/`; tracks `strict-floor-tracks-v2/` and
`strict-floor-tracks-revisit-v1/`. Only this task's additions checkpointed.

https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/heartbeat-20260930T0830/

Source-visible floor triangle, corrected CUDA coverage and bounded doorway walk.
