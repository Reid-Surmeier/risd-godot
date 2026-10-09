# Placement by eye: footage against the draft, wall by wall (8 October 2026)

Each sheet: footage frames on top (clip and second in yellow), the unbaked draft room project
below, taken from about the same place with `eye_shot.gd` (this folder; absolute room-scene
points, x east, y up, z south; `list:` prints every catalogued work in a rectangle, `plan:` a
cut top view). The draft is the lead's integration draft copied to
`~/risd-godot-ingestion/collection-expansion/rebuild-placement-eye-copy/`; its sources were
byte-identical to this branch's. The footage camera's standpoint is not known, so a distance
along a wall is not read from these sheets: only wall, order, third of the wall, height band
and facing.

## Dark medieval room (IMG_6382) — nothing moved

| Wall | Work or piece | Footage | Draft | Agree |
|---|---|---|---|---|
| north | iron grille on its white platform | 12 s, 14 s: east of the portal, the platform's end against the pier, a label then the corner beyond | same; no wall label | yes |
| north | screen projection | 88 s: west of the portal | same | yes |
| north | 22.047 Taking of Saint Peter, 21.250 Mary Magdalene | 86 s: Magdalene nearer the corner, then 22.047, then the projection; eye height | same order, eye height | yes |
| east | 41.046, the stair door, 41.045 | 17, 22, 24.5, 27, 78 s: one apostle each side of the door on a shelf with a grey backplate; 41.045 between the door and the corner | same | yes |
| south | Head 59.131, Christ in Majesty 69.196, Crucifix 43.195, Saint Peter 20.254, St Anthony 16.243 | 80 s, east to west in that order; 30, 52, 58 s: each faces the room | same order, same facing | yes |
| west | Angel 37.114 | 60 s: south of the tracery doorway, facing the room, its label on the wall to its north | same | yes |
| west | 20.207 Madonna, 57.301 Virgin | 64, 70, 86 s: north of the doorway, the Madonna beside the doorway, the Virgin near the corner | same order; the Madonna stands about a door's width from the doorway | see below |
| floor | low paper case, tall case | 78, 80, 88, 96 s: low case mid-room in front of the crucifix, tall case east of it in front of the stair door | same | yes |
| tall case | Virgin and Child 15.108, reliquary 2020.55, monstrance 40.002, beaker 1992.051, pyx 30.011, Christ 2014.110, pax 52.002 | 104, 108, 112 s: the Virgin on the tall riser at the west side facing west, reliquary centre, monstrance east, beaker north-east, Christ on its wedge north, pax north-west | same | yes |

Not sure, left alone:

- **The west pair against the tracery doorway.** In 64 s the Madonna hangs about half its own
  width from the doorway; in the draft the gap is about 1.1 m. The room's west wall north of
  the doorway is 3.10 m in the plan and about 2.33 m in footage (placement-2026-10-08.md), and
  the pair was set from the corner with its measured 0.87 m spacing. Moving the pair 0.4 m south
  would halve the error at each end; moving the doorway is the room's plan. A decision.
- Distances along the south wall. In 80 s (ultra-wide, oblique) the relief looks nearer the
  crucifix than in the draft; without the camera's place that is not a reading.
- The labels (grille, apostles, panels) are filmed and not built; not placement.

## Lion stair landing (IMG_6387 0–46 s, frames turned upright) — nothing moved

One work, one sheet (`lion-landing-north.jpg`).

| Wall | Work or piece | Footage | Draft | Agree |
|---|---|---|---|---|
| north | the lion relief on its white mount | 2, 41, 42 s: right of the modern gallery's door, its far end close to the north-east corner, the lion walking left (toward the door), eye height, a vent above it | same | yes |
| north | the lion's label | 42, 43 s: on the wall between the door's casing and the mount | a blank block in the same place | yes |
| east | door to the white sculpture gallery | 2, 36–40 s: in the grey wall round the corner from the lion | same | yes |
| west | door to the medieval room | 44, 45 s: in the grey west wall; the medieval tall case stands on its axis | same | yes |

Only in footage: a cart of stacked black chairs by the stair rail (35 s); a label right of the
medieval door (44 s). Neither is a work.

## Modern painting gallery (IMG_6387 46–82 s, frames turned upright) — nothing moved

Two sheets: `modern-west-north-south.jpg` (47–62 s) and `modern-east-north-west.jpg` (64.5–77 s).
The clip pans the room clockwise from the entry door, so the order along every wall is filmed.

| Wall | Work or piece | Footage | Draft | Agree |
|---|---|---|---|---|
| south | Braque 48.248, Villon 70.058 | 52, 54.5, 57 s: beyond the entry door, Braque then Villon, Villon near the window corner, a label between them, eye height | same order and corner; no label | yes |
| east | window, Seated Woman 67.089 in its case, window | 62, 64.5, 67 s: the case on the pier between the windows, the figure turned to the room | same | yes |
| north | doorway, Cézanne 43.255, Matisse 57.037 | 69.5, 72, 74.5, 49.5 s: the doorway by the north-east corner, then Cézanne, then Matisse about a picture's width from the north-west corner | same | yes |
| west | Fauconnier 1995.043 | 47, 49.5, 77 s: fills the wall from the entry jamb, its foot under knee height | same | yes |
| floor | bench | 49.5 s: mid-room, long side along the Fauconnier wall | same | yes |

