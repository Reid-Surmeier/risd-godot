# Skylight Gallery: builder notes (Issue #238)

Branch `room/skylight`, base `8fca73d3`. First version, built inside a 45-minute time box. **Provisional throughout.**

## What is built

The 2.0 x 1.6 m stub "piano-stair threshold study limit" is replaced by two rows of `geometry['rooms']`:

| Row | Bounds, room-scene metres `[x0, x1, z0, z1]` | Openings |
| --- | --- | --- |
| `Skylight Gallery` | `[0.35, 9.85, -10.76, -5.76]` (9.5 x 5.0 m), height 3.9 | south `[4.55, 6.55]` |
| `Skylight Gallery reveal threshold` | `[4.55, 6.55, -5.76, -4.96]` (the door wall's 0.8 m thickness) | north and south `[4.55, 6.55]` |

The grey gallery's north opening is unchanged (`[4.55, 6.55]`).

In `skylight_additions.gd`: blue-grey walls, a flat ceiling with two gridded emissive laylights and a plain cornice (all hide when the camera is above them), the door reveal with two folded leaves, lift 4 as a closed wall feature with the SKYLIGHT GALLERY strip, a black grand piano and bench from simple solids (with collision), the five works at catalogue size with metadata and a blank label card each.

## The big simplification: one level instead of two

`IMG_6379.MOV` shows a double-height room. The grey gallery's door opens on an upper landing with an iron balustrade; a black stair runs round the east end down to the floor that holds the piano, the EXIT double door, lift 4, a closet door and a vestibule. The visitor in the app cannot change level (`main_build_walk.gd` holds `y = 0`), so this version builds the whole footprint at the door's level: a walkable flat room with the piano and the works in their true plan positions and the works at their true heights above the door's floor. The landing, stair, lower floor and the lower-floor doors are **not built**.

## Measurements

Method: structure-from-motion on 609 frames of `IMG_6379.MOV` (the sharpest of every three at 10 per second, exhaustive matching, pycolmap 4.2.1): 423 frames registered, 26,977 points, mean reprojection error 0.72 px. Scale from one catalogue size: the top edge of the Diao canvas (69.094, 221 cm wide) triangulated from frames 378, 381, 392, 400, 1514 and 1534 (37.7 to 153.3 s) is 3.089 model units (3.04 to 3.12 leaving one frame out), so 1 unit = 0.7155 m, +/- 1.3 %.

| Dimension | Value | Source | Confidence |
| --- | --- | --- | --- |
| Room, north to south | 5.04 m, built 5.0 | North wall plane (2,708 points, the Congdon and Feldman wall) to the south end of the landing's west balustrade; single-view check on the frame at 127.0 s gives 5.1 m | medium, +/- 0.3 m |
| Room, west to east | 9.55 m, built 9.5 | West wall from the triangulated Diao corners; east wall **not seen in the point cloud**: the stair well's inner balustrade plus one flight width taken equal to the other two flights | low, +/- 0.6 m |
| Grey-gallery door along the south wall | centre 5.2 m from the west wall, 4.3 m from the east wall | Camera path through the door at 176 to 182 s; the landing spans 2.7 m with the door on it | low, +/- 0.4 m |
| Ceiling above the door's floor | 3.9 m | Diao top edge 2.75 m above the landing floor, plus wall and cornice above it by eye (frames 40.0, 127.0 s) | low, +/- 0.3 m |
| Lower floor below the door's floor | 3.3 m | Landing floor to the lowest floor points | medium, +/- 0.2 m; **not built** |
| Upper landing | 2.7 m east to west, 1.65 m deep | Balustrade lines in the point cloud; frames 38.0, 153.0 s | medium; **not built** |
| Stair | three flights round the east end (north wall, east wall, south wall), well 1.75 x 2.07 m | Balustrade U in the point cloud; frames 6.0, 7.0, 99.0, 113 to 127 s | medium; **not built** |
| EXIT double door, north wall, lower floor | 1.8 m wide, centre 0.5 m west of the upper door's centre | Door-jamb point clusters; frames 103.5, 157.0 s | medium; **not built** |
| Door wall thickness (reveal) | 0.8 m, built | **Not measured.** The footage shows both leaves folded inside a deep panelled reveal (6379 169 to 182 s, 6380 0.0 and 14.0 s). 0.8 m is the build's own rule for the Hall door (one folded leaf less the proud frame) and puts the room's south wall on Rockefeller's north wall line | low |
| Door width | 2.0 m, unchanged | The built interval. On 6380 14.0 s the opening looks nearer 1.5 m against its height; not measured, not changed | low |
| Piano | 1.75 x 1.48 m, case 0.60 to 0.98 m | By eye from 3.0, 14.0, 132.0 s; maker unread | low |

Work positions: the Diao is centred on the west wall (127.0 s); the Feldman hangs over the EXIT door, the Congdon east of it and the Mangold west of it on the north wall (132.0, 54.0 s); the Walsh is on the east wall over the stair (6.0, 52.5 s). Distances along the walls come from the point cloud for the Feldman and Congdon and are by eye for the Mangold and Walsh. Heights: the Diao's centre is 1.64 m above the door's floor (triangulated); the others are set by eye against it.

## The five works

Catalogue sizes are unframed canvases; nothing was added for a frame (none has one in the footage).

| Work | Size | How identified | Picture used |
| --- | --- | --- | --- |
| David Diao, *Untitled*, 1968, 69.094 | 222.3 x 221 x 3.8 cm | Catalogue photograph matches the tan canvas (38 to 40 s) | catalogue |
| Robert Mangold, *Distorted Circle within a Polygon II*, 1972, 73.018 | 224.2 (wide) x 203.8 cm | Catalogue photograph matches outline and drawn circle (155.0 s) | catalogue |
| Amy Feldman, *Foreign Sign*, 2016, 2026.3 | 152.4 x 153 cm | Wall label read at 103.9 s: "Amy Feldman ... Foreign Sign, 2016, Acrylic on canvas" | footage crop, 54.0 s (no catalogue photograph online) |
| Dennis Congdon, *Pile*, 2000, 2000.17 | 221 x 188 cm | Catalogue photograph matches (134.0 s) | catalogue |
| Dan Walsh, *Spectrum II*, 1998, 2025.19 | 152.4 x 152.4 x 3.8 cm | **Inferred, not label-verified.** The only other on-view recent-acquisition acrylic on canvas in the catalogue; its label carries the same "Recent Acquisition" tag and line pattern (138 to 139.5 s) but cannot be read. A sharper label frame would settle it | footage crop, 52.5 s (no catalogue photograph online) |

URLs and credit lines: `image-work/collection-room-remodel/additions/skylight/SOURCES.md`.

## Neighbours

No overlap in the generator. The room lies north of z = -5.76, which is Rockefeller's north wall line, so its west 1.35 m (x 0.35 to 1.7) runs behind Rockefeller's north wall. That only works because the reveal is 0.8 m: with a thinner door wall the room would overlap Rockefeller by up to 1.35 x 0.8 m and would have to stop at x = 1.7. The east wall (x = 9.85) is 1.2 m short of the grey gallery's east end (11.05), so the room does not reach the marble stair hall's side.

## What other files need (not edited here)

1. `main_build_walk.gd`, `FAR_ROOMS`: replace `"piano-stair threshold study limit"` with `"Skylight Gallery"` and add `"Skylight Gallery reveal threshold"`.
2. `main_build_check.gd`: the plan now has 15 added rooms (was 14); blocks, cut-away bodies and the probe count (350) may differ.
3. `remodel_review.gd`: unchanged; its ceiling assertion was already out of date and now sees three more ceilings (this room's, its two laylights and the reveal soffit make it nine in all).
4. `collection_rooms/objects.json` (if kept): rows for the five accession numbers.
5. `modules/shell/PROVENANCE.md`: a line for this bake.

## Lamps and probes for the bake (room-scene metres; not added to `remodel_bake.gd`)

The two laylights are emissive panes (energy 2.5) at y = 3.89: centres (3.95, -8.26), 3.4 x 2.6 m and (7.05, -8.26), 1.7 x 2.6 m. If the baker prefers lamps, hide them from the bake and use:

| Kind | Position | Target | Settings |
| --- | --- | --- | --- |
| Omni fill | (1.9, 3.5, -8.26), (3.95, 3.5, -8.26), (7.05, 3.5, -8.26), (8.9, 3.5, -8.26) | | colour f2f0ea, energy 0.8, range 7, size 0.12 (as the modern gallery's) |
| Spot, Diao | (1.95, 3.6, -8.26) | (0.43, 1.64, -8.26) | f2f0ea, energy 1.2, angle 40, range 6 |
| Spot, Mangold | (2.55, 3.6, -9.16) | (2.55, 1.75, -10.68) | same |
| Spot, Feldman | (5.0, 3.6, -9.16) | (5.0, 2.0, -10.68) | same |
| Spot, Congdon | (7.98, 3.6, -9.16) | (7.98, 1.75, -10.68) | same |
| Spot, Walsh | (8.25, 3.6, -8.26) | (9.77, 1.9, -8.26) | same |
| Spot, piano | (2.6, 3.6, -8.6) | (1.9, 0.9, -9.7) | energy 0.8 |
| Probes | x in 1.5, 3.5, 5.55, 7.5, 9.0; z in -10.0, -8.26, -6.5; y in 0.3, 1.1, 2.0; and (5.55, y, -5.36) in the reveal | | 48 probes |

## Not done, and why

1. The two levels: landing, balustrades, three-flight stair, lower floor, EXIT double door, vestibule opening, closet door, wayfinding screen, directory plaque, fire devices, the vent and cameras in the south-east corner. Time box; and the app cannot walk levels.
2. Floors: the footage has pale straight boards below and a black landing; the build has the default oak boards.
3. Ceiling track heads, the dentil cornice, the exit signs.
4. Leaves hinge on the grey-gallery side in the footage; `build_reveal` puts the knobs there instead.
5. Measured wall positions for the Mangold and Walsh, the east wall, the door's width and the reveal depth.
6. A sharper frame for the Walsh label; catalogue photographs for the Feldman and Walsh do not exist online.
7. The walking self-check (`--selfcheck`, about 9 minutes) was not run; three trials were added (`grey_skylight_out`, `grey_skylight_back`, `skylight_piano_blocked`) and the stub's two removed.
