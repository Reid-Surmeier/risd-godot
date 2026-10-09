# Marble stair hall (#238): builder notes

Branch `room/marble-hall`, base `8fca73d3`. First version, built inside a 45 minute time box: the room is real and walkable, the stair is simple solid geometry, both objects are identified and placed. Everything metric is a one-camera estimate and is marked provisional in the code.

**Not baked and not installed.** By the coordinator's instruction this commit holds sources, pictures and these notes only; `collection_rooms/` is unchanged and still shows the stub until the rooms are rebuilt after the merge. `scripts/rebuild_rooms.sh --draft` passes its architecture check on these sources (`failures: []`). In two full runs the bake's own preparation step passed (`BAKE_PREPARE surfaces=1401`, 43 more than the 1358 at base); both bakes were then stopped from outside before finishing, so no lightmap of this room exists and no baked picture was looked at.

## What is built

| Audit item (section 3.1) | State |
| --- | --- |
| The hall as a room | **Built.** `marble stair hall`, 8.4 x 6.0 m, 8.0 m high, replaces the 1.6 x 6.0 m Ionic stub. |
| Columned opening from the grey gallery | **Kept as it was**: the grey gallery's whole east side, z -4.96 to 1.04, identical on both rooms. Columns, pilasters and beam untouched. |
| Marble floor in a large diagonal checker | **Built**, two flat tones, 0.76 m squares at 45 degrees, grey band on the column line. No veining, no border band along the walls. |
| Stair: curved first step, about 14 steps, two quarter-turns of winders, iron balusters, wood handrail, wall handrail | **Built, simplified.** 13 steps + 6 winders + half-landing + 6 winders + 4 steps = 31 risers. Winders fill square corners (the real walls are curved). Balusters are plain bars with a cross on every other one; no scrollwork. |
| Three-part window on the half-landing | **Built, simplified**: arched middle light, two side lights, four engaged columns as plain shafts, sill, apron, grille. |
| Upper landing, balustrade round the well, three doorways | **Built** as a slab over the strip behind the columns with an arm over the fireplace, balustrade, three closed doors. No glass screen, no floor pattern. |
| Art Nouveau chimneypiece with its label | **Built and identified**: RISD 83.152. Blank label card to its right. |
| Blown-glass chandelier | **Built and identified**: RISD 2011.60. Authored geometry, not a likeness. Blank placard on the upper balustrade. |
| Doorway under the stair with an exit sign | **Built as a closed door** with its EXIT sign. |
| Lit passage to a further gallery | **Built as a closed door** in a grey wall, vent above, fire alarm pull beside it. |
| Round-arched niche with a stair going down | **Placeholder**: a dark blind recess. The stair down is not built. |
| Cornice, ceiling lights | Flat ceiling with a plain cornice, hidden when the camera is above 3.4 m. No lights modelled. |

## Plan, in room-scene metres

x grows east, z grows south. Column line x = 11.05.

| Dimension | Value | Read from | Confidence |
| --- | --- | --- | --- |
| Width north to south | 6.0 m (z -4.96 to 1.04) | The built grey-gallery opening. IMG_6380 43.0 s: the north pilaster stands on the hall's north wall line. IMG_6380 70.0 s: the passage wall, the south pilaster and the grey gallery's south wall share one baseboard line. | High that the hall is as wide as the opening; the 6.0 itself is the grey register's (5.4 to 6.6). |
| Depth, columns to the window wall | 8.4 m (x 11.05 to 19.45) | Sum of the rows below. | Low to medium, about +-0.6 m. |
| Columns to the west corner of the fireplace wall, which is also the upper landing's edge | 2.8 m | IMG_6380 70.0/71.0 s: 0.5 m of wall with the fire pull, a 2.0 m casing, 0.3 m to the pilaster. Scale: the casing's height against a pull station at 1.15 m. | Medium. |
| That corner to the fireplace | 1.0 m | IMG_6380 50.5 s, against the fireplace's 2.11 m lower body. | Medium. |
| Fireplace | 2.108 m wide, 3.498 m high | RISD catalogue 83.152. | High. |
| Fireplace to the inside corner under the half-landing | 0.9 m | IMG_6380 47.0 s. | Medium. |
| Depth of the half-landing | 1.6 m | Taken equal to the flight width. | Low. |
| Flight width | 1.6 m | IMG_6381 71.0 s: a tread is about 1/5 of the flight's width. With 1.6 m both balustrade lines land on the two Ionic columns (z -3.36 and -0.56), as IMG_6381 83.5 s shows for the north one. | Medium. |
| Open floor between the two flights | 2.8 m | 6.0 - 2 x 1.6; IMG_6381 72.0 s gives 2.6 to 3.0 m. | Medium. |
| First step from the column line | 2.25 m (nosing), plus a rounded end | IMG_6380 45.5 s (2.1 to 2.9 m) and IMG_6381 83.5 s (1.4 to 1.9 m). | Low. |
| Upper landing soffit, the ceiling of the strip behind the columns | 3.745 m | IMG_6380 65.0 s and the 83.152 photographs: the soffit bracket sits just above the 3.5 m fireplace. | Medium. |
| Upper floor | 4.495 m | 31 risers of 0.145 m; IMG_6381 31.5 s: from the half-landing the eye is level with the upper floor. | Medium, +-0.3 m. |
| Ceiling | 8.0 m | IMG_6381 58.75 s and the 2011.60 photographs: the window's arch, 0.65 m of wall, cornice. | Low. |

