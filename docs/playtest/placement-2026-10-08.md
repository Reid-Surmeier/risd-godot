# Where each work hangs: footage against the build — 2026-10-08 (#266)

One row per work measured so far. "Built" is the installed build at `5cb7697a`. A work more than
0.15 m off along its wall or 0.08 m off in height is a fault.

## How a number was read

A frame is taken from the whole clip in `~/risd-godot-ingestion/collection-expansion/verified/`
(tone-mapped; IMG_6382 turned 180°). The work's own picture is matched to the frame (SIFT, RANSAC
homography), and because the picture's size is known the frame is redrawn square-on to its wall at
100 pixels per metre. Heights, neighbours, corners and door edges are then read off that drawing in
metres. The scale is the work's catalogue size in the same wall plane. The error grows with
distance from the picture: about ±0.03 m beside it, ±0.06 m at the floor below a small panel,
±0.10 m at a corner 1.5 m away. A centre-to-centre distance between two works matched in one frame
is computed, not read. Sculpture does not match this way and is not measured here.

Three of these readings repeat the 1 October audit's
(`docs/research/2026-10-01-museum-artwork-size-audit.md`, different method) to within 0.03 m.

## Dark medieval room (IMG_6382)

| Work | Wall, order | Filmed | Frame, error | Built | Off by | Change |
|---|---|---|---|---|---|---|
| 20.207 Madonna and Child | west, first north of the tracery doorway | bottom 0.95 m, centre 1.40 m; centre 1.55 m from the north-west corner, 0.78 m from the doorway's edge | 65.5 s and 68.0 s, ±0.05 high, ±0.10 along | centre 1.55 m; 1.90 m from the corner | 0.15 m high, 0.35 m south | lowered to 1.40 m, moved to 1.55 m from the corner |
| 57.301 Virgin of the Annunciation | west, next north | centre level with 20.207 (2 cm), 0.87 m from it (0.89 and 0.81 computed; audit 0.86–0.875); 0.70 m from the corner | 68.0 s, 65.5 s, ±0.05 | centre 1.55 m; 0.68 m from the corner; 1.22 m from 20.207 | 0.15 m high; spacing 0.35 m wide | lowered to 1.40 m |
| 21.250 Mary Magdalene | north, first east of the corner | centre level with 22.047 by eye; 0.80 m from it | 73.0 s, ±0.06 (one oblique frame, by eye) | centre 1.55 m; 0.82 m from 22.047 | 0.18 m high with 22.047 | lowered to 1.37 m |
| 22.047 The Taking of Saint Peter | north, next east, before the portal | centre 1.36 m, bottom 1.17 m (audit 1.2 m); baseboard 0.17 m | 74.0 s, ±0.06 | centre 1.55 m, bottom 1.36 m | 0.19 m high | lowered to 1.37 m |
| 16.243 St. Anthony Abbot Enthroned | south (built), on a pier that stands proud of the wall | bottom 0.57 m | 57.5 s, ±0.04 | bottom 0.60 m | 0.03 m | none |

Not measured: the Crucifix 43.195, Saint Peter 20.254, the Head 59.131, Christ in Majesty 69.196,
the Angel 37.114, the two Apostles, and the cases. Seen once in a contact sheet of the clip (one
frame every 5 s): both Apostles hang on small grey shelves fixed to the wall, not in niches and not
on floor plinths; the Head and Christ in Majesty stand on grey floor pedestals with the label on
the pedestal's face; the Crucifix and St Anthony have labels on the wall beside them.

The room itself, not a work: in footage the wall between the tracery doorway and the north-west
corner is about 2.33 m long (65.5 s, ±0.10). The build has 3.10 m (`geometry.json`, opening
31.2–32.33 in a room that starts at 28.1). So after the move 20.207 stands 1.23 m from the doorway
where the footage has 0.46 m. That is the room's plan, outside this ticket.

The four panels' labels are filmed (left of 20.207 and of 21.250, right of 57.301 and of 22.047).
Whether the build has them was not checked.

## Light Renaissance room (IMG_6383)

