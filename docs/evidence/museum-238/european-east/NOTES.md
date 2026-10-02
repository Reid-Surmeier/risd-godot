# European gallery: east wall and floor pieces (#238)

Builder `european-east`, base `8fca73d3`, branch `room/european-east`. First version, built under a time box:
everything is in the room, every position is provisional. Source: `modules/shell/prototype/collection_reconstruction/european_east_additions.gd`,
pictures and their sources in `image-work/collection-room-remodel/additions/european-east/`.

## What is built

East wall, south to north. "Verified" means I put the catalogue record's photograph beside the footage frame and they are the same object.

| # | Work | Record | Catalogue size | Built | How identified |
| --- | --- | --- | --- | --- | --- |
| 1 | Giuseppe Cesari, *Perseus and Andromeda*, ca. 1592 | 57.167 | 70.5 × 54.9 cm | canvas at catalogue size in the `romany-frame` asset, outer 0.75 × 0.92 m | label read (6384 6.75 s), photograph verified |
| 2 | After Pieter Bruegel I, *River Landscape with Mercury Abducting Psyche* | 84.198.1032 | plate 27.6 × 34.6 cm | plate at catalogue size, white mount, black frame 0.573 × 0.432 m (measured) | label read (6384 9.7 s), photograph verified |
| 3 | Nicolas Poussin, *Venus and Adonis*, ca. 1628 | 54.186 | 76.2 × 101 cm | canvas at catalogue size in `bertin-frame`, outer 1.18 × 0.99 m | photograph verified (6384 54.5 s) |
| 4 | Netherlandish, *The Adoration of the Magi*, ca. 1510 | 21.482 | 52.1 × 34.6 cm | the record's own framed photograph as one slab, 0.52 × 0.80 m (measured outer) | photograph verified, frame included (6384 60.5 s) |
| 5 | Spanish, *Crucifixion*, ca. 1490 | 69.197 | 143.8 × 113 cm | panel at catalogue size in `matisse-frame`, outer 1.33 × 1.64 m | photograph verified (6384 66.25 s); already in the repo's notes |
| 6 | French, *Cloth of Gold*, ca. 1750–1769 | 46.256 | length 129.5 cm | 0.56 × 1.295 m on a white board 0.80 × 1.40 m | photograph compared with a blurred frame (6384 69 s): same ground, same sprigs; the least certain match on the wall |
| 7 | Pietro Longhi, *A Meal at Home*, ca. 1753 | 34.1371 | 61.9 × 50.5 cm | canvas at catalogue size in `romany-frame`, outer 0.68 × 0.81 m | photograph verified (6384 73.5 s) |
| 8 | Anton Raphael Mengs, *Portrait of an English Gentleman*, ca. 1754 | 57.281 | 99.1 × 73.3 cm | canvas at catalogue size in `edwards-frame`, outer 0.97 × 1.22 m | label read (survey 6384/155), photograph verified |
| 9 | Joshua Reynolds, *A Caricature Group…*, ca. 1751 | 53.349 | 62.9 × 48.3 cm | canvas at catalogue size in `fetti-frame`, outer 0.71 × 0.87 m | label read (6384 81.25 s), photograph verified |
| 10 | Indian, *Cover*, ca. 1700–1800 | 37.009 | length 133.4 cm | 0.92 × 1.334 m on the display panel | photograph verified (6384 89 s) |
| 11 | Charles Cressent, *Commode*, ca. 1725–1730 | 2017.46 | 86.4 × 144.8 × 64.8 cm | closed box at catalogue size, front photograph, marble slab; collision | photograph verified (6384 93 s) |
| 12 | Meissen, *Charger*, ca. 1745 | 2014.31 | diameter 43.2 cm | disc at catalogue size in an acrylic box on the commode | photograph verified (6384 93 s) |
| 13 | Elisabeth Louise Vigée Le Brun, *Portrait of an Artist*, ca. 1773 | 2025.86 | 55.6 × 46 cm | the record's own framed photograph as one slab, 0.705 × 0.80 m | label read (6384 99 s), photograph verified |

Floor pieces.

