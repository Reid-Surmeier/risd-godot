# Collection: remaining architecture and source coverage

Independent review for Issues #178 / #181 / #182 / #183, 2026-10-01. Review only: no code, bake, asset, interface, error type or acceptance test was touched, nothing was written to the root workspace or the ingestion folder, and Godot was not run. No paid call, no GPU, no nested worker.

## Verdict

1. **The lion landing is built a quarter-turn out.** The modern door and the lion are on the wall that meets the medieval-door wall at a corner, not on the wall opposite it. The sculpture-gallery door is on the wall after that. Detail and root's proposed refit: [`LANDING.md`](LANDING.md).
2. **The medieval room's two side doors are on one axis in the video and 1.715 m apart as authored.**
3. **The purple connector enters the grey gallery at its corner, not mid-wall.** As authored it is 3.0 m from the corner, which puts the whole Rockefeller and European gallery group 3.0 m out of register with the Hall.
4. The medieval, Renaissance, grey and Rockefeller rooms otherwise have every door and every object I checked on the correct wall and in the correct order. The root's inventories agree with the video on wall assignment, with one exception (D5).
5. All ten videos are accounted for. Eight are in the built loop or its stubs; the auditorium (6378) and the upper marble-stair level (6381) connect to nothing else that was filmed.

No room size in this report comes from the video. Where a metre appears it is an authored value read from `geometry.json`, a catalogue size, or root's own proposal.

![authored plan with the five defects](rooms-plan.png)

## Corrections, in the order to do them

Authored values are from the built `geometry.json` (sha256 `7e0c504d…40b6b`, identical in v48b and v50b) and the root's `remodel_room.gd` and `prepare_remodel.py`. `check_claims.py` re-derives every authored number below.

| | Authored | Source shows | Evidence | Sure? |
| --- | --- | --- | --- | --- |
| **D1** | `rooms[5]` lion landing: `openings.east [29.2, 30.9]` is the modern door, facing the medieval door; lion on the east wall at z 33.15; sculpture door `openings.south [13.9, 15.9]`. Modern room east of the landing. | Modern door, text panel, lion on the **north** wall, door next to the corner shared with the medieval-door wall. Sculpture door on the **east** wall. Stairwell on the south side. Modern room north of the landing, backing onto the Hall's east wall. | `IMG_6387` 9.0, 9.5, 10.0, 42.5, 43.0, 43.5 s (corner); 3.0, 41.0 s (lion, corner, sculpture wall); 45.5–47.5 s (walk-in); 83.0 s (stair seen straight across from the modern door). | Yes. Two pans in opposite directions and an unbroken walk-in. |
| **D2** | `rooms[3]` medieval: tracery doorway `openings.west [31.2, 32.33]`, stair door `openings.east [29.2, 30.9]`. Centres 31.765 and 30.05. Tall case at z 30.9. | Stair door, tall case and tracery doorway on one straight line. | `IMG_6387` 13.0, 44.0 s; `IMG_6383` 66.5 s. | Yes. |
| **D3** | `rooms[7]` grey: connector doorway `openings.west [-2.8, -1.2]` in a wall from -5.8 to 1.8, so 3.0 m of wall either side. | Doorway casing starts at the south-west corner, beside the Grand Gallery doorway. Two paintings (barn, then the Courbet forest) fill the wall between it and the piano-stair corner. The connector is straight and both its openings are on one axis. | `IMG_6380` 38.0, 101.0, 248.0 s; `IMG_6379` 171.5 s; `IMG_6381` 90.0 s; connector axis `IMG_6380` 103.0, 246.0 s. | Yes on the corner (four viewpoints). The size of the shift is authored arithmetic, not a measurement. |
| **D4** | Medieval east wall: 1.1 m of wall north of the stair door, 3.3 m south; apostle 41.045 bracket 2.7 m from the south-east corner. | The wall reads corner, apostle, door, apostle, corner. Each apostle is about one of its own backplates from its corner. | `IMG_6382` 14.0, 24.0, 26.0, 78.0 s. | Order: yes. That the room is shallower than 6.1 m: likely, not established. |
| **D5** | `european-gallery-inventory.json` `display_groups`: `far-tabernacle` "east of doorway", `far-bronze-christ` "west of doorway"; Previtali 16.237 "exact wall assignment pending". | Facing the far end wall: Previtali, bronze figure case, doorway, tabernacle, then the corner and the west wall with the bronze relief case. So the bronze case and the Previtali are east of the doorway and the tabernacle is west. | `IMG_6384` 12.0, 14.0, 16.0, 18.0 s. | Yes. Text only; neither object is built yet. |

![source frames for D2 to D5](evidence-sheet.jpg)

### What each fix touches

