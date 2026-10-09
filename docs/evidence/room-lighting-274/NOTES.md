# Update, 8 Oct night: the other rooms under the warm rule (`feat/room-lighting-274b`)

This section is the current one. The section under it ("Update, 8 Oct evening") describes the
rule and the medieval room and still holds; its list of unjudged rooms is superseded here.

## What was wrong, looking at the live build's views (`cef5a26e`, 130 views)

1. In every room with a dense hang the fill had been left at a quarter of its base (the
   `SPILL` floor) and then trimmed down again for the afternoon's near-white rule: 0.2 to 0.35
   a lamp against spots of 6 to 9. The walls were lit by the spots and by bounce off the oak,
   both orange, so a pale grey-green wall read peach from end to end and the pools had nothing
   to stand out from. European gallery, wall away from works: 111,90,67.
2. The Skylight Gallery's landing, treads and reveal floor are painted `25272a`. Under the
   room's lamps that read 5 to 24 of 255: a hole where the visitor stands.
3. The Impressionist galleries' walls between pools read 48 and 72: grey and dim.

## What changed (three bakes, each on the RTX: 42 s, 39 s, 39 s)

| Room | `FILL_TRIM` before | after | Paint |
| --- | --- | --- | --- |
| European (adjacent) gallery | 0.82 | 2.8 | wall `dfe3dd` to `cddddb`, a step cooler, so that under the warm light it still reads grey-green |
| Skylight Gallery | 1 | 3.0 | landing, treads, nosings `25272a` to `3d3f43` (`TREAD` in `skylight_additions.gd`) |
| Skylight Gallery reveal threshold | 1 | 3.0 | its floor, the same |
| Impressionist gallery A | 1 | 2.5 | |
| Impressionist gallery B | 1 | 1.8 | |
| Impressionist passage, passage return | 1 | 1.5 | |
| Rockefeller | 0.75 | 1.5 | |
| Rockefeller reveal threshold | 1.5 | 1.0 | its floor rose with the European gallery's fill beside it |
| grey French gallery | 0.5 | 2.0 | |
| light Renaissance room | 0.95 | 2.5 | |
| modern painting gallery | 0.86 | 3.0 | |

No lamp's aim, colour or strength changed; no constant of the rule changed; the dark medieval
room's numbers are untouched (its readings moved by one count: 99 to 100 on the floor).

## The light pass, before (`cef5a26e`, live) and after (this branch), 0 to 255