| Piece | Inside, built | Audit's lower bound | Notes |
| --- | --- | --- | --- |
| Silver and porcelain case | 9: Archambo cake basket 2016.124, de Lamerie coffeepot 2014.33, armorial plates 09.351 and 2016.62, Plate with Elephant 2016.102.2 (all verified); Saldanha platter 55.023.6H (candidate, seen only from behind); two porcelain figures and a teapot as plain blocks | 9 | The figures are probably Kändler's *Turkish Man* 37.087 and *Turkish Woman* 37.086 (on view, same gallery); their photographs were not fetched in time, so they carry `catalogue_candidate`, not an accession. The green and yellow teapot is unidentified. |
| Bench | black slab on four legs, collision | 1 | Sizes by eye. |
| Cabinet case | 1: German *Writing Desk (Schreibtisch)* 75.023, verified | 2 | The flat inlaid board beside it (its fall front, or a second object) is not built. |
| Majolica case | 11: mortar 54.147.9 with pestle 54.147.20 (one card), Embriachi casket 85.075.8, orciuolo 43.351, istoriato plate 35.703, Reymond calendar plate 1989.085, Apollo roundel 51.502, pastiglia casket 51.272 (all verified); small dish and three small metal objects as plain blocks | 10 | The four small objects are unidentified. |
| River God case | 1: Giambologna, *River God* 44.674, verified | 1 | |

Case objects are the record's photograph on a thin two-sided card at catalogue size, not solids. The photographs keep their grey studio background.

Fixtures: one blank card (0.30 × 0.17 m, `artwork_label_proxy`) south of each wall work at 1.40 m, a label stand on the platform, a small card by each case object. The display panel and its platform are built (below).

## How the positions were measured

The earlier survey reconstruction `sfm-galleries-v3`, model 0 (192 frames of IMG_6384/6385/6386, 19,730 points) gives camera poses for most of the room. I fitted the floor and the east wall to its points, then sent rays through picture corners read off the registered survey frames.

1. **Scale.** Four catalogue sizes along 10 m of wall agree: Crucifixion 1.489 and 1.477 m per unit (width, height), Poussin 1.482 and 1.506, Mengs 1.479 and 1.497, Reynolds 1.492 and 1.480. I used 1.48.
2. **Centres from the south wall, metres:** Perseus 1.20, print 2.27, Poussin 3.77, wall text 4.98, Adoration 5.85, Crucifixion 7.49, cloth 9.22, Longhi 10.72, Mengs 12.16, Reynolds 13.49, panel south edge 14.6–14.8, cover on the panel 15.9. Two frames agree within 2 cm for Poussin, 3 cm for Reynolds and 4 cm for Mengs.
3. **Heights.** Picture centres are 1.55–1.60 m above the floor on all eight measured works (Perseus 1.565, print 1.57, Poussin 1.57, Adoration 1.595, Crucifixion 1.573, Longhi 1.56, Mengs 1.55, Reynolds 1.56). Cloth, cover and Vigée Le Brun are hung at the same line by inference.
4. **Frame allowance.** Outer sizes measured: Perseus 0.71 × 0.89, Poussin 1.24 × 0.98, Crucifixion 1.31 × 1.65, Longhi 0.66 × 0.78, Mengs rails 0.93 × 1.16 (plus corner shells and crest), Reynolds 0.64 × 0.78, Adoration 0.52 × 0.80, print frame 0.573 × 0.432. The catalogue sizes are unframed. `Painting.build_framed` ties the band to the canvas height, so I chose the existing frame asset whose band ratio is nearest; built outer sizes are within 2–9 cm of the measured ones. The asset was chosen by band width, not by look: none of the six has been compared with the real frame.
5. **North end is not measured.** No registered frame shows the north wall. Commode at 18.5 m, Vigée Le Brun at 20.45 m and the room length of 21.2 m are estimates from object sizes and unregistered frames (6386 44.4 s, 68.2 s; 6384 90–101 s).
6. **Floor pieces are placed by eye** from clusters in the reconstruction's top view and the wide frames (6386 41.2 s, 43.4 s, 57.25 s; 6384 32 s, 39.25 s): silver case 15.2 m from the south wall and 4.0 m from the east wall; bench 10.3, 2.6; cabinet case 8.3, 3.0; majolica case 4.9, 4.5; River God 2.8, 2.5. Case and plinth sizes are by eye.

Because the real room is shorter than the build's, each position is laid in by its fraction of the real room (`REAL` in the script), not by bare metres. Sizes stay real, gaps stretch by 24 % along the room and 5 % across it. If the shell is corrected the works fall on their measured metres with no edit.

