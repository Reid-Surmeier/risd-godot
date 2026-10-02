# European gallery, west wall and end walls (#238): builder notes

Branch `room/european-west`, base `8fca73d3`. First version, built inside a time box set by the
coordinator: every position below is **provisional**.

**Not baked.** `scripts/rebuild_rooms.sh --draft` passes (`ARCHITECTURE_CHECK ... "failures":[]`,
`REMODEL_READY` lists `european_west` with 21 identified works). The one full bake I started was stopped by
the coordinator at `BAKE_STARTED` (six bakes at once); `collection_rooms/` is untouched and the game still
shows the old room until the coordinator's single bake. The ten pictures here are the **unbaked** room scene
(`remodel_room.tscn`, camera at 1.6 m, 62 degree lens) beside the footage frame of the same wall.

## What I looked at

Seen in the unbaked renders (pictures 01 to 10): every work listed below is on its wall, faces the room,
and stands in the footage's order; labels sit on the side the footage shows; both EXIT signs are over their
doors; the secretary stands on the new platform beside the dress case. Not seen: anything lit by the bake,
the walking camera's wall cut-away, and the click-to-inspect captions. Known by eye from the renders: the
door knocker's cut-out keeps a pale rim of studio background; the stemmed cup lost its lid in the cut.

## What is built

New file `european_west_additions.gd`; `build_adjacent_gallery()` in `remodel_room.gd` moves four existing
objects. Assets and catalogue records are in `image-work/collection-room-remodel/additions/european-west/`
(`records.json`, `SOURCES.md`, `prepare_assets.py`).

| Wall | Work (south to north on the west wall) | Accession | Catalogue size | Built size | How built |
| --- | --- | --- | --- | --- | --- |
| South, west of door | Domenico Gagini, *Tabernacle* | 06.057 | 50.8 x 73.7 cm | 0.737 x 0.508 m relief, 0.15 deep, on a 0.80 x 1.02 x 0.32 m pedestal | cut-out of the catalogue photograph |
| South, east of door | Northern Italian, *Apollo* | 73.079 | 18.7 x 6.4 x 4.5 cm | 0.21 m with its black base, in a 0.40 x 0.45 x 0.26 m wall case | cut-out |
| South, east end | Andrea Previtali, *Risen Christ* | 16.237 | 29.2 x 26 cm | canvas 0.26 x 0.292 m | Perugino tabernacle frame asset |
| West | Girolamo Campagna, *Door Knocker* | 55.091 | 39.4 x 29.2 x 12.7 cm | 0.394 m tall on a 0.45 x 0.56 m white board in an acrylic box | cut-out |
| West | Johanna Sibylla Küssell, two views of the Villa d'Este fountains | 2024.17.5, 2024.17.6 | plates 8 x 11.9 and 8.1 x 12.2 cm | plates at size, mounts 0.62 x 0.47 m | black 25 mm moulding built from boxes |
| West | Hendrick Goltzius, *Christ on the Cold Stone with Two Angels* | 61.006 | 51 x 34.5 cm | unchanged | **moved** |
| West | Gaetano Zompini, *Fruit Vendor* and *Baked Goods Hawker* | 67.106.31, 67.106.8 | plates 25.9 x 17.8 and 25.9 x 18.3 cm | plates at size, mounts 0.40 x 0.50 m | black moulding |
| West | Portuguese, *Textile* (embroidered panel) | 85.075.6 | 57.2 cm high | 0.572 m high, width from the photograph (0.76 m), on a 1.0 x 0.8 m white board | photograph on a slab |
| West, pedestal case under it | *Tigerware Jug* 47.625; *Stemmed cup with cover* 45.188; *Cup* 32.010; *Bowl* 73.060; *Owl Beaker* 52.533 | as listed | heights 24.1, 20.5, 20, 12.7, 22.9 cm | catalogue heights | cut-outs on a 1.0 x 1.0 x 0.45 m pedestal under an acrylic hood |
| West | Domenico Fetti, *Christ Ministered To by the Angels* | 36.003 | 89.5 x 78.1 cm | unchanged | **moved** |
| West | Francesco Tironi, *View of the Grand Canal, Venice, with Churches of the Scalzi and Santa Lucia* | 42.042 | 51.8 x 83.8 cm | canvas 0.838 x 0.518 m | Hall frame W10 |
| West, stacked | Francesco Guardi, *Scuola di San Marco with Loggia...* (above) and *Main Salon in the Ridotto, Venice* (below) | 53.115, 24.508 | 38.7 x 32.4 and 31.4 x 51.1 cm | canvases at size | Hall frames W2 and W7 |
| West | Eugène Delacroix, *Arabs Traveling* | 35.786 | 54.1 x 65.1 cm | unchanged | **moved** |
| West | Giovanni Battista Piranesi, *Egyptian Decoration of the Caffè degli Inglesi*, plate 45 | 63.066.45 | plate 23.8 x 32.5 cm | plate at size, mount 0.72 x 0.52 m | black moulding |
| West | Guillaume Beneman, *Drop-Front Secretary* | 80.106 | 143.5 x 114.3 x 42.6 cm | unchanged | **moved**; now on a 1.05 x 0.13 x 2.65 m white platform |
| North-west corner | English, *Dress* | 2000.103.3 | 134.6 cm long | 1.50 m cut-out with mannequin, in a 0.74 x 1.75 x 0.60 m glass case on a 0.12 m base | cut-out |
| North, west of door | Thomas Lawrence, *Mrs. Wolff* | 42.072 | 22.2 x 24.1 cm | sheet at size, mount 0.42 x 0.40 m | gilt 18 mm moulding |
| North, east of door | Italian, *Micromosaic Tabletop with Nine Views of Rome* | 1990.060 | diameter 59.7 cm | 0.597 m disc on a 0.76 m board in an acrylic box, shelf case below | photograph on a disc |