| Room | | Floor | Wall beside works | Wall away from works | Skirting | Works |
| --- | --- | --- | --- | --- | --- | --- |
| Rockefeller | before | 180,126,69 (134) | 142,111,79 (116) | - | - | 119 |
|  | after | 198,142,80 (150) | 148,118,86 (122) | - | - | 121 |
| adjacent gallery | before | 152,103,53 (109) | 196,153,105 (159) | 111,90,67 (93) | 148,119,88 (122) | 130 |
|  | after | 198,144,81 (151) | 204,176,134 (179) | 140,129,106 (129) | 180,153,123 (157) | 132 |
| light Renaissance room | before | 151,102,52 (109) | 189,147,100 (153) | - | 133,102,74 (107) | 100 |
|  | after | 194,139,76 (146) | 200,164,118 (168) | - | 163,132,101 (136) | 101 |
| dark medieval room | before | 126,95,59 (99) | 92,73,59 (76) | 37,35,37 (36) | 96,73,54 (77) | 108 |
|  | after | 127,96,60 (100) | 92,73,60 (76) | 38,35,37 (36) | 97,73,55 (77) | 108 |
| lion stair landing | before | 149,131,110 (134) | 150,131,109 (133) | 114,106,94 (107) | 115,105,90 (106) | 128 |
|  | after | 150,132,110 (134) | 150,131,110 (134) | 122,114,100 (115) | 118,107,92 (108) | 128 |
| purple elevator-5 connector | before | 181,130,72 (136) | - | 82,70,67 (72) | 69,57,55 (59) | - |
|  | after | 191,138,76 (145) | - | 84,71,69 (74) | 70,58,57 (60) | - |
| grey French gallery | before | 153,111,66 (117) | 102,83,63 (85) | - | 145,115,88 (120) | 106 |
|  | after | 186,138,84 (145) | 120,101,79 (103) | - | 171,141,112 (146) | 111 |
| marble stair hall | before | 130,114,97 (116) | - | 50,47,44 (48) | 126,111,94 (113) | 83 |
|  | after | 134,118,100 (120) | - | 51,48,44 (49) | 133,117,99 (119) | 85 |
| Skylight Gallery | before | 83,74,66 (75) | 183,155,134 (159) | 135,126,121 (127) | 113,108,100 (108) | 165 |
|  | after | 99,89,81 (90) | 201,174,155 (178) | 162,152,147 (154) | 130,127,119 (127) | 174 |
| modern painting gallery | before | 129,86,42 (92) | 175,139,98 (144) | - | 146,111,81 (116) | 106 |
|  | after | 182,129,70 (136) | 204,171,132 (175) | - | 192,157,125 (162) | 107 |
| white sculpture gallery threshold study limit | before | 138,107,66 (111) | - | 123,115,100 (115) | 122,107,91 (109) | - |
|  | after | 138,107,66 (111) | - | 124,115,100 (116) | 122,107,91 (109) | - |
| Impressionist gallery B | before | 143,99,51 (105) | 170,131,94 (137) | 81,70,60 (72) | 124,102,80 (105) | 126 |
|  | after | 178,126,67 (133) | 185,147,110 (152) | 102,89,76 (91) | 150,125,102 (129) | 127 |
| Impressionist passage | before | 125,90,48 (94) | - | 88,79,68 (80) | 85,75,64 (76) | - |
|  | after | 147,107,58 (112) | - | 105,93,80 (94) | 100,88,74 (90) | - |
| Impressionist gallery A | before | 134,92,47 (98) | 167,128,91 (134) | 54,46,39 (48) | 119,95,74 (99) | 95 |
|  | after | 186,133,73 (140) | 189,151,115 (157) | 75,65,55 (67) | 155,129,104 (133) | 95 |
| Impressionist passage return | before | 128,93,50 (97) | - | 101,91,77 (92) | 110,96,80 (98) | - |
|  | after | 156,114,63 (119) | - | 122,108,92 (110) | 131,114,95 (116) | - |
| Grand Gallery reveal threshold | before | 159,118,66 (123) | - | 132,119,104 (121) | 133,115,96 (118) | - |
|  | after | 178,133,74 (138) | - | 142,127,111 (129) | 146,126,105 (128) | - |
| Rockefeller reveal threshold | before | 155,113,60 (118) | - | 153,128,103 (131) | 142,114,88 (118) | - |
|  | after | 184,136,75 (142) | - | 173,146,117 (150) | 164,136,105 (140) | - |
| Skylight Gallery reveal threshold | before | 36,30,26 (31) | - | 156,135,115 (138) | 137,119,102 (121) | - |
|  | after | 68,61,55 (62) | - | 202,180,156 (183) | 166,148,129 (150) | - |

Wall beside works over wall away from works: European gallery 1.71 to 1.39 (the wall away rose
from 93 to 129 and turned from peach to grey-green, so the pool now differs in colour as well
as level); Impressionist A 2.8 to 2.3; Impressionist B 1.9 to 1.7; Skylight Gallery 1.25 to 1.16.

Sheets, before on top, the same five cameras: `7-` to `19-…-before-after.jpg` in this folder.

## Looked at and left alone

- Lion stair landing: the lion has a strong pool, walls and floor read 108 to 134. Nothing to fix.
- Marble stair hall: walls cream, floor 120, the fireplace in its pool. Its "wall away from
  works" of 48 is six samples that land on the dark cut-wall slabs, which are another branch's.
- Dark medieval room: judged by the owner's words on the earlier branch; not touched.
- Purple connector, white sculpture stub, Grand Gallery reveal threshold: read 111 to 145 on the
  floor; left.

