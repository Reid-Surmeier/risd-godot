# Collection reconstruction checkpoint — 2026-09-30 15:00 UTC

Collection map prototype only; #178/#181/#182/#183 remain open. No Viewer,
production integration or paid call; tick $0, recorded Muse total $0.02.

1. Live process/Orca checks found no other writer in this workspace. Preserved
   27 pinned pending files, ten originals and 35 frozen ingestion inputs.
   Historical holdout already complete; corrected model remains the source.
2. Froze wider floor anchors 13116/14320/14976 across visits 244/505 before
   reserved lookup. Ray angles 6.96–11.31 degrees; normal sensitivity p95 13.79
   degrees. Reserved 245/508/509 each miss anchors. IMG 6384 candidates are
   plinth/baseboard features, excluded from wood-floor support.
3. Added optional frozen-triangle/query/wall-mask diagnostics. Original default
   replays exactly. Reverse 486/496 fail upper-image support. Source-reviewed
   entry 206 y<540 mask passes 68 pose inliers and 59/78 unused points within 4 px;
   original 450 failure retained. Saved camera/pose for reuse. Floor transfer
   remains inconclusive: near correlation 0.783 versus+5% control 0.791; no
   sparse floor observations. No plane, scale or collision extension accepted.
4. Native/Chrome RTX 4070 SUPER bounded walk passes 24 checks each and real WASD
   crossing/return; visuals inspected. Repository, replay/negative guards,
   pose round-trip, source-preservation and diff checks pass. Shell retains
   seven previously seen pixel/layout/timing failures. Timings excluded from
   acceptance while separate-worktree workers are active. Muse/rejected head
   surfaces inspected; holes/rear and bake remain unresolved.
5. Next: reuse the saved entry 206 pose; freeze distinct source-visible floor
   feature picks in 206 and244/505 before triangulating or inspecting predicted
   pixels. Check identities/occlusion rather than optimize photometric scores.
   Reverse 486 still needs more separated wall support; keep pose gates fixed.
   Real blockers: independent floor/scale/opening/room coverage, #181 quality/
   topology contract, sculpture coverage and UV/bake. Automation remains enabled
   because the connected map is incomplete. No ticket closure.

Evidence/commands: `docs/evidence/collection-reconstruction/heartbeat-20260930T1500/`.
New local trials: `strict-floor-wide-tracks-v1`, `strict-floor-wide-photometric-final`,
`strict-floor-reverse-photometric-v1`, `strict-floor-entry-wall-photometric-final`.
The entry pose is in the last trial's `result.json`; its camera matrix and
intrinsics round-trip checked. Historical doorway walk geometry is unchanged.

https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/heartbeat-20260930T1500/

Inspect wider anchors, the supported entry mask and rejected floor transfer.

Git automatic repack reported a damaged index in the unrelated homepage-prototype
worktree; checkpoint commit succeeded. No repair attempted within this scope.
