# Grand Gallery v4 — PROTOTYPE: the whole room (2026-09-26, map #116)

- `canvas/`: RISD's own CC0 photographs of all 23 works via Wikimedia Commons (`works.json`: Wikidata items, files).
- `views/find_views.py`: each photo SIFT-matched to every video frame (3 fps); best views rectified with the frame (`views.json`).
- `frames/`: 20 Muse empty-frame passes, each prompt naming the real frame's profile and ornament (plus W3, W7 from `painting-asset-v1*`).
- `surfaces/`: Muse floor, wall, skylight tiles and the two views through the doorways.
- Game: `modules/shell/prototype/gallery_walk4/` — order, sizes and heights from `docs/research/grand-gallery-hang.md`; frames as
  3D nine-slices at their real band widths; room 26 × 11.5 m (estimate), even gaps per wall (estimate, the video survey refines it).

Spend (OpenRouter, Muse, declared $0.01 each): 25 passes = $0.25.