| Work | Wall | Filmed | Frame, error | Built | Off by | Change |
|---|---|---|---|---|---|---|
| 58.196 Madonna and Child with Saints | west | panel centre 1.525 m, bottom 1.07 m (audit 1.075 m); baseboard 0.20 m; frame about 1.02 x 1.11 m outside | 15.0 s, 427 matches, ±0.03 | centre 1.22 m, bottom 0.76 m; frame 1.005 x 1.06 m | 0.31 m low | raised to 1.52 m |

## Main Hall: applied in one held commit, not re-measured

The last commit on `feat/placement-266` ("HOLD for a Hall re-bake") applies section 4 of the
1 October audit (`docs/research/2026-10-01-museum-artwork-size-audit.md`) to
`modules/shell/prototype/gallery_walk4/works.json`: the `hang` of 21 paintings (20 raised
0.12–0.40 m, W6 lowered 0.30 m; S2 and E5 unchanged) and the canvas of seven (W7, E8, W6, W5, W2,
W3, E1), ±0.06 m by the audit. Its message lists every old and new value. Nothing in it was
re-measured for this ticket; five of the audit's room readings were, and agree to 0.03 m.

What the next agent needs to know about the Hall:

- **Click targets** come from `works.json` at run time: `walk4.gd` `_build_paintings()` builds a
  `painting_asset.gd` node per row and `_place()` records its corners in `_paintings`. They move
  the moment `works.json` changes.
- **What a visitor sees** is the saved bake `gallery_walk4/baked/room.tscn`, loaded by
  `_set_lighting(true)`. It still has the paintings at the old heights and sizes, so until the
  Hall is re-baked a click lands up to 0.40 m off the picture. Merge the commit and a re-bake
  together or not at all.
- **The bake** is `python3 modules/shell/prototype/gallery_walk4/bake/run.py`
  (`gallery_walk4/bake/README.md`): it saves the merged room, unwraps UV2, and drives the editor's
  Bake Lightmaps through a temporary plugin. It needs Godot 4.7.2 and an X display. I did not run
  it and do not know how long it takes.
- **A size change needs one more file.** Each painting's shadow and lamp-pool quads are
  `QuadMesh`es sized from the painting, and `cpu_geometry.gd` looks every primitive up in
  `native_cpu_arrays.res`; with a new canvas size the Hall asserts "Regenerate
  native_cpu_arrays.res" on load. The commit includes the file regenerated by
  `godot --path . --script res://modules/shell/prototype/gallery_walk4/prepare_cpu_geometry.gd`
  (needs a display). That script also rewrites `modules/shell/character/launch_geometry.res`;
  I restored that file and the checks pass with the old one.
- **Re-baked** in `15aa089a` with the same lamps; pictures and numbers in
  `docs/evidence/hall-hang-266/NOTES.md`.
- **Frame widths are not touched.** `painting_asset.gd` sets every band as
  `margins_px x canvas height / opening pixels`, so a frame cannot take a measured width by an
  argument. The audit's targets (S2 0.085 / 0.10 / 0.085 / 0.08 m, built about 0.24 m; S1 0.06 m
  all round) need its proposed optional `band_m` on the record. Not done.

## Hang heights the 1 October audit measured: read again and applied

Each was read again on a frame redrawn square to its wall, without the grid
(`plain-<key>.png`), as the row where the skirting meets the floor under or beside the work.
The new height is the mean of the two readings. "Built" is the canvas centre before this change.

| Work | Room | Audit | Read here, frame | Built | Now | Moved |
|---|---|---|---|---|---|---|
| Arabesque Wallpaper 34.912 | Rockefeller | 1.55 m | 1.50 m, IMG_6380 159.5 s, 317 matches | 2.10 m | 1.52 m | 0.58 m down, with its mount and clips |
| Fetti 36.003 | European gallery | 1.51 m | 1.55 m, IMG_6386 30.5 s, 286 matches | 1.80 m | 1.53 m | 0.27 m down |
| Delacroix 35.786 | European gallery | 1.57 m | 1.62 m, IMG_6386 60.5 s, 236 matches | 1.75 m | 1.60 m | 0.15 m down |
| Goltzius 61.006 | European gallery | 1.62 m | 1.67 m, IMG_6386 0.0 s, 132 matches | 1.75 m | 1.64 m | 0.11 m down |
| Matisse 57.037 | modern gallery | 1.54 m | 1.54 m, IMG_6387 74.0 s, 49 matches | 1.65 m | 1.54 m | 0.11 m down |

