# Impressionist rooms: the plan as filmed against the plan as built

Research only, 8 October 2026, branch `research/impressionist-plan` off `integration/next` at `8ee6f25a`. No game source is changed here. The owner wrote after playing the build: "you made a major artheciiual mishap with the floorplan and the impressionist room placment. look back at that."

## The answer

The build enters the Impressionist rooms through the wrong door.

- **Filmed:** the visitor comes through the columns into the marble stair hall, turns right, and goes through the cased doorway in the hall's **south** wall, beside the fire alarm pull and the arch with the stair going down. A short straight passage leads into gallery A with Manet's *Le Repos* dead ahead.
- **Built:** the **EXIT door under the stair's half-landing** was opened instead. A passage was added beyond the half-landing's window wall, then a second "return" passage to bring the visitor back west into gallery A. Neither passage is in any frame. The real doorway is still built shut (`PassageDoorClosed` in `marble_hall_additions.gd`).

Galleries A and B themselves are on the correct side of the correct neighbours, the right way round, with their windows on the correct wall. Two further things are wrong inside them: A's entry is at the wrong end of its north wall, and B's pictures are on the wrong walls.

**Second finding, from the museum's own Floor 5 map (added after the owner wrote "look back at the floorplan").** The map agrees with the footage on every door. It also shows that the two galleries are built too long: about 9.7 and 9.6 m against about 6.8 and 7.6 m. They were stretched to run the length of a Grand Gallery that is itself built about 6 m too long (26.3 m against about 20.4 m). See "The museum's Floor 5 map" below.

![Plan as built beside plan as filmed](plan-compare.png)

Three panels: as built, as filmed (doors and walls from frames, lengths left as built), and the museum's map redrawn at one scale. Top of the picture is plan -z, 26 px per metre, the scale and orientation of the orchestrator's `plan-as-built.png`. Redraw with `python3 docs/evidence/impressionist-plan/plan.py`.

## What I watched

| Clip | How much | What it gives |
| --- | --- | --- |
| `IMG_6343.MOV` (SDR) | All 264 s at 1 fps; 83–92.75, 127–133.5, 139.5–146, 150.5–153.75, 174–180.5, 211.5–218, 222.5–229 s at 2–4 fps | The only clip that walks the route: grey gallery, stair hall, passage, A, B, modern gallery |
| `IMG_6380` survey frames | 49.0, 70.0, 71.0, 73.5 s upright; contact sheets | The stair hall's south door from the stair hall, with the gallery beyond |
| `IMG_6387` survey frames | 51.0, 68.0, 69.0, 69.5 s upright; contact sheets | The modern gallery's north door looking back into B |
| `IMG_6381` survey frames | 1.5, 90.5 s upright; contact sheets | Stair hall from the west and from the stair |
| `IMG_6344.MOV` | 3 of 8 one-per-second sheets | Lion landing, medieval room, Main Hall long walls |
| `IMG_6378`, `6379`, `6382`–`6386` | Not re-watched | Per `docs/playtest/census-2026-10-08-rooms.md` these are the auditorium, the Skylight Gallery, the medieval and Renaissance rooms and the adjacent gallery. INFERRED that none shows the Impressionist rooms |

Times are seconds in the named clip. Frames were pulled with ffmpeg into the session scratchpad; only the two sheets and the plan in this folder are committed. Footage is reference only.

## The route, doorway by doorway

![Stair hall to gallery A](doors-1-stair-hall-to-A.jpg)

![Gallery A to the modern gallery](doors-2-A-to-modern.jpg)

