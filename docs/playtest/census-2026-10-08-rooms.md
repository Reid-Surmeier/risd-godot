# Room census, 8 Oct 2026: what is wrong with each room, against the footage

Ticket [#257](https://github.com/Reid-Surmeier/risd-godot/issues/257), map [#249](https://github.com/Reid-Surmeier/risd-godot/issues/249). Rooms only: shell, openings, fixed architecture, display furniture, lighting, rendering faults. The individual objects are in the other census.

Read-only. No game file changed, no export, no Godot run, no paid call.

## Answer first

1. **Every one of the 16 areas has at least one finding the owner would call broken.** 40 BLOCKS, 55 POLISH, 19 MINOR.
2. **The build has three lighting treatments, not one.** The Main Hall is dark with a pale blob above each frame (mean picture brightness 0.23). Six rooms and the five stubs are flat and unlit (0.31–0.50). Four rooms have stray pools (0.31–0.61). In the footage the Main Hall is bright and even under its laylight, and every other room is lit from ceiling tracks, with a soft pool on each work. No filmed room is dark like the build's Hall and none is unlit.
3. **16 of 22 doorway sides are a bare hole or a flat thin frame.** The footage shows the same doorway everywhere: a white moulded casing with a panelled reveal.
4. **At least 34 pieces of display furniture are plain cuboids**: case bases, plinths, platforms, benches, the piano.
5. **Three rooms have no ceiling** (European gallery, Rockefeller, grey French gallery). In five more, and in the stubs, the views cannot show whether there is one.
6. **Room sizes are still the typed-in ones.** `geometry.json` holds the same numbers the 1 Oct architecture audit called wrong: the Main Hall is 26.3 m long against a measured 21.9.
7. **First room to rebuild as the finished standard: the Light Renaissance room.** Runner-up: the dark medieval room. Reasons in "Two answers".
8. **The missing room is two rooms: the Impressionist galleries between the marble stair hall and the modern gallery** (`IMG_6343.MOV`, 91–223 s). The build has a closed dummy door at one end of them and a 1.3 × 1.6 m stub at the other. Also unbuilt: the Metcalf Auditorium (`IMG_6378.MOV`), which no filmed route reaches. The white sculpture gallery is a stub. The Skylight Gallery is built, but as the wrong room.

## Summary table

"Lit" asks whether any light falls on the works. "Doorways plain" counts each doorway side seen from that room that is a bare hole or a flat frame with no moulding. "Boxes" counts plinths, case bases, glass cases, platforms and benches that are one plain cuboid, as far as the five views per standpoint show them.

| # | Area | BLOCKS | POLISH | MINOR | Lit | Doorways plain | Boxes | Mean brightness |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Main Hall (Grand Gallery) | 4 | 5 | 2 | yes, wrongly: dark room, blobs above the frames | 0 of 2 | 0 | 0.23 |
| 2 | Dark medieval room | 2 | 7 | 2 | no | 2 of 3 | 6 | 0.32 |
| 3 | Light Renaissance room | 3 | 6 | 2 | no | 2 of 2 | 7 | 0.33 |
| 4 | European gallery ("adjacent gallery") | 3 | 5 | 1 | no (one stray glow) | 1 of 2 | 11 | 0.50 |
| 5 | Rockefeller | 2 | 4 | 1 | partly (north and west walls) | 2 of 2 | 4 | 0.53 |
| 6 | Purple elevator-5 connector | 2 | 3 | 1 | no | 2 of 2 | 0 | 0.40 |
| 7 | Grey French gallery | 3 | 4 | 2 | no | 3 of 3 | 1 | 0.47 |
| 8 | Marble stair hall | 5 | 3 | 1 | no | 0 of 0, plus 2 dummy openings | 0 | 0.34 |
| 9 | Skylight Gallery ("piano room") | 4 | 2 | 1 | partly (soft wash, top of walls) | 0 of 1 | 1 | 0.61 |
| 10 | Lion stair landing | 2 | 4 | 2 | partly (one pool, on the lion) | 3 of 3 | 0 | 0.31 |
| 11 | Modern painting gallery | 2 | 6 | 1 | partly (soft wash, two walls) | 1 of 2 | 4 | 0.44 |
| 12 | Stub: Main Hall reveal threshold | 1 | 2 | 1 | no | 0 of 2 | 0 | 0.31 |
| 13 | Stub: Rockefeller reveal threshold | 1 | 1 | 1 | no | 0 of 2 | 0 | 0.43 |
| 14 | Stub: Skylight Gallery reveal threshold | 2 | 1 | 0 | no | 0 of 2 | 0 | 0.49 |
| 15 | Stub: modern adjoining gallery | 2 | 1 | 0 | no | 0 of 1 | 0 | 0.31 |
| 16 | Stub: white sculpture gallery | 2 | 1 | 1 | no | 1 of 1 | 0 | 0.31 |
| | **All** | **40** | **55** | **19** | 1 yes, 4 partly, 11 no | **16 of 22** in the 11 rooms | **34** | 0.23–0.61 |

## How to read this

**Build looked at.** The playtest pictures of commit `88b7c207`: 110 views, 960 × 640, in `build/museum-playtest/` of the `wt-runtime` checkout, read as the 22 prepared contact sheets and six single pictures at full size. No room code changed between `88b7c207` and the branch tip `b9135a3d` (`git diff --stat` over `collection_rooms/` and `walk4.gd` is empty), so this describes the current build.

**Picture names.** `dark-medieval-room-0-e.png` is standpoint 0 of that room, dollhouse view facing east. `-follow` is the follow view. A dollhouse view facing east looks at the east wall from above and behind the visitor.

**Footage names.** `IMG_6382 000041 (20.0 s)` is frame 41 of the two-per-second survey of that clip: `~/risd-godot-ingestion/collection-expansion/survey-2fps/IMG_6382/000041.jpg`, 20.0 seconds into `verified/IMG_6382.MOV`. The survey frames are stored sideways; turn them a quarter clockwise. `IMG_6344 sfm 0050 (24.5 s)` is `~/risd-godot-ingestion/sfm-6344/images/0050.jpg`, already upright. `IMG_6343 84 s` is that second of `~/risd-godot-ingestion/walkthrough/IMG_6343.MOV`, taken from the clip itself; no survey of it exists.

**Severity.** BLOCKS: the owner would call it broken. POLISH: wrong against the footage, and visible. MINOR: a small fixture or a detail.

**Basis.** Every finding carries one of three words.

- VERIFIED: I put the game picture beside the named footage frame and saw the difference myself.
- EARLIER: measured or counted by the 1 Oct audits (`docs/research/2026-10-01-museum-architecture-audit.md`, `…-museum-inventory-audit.md`). I checked that `geometry.json` still holds the old number; I did not re-measure.
- INFERRED: my reasoning, not something seen.

**Sizes.** Sizes in centimetres read off footage are judged against the door they sit on, not measured. Room sizes "as built" are from `modules/shell/collection_rooms/geometry.json`.

**Brightness.** Mean of the grey value of every pixel, 0 to 1, averaged over the area's views. It is a comparison between rooms, not a calibrated reading.

**Colour and light.** The ten September clips (`IMG_6378`–`6387`) are HLG HDR, and their survey frames were grabbed without tone-mapping, so they look flat and washed. I use survey frames for shape only. Every statement about colour or light in those rooms was checked on a frame taken from the original clip at the same second and tone-mapped (`zscale=t=linear:npl=100,format=gbrpf32le,zscale=p=bt709,tonemap=hable:desat=0,zscale=t=bt709:m=bt709:r=tv,format=yuv420p`): Rockefeller 131 and 223.5 s; European gallery `6384` 66 s, `6386` 67.5 and 74.5 s; Renaissance 34 and 62.5 s; medieval 40, 65 and 77.5 s; landing 8.5, 10.5 and 27 s; modern 47 and 73.5 s; grey gallery 16.5 and 24.5 s; marble stair hall 5.5 and 97.5 s; Skylight Gallery 6.5 and 154.5 s; connector 102.5 s. `IMG_6343` and `IMG_6344` are ordinary SDR and need no tone-mapping. The phone's white balance still drifts, so a colour finding names two or more frames.

**Corrected after the first version.** The first version of this file judged wall and floor colour from the washed survey frames and called every oak floor "pale blond" and several walls "pale cool grey". Tone-mapped, the oak is a warm honey and the Renaissance room's walls are a mid grey that the build already matches. Those findings are reworded below; one moved from POLISH to MINOR. The first version also named the auditorium as the missing room without opening `IMG_6343`.

## The same seven faults, in most rooms

Each instance is listed again under its room and counted there.

1. **Three lighting treatments.** The Main Hall is dark with pale blobs on the wall. The added rooms are evenly bright with no pools, except for stray warm patches in Rockefeller, the European gallery, the modern gallery and on the lion. The Skylight Gallery is 2.7 times as bright as the Main Hall (0.61 against 0.23). In the footage the Main Hall is bright and even under daylight, and the other rooms are lit from ceiling tracks with a soft pool on each work (`IMG_6343 78 s`, `IMG_6380` 16.5 s tone-mapped).
2. **Trim is grey or beige; in the footage it is white everywhere.** Door casings, baseboards, cornices, platforms, plinths and case bodies are white in all ten clips. No room in the build has white trim except the Skylight Gallery's baseboard.
3. **Doorways.** The footage has two kinds. Gallery doors: a white casing about 15–20 cm wide with a moulded profile, a panelled reveal 0.5–0.9 m deep, and a panelled leaf folded flat into the reveal. Stair doors: the same casing with two white panelled fire doors, closers and push bars. Six doorway sides in the build are better than that: the Main Hall's north door, the stone portal from both sides, the European gallery's north door, the Skylight Gallery's entry and the modern gallery's north door. The other 16 sides are flat frames a few centimetres wide or bare holes.
4. **Ceilings.** Three rooms show the dark background above their wall tops in the follow view. Track rails and lamp heads hang against it.
5. **The camera's cut-away draws dark navy slabs.** Where a wall is cut away its top or outer face is drawn as a flat dark navy area. In the five stubs and the connector these fill 30–85% of the picture, and the neighbouring rooms show over the walls. This is the owner's "I just see the old room cut off … this black" and "I can sort of see into other rooms".
6. **Display furniture is plain cuboids in the wall's colour.** The footage's furniture is white, with a recessed base, a deck, a label, and clear acrylic hoods with polished edges.
7. **Exit signs.** Four are lettered "EXIT": the Main Hall's north door, both ends of the European gallery, the stair hall. At least five are blank green rectangles: grey gallery ×2, Rockefeller ×2, the Skylight threshold.

## The five worst

1. **The Skylight Gallery is the wrong room** (area 9, findings 1–4). A one-storey box entered at floor level, where the footage has a two-storey room entered from an upper landing, with a black stair down, an iron balustrade and two laylights.
2. **The Main Hall is dark, and no two rooms are lit alike** (area 1, findings 1–3; the brightness column). The owner asked for the Hall's original lighting back; the footage shows a bright, evenly lit room.
3. **Changing rooms shows slabs, voids and the inside of the visitor's head** (areas 6, 12–16). Two follow views are inside the visitor's hat. Three stub views are more than half flat navy.
4. **Both stair spaces are blocked out** (areas 8 and 10). Balustrades are plain black bars where the footage has scrolled ironwork; the marble floor is a hard checkerboard; a niche is a flat black arch; the doorway to the Impressionist galleries is drawn as closed lift doors; the lion stair's white, daylit shaft is dark grey.
5. **The European gallery has no ceiling, no light, and two piers that are not in the footage** (area 4, findings 1–3). It is the longest room after the Hall.

Close behind: the modern gallery's two south-wall works render as blurred smudges (area 11, finding 1).

## Two answers

### Which room to rebuild first as the finished standard

**The Light Renaissance room.** Fairly sure (about two in three).

- Its size already matches. The architecture audit measured 6.3 × 6.1 m against a built 6.1 × 6.1 and a centred north door; it is one of two rooms the audit calls a match. The rebuild can go to finish, with no seam to move.
- It holds one of everything the owner named: a cased door with leaves, a stone doorway (the tracery), wall cases, a floor case with a hood, sculpture (Saint Roch, the Pietà), paintings, textiles on a platform, a bench, a window, a ceiling with a track.
- Reference: the whole of `IMG_6383` (73 s, 148 survey frames) for a 6 × 6 m room, every wall, the ceiling and both doors. All 19 objects are identified.
- What it settles carries to five other rooms. Pale grey wall, white trim, straight oak boards and the white cased doorway are the vocabulary of the European gallery, Rockefeller, the modern gallery, the grey gallery and the connector.
- It is small enough to finish: 37 m².

**Runner-up: the dark medieval room.** It has the best single piece of architecture in the build (the stone portal), it is what the Main Hall's axis looks at, and its dark walls are the hard lighting case. Against it: the audit moves its depth and two of its three doors, which shifts seams with three neighbours, and the owner's own note on it is about misplaced objects. Do it second; it shares the tracery doorway with the Renaissance room.

### Which room in the footage is missing

**The two Impressionist galleries between the marble stair hall and the modern painting gallery.** Fairly sure (about four in five). I agree with the sources researcher's match.

- VERIFIED: `IMG_6343.MOV` walks from the grey gallery through the columns into the marble stair hall (`IMG_6343 84 s`, `87 s`), through the white cased doorway under the stair (`89.5 s`), into a gallery with Manet's *Le Repos* on the end wall, a bronze dancer in a case on a six-sided plinth, a shaded window and Impressionist landscapes (`93 s`, `105 s`, `145 s`), on into a second gallery (`185 s`, label "Paul Gauguin"; `210 s`), and out into the modern painting gallery by its far door (`228 s`).
- VERIFIED: the build has both ends and nothing between. At the stair hall end it is the closed flat double door (area 8, finding 4). At the modern gallery end it is the 1.3 × 1.6 m stub (area 15).
- VERIFIED: the owner's crit pictures 08 and 09 are both taken standing in front of that closed door.
- VERIFIED: the clip is on the Proton Drive, `/my-files/OBJ/IMG_6343.MOV` (265 MB, 25 Sep), and on this machine. Neither 1 Oct audit opened it; the inventory audit says so.
- INFERRED: "This room … also needs to be there. I have a video for it in the Proton Drive. The lighting in that room also is not lit yet" was said at that door, in the unlit stair hall.
- This also gives the marble stair hall, the grey gallery and the modern gallery a second set of reference frames, in ordinary SDR, which the audits never used.

**Also unbuilt: the Metcalf Auditorium.** `IMG_6378` (180 s) is a raked hall with maple-backed seats and a maple stage (`IMG_6378 000020 (9.5 s)`, `000100 (49.5 s)`). Nothing in `geometry.json` is this room, and no route to it was filmed. The first version of this file named it as the missing room; I had not opened `IMG_6343`, and I wrongly wrote that the Proton Drive held no museum clip the build had not used.

**Stub only: the white sculpture gallery** (area 16). The footage sees it through its open door, about 12 frames (`IMG_6387 000080 (39.5 s)`): enough to dress a view, not to build a room.

**Other Proton Drive video.** `/my-files/video refrence.` lists nine of the ten September clips, all ingested. `/my-files/RISD-VIDEOS` holds three screen recordings of 5 Oct; I opened the smallest and it shows the 3D Viewer Tab, not a museum room.

## 1. Main Hall (Grand Gallery)

As built: 10.0 × 26.3 m, cornice at 6.0 m. Views: `grand-gallery-0` to `-3`, 20 pictures. Footage: `IMG_6344`.

1. **BLOCKS** · VERIFIED. The room is dark. Mean brightness 0.23, the lowest of the 16 areas. Walls render near-black navy. Footage: mid slate-blue walls, evenly lit under the laylight. Owner: "It shouldn't be this dark room." Picture: `grand-gallery-1-follow.png`, `grand-gallery-3-follow.png`. Footage: `IMG_6344 sfm 0050 (24.5 s)`, `sfm 0348 (173.5 s)`.
2. **BLOCKS** · VERIFIED. Each painting has a pale blue-white blob on the wall, centred above the top of its frame, not on the canvas; 14 or more are visible down the two long walls. Footage: no pools; the wall is evenly lit from end to end. Picture: `grand-gallery-0-follow.png`, `grand-gallery-3-follow.png`. Footage: `IMG_6344 sfm 0318 (158.5 s)`, `sfm 0176 (87.5 s)`.
3. **BLOCKS** · VERIFIED. The floor is mid-brown and dimmer than the paintings. Footage: light oak under daylight, the brightest surface after the laylight (this clip is SDR). Picture: `grand-gallery-2-n.png`. Footage: `IMG_6344 sfm 0132 (65.5 s)`.
4. **BLOCKS** · EARLIER. Length 26.3 m against a measured 21.9 ± 0.5 (both long walls, painting by painting). `geometry.json` still has z 1.8 to 28.1. Gaps between frames and the wall left at each corner are wrong with it. This is under the owner's "sizing of the objects in relation to the room", and every room at the far end hangs off it.
5. **POLISH** · VERIFIED. Vault and cornice are dark grey-brown; the laylight reads as a narrow bright slot. Footage: white vault, white cornice, a gridded laylight along the crown with track lights on both edges. Picture: `grand-gallery-3-follow.png`. Footage: `IMG_6344 sfm 0348 (173.5 s)`.
6. **POLISH** · VERIFIED. Baseboard is dark grey. Footage: white, tall (about 30 cm), with outlets. Picture: `grand-gallery-0-follow.png`. Footage: `IMG_6344 sfm 0275 (137.0 s)`.
7. **POLISH** · VERIFIED. North door casing is grey. Its shape is right: casing, projecting header, exit sign, passage with leaves. Footage: the same in white. At the south end the Hall side of the portal shows two grey jamb strips; footage has a white casing with a projecting header and a green exit sign, the stone arch behind it. The head of the build's casing is out of frame, so I cannot tell whether it has a header. Picture: `grand-gallery-0-follow.png`, `grand-gallery-3-s.png`. Footage: `IMG_6344 sfm 0050 (24.5 s)`, `sfm 0132 (65.5 s)`.
8. **POLISH** · EARLIER, border VERIFIED. Floor boards are 1.9 × 0.36 m against about 0.76 × 0.12. The border runs along the long walls only; footage has a band on all four sides, a strip, short boards laid across, a strip. The owner chose the built board size in #186. Picture: `grand-gallery-0-n.png`. Footage: `IMG_6344 sfm 0070 (34.5 s)`, `sfm 0060 (29.5 s)`.
9. **POLISH** · VERIFIED in pictures. Seen from outside, the Hall's wall faces carry artefacts: a hatched stripe band at the left edge of `rockefeller-reveal-threshold-0-w.png`; four small striped patches beside the door and blurred pale blobs in `grand-gallery-reveal-threshold-0-s.png`. The owner's white zig-zag patches between paintings (his picture 01) do not appear in any of the 20 Hall views of this commit.
10. **MINOR** · EARLIER; absence VERIFIED in views. Low vent grilles under W1, W10, E9 and E1 are in the footage and in none of the 20 views. Label plates are blank. No thermostat, no wall text by N1. Footage: `IMG_6344 sfm 0070 (34.5 s)`, `sfm 0060 (29.5 s)`.
11. **MINOR** · VERIFIED in pictures. A white slab fills the lower-left corner of `grand-gallery-0-e.png` and a pale slab the right edge of `grand-gallery-3-e.png`: door parts cut by the camera.

Not wrong: both benches are tufted meshes; the north door's exit sign is lettered; the north door has a real casing.

## 2. Dark medieval room

As built: 10.0 × 6.1 m, ceiling 4.25 m. Views: `dark-medieval-room-0`. Footage: `IMG_6382`.

1. **BLOCKS** · VERIFIED. No light falls on any work. The walls are one dark tone, the sculptures on the south wall are unlit, and the floor is the brightest surface by a wide margin. Footage: a white ceiling with tracks and a dozen or more spots; each relief and the crucifix picked out, the crucifix casting a shadow on the wall. Picture: `dark-medieval-room-0-s.png`. Footage: `IMG_6382 000156 (77.5 s)`, `000081 (40.0 s)`.
2. **BLOCKS** · VERIFIED in pictures. Black slabs. A black-topped box a third of the picture wide, with the tracery set in it, across the bottom of `dark-medieval-room-0-e.png`. A full-height dark slab on the left edge of the same view, another on the right edge of `-0-s.png`, two more mid-frame in `-0-w.png`. They are cut walls and the pier, drawn with black caps. This is the owner's picture 02.
3. **POLISH** · VERIFIED. Stair door (east): a flat thin white frame with no header. Footage: a white moulded casing about 15–20 cm wide, a panelled soffit, two fire doors with closers and push bars, a lettered strip ending "MEDIEVAL GALLERY", an exit sign. Picture: `dark-medieval-room-0-e.png`. Footage: `IMG_6382 000041 (20.0 s)`.
4. **POLISH** · VERIFIED. Tracery opening (west): a bare hole. On this side the footage is also a plain rectangular opening, so the shape is right; the reveal should be pale plaster about half a metre deep. Picture: `dark-medieval-room-0-w.png`. Footage: `IMG_6382 000131 (65.0 s)`.
5. **POLISH** · VERIFIED. The two case bases are near-black plain cuboids. Footage: mid-grey bases with a recessed plinth line, a pale deck, glass with visible edges. Picture: `dark-medieval-room-0-n.png`, `-0-follow.png`. Footage: `IMG_6382 000156 (77.5 s)`.
6. **POLISH** · VERIFIED. Two rectangular pedestals, the long platform under the crucifix and the grille's base are plain dark or grey cuboids. Footage: mid-grey pedestals with labels; a long low white platform; the iron grille standing on a white platform about 15 cm high in a thin frame. Whether the build's grille is see-through I cannot tell from these views. Picture: `dark-medieval-room-0-s.png`, `-0-n.png`. Footage: `IMG_6382 000081 (40.0 s)`, `000011 (5.0 s)`.
7. **POLISH** · VERIFIED. Baseboard is grey. Footage: white, tall. Picture: `dark-medieval-room-0-n.png`. Footage: `IMG_6382 000131 (65.0 s)`.
8. **POLISH** · VERIFIED, lower confidence. The herringbone floor is pale beige with regular light and dark bands and reads as zigzag stripes. Footage: warm honey oak, the boards varying at random. Picture: `dark-medieval-room-0-e.png`. Footage: `IMG_6382 000156 (77.5 s)`, tone-mapped.
9. **POLISH** · EARLIER. Depth 6.1 m against 5.6. Stair door centre 1.07 m too far south, head at 2.74 m against about 2.15. Tracery door 0.6 m too far south, 1.13 m wide against 1.34. `geometry.json` unchanged.
10. **MINOR** · EARLIER. In the footage and not in the views: 14 or more labels, a wall text, a thermostat, a fire horn, a security dome, floor outlets at the stair door.
11. **MINOR** · VERIFIED. The pier with the black screen left of the portal is present and in the right place. Picture: `dark-medieval-room-0-follow.png`. Footage: `IMG_6382 000004 (1.5 s)`.

Not wrong: the stone portal is the best architecture in the build; two octagonal pedestals are modelled as octagons. The wall colour matches: dark slate blue-grey in the build and in the tone-mapped footage (`IMG_6382` 40, 65 and 77.5 s). Cannot tell from these views: the ceiling (no view reaches it).

## 3. Light Renaissance room

As built: 6.1 × 6.1 m, ceiling 3.5 m. Views: `light-renaissance-room-0`. Footage: `IMG_6383`.

1. **BLOCKS** · VERIFIED. Unlit: flat grey in all five views, no pool on any work. Footage: a ceiling track with spots; the case interiors and the works are the brightest things in the room. Picture: `light-renaissance-room-0-follow.png`. Footage: `IMG_6383 000126 (62.5 s)`.
2. **BLOCKS** · VERIFIED. A door leaf is drawn pure black in a grey frame, right foreground of `light-renaissance-room-0-w.png`; a second is dark brown-black, left of `-0-e.png`. Footage: cream-white panelled leaves. Footage: `IMG_6383 000126 (62.5 s)`.
3. **BLOCKS** · VERIFIED. Tracery doorway: a dark rectangular opening with the stone tracery sitting on top of it. Footage: a pointed-arch recess in white plaster, the tracery set inside the arch above a white shelf, lit. Picture: `light-renaissance-room-0-e.png`. Footage: `IMG_6383 000006 (2.5 s)`.
4. **POLISH** · VERIFIED. North door: a thin flat frame; the leaves stand in the room as thin slabs. Footage: a white moulded casing with a deep reveal, the leaf folded against it, a lettered strip and a slot vent above. The vent is present. Picture: `light-renaissance-room-0-n.png`, `-0-s.png`. Footage: `IMG_6383 000126 (62.5 s)`.
5. **POLISH** · VERIFIED. The baseboard is grey. Footage: white, about 20 cm. The wall colour is right: a mid grey in the build and in the tone-mapped footage. Picture: `light-renaissance-room-0-n.png`. Footage: `IMG_6383 000069 (34.0 s)`, `000126 (62.5 s)`, tone-mapped.
6. **POLISH** · VERIFIED. Five cases are bare glass cuboids on a slab. Three are outlined with black wire edges and two are not. Footage: a white case body with a deck and back panel under a clear acrylic hood with polished edges, and a thin frame on the floor beneath each of the four wall cases. Picture: `light-renaissance-room-0-n.png`, `-0-s.png`. Footage: `IMG_6383 000089 (44.0 s)`, `000035 (17.0 s)`.
7. **POLISH** · VERIFIED. The bench is a black slab on four legs. Footage: a grey tufted bench on a dark frame. Picture: `light-renaissance-room-0-n.png`. Footage: `IMG_6383 000126 (62.5 s)`.
8. **POLISH** · VERIFIED. The platform under the textiles is a grey slab. Footage: a white platform with sloped label blocks on it. Picture: `light-renaissance-room-0-s.png`. Footage: `IMG_6383 000021 (10.0 s)`.
9. **POLISH** · VERIFIED in pictures. A hard-edged bright rectangle lies on the floor inside the north doorway. Nothing like it in the footage. Picture: `light-renaissance-room-0-n.png`.
10. **MINOR** · EARLIER. Not in the views: the exit sign by the tracery door (its green glow is in `IMG_6383 000006`), a wall text, the strip over the north door, two security domes. Ceiling 3.5 m against about 3.8, low confidence.
11. **MINOR** · VERIFIED in pictures. Two short black posts stand at the bottom left of `light-renaissance-room-0-w.png`. I cannot tell what they are; nothing like them is in the frames I opened.

Not wrong: size and door position (audit); wall colour; the ceiling and slot vent exist; the window is on the right wall.

## 4. European gallery ("adjacent gallery")

As built: 6.1 × 26.3 m. Views: `adjacent-gallery-0` to `-3`, 20 pictures. Footage: `IMG_6384`, `6385`, `6386`.

1. **BLOCKS** · VERIFIED. No ceiling. All four follow views show the dark background above the wall tops, about a quarter of the picture. Footage: a flat white ceiling with six or more track runs, spots and security domes. Picture: `adjacent-gallery-2-follow.png`, `-3-follow.png`. Footage: `IMG_6386 000150 (74.5 s)`.
2. **BLOCKS** · VERIFIED. Unlit, except one warm glow on the west wall near the north end with no lamp to explain it. Footage: evenly lit along the whole length. Picture: `adjacent-gallery-0-w.png`, `-1-follow.png`. Footage: `IMG_6386 000150 (74.5 s)`.
3. **BLOCKS** · VERIFIED against one frame. Two full-height plain piers stand out from the east wall either side of the commode, each about 0.6–1 m deep. Footage: one shallow white display panel, carrying the red textile, on the white platform beside the commode. INFERRED: these are the owner's "weird pillars in this room that don't actually exist"; his picture 05 is this wall. Picture: `adjacent-gallery-0-e.png`, `-1-follow.png`. Footage: `IMG_6386 000136 (67.5 s)`.
4. **POLISH** · VERIFIED, colour at lower confidence. Walls are beige; baseboard thin and beige. Footage: light grey walls, reading slightly green in one tone-mapped frame and slightly warm in another, and a white baseboard about 20 cm. Picture: `adjacent-gallery-2-e.png`. Footage: `IMG_6384 000133 (66.0 s)`, `IMG_6386 000136 (67.5 s)`, tone-mapped.
5. **POLISH** · VERIFIED. South door: a flat frame; its leaves stand as dark slabs in the foreground. Footage: a white casing and cream panelled leaves. The north door is better: a casing with a header and panelled reveal is built. The folded leaf with a brass knob in that reveal I cannot make out in the views. Picture: `adjacent-gallery-3-n.png`, `-3-s.png`, `rockefeller-reveal-threshold-0-follow.png`. Footage: `IMG_6385 000003 (1.0 s)`.
6. **POLISH** · VERIFIED. Furniture: seven or more case and pedestal bases, three platforms and a bench are plain cuboids in beige, grey or black. Footage: white pedestals and platforms with a riser of about 12 cm. Picture: `adjacent-gallery-2-s.png`, `-1-n.png`. Footage: `IMG_6384 000037 (18.0 s)`, `IMG_6386 000136 (67.5 s)`.
7. **POLISH** · EARLIER, length INFERRED there. Width 6.1 m against 5.7. Length 26.3 m against at least 17.4 measured and 21.9 inferred from the floor plan.
8. **POLISH** · VERIFIED, lower confidence. Board direction is right. The boards are pale beige with regular light and dark stripes; footage is warm honey oak with random variation. Picture: `adjacent-gallery-1-s.png`. Footage: `IMG_6384 000133 (66.0 s)`, `IMG_6386 000136 (67.5 s)`, tone-mapped.
9. **MINOR** · EARLIER. Not in the views: low vents (three square grids on the east wall and two more), high slot vents, a thermostat, four wall texts.

Not wrong: both end doors now carry a lettered exit sign.

## 5. Rockefeller

As built: 6.4 × 6.8 m. Views: `rockefeller-0`. Footage: `IMG_6380` 120–240 s.

1. **BLOCKS** · VERIFIED. No ceiling. The follow view shows the dark background above the walls, with track rails and four lamp heads hanging against it. Footage: a white ceiling with a track loop. Picture: `rockefeller-0-follow.png`. Footage: `IMG_6380 000448 (223.5 s)`.
2. **BLOCKS** · VERIFIED in pictures. A black blurred smear covers the lower half of the gold-service case's base. It is the shadow of nothing. Picture: `purple-elevator-5-connector-0-w.png`, centre right.
3. **POLISH** · VERIFIED. Light is uneven and orange: three warm pools on the north wall and one on the west, none on the east and south cases. Footage: even light from the track loop on every wall; the cases are the brightest things. Picture: `rockefeller-0-n.png`, `-0-w.png`. Footage: `IMG_6380 000448 (223.5 s)`, `000334 (166.5 s)`.
4. **POLISH** · VERIFIED. Walls are warm beige. Footage: light grey-green in both tone-mapped frames. Picture: `rockefeller-0-follow.png`. Footage: `IMG_6380 000263 (131.0 s)`, `000448 (223.5 s)`, tone-mapped.
5. **POLISH** · VERIFIED. Both doors are flat thin frames, and both exit signs are blank green rectangles. Footage: white moulded casings; the south door has a deep panelled reveal with a folded leaf, a lettered strip and a slot vent above. Picture: `rockefeller-0-s.png`, `-0-e.png`. Footage: `IMG_6380 000474 (236.5 s)`, `000263 (131.0 s)`.
6. **POLISH** · VERIFIED. Four plain cuboids: the central pedestal, the gold-service case base, the bust's plinth, the wall platform. Footage: white, with label blocks on the platform and a label panel on the case's apron. Picture: `rockefeller-0-w.png`, `-0-e.png`. Footage: `IMG_6380 000334 (166.5 s)`, `000273 (136.0 s)`.
7. **MINOR** · EARLIER. Not in the views: about 14 labels, a wall text, security domes.

Not wrong: size (audit); board direction; the furniture on display is the most finished in the build.

## 6. Purple elevator-5 connector

As built: 2.15 × 1.84 m. Views: `purple-elevator-5-connector-0`. Footage: `IMG_6380` 100–104, 118–122, 240–254 s.

1. **BLOCKS** · VERIFIED in pictures. The follow view is inside the visitor: the hat fills the picture. The room is shorter than the follow distance. Picture: `purple-elevator-5-connector-0-follow.png`.
2. **BLOCKS** · VERIFIED in pictures. Flat navy slabs fill the bottom third of the east view and a strip of the other three, and Rockefeller, the grey gallery, the stair hall and a Main Hall painting all show over the walls. In no view does the connector read as a room. Picture: `purple-elevator-5-connector-0-e.png`, `-0-n.png`.
3. **POLISH** · VERIFIED. The black wall is one flat black rectangle. Footage: a black wall with a pair of black panelled doors and a brass knob, a lit wayfinding screen and a red pull station. Picture: `purple-elevator-5-connector-0-s.png`. Footage: `IMG_6380 000482 (240.5 s)`, `000206 (102.5 s)`.
4. **POLISH** · VERIFIED. The lift doors with the "5" and the purple return are present. Missing against the footage: the white casing, the steel call panel, the purple baseboard. Picture: `purple-elevator-5-connector-0-n.png`. Footage: `IMG_6380 000242 (120.5 s)`.
5. **POLISH** · VERIFIED. The openings at both ends are grey slab jambs standing free. Footage: white moulded casings, an exit sign over the east end, three recessed ceiling lights in a white ceiling. Picture: `purple-elevator-5-connector-0-n.png`, `-0-s.png`. Footage: `IMG_6380 000482 (240.5 s)`, `000206 (102.5 s)`.
6. **MINOR** · VERIFIED. Boards run along the corridor, as filmed. The footage also has a threshold strip across each end; I cannot tell from the views whether the build does. Footage: `IMG_6380 000244 (121.5 s)`.

Cannot tell: whether there is a ceiling (the follow view is unusable).

## 7. Grey French gallery

As built: 7.2 × 6.0 m. Views: `grey-french-gallery-0`. Footage: `IMG_6380` 0–50 and 80–118 s.

1. **BLOCKS** · VERIFIED. No ceiling. The follow view shows track rails and the beam against the dark background. Footage: a white ceiling with two track runs. Picture: `grey-french-gallery-0-follow.png`. Footage: `IMG_6380 000034 (16.5 s)`.
2. **BLOCKS** · VERIFIED. Unlit: no pool on any of the paintings. Footage: a soft pool round each painting from the ceiling spots. Picture: `grey-french-gallery-0-n.png`, `-0-s.png`. Footage: `IMG_6343 78 s`, `IMG_6343 40 s`, `IMG_6380 000034 (16.5 s)` tone-mapped.
3. **BLOCKS** · VERIFIED. The two columns are fat shafts with oversized scroll capitals, each topped by a black cuboid, carrying nothing. Footage: two slender plain white columns on simple round bases, with small capitals, under a white beam with a dentil cornice, and a pilaster at each end. The beam is drawn in the follow view and cut away in the dollhouse views, which leaves the black caps. INFERRED: a second candidate for the owner's "weird pillars"; his picture 08 shows them. Picture: `grey-french-gallery-0-w.png`, `marble-stair-hall-0-e.png`. Footage: `IMG_6380 000072 (35.5 s)`, `000090 (44.5 s)`, `IMG_6343 84 s`.
4. **POLISH** · VERIFIED, wall colour at lower confidence. Walls are a mid taupe-grey; baseboard grey. Footage: a white baseboard, and walls that read light cool grey in four frames of the earlier visit; one tone-mapped frame of the later visit shows the north wall darker and warmer. Picture: `grey-french-gallery-0-follow.png`. Footage: `IMG_6343 40 s`, `60 s`, `78 s`; `IMG_6380 000034 (16.5 s)` tone-mapped.
5. **POLISH** · VERIFIED. All three doors are flat thin frames, and their exit signs are blank green rectangles. Footage: white moulded casings; the Hall door has a panelled reveal with a folded leaf; the north door is a white six-panel leaf in a deep panelled reveal. Picture: `grey-french-gallery-0-w.png`, `-0-n.png`, `-0-s.png`. Footage: `IMG_6380 000202 (100.5 s)`, `IMG_6379 000341 (170.0 s)`.
6. **POLISH** · VERIFIED. The Rodin's plinth is a grey plain cuboid about 0.8 m tall. Footage: a low white plinth with a stepped base. Picture: `grey-french-gallery-0-e.png`. Footage: `IMG_6380 000034 (16.5 s)`.
7. **POLISH** · VERIFIED, lower confidence. The herringbone floor has the same pale tone and regular banding as the medieval room's; footage is warm honey oak with random variation. Picture: `grey-french-gallery-0-n.png`. Footage: `IMG_6343 60 s`, `IMG_6380 000034 (16.5 s)` tone-mapped.
8. **MINOR** · VERIFIED. Under the columns the floor changes at a pale strip. Footage: a grey stone threshold band about as wide as the column bases, which stand on it. Picture: `grey-french-gallery-0-e.png`. Footage: `IMG_6343 84 s`, `IMG_6380 000072 (35.5 s)`.
9. **MINOR** · VERIFIED. In the footage and not in the views: hanging wires above every painting (`IMG_6343 40 s`), a high slot vent and a security dome (`IMG_6343 78 s`, `60 s`), a wall text. A dark rectangle low on the south wall is in the place of the filmed low vent grille (`IMG_6343 78 s`).

## 8. Marble stair hall

As built: 8.4 × 6.0 m, 8.0 m high. Views: `marble-stair-hall-0`. Footage: `IMG_6381`, `IMG_6380` 45–82 s.

1. **BLOCKS** · VERIFIED. Balustrade: straight black bars, a flat X on every few, a disc for a newel. Footage: wrought-iron balusters with scroll and leaf panels, a cage newel on a curved bottom step, an oak handrail ending in a volute. Owner: "the detailing in the stairwell". Picture: `marble-stair-hall-0-n.png`, `-0-s.png`. Footage: `IMG_6381 000012 (5.5 s)`, `000008 (3.5 s)`.
2. **BLOCKS** · VERIFIED. Floor: a flat grey-and-white checker with hard edges. The diagonal layout and the size are about right. Footage: polished veined marble in off-white and pale grey, the two tones close together, with reflections of the window and lamps, and a grey marble skirting. Owner: the floor "needs to be better". Picture: `marble-stair-hall-0-n.png`, `-0-follow.png`. Footage: `IMG_6343 84 s`, `87 s`; `IMG_6381 000196 (97.5 s)` tone-mapped.
3. **BLOCKS** · VERIFIED. A flat black round-headed shape on the wall. Footage: a round-arched niche with a stair going down and a handrail, dark olive green inside. Picture: `marble-stair-hall-0-e.png`, right. Footage: `IMG_6343 84 s`, `87 s`; `IMG_6380 000072 (35.5 s)`, left.
4. **BLOCKS** · VERIFIED. Under the stair is a closed flat double door with an exit sign; it reads as a lift. Footage: a white cased doorway with an exit sign and white panelled leaves folded back, a short passage with a grey stone floor, and beyond it a gallery with Manet's *Le Repos* on the end wall. This is the door to the missing rooms; the owner's pictures 08 and 09 are both taken in front of it. Picture: `marble-stair-hall-0-e.png`. Footage: `IMG_6343 87 s`, `89.5 s`; `IMG_6381 000196 (97.5 s)`.
5. **BLOCKS** · VERIFIED. Unlit and grey. Footage: near-white walls, daylight from a tall three-part arched window with engaged columns at the half-landing, recessed ceiling lights, a cornice. The window is in none of the five views; I cannot tell whether it is built. Picture: `marble-stair-hall-0-follow.png`. Footage: `IMG_6343 87 s`, `IMG_6381 000058 (28.5 s)`, `000120 (59.5 s)`.
6. **POLISH** · VERIFIED in pictures. Large untextured slabs: the lower half of `marble-stair-hall-0-w.png` is one grey plane (the upper landing), and a pale blue-grey slab fills the top left of `-0-n.png`.
7. **POLISH** · VERIFIED. Stair shape: a square start and an octagonal newel base. Footage: a curved bottom step, about 14 steps, two quarter-turns of winders past the window, a curved wall and stringer. The dark strips on the treads are right. Picture: `marble-stair-hall-0-n.png`, `-0-e.png`. Footage: `IMG_6381 000008 (3.5 s)`, `000048 (23.5 s)`.
8. **POLISH** · VERIFIED. The two columns with black caps, seen from this side (finding 3 of area 7). Picture: `marble-stair-hall-0-e.png`.
9. **MINOR** · VERIFIED from `report.json`. The chandelier hangs above every view and cannot be clicked: the run's one failure, "2011.60#153 … not clickable from in front of it".

The chimneypiece is an object and is in the other census; from the side it shows as stacked slices (`marble-stair-hall-0-e.png`).

## 9. Skylight Gallery ("piano room")

As built: 9.5 × 5.0 m, 3.9 m high. Views: `skylight-gallery-0`. Footage: `IMG_6379`.

1. **BLOCKS** · VERIFIED. It is the wrong kind of room: one storey, entered at floor level. Footage: a two-storey room. The grey gallery's door opens onto an upper landing with a black floor and an iron balustrade on two sides. A black stair with a curved bottom step, a half-landing in the corner and a wall handrail goes down to the oak floor a storey below. None of that is built. Owner: "Totally incorrect. There's a stairwell and you're just oversimplifying it." Picture: all five of `skylight-gallery-0-*.png`. Footage: `IMG_6379 000014 (6.5 s)`, `000310 (154.5 s)`, `000320 (159.5 s)`, `000056 (27.5 s)`, `000160 (79.5 s)`.
2. **BLOCKS** · VERIFIED absent in views. No skylight. Footage: two gridded laylights in a panelled ceiling with a dentil cornice and track heads. No view shows a ceiling at all, so I cannot tell whether one exists. Picture: `skylight-gallery-0-follow.png`. Footage: `IMG_6379 000014 (6.5 s)`, `000034 (16.5 s)`.
3. **BLOCKS** · VERIFIED. The works hang at eye level on a 3.9 m wall. Footage: they hang high, above door-head height, on walls about two storeys tall. Picture: `skylight-gallery-0-n.png`. Footage: `IMG_6379 000310 (154.5 s)`, `000220 (109.5 s)`.
4. **BLOCKS** · VERIFIED. The piano is an L-shaped black box on four square legs. Footage: a grand piano with a curved case. Picture: `skylight-gallery-0-n.png`, `-0-w.png`. Footage: `IMG_6379 000310 (154.5 s)`.
5. **POLISH** · VERIFIED. The exit door on the west wall is a thin frame. Footage: a moulded white casing, two fire doors with push bars and a lettered exit sign. The wayfinding screen beside the lift is not in the views. Picture: `skylight-gallery-0-w.png`. Footage: `IMG_6379 000220 (109.5 s)`, `000014 (6.5 s)`.
6. **POLISH** · VERIFIED in pictures. Brightest room in the build, 0.61, with a soft wash along the wall tops and no lamp. See the lighting pattern.
7. **MINOR** · VERIFIED. Right against the footage: pale grey walls, straight pale boards, white baseboard, lift "4" with its purple reveal and the "SKYLIGHT GALLERY" strip, a profiled entry casing with panelled leaves. Picture: `skylight-gallery-0-s.png`. Footage: `IMG_6379 000160 (79.5 s)`, `000341 (170.0 s)`.

The tan rectangle on the west wall is a filmed work (a tan monochrome canvas, `IMG_6379 000034`), not a placeholder.

## 10. Lion stair landing

As built: 5.6 × 9.5 m with the stair void from 5.6 m south of the lion wall; ceiling 4.1 m. Views: `lion-stair-landing-0`. Footage: `IMG_6387` 0–46 s.

1. **BLOCKS** · VERIFIED. The stair shaft is dark grey, darker than the landing; the left third of the west view is a near-black slab. Footage: a white shaft, lit from above and by oval wall lamps, and over the landing a white ceiling with a cornice and recessed spots. Picture: `lion-stair-landing-0-s.png`, `-0-w.png`. Footage: `IMG_6387 000055 (27.0 s)`, `000018 (8.5 s)`, tone-mapped.
2. **BLOCKS** · VERIFIED. Balustrade: thin plain black bars under a straight brown rail. Footage: iron balusters each with a scroll ornament, a wood handrail sweeping round the well in a curve, a second rail on the wall. Picture: `lion-stair-landing-0-n.png`, `-0-follow.png`. Footage: `IMG_6387 000031 (15.0 s)`, `000055 (27.0 s)`.
3. **POLISH** · VERIFIED shape; sizes EARLIER. The stair is now the right kind, an open-well stair: up along the west wall, turning east along the south wall, with the flight down on the east. Still wrong: square corners where the footage has curved winders and a curved white stringer; nothing above or below (the footage sees two storeys down); the void starts 5.6 m from the lion wall against 4.1. Picture: `lion-stair-landing-0-s.png`. Footage: `IMG_6387 000040 (19.5 s)`, `000031 (15.0 s)`.
4. **MINOR** · VERIFIED. Floor: the herringbone of large two-tone slabs is the right pattern. The tones are two cool greys; footage has a warm beige and a grey-beige. Picture: `lion-stair-landing-0-e.png`. Footage: `IMG_6387 000018 (8.5 s)`, `000022 (10.5 s)`, tone-mapped.
5. **POLISH** · VERIFIED; head height EARLIER. All three doors are flat thin frames, and the leaves are beige slabs with black bars. Footage: white moulded casings about 15–20 cm wide; a wall about 0.9 m thick at the modern door; white six-panel leaves with closers and push bars. Door heads 2.74 m against 2.15–2.3. Picture: `lion-stair-landing-0-follow.png`, `-0-e.png`. Footage: `IMG_6387 000022 (10.5 s)`, `000018 (8.5 s)`, `000011 (5.0 s)`.
6. **POLISH** · VERIFIED. Lion wall: a grey wall, one pool on the relief, a black bar above it. Footage: a white wall; the relief in a wide flush white surround; a grey louvred vent up and to the left; a tall grey text panel between the door and the lion; a small label. No text panel, no label. Picture: `lion-stair-landing-0-follow.png`. Footage: `IMG_6387 000022 (10.5 s)`.
7. **POLISH** · VERIFIED. One grey on every wall. Footage: grey on the medieval-door wall and the sculpture-door wall, white on the lion wall and the shaft. The grey the build uses is about right for the two grey walls. Picture: `lion-stair-landing-0-follow.png`. Footage: `IMG_6387 000018 (8.5 s)`, `000022 (10.5 s)`, tone-mapped.
8. **MINOR** · EARLIER. Not in the views: the level "5" sign and directory by the medieval door (`IMG_6387 000016`), the fire strobe, pull station and access panel by the sculpture door (`000011`).

## 11. Modern painting gallery

As built: 6.0 × 5.8 m, ceiling 3.5 m. Views: `modern-painting-gallery-0`. Footage: `IMG_6387` 46–84 s.

1. **BLOCKS** · VERIFIED. On the south wall the two works are blurred smudges: a pale rectangle and a dark one with soft edges, inside a light pool. Footage: the Braque in a gilt frame with a cream liner and the Villon in a white box frame, sharp, each with a label. Either the works are hidden and their baked shadows remain, or they are drawn out of focus; I cannot tell which. The playtest rules name the first case. Picture: `modern-painting-gallery-0-s.png`, `-0-w.png` (left wall). Footage: `IMG_6387 000108 (53.5 s)`.
2. **BLOCKS** · VERIFIED in pictures. Flat navy beside the room: the right quarter of the north view and the left sixth of the south view. Picture: `modern-painting-gallery-0-n.png`, `-0-s.png`.
3. **POLISH** · VERIFIED. Light: a soft wash on the north and south walls, three small fixtures on the ceiling, windows drawn as bright horizontal slats. Footage: track loops with about nine heads and recessed lights, even light, plain roller shades drawn half-way with daylight below them. Picture: `modern-painting-gallery-0-follow.png`, `-0-e.png`. Footage: `IMG_6343 228 s`, `242 s`; `IMG_6387 000095 (47.0 s)`.
4. **POLISH** · VERIFIED. Under each window is a beige box with a dark slot. Footage: a white panelled apron under each sill, with a louvred grille along its foot. Picture: `modern-painting-gallery-0-e.png`. Footage: `IMG_6343 242 s`, `IMG_6387 000124 (61.5 s)`.
5. **POLISH** · VERIFIED; thickness EARLIER. Entry door: a thin frame in a wall with no thickness. Footage: a white casing, a wall about 0.9 m thick with a stone threshold and two floor outlets, an exit sign inside above the door, a low vent panel on each side. The leaves with push bars are right. Picture: `modern-painting-gallery-0-s.png`. Footage: `IMG_6343 261 s`, `228 s`; `IMG_6387 000166 (82.5 s)`.
6. **POLISH** · VERIFIED. Walls are warm beige; baseboard beige. Footage: light blue-grey walls, white baseboard, in both visits. Picture: `modern-painting-gallery-0-n.png`. Footage: `IMG_6343 252 s`, `261 s`; `IMG_6387 000148 (73.5 s)` tone-mapped.
7. **POLISH** · VERIFIED. The bench is a black slab; the footage's is dark grey and tufted on a dark frame. The sculpture's pedestal is a plain beige cuboid; the footage's is light grey with a stepped base and a bevelled deck under an acrylic hood. Picture: `modern-painting-gallery-0-e.png`. Footage: `IMG_6343 228 s`, `242 s`.
8. **POLISH** · EARLIER, medium confidence. Depth 5.8 m against about 7.3.
9. **MINOR** · EARLIER. Not in the views: six labels, a wall text, security domes, the high vent over the large painting (`IMG_6387 000095`), the strip over the far door (`000140`).

Not wrong: the far door has a profiled casing with a header (`modern-adjoining-gallery-threshold-study-limit-0-follow.png`).

## 12. Stub: Main Hall reveal threshold

As built: 1.9 × 0.76 m, between the Main Hall and the grey gallery. Views: `grand-gallery-reveal-threshold-0`. Footage: `IMG_6380 000202 (100.5 s)`; no other wall was filmed.

1. **BLOCKS** · VERIFIED in pictures. Navy slabs: the bottom third of the north view; in the south view the upper two thirds is the Hall's outer wall face in dark navy. The lift, the stair hall and the grey gallery show beside it. Picture: `grand-gallery-reveal-threshold-0-n.png`, `-0-s.png`, `-0-e.png`.
2. **POLISH** · VERIFIED. The follow view is the best doorway in the build: a casing with a header, panelled reveals, panelled leaves. It is grey. Footage: the same in white, with a folded leaf and a brass knob. Picture: `grand-gallery-reveal-threshold-0-follow.png`. Footage: `IMG_6380 000202 (100.5 s)`.
3. **POLISH** · VERIFIED in pictures. A dark brown-black block stands at the right of the south view, about an eighth of the picture. I cannot tell what it is. Picture: `grand-gallery-reveal-threshold-0-s.png`.
4. **MINOR** · VERIFIED in pictures. A blank green rectangle lies on a beige slab in the east view: an exit sign seen from above. Picture: `grand-gallery-reveal-threshold-0-e.png`.

## 13. Stub: Rockefeller reveal threshold

As built: 2.0 × 0.76 m, between the European gallery and Rockefeller. Views: `rockefeller-reveal-threshold-0`. Footage: `IMG_6380 000266 (132.5 s)`, `IMG_6385 000003 (1.0 s)`.

1. **BLOCKS** · VERIFIED in pictures. Navy slabs in the north and south views; in the west view the left 40% is the Hall's outer wall, with a hatched stripe band and the corner of a painting. Picture: `rockefeller-reveal-threshold-0-w.png`, `-0-n.png`.
2. **POLISH** · VERIFIED. The follow view has a casing with a header, a panelled reveal and a lettered exit sign: the right kind of doorway. It is beige; the footage's is white, with a folded panelled leaf and a brass knob that I cannot make out in the build. Picture: `rockefeller-reveal-threshold-0-follow.png`. Footage: `IMG_6385 000003 (1.0 s)`.
3. **MINOR** · VERIFIED in pictures. In the dollhouse views the jambs are two thin slabs standing free. Picture: `rockefeller-reveal-threshold-0-n.png`.

## 14. Stub: Skylight Gallery reveal threshold

As built: 2.0 × 0.8 m, between the grey gallery and the Skylight Gallery. Views: `skylight-gallery-reveal-threshold-0`. Footage: `IMG_6379 000341 (170.0 s)`.

1. **BLOCKS** · VERIFIED. It joins two floors as one. Footage: the door opens onto the upper landing, whose black floor meets the grey gallery's oak at the sill; the gallery floor is a storey below. Build: oak boards run level through the door into the room. Picture: `skylight-gallery-reveal-threshold-0-n.png`. Footage: `IMG_6379 000341 (170.0 s)`.
2. **BLOCKS** · VERIFIED in pictures. Navy slabs across the bottom third of the north and south views; the left 35% of the west view is one blank pale slab. Picture: `skylight-gallery-reveal-threshold-0-n.png`, `-0-w.png`.
3. **POLISH** · VERIFIED. The exit sign over the door is a blank green rectangle. The casing and panelled leaves are the right kind. Picture: `skylight-gallery-reveal-threshold-0-follow.png`. Footage: `IMG_6379 000341 (170.0 s)`.

## 15. Stub: modern adjoining gallery

As built: 1.3 × 1.6 m, north of the modern gallery. Views: `modern-adjoining-gallery-threshold-study-limit-0`. Footage: `IMG_6387 000140 (69.5 s)` through the doorway; `IMG_6343` 176–223 s inside the room beyond.

1. **BLOCKS** · VERIFIED. A closet in a void. Three of the five views are 60–85% flat navy, and the stub is a beige box ending in a blank wall. Footage: through this doorway, the second of the two Impressionist galleries: an oak floor, grey walls, sash windows with shades, gilt-framed paintings each with a label, and a lettered strip over the door. The earlier clip walks through it into the modern gallery. This stub is the south end of the missing rooms. Picture: `modern-adjoining-gallery-threshold-study-limit-0-n.png`, `-0-e.png`, `-0-s.png`. Footage: `IMG_6387 000140 (69.5 s)`, `IMG_6343 185 s`, `210 s`, `228 s`.
2. **BLOCKS** · VERIFIED in pictures. In the west view the Main Hall's dark floor and a bench show beside the stub, at a different brightness, with a saw-tooth edge. Picture: `modern-adjoining-gallery-threshold-study-limit-0-w.png`.
3. **POLISH** · VERIFIED. The casing on the modern-gallery side is profiled with a header: the right kind, in beige for the footage's white. Picture: `modern-adjoining-gallery-threshold-study-limit-0-follow.png`. Footage: `IMG_6387 000140 (69.5 s)`.

## 16. Stub: white sculpture gallery

As built: 1.5 × 2.0 m, east of the lion landing. Views: `white-sculpture-gallery-threshold-study-limit-0`. Footage: `IMG_6387 000080 (39.5 s)`, through the open door only.

1. **BLOCKS** · VERIFIED in pictures. The follow view is inside the visitor: the hat fills the picture. Picture: `white-sculpture-gallery-threshold-study-limit-0-follow.png`.
2. **BLOCKS** · VERIFIED. A dark box in a void. The east view is about 75% flat navy and the north and south views about 55%. The stub is a grey box with a dark board floor and a blank end wall. Footage: through the door, a bright gallery with pale blue walls, a round white stepped plinth carrying five or more marble heads on pedestals, a white round column and a pale herringbone floor. Picture: `white-sculpture-gallery-threshold-study-limit-0-e.png`, `-0-n.png`. Footage: `IMG_6387 000080 (39.5 s)`.
3. **POLISH** · VERIFIED; width EARLIER. The door is a flat frame. Footage: a white moulded casing and a white leaf with a closer and push bar, opening into the sculpture gallery. Opening 2.0 m wide against about 1.6. Picture: `lion-stair-landing-0-e.png`. Footage: `IMG_6387 000080 (39.5 s)`, `000011 (5.0 s)`.
4. **MINOR** · VERIFIED. The stub's floor is dark brown boards. Footage: pale herringbone beyond a stone threshold. Picture: `white-sculpture-gallery-threshold-study-limit-0-e.png`.

## What I could not judge

1. **Ceilings in five rooms and the stubs.** Medieval room, Skylight Gallery, marble stair hall, lion landing, connector and the five stubs: no view reaches the ceiling, so I cannot say whether one is built or what is on it. A follow view tilted up, one per room, would settle it.
2. **The marble stair hall's window and upper landing.** Not in any of the five views.
3. **Anything that only shows in motion.** Room changes, the black flash on entering a room, flicker, the camera passing through walls. These are single stills. The two follow views inside the visitor's head are the only motion-type fault I can prove.
4. **The owner's white patches on the Main Hall walls** (his picture 01). Not in the 20 Hall views of this commit; I cannot say whether they are fixed or only show from his camera position.
5. **Exact wall colours.** Good enough to say beige against grey, not to give a paint value. The Hall's blue is "mid slate blue, not near-black"; the European and grey galleries' greys shift between frames and visits.
6. **Exact sizes.** I measured nothing. Every dimension here is the 1 Oct audit's, and that audit did not reach the grey gallery, the connector, the marble stair hall or the Skylight Gallery. Those four rooms have no measured size at all.
7. **Whether the modern gallery's smudges are hidden works or blurred ones**, and what the two black posts in the Renaissance room and the dark block beside the Main Hall threshold are.
8. **Counts of boxes.** Counted from five views per standpoint; furniture hidden behind other furniture is not counted. Read them as "at least".
9. **Two of the three 5 Oct screen recordings on the Proton Drive.** Not opened.
10. **The two Impressionist galleries' sizes and full contents.** I opened 8 frames of `IMG_6343` between 89 and 228 s, enough to confirm the route and the rooms, not to inventory them.

## Sources

- Owner's crit and ten pictures: [#238, 7 Oct comment](https://github.com/Reid-Surmeier/risd-godot/issues/238#issuecomment-6051092255); `docs/evidence/crit-2026-10-07/`.
- Playtest pictures and `report.json`: `build/museum-playtest/` in the `wt-runtime` checkout (not in git).
- Footage: `~/risd-godot-ingestion/collection-expansion/survey-2fps/` and `verified/`; `~/risd-godot-ingestion/sfm-6344/images/`; `~/risd-godot-ingestion/walkthrough/IMG_6343.MOV` (grey gallery 0–82 s, marble stair hall 82–88 s, the doorway 88–91 s, Impressionist gallery A 91–154 s, gallery B 176–223 s, modern gallery 224–263 s; times from the sources researcher, spot-checked at 17 frames).
- Audits: `docs/research/2026-10-01-museum-architecture-audit.md`, `2026-10-01-museum-inventory-audit.md`, `2026-10-01-acnh-museum-polish-spec.md`.
- Room list and sizes: `modules/shell/collection_rooms/geometry.json`.
