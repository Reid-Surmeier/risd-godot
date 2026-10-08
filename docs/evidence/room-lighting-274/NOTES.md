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
