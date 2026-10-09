# Collection reconstruction checkpoint — 2026-09-29, 20:35 UTC tick

**Next action:** measure the doorway's actual jamb/floor intersections across
several registered views around `IMG_6380/000504–000507` and the corresponding
`IMG_6380_exit6fps` frames. Validate those measurements against withheld frames
before making collision surfaces. Do not repeat the completed held-out or depth
runs. Do not fit the stepped casing as a single plane again.

Scope remains [Collection map #178](https://github.com/Reid-Surmeier/risd-godot/issues/178),
[connected-room prototype #182](https://github.com/Reid-Surmeier/risd-godot/issues/182).
No 3D Viewer, runtime, frozen interface, production integration or ticket closure.
The existing prototype branch is `Reid-Surmeier/collection-reconstruction`.
Other visible Codex processes were in the main checkout, not this workspace;
no reconstruction process or completed calibrated holdout existed at preflight.

## Finished evidence

1. Ran `holdout.py --source sfm-calibrated-doorway-v1 --output heldout-calibrated-v1 --all-references`
   using the ingestion virtualenv. Frozen model: **475 views, 43,253 points,
   0.639588 px fitted reprojection error**. **49/69** nearby withheld frames pass
   the existing 20-inlier / 25% support rule. Twenty fail or remain weak.
2. Added and ran `calibrated_audit.py` using cached matches. It fits pose with odd
   3D point IDs and checks even IDs, with no shared point IDs between these sets.
   **46/69** pass this stricter diagnostic. At least 20 fit inliers and 20 test
   points below 4 px, each with 25% support, are required. Doorway frames 506 and
   516 predict **315/380** and **75/101** unused points within 4 px. The frozen
   sparse-file hashes remain unchanged; query names and nominal revisit times
   are excluded from training. These are nearby video frames, not independent
   capture sessions, and point splitting does not make the underlying geometry
   independent.
3. Shared-track consistency with original components 0 and 5: **99.92%** and
   **94.58%** of reserved point pairs within 2% of the corresponding component's
   radius. This measures consistency with correlated seed models, not absolute
   accuracy or an accepted room connection. A new flat Delacroix canvas scale
   trial found **zero supported views** in the joined model. The stepped
   bookcase scale is still provisional.
4. Ran a **61-view CUDA depth** trial at 640 px: **19,815 fused points**. The first
   subset trial failed because COLMAP exported 61 bitmaps but retained a
   475-view sparse model; automatic source selection reached missing files.
   `dense.py --image-list` now removes excluded frames from the disposable
   undistorted model and verifies the serialized selection and every bitmap
   before depth work. The corrected v2 completed; v1 and its failure log remain.
5. Added and ran `doorway_geometry.py`, with visible manual casing/floor masks.
   **Rejected:** casing support 37.1%, floor support 74.8% within 2.5 provisional
   cm; bottom-corner/floor discrepancy **0.501 provisional m**. A stepped/recessed
   casing and incomplete depth are not a reliable common plane. This does not
   by itself prove the joined camera model is wrong. No failed plane was turned
   into collision geometry. Observed depth, annotations, held-out overlays and
   plan were inspected. Sculpture v2 still visibly has holes/missing rear; no
   paid retry. Recorded prior Muse total remains **$0.02**, this tick **$0**.

## Review and checks

[Private evidence page](https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/heartbeat-20260929T2035/)
reuses the owner's existing three-day preview; no new share was created.
[Committed evidence folder](../evidence/collection-reconstruction/heartbeat-20260929T2035/index.html)
contains the numerical reports, pictures, source hashes and logs. Private raw
GitHub URLs are not used as image delivery links.

- `scripts/check.sh`: passed; existing eight ObjectDB leak warning.
- `git diff --check` and Python compilation: passed.
- `scripts/playtest.sh shell`: **failed eight checks** on unchanged runtime and
  acceptance files (white-page/layout expectations and input/fade timing).
  Inspected resize capture includes existing desktop/header chrome; failure is
  not silently waived. An isolated Xvfb retry could not open X11 and fell back
  to Wayland; it is not a passing test. Logs retained in ingestion.
- Review page: HTTP 200, six images loaded in Chrome, no page errors. This is a
  report-page check, **not** a game performance or connected browser walk test.

## Local artifacts and reproduction

Ingestion root: `/home/reidsurmeier/risd-godot-ingestion/collection-expansion`.
Use its `.venv/bin/python` for scripts in
`modules/shell/prototype/collection_reconstruction/`.

```sh
python calibrated_audit.py
python dense.py --run sfm-calibrated-doorway-v1 --component 0 \
  --output dense-doorway-calibrated-v2 --size 640 \
  --image-list /home/reidsurmeier/risd-godot-ingestion/collection-expansion/doorway-depth-views.txt
python doorway_geometry.py
```

These commands document the completed work; inspect existing results/processes
before deciding to rerun. Keep previous trials. `heldout-calibrated-v1/audit.json`
records the exact frozen sparse hashes. `dense-doorway-calibrated-v2/fused.ply`
and `doorway-geometry-v1/` hold the depth and rejected measurements. CUDA sweeps
ran on GPU 0 (RTX 4070 SUPER); fusion and pose checks are CPU. The known Ceres
CPU optimization fallback remains; this tick did not rebuild the camera model.

Remaining blockers: reliable doorway surfaces, independent metric anchor,
connected walk/collision/camera checks, browser performance, sculpture geometry
and lighting bake. Quality/topology decisions in #181 remain open. Automation
stays enabled because the requested connected Collection work is incomplete.
Earlier uncommitted asset/geometry work remains preserved for the next tick.