| Door | Time | Turn before | Seen through it before crossing | Turn after | Looking back |
| --- | --- | --- | --- | --- | --- |
| **X** EXIT door under the half-landing, stair hall east | faced at 84.5–86.5 s, **not crossed** | none; the camera walks east from the columns | A yellow-lit vestibule about one door deep, then a second opening with a dark glazed leaf | The camera turns right, away from it | Not filmed |
| **D1** stair hall south wall → passage | 88.25–89.5 s | One continuous right turn of about 90°, 86.5–88.25 s: EXIT door, fireplace (RISD 83.152), olive arch with a handrail going down, red fire pull, white cased doorway | Grey stone sill, oak floor, a white six-panel leaf on the left wall, a second cased doorway, *Le Repos* centred at the far end, three Monets edge-on at the right, a case at the left | None; straight on | Not filmed from the passage. `IMG_6380` 49.0 and 70.0 s show the same doorway from the hall with the gallery beyond |
| **D2** passage → A, north wall, west end | 91.0–91.75 s | None | As D1; panelled leaves folded into both reveals | Slight right to the Monet wall (92–96 s), then one left turn round the whole room, 96–141 s | 140.5 s from inside A: the lit passage and its low grille, immediately left of the north-wall portrait; 141.0 s: the first Monet on the west wall |
| **D3** A south wall, east end → B north wall, east end | crossed between 155 and 176 s with the camera pointed at the floor | At 164–175 s a panelled window apron and floor grille pass beside the feet | 152.25 s: door at the corner beside A's second window; B's window and a further doorway beyond, in line | Not seen. First frame in B is 177 s, facing its north-west corner | 215.5 s from B: Gauguin, Pissarro, then the door in the same wall at its east end, with A's two windows and the Degas through it |
| **D4** B south wall, east end → modern gallery north wall, east end | 224.5–226.5 s | Right pan along B's window wall: window, Cassatt, window (216.5–223.5 s) | Name strip above the casing (reads approximately "JEAN DI BONA GALLERY", not sharp); window on the left wall; gilt figure in a case on the left; oval painting, still life and an EXIT pair on the far wall | Right pan of about 60° to the large painting on the west wall (227–229 s) | `IMG_6387` 68–69.5 s from the modern gallery: B's window, Cassatt, window and the door to A on one line |
| **D5** modern gallery south wall, west end | 227.5, 240, 260–263 s, not crossed | — | Double fire doors with push bars and an exit sign; at 260–263 s open, a grey stone floor and more white doors | — | The clip ends at 263 s |

D3's crossing itself is INFERRED from the frames either side of it. Everything else in the table is VERIFIED from frames.

## Fixed anchors

1. **Windows.** A: two, on the left wall as you enter (143, 149–151 s). B: two, same side (216.5–218 s). Modern gallery: same side again (226 s; `IMG_6387` 51.0 s). One straight outside wall runs past all three rooms, and D3 and D4 are both at the window end of their walls, so the three rooms form a line with the doors in a row along the windows. VERIFIED.
2. **Stair hall half-landing window.** Three lights with a brick building outside, above the EXIT door (85–87 s). The built passage runs outside this wall at floor level.
3. **Service stair.** Behind the olive arch, going down (87.25 s; `IMG_6380` 73.5 s). It lies between the fireplace and the south doorway. The passage's left-hand service leaf (89.25 s) is on the wall toward it.
4. **Exit signs.** Over the EXIT door under the half-landing (86.0 s) and over the modern gallery's fire doors (227.5 s). None over D1–D4.
5. **Seen from two rooms.** *Le Repos* from the stair hall (88.25 s; `IMG_6380` 49.0 s) and in A (115 s). A's windows from B through D3 (215.5 s). B's Cassatt from the modern gallery through D4 (`IMG_6387` 69.5 s).
6. **No lift** appears between the stair hall and the modern gallery.

## The museum's Floor 5 map

Source: `https://risdmuseum.org/visitor-guide/floor-5`, image `Floor5-map-121420.png`, held at `~/risd-godot-ingestion/collection-expansion/review-preview/architecture-review-v39/risd-official-floor5-map.png` and recorded in `docs/evidence/collection-reconstruction/main-worker-hall-join-20261001T0620/floorplan-source.json`. I scanned its wall lines for pixel positions and redrew them in the third panel; the museum's image is not copied into this repository.

**Orientation.** Turned a quarter clockwise it matches the build with no mirror, as the lead read it: map-left is the stair and lift end, the bottom "European" is the long adjacent gallery, the top "European" strip beside the Radeke Garden is A, B and the modern gallery. VERIFIED against the footage: A's windows look onto planting and a brick wing, and every door below is where the frames put it.

**Doors, map against footage.** All agree.

| Door | On the map (pixels) | In the footage |
| --- | --- | --- |
| Stair hall → A | Gap in the strip's west wall at its Grand Gallery corner (x 503, y 323–348), directly below the stair's second flight (x 482–503, y 265–305) | D1/D2: stair hall south wall beside the upper flight and fireplace; A's north wall, west end |
| A → B, B → modern | Gaps on the garden side of both dividers (x 596 and 699, y 267–305) | D3, D4: window end of each wall |
| Modern → lion landing | Gap at the strip's far corner on the Grand Gallery side (x 785, y 322–348) | D5: far wall, right-hand (west) end |
| Stair hall, far side | An open corridor between the two flights running on toward Pendleton House (x 442–482, y 172–265) | X: the EXIT door under the half-landing, a lit vestibule and a second door beyond |

