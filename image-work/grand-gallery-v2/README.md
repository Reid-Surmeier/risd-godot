# Grand Gallery v2 — PROTOTYPE stills and motion (2026-09-26)

The RISD Museum Grand Gallery, walked in third person, in the owner's NextRooms gallery style.

- **Source**: `IMG_6344.MOV` (Proton Drive `/my-files/`, local `~/risd-godot-ingestion/walkthrough/`). Frames: 104 sharp
  frames from the perimeter lap (west 27–62 s, north 62–73 s, east 73–167 s), grouped per painting into ordered
  wall sheets `references/wall-{west,east}-arch-to-door.png`; wide views at 25 s (north from the arch), 19 s (arch), 64.5 s (north door).
- **Style**: the owner's 2026-09-15 recipe (`~/muse-runs/nextrooms-gallery`: Muse `edit` with the NextRooms viewport as
  reference 1, then a retro reduction). `degrade.py` is that reduction as a script (colour match to
  `references/style-grand-gallery-final.png`, 480 px, 96 colours dithered, nearest up, scanlines).
- **Sweep** (`prompts/`, `review/`): v1 the recipe as-is, v2/v4/v5 anchored on the owner's approved gallery image,
  v3/v6 the kid from behind (Art Store camera). Chosen: **v4** (empty room) as the style anchor.
- **Stops** (`../grand-gallery-v2-stops`): s2, s3 north and r3, r2 south, each generated against the v4 anchor.
- **Motion** (`../grand-gallery-v2-motion-b`): Seedance 2.0 mini first/last-frame clips s1→s2, s2→s3 and a looping
  kid walk cycle from `review/kid-back-raw.png`. All three came back at a different size than requested
  (752x560 / 640x640), so the pipeline marks them verification failures: they are evidence, not deliverables.
  Room clips are conformed with `conform-room.sh` (12 fps held, same reduction) and trimmed at the frame that best
  matches the next still (frame 16 of 49 for both: Muse's steps are shorter than Seedance's walk).
  `../grand-gallery-v2-motion` holds the first attempt, rejected with HTTP 520 for unsupported sizes (640x640, 720x480).

Spend (OpenRouter): 11 Muse passes, declared $0.01 each = $0.11. Seedance: first attempt 3 runs, "possibly spent",
no job created (≤ $0.45 worst case, likely $0); second attempt 3 jobs, one recorded at $0.1358, two unknown (≤ $0.15 each).
Raw run folders (`artifacts/`) and source frames (`source/frames/`) are not committed.
