# Collection reconstruction checkpoint — 2026-09-29, 22:30 UTC tick

**Next action:** measure identifiable floor/threshold landmarks in the original
1280×720 registered photographs, triangulate with `measurements.py`, and reserve
another view before fitting. Near-floor depth has failed cross-view support;
do not repeat completed holdout, matching or depth sweeps. Use the measured
aperture as the connection constraint; no level floor, step or full room shell
has been accepted. Browser walking and collisions remain ahead.

1. Read live processes, prior session completion events, Git, AGENTS.md,
   MODULES.md, Shell/testing docs and map #178 / tickets #181–183. Prior
   Collection workers were idle; the active other-map session uses a different
   worktree. No nested agents, new heartbeat loop, runtime/3D Viewer or frozen
   acceptance-file edits. Existing uncommitted work remains preserved.
2. Verified calibrated result: 475 views, 43,253 points, 0.639588 px fitted
   reprojection. Frozen model hashes match the completed holdout audit: 49/69
   supported and 46/69 split-point passes. These are nearby same-video samples,
   not independent capture validation. No reconstruction jobs rerun.
3. Added `floor_crossview.py`: project the frozen frame-18 near/far floor
   footprints into cached depth views, without refitting, hiding missing depth
   or rejecting disagreeing samples. Across three other usable near views,
   coverage is 3.8–18.6%; 90th-percentile plane errors are 7.5–14.5 provisional
   cm. Far coverage across four other views is 80.7–98.9%, with 4.0–7.3 cm
   errors. No near-floor sparse points exist inside these footprints; far has
   at most eight per view. Sparse points repeat between views, not independent
   samples. The available evidence cannot establish a physical step or slope.
4. Exit frame 14 has identical image/depth hashes to survey frame 505, so the
   comparison explicitly excludes the duplicate. Frame 26 near footprint
   crosses the camera plane and is recorded as not evaluated. Inspected all
   five distinct overlays: projected masks fall on visible floor, with expected
   frame-edge clipping and no visible plinth/case overlap. Same-view frame 18
   is a control; shared multiview stereo inputs are correlated.
5. Projection round-trip, plane intersection and displaced-plane negative
   control assertions pass. `scripts/check.sh` passes with eight ObjectDB leak
   instances warned. Shell playtest on :99/llvmpipe repeats exactly the seven
   prior failed check names; screenshot inspected. Browser page and all five
   images return HTTP 200 and load; the only console error is site favicon 404.
   Static report inspection is not gameplay/performance validation.

Evidence and hashes: `docs/evidence/collection-reconstruction/heartbeat-20260929T2230/`.
Raw trial: `/home/reidsurmeier/risd-godot-ingestion/collection-expansion/floor-crossview-v1/`.
Run: ingestion `.venv/bin/python` plus
`modules/shell/prototype/collection_reconstruction/floor_crossview.py`.

Private review:
https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/heartbeat-20260929T2230/

Blockers: unreliable near-floor geometry; room extent/wall coverage; independent
metric scale; connected browser walk, collisions, camera and performance;
sculpture holes/back coverage and UV/bake acceptance. Owner-approved Muse frame
and sculpture appearance receipts reviewed, combined $0.02 retained; no paid
calls this tick ($0). Bookcase scale stays provisional. All four issues remain
open; automation is retained because the requested map is incomplete.
