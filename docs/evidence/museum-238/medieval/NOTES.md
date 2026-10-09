# Medieval room, first version (#238)

Branch `room/medieval`, base `8fca73d3`. Time-boxed: the six missing works are in; the
corrections to existing objects, the walls and the room plan are measured but **not applied**.

**Not baked.** `collection_rooms/` is unchanged on this branch, so the game still shows the old
room until the rooms are rebuilt. The draft build passed the architecture check (`failures: []`)
and the bake preparation counted 1399 surfaces (1358 before, 41 new). The bake itself was stopped
by the coordinator after about 13 minutes at a machine load of 80; one bake is to follow the merge.
Every picture here is an unbaked draft render.

## What is built

All in `modules/shell/prototype/collection_reconstruction/medieval_additions.gd`, placed with
`wall_point()` from the room's own walls and re-parented to the south or west wall body.

| Audit # | Work | Built as | Position (provisional) |
| --- | --- | --- | --- |
| 7 | Head of Christ or a Saint, 59.131 | photograph slab 0.813 m high on an octagonal pedestal (top 1.50 m), label card on the pedestal | 8.62 m along the south wall from the west corner |
| 8 | Christ in Majesty, 69.196 (was "stone relief slab", unidentified) | slab 0.978 m high on a rectangular pedestal (top 1.20 m), label | 7.39 m |
| 9 | The Crucified Christ, 43.195 (was a candidate) | slab 2.159 m high, feet 1.00 m up; long white platform 3.10 x 0.50 x 0.15 m under it, label lying on the platform | 5.28 m |
| 10 | Saint Peter, 20.254 (was "bust with a staff", unidentified) | slab 0.762 m high on a rectangular pedestal (top 1.20 m), label | 3.27 m |
| 11 | St. Anthony Abbot Enthroned, 16.243 | gabled slab 2.324 m high, bottom 0.60 m up, on a lighter backing 1.62 x 3.30 x 0.08 m, label on the backing | 1.75 m |
| 12 | Angel of the Annunciation, 37.114 | slab 1.524 m high on a low octagonal pedestal (0.69 m), label on the wall | west wall, 1.29 m from the south wall |

Every work carries `catalogue_accession`, title, maker, date, medium, dimensions and
`catalogue_image` (the catalogue photograph). Records, URLs and credit lines:
`image-work/collection-room-remodel/additions/medieval/SOURCES.md`. Three identifications are
new and rest on picture matches, not on labels (not legible): 69.196, 20.254, 43.195.

