# Grand Gallery v4 — PROTOTYPE: the whole room (2026-09-26, map #116)

- `canvas/`: RISD's own CC0 photographs of all 23 works via Wikimedia Commons (`works.json`: Wikidata items, files).
- `views/find_views.py`: each photo SIFT-matched to every video frame (3 fps); best views rectified with the frame (`views.json`).
- `frames/`: 20 Muse empty-frame passes, each prompt naming the real frame's profile and ornament (plus W3, W7 from `painting-asset-v1*`).
- `surfaces/`: Muse floor, wall, skylight tiles and the two views through the doorways.
- Game: `modules/shell/prototype/gallery_walk4/` — order, sizes and heights from `docs/research/grand-gallery-hang.md`; frames as
  3D nine-slices at their real band widths; room 26 × 11.5 m (estimate), even gaps per wall (estimate, the video survey refines it).

Spend (OpenRouter, Muse, declared $0.01 each): 25 passes = $0.25.

## Round 6 (owner feedback, 2026-09-26)
- `frames2/`: 22 frames redone as Muse *edits of each frame's own straightened video photo* (canvas blanked, magenta outside) — the
  frame's real outline, band widths and ornament come from the photo, not from a description. The Veronese (S1) from RISD's Jan 2026
  photo (its video views were blurred). `stone.png`: Muse limestone for the arch portal. 24 passes, $0.24 declared.
- Look: `ps1.gdshader` — a Godot 4 port of Mighty Duke's CC0 "PS1 Shader" (godotshaders.com) with vertex snapping and affine texturing,
  lit per pixel; 15-bit colour with 4x4 ordered dither after the render; baked occlusion in vertex colours; soft baked shadows under
  every frame and bench; lighting from overhead (skylight) as in the game's 3D viewer. Lighting reference: the owner's Animal Crossing:
  Wild World E3 2005 trailer (flat top light, soft contact shadows).