## The shell, measured (not changed)

| | Footage | Build |
| --- | --- | --- |
| Width, plaster to plaster | 5.79 m (east and west wall planes parallel to 0.1°) | 6.10 m |
| Length | Reynolds' centre is 13.49 m from the south wall (measured). Panel, commode, Vigée Le Brun and the corner follow: about 21 m in all (inferred). | 26.30 m |
| Ceiling | 3.54–3.61 m | 3.50 m |
| Baseboard | 0.21–0.25 m | 0.16 m |
| Floor boards | run across the room, east–west (6386 41.2 s, 43.4 s; 6384 6.75 s) | run along it, north–south |
| Projecting panel | **one**: a white display panel about 2.7 m wide, 0.31 m deep, top about 3.45 m, on a white platform about 0.12 m high, 1.3 m deep and about 4.9 m long that also carries the commode (6386 44.4 s, 68.2 s, survey 6386/138; 6384 86–96 s) | two plain piers 0.9 × 0.44 × 3.5 m at z 3.65 and 8.4 |

The frame the earlier agent cited for a second pier (6386 44.25 s) shows the same single panel, with the silver case's acrylic hood in front of it at the left. There is no second pier. I removed nothing: the pier at z 8.4 now sits inside my panel, which is why the panel is built 0.46 m deep and the platform 0.14 m high instead of the measured 0.31 and 0.12. The pier at z 3.65 stands where the wall between the commode and the Vigée Le Brun should be bare, and hides that portrait's label. Both piers (`remodel_room.gd`, `build_adjacent_gallery`, the `for z in [3.65,8.4]` loop) should go; then set the panel depth to 0.31 and the platform to 0.12 in my script.

Also seen on this wall and not built (fixtures pass): one wall text between the Poussin and the Adoration (centre 4.98 m from the south wall, about 0.32 × 0.56 m of lettering); high slot vents about 0.75 × 0.19 m at 3.27–3.45 m, centred 3.74 m and 14.1 m from the south wall; low square-grid vents under the Longhi (0.54 × 0.30 m, centre 10.78 m) and in the south-east corner beside Perseus; one below and north of the Vigée Le Brun; a thermostat south of Perseus.

The real label cards are upright, about 0.17–0.19 m wide and 0.25–0.32 m tall, centred 1.40 m high, 5–10 cm south of each frame. I built the brief's 0.30 × 0.17 m card lying on its long side at that height and side; `LABEL` in the script turns it.

## Spots for the lighting pass

Room-scene metres, on the build's present shell. One spot per wall work, 1.5 m out from the wall at 3.40 m; two per case.

| Work | Spot position | Target |
| --- | --- | --- |
| Perseus and Andromeda 57.167 | (-0.95, 3.40, 26.61) | (0.48, 1.56, 26.61) |
| After Bruegel, River Landscape 84.198.1032 | (-0.95, 3.40, 25.28) | (0.48, 1.57, 25.28) |
| Poussin, Venus and Adonis 54.186 | (-0.95, 3.40, 23.42) | (0.48, 1.57, 23.42) |
| Adoration of the Magi 21.482 | (-0.95, 3.40, 20.84) | (0.48, 1.59, 20.84) |
| Crucifixion 69.197 | (-0.95, 3.40, 18.81) | (0.48, 1.57, 18.81) |
| Cloth of Gold 46.256 | (-0.95, 3.40, 16.66) | (0.48, 1.57, 16.66) |
| Longhi, A Meal at Home 34.1371 | (-0.95, 3.40, 14.80) | (0.48, 1.56, 14.80) |
| Mengs, English Gentleman 57.281 | (-0.95, 3.40, 13.01) | (0.48, 1.55, 13.01) |
| Reynolds, Caricature Group 53.349 | (-0.95, 3.40, 11.36) | (0.48, 1.56, 11.36) |
| Indian cover 37.009 on the panel | (-1.45, 3.40, 8.25) | (0.08, 1.56, 8.25) |
| Cressent commode 2017.46 and Meissen charger 2014.31 | (-1.45, 3.40, 5.15) | (0.08, 0.90, 5.15) |
| Vigée Le Brun, Portrait of an Artist 2025.86 | (-0.95, 3.40, 2.73) | (0.48, 1.56, 2.73) |
| Silver and porcelain case | (-3.66, 3.40, 10.14) and (-3.66, 3.40, 8.34) | (-3.66, 1.15, 9.24) |
| Cabinet case (Schreibtisch 75.023) | (-2.61, 3.40, 18.70) and (-2.61, 3.40, 16.90) | (-2.61, 1.05, 17.80) |
| Majolica case | (-4.18, 3.40, 22.92) and (-4.18, 3.40, 21.12) | (-4.18, 1.00, 22.02) |
| River God case 44.674 | (-2.08, 3.40, 25.53) and (-2.08, 3.40, 23.73) | (-2.08, 1.25, 24.63) |