So the map has no passage off the stair hall's garden side leading to these rooms, and no return passage. It answers what is behind the EXIT door: a corridor to the Pendleton House and Greek and Roman galleries. The "short stair" beside A's door is the marble stair's upper flight. The short straight passage filmed between the hall and A is not drawn; the map puts A's end wall level with the Grand Gallery's, the footage puts it about 1.2 m further (2.0 ± 0.4 m of passage less the 0.76 m wall the build already has).

**Scale.** The map is called a schematic, but its widths fit one scale. Three widths the build already has give 13.6 px per metre: Grand Gallery 136.5 px for 10.0 m, long gallery 83.5 px for 6.1 m, strip 84 px for 6.15 m. At that scale the door positions also land on the build's: the Grand Gallery's north door at x 3.9–6.4 (built 4.55–6.55) and the modern gallery's landing door at x 10.7–12.6 (built 11.0–12.7). Lengths at the same scale:

| Room | Map | Built | Footage check |
| --- | --- | --- | --- |
| Gallery A, along the windows | 93 px = 6.8 m | 9.66 m | 6.2–7.4 m: at 146.0 s *Le Repos*' frame (about 1.47 m) is 118 px wide in a 720 px frame, and the lens is the 13 mm one (see below) |
| Gallery B | 103 px = 7.6 m | 9.60 m | 6.5–7.5 m by counting its window wall (corner, window, Cassatt pier, window, corner) |
| Modern gallery | 86 px = 6.3 m | 5.80 m | not re-measured |
| Three rooms together | 282 px = 20.7 m | 25.06 m | — |
| Grand Gallery length | 278 px = 20.4 m | 26.3 m | about 18–20.5 m: `IMG_6344` 24.0 s, far wall 290 px wide in a 720 px frame, 13 mm lens, camera about 1 m inside the south wall |
| Long adjacent gallery | 278 px = 20.4 m | 26.3 m | not re-measured |
| Stair hall, columns to its garden end | 85 px = 6.3 m, level with the strip's garden wall | 8.4 m, 2.75 m past the strip | not re-measured; the builder's 8.4 m is a sum of five eyeballed pieces, ± 0.6 m by its own note |
| Lion stair landing, along the hall | 80 px = 5.9 m | 8.0 m | not re-measured |

**The lens.** The clips carry the lens in their QuickTime tags. `IMG_6344`, `6380` and `6387` are tagged `1.54mm f/2.4`, 13 mm equivalent. `IMG_6343` is tagged `5.96mm f/1.6`, 26 mm equivalent, at its start, and zooms out to the wide lens for its room overviews (141.3–141.9 s is one such zoom). A 13 mm lens gives a 720 px wide upright frame a focal length of 481–534 px depending on stabilisation crop, a horizontal field of 68–74°. The first agent's 9.6 m for gallery A assumed 50–60°; the same measurement at 68–74° is 6.6–7.3 m. That is the whole of the difference.

**What this means.** The record already says the Hall's length is a fit: `loop_fit` in `geometry.json` reads "Extend parallel long galleries, align Hall end doors", `hall_length_m: 26.3`, `metric_accepted: false`. The Impressionist rooms were then stretched to match. The map and two lens-based readings both put the Grand Gallery near 20 m and the two galleries near 7 m. INFERRED, not surveyed: the stabilisation crop and the camera's distance from the near wall each move these by about 10%.

## Differences, worst first

