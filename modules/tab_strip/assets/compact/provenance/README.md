# Compact taskbar pieces (Issue #113)

Every pixel here is copied from one Muse output; nothing is drawn.

- Source: Muse (`meta/muse-image`, OpenRouter) run `run-b443ade33509293fc5b17b6b`, pass 16 of the owner's taskbar edit loop, cropped band `pass-16/review/band.png` (sha256 `b4298d8ceb14cfd7e86cf1914357625583b5a5488faa34b28c14b7cfc07a7e4c`). Cost 0.01 USD; the whole loop spent 0.09 USD.
- `rebuild.py` re-lays that band out (owner-approved exception to the conformance-only rule): 1.5x equal tabs, icons one pad from each slanted edge, labels a fixed gap after, halo-free icon cut-outs, tray moved onto the tab axis.
- `export_game_assets.py` slices the result into these pieces and `layout.json`, and composes the bar from the pieces the way `tab_strip.gd` does, to check the slicing and render the selected-tab variations.

Run both from `image-work/taskbar-pixel-tabs-loop/rebuild/` in the main checkout (the band lives there).
