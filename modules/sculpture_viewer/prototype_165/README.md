# Throwaway square Viewer catalogue — Issue #165

Question: Which 1080-square arrangement makes a five-by-four catalogue, selection detail and enlarged lower-left hover preview legible beside the existing RISD Museum styling?

Run from the repository root with one command:

```bash
env -u WAYLAND_DISPLAY DISPLAY=:99 godot --display-driver x11 --rendering-method gl_compatibility --resolution 1080x1080 --windowed --path . --script modules/sculpture_viewer/prototype_165/run.gd
```

Press F1/F2/F3 (or click the dark prototype bar) for split catalogue, gallery-first, or mirrored split. Click a thumbnail to update the name, department-verification state and 3D availability. Hover a thumbnail to open the larger lower-left preview. For the existing animated catalogue icons it plays their Seedance frame atlas; the four scan-source entries show their actual matched 2D capture and explicitly say 3D preview unavailable. The four scans are not live because none passed #154's full-orbit visual gate. Buddha remains outside this 20-entry selection.

Add `-- --capture` to the run command for nine 1080-square PNGs in `evidence/` plus input/state assertions. These are native Godot captures, not a browser mock-up. The first four captures are indexed by source timestamp; the remaining sixteen are existing panel cells 6–17 and 19–22, in that order. Human museum titles and departments are intentionally unasserted. The 2D captures and panel art stay in this throwaway branch and are not runtime-accepted assets.
