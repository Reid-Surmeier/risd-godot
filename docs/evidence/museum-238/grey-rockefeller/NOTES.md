# Grey French gallery and Rockefeller: builder notes (#238)

Branch `room/grey-rockefeller`, base `8fca73d3`. First version, built inside a 40-minute time box set by the
coordinator: everything below marked provisional is placed approximately and needs a second pass.
No paid call was made. Nothing in `prepare_remodel.py`, the room footprints or the doorways was changed.

**Not baked.** `scripts/rebuild_rooms.sh --draft` passes its architecture check (`failures: []`) on these
sources. One full run was started and its bake was stopped by the coordinator (machine load); the
coordinator bakes once after merging. So `collection_rooms/` is not updated on this branch, and every
"after" picture here is the unbaked draft. What the bake does to these rooms has not been seen.

## What was built

New files: `grey_additions.gd`, `rockefeller_additions.gd`, the pictures and `SOURCES.md` under
`image-work/collection-room-remodel/additions/{grey,rockefeller}/`. Edited: `build_grey_gallery()` and
`build_displays()` in `remodel_room.gd`, and seven pink-service rows of `video-inventory.json`.

### Grey French gallery

| Audit row | Work | State | Identification |
| --- | --- | --- | --- |
| 1 | Géricault, *A Cart Loaded with Kegs (Le Haquet)*, 43.539 | built | audit's label reading, then the RISD record; catalogue photograph matched to IMG_6380 8.17 s (533 SIFT inliers) |
| 2 | Courbet 43.571 | corrected: centre 1.80 to 1.69 m | already in the build |
| 3 | Bannister, *Landscape with shepherdess, sheep and cows*, 2023.53 | built | audit's label reading, then the RISD record; matched to IMG_6380 22.57 s (219 inliers) |
| 4 | Daubigny 73.120 | built | repository record; matched to IMG_6380 26.07 s (837 inliers) |
| 5 | Corot 24.089 | checked, left as it is | matched to IMG_6380 29.7 s (95 inliers); centre read 1.78 m against 1.80 built |
| 6 | Villeneuve 1998.35 | built | repository record; matched to IMG_6380 88.0 s (731 inliers) |
| 7 | Bertin 56.214 | corrected: 0.2 m east along its wall | already in the build |
| 8 | Pannini 56.094 | built | repository record; matched to IMG_6380 95.13 s (383 inliers) |
| 9 | Pier landscape | built as Eastlake, *The Celian Hill from the Palatine*, 56.099: **identification by eye** | found by listing every on-view painting in the catalogue and comparing the small landscapes with IMG_6380 101.7 s and 105.4 s (dark tree left, sunlit buildings, round ruin, bright sky). Both frames are blurred and the feature match failed (10 inliers), and the label is not legible. Settle it by reading the label on site. |
| 10 | Rodin, *The Hand of God*, 23.005 | built on a plinth | repository record |

Also changed in `build_grey_gallery()`:

1. **Black capitals: cause and fix.** The beam was a box from 2.72 to 3.50 m and the capitals stand from 2.70 to
   3.10 m, so the beam swallowed them. The bake gave them no light, and they only showed from the stair
   side, where the app's camera cuts the beam away with the grey gallery's east wall. The beam now starts
   at 3.10 m and the end pilasters run up to it. Seen: in the unbaked draft the capitals now stand clear
   under the beam from both sides (picture 06). Inferred, not seen: that the black was the bake, from the
   geometry and from `_collect_parts()` in `main_build_walk.gd`; it needs a look after the next bake.
2. Label cards on the three existing paintings are now the polish spec's 0.30 x 0.17 m, clear of the frame.

Fixtures built in `grey_additions.gd`: a blank card beside each new wall work except the pier's, one on the
Rodin's plinth, the exit sign over the piano door, the square-grid return under the Villeneuve, one high slot
on the south wall, a rectangle of ceiling track with twelve spot heads.

### Rockefeller