Not sure, left alone: where the Seated Woman's case stands between the two windows (64.5 s
shows it hard by the south window's casing, from an oblique place; the draft has it 0.25 m
north of the middle). `IMG_6343` 224–263 s, the second walk of this room, was not opened.

## European gallery (IMG_6384, 6385, 6386) — the west wall re-laid, one case deck turned

Sheets: `european-east-south.jpg`, `european-east-north.jpg`, `european-south.jpg`,
`european-west-south.jpg`, `european-across.jpg` (six frames that hold a floor case and a wall
at once, with the draft from the same places), `european-cases.jpg` (majolica deck and the north
group, after), `european-case-porcelain.jpg`; before the change: `european-west-north-before.jpg`,
`european-case-majolica-before.jpg`. The three east and south sheets were read against the draft
before the change and re-made after it without being opened again; nothing on those walls moved.

**What was wrong.** The real room is about 21.2 m long and the build's is 26.3.
`european_east_additions.gd` lays the east wall and the five floor pieces in by their fraction of
the room (every distance x 26.3/21.2). The west wall's south group, Fetti, Goltzius and Delacroix
were laid in at their real metres, unstretched. So each wall was right in itself and wrong against
what faces it, by up to 3.4 m, with 7.2 m of bare wall between the Guardi pair and the Delacroix:

| Footage | What it shows | Draft before | Draft after |
|---|---|---|---|
| 6386 1 s, 15 s | the majolica case ends just south of the Goltzius; the two Kussell prints hang behind its south half (6386 9 s) | the case stood centred on the Goltzius | as filmed |
| 6386 45.5 s | from the Canal view, the porcelain case is a few steps on, by the Guardi pair | 4 m further | 0.6 m past the pair |
| 6386 53–57 s, 6385 29.5–31 s | pair, wall text, Delacroix follow within the case's length; from the Delacroix the case is at hand and Reynolds, Mengs, Longhi stand behind it | case 1.5 m south of the Delacroix, pair 7.2 m from it | the Delacroix at the case's north end, the pair 2.6 m on |
| 6386 86–89 s | from between the Zompini prints and the textile case, the writing desk stands before the Crucifixion | from there it stood before the Longhi | as filmed |

**Moved** (all on the west wall, z in room metres, each distance from its end wall x 26.3/21.2):
knocker 55.091 25.10 → 24.38; Kussell 2024.17.5 24.00 → 23.01 and 2024.17.6 23.25 → 22.08;
Goltzius 61.006 22.01 → 20.54; Zompini 67.106.31 20.49 → 18.66 and 67.106.8 19.95 → 17.99; the
textile 85.075.6 with the glass case under it and its five vessels 18.63 → 16.35; Fetti 36.003
16.96 → 14.28; Tironi 42.042 15.44 → 12.39; the Guardi pair 24.508 and 53.115 14.02 → 10.63;
Delacroix 35.786 6.85 → 8.07; Piranesi 63.066.45 5.10 → 5.89; their label cards with them. Hang
heights untouched. The lamps follow the works (they are made from them at the bake).