## Not solved

1. Rockefeller's walls still read olive-brown (148,118,86 beside works) where the paint is a
   pale blue-green. Its works stand in cases in the middle of the room, so no spot lights a
   wall, and the fill points down: at trim 3.0 the floor bleached (176) while the wall only
   reached 133. It needs light aimed at the walls, which the rule does not have; a trim cannot
   do it. Floor now 150.
2. The grey French gallery's walls read warm cream (120,101,79), the paint being a warm white.
   Pools are visible on every picture; whether that is too peach is the owner's call.
3. Skylight Gallery: treads read about 40, but risers in shadow and the balusters' ironwork are
   still under 25 (14 to 20% of the stair in three views), and the piano is black, as it is.
4. Black window panes in the Impressionist galleries and the cut-wall faces: another branch.
5. Ceilings were not judged. The Web export was not run.

---

# Update, 8 Oct evening: the warm rule, and what the day's bake trouble was

Everything below this heading supersedes the lamp colours, levels and bake times in the
sections under it, which describe the afternoon's near-white rule (`a25c1a24`). The method
(the light pass, wall against skirting) and the costs of drawing works still hold.

## The owner's words, 17:35, playing the live build `10f7c0b9` (old lamps)

"generally also lighting is so bad. you don't have spotlights on objects warm glow." "the
lighting should be warm in the medieval room." So the rule turned: a warm spot on every work
(`#ffb870`, 3.6 a metre), a low faintly warm fill (`#fff0e0`, 1.0 for 25 m2), works warmed
by their spot and shaded harder from its side. The rule in words is the "Light" section of
`docs/playtest/room-builder-guide.md`.

## The medieval room, first (VERIFIED)

`5-dark-medieval-room-warm.jpg`: the owner's two screenshots, the build before, this branch,
the Main Hall. Baked on the RTX ("bake on the GPU (Windows Godot): 49 s", BAKE_OK
users=1761, 139 lamps), rendered at the game camera on opengl3.

| Dark medieval room | Floor | Wall beside works | Wall away from works | Skirting | Works |
| --- | --- | --- | --- | --- | --- |
| before (`cb8a272e`) | 122,106,82 (107) | 44,43,44 (43) | 31,29,30 (30) | not sampled | 108 |
| this branch | 121,90,55 (94) | 84,62,45 (66) | 27,23,21 (24) | 93,67,46 (71) | 88 |

The pool is 2.8 times the wall away from it (before 1.4); floor and walls are warm where
they were grey. No wall reads black (24 of 255 at the dimmest). Works read 88 against 108
before because the placed meshes (heads, the crucifix, the angel) are now shaded from their
lamp's side instead of drawn at one flat brightness.

Only this room has been looked at under the warm rule. The other rooms are baked with it
and unjudged; their `FILL_TRIM` values are still the afternoon's.

## What the bake trouble was

1. Every bake until 17:55 ran on lavapipe, the CPU Vulkan device inside WSL. On it the whole
   cost is the lamps' shadow rays: with 139 lamps the bake did not finish in 7 minutes; the
   same with shadows off on every lamp took 1:37; with probes off, bounces off or the
   denoiser off it still did not finish. Triangle counts, texels, lamp ranges and other
   agents' load, each of which I named as the cause during the afternoon, were not it.
2. `scripts/rebuild_rooms.sh` now bakes in the Windows build of Godot on the NVIDIA driver:
   18.7 s for the same 139 lamps.
3. Kept from the hunt because they are worth having anyway: works and any mesh over 30,000
   triangles are not written into `addition_baked/room.tscn` (16 MB; 35 MB with thirteen
   placed meshes and one ironwork inline), and BAKE_PREPARE prints what each room puts in
   the bake.

## A fault I pushed and fixed

`3ebf64bc` and `4fe71f99` stopped the rooms installing in any rendered debug run (0 works,
0 cut-away walls): duplicating a work's shader material copied `floor_z_limits` into it.
Fixed in `aea45e34`. It did not show in `scripts/check.sh`, which runs headless.

