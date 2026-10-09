# Collection checkpoint — 2026-09-30, 07:00 UTC tick

**Next action:** build a fresh disposable model from cached matches using
`sampling-timing-v1/strict-training-selection.json` (473 allowed images).
Exclude exit6fps frames 18 and 48 using actual decoded timestamps. Do not seed
with geometry fitted to excluded images. Then validate the same 69 withheld
images before extending Grand-end floor/collision. Do not rerun completed
matching, old holdout, or retune rejected pixels.

1. Live workspace/processes and #178/#181–183 checked; earlier Collection
   workers idle. Existing authorized prototype branch reused, dirty work
   preserved. Model remains 475 views / 43,253 points / 0.639588px fitted error.
   Historical holdout 49/69 supported, split-point 46/69 preserved; no rerun.
2. New left plinth shoulder passes reserved manual pixels at 4.677px, ray angle
   8.07°, picking sensitivity p95 13.02 provisional cm. Opposite shoulder fails
   at 10.118px despite 36/79 pose inliers and passing unused-point diagnostics.
   Both inspected in overlays/native crops. Shoulder is above floor; no new
   aperture, floor or collision accepted. Previous failures remain preserved.
3. Actual CUDA-decoded sample audit exposes the nominal-time exclusion flaw:
   fps2 and fps6 select different source timestamps within their output bins.
   Registered exit references 18/48 lie 0.167/0.166s from held-out 506/516,
   inside the declared 0.2s gap. Entry reference 12 also violates that gap;
   reference 14 is an identical source alias of registered frame 207. None of
   the original 69 queries is an identical training bitmap. New guards reject
   the affected Grand trials/old audit before fitting or overwriting reports.
   Conservatively excluding two affected queries leaves **44/69** split-point
   passes; this is accounting, not a newly validated model or independent capture.
4. Existing doorway-walk-v7 passes all 24 native/RTX Chrome checks plus actual
   WASD round trip. Godot 4.7.2 p95 8.87ms; Chrome 154 1100×760 ready 2.644s,
   sampled p95 16.67ms. RTX4070SUPER D3D12 verified in both; visuals inspected.
   Shell has four failures, all names seen at 06:30. Repository, Python, pose,
   decoder checksum/negative-control, historical-preservation and diff checks
   pass. Eight ObjectDB leaks warned. Not a green integrated build/full map.
5. Muse frame/sheet and failed head v2 inspected; $0.02 combined receipts and
   never-resubmit unchanged. Tick $0. Remaining blockers: corrected frozen
   validation, independent scale, reference coverage/full aperture, quality
   contract #181, sculpture holes/rear coverage and UV/bake acceptance. No
   runtime or 3D Viewer edits, production integration, paid calls or closures.
   Automation 99695359-522b-46ce-bb00-078657d105ea remains enabled/reuseSession=true
   because the requested connected map is incomplete. No unfinished job.

Evidence: docs/evidence/collection-reconstruction/heartbeat-20260930T0700/.
Decoder commands, original raw gzip logs, source/output hashes and runnable
sampling auditor are retained. The original model and evaluated pixels stay
unchanged. Only this tick's changes are checkpointed on the prototype branch.

https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/heartbeat-20260930T0700/

Sampling correction, rejected right shoulder, and bounded doorway walk.
