# Integrated 42° camera export

The `22089e5` Web export includes the 42° dollhouse pitch tested in [the matched A/B](../gallery-camera-pitch/README.md). Its other production assets match the prior `105551c` export. The 42° view reduces the measured exposed dark corner background by 25% at the reproduced pose; the finite-wall exposure remains.

The exported shell was tested through the active share in Chrome on ANGLE D3D12 / NVIDIA RTX 4070 SUPER. [Browser JSON](browser.json) records a successful entrance, mouse drag, horizontal-wheel turn, fresh opposite-wall event, camera switch, and lighting switch. Standing, walking, and turning each had 16.7 ms p95 rAF timing. Transfer was 113,745,585 bytes. The Linux/RTX result does not establish Mac M3 performance.

Visual evidence: [entry at 1600](entry-1600.png), [opposite wall at 1600](opposite-wall-1600.png), and [opposite wall at 720](opposite-wall-720.png). The opposite-wall capture visibly includes three paintings. Existing console messages include a missing favicon, GLES3 2D MSAA support warning, and `arrow_cursor` metadata errors; no page exception or failed browser control occurred.

`scripts/check.sh` and `git diff --check` passed after the camera edit. The browser run using the default `DISPLAY=:99` used llvmpipe, so only the D3D12 run above is used for the frame-time statement.
