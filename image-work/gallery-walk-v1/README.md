# Gallery walk v1 — PROTOTYPE stills (2026-09-25)

Muse (`meta/muse-image`) edit passes that rebuild one RISD Museum gallery (the Impressionist room) from the
owner's walkthrough video `IMG_6343.MOV` (Proton Drive `/my-files/OBJ/`, local copy
`~/risd-godot-ingestion/walkthrough/`). Reference 2 of every pass is the owner's 8-bit gallery example,
`references/style-grand-gallery-8bit.png`.

- `gallery-walk-v1/`: six walk stops, `walk-prompt.txt`. Source frames: the sharpest frame within ±0.5 s of
  91 s (n0 doorway), 94 s (n1 room), 96 s (n2 right wall), 112 s (n3 poppy wall), 115 s (n4 Le Repos wall), 145 s (n5 reverse).
- `gallery-walk-v1-closeups/`: five painting close-ups, `closeup-prompt.txt` (video frame at 98 s sailboats,
  102 s road, 116 s Le Repos, 124 s bonnet portrait) and `closeup-real-prompt.txt` (the museum's own IIIF photo of
  Monet, *A Walk in the Meadows at Argenteuil*, 1998.107, `iiif.micr.io/UJbzC`, plus the 110.5 s frame).

Source frames (`source/`) and raw run folders (`artifacts/`) are not committed; the frames re-extract from the
video at the times above. Results are in `review/`; the game copies are in `modules/shell/prototype/gallery_walk/stills/`.

Spend: 11 Muse passes via OpenRouter at a declared $0.01 each = $0.11 (actual cost reported as unknown by the pipeline).
