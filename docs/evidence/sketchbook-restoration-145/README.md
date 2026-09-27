# Sketchbook restoration — #145

Implementation and export: `a4ebdea2`. Exact original gold frame and mountain/church painting restored; palette v7 restored with pencil and eraser interaction, registered paint wells and mixing trays. Existing six catalogue paintings remain. A seeded browser collection verifies that saved artworks remain while the obsolete reference panel stays hidden.

Original assets and SHA-256 hashes: [module provenance](../../../modules/sketchbook/PROVENANCE.md). No paid generation, bitmap edits, source moves or cleanup. The new palette runtime asset is 1.2 MB; original generation records remain in the verified Proton preservation catalog.

Review `desktop.png`, `original-frame-enlarged.png`, `palette-mixing.png` and `compact.png`. Screenshot capture disables CRT for clear asset inspection; these images do not claim completion of the separately requested gallery retro-rendering work.

Verification: `scripts/check.sh`, direct GDScript parse checks, `git diff --check`, and `modules/sketchbook/playtest/coverflow.mjs` through the shared tailnet URL. The browser test seeds an isolated profile with two saved artworks, checks all seven paintings, pencil/eraser selection, pigment deposit/mixing, viewer navigation, drawing/page retention, dragging/resizing, tab freeze/resume and smaller viewport. Repository checks retain the existing six ObjectDB exit warnings.

The first browser pass caught an inferred-type GDScript parse error, corrected with an explicit Vector2. The next caught a test reading QA state before its next update; it now waits for the actual tool state. Final results are recorded alongside this file. No green GitHub CI or owner visual acceptance is implied.

Preview: https://windows-wsl.taile06c45.ts.net/sketchbook-coverflow-01a0df0c/a4ebdea2.html
