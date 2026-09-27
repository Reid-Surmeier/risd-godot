# Visitor texture-bake trial

The isolated `Reid-Surmeier/gallery-visitor-uv-bake` branch at `0f690ea` contains a reproducible Blender 4.3 source-image → UV albedo/AO → skinned GLB → Godot Compatibility pipeline. Its [source-backed recipe](gallery-visitor-uv-bake-sources.md) records the Blender, glTF, and Godot transfer seams. The source image was an authored placeholder; this trial did not call Muse or spend money.

The rig stayed intact (41 joints, 76 animations); the Godot import found both 512² maps; contact checks passed. Matched RTX 1600- and 720-pixel entry/white-room captures and 720-pixel motion are in the isolated branch's `docs/evidence/gallery-visitor-uv-bake/`. At the actual embedded 720-pixel viewer size, the baked shirt showed **no clear visual improvement** over the current solid-color shirt. The compressed game pack grew by 8,966 bytes; a sequential, cache-confounded browser pair does not establish a load-time change. The candidate remains isolated and is not the default gallery asset.

The bake route is ready for a deliberately authored texture when there is a texture whose detail survives the viewer's size. A shirt-only bake did not fix the character/room lighting mismatch found in the [blind review](gallery-final-blind-gaps.md).