- **D1.** `prepare_remodel.py`, the block under the `#6387 reciprocal wides` comment (`rooms[5]` openings, the three rooms appended after it) and the `landing_to_modern` / `modern_to_landing` / `landing_white_*` trials; `remodel_room.gd` `build_lion_modern_rooms` (lion slab at `Vector3(16.092, 1.7005, 33.15)`, door specs `Vector3(16.15, 0, 30.05)` and `Vector3(14.9, 0, 35.9)`, the two cornice runs). Root's proposal already has the right sequence and is not mirrored. Three flags on it are in `LANDING.md`: the lion must not touch the north-east corner, the sculpture door's position is unmeasured, and the modern room now backs onto the Hall wall that the live Hall hides for its dollhouse view.
- **D2.** Move the stair door, not the tracery doorway. Moving the tracery north to 30.05 would leave 1.385 m of wall for the Bartolo Madonna (0.635 m) and the Virgin Annunciate (0.419 m) with their mounts and labels, and the video shows more wall north of that door than south of it. So: `rooms[3].openings.east` and `rooms[5].openings.west` to `[30.915, 32.615]`; `build_medieval_stair_door` leaf edges, the two apostle brackets, the tall case and the `stairs_door_*` trials move with it. The landing's stair void starts at z 32.0 as authored and would then overlap the door; the video has the "5" sign and the down rail directly beside the door, so the void has to start after it.
- **D3.** This is a change of register between two groups, not a local edit. With the connector straight, moving its grey-side doorway to the corner moves the Rockefeller east door, and with it Rockefeller and the north end of the European gallery, 3.0 m toward the Hall end. Using only authored numbers the European gallery goes from 28.5 m to about 25.5 m, taking 3 m out of the 9.25 m stretch that `loop_fit` already marks unaccepted. Measure before applying (see below).
- **D4.** D2 fixes the south side by itself (apostle 0.985 m from the corner). The north side stays long (2.365 m from apostle to corner against about one backplate in the video). Do not close that by eye.
- **D5.** Swap the two location strings and set the Previtali to the far end wall, east of the bronze case.

## Wall order seen in the video

For placing what is still missing. Orders are read in the direction given; seconds are for the clip named in the row.

| Room and wall | Order | Clip, seconds |
| --- | --- | --- |
| Medieval north, west to east | small gabled Magdalene 21.250, predella 22.047, floor vent, projecting pier with black screen, portal, wall text, iron grille on white plinth, low vent | 6382: 72–76, 0–13, 85–89 |
| Medieval east, north to south | apostle on bracket, stair door (two leaves open into the landing, EXIT), thermostat, apostle on bracket | 6382: 14–27 |
| Medieval south, east to west | Head of Christ on octagonal pedestal, Virgin and Child relief on pedestal, Crucified Christ, bust-length figure on pedestal, large gabled enthroned saint on a raised lighter backing | 6382: 29–58, 79–82 |
| Medieval west, south to north | painted standing figure on octagonal pedestal, tracery doorway, Bartolo Madonna 20.207, Virgin Annunciate 57.301 | 6382: 59–71, 82–85 |
| Medieval floor | low table case with manuscript leaves; tall case with seated Virgin and Child and metalwork, on the door axis | 6382: 77–79, 90–112 |
| Renaissance north, west to east | triptych wall case, doorway to the European gallery (two leaves into this room, sign and vent above), wall text, Perugino 16.236 | 6383: 27–39, 62–65, 72–73 |
| Renaissance east, north to south | portraits and book wall case, tracery doorway (pointed plaster reveal on this side, EXIT above), maiolica wall case | 6383: 0–4, 40–58, 65–67 |
| Renaissance south, east to west | burgundy textile in white mount, hunting tapestry, long raised white plinth below both | 6383: 5–12, 60, 69 |
| Renaissance west, south to north | Holy Family painting, shuttered window, bronze figure in a tall case on a plinth in front of it, Pietà wall case | 6383: 14–25, 60–62, 70 |
| Grey west, south to north | connector doorway at the corner, barn and coach painting, Courbet 43.571 | 6380: 0–9, 38–39 |
| Grey north, west to east | piano-stair door (leaf open, EXIT), wall text, row of small landscapes, to the columns | 6380: 14–31 |
| Grey east | Ionic opening the full width, two free columns; marble bust on a plinth in front of it, on the connector axis | 6380: 17–18, 34–35, 246–249 |
| Grey south, east to west | low vent, landscapes including the waterfall and the Colosseum, Grand Gallery doorway with its leaf, one small painting, corner | 6380: 36–38, 90–101, 106 |
| Rockefeller | matches the authored room: European doorway between two sconces on the south wall with the pink service case east of it; textile, portrait over settee and bust on the west wall; mirrors and cabinet on the north wall; wallpaper panel and gold service case by the east door | 6380: 122–239 |
| Landing | see `LANDING.md` | 6387 |

Seen and not built, medieval: Head of Christ, relief, Crucified Christ, bust figure, gabled enthroned saint, standing figure, both cases' contents. Renaissance: everything except the Perugino, bench, window, plinth and vent. Grey: the bust, the barn painting, most of the small landscapes. The root files already mark these rooms incomplete.

## Not established

