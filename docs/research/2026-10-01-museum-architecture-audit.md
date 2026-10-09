# Museum architecture audit — built rooms against the walkthrough footage

2026-10-01. Read-and-measure only: no tracked file was changed, nothing was baked, no paid call. Stopped early at the coordinator's request, so section 6 lists what was not reached.

## Answer

1. **The Main Hall is built 4.4 m too long: 21.9 m, not 26.3 m.** Both long walls were measured painting by painting. Everything attached to its far end, and the parallel European gallery, inherits the error.
2. **The stairwell is the wrong kind of stair.** The real one is an open-well stair filling a shaft as wide as the landing, with one flight up along the west wall and one down along the east wall. The build has two straight parallel flights side by side in the west half.
3. **The medieval room is 0.5 m too deep and its two side doors are in the wrong places** (stair door 1.07 m too far south, tracery door 0.6 m too far south). They are not on one axis; they are 0.44 m apart.
4. **The black slabs on the medieval floor are baked shadow under furniture that the camera has hidden.**
5. Room widths, the Renaissance room, Rockefeller and most ceiling heights are right to within the measurement error.

## How it was measured

- **Method.** For each wall, the footage frames were rectified onto the wall's plane using camera poses from structure-from-motion, giving a flat mosaic. Positions were read off the mosaic and scaled by catalogued works lying in that same plane. This does not depend on the lens focal length.
- **Models used.** Existing: `sfm-6344`, `sfm-6344-east`, `sfm-6344-west`, `sfm-galleries-v3`, `sfm-connected-v4` under `/home/reidsurmeier/risd-godot-ingestion/`. New, run for this audit on IMG_6382, 6383 and 6387 (4–5 frames per second, exhaustive matching): 389, 233 and 231 registered frames.
- **Three kinds of statement below.** *Measured* = read off a mosaic or model by me. *Earlier* = claimed by a document under `docs/evidence/collection-reconstruction/`. *Inferred* = my reasoning, no direct reading.
- **Errors.** Edge picks are good to about 0.05 m on sharp mosaics. Scale per wall is good to about 3 %. Heights are weaker than plan distances: the models' vertical is tilted by 2–4°.
- Scratch, scripts and mosaics: `build/audit-architecture/` (`notes.md` holds every reading; `frames/ortho-*.png`, `frames/og-*.jpg`, `frames/top-*.png` are the mosaics and plans).

Coordinates are `geometry.json`'s: x east, z south, metres.

## 1. Rooms

### Main Hall ("Grand Gallery") — wrong

Source: IMG_6344 21–26 s and 160–178 s; the two wall sweeps at 4 fps.

| | Built | Measured | Verdict |
| --- | --- | --- | --- |
| Length | 26.3 | **21.8 (west wall), 21.9 (east wall)** | Wrong. Use 21.9 ± 0.5 |
| Width | 10.0 | 10.0 ± 0.3 | Matches |
| Gaps between frames | 0.75 default, six measured 0.59–0.92 | 0.44–0.85 (table below) | Wrong |
| Wall left at each corner | 1.53 (west), 1.96 (east) | 0.47–0.64 | Wrong |
| Frame outer sizes | — | within 5 % of built for the ten checked | Matches |
| Arch door clear opening | 1.9 × 3.1 | about 1.8 × 3.2 | Matches |
| Floor plank | 1.9 × 0.36 herringbone | about 0.76 × 0.12 (± 20 %) | Wrong; owner chose the built size in #186 |
| Floor border | two 0.36 boards along the long walls only | about 0.9 m on all four sides: a strip, a band of short boards laid like piano keys, a strip | Wrong |
| Cornice top | 6.0 | about 6.4 | Cannot tell (weak) |
| Vault rise | 3.0 | 4.3–5 (near a half circle) | Cannot tell (weak) |
| Skylight width | 4.2 | about 4.45 | Matches |

Anchors: sixteen catalogue canvas widths, four mosaics. Scale agreed within each mosaic to 2–4 %.

Frame outer edges, metres from the arch-end corner (measured):

- West: W1 0.64–1.99, W2 2.52–4.05, W3 4.55–5.56, W4 6.31–7.47, W5 8.20–9.66, W6 10.29–12.30, W7 12.91–15.01, W8 15.44–16.72, W9 17.21–19.04, W10 19.49–21.32, far corner 21.79.
- East: E9 0.61–2.40, E8 2.94–4.38, E7 4.89–6.67, E6 7.16–8.80, E5 9.35–11.68, E4 12.34–14.18, E3 14.86–16.13, E2 16.98–18.24, E1 19.09–21.33, far corner 21.91.