No neighbour is in the way: the nearest rooms are the Grand Gallery (x up to 10.55) and the modern adjoining stub (z from 20.7). The generator's overlap assertion passes with the full footprint.

## Stair

1. Direction: the first flight rises **east along the north wall** (IMG_6381 83.5 s looks down it to the north column). The audit's "east wall" is wrong.
2. 13 straight steps (counted three ways: IMG_6380 45.5 s, IMG_6381 71.0 s, 83.0 s give 12 to 14), tread 0.35 m, riser 0.145 m.
3. 6 winders round the north-east corner (IMG_6381 80.75 s), half-landing at 2.90 m under the window, 6 winders round the south-east corner (75.5 s), 4 straight steps west (68.5 s) to an arm of the upper landing at 4.495 m. The arm runs west over the fireplace to the main landing (72.0 s and the 83.152 photographs).
4. Risers and treads are inferred, not measured: 31 risers must reach about 4.5 m, and 0.145 + 0.35 keeps the run consistent with the fireplace wall's length. A 0.165 m riser would put the upper floor at 5.1 m, which the fireplace photographs rule out.
5. Not walkable: `floor_void` [13.85, 19.45, -0.56, 1.04] (the service stair under the upper flight, behind the fireplace wall), plus collision-only solids over the first flight, the whole east end behind the exit wall, and the fireplace. Walk trial `marble_stair_blocked` covers the first flight.
6. Closed continuation: the upper flight ends on the landing arm; three closed doors stand on the upper level. Nothing ends in mid-air.

## Objects

| Object | Identification | How it was confirmed | Size used |
| --- | --- | --- | --- |
| Chimneypiece | Hugnet Frères, *Fireplace Surround*, 1900, walnut, ceramic tiles and copper, RISD **83.152** | API search `fireplace`, on view; the catalogue's own photographs show it in this hall under the same stair string. The wall label is not legible in the footage (IMG_6380 52.0 s, enlarged). | Catalogue 349.8 x 210.8 x 50.8 cm, object size, no frame. Built 2.108 x 3.498 m on its outline, 0.40 m deep. |
| Chandelier | Dale Chihuly, *Gilded Frost and Jet Chandelier*, 2008, glass with metal armature, RISD **2011.60** | API search `Chihuly chandelier`, on view; the catalogue's photographs show it before this window. | Catalogue 121.9 x 274.3 x 228.6 cm. Authored geometry within it, centre 6.65 m up, 2.45 m west of the window wall. |

Sources and credit lines: `image-work/collection-room-remodel/additions/marble-hall/SOURCES.md`.

The "mirror" in the audit is the fireplace's copper panel.

## What other files need (not edited here)

1. **`main_build_walk.gd`, `FAR_ROOMS`**: replace the entry `"Ionic marble-stair threshold study limit"` with `"marble stair hall"`. Until then the hall counts as a portal-side room and the game changes space at the columns.
2. **`main_build_check.gd` line 43** expects exactly 350 probes. This room extends the baked volume east to x 19.45; read the new count from the bake log.
3. **`remodel_review.gd` line 64** counts opaque ceilings (already wrong at base: 5, not 3). This room adds one.
4. **`remodel_bake.gd`**: see the lamp list. The old stub's omni at (11.9, 3.25, -1.96) now sits under the upper landing and is the hall's only lamp, so a bake without the lamps below will leave the east end dark (inferred from the script; not seen).
5. **`modules/shell/PROVENANCE.md`**: a line for this bake.
6. `prepare_remodel.py` line 422 still seeds the row under the stub's label; my block after the trial loop renames and resizes it, and removes the two `grey_ionic` trials. No existing line was changed, so it merges with an edit to the piano-stair row.
7. The oak boards that `build_rooms` lays in any room without a known floor are deleted for this room in `marble_hall_additions.gd`. A `marble` branch in `build_rooms` would be cleaner.

