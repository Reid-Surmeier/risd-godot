# Collection page search evidence

Issue #79 replaces the decorative Search filters and fake artwork count with native Godot controls and verified RISD results.

`native/` is the accepted 1920x1080 and 720x486 playtest. `report.json` records every input and seam state, `verify.json` records 34 independently computed checks, and `SHA256SUMS` identifies the screenshots. The filtered-paintings image is the clearest review frame.

`browser/` is produced by `browser_play.mjs` from the fresh cache-keyed Web export and records real canvas keyboard/mouse input, response state, edge-bar measurements and served file hashes.