Cross-checks:

- A different method (size of the far-wall portrait N2, 60.039, from the arch doorway at 22.5–24 s, focal length 893 px) gives 20.9 ± 0.7 m.
- The official floor-5 plan draws the Hall 2.04 times as long as wide; measured is 2.18; built is 2.63.
- Earlier: `main-worker-bertin-20261001T0555` already noted that canvas totals imply about 20 m and called 26.3 "provisional". It was never acted on.

The built length comes from `walk4.gd` `_build_paintings`: frame widths plus a 0.75 m default gap, with the remainder split between the corners.

### Dark medieval room — wrong

Source: IMG_6382, whole clip. Anchors: St Anthony 16.243 (232.4 × 92.1 cm), Bartolo Madonna 20.207, the portal 40.014 (4.229 × 3.861 m), and the Hall's width seen through the portal. Scale 0.80–0.81 m per unit, ± 3 %.

| | Built | Measured | Verdict |
| --- | --- | --- | --- |
| Width (east–west) | 10.0 | 10.3 ± 0.3 | Matches |
| Depth (north–south) | 6.1 | **5.6 ± 0.2** | Wrong |
| Ceiling | 4.25 | about 4.3 | Matches |
| Stair door centre, from north wall | 3.665 (z 31.765) | **2.60** (z 30.70) | Wrong |
| Stair door clear size | 1.7 × 2.74 | about 1.8 × 2.15 | Height wrong |
| Tracery door centre, from north wall | 3.665 (z 31.765) | **3.04** (z 31.15) | Wrong |
| Tracery opening width | 1.13 | 1.34 (catalogue arch 1.41) | Wrong |
| Apostles, from north wall | 2.365 and 5.115 | 0.90 and 4.35 | Wrong |
| Floor | herringbone | herringbone | Matches |
| Walls | dark blue-grey | dark blue-grey | Matches |

- The Renaissance model puts the tracery door 3.1 m from its north wall; the medieval model puts it 3.04 m. The landing model puts the stair door 2.47 m from the lion wall; the medieval model 2.60 m. So the three rooms' north walls do share one line, as built, to about 0.15 m.
- Earlier (`opus-remaining-architecture-review`, D2) said the two doors are "on one straight line" and moved the stair door 1.715 m south to make them so. Measured, the stair door sits 0.44 m north of the tracery door. You can see through both, which is what the frames show. The door's old position (z 30.05) was closer than the current one.

### Light Renaissance room — matches

Source: IMG_6383, whole clip. Anchor: The Woodcutters 29.280 (94 × 152.4 cm).

- Measured 6.3 × 6.1 m; built 6.1 × 6.1. Matches.
- North door clear about 1.83 m, centred; built 2.0, centred. Matches.
- Ceiling about 3.8 m; built 3.5. Probably 0.3 m low; heights are the weak axis.
- Board direction: not checked.

### European gallery ("adjacent gallery") — wrong length, object positions wrong

Source: IMG_6384 and 6386. Anchor: Crucifixion 69.197 (113 × 143.8 cm), scale 1.48 m per unit.

| | Built | Measured | Verdict |
| --- | --- | --- | --- |
| Width | 6.1 | 5.7 ± 0.2 | Slightly wide |
| Length | 26.3 | at least 17.4 m plus the camera's stand-off; the north wall is not in the model | Inferred 21.9, same as the Hall (official plan) |
| Ceiling | none built (open top); wall 3.5 | about 3.6 | Height matches; ceiling missing |
| Goltzius 61.006, from south wall | 13.4 | **5.85–6.32** | Wrong |
| Fetti 36.003, from south wall | 19.3 | **10.5–11.5** | Wrong |
| Floor | straight boards along the length | straight boards along the length | Matches |

East-wall order and positions from the south-east corner are in `notes.md`; none of those works is built yet.

### Lion stair landing — wrong

Source: IMG_6387 0–50 s. Anchor: the lion relief (2.286 m).