| Audit row | Work | State | Identification |
| --- | --- | --- | --- |
| 57-58 | Vincennes, *Neptune* and *Amphitrite as River Deity*, 2017.74.31.1 and .2 | built on the central pedestal | repository record; catalogue photographs fetched this round |
| 32 | Brown textile above the armchair | built as *Apparel textile length*, English, 44.226: **identification by eye** | found among the on-view textiles; arches and flowers match IMG_6380 135.0 s and 195.6 s. Not feature-matched. The acrylic box is not built. |
| 33-34 | Two stacked prints | built as Mary Smirke, *Cloisters' Wood* 2016.80.89 (top) and *A Lady in a Park* 2016.80.91 (bottom): **identification from the label name and by eye** | the label beside them reads "Mary Smirke" in IMG_6380 188.2 s; both are on view and their compositions match. They are watercolours, not prints. |
| 50-56 | Pink Worcester case | corrected | see below |
| 31 | Writing table (placeholder) | not done | |

**The case near the east door.** It is the pink Worcester case. As built it was 0.88 m deep and stood 0.11 m
clear of the south wall, so its north edge was 0.23 m from the east door's axis. In IMG_6380 123 to 128 s and
176 to 178.5 s it is a box hung on the wall, about 0.6 m deep. It is now 0.6 m deep and against the wall
(north edge 0.56 m from the axis); its seven pieces moved back with it in `video-inventory.json`. The
footage supports this: the view from the connector at 122.5 s has the floor clear along the axis.

Fixtures built in `rockefeller_additions.gd`: a card on the pedestal, one beside each watercolour, the exit
sign over the east door.

## What was measured, and from which frame

Method: the catalogue photograph is SIFT-matched to a video frame, which gives the wall plane in metres with
the canvas as the ruler (`rect.py`, kept beside this file). Read by eye off a 0.1 m grid.

| Quantity | Value | Frame |
| --- | --- | --- |
| Géricault frame, outer | 0.99 x 0.83 m (bands 0.13 / 0.105 / 0.13) | IMG_6380 6.87 s, 8.17 s |
| Courbet frame, outer | 1.06 x 0.92 m | IMG_6380 3.07 s |
| Courbet and Géricault, canvas centre above the baseboard top | 1.41 and 1.42 m | same frames |
| Baseboard height in this room | 0.26 to 0.28 m (the build has 0.16) | IMG_6380 3.07 s, 6.87 s, 95.13 s |
| Pannini frame, outer | 0.98 x 0.65 m | IMG_6380 95.13 s |
| Daubigny frame, outer | 0.80 x 0.50 m | IMG_6380 26.07 s |
| Bannister frame, outer | 0.455 x 0.38 m | IMG_6380 22.27 s |
| Villeneuve canvas | about 0.41 x 0.31 m, taking the record's 61 x 50.8 cm frame as the ruler | IMG_6380 87.87 s |
| Real labels | about 0.17 to 0.19 m wide, 0.25 to 0.28 m tall, to the viewer's right of each painting | all of the above |
| Hall door, clear width | 1.59 m (the build has 2.0) | IMG_6379 172.27 s |
| Gap, Bertin frame to Pannini frame | 0.58 m | IMG_6379 172.27 s |
| Pannini frame to the Hall door casing | 0.36 m | IMG_6379 172.27 s |
| **Pier**: Hall door's clear edge to the south-west corner | **1.20 m**; 1.03 m of free wall beyond the casing | IMG_6379 172.27 s |
| Eastlake frame, outer | 0.61 x 0.48 m; 0.29 m from the casing with its label between, 0.125 m from the corner | IMG_6379 172.27 s |

Frame allowances: every record used is the unframed support except 1998.35 (frame). The six new works wear
the room's three existing Muse frames, scaled by the frame helper to each canvas, so the built bands are
0.04 to 0.10 m against the measured ones above. None of the six frames is the work's own.

## The pier needs widening

The wall between the Hall door and the connector door is 0.70 m in `geometry.json` (0.59 m free once the
casing is drawn). The footage has 1.20 m (1.03 m free). The Eastlake is 0.61 m across its frame and has its
label beside it, so it cannot hang there as filmed: it is built with the thinnest frame (0.52 m) and no label.
The connector door's jamb stands 0.19 m out of the west wall 0.1 m in front of the frame's west end, so from
the west the painting is partly hidden behind it (picture 05). Nothing intersects.
The grey gallery's west wall would have to move about 0.5 m west, or the Hall door be narrowed to its
filmed 1.6 m, for the pier to take the work as it hangs.

## Provisional

1. Hang heights. Two readings disagree: the close-up fit puts the Pannini's centre 1.79 m above the floor,
   the square-on view from the piano door about 1.52 m. I did not resolve this. Built: 1.69 m on the west
   wall, 1.75 to 1.80 m elsewhere.