## Also fixed on the way

Floors were merged under whichever floor material came last, so once the Skylight Gallery
brought its own paler oak every room's floor took that tone. Floors are merged per material.

## Not done, and not known (evening)

1. Every room but the medieval one under the warm rule: unjudged. The Renaissance window
   shade, the Impressionist rooms, the stairs and the two-storey Skylight Gallery have not
   been looked at with their lamps at all.
2. The black slabs and doorways in the pictures are the cut-away and the room-change, not
   the bake; another branch replaces them.
3. Whether a statue's box shadow reads wrong: not seen wrong on the medieval heads or the
   crucifix in these views; not looked at close.
4. The Web export was not run.

---

# One lighting for every room (#274)

Branch `feat/room-lighting-274`, on `origin/feat/trim-kit-273`. The owner, 7 Oct: "doesn't
have any lighting, like there's no lighting present in it", "the inconsistent lighting,
inconsistent shader application", and of the Main Hall: "The center room should go back to
the original lighting it was in." The Hall as restored is the exemplar; nothing in the Hall
or its bake is changed here.

Everything below marked VERIFIED was rendered and measured on a full bake of `0d3dc292`
(105 lamps, `BAKE_OK users=1236`) at the game camera on the Web build's renderer (GL
Compatibility, `--rendering-driver opengl3`, 960 x 640). "Before" is the build tip
`cb8a272e`, which has no trim-branch ceilings or furniture; "after" has them.

## The rule

In `docs/playtest/room-builder-guide.md`, section "Light". In one breath: every area of the
plan gets a fill at its ceiling, every catalogued work gets a spot hung as the Hall's are,
lamps are near white and the oak carries the honey, works are drawn at their own colours
with one brightness per vertex from their own spot, walls are pale greys judged against the
room's white skirting. `remodel_bake.gd` derives all of it from `geometry.json` and the
works; no room script places a lamp.

## Pictures

Each sheet: tone-mapped footage, build before, build after, the Main Hall.

1. `1-light-renaissance-room.jpg`: the first room, two walls.
2. `2-rockefeller-european.jpg`
3. `3-grey-french-medieval.jpg`
4. `4-modern-lion-landing.jpg`