| | Built | Measured | Verdict |
| --- | --- | --- | --- |
| Lion (north) wall length | 5.6 | 5.97 | Wrong |
| Ceiling | 4.1 | 3.87 | Slightly high |
| Modern door | clear 1.7, 0.45 m from the west corner | clear about 1.6, about 0.2 m from the corner | Wrong |
| Door heads (modern, sculpture, medieval) | 2.74 | 2.15–2.3 | Wrong |
| Lion slab along the wall | 2.91–5.19 | 2.92–5.18 | Matches |
| Lion slab bottom | 1.18 | 1.28 | Slightly low |
| Vent above the lion | 1.65 wide, centred on the lion | 0.91 × 0.18, centred 3.12 m from the west corner, 3.1 m up | Wrong |
| Grey text panel between door and lion | not built | 0.40 × 0.70 at 2.24–2.64 m | Missing |
| Sculpture-gallery door | 2.0 wide, centre 2.4 m from the lion wall | about 1.6 wide, centre 2.5 m | Width wrong |
| Floor | wood, 1 m alternating squares | large two-tone stone tiles laid herringbone | Wrong |
| Wall colour | one plaster on all walls | west and east walls grey; lion wall and stair shaft white | Wrong |
| Stair void starts | 5.615 m south of the lion wall | 4.1 m | Wrong; see section 3 |

### Modern painting gallery — depth wrong

Source: IMG_6387 45–84 s, landing model (scale from the lion only; medium confidence).

- North–south: built 5.8, measured about 7.3. East–west: built 6.0, measured 5.5–6.0.
- The wall between the landing and this room is about 0.94 m thick (the open door leaf lies in it). Built with no thickness.
- Two windows on the east wall, case between: matches earlier `opus-modern-layout-review`.
- Board direction, window sizes: not checked.

### Rockefeller — matches

Source: IMG_6380 122–239 s. Bookcase wall 6.65 m (built 6.4); depth about 6.1 (built 6.8, rough). Mirrors 1.4–1.5 m either side of the bookcase (built 1.6, 1.7). Boards run toward the bookcase wall, as built.

### Not measured in this audit

Grey French gallery, purple connector, the two reveal thresholds, and the four "study limit" stubs. Earlier `opus-grey-register-fit` measured the grey west wall (6.0 m) and its corner door; that is already in `geometry.json`. Seen but not measured: the grey gallery floor is herringbone (IMG_6343 0.5 s), as built.

## 2. Topology

The official plan (`risd-floor5-map-2020.png`, from risdmuseum.org/visitor-guide/floor-5, schematic, no scale) and the footage agree with `geometry.json` on which rooms touch. What differs is size.

```
 north                                                       (x east →, z south ↓)
 ┌──────────┬────┬─────────────────┬──────┐
 │Rockefeller│purp│ grey French     │Ionic │   these six move 4.4 m south
 │          │    │                 │stair │   with the Hall's far wall
 ├───┤ ├────┴────┴──┤ ├────────────┴──────┘
 │          ║             ║
 │ European ║  Main Hall  ║──────────┐
 │ gallery  ║  10 × 21.9  ║ (adjoin) │
 │ 5.7×21.9 ║  (built     ║──┤ ├─────┤
 │ (built   ║   26.3)     ║ modern   │  5.5–6 × 7.3 (built 6 × 5.8)
 │ 6.1×26.3)║             ║ gallery  │
 │          ║             ║▓▓┤ ├▓▓▓▓▓│  wall 0.94 thick (built 0)
 ├───┤ ├────╫────┤ ├──────╫──────────┤
 │Renaissance  medieval   ┤ lion     ├ white sculpture
 │ 6.3×6.1  ┤ 10.3 × 5.6  │ landing  │
 │          │ (built 6.1) │──────────│  void starts 4.1 m from lion wall
 └──────────┴─────────────│ up│well│dn│  stair shaft, full width
                          └──────────┘
```

| Doorway | Sides line up in the build? | Against footage |
| --- | --- | --- |
| Hall ↔ medieval (portal) | Yes | Position along the wall not settled (section 6) |
| Hall ↔ grey (reveal) | Yes | Both move 4.4 m south with the Hall's far wall |
| European ↔ Rockefeller (reveal) | Yes | Same |
| European ↔ Renaissance | Yes | Matches |
| Renaissance ↔ medieval (tracery) | Yes | Both 0.6 m too far south, 0.2 m too narrow |
| Medieval ↔ landing (stair door) | Yes | Both 1.07 m too far south, head 0.6 m too high |
| Landing ↔ modern | Yes | 0.25 m too far east; no wall thickness |
| Landing ↔ white sculpture | Yes | 0.4 m too wide |
| Rockefeller ↔ connector ↔ grey | Yes | Not measured here |

## 3. The stairwell

Source: IMG_6387 13.75–31.25 s. Plan from the landing model (`frames/top-landing.png`).