| # | As built | As filmed | Status |
| --- | --- | --- | --- |
| 1 | The route leaves the stair hall by the EXIT door under the half-landing (`marble stair hall` `openings.east [-2.51, -1.41]`, x 17.85 and 19.45) | It leaves by the cased doorway in the **south** wall next to the columns. The EXIT door is a different door, faced and not entered | **VERIFIED** (6343 83.0–89.75 s continuous; 6380 49.0, 70.0 s) |
| 2 | `Impressionist passage` [19.45, 21.45, -2.86, 1.04]: 2 m wide, 3.9 m long, beyond the half-landing window wall | Nothing filmed there. Through the EXIT door there is a small lit vestibule and a second door | Passage not in footage: **VERIFIED**. What is really there: **UNKNOWN** |
| 3 | `Impressionist passage return` [14.75, 21.45, 1.04, 3.04]: 6.7 m of corridor running back west, with the service leaf and grilles moved onto it | Does not exist. The passage is straight, about 2 m long and about 2 m wide, and *Le Repos* is visible from the stair hall through both doorways | **VERIFIED**. The first agent's own record marks it `passage_elbow_inferred: true` |
| 4 | The real doorway is built shut: `PassageDoorClosed`, centre x 12.43 on z 1.04 | Open, leaves folded into the reveal, grey stone sill | **VERIFIED** |
| 5 | A's entry is at the **east** (window) end of its north wall, `openings.north [15.10, 16.40]` | At the **west** end, next to the Monet wall. From east to west the north wall reads: corner, Manet *Tuileries*, Carolus-Duran portrait, door, corner | **VERIFIED** (91.25–92.75, 135–141 s) |
| 6 | B's pictures (bare positions in `WORKS-NEEDED.md`, and Monet 44.541 hung): west = Pissarro, Gauguin; south = Cézanne 33.053, Monet 44.541; east = iris, Morisot, van Gogh, Cassatt | North = Gauguin, Pissarro, door. West = Cézanne 33.053, Monet 44.541 under the long grille. South = iris, Morisot, van Gogh, door. East = window, Cassatt, window, nothing else | **VERIFIED** (one unbroken right pan, 211.5–218 s; 213.5 and 215.5 s) |
| 7 | A is 9.66 m and B 9.60 m along the windows | About 6.8 and 7.6 m on the museum's map; 6.2–7.4 and 6.5–7.5 m from frames with the lens taken from the clip's tag. Each room is close to square, not a long gallery | **INFERRED**, three readings agree; not surveyed |
| 8 | Grand Gallery and long adjacent gallery 26.3 m | 20.4 m on the map; about 18–20.5 m from `IMG_6344` 24.0 s. The three rooms were stretched to fill this length | **INFERRED**. The build's own record marks 26.3 as an unaccepted fit |
| 9 | Stair hall 8.4 m deep, ending 2.75 m past the galleries' window wall; lion landing 8.0 m | On the map the stair hall ends level with the galleries' garden wall (6.3 m) and the landing is 5.9 m | Map: **VERIFIED** as drawn. True depth: **UNKNOWN**, not re-measured here |
| 10 | A and B share the Main Hall's east wall line, x 10.55 | The map shows the strip sharing the Grand Gallery's long wall. The south door (centre 12.43) and A's entry line up with A's west wall near x 10.5 | **VERIFIED** on the map; consistent in footage |

## The lead's questions, plainly

1. **Correct side of the correct neighbour?** Yes. South of the stair hall, north of the modern gallery, windows on the plan's east, the Grand Gallery behind the west wall. VERIFIED from frames for order and side, and on the museum's map for the shared wall.
2. **Long axis in the right direction?** Yes: north–south, along the window wall. VERIFIED.
3. **Doors on the right walls?** A's exit to B, B's two doors and the modern gallery's door: yes, right wall and right end. A's entry: right wall, **wrong end**. The stair hall's door: **wrong wall**.
4. **Connected to the right rooms?** The rooms are right, the stair hall connection is not: it should be the south doorway.
5. **Is the passage real?** A passage is real: one straight piece about 2 × 2 m. The built pair, 3.9 m and 6.7 m with two turns, is an invention to make a plan close from the wrong door.
6. **Does anything sit where the footage shows something else?** The built passage sits beyond the stair hall's half-landing window wall, where the map has the garden and a corridor to Pendleton House. The return passage sits south of the service stair where nothing was filmed. The opened EXIT door replaces a door that leads somewhere else. A and B overlap nothing filmed.
7. **The lead's reading of the map.** Orientation, the door beside the short stair, the absence of the elbow and the stair hall's overshoot: all confirmed. One correction: the three rooms' lengths. Taking the Grand Gallery as 26.3 m gives 8.9 / 9.7 / 8.0 m; taking the scale from the map's widths gives 6.8 / 7.6 / 6.3 m, and the footage supports the second.

## Public information

The museum's own Floor 5 map, above. My own searches did not find it (`risdmuseum.org/visit/museum-map` returned HTTP 403, two web searches returned no plan); the lead pointed me to the copy the project already held. Nothing here rests on memory of the building.

## Proposal

Two parts. Part 1 makes the route true and moves no other room. Part 2 makes the sizes true and is a larger decision.

### Part 1: the smallest change to `prepare_remodel.py`'s room list

Room-scene metres, bounds as [x0, x1, z0, z1]. No other room moves.

