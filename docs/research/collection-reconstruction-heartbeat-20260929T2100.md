# Collection reconstruction checkpoint — 2026-09-29, 21:00 UTC tick

**Next action:** distinguish the right doorway inner jamb/floor toe from its
bevel/shadow using additional source views. Keep the failed `doorway-triangulation-v1`
picks unchanged; reserve fresh validation pixels before fitting a successor.
Then measure the lintel and observed floor patches on both sides before building
collision surfaces. Do not repeat completed held-out or CUDA depth sweeps.

Scope: [Collection map #178](https://github.com/Reid-Surmeier/risd-godot/issues/178),
[connected-room prototype #182](https://github.com/Reid-Surmeier/risd-godot/issues/182).
Read live processes, session tails, git, module docs and #181–183. Prior heartbeat
had finished at 20:54 UTC; other active work was in a separate checkout. Existing
uncommitted work was preserved. Prototype branch only; no runtime, 3D Viewer,
frozen acceptance files, production integration or ticket closures.

## New measurements

1. Existing frozen-model audit remains **49/69** supported nearby held-out frames,
   **46/69** under disjoint-point pose validation. Source hashes still match.
   Completed runs were not launched again.
2. `doorway_triangulation.py` triangulates the actual two inner jamb/floor points
   from three registered views, without fitting the stepped casing as a plane.
   Ray angles: **7.46° / 5.74°**. Held-out `IMG_6380/000506.jpg` errors:
   **2.22 / 9.18 px**. The right corner **fails** the exploratory 8 px diagnostic;
   annotations and threshold were not changed to obtain a pass. The pose uses
   316 odd-ID feature inliers, excluding features within 20 px of the annotations.
3. Opening width: **1.851 provisional m**. With 3 px pick perturbations, the
   10th–90th percentile is **1.760–1.955 m**, not a confidence interval.
   Compared with the earlier depth floor, corner offsets are **−1.8 / −7.4 cm**,
   versus the prior casing-plane trial's 50 cm discrepancy. This is improved
   consistency, not certification of the depth floor, walls or walkability.
4. `bookcase_extents.py` triangulates top-rail ends and two castor contacts from
   frames 292/297. Catalogue width and height imply **2.631 / 2.585 m per model
   unit**, **1.76%** apart; previous scale was 2.627. Held-out frame 296 predicts
   all four manually reserved landmarks within **3.85 px** (622 pose inliers).
   This cross-check avoids a whole-object planar assumption, but exact catalogue
   extrema, castors and floor-derived vertical remain uncertain. It is the same
   object and correlated video geometry, not an independent metric anchor.
5. Added shared source-pixel camera adapters in `measurements.py`. Synthetic
   triangulation recovery, rotation-coordinate roundtrip, positive depth and
   a displaced-annotation negative control pass. Source images, frozen model,
   annotations, outputs and generators have recorded hashes. CPU pose/ray
   arithmetic only; no new feature/matching/depth sweep or paid calls (**$0**).

## Evidence and checks

[Private evidence page](https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/heartbeat-20260929T2100/)
reuses the existing registered preview. Fit/held-out overlays and Shell resize
capture inspected. Browser report checks the static evidence page, not a game.
Committed reports, images and logs: `docs/evidence/collection-reconstruction/heartbeat-20260929T2100/`.

- `scripts/check.sh`: passed, existing eight ObjectDB leak warning.
- `scripts/playtest.sh shell`: **six failures**, on unchanged runtime/tests:
  launch white area, click tint timing, dip timing, tenant fill, grey appearance,
  resize fill. Existing desktop chrome is visible in the resized capture.
  No scope expansion or frozen-test edits to conceal those failures.
- Python compilation and `git diff --check`: passed.
- Both measurement scripts ran successfully with assertions. Doorway diagnostic
  failure is recorded data, not misrepresented as a passing navigation gate.

Reproduce with the ingestion `.venv/bin/python` and prototype script paths.
Local outputs: `doorway-triangulation-v1/`, `bookcase-extents-v1/`,
`heartbeat-20260929T2100/`, under `/home/reidsurmeier/risd-godot-ingestion/collection-expansion`.

Remaining blockers: right jamb measurement, doorway height and floor/wall
coverage, independent metric confidence, connected browser walk/collision/camera
and performance checks, sculpture holes/rear coverage and lighting bake. #181's
quality/topology choices remain open. Existing Muse receipts total **$0.02**;
no paid retry. Automation remains enabled because connected Collection work is
not verified complete.