Not yet on a sheet: the Skylight Gallery, the marble stair hall, the connector and the five
stubs. The first two are being rebuilt on other branches (#275, #276) and are lit by this
rule from the plan as it stands; they are measured below.

## Brightness, before > after (VERIFIED)

Picture brightness, 0 to 255, from each room's four dollhouse views with the visitor hidden:
the floor on a half-metre grid clear of furniture, the wall 20 cm beside each work, the wall
a metre or more from any work, each work over the middle of its front. `--only=light` of
`modules/shell/playtest/museum_playtest.gd` prints these.

| Area | Floor | Wall beside works | Wall away from works | Works | Whole picture | Lamps after |
| --- | --- | --- | --- | --- | --- | ---: |
| Main Hall (reference, untouched) | 143 | 74 | 53 | 79 | 126 | its own 37 |
| Rockefeller | 150 > 143 | 129 > 110 | - | 125 > 123 | 129 > 114 | 12 |
| European gallery | 136 > 136 | 122 > 155 | 127 > 117 | 121 > 135 | 128 > 125 | 37 |
| Light Renaissance room | 87 > 134 | 78 > 149 | - | 64 > 110 | 78 > 111 | 9 |
| Dark medieval room | 107 > 133 | 43 > 61 | 30 > 35 | 108 > 114 | 73 > 88 | 11 |
| Lion stair landing | 88 > 143 | 112 > 149 | 74 > 122 | 136 > 136 | 72 > 115 | 3 |
| Purple elevator-5 connector | 114 > 131 | - | 46 > 69 | - | 47 > 51 | 1 |
| Grey French gallery | 148 > 142 | 70 > 101 | - | 98 > 110 | 112 > 120 | 9 |
| Marble stair hall | 100 > 137 | - | 116 > 26 | 57 > 79 | 84 > 104 | 5 |
| Skylight Gallery | 173 > 141 | 148 > 112 | 140 > 106 | 193 > 191 | 151 > 125 | 7 |
| Modern painting gallery | 133 > 144 | 144 > 158 | - | 106 > 113 | 110 > 115 | 6 |
| Stub: white sculpture gallery | 72 > 134 | - | 102 > 127 | - | 46 > 69 | 1 |
| Stub: modern adjoining gallery | 75 > 129 | - | 92 > 126 | - | 47 > 57 | 1 |
| Stub: Main Hall reveal threshold | 118 > 129 | - | 81 > 133 | - | 54 > 53 | 1 |
| Stub: Rockefeller reveal threshold | 108 > 135 | - | 123 > 156 | - | 58 > 58 | 1 |
| Stub: Skylight reveal threshold | 142 > 143 | - | 106 > 127 | - | 79 > 69 | 1 |

What it says:

1. Floors. Before, 72 to 173 (the Skylight Gallery 2.4 times the darkest stub). After, 129
   to 144 in every area, against the Hall's 143. The three lowest are stubs.
2. No area is without a lamp (before: no lamp list existed, and the playtest's light pass
   on `cb8a272e` reports none). Every catalogued work in the nine rooms that have works has a
   spot aimed at it (the pass lists none without).
3. The wall beside works is brighter than the wall away from them in all four rooms where
   both can be sampled (155/117, 61/35, 149/122, 112/106; the Hall is 74/53). In the other
   five rooms the hang is too dense to leave a metre of bare wall, so the pass cannot test
   it; the pools are in the pictures.
4. "Works" is the brightness of the photograph, not of the light. The Hall's floor reads 143
   and its paintings 79, so "works brighter than the floor" is not a test this build can
   pass without the dark rooms the owner turned down on 7 Oct; the pass prints the number
   and does not fail on it.

## Wall colour (VERIFIED)

A wall is judged against the skirting in the same picture: divide wall by skirting, channel
by channel. In the two SDR footage frames the wall is within 0.02 to 0.05 saturation of its
skirting (IMG_6343 78 s, grey gallery; 252 s, modern gallery, the wall a touch bluer than
the trim). The HDR clips' tone-mapped whites are compressed toward neutral, so the same sum
on them reads the wall warmer than it is; they are used for shape and for the look.

| Room | Floor | Wall | Skirting | Wall with the skirting made neutral | Hue | Saturation | Reads |
| --- | --- | --- | --- | --- | ---: | ---: | --- |
| Main Hall | 183,137,85 | 74,74,63 | 195,174,155 | 0.89, 1.00, 0.96 | 155 | 0.11 | slightly green grey |
| European gallery | 174,130,79 | 167,153,133 | 158,140,122 | 0.97, 1.00, 1.00 | 175 | 0.03 | faintly cool-green grey |
| Light Renaissance room | 173,128,77 | 162,147,130 | 139,120,103 | 0.92, 0.97, 1.00 | 203 | 0.08 | slightly blue grey |
| Dark medieval room | 166,128,86 | 65,60,62 | 97,81,69 | 0.75, 0.82, 1.00 | 221 | 0.25 | slate blue grey |
| Lion stair landing | 156,141,127 | 159,147,139 | 152,140,130 | 0.98, 0.98, 1.00 | 230 | 0.02 | neutral grey |
| Grey French gallery | 185,136,79 | 113,99,87 | 154,132,113 | 0.95, 0.97, 1.00 | 213 | 0.05 | faintly blue grey |
| Skylight Gallery | 176,137,83 | 118,111,109 | 129,118,107 | 0.90, 0.92, 1.00 | 225 | 0.10 | slightly blue grey |
| Modern painting gallery | 188,138,82 | 169,156,145 | 185,158,137 | 0.86, 0.93, 1.00 | 209 | 0.14 | slightly blue grey |
| Rockefeller | 181,138,88 | 125,108,89 | not sampled | - | - | - | see below |

Rockefeller has no clear stretch of skirting to sample; against the European gallery's
skirting its wall is 0.08 warm, and in the picture it is the darkest and most olive of the
pale rooms. The footage has it light grey-green. Not right yet.

## How works are lit, and what it costs

Every surface of a catalogued work is drawn unshaded at its own colours, with one brightness
per vertex computed at bake preparation from the spot aimed at that work: full on the face
it shows the room, down to 45% on faces turned away. No work takes lightmap texels. Before,
ten of the Renaissance room's sixteen works were lightmapped (14 cm texels on 10 to 30 cm
objects) and read as dark lumps; flat pictures were unshaded; frames were a third thing.
A mesh placed with `place_mesh()` is a work like any other and goes the same way.

