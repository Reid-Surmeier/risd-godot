# Square Viewer catalogue — Issue #170

Layout C from prototype #165 (`ea9c8205`) is integrated into the real
seven-tab application. `before.png` is the previous build's Viewer;
`tab-3d_viewer.png` is the integrated initial state. Selected scan and
image-only states are `selected-02.png` and `selected-19.png`;
`hover.png` distinguishes hovered Bull from selected turtle.

Native Godot 4.7.2 Compatibility, X11 :99, Mesa llvmpipe, 1080×1080.
Run: `scripts/playtest.sh sculpture_viewer /tmp/viewer-170-final`.
All seven real tab clicks and all twenty card clicks passed. The independent
verifier checked five-row/four-column geometry, source identifiers, changed
detail/preview pixels, hover animation, frozen input/processing and return.
`report.json` records the interactions; `verify.json` binds screenshot hashes.
Screenshots are local renders, USD 0, with no generated replacement artwork.

Web loader HTML/WASM/PCK and the game PCK exported successfully with the existing
`Web` and `Web Game` presets. A headless probe mounted the resulting game PCK,
created the Viewer through its interface and verified twenty cards and false
`3d_preview_available`. No new candidate GLB ships.
`scripts/check.sh` and `git diff --check` passed.
The native renderer reports its pre-existing OpenGLES fallback and unsupported
2D MSAA warnings; the baseline headless exit reports 13 leaked ObjectDB instances.

The unchanged `embedded_viewer()` still supplies the separate Buddha viewer to
Sketchbook. Runtime scan acceptance remains blocked by #154/#157, and official
museum metadata by #169. The clipped shared desktop icon captions are tracked
separately in #172; no Shell interface or frozen Shell test changed.