Also built: a blank card 0.17 x 0.30 m beside each work (upright, as every label in this room is; the brief's
0.30 x 0.17 turned), green EXIT signs over both doors on the gallery side, the platform under the dress case
and secretary.

Every identification was made by reading the label in a full-size frame where legible and then matching the
catalogue photograph against the footage by eye. All 21 records are flagged on view by the catalogue API.

## Positions and the measurement behind them

One camera solve (pycolmap, the three clips at 6 and 4 frames a second, 963 of 1,284 frames in one model)
gives a west-wall line and an east-wall line 0.9 degrees apart and 3.98 model units apart. Feature points
within 0.05 units of the west wall cluster at each work. Scale 1.47 m per unit comes from two frames whose
outer widths I estimated from catalogue canvas plus frame (Fetti 0.72 units = about 1.05 m, Tironi 0.70 units
= about 1.04 m). That scale gives a room width of 5.85 m (build: 6.1 m) and a camera height of 1.66 m.
The south wall is at +7.58 units.

| Work | Centre, units | From south wall, m | Built z | Was |
| --- | --- | --- | --- | --- |
| Fetti 36.003 | 0.00 | 11.14 | 16.96 | 8.8 (19.3 m from the south wall) |
| Goltzius 61.006 | +3.44 | 6.09 | 22.01 | 14.7 (13.4 m) |
| Guardi pair | -2.00 | 14.08 | 14.02 | new |
| Tironi | -1.03 | 12.66 | 15.44 | new |
| Textile and case | +1.14 | 9.47 | 18.63 | new |
| Zompini pair | +2.22 | 7.88 | 20.22 | new |
| Küssell pair | not resolved (white mounts carry no features) | 4.1 and 4.85, by eye | 24.0, 23.25 | new |
| Door knocker | about +5.5 | 3.0 | 25.1 | new |

North group (dress case, secretary, Piranesi, Delacroix) and both end walls: wall order from IMG_6385 and
IMG_6384 plus catalogue widths; not measured. The Delacroix moved from z 4.35 to 6.85 and the secretary from
3.05 to 3.55 because the dress case and the Piranesi have to fit north of them.

