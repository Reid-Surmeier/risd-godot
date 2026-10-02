# Collection reconstruction checkpoint — 2026-09-30 12:30 UTC

Collection map prototypes only; issues #178/#181/#182/#183 stay open. No
production integration, 3D Viewer change or paid call. Tick spend $0;
combined recorded Muse cost remains $0.02, never-resubmit receipts preserved.

1. Checked live Orca/process state: this is the only worker in this checkout;
   the map149 worker uses a separate checkout. Preserved existing dirty files.
   The requested historical holdout is already complete (49/69 supported;
   46/69 split-point diagnostics). Sampling overlap invalidates treating it as
   independent capture validation. Corrected model remains 473 views/43,042
   points/0.640691px; 45/69 split-point diagnostics, still correlated video.
2. Recovered interrupted 09:00 floor diagnostics without changing its evidence.
   Strict cross-view near-floor residual p90 is 1.66–2.38% of camera depth in
   non-source views; far 1.11–1.40%. Sparse withheld floor check: near zero points,
   far 1.633px in 246 and 0.824/2.782px in 506. Frame516 fails unused pose support.
3. Added frozen-plane photometric transfer with normal offsets fixed at
   0/±1%/±5% source camera depth and identical visible pixels across controls.
   Source/floor features remain outside camera fitting. Frame246 near patch is
   below the image (145/34,461 original pixels; no shared control coverage).
   Far correlation is 0.931 versus 0.847/0.749 at ±5%. Frame506 near correlation
   0.894 is worse than the -5% control 0.908; far 0.959 is worse than 0.962.
   Repeated wood, exposure and short baseline weaken this check. No retuning or
   new floor/collision acceptance. Initial coverage assertion failures retained.
4. Inspected final transfer panels, reference overlays, native/browser doorway
   captures, Muse sculpture and rejected head-v2. Historical bounded walk passes
   24 native and 24 browser engine checks plus real WASD crossing/return on RTX
   4070 SUPER. This does not validate corrected-model rooms or physical scale.
   Repository checks pass with eight ObjectDB warnings; Shell fails the same
   four checks: launch white pixels, tenant fill, grey tenant pixels and resize.
   Python/projection/sampling checks, exact old-result replay, source preservation
   and diff checks pass. Timings excluded due to other-worktree activity.
5. Next: inspect native early-entry frames202/204 against later505 and IMG6384
   to find three spatially separated, source-visible near-floor landmarks or
   wall-floor intersections. Freeze picks and a reserved view before fitting;
   check actual sampling separation. If visibility is insufficient, record that
   coverage gap rather than extend collisions. Do not repeat completed holdouts,
   depth or Muse jobs. Real blockers: independent scale/floor/opening/room coverage,
   #181 quality/topology contract, sculpture holes/rear and UV/bake acceptance.
   Automation 99695359-522b-46ce-bb00-078657d105ea remains enabled, reused session;
   the requested connected map is incomplete.

Evidence and reproducible commands:
`docs/evidence/collection-reconstruction/heartbeat-20260930T1230/`.
Recovered previous tick: `heartbeat-20260930T0900/`. Completed local transfer:
`~/risd-godot-ingestion/collection-expansion/strict-floor-photometric-final/`.

https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/heartbeat-20260930T1230/

Compare fixed floor pixels and shifted controls; bounded doorway walk is unchanged.
