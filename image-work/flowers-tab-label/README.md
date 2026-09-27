# Flowers tab label and icon (2026-09-25)

The Flowers tab's `icon_flowers.png` and `label_flowers.png` in `modules/tab_strip/assets/compact/`
come from one Muse pass; nothing is hand-drawn.

1. `compose.py` lays the game's own compact taskbar pieces out exactly as `tab_strip.gd` draws them —
   Collection, Playground, then a seventh empty tab and the stub — and crops that band:
   `input-seven-tabs.png` (every pixel copied from the pieces).
2. `pass.sh 01` is one Muse edit (`meta/muse-image` via `~/Image-generation-pipline/bin/image-pipeline`,
   OpenRouter; adapted from `image-work/taskbar-pixel-tabs-loop/pass.sh` in the main checkout):
   reference 1 the band above, reference 2 `style-left-tabs.png` (the rebuilt taskbar's Map,
   Sketchbook and 3D Viewer tabs, for icon and font style), prompt `prompt.txt`. Run
   `run-0eb871be00ebeea3313f1615`, **0.01 USD**, output `pass-01/review/full.png` (sha256 of the
   provider's webp `843a1709…d44a`). The run's cache under `pass-01/artifacts/` is not committed.
3. `slice.py` cuts the flower icon and the "Flowers" label out of that output with the same rule as
   `modules/tab_strip/assets/compact/provenance/rebuild.py` (darker-than-fill mask, specks dropped,
   icon = first run of columns) and resamples them by the pass's own Playground label width against
   `label_playground.png` (2.04x), so the glyphs are the existing labels' size. Place: icon at (58, 46),
   label at (149, 59) — the Playground tab's label row, the layout's 26 px icon-label gap.
4. `compose.py --check` renders `check-seven-tabs.png`: the bar with the new pieces in place.
