# Collection reconstruction checkpoint — 2026-09-29, 23:00 UTC tick

**Next action:** seek wider spatial support from near-room wall/baseboard–floor
intersections in the registered photographs, with a reserved view chosen before
fitting. Use the existing aperture as a connection constraint. Do not extend the
narrow threshold plane into the room, repeat completed holdout/depth sweeps, or
spend another tick fitting the same five threshold points. Room extents and the
near floor still need evidence before the connected collision/browser walk.

1. Read live Git, processes, Orca terminal states, AGENTS.md, MODULES.md,
   Shell/testing docs and map #178 / tickets #181–183. Earlier Collection
   sessions were idle; no competing reconstruction writer/job. Existing dirty
   sculpture, geometry, scale and provenance work is preserved. Prototype
   branch only; no runtime, 3D Viewer or frozen acceptance-file changes.
2. Frozen 475-view/43,253-point model hashes match the completed holdout audit.
   Its 0.639588 px fitted error is not held-out accuracy. Existing results stay
   49/69 supported and 46/69 split-point passes; no rerun. Nearby same-video
   validation is correlated, not independent capture evidence.
3. Added `threshold_landmarks.py`: five frozen manual landmarks, training
   frames 13/18, reserved frame 15. Cached matches only; 280 pose-fit inliers.
   All reserved pixel errors are 1.33–3.40 px; ray angles are 5.74–8.36°.
   The corner plane still fails as a reliable floor: the excluded knot is
   4.75 provisional cm away. ±3 px pick perturbations produce a 21.05°
   95th-percentile normal deviation. This is sensitivity, not a confidence
   interval. Jamb-derived verticals disagree by 4.71° and do not settle gravity.
4. CUDA-decoded just three native 1920×1080 source frames, preserving the
   existing seek/fps/filter ordering and original video hash. Inspected native
   floor crops: motion blur/repetitive boards still limit confident junction
   picks. No new reconstruction feature/matching/depth sweep. All three
   landmark overlays and the measured plan/elevation were inspected. Neither
   a level floor, step, slope nor physical wall thickness is accepted.
5. Synthetic plane recovery, displaced-plane negative control, ray round-trip
   and shifted-pixel negative control pass. `scripts/check.sh` passes with
   eight ObjectDB leak instances warned. Shell playtest on :99/software
   rendering repeats exactly seven prior failed check names; resized screenshot
   inspected. Browser report and all seven images return HTTP 200; Chrome
   screenshot inspected. Static report review is not gameplay validation.

Evidence, annotations, source commands, hashes and logs:
`docs/evidence/collection-reconstruction/heartbeat-20260929T2300/`.
Raw measurements: ingestion `threshold-landmarks-v1/`.
Native references: ingestion `threshold-source-native-v1/`.
Run: ingestion `.venv/bin/python` plus
`modules/shell/prototype/collection_reconstruction/threshold_landmarks.py`.

https://windows-wsl.taile06c45.ts.net/risd-frame-review-01a0ee18/heartbeat-20260929T2300/

Blockers: broad near-floor and room extent support; independent metric scale;
connected browser walk, collisions, camera and performance; sculpture holes/back
coverage and UV/bake acceptance. Owner-approved Muse frame/sculpture receipts
reviewed, combined recorded $0.02 retained with never-resubmit flags. This tick
spent $0. Bookcase scale remains provisional. All issues remain open. Automation
99695359-522b-46ce-bb00-078657d105ea verified enabled/reuseSession=true; retained
because map work is incomplete. Existing private share reused; no new mount.