Each reading is good to about 0.05 m. In the European gallery the skirting reads 0.24 m tall and
its foot is in shadow, so the floor line there is the skirting's top less 0.24 m, checked against
the colour change to wood where that shows. Courbet 43.571 (0.07 m, inside the line) and the
Cézanne's height were left. `remodel_review.gd` asserts the Matisse's exact position, so it
changed with it.

The Renaissance room's other two wall works share the first fit that had the Madonna 0.3 m low.
The method cannot read them: the velvet 23.307X matches 34 points (40 are needed) and the
Woodcutters 29.280 none, and a white platform hides the floor line under both. By the weak
drawing and by eye in IMG_6383 at 6 s and 68.5 s the velvet's centre is 1.35–1.43 m (built 1.31)
and the tapestry's about 1.30 m (built 1.35), each ±0.10 m. Neither is 0.3 m off; both stay.

## Frame moulding widths

`painting_asset.gd` `build_framed()` takes an optional fifth argument, the moulding's widths in
metres (left, top, right, bottom); without it a frame is built as before. Read on the same
drawings from the catalogue canvas's edge to the frame's outer edge:

| Work | Built | Audit | Read here | Now | Framed size now |
|---|---|---|---|---|---|
| Cézanne 43.255 | 0.105 m | 0.12–0.135 m | 0.14 top, 0.155 right (bottom 0.165 with its shadow; left out of frame), IMG_6387 71.5 s | 0.14 m | 1.017 x 0.890 m |
| Matisse 57.037 | 0.055 m | 0.12–0.147 m | 0.14 / 0.125 / 0.135 / 0.14, IMG_6387 74.0 s | 0.135 m | 0.915 x 1.070 m |
| Fetti 36.003 | 0.165 m | 0.094–0.11 m | 0.115 left, IMG_6386 30.5 s | 0.105 m | 0.991 x 1.105 m |
| Villeneuve 1998.35 | 0.065 / 0.08 m | not measured | none: the catalogue gives the framed size, 50.8 x 61 cm | 0.10 / 0.099 m | 0.610 x 0.508 m |

The frame texture's band is stretched to the new width. Not done: the audit's other targets
(Perugino top 0.20 and bottom 0.15 m; in the Hall S2, S1, E1 and W10, which would need the Hall
baked again).

## Photograph cards in the European gallery's east cases

Each card is now scaled so the object in the photograph, not the photograph, is at catalogue
size. `card(...)` records the object's share of the photograph (`fill`, width x height) and the
share of its height below the object's foot (`foot`); an upright card is sunk by `foot` so the
object stands on the deck, and `sizes_check.gd` holds such a card by its object. Fills were
measured again here by flooding the backdrop from the photograph's edge and agree with the table
that stood here to 0.03.

| Work | Card before (m) | Fill | Card now (m) | Object now (m) | Catalogue |
|---|---|---|---|---|---|
| 2014.33 Coffeepot | 0.191 x 0.235 | 0.77 x 0.84 | 0.227 x 0.280 | 0.175 x 0.235 | 23.5 x 19.1 cm |
| 09.351 Plate | 0.300 x 0.229 | 0.64 x 0.86 | 0.358 x 0.273 | 0.229 across | diameter 22.9 cm |
| 2016.62 Plate | 0.250 x 0.229 | 0.72 x 0.82 | 0.318 x 0.291 | 0.229 across | none: sized as 09.351, its neighbour of the same service |
| 2016.102.2 Plate | 0.310 x 0.230 | 0.59 x 0.81 | 0.388 x 0.288 | 0.229 across | none: sized as 09.351 |
| 55.023.6H Platter | 0.295 x 0.222 | 0.70 x 0.73 | 0.421 x 0.317 | 0.295 long | length 29.5 cm |
| 54.147.9 Mortar | 0.240 x 0.228 | 0.64 x 0.61 (the mortar without its pestle) | 0.304 x 0.289 | 0.176 high | height 17.6 cm |
| 85.075.8 Casket | 0.320 x 0.240 | 0.48 x 0.90 | 0.477 x 0.358 | 0.229 x 0.322 | base 31.8 x 22.9 cm |
| 43.351 Jar | 0.254 x 0.254 | 0.75 x 0.76 | 0.324 x 0.324 | 0.243 x 0.246 | 23.5 x 25.4 x 20.3 cm |
| 35.703 Plate | 0.285 x 0.273 | 0.74 x 0.80 | 0.365 x 0.349 | 0.270 across | diameter 27 cm |
| 1989.085 Plate | 0.196 x 0.196 | 0.81 x 0.84 | 0.227 x 0.227 | 0.184 across | diameter 18.4 cm |
| 51.272 Casket | 0.220 x 0.200 | 0.86 x 0.72 | 0.238 x 0.217 | 0.205 x 0.156 | 15.2 x 21 x 14 cm |
| 44.674 River God | 0.390 x 0.483 | 0.77 x 0.74 | 0.528 x 0.654 | 0.407 x 0.484 | 48.3 x 43.5 x 31.8 cm |