**Majolica case deck** (6386 3.5, 6, 9, 12 s, 6384 31 s): filmed from the room side the mortar,
the bone casket and the jar stand along the wall side and the two plates and the roundel along
the room side; the draft had the two sides exchanged. All seven cards now stand at the same place
along the deck on the other side of its long axis (x → −x about the case's centre).

| Wall | Work or piece | Footage | Draft | Agree |
|---|---|---|---|---|
| east | Perseus 57.167, print 84.198.1032, Venus and Adonis 54.186, Adoration 21.482, Crucifixion 69.197, Cloth of Gold 46.256 | 6384 5–70 s, south to north in that order, eye height; 47 s: print then Perseus then the corner | same | yes |
| east | Longhi 34.1371, Mengs 57.281, Reynolds 53.349 | 6384 71–83 s; 6386 43 s from across the room | same | yes |
| east | Cover 37.009 on its panel, the platform, commode 2017.46 with the charger, Vigée 2025.86 | 6384 86–99 s, 6386 68 s: panel south, commode north of it on the same platform, the portrait beyond | same | yes |
| north | micromosaic 1990.060 over its wall case east of the door; Mrs. Wolff 42.072 west of it | 6384 101.5 s; 6385 0–6 s | same | yes |
| west, north end | dress 2000.103.3 in the corner, secretary, Piranesi, Delacroix | 6385 2–28 s, 6386 61–66 s | same order | yes |
| west | Guardi pair (Scuola over Ridotto), Tironi, Fetti, textile over its glass case, Zompini pair, Goltzius, Kussell pair, knocker | 6386 15–53 s, 6384 21–29 s | same order, now at the east wall's scale | yes |
| south | Risen Christ 16.237, Apollo 73.079 in its wall case, door, tabernacle 06.057 on its pedestal by the corner | 6384 1, 13, 16, 19, 36 s; 6386 98.5 s | same | yes |
| floor | River God, majolica case, writing desk, bench, porcelain case | 6384 36–41, 50.5 s; 6386 43, 79, 86 s | same order down the room; bench before the Longhi | yes |

Not sure, left alone:

- **Porcelain and silver case deck** (`european-case-porcelain.jpg`). 6385 34 s has the riser with
  the two figures at the far side, a plate leaning on each side of it, the armorial plate in front
  left and the silver basket in front right; 6386 57 s, from the west, has the riser beyond, a flat
  plate nearest and the coffeepot to the south. The draft's riser is at the north-east and the
  basket at the south-west. The two clips do not fix which side 6385 34 s was taken from.
- **The label stand on the east platform**: 6384 89 s shows it under the cover's north edge; the
  draft has it 1 m south of the cover's centre. One frame, oblique.
- **River God**: 6384 36 s looks at the south door with the god's case off to the left, not before
  the door; the draft has it 0.4 m east of the door's axis. It is a card of the front photograph;
  6384 41 s shows its back from the north-west, which a card cannot.
- In the footage the gilt casket 51.272 stands on the low riser at the majolica case's north end,
  the small dish and utensil beside it; the draft has four plain blocks on that riser. A work on
  another riser is the lead's call.
- Piranesi to the platform's end: 0.7 m in 6386 63.5 s, 1.4 m now (0.65 m before), the stretch.

## Rockefeller (IMG_6380 118–240 s) — nothing moved

Sheets: `rockefeller-north-west.jpg`, `rockefeller-south-east.jpg`, `rockefeller-east.jpg`,
`rockefeller-cases.jpg`. The clip enters from the purple connector and pans every wall twice.

| Wall | Work or piece | Footage | Draft | Agree |
|---|---|---|---|---|
| south | pink service in its wall case, sconce, door, sconce over the two Smirke watercolours | 125, 182–191, 236 s: east to west in that order; the case and the watercolours each a hand from the door's casing | same | yes |
| west | armchair under the silk length 44.226, writing table, settee under the portrait, Récamier bust on its pedestal, armchair in the corner | 131–143, 197, 200 s: south to north in that order, all on the platform; the bust turned to the room | same | yes |
| north | mirror, cabinet under the portrait, mirror, armchair | 146–158 s | same | yes |
| east | wallpaper 34.912, a label, the gold service case before the wall, the door to the connector | 160, 208–212 s | same order | see below |
| floor | central pedestal with the Vincennes pair | 122, 225, 228.5 s: mid-room, on the line from the connector door to the settee | same | yes |
| cabinet | three groups on top, three shelves | 152.25 s: riders and a standing figure on top; the two large birds on the middle shelf; figure, cow, figure below | same | yes |
| gold case | tureen between two plates at the wall side, square dishes, écuelle in the middle, baskets and the two cups at the room side | 164–173, 215–221 s | same; the two halves alike about the tureen, as filmed | yes |
| pink case | a tureen at each end, the raised dish behind the middle, shell dishes in front | 176.25, 179 s | same | yes |

Not sure, left alone:

- **The north-east corner.** 208 s has the wallpaper's mount about 0.3–0.6 m from the corner and the
  platform running to the corner under the armchair. The draft's mount is 1.4 m from the corner and
  its platform stops a metre short of the east wall. The wallpaper and the gold case stand right
  to each other (160, 210.25 s: mount, label, case), so moving the wallpaper alone would break
  that; moving both means moving a case. The room's shell is larger here than filmed.
- Which of the Vincennes pair stands on which side of the pedestal: too small in every frame.
- The two tureens of the pink service read larger against their case than in 176.25 s; a size.

## For whoever continues

Rooms left, in order: the grey French gallery (6380 0–50 and 80–118 s, 6343 0–82 s),
the Light Renaissance room (6383). The draft at
`~/risd-godot-ingestion/collection-expansion/rebuild-placement-eye/extension` matches this
branch's sources (rebuilt after the European change). `sheet.py` (this folder, beside a copy of
`eye_shot.gd`) makes a sheet in one call: footage seconds on top, draft shots or `plan` cuts below;
an overview strip's seconds run a second or two early, `-ss` before `-i` is exact. Rockefeller's
works come from `video-inventory.json` (room point = row position + (-1.95, 0, 1.44)); `list:`
prints only the nine tagged by an additions file. Per room: `list:<x0,x1,z0,z1>` with the room's bounds from
`modules/shell/collection_rooms/geometry.json` names every work and its place; shots are
`<out.png>:<camera>:<aim>:<fov>:<w>x<h>`. Do not un-hide what the build hides: the Hall's spare
surfaces stand across the medieval room. A camera inside a case photographs grey.
