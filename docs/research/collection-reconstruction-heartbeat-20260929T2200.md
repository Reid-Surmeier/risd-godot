# Collection reconstruction checkpoint — 2026-09-29, 22:00 UTC tick

**Next action:** validate near-side floor geometry across registered views before
collision surfaces. Start with cached depth `IMG_6380_exit6fps/000018.jpg` and
review the pre-crossing views; distinguish actual slope/threshold from noisy
close-floor depth. Preserve both floor trials and both doorway validation
outcomes. No repeat of completed all-reference holdout, matching or depth sweeps.

Scope: Collection map #178, prototype #182; #181/#183 read and left open.
Live Orca terminal tails showed prior workers interrupted/idle, including the
21:30 aperture worker. No concurrent writer or reconstruction job was running.
Recovered that worker's completed aperture result and source; all other existing
uncommitted sculpture, geometry and provenance work was preserved. Prototype
branch only; no runtime, 3D Viewer, frozen tests or production integration edits.

1. Existing held-out model remains 49/69 supported, 46/69 split-point passes;
   nearby same-video samples, not independent capture accuracy. No rerun.
2. Reran `doorway_aperture.py` using its cached completed matches. Source/model
   hashes and synthetic ray checks pass. Four reserved corners in exit frame 15
   have errors 1.43, 1.72, 4.11, 3.20 px. Bottom width 1.851 provisional m;
   left/right heights 2.432/2.511 provisional m. Earlier frame 506 still fails
   at 9.18 px; the new passing frame does not erase it.
3. New `floor_patches.py` fits the existing near/far masks separately. Original
   view 505 near patch: 200/50,326 valid depth pixels (0.40%), too few for the
   declared 100-fit/100-check split. Far patch: 2,883/2,916 (98.87%). The old
   combined floor fit was overwhelmingly far-side evidence.
4. Reviewed later frame 18, with new explicit masks: near coverage 66.48%, far
   99.48%. Spatial-block check support within 25 provisional mm: 53.38%/67.46%;
   90th-percentile residuals 6.80/4.21 cm. Normals differ 3.958 degrees. At the
   jamb toes, far-minus-near extrapolated levels are +5.42 / −3.85 cm. This does
   not establish a level join, a real step or an accepted collision floor.
5. Inspected aperture, both depth masks and Shell resize screenshot. Repository
   check passed (eight existing ObjectDB leak warnings); synthetic plane recovery
   and displaced-plane negative control passed; git diff check passed. Shell
   playtest on :99/llvmpipe failed seven existing layout/pixel/timing checks,
   retained in evidence. No GPU gameplay/performance claim.

Run the ingestion `.venv/bin/python` on
`modules/shell/prototype/collection_reconstruction/floor_patches.py` and repeat
with `--revisit` for the later frame. Outputs are `floor-patches-v1/` and
`floor-patches-v2/` under the ingestion root. Aperture is `doorway-aperture-v1/`.

[Review pictures](https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/heartbeat-20260929T2200/)
reuse the owner's existing private share. Committed reports, pictures, hashes
and check logs: `docs/evidence/collection-reconstruction/heartbeat-20260929T2200/`.

Blockers: unresolved floor consistency and doorway picks; room wall/extent
coverage; independent metric scale; connected browser walk, collisions, camera
and performance; sculpture holes/back coverage and UV/bake acceptance. Bookcase
scale remains provisional. Existing Muse receipts total $0.02 with the unknown
spend/never-resubmit flag retained. This tick spent $0. No issue closures or
owner acceptance inferred. Automation retained because map work is incomplete.