- Every room's size. The medieval depth (6.1 m), the grey gallery's two extents, the connector's length (2.15 m) and the European gallery's length are all authored guesses, and D3 and D4 say at least two of them are off.
- Where along its walls the shared medieval door axis sits. D2 only makes the two doors agree.
- Whether the Renaissance north wall lines up with the medieval north wall. `prepare_remodel.py` asserts it; no frame shows it.
- Where the European doorway sits in the Renaissance north wall. From inside it looks west of centre; from the European gallery it looks centred. The two rooms need not be the same width.
- The sculpture door's position on the landing's east wall, and the stair geometry. The white sculpture gallery's interior is seen only through its door.
- The crucifix's offset along the medieval south wall. It is on the Hall's door axis in the earlier Hall footage (`IMG_6344` 177.5 s, from my first review).
- Any link between the auditorium and the museum, between the lion landing and the piano stair, or from the upper marble-stair level to anything else.

The route to the metric ones is the method root already used in `medieval-panel-source-fit.json`: a planar fit anchored on a catalogue-sized object in the same wall plane. Anchors exist for each: the apostles (0.267 x 0.826 m, 0.254 x 0.864 m) for the medieval east wall, the Courbet canvas (0.733 x 0.597 m) for the grey west wall, the lion (2.286 m) for the landing's north wall.

## Coverage of the ten videos

Hashes are from the ingestion `verified-manifest.json` and match `reconstruction-coverage.json`. The three root inventories account for all 2,485 survey frames (373 + 497 + 1,615). I looked at 875 of them, sampled; the per-video list, sheet hashes and frame hashes are in [`ledger.json`](ledger.json).

| Video | sha256 | Frames | I looked at | What it shows | Root file | Agrees? |
| --- | --- | --- | --- | --- | --- | --- |
| 6378 | `a79c9a65e822` | 360 | 45 | Metcalf Auditorium | hall-stairs | Yes. No link to any other room. |
| 6379 | `abc4922925e5` | 365 | 90 | Piano stair, level 4 up to the grey gallery door | hall-stairs | Yes. Adds a view for D3. |
| 6380 | `eaf7a7853b6c` | 521 | 261 | Grey gallery, marble stair hall, connector, Rockefeller | hall-stairs, video-inventory, grey source fit | Wall order yes; geometry no (D3). |
| 6381 | `12df06479e7d` | 198 | 50 | Marble stair to the upper landing and back | hall-stairs | Yes. Adds a view for D3. |
| 6382 | `415467db2d22` | 226 | 113 | Medieval room | sculpture-room, medieval panel and Magdalene fits | Wall order yes; geometry no (D2, D4). |
| 6383 | `8cfd089e7690` | 147 | 76 | Renaissance room | sculpture-room, Perugino fit | Yes. |
| 6384 | `0a2255c4fbcb` | 209 | 55 | European gallery from the far end | european-gallery | Yes except D5. |
| 6385 | `a15a2e90b2ae` | 75 | 38 | European gallery from the Rockefeller door | european-gallery, video-inventory | Yes. |
| 6386 | `3112391373f0` | 213 | 54 | European gallery, far doorway, walk into the Renaissance room | european-gallery, Goltzius fit | Yes. |
| 6387 | `75c4892c1a37` | 171 | 93 | Lion landing, stairwell, modern gallery | hall-stairs, modern frames fit | **No (D1).** |

Two notes on the root files. The `scope` line of `video-inventory.json` still says "the current built study covers Rockefeller and its adjoining long gallery", which is several builds stale. Five videos (6378, 6379, 6381, 6384, 6385) have no source-fit file at all; for 6378 and 6381 that is correct, since nothing from them is built.

## Next action

**Apply D1 as root proposed it, with the lion moved clear of the north-east corner, before the modern room is baked.** It is the only defect that changes which rooms touch, it decides where the modern worker's finished interior attaches, and root's numbers for it already pass the sequence and handedness check. D2 edits the same landing opening and is the natural second step.

## Files and how to check

```bash
python3 docs/evidence/collection-reconstruction/opus-remaining-architecture-review-20261001/check_claims.py
```

- `LANDING.md`, `landing-plan.png`, `landing-pan-A-0.5-11s.jpg`, `landing-pan-B-41-47.5s.jpg`: D1.
- `rooms-plan.png`, `evidence-sheet.jpg`: D1–D5 on the authored plan, and the frames for D2–D5.
- `ledger.json`, `check-claims.json`, `SHA256.json`, `*-frames-sha256.json`: hashes and counts.
- `sheets/` (32 contact sheets, all ten videos), `frames/` (enlargements).
- `contact.py`, `trio.py`, `landing.py`, `landing_plan.py`, `evidence.py`, `ledger.py`: how each image and file was made.

Limits. The frames are the 1280x720 two-per-second survey, not native video, from an ultrawide lens. The coloured markers were placed by eye to point at a feature. `scripts/check.sh` was not run: it imports the Godot project and writes outside this folder, and this change adds no code. `git diff --check` is clean.