| | Built (`build_lion_modern_rooms`, lines 1292–1318) | Footage |
| --- | --- | --- |
| Type | Two straight flights side by side | Open-well stair around a rectangular well with rounded corners |
| Footprint | x 10.55–13.55 only (3 m); a 2.6 m floor strip continues south on the east side | The whole landing width, about 6.1 m; no floor strip |
| Void starts | 5.615 m south of the lion wall | 4.1 m |
| Up flight | x 10.70–11.80, 1.1 m wide, 18 treads straight south | Along the west wall, about 1.85 m wide. Nine treads visible to the south-west corner, turns left on a curve, continues east along the south wall toward level 6 |
| Down flight | x 12.20–13.30, beside the up flight | Along the east wall, about 1.85 m wide, south to the south-east corner, turns west. A half-landing with a window lower down |
| Well | none | About 2.3 m wide between the flights; you see two floors down (stacked chairs at the bottom) |
| Balustrade | Square posts with collars, straight wood rail | Wood handrail on iron balusters with scroll panels; volute newels; wall handrails on both outer walls |
| Treads | Wood | Grey marble with a black strip at the nosing; closed grey stringer |
| Above | Nothing | Tall white shaft with a large glazed skylight |
| Below | Nothing; rays into the void hit no mesh | Cream walls, sconces, lower flights |
| On the landing | — | Sign "5" and a directory between the medieval door and the first step; alarm, pull station and donor text by the down flight |

**Specification for the rebuild** (z measured from the lion wall at 28.1):

1. Shaft: full landing width, z 32.2 to about 36.9 (4.7 m deep). Delete the `landing east floor` patch and narrow nothing: `floor_void` becomes the full width.
2. Up flight against the west wall, 1.85 m wide, first riser at z 32.2, ten risers south, a curved quarter-turn in the south-west corner, then a second run east along the south wall.
3. Down flight against the east wall, 1.85 m wide, first riser at z 32.2, south to a quarter-turn in the south-east corner, then west and down to a half-landing.
4. Well 2.3 m wide between them, open, with a guard along its north edge at z 32.2.
5. White shaft walls rising past the landing ceiling to a skylight; walls below the landing so the void is not background colour.
6. Marble treads with black nosing strips, grey stringers, iron-and-wood balustrade.

Inferred, not measured: riser height, the count on the second runs, and where the flights arrive.

## 4. Root causes

- **(a) and (c), camera cut-away.** The coordinator reports these are already fixed; I did not re-check. For the record, at the time of my run the cause was in `main_build_walk.gd` `_update_camera`: the dollhouse camera for a visitor beside the Hall sits inside the Hall, and the parent hides the Hall's far-side wall layer rather than the near one; the follow camera in an added room was placed 3.1 m behind the visitor with no clamp and the Hall layers were switched on.
- **(b) black slabs, medieval floor.** Verified. The pixels are pure black and the surface hit is `BakedRoom/ContinuousFloor` inside the low case's footprint. The floor lightmap is baked with the furniture present, so the floor under it is unlit. `_update_camera` then hides any body between camera and visitor, and the low case base is in that list. Fix: in `_attach_rooms`, keep floor-standing furniture (bodies without `room_wall` whose box starts below 1.2 m) out of `_walls`; or bake the floor with furniture not casting onto it. The atlas also stands the visitor inside the case (`museum_atlas.gd` uses the room centre), which is why every medieval shot shows it.
- **(d) stair draft and void.** Verified: nothing exists below the floor except the 85 stair parts; no well walls, no lower landing, no ceiling over the landing. `build_rooms` gives ceilings to three rooms only. Fix: section 3.
- **(e) floor patterns.** Per room, `build_rooms`: herringbone in the Hall, grey gallery and medieval room matches the footage. Straight boards in the European gallery, Rockefeller and connector match. The landing's wood squares are wrong (stone tile). The Hall's plank is 2.5–3 times too large and its border is missing on the end walls, which is why the floor changes character at each Hall door.
- **Other, seen in the atlas.** Rooms other than Renaissance, medieval and modern have no ceiling, so the follow camera shows background above the walls. Shared walls have no thickness and single-sided faces, so the dollhouse view shows background through outer walls and at the stub rooms. The modern room's west wall is 0.15 m off the Hall's east wall, leaving a sliver.

## 5. Corrections, in order