2. Positions along the north and south walls, apart from the three measured gaps above, are by eye from
   the order and spacing in the footage.
3. The Rodin: distance from the columns, the plinth's size (1.0 x 0.5 x 1.0 m) and which way it faces are by
   eye. The volume is the front photograph's silhouette swept round, with that photograph on both sides;
   the hand does not read from behind.
4. The Vincennes pair: same construction, same limit; which way they face is by eye.
5. Frame and mount sizes of the two watercolours, the board behind the silk, the ceiling track's run and the
   vents' positions are by eye.
6. The three identifications marked by eye above.

## Not done

1. Grey gallery: wall text east of the piano door, hanging wires and rail, dentil cornice, stone threshold
   band under the columns, the louvre vent, the second high slot, security domes, the label on the pier.
   Frames of their own for the six new paintings.
2. Rockefeller: about eleven of the fourteen labels, the wall text "The Artist's Profession", the lettered
   strip over the south door, the south door's folded leaves, the thin floor frame under the pink case (the
   case still stands on four legs), security domes, the half-round writing table, the acrylic box over the silk.
   The size audit's corrections for this room (wallpaper 0.55 m too high, armchair width, Mrs. Edwards) are
   not applied.
3. Connector: nothing. Call button, wayfinding screen, black double doors, pull station and ceiling lights
   are still missing.
4. Door casings and lift panels were not compared with the footage. Holes, gaps and z-fighting were looked
   for only in the pictures listed below.
5. The walking self-check and the app-side checks (`main_build_check.gd`, `click_route_check.gd`, the
   playtest) were not run on this branch.

## What other files need (not edited here)

1. `collection_rooms/objects.json`: caption rows for 43.539, 2023.53, 73.120, 56.094, 1998.35, 56.099, 23.005,
   2017.74.31.1, 2017.74.31.2, 2016.80.89, 2016.80.91 and 44.226. Title, maker, date, medium, dimensions and
   picture are on each node as `catalogue_*` metadata.
2. `main_build_check.gd`: its expected counts will move (one more walk block for the Rodin's plinth; the
   bake preparation counted 1423 surfaces against 1358 before).
3. `modules/shell/PROVENANCE.md`: the twelve catalogue photographs in the two `SOURCES.md` files.
4. `build_rooms()` in `remodel_room.gd`: this room's baseboard is 0.27 m, not 0.16 m.
5. `remodel_bake.gd`: no spot lights were added for the new works; the grey gallery still has only its two
   fill lights.

## Pictures

Each is the footage frame, the base before (an unbaked draft of `8fca73d3`, where one was taken from the
same place) and this branch's unbaked draft, from the room project (`capture.gd`). The room project draws
the Hall's dark door tunnel into the grey gallery; the app removes it. In 02 the camera stands inside the
Rodin, which is the blob in the foreground.

| Picture | Shows | Footage |
| --- | --- | --- |
| `01-grey-west-wall.jpg` | Géricault added beside the Courbet, both lower; cards; track | IMG_6380 38.5 s |
| `02-grey-north-wall.jpg` | Bannister and Daubigny before the Corot; exit sign; capitals under the beam | IMG_6380 16.0 s |
| `03-grey-south-wall.jpg` | Villeneuve, Bertin, Pannini; the Rodin; vents | IMG_6379 172.27 s |
| `04-grey-rodin.jpg` | The Rodin on its plinth before the columns | IMG_6380 17.0 s |
| `05-grey-pier.jpg` | The Eastlake on the 0.70 m pier, partly behind the connector door's jamb | IMG_6380 105.44 s |
| `06-grey-capitals-from-stair-side.jpg` | Before: the beam swallows the capital. After: the capital under the beam | IMG_6380 34.5 s |
| `07-rockefeller-from-connector.jpg` | The pink case back against the wall; the door's axis clear | IMG_6380 122.5 s |
| `08-rockefeller-west-wall.jpg` | The silk on its board; the pair on the pedestal; the watercolours | IMG_6380 224.0 s |
| `09-rockefeller-south-wall-prints.jpg` | The two watercolours under the sconce | IMG_6380 189.17 s |
| `10-rockefeller-pedestal.jpg` | The Vincennes pair and the pedestal's card | IMG_6380 223.5 s |

`prep_assets.py` derives the pictures under `additions/`; `rect.py` is the measuring tool; `capture.gd` took
the renders.