Heights: the solve puts the Fetti's and Goltzius's centres at 1.80 and 1.74 m, which the build already had;
new single works hang at 1.60 to 1.75 m, the Guardi pair at 1.55 m (lower centre) with the upper one 6 cm above.

## The shell: measure this before trusting any of the above

The solve's northernmost camera (IMG_6386 66.5 s, standing by the secretary) is 12.4 units = 18.2 m from the
south wall. The north wall itself is not in the solve (the north-end frames had not registered when the time
box closed). The room is therefore probably about 20 m long, not 26.3 m. I anchored the south group to the
south wall and the north group to the north wall, so in the build about 6 m of bare wall separates the Guardi
pair from the Delacroix; in the footage one wall text sits between them. Not confirmed.

## Frames chosen (nearest existing asset)

Tironi: Hall `W10` (plain gilt). Guardi above: Hall `W2` (carved, straight rails). Guardi below: Hall `W7`
(swept, shell centres). Previtali: `perugino-frame.png` (cornice and base; the real one is plain gilt).
Prints and the Lawrence: a plain moulding built from four boxes, because no existing asset is a thin print frame.

## Not built, and why

1. Three wall texts on the west wall (one titled "Unearthing the Past" by the south-west corner): lettering
   on the wall, not legible enough to reproduce, and no card to stand in for it.
2. The small objects in the shelf case under the micromosaic (at least six). Probable on-view matches, not
   confirmed against the footage: 67.269, 80.084.7, 24.009, 58.172.11A. The case itself is built empty.
3. The folded door leaf in the Rockefeller reveal (north door).
4. Vents: I saw none on these three walls; the louvres at both ends are on the east wall. Not exhaustively checked.
5. Volumes for the objects: all are flat cut-outs of the catalogue photograph (no paid generation this round).

## What other files need

1. `remodel_bake.gd` line 112 still lights the Delacroix at (-3.48, 1.75, 4.35); it now hangs at z 6.85.
2. Spots wanted (ceiling 3.4 m, track about 1.6 m off the west wall, x -3.95), position then target:
   knocker (-3.95, 3.4, 25.1) to (-5.48, 1.60, 25.1); Küssell (-3.95, 3.4, 23.6) to (-5.48, 1.60, 23.6);
   Goltzius (-3.95, 3.4, 22.0) to (-5.48, 1.75, 22.0); Zompini (-3.95, 3.4, 20.2) to (-5.48, 1.72, 20.2);
   textile and case (-3.95, 3.4, 18.6) to (-5.4, 1.6, 18.6); Fetti (-3.95, 3.4, 17.0) to (-5.48, 1.80, 17.0);
   Tironi (-3.95, 3.4, 15.4) to (-5.48, 1.75, 15.4); Guardi (-3.95, 3.4, 14.0) to (-5.48, 1.85, 14.0);
   Delacroix (-3.95, 3.4, 6.85) to (-5.48, 1.75, 6.85); Piranesi (-3.95, 3.4, 5.1) to (-5.48, 1.72, 5.1);
   secretary (-3.6, 3.4, 3.55) to (-5.2, 0.9, 3.55); dress case (-3.6, 3.4, 3.0) to (-5.0, 1.0, 2.42);
   Lawrence (-4.15, 3.4, 3.4) to (-4.15, 1.62, 1.87); micromosaic (-0.45, 3.4, 3.4) to (-0.45, 1.6, 1.87);
   Apollo and Previtali (-0.5, 3.4, 26.5) to (-0.5, 1.5, 28.03); tabernacle (-4.35, 3.4, 26.5) to (-4.35, 1.3, 27.8).
3. `MODULES.md`, `modules/shell/PROVENANCE.md`: one line for the new bake and the 21 catalogue photographs.

## Outside the brief's 0.6 m rule

The platform (1.05 m from the west wall, z 1.8 to 4.45) and the dress case on it stand further than 0.6 m
from the walls, because that is their size in the footage. Nearest floor piece of the other builder is the
silver case, well clear.