1. Per frame, VERIFIED: the Renaissance room drew 245 calls on `cb8a272e` and 245 on the
   first bake of the rule (`d787f2c9`, which also has the trim branch's ceilings: 41,036 >
   41,280 triangles). On `0d3dc292` it draws 282, after the trim branch added furniture;
   the lighting adds no draw call. The only light node in the scene is the
   visitor's own lamp, before and after; the bakes keep no lamp nodes. Frame time on this
   shared GPU moved between 12 and 33 ms across runs with no change of mine, so it is not
   quoted.
2. Per frame, INFERRED: an unshaded vertex-colour surface costs less per pixel than the
   lightmapped surface it replaces.
3. In the pack, VERIFIED: `room.exr` 6.31 MB > 5.64 MB (flat works left the lightmap);
   `room.tscn` 11.63 MB > 12.29 MB, which is the per-vertex colours plus the trim branch's
   furniture, not separated.
4. In bake time, VERIFIED: 105 lamps bake in 1 to 7 minutes when the fills are spots (four
   bakes: 1:04, 1:01, 6:41, 6:01; the two slow ones ran while other builders were baking,
   and I have not separated that from the wider fill cone they also had). With all-round
   fills 107 lamps took 19:33 and 159 did not finish in the rebuild's 28 minutes.

## Nothing left behind by hidden works (VERIFIED on four walls)

With every work of a room hidden and its wall still drawn (Renaissance north, modern south,
Rockefeller north, European east), framed pictures and textiles leave only their pool of
light. On the first bake of the rule they left soft dark blobs: a mesh's shadow flag does
not stop it occluding in the bake, so flat wall works are now left out of the bake. The
modern gallery's two "smudges" of the room census are gone. A work standing on the floor
still casts: the European gallery's commode leaves its shadow on the wall behind it when
hidden, which only the inspection bug of review round 2 does.

## What was tried and dropped

1. The Hall's own lamp colours (`#ffe1b2`, `#ffd391`). Trim read tan (143,120,86) and pale
   paint cream; the Hall's daylight is what makes its skirting read (195,174,155).
2. Paints made bluer to cancel the warm lamps. Walls read mauve, 0.19 to 0.35 blue of their
   own trim.
3. Fills as all-round lamps half a metre under the ceiling: a glow on the ceiling over each,
   and a bake too slow for the rebuild.
4. Fills as 80-degree downlights: no glow, but the wall away from works fell to two thirds
   of the skirting.

## Not done, and not known

1. Rockefeller's wall is too dark and too olive (above).
2. Ceilings read dim and tan in the follow view: they take only what bounces off an orange
   floor. The footage's are white. Two bounces is what the bake allows in its time.
3. The marble stair hall's wall away from works samples 26. I have not looked at why; #276
   replaces that room.
4. The pool test cannot run in five rooms (no bare wall).
5. `FILL_TRIM` is measured, not derived: a new or changed room needs a bake, a reading of
   its floor, and a trim. The three new-room branches are not in this bake.
6. The Renaissance room's window shade (furniture branch) is the brightest thing in its
   room after the case tops; it does not clip. Whether it is too strong is for whoever
   looks at it beside IMG_6383.
7. Whether the wide fill cone or host load made two bakes take six minutes.
8. The Web export was not run; every picture is the desktop build on the Web renderer.