1. **Delete** `Impressionist passage` [19.45, 21.45, -2.86, 1.04] and `Impressionist passage return` [14.75, 21.45, 1.04, 3.04], with their trials `impressionist_stair_inner`, `_stair_outer`, `_passage_return`, `_return_A` and route legs 00–04.
2. **Marble stair hall:** remove `openings.east [-2.51, -1.41]` and its 2.47 head; add `openings.south [11.55, 13.31]`, head 2.60. That is the existing closed leaf pair (centre 12.43, two 0.86 m leaves). In `marble_hall_additions.gd` `inner_walls()`: put back the closed EXIT leaves and the single obstruction behind them as they were before #277, and replace `PassageDoorClosed` with the open doorway, leaves folded into the reveal. The vent above it and the fire pull stay.
3. **Add** `Impressionist passage` [11.45, 13.45, 1.04, 3.04], height 3.2. Openings: north [11.55, 13.31] head 2.60; south [11.75, 13.15] head 2.74. Grey stone floor for z 1.04–1.64, oak beyond. East wall: the 0.85 m six-panel service leaf centred near z 2.0, high grille above. West wall: low grille near the A end. Width 2.0 ± 0.3, length 2.0 ± 0.4 (89.25–89.75 s).
4. **Gallery A:** bounds unchanged, [10.55, 16.70, 3.04, 12.70]. Move `openings.north` from [15.10, 16.40] to **[11.75, 13.15]**. South opening unchanged, [15.20, 16.30]. Re-lay the north wall east of the door: Carolus-Duran 2007.68 centred about x 14.2, Manet *Tuileries* 42.190 about x 15.6. Order VERIFIED, metres estimated ± 0.4.
5. **Gallery B:** bounds and both openings unchanged. Move the picture positions to the walls in row 6 above; Monet 44.541 goes from the south wall to the west wall, about 1.9 m from the south-west corner, under the grille. Order VERIFIED, metres estimated.
6. **Route:** (12.43, 0.30) → (12.43, 1.60) → (12.45, 2.60) → (12.45, 3.85) → (13.6, 6.2) → (14.85, 9.2) → (15.75, 11.85), then the existing legs through B to (15.75, 23.25). Door trials: stair hall ↔ passage (12.43, 0.30) ↔ (12.43, 1.70); passage ↔ A (12.45, 2.30) ↔ (12.45, 3.85).
7. **`impressionist_fit`:** `fixed_stair_door` becomes [12.43, 1.04]; `longitudinal_residual_m` about 0.86; drop `passage_return_m`; `passage_elbow_inferred` false.

`main_build_walk.gd` `JOINED` and `FAR_ROOMS` lose `Impressionist passage return`. Lamps (#274) and the trim kit are untouched.

### Part 2: the lengths (not a small change; the owner's or the lead's call)

The true sizes cannot be had by editing the Impressionist rooms alone. The modern gallery's far door must still meet the lion stair landing, and the landing sits beside the medieval room at the Grand Gallery's far end. Shortening A and B therefore means shortening the Grand Gallery and the long adjacent gallery with them.

1. Target lengths along z: Grand Gallery and adjacent gallery 20.4 m (z 1.8 to 22.2) in place of 26.3; A 6.8 m, B 7.6 m, modern 6.3 m, with A starting at z 3.04 after the passage or at z 1.8 if the map is followed exactly.
2. Everything south of the Grand Gallery (medieval, Renaissance, lion landing, sculpture stub) moves 5.9 m north unchanged.
3. Every work on the two long galleries' side walls keeps its order and closes up by the same factor, 0.776.
4. Stair hall depth 8.4 → about 6.3–6.9 m, and lion landing 8.0 → about 5.9 m, only after a measurement of each from footage; the map alone is not enough for those two.

Before doing Part 2, measure the Grand Gallery once more against catalogue canvas widths along one long wall in `IMG_6344`; that takes the 10% lens uncertainty out. If Part 2 is not done before the deadline, Part 1 alone still removes the invented passages and puts every door on the right wall; the rooms stay about 2.5 m too deep each, and that should be said to the owner.

## Not determined

1. The Grand Gallery's length to better than about 10%: map 20.4 m, footage about 18–20.5 m, built 26.3 m.
2. The stair hall's and the lion landing's true depths.
3. How long the short passage is against the map, which draws none: 2.0 ± 0.4 m by footage.
4. Whether the owner means the door and passages, the stretched rooms, or both.

**One question for the owner:** "The map makes the two Impressionist rooms nearly square, about 7 m each, and the Grand Gallery about 20 m long; we built them about 9.6 m and 26 m. Is it the stretched rooms you mean, the entrance from the stair hall, or both?"
