# Grand Gallery v3 — PROTOTYPE: the room rebuilt from the video (2026-09-26)

The Grand Gallery as a real-time 3D room whose walls are the real walls, measured from `IMG_6344.MOV`.

1. **Structure from motion** (pycolmap 4.2, CPU; venv `~/risd-godot-ingestion/.venv-sfm`): frames at 4 fps,
   sequential matching (`~/risd-godot-ingestion/sfm-6344-{west,east}/run.py`). The lap splits into pieces; the four used:
   west model 0 (33–62.5 s), east models 2 (63–91 s), 0 (92–135 s), 1 (141–160 s).
2. **Elevations** (`elevation/ortho.py`): per piece, fit the wall plane, take "up" from the cameras, project every posed
   frame onto the wall → an orthographic picture of the wall. `IMAX` drops the final turn to a wide view.
3. **Strips** (`elevation/strip.py`): level on the skirting, find the floor line, scale by an assumed 1.40 m phone height,
   find paintings (texture blobs; `*-rects.json` are rectangles marked by eye where detection failed), write a 48 px/m
   wall strip. **Details** (`elevation/sharpen.py`): for each painting, the sharpest correctly aligned view anywhere in
   that wall's stretch of video, re-projected straight-on at 700 px/m.
4. **Layout**: historical `modules/shell/prototype/gallery_walk3/layout.json` in Git history, metres from the arch end. The wall with the supper
   scene, Charity, the angel and the musical group is on the left from the arch end; the family-portrait wall on the right
   (from the elevation geometry plus the 0:25 wide shot; the walking-direction evidence was contradictory — confirm).
   Room length 35 m and width 12 m are estimates; gaps between pieces are estimates.

No paid calls in v3. Raw mosaics, levelled images and reference crops are not committed.
