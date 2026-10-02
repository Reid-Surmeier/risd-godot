# Collection checkpoint — 2026-09-30, 04:00 UTC tick

**Next action:** measure floor/wall junctions defining the first room's observed
extent using wider-baseline IMG_6380 references and the existing `measurements.py`
triangulation helpers. Reserve a view before picking training pixels. Reuse
`corridor-floor-v2`; do not substitute the weaker `wall-floor-landmarks-v1` plane,
invent missing walls, or rerun completed holdout/depth sweeps. Then extend only
the supported floor patches in the isolated walk study.

1. Read live sessions/processes, Git, operating/module docs and #178 / #181–183.
   The other Collection terminal was interrupted and idle. Resumed this branch;
   preserved all earlier dirty asset, scale and provenance work. Ten verified
   originals match manifest sizes/SHA256. The frozen model still has 475 views,
   43,253 points and 0.639588px reprojection error; audit model hashes match.
   Completed holdout is 49/69 supported and 46/69 point-split passes, with no
   independent capture or metric acceptance. No rerun.
2. Added ten isolated movement trials plus camera checks: both jambs from both
   sides, left/right clearance round trips and original centre traversal. Actual
   slide contacts distinguish casing blocking from a floor-edge stall. Initial
   diagonal targets slid into the opening; a right rear straight target also
   passed inside the casing. Preserved these results and aimed the final rear
   test at the actual proxy. These are trial corrections, not museum geometry
   fixes. Visual inspection then found casing clipping missed by centre rays;
   intermediate shoulder rays now hide it while retaining collision.
3. Final `doorway-walk-v6` passes all 20 checks natively and in Chrome 154 on
   RTX 4070 SUPER at 720×760 and 1100×760, plus real WASD round trips. Inspected
   browser forward/return/jamb images and native before/after. First ready:
   2,931 / 4,476ms; sampled p95: 16.67 / 33.33ms (narrow/wide); native 11.11ms.
   Short tiny-scene samples, not accepted full-map budgets. An earlier browser
   run used llvmpipe and is excluded from GPU claims. One native X connection
   broke; its log remains in `doorway-walk-v4/evidence/`; final RTX run completed.
4. Final repository and diff checks pass; eight ObjectDB leaks warned. Owning
   Shell playtest retains the same eight failures as the preceding checkpoint;
   comparison/log and inspected resized image retained. No runtime/frozen files
   or 3D Viewer changes. This is not a green integrated build.
5. Evidence, generator/input/output hashes and source pointers are in
   `docs/evidence/collection-reconstruction/heartbeat-20260930T0400/`. Native/Web
   builds remain in ingestion `doorway-walk-v6/`. Browser reproduction:
   `GALLIUM_DRIVER=d3d12 MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA DISPLAY=:0 node
   modules/shell/prototype/collection_reconstruction/doorway_walk_browser.cjs
   <preview>/walk/ <new-output-folder> 720` (use 1100 for the wide run).

https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/heartbeat-20260930T0400/

Playable bounded doorway, camera before/after, both browser sizes and results.

Blockers: reference-backed room extents and independent scale; final navigation,
camera and performance contract; sculpture holes/rear coverage and UV/bake
acceptance. Muse frame/sheet and failed head render inspected; existing unknown
spend / never-resubmit receipts unchanged, combined recorded $0.02. This tick
spent $0. #178 and #181–183 remain open; no production integration. Automation
99695359-522b-46ce-bb00-078657d105ea is enabled with reuseSession=true because the
requested connected map is incomplete. Existing private share reused.