| # | Change | Old → new | Where | Confidence | Re-bake |
| --- | --- | --- | --- | --- | --- |
| 1 | Hall length | 26.3 → 21.9 | `walk4.gd` `L`; `geometry.json` Grand Gallery `bounds` z; `loop_fit.hall_length_m` | High | Hall and rooms |
| 2 | Hall gaps | W1–W10: 0.53, 0.50, 0.75, 0.73, 0.63, 0.61, 0.44, 0.49, 0.45. E1–E9: 0.85, 0.85, 0.69, 0.67, 0.55, 0.50, 0.52, 0.54 | `gallery_walk4/gaps.json` | Medium-high; differs from the six existing entries by 0.1–0.3 | Hall |
| 3 | Far rooms follow the Hall | Rockefeller, connector, grey, Ionic, piano, both reveals: z + 4.4 | `geometry.json` `bounds`, `openings`, trials, loop waypoints; `remodel_room.gd` `shift_new` offsets; `remodel_bake.gd` `corrected()` | High (follows 1) | Rooms |
| 4 | European gallery | length 26.3 → 21.9; width 6.1 → 5.7; Goltzius z 14.7 → 22.0; Fetti z 8.8 → 17.1 | `geometry.json` `adjacent gallery`; `build_adjacent_gallery` | Length inferred; width and positions medium | Rooms |
| 5 | Medieval depth | z1 34.2 → 33.7 | `geometry.json` `dark medieval room` | Medium-high | Rooms |
| 6 | Stair door | `[30.915, 32.615]` → `[29.80, 31.60]` on both rooms; apostles to z 29.0 and 32.45 | `openings.east` / `.west`; `build_medieval_stair_door`; `build_sculpture_rooms` | Medium-high | Rooms |
| 7 | Tracery door | `[31.2, 32.33]` → `[30.48, 31.82]` on both rooms | `openings.west` / `.east`; `stone_asset("tracery-arch", …)` | Medium-high | Rooms |
| 8 | Door heads | 2.74 → 2.2 for the stair door, modern door and sculpture door | `clear_heights` per room; leaf height in `build_lion_modern_rooms`, `build_medieval_stair_door` | Medium | Rooms |
| 9 | Stairwell | rebuild to section 3; `floor_void` full width from z 32.2; drop `landing east floor` | `geometry.json` `lion stair landing`; `build_lion_modern_rooms` | High on layout, low on step counts | Rooms |
| 10 | Landing | lion wall 5.6 → 6.0; height 4.1 → 3.9; modern door `[11.0, 12.7]` → `[10.75, 12.35]`; stone tile floor; grey west and east walls; text panel; vent 0.91 × 0.18 | same room; `build_rooms` floor branch | Medium-high | Rooms |
| 11 | Modern gallery | depth 5.8 → 7.3 behind a 0.94 m wall: z `[22.3, 28.1]` → about `[19.9, 27.2]` | `geometry.json` `modern painting gallery`, its stub, and every placement in `build_lion_modern_rooms` | Medium | Rooms |
| 12 | Black slabs | exclude floor furniture from the cut-away list | `main_build_walk.gd` `_attach_rooms` | High | No |
| 13 | Ceilings | add to European gallery, Rockefeller, grey, connector, landing | `build_rooms` line 291 | High | Rooms |
| 14 | Hall floor | plank 1.9 × 0.36 → about 0.76 × 0.12; border on four sides | `walk4.gd` `PLANK`, `_build_floor` | Medium; owner's choice in #186 | Hall |
| 15 | Renaissance ceiling | 3.5 → 3.8 | `geometry.json` (no `height` key today) | Low | Rooms |

Items 1–3 change `walk4.gd` and the Hall's saved bake. Under the repository rules that is a seam change and needs its own Issue.

## 6. Not determined, or not reached

Not reached before the stop:

- Grey gallery east–west extent, column spacing, connector length, and the four stub rooms.
- Whether fixes for (a) and (c) work; not re-run.
- Board direction in the Renaissance and modern rooms; window sizes; lighting-track layouts in any room.
- Wall colours beyond what is noted; no colour was sampled.
- A render of any proposed change. Nothing here has been seen in the game.

Cannot be determined from this footage:

- Where the portal sits across the Hall's end wall. The Hall-side mosaic puts its centre 4.7 m from the west wall; the medieval model, read through the portal, puts it about 5.2 m. The Hall's side walls bend by up to 3° in that model, so neither is settled.
- The depth of the passage between the medieval room and the Hall (built 1.65 m).
- The European gallery's north end, so its length is inferred from the plan.
- Stair riser height, total rise, and where either flight arrives.
- The Hall's cornice height and vault rise to better than half a metre.
- The interiors of the white sculpture gallery, the room beyond the modern gallery, and anything behind the Ionic columns.