The real tracks cross the room east–west at intervals (6386 66.5–81.5 s). I did not measure where.

## Provisional, in order of how much it shows

1. Positions of the five floor pieces (by eye) and of everything north of the Reynolds (inferred).
2. Frames: nearest existing asset by band width; looks not compared. Mengs' shell-crested frame and the Crucifixion's pierced scroll frame are not represented.
3. Case objects are photograph cards with studio backgrounds, not solids. Plinth and hood sizes by eye. The majolica case's plinth is a plain box; the real one has cut corners and a sloped label rail, as has the silver case.
4. Cloth of Gold: width from the photograph's proportion, mount size by eye, identification the weakest on the wall.
5. Commode: a box with one front photograph; no bombé shape, no side or top photograph.
6. River God: one photograph, turned 45°; the record has 24 views.

## Not done

1. **No bake.** The coordinator stopped the bakes (six at once took the machine to load 80) and will bake once after merging. `scripts/rebuild_rooms.sh --draft` passes its architecture check (`failures: []`, 1506 surfaces against 1358 before). `collection_rooms/` is untouched on this branch. The pairs in this folder are unbaked draft renders, the only look I had; nothing was iterated after looking.
2. The second object in the cabinet case, the three unidentified small objects, the teapot and the two porcelain figures.
3. Wall text, vents, thermostat (fixtures pass).
4. The walking self-check and the repo checks (`main_build_check.gd`, `click_route_check.gd`) were not run. The cases, bench, platform, panel and commode are new walk blocks. The loop route runs straight down x = -2.5 and now meets three of them: legs 4 and 5 (trials `loop_04`, `loop_05`) cross the bench, legs 5 and 6 the cabinet case, legs 7 and 8 the River God case. In the footage those pieces do stand on or beside the room's long axis, so the route in `prepare_remodel.py` has to go round them (the east aisle at about x = -1.0 is clear from z 11 to 26).

## What other files need

1. `remodel_room.gd`: remove the two piers; set `boards_across` for this room in `prepare_remodel.py`; consider the room's length and width.
2. `remodel_bake.gd`: the spots above.
3. `modules/shell/PROVENANCE.md`: the catalogue photographs in `additions/european-east/` (list and credit lines in `SOURCES.md` there). No generated image, no paid call.
4. `MODULES.md`, `main_build_walk.gd`, `walk4.gd`, check scripts: nothing known.

## Pictures

Each is the footage frame (left) beside the unbaked draft render of the same subject (right).

| File | Footage | Shows |
| --- | --- | --- |
| `01-east-wall-south.jpg` | IMG_6384 34.0 s | Adoration, Poussin, print, Perseus; River God case in front |
| `02-east-wall-middle.jpg` | IMG_6386 43.4 s | Reynolds, Mengs, Longhi, Cloth of Gold, Crucifixion; bench |
| `03-east-wall-north-panel.jpg` | IMG_6386 44.4 s | Vigée Le Brun, commode and charger, display panel with the cover. The pier left of the commode is the build's older one. |
| `04-silver-case.jpg` | IMG_6386 57.25 s | silver and porcelain case |
| `05-majolica-case.jpg` | IMG_6386 12.0 s | majolica case |
| `06-river-god.jpg` | IMG_6384 39.25 s | River God case |
| `07-cabinet-and-bench.jpg` | IMG_6386 41.2 s | cabinet case and bench, looking south |
| `08-long-view-from-north.jpg` | IMG_6386 69.0 s | whole room from the north end |

Seen in the renders: the eleven wall works hang on one centre line in the footage's order; frames read as gilt at this distance; the case cards show their grey studio backgrounds; the label cards are too pale against the plaster to see from across the room; the plates laid flat in the silver case barely show.