Read with care:

- The jar and the 51.272 casket are scaled between their height and width (each within 1.2 cm).
- The 85.075.8 casket has only a base size. The photograph shows it end on, so the width seen is
  taken as the base's short side, 22.9 cm; that makes it 0.32 m tall. In IMG_6386 at 10–13 s it
  stands about 1.6 times the mortar's body, 0.28–0.30 m. Inferred, not catalogued.
- The River God is held by its height. Its width in the photograph (0.407 m) lies between the
  catalogue's width and depth because it was photographed at an angle; `sizes_check.gd` will
  still flag the width.
- The basket 2016.124 and the roundel 51.502 were right and are untouched.

In the cases: the mortar moved 4.5 cm and the 85.075.8 casket 4 cm along the majolica case's
deck, the least that keeps the mortar's card on the deck and the casket's card clear of the
mortar's and the jar's (0.5 cm and 1 cm). Nothing else touches a neighbour, the hood or the
riser, by the cards' rectangles and in a draft
(`docs/evidence/placement-266/east-cases-before-left-after-right.jpg`). Seen and left: the label
note of the elephant plate lies under the basket card's edge, and the platter's note is inside
the white riser block; both were so before.

Apollo 73.079: `cutout` height 0.21 → 0.187 m (catalogue 18.7 cm), its foot kept on the case floor.

## Not started

- Positions along the walls in the European gallery, Rockefeller, grey and modern galleries, the
  rest of the Renaissance room, and every standing work's base height.
- In the footage the east cases' objects are laid out differently from the build (IMG_6385
  31–36 s, IMG_6386 2–13 s): a card's place in its case was not measured.

## Running the method again

    cd <worktree>; source ~/promo-lab/gpu-env.sh
    R=res://modules/shell/prototype/collection_reconstruction
    P=modules/shell/prototype/collection_reconstruction
    # 1. sizes of all 177 works against the catalogue
    timeout 600 godot --headless --path . --script $R/sizes_check.gd -- /tmp/sizes-table.md
    # 2. each work's node, parts and room bounds
    timeout 600 godot --headless --path . --script $R/placement_dump.gd -- /tmp/parts.json
    # 3. frames of the clip around the second you want (HLG tone-map; add ,hflip,vflip for IMG_6381/6382)
    HDR="zscale=t=linear:npl=100,format=gbrpf32le,zscale=p=bt709,tonemap=hable:desat=0,zscale=t=bt709:m=bt709:r=tv,format=yuv420p"
    ffmpeg -ss 52 -t 26 -i ~/risd-godot-ingestion/collection-expansion/verified/IMG_6382.MOV -vf "fps=2,$HDR,hflip,vflip" -q:v 3 /tmp/f/a%03d.jpg
    # 4. redraw each work's wall square-on; open /tmp/out/rect-<key>.jpg (600 x 420, 100 px per metre,
    #    picture centre at x 300, y 160, grid every 0.5 m) and read the floor line, corners and neighbours
    python3 $P/placement_rectify.py "/tmp/f/a*.jpg" "dark medieval room" 20.207,57.301,22.047 /tmp/parts.json /tmp/out

Frame `aNNN` is second `start + (NNN - 1) / 2`. Room labels are the ones in the sizes table. A
painting needs about 40 matches to be trusted; a "PAIR" line is the centre of one work in the
metres of another matched in the same frame.
