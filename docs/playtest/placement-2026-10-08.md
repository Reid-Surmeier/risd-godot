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

## Already measured by the 1 October audit and still not in the build

Not re-measured here. Where this ticket re-measured the audit (five readings above) it was right.

- **Main Hall hang heights.** 20 of 23 paintings hang 0.12–0.40 m too low; W6 0.30 m too high. The
  audit's section 4 has a ready table of new `hang` values for
  `modules/shell/prototype/gallery_walk4/works.json`, ±0.06 m. `works.json` still holds every old
  value. A visitor sees the Hall's saved bake, so this needs the Hall re-baked with it.
- **Three Hall canvases** differ from the catalogue on the wall: W7 44.161 (1.222 → 1.111 m
  high), E8 62.064 (1.975 → 2.104 m), W6 32.246 (1.98 x 3.31 → 2.06 x 3.46 m). Same file.
- **Grey gallery**: Courbet 43.571 canvas 1.12 m above the baseboard top in footage (IMG_6380
  3.5 s). The built canvas bottom is 1.39 m above the floor now, about 1.20 m above a 0.19 m
  baseboard: 0.08 m high, on the line.
- **Modern gallery**: Matisse 57.037 canvas bottom 1.14 m filmed, 1.25 m built (IMG_6387 74.4 s):
  0.11 m high. Braque, Cézanne and Le Fauconnier agree with the build.

## Not started

European gallery, Rockefeller, grey gallery and modern gallery positions along the walls; every
standing work's base height; the rest of the Renaissance room.
