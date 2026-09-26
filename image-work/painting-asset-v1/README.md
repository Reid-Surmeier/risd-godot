# Painting Asset v1 — PROTOTYPE (map #116, "the Painting Asset recipe on three paintings"), 2026-09-26

Muse `edit` passes, one per part, from two video views of each painting:
- **Frame** (`prompts/*-frame-v2.txt`, and `../painting-asset-v1b/prompts/music-frame.txt`): the empty frame head-on, opening pure white,
  the frame's *real* profile and ornament named in the prompt. The first attempt (`*-frame.txt`, with the game's low-poly frame as a
  style reference) invented rosettes and friezes on both plain frames — so the style reference is dropped and the real ornament is described.
- **Canvas** (`prompts/*-canvas.txt`): the picture only, straight-on, de-glared, faithful.
- **Shaped** (`prompts/angel-shaped.txt`): the whole cartouche canvas with its gilt edge on a magenta matte.

Built in `modules/shell/prototype/gallery_walk3/painting_asset.gd`: frame texture on a front face 9 cm off the wall, side faces from the
frame's own band colours, canvas inset 3 cm; shaped works as a keyed slab 4 cm off the wall. The detail view uses the same frame
texture as a nine-patch around the same canvas (one master).

Spend (OpenRouter, Muse, declared $0.01 each): 10 passes = $0.10; two Charity canvas passes were blocked by the provider
("possibly spent", no image) — likely a content filter on the painting's nude infants, so Charity was replaced by the musical group.