Sizes: catalogue heights, unframed/overall as the record gives them; no frame allowance was
added (16.243's record includes its integral frame). Widths follow the photograph outlines.

## How positions were measured

1. Structure from motion (pycolmap 4.2.1, free): IMG_6382 at 6 frames a second (679 frames)
   and the first 30 s of IMG_6344 (180 frames). One model registered 746 frames, 43,782 points,
   0.85 px mean reprojection error. Camera: 890 px focal length at 1080 x 1920, so the portrait
   view is 94.3 degrees high and 62.5 wide.
2. Floor plane from 529 floor points (1.5 cm residual). Axes from the plane of St Anthony's
   painted panel (4,506 points, 0.8 cm residual). Scale 0.89 m per model unit from the same
   panel: catalogue height 2.324 m gives 0.8855, body width 0.921 m gives 0.895.
3. Each object's position is the median of its own reconstructed points
   (59.131: 1,709 points; 69.196: 748; 43.195: 2,068; 20.254: 101; 16.243: 4,693; 37.114: 686).

Checks: the portal's overall width comes out 4.25 m against the catalogue's 4.229 m. The
north wall reads about 1.3 degrees off the panel's plane, so along-wall positions carry about
+-0.1 m and heights +-0.05 m. Pedestal and platform sizes are by eye from the frames.

## Measured but not applied

| Subject | Build | Footage (this fit) | Evidence |
| --- | --- | --- | --- |
| Room width, west to east wall | 10.00 m | 10.17 m (west wall face -5.72, east about +4.45) | wall-mounted points, baseboard picks in IMG_6382 86.0 s |
| Room depth, north to south wall | 6.10 m | 5.62 m (north face -2.52, south baseboard +3.10) | same; south wall from 21 baseboard points only |
| Door axis (tracery door, tall case, stair door) from the north wall | 3.665 m of 6.10 | about 2.8 m of 5.62, so near the middle | tracery points z -0.2..1.1, stair-door frame -0.7..1.3, tall case 0.28 |
| Iron screen | one flat panel | **one flat panel**, 0.87 m or more wide, 0.23 to 0.27 m off the wall; the "second angled panel" is its shadow: its 415 points lie flat on the wall plane | IMG_6382 12.3 s (frame A/000075) |
| Bartolo 20.207 and Virgin 57.301 centres apart | 1.22 m | 0.82 m (z -0.89 and -1.71) | panel points; agrees with the size audit's 0.86 to 0.875 |
| Tall case centre to low case centre | 2.60 m | 3.8 m (x 1.39 and -2.40), both on the door axis | case contents' points |

If the plan is changed to the measured room and the doors stay where they are, the medieval
bounds become z 28.97..34.60 (north wall 0.87 m south of the Hall's end wall, which is about
the real wall thickness) instead of 28.10..34.20. Not done: it moves every existing object
in the room and needs the wall infill described below.

## The stone archway (Romanesque Portal 40.014)

It is the Main Hall's: `gallery_walk4/walk4.gd` `_arch_end()` and `_portal_stone()`, kept in
the Hall's bake (`Surface004`, `Surface005`); `retained_hall_room.gd` skips the room scripts'
own copy. Not edited.

| | Build | Footage |
| --- | --- | --- |
| Stone pier fronts beyond the medieval north wall face | 1.83 m (reveal 0.45 + `PORTAL_DEPTH` 1.2 + 0.18), shaft bases and imposts to 2.2 m | 0.10 m, +-0.08 |
| Depth of the stepped stone jamb into the wall | 1.2 m tunnel behind the fronts | about 0.8 m (inner jamb at -3.3 against the wall face at -2.5) |
| Clear opening between the inner shafts | 1.90 m | about 1.5 m |
| Overall width | 4.18 m | 4.25 m (catalogue 4.229) |

Cause: the Hall's end wall and the medieval north wall are the same plane (z 28.1) with no
thickness, so the whole depth of the portal stands in the medieval room, with open gaps
beside the tunnel. Correction for the Hall and the plan together:

1. Give the wall its thickness: medieval north wall face `T` south of the Hall's end wall.
   From the doors, `T` = 0.87 m (see above).
2. In `walk4.gd`, shorten the passage so the pier fronts end 0.10 m beyond that face: reveal
   plus tunnel 0.87 - 0.08 = 0.79 m in place of 1.65 m (for example reveal 0.15 and
   `PORTAL_DEPTH` 0.64), which also needs `PORTAL_MOUTH` in `main_build_walk.gd` (2.2) and the
   two portal guards in `retained_hall_room.gd` (z centre 29.425, depth 1.77) moved to match.
3. Close the medieval wall round the stone: a wall face with a round-headed hole (piers 2.09 m
   either side of the axis to the spring at 2.39 m, radius 1.83 m above) in place of today's
   4.229 x 3.861 m rectangular opening.

## Not done, and why

Time box. None of these was started in the sources:

1. Corrections to existing objects (brief item 2): panel heights and spacing, the case
   positions, apostle brackets, vents, pier. Numbers above; the size audit has the heights.
2. Walls and detail (item 4): baseboard, stair-door surround and lettered strip, ceiling
   track, low vents, wall text, fire devices, thermostat, security dome, floor outlets.
3. Label cards for the works that were already there (four panels, two apostles, portal,
   tracery, screen, case objects). Only the six new works have cards.
4. Room plan (item 5): no change made to `prepare_remodel.py`.
5. Real volumes for the head, the bust and the angel: they are flat photograph slabs
   0.28 to 0.35 m thick and read as cut-outs from the side. No paid generation was used.
6. The crucifix platform's raised label rail and printed text; pedestal sizes from a fit.

## What other files need

1. `remodel_bake.gd`: spot lights for the six new works (the room has two fill lights only).
2. `modules/shell/PROVENANCE.md`: the twelve JPEGs and `shapes.json` under
   `additions/medieval/`, source and licence as in SOURCES.md, cost 0.
3. `export_presets.cfg`: `collection_rooms/assets/additions/medieval/shapes.json` must be in
   the export (check that `collection_rooms/assets/*.json` reaches sub-folders).
4. `main_build_check.gd` expects exactly 350 probes. Not checked: no bake was completed, and
   41 new static meshes may change the generated probe count.
5. `scripts/rebuild_rooms.sh`: the `--import` step crashed twice with a segmentation fault
   while other builds were running (load average 24) and passed on the third run unchanged.
6. The app picks up the six works from their metadata; `collection_rooms/objects.json` needs
   no row for them unless a caption should differ from the catalogue record.

## Pictures

Unbaked draft renders at the footage camera's field of view (94.3 degrees high, 720 x 1280),
from positions chosen by eye, not from the fitted camera poses.

| File | Left | Middle | Right |
| --- | --- | --- | --- |
| `01-south-wall.jpg` | IMG_6382 79.5 s | before | after |
| `02-head-59131.jpg` | IMG_6382 30.5 s | before | after |
| `03-christ-in-majesty-69196.jpg` | IMG_6382 36.0 s | before | after |
| `04-crucified-christ-43195.jpg` | IMG_6382 39.0 s | before | after |
| `05-saint-peter-20254.jpg` | IMG_6382 50.0 s | before | after |
| `06-st-anthony-16243.jpg` | IMG_6382 57.2 s | before | after |
| `07-angel-37114.jpg` | IMG_6382 60.5 s | before | after |
| `08-archway-not-changed.jpg` | IMG_6382 1.0 s | the build today: pier fronts 1.83 m out | |
| `09-dollhouse.jpg` | before, from above the Hall end | after | |
| `10-iron-screen-is-one-panel.jpg` | IMG_6382 12.3 s: one panel and its shadow on the wall | | |

What the pictures show that is still wrong: the works are flat slabs with a pale side band;
pedestals are darker than the footage's blue-grey; the backing panel is wider and shorter than
the real one; no spot light falls on any of the six works.
