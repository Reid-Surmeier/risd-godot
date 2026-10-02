# Collection reconstruction checkpoint — 2026-09-30, 00:00 UTC tick

**Next action:** extend the bounded doorway trial's checks to left/right jamb
clearance, return-side camera occlusion and a 720px browser. Then measure room
floor/wall extents from registered references before extending the walkable
patches. Do not repeat completed holdout or depth sweeps. This is a runnable
connection study, not the connected pair of finished rooms required by #182.

1. Read live Git, processes/session tails, Orca, AGENTS.md, MODULES.md,
   Shell/testing docs and map #178 / #181–183. Earlier Collection sessions were
   idle/interrupted; active workers were using the separate integration tree.
   Preserved prior dirty asset/scale/provenance work. Recovered the interrupted
   `corridor_floor.py` unchanged and its `corridor-floor-v2` evidence: an earlier
   video pass gives 16–25° ray separation, 4.81px reserved landmark maximum and
   2.58° p95 ±3px pick sensitivity. Its reserved camera contributed to SfM.
2. Frozen 475-view/43,253-point model hashes still match the completed audit.
   Existing holdout results remain 49/69 supported, 46/69 split-point passes;
   no rerun. New `wall_floor_landmarks.py` uses nearer views and is weaker:
   7.04° p95 sensitivity; reserved frame 12 left toe misses by 8.90px. Retained
   that failure; used the existing wider-baseline result for the trial.
3. Added an isolated Godot doorway walk, original identity visitor and gallery
   35° camera framing. Purple support triangle, gold interpolated threshold and
   teal visible-floor patch are explicit study limits, not invented room walls.
   Scale, floor levels and conservative jamb collision proxies are provisional.
   Native RTX and Chrome engine checks pass forward, reverse and right-jamb
   blocking. Real browser WASD input also crosses and returns on the floor.
   Visual inspection caught lintel occlusion; four sight rays now hide obstructing
   casing visuals while preserving collision. Final native/browser images inspected.
4. Chrome 154.0.8037.57, 1100×760, ANGLE D3D12 RTX 4070 SUPER: first ready
   2,493ms, sampled p50/p95 16.67ms, JS heap 67,599,035 bytes. Native RTX p95
   8.33ms. These are one short tiny-scene measurements, not full-game budgets;
   JS heap is not whole-process/GPU memory. Initial browser attempt used
   `index.html`; the existing share redirects that nested filename to the root.
   Directory URL below works and was tested. No new share mount.
5. Final `scripts/check.sh` passes (eight ObjectDB leaks warned); diff check
   passes. Shell playtest fails eight checks: the previous seven plus
   `page_cross_fades_through_in_between_greys` in this run. Saved comparison,
   log and inspected resized image; no Shell runtime or frozen test files changed.
   This is not a green integrated build. All map/tickets remain open.

Evidence and hashes: `docs/evidence/collection-reconstruction/heartbeat-20260930T0000/`.
Runnable sources: `modules/shell/prototype/collection_reconstruction/`:
`prepare_doorway_walk.py`, `doorway_walk.gd`, `doorway_walk.tscn`,
`doorway_walk_browser.cjs`. The generator takes a **new** output directory:

```bash
/home/reidsurmeier/risd-godot-ingestion/collection-expansion/.venv/bin/python \
  modules/shell/prototype/collection_reconstruction/prepare_doorway_walk.py /tmp/collection-doorway-new
godot --headless --editor --path /tmp/collection-doorway-new --import
GALLIUM_DRIVER=d3d12 MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA DISPLAY=:0 \
  godot --path /tmp/collection-doorway-new -- --selfcheck
```

Ingestion `doorway-walk-v1/` contains the tested native/Web build; `doorway-walk-v2/`
is a fresh generator check with identical geometry, fuller input hashes and plan.
The Web build is 41,103,101 bytes. Source/asset/model hashes accompany the evidence.

https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/heartbeat-20260930T0000/

Open **playable trial** for WASD traversal; coloured edges are test limits.

Blockers: measured room bounds and independent scale; whole-room navigation,
collision, camera and agreed performance criteria; sculpture holes/rear coverage
and UV/bake acceptance. Owner-approved Muse frame/sculpture receipts reviewed;
combined recorded $0.02 and never-resubmit states retained. This tick spent $0.
3D Viewer untouched. Automation 99695359-522b-46ce-bb00-078657d105ea remains enabled
with reuseSession=true because requested map work is incomplete.