## Lamps and probes this room needs

Positions in room-scene metres.

| Kind | Position | Target or range | Why |
| --- | --- | --- | --- |
| Daylight, area or spot, cool white | (20.2, 5.9, -1.96), outside the window | toward (15.0, 0.5, -1.96), 60 degree cone | The three-part window is the hall's main light (IMG_6381 24 to 29 s). |
| Omni, neutral, range 9, energy about 0.8 | (16.0, 7.4, -1.96) | - | Recessed ceiling lights over the well (58.75 s). |
| Omni, neutral, range 6 | (12.4, 3.4, -3.4) and (12.4, 3.4, -0.5) | - | Downlights in the soffit behind the columns (85.5 s). Replaces the stub's omni at (11.9, 3.25, -1.96). |
| Spot, warm, 35 degrees | from (15.9, 3.5, -2.6) | fireplace centre (15.9, 1.75, -0.85) | The fireplace reads lit from the front (65.0 s). |
| Omni, neutral, range 5 | (12.4, 7.0, -1.96) | - | Upper landing ceiling lights (31.5 s). |
| Probes at y 0.3, 1.1, 2.0 | x 12.4, 14.5, 16.8; z -2.0; and (12.4, -4.0), (12.4, 0.2) | - | The walkable floor. |
| Probes at y 3.4, 5.0, 6.6 | (15.5, -1.96) | - | So the inspection camera at the chandelier's height is lit. |

## Pictures looked at

Footage: all nine 24-frame sheets of IMG_6381 (`IMG_6381-survey-v1`), my own sheets of IMG_6380 frames 92 to 163, and full-size frames IMG_6380 40 to 45.5, 47.0, 48.0, 49.0, 50.5 to 52.5, 54.0, 65.0, 66.5 to 67.25, 70.0, 71.0, 72.5 to 76.5 s; IMG_6381 0 to 3.5, 6.5 to 17.75, 20.5, 31.5, 66.5 to 83.5, 85.5 to 92.5 s. Catalogue: six photographs of 83.152 and nine of 2011.60.

Renders: the draft (unbaked) room project from ten cameras, then from the twelve cameras paired with footage in this folder (`01` to `10`). All are unbaked: flat draft light, every wall drawn. The two "before" halves of `08` and `09` are the stub in the audit's atlas of `32d3ba8c` (`build/museum-atlas/` in the coordinator's checkout).

What the pairs show, by looking: the layout agrees with the footage from the columns (`01`), down the first flight (`07`), toward the grey gallery (`04`) and across the well to the upper landing (`06`). They also show the faults listed below: square corners where the walls curve, a heavy disc for the newel, the fireplace's flat brown side and spur (`02`), a blind arch (`03`), and a window smaller than the real one (`01`).

## What remains, and why

1. **Curved east end.** The real window wall has two quarter-round corners that the winders follow. Built square: time.
2. **Service stair behind the arch.** Filmed (IMG_6380 72.5 to 77.5 s: black treads, iron balustrade, curved wall, sash window). Built as a dark blind recess: time.
3. **Ironwork.** Real balusters alternate plain bars with scrolled panels and collars; the handrail ends in a volute over a cage of bars. Built as bars, crosses and a disc.
4. **Glass screen** in front of the upper balustrade (IMG_6381 20.5 s). Not built.
5. **Fireplace depth.** One 0.40 m extrusion of the outline; the real overmantel is shallower than the base and the firebox is recessed. The outline has a spur at the lower right from the floor's reflection.
6. **Chandelier likeness** needs image generation or a much richer model. No paid call was made.
7. **Marble**: veining, the border band along the walls, the upper landing's bordered checker. Flat tones now.
8. **Alcove ceiling**: dentil cornice, six downlights, a slot diffuser (IMG_6381 85.5 s). Not built.
9. **Door leaves**: the three upper doors, the exit door and the passage door are plain slabs with casings.
10. **Wall colours** are by eye from IMG_6380 47 to 49 s.
11. **Not run**: the bake and the install (see the top); the walking self-check with the three new trials; the repo checks and the atlas in the app, with or without the `FAR_ROOMS` change. The camera cut-away rules for the internal walls (`room_wall` tags `south:chimney`, `south:return`, `south:arm`, `east:landing`, `west:landing`) and the walk blocks are reasoned from `main_build_walk.gd`, not seen in the app.
12. **The chandelier is outside the dollhouse camera's frame** from anywhere on this floor (it hangs from 6 m up; the frame tops out near 3 m). It is in the scene and carries its metadata.
