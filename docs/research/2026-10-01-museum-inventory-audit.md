# Museum inventory audit: the walkthrough footage against the build

2026-10-01. Read-and-compare only: no project file was changed, the engine was not run, no paid call was made.

## Answer first

**1. What is in the build, by room.** "Display objects" are artworks, each legible object in a case, furniture on display, benches. "Fixture kinds" are labels, wall texts, exit signs, vents, lighting track, door leaves, windows and the like, counted once per kind per room.

| Room | Display objects, present / seen | Fixture kinds, present / seen |
| --- | --- | --- |
| Grand Gallery (Main Hall) | 25 / 25 | 7 / 10 |
| Dark medieval room | 18 / 24 | 7 / 17 |
| Light Renaissance room | 19 / 19 | 8 / 13 |
| European gallery ("adjacent gallery") | 4 / 67 or more | 4 / 15 |
| Rockefeller | 53 / 58 | 6 / 12 |
| Purple elevator-5 connector | 0 / 0 | 4 / 9 |
| Grey French gallery | 3 / 10 | 5 / 14 |
| Lion stair landing | 1 / 2 | 5 / 12 |
| Modern painting gallery | 7 / 7 | 5 / 13 |
| **All built rooms** | **130 / 212** | **51 / 115** |

82 display objects seen in the footage are not in the build: 63 in the long European gallery, 7 in the grey gallery, 6 in the medieval room, 5 in Rockefeller, 1 on the landing. Of the 130 that are present, 5 are placeholders and 2 hang in the wrong place.

Three more filmed spaces are not rooms in the build at all, so nothing of theirs is present: the Skylight Gallery (7 display objects seen), the marble stair hall (2) and the auditorium (seating and a stage, no artworks). Their inventories are in section 3.

**2. The room that has not been integrated.** Three filmed spaces have no room in the build. My answer, as an inference: the owner most plausibly means the **Metcalf Auditorium** (`IMG_6378.MOV`, the whole three-minute clip). It is the only fully filmed room with nothing at all in `geometry.json`, not even a doorway stub. A session-memory record of 1 October (not a repository file) has the earlier agent listing the auditorium to the owner among the "unfinished parts of the goal". The runner-up is the **Skylight Gallery**, the double-height room with the grand piano and five modern works (`IMG_6379.MOV`, the whole clip), which the build reduces to a 2.0 × 1.6 m empty box behind the grey gallery's north door. Third is the marble stair hall behind the two Ionic columns (`IMG_6381.MOV`). All three are filmed well enough to build. Only the auditorium has no filmed connection to any other room. Section 3 has the detail.

**3. The ten most visible missing objects.**

| # | Object | Where it belongs | Why it is visible | Footage |
| --- | --- | --- | --- | --- |
| 1 | Crucified Christ, large wood figure | Medieval room, south wall | On the Hall's long axis: seen through the portal from the whole length of the Hall | 6382 38.5–41.5; 6344 169.5–178.5 |
| 2 | Rodin, *The Hand of God*, 23.005 | Grey gallery, centre, before the columns | Free-standing, on the axis of the purple connector | 6380 16.5–17.5, 36.5–39.5; 6381 31.5 |
| 3 | *St. Anthony Abbot Enthroned*, 16.243 | Medieval room, south wall, west end | Tall gold gabled panel, about a person's height | 6382 53.5–57.5 |
| 4 | Silver and porcelain case, 9 or more objects | European gallery, north end, on the floor | First thing ahead when entering from Rockefeller | 6385 30.5–37 |
| 5 | Crouching male figure in its case | European gallery, south end, on the floor | On the gallery's long axis; seen from the Renaissance room | 6384 34.5–40.5 |
| 6 | Vincennes river-god pair, 2017.74.31.1 and .2 | Rockefeller, central pedestal | The pedestal is built and stands empty in the middle of the room | 6380 223.5–226.5 |
| 7 | *Crucifixion*, 69.197 | European gallery, east wall | Large gold-ground panel, 1.13 × 1.44 m | 6384 62.5–68.5 |
| 8 | *Head of Christ*, 59.131, on its pedestal | Medieval room, south wall, east end | Beside the stair door, at eye height | 6382 28.5–32.5 |
| 9 | White dress in a tall glass case | European gallery, north-west corner | Tall case just inside the Rockefeller door | 6385 3.5–5.5 |
| 10 | *Angel of the Annunciation*, 37.114 | Medieval room, west wall, beside the tracery door | Painted wood figure on a pedestal | 6382 59.5–61.5 |

**4. The stairwell.** The real stair is one open-well stair: it leaves the landing along the west wall beside the medieval door, turns twice with winders and reaches the next floor along the east wall, and the flight coming up from below arrives on the east side beside the sculpture door. The build has two straight flights side by side on the west side that end in mid-air. Section 4 lists 14 differences.

## How to read this

**Build audited.** Checkout `consolidate-character-236`, HEAD `32d3ba8c`. Room content: `collection_rooms/remodel_room.gd`, the `collection_rooms/*_assets.gd` scripts, `collection_rooms/assets/catalogue-objects.json`, `collection_rooms/geometry.json` (none changed after 20:45). Main Hall: `modules/shell/prototype/gallery_walk4/walk4.gd` and `works.json`. Pictures: `build/museum-atlas/` (taken 20:47–20:49). Commit `e69dbfc3` (#238: sprint, jump, click-to-inspect, a playtest) landed during the audit; it changes no file under `collection_rooms/` and not `works.json`, so the room content is the same at both commits. `collection_rooms/remodel_room.gd` and its asset scripts differ from the earlier agent's last source only in file paths, the bake location and one guard line; they build the same objects. None of the 49 earlier prototype builds that kept a `geometry.json` contains a room that the current build lacks.

**Footage.** The ten clips of 29 September, `~/risd-godot-ingestion/collection-expansion/verified/IMG_6378.MOV` to `IMG_6387.MOV`, and for the Hall the earlier clip `~/risd-godot-ingestion/walkthrough/IMG_6344.MOV`. I looked at all 2,485 frames of the existing two-per-second survey of the ten clips as 24-frame sheets, at about 430 of them enlarged, at about 30 full-size frames for labels, signs and counts, and at every third frame of the two-per-second set of IMG_6344.

**Times.** `6382 38.5` means `IMG_6382.MOV` at 38.5 seconds. The matching survey frame is number 2 × seconds + 1, here `survey-2fps/IMG_6382/000078.jpg`. Appendix B says how to open one upright.

**Who says so.** The "Basis" column uses these words:

- **seen**: I saw the object in the footage myself. Every row in this report is seen unless it says otherwise.
- **repo**: the name or accession number comes from an earlier document in this repository (`image-work/collection-room-remodel/*.json`, `works.json`, `docs/research/collection-*.md`). I did not re-check the catalogue.
- **label**: I read the name off the wall label in a full-size frame. A reading, not a catalogue match.
- **look**: my own description; no identification exists.
- **inferred**: my reasoning, not something seen.

**Status.** *present*; *placeholder* (present, but a stand-in or a plain block); *wrong position*; *missing*. I did not measure positions. "Wrong position" is used only where the wall, the order along the wall or the rough distance along it disagrees with the footage.

**Walls.** North, south, east and west are the build's own directions (the Hall's portal end is south). They are not compass bearings.

## 1. Room-by-room inventory

### 1.1 Grand Gallery (Main Hall)

Source: `IMG_6344.MOV`, 179 s. Also seen through doors at 6382 1.5–9.5, 6380 98.5 and 6379 170.5. Identifications: repo (`works.json`).

| Wall | Works, in hanging order | Footage (6344) | Build |
| --- | --- | --- | --- |
| South (portal end), west of door | S2 Vanni 57.227 | 72–75 | present |
| South, east of door | S1 Veronese 56.096 | 33–37.5 | present |
| West, from the portal end | W1 Cossiers 23.332 · W2 Stom 56.177 · W3 Cuyp 62.019 · W4 van der Helst 60.009 · W5 *Charity* 57.157 | 76.5–102 | present (5) |
| West, continued | W6 Tiepolo 32.246 · W7 Ghezzi 44.161 · W8 Gascar 55.152 · W9 Wtewael 62.058 · W10 Pace del Campidoglio 60.107 | 103.5–135 | present (5) |
| North (far end) | N1 Hampden lady 42.283 · N2 Lawrence 60.039 | 136.5–139.5 · 145.5–148.5 | present (2) |
| East, from the far end | E1 Magnasco 63.061 · E2 Copley 18.264 · E3 Bourdon 51.506 · E4 Sarazin de Belmont 1987.056 | 150–168 | present (4) |
| East, continued | E5 Barbier-Walbonne 2003.105 · E6 Robert 37.104 · E7 Ruysdael 33.204 · E8 Passarotti 62.064 · E9 Collantes 18.096 | 39–61.5 | present (5) |
| Centre | two tufted benches | 22.5–31.5, 169.5–178.5 | present (2) |

| Fixture | Footage (6344) | Build |
| --- | --- | --- |
| Caption label right of every painting | 39–168 | placeholder (blank plates) |
| Wall text right of N1 | 138–139.5 | missing |
| Exit sign over the portal-end door | 64.5–67.5, 171–178.5 | present |
| Exit sign over the far door | 22.5–31.5 | present |
| High slot vents | 31.5, 63 | present |
| Low vent grilles in the wall under W1, W10, E9 and E1 | 76.5–79.5, 129–135, 39–40.5, 150–151.5 | missing (no geometry in `walk4.gd`) |
| Thermostat right of W10 | 130.5–133.5 | missing |
| Vault, skylight, cornice | 22.5–31.5 | present |
| Door casings, far door leaf | 22.5, 64.5 | present |
| Herringbone floor, baseboard | throughout | present |

### 1.2 Dark medieval room

Source: `IMG_6382.MOV`, 113 s. Wide views also at 6344 6–21.

| # | Object | Where | Footage (6382) | Identification | Basis | Build |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Gabled panel of a saint in red | North wall, west end | 72.5 | Lippo Memmi, *Mary Magdalene*, 21.250 | repo; label reads "Lippo Memmi" | present |
| 2 | Narrative gold panel | North wall | 74.5 | Jacopo di Cione, *The Taking of Saint Peter*, 22.047 | repo | present |
| 3 | Stone portal | North wall, centre | 1.5–9.5 | *Romanesque Portal*, 40.014 | repo | present |
| 4 | Wrought-iron scroll screen on a low white plinth | North wall, east of portal | 12.5 | none | look | present (two angled panels in the footage, one flat panel built) |
| 5 | Stone apostle on a bracket | East wall, north of stair door | 14.5–16.5 | *Apostle*, 41.046 | repo | present |
| 6 | Stone apostle on a bracket | East wall, south of stair door | 24.5–26.5 | *Apostle*, 41.045 | repo | present |
| 7 | Large bearded painted stone head on an octagonal pedestal | South wall, east end | 28.5–32.5 | *Head of Christ*, 59.131 | repo | **missing** |
| 8 | Stone relief slab of a seated draped figure on a pedestal | South wall | 34.5–36.5 | none | look | **missing** |
| 9 | Crucified Christ, wood, arms out, long tunic, no cross, hung high over a long low white platform | South wall, centre | 38.5–41.5, 47.5 | candidate 43.195 | repo (candidate only) | **missing** |
| 10 | Bust-length bearded stone figure with a staff, on a pedestal | South wall | 44.5–50.5 | none | look | **missing** |
| 11 | Tall gabled gold panel of an enthroned saint, on a projecting lighter backing | South wall, west end | 53.5–57.5 | *St. Anthony Abbot Enthroned*, 16.243 | repo | **missing** |
| 12 | Painted wood standing figure on an octagonal pedestal | West wall, south of tracery door | 59.5–61.5 | *Angel of the Annunciation*, 37.114 | repo | **missing** |
| 13 | Stone tracery over the doorway | West wall | 63.5 | *Tracery Arch*, 40.156.1 | repo | present |
| 14 | Gold Madonna panel | West wall, north of door | 66.5 | Bartolo di Fredi, *Madonna and Child*, 20.207 | repo | present |
| 15 | Kneeling Virgin, shaped panel | West wall, north end | 69.5 | Matteo di Giovanni, *Virgin of the Annunciation*, 57.301 | repo | present |
| 16–17 | Two mounted leaves in the low table case | Floor, west | 0–1.5, 96–99 | probable 82.190.2 and 51.020 | repo (probable) | placeholder (2 flat cards with a film crop) |
| 18–24 | Seven objects in the tall case: seated Virgin and Child, lidded ceramic vessel, monstrance, beaker, pyx, small Christ on a wedge, pax on a rod | Floor, east, on the stair-door axis | 100–113 | 15.108, 2020.55, 40.002, 1992.051, 30.011, 2014.110, 52.002 (three of them probable) | repo | present (7) |

| Fixture | Footage (6382) | Build |
| --- | --- | --- |
| Labels beside wall works, on pedestals and on case aprons (14 or more) | 16.5, 28.5, 66.5–74.5 | missing |
| Wall text panel, east wall, north end | 14.5 | missing |
| Lettered strip over the stair door (first line ends "MEDIEVAL GALLERY") | 20.25–20.75 | missing |
| Exit sign over the stair door | 20.5 | present |
| Stair-door leaves with push bars and closers | 18.5–22.5 | present |
| Fire horn and strobe | 24.5 | missing |
| Thermostat | 26.5 | missing |
| Low vents: two square grids under the north-wall panels, one louvre in the north-east corner | 72.5–74.5, 14.5 | present (1 of 3) |
| High slot vent, north wall | 1.5 | present |
| Ceiling track with spots | 77.5 | present (one rail) |
| Projecting pier with a black screen | 1.5 | present |
| Long low white platform under the crucifix | 38.5–47.5 | missing |
| Projecting backing panel behind St. Anthony | 53.5–57.5 | missing |
| Four pedestals (two octagonal, two rectangular) | 28.5–50.5, 59.5 | missing |
| Security dome, ceiling detector | 12.5, 77.5 | missing |
| Floor outlets at the stair-door threshold | 22.5 | missing |
| Herringbone floor, dark walls, flat ceiling, baseboard | throughout | present |

### 1.3 Light Renaissance room

Source: `IMG_6383.MOV`, 73 s. Identifications: repo (the 18-slot ledger). All 18 slots have an object in the build; all are prototypes.

| # | Object | Where | Footage (6383) | Identification (repo) | Build |
| --- | --- | --- | --- | --- | --- |
| 1 | Burgundy velvet in a white hooded mount | South wall, east | 6.5 | *Velvet Cover*, 23.307X | present |
| 2 | Tapestry of two woodcutters | South wall, west | 9.5–12.5, 68.5 | *The Woodcutters*, 29.280 | present |
| 3 | Madonna with two female saints, dark frame | West wall, south | 14.5 | *Madonna and Child with Saint Barbara and Saint Catherine*, 58.196 | present |
| 4 | Polychrome figure with hat, cape and dog, on a plinth under a tall hood | West wall, before the window | 17.5–20.5, 70.5 | *Saint Roch*, 21.398 | present |
| 5 | Small wood Pietà in a wall case | West wall, north | 23.5 | Riemenschneider, *Pietà*, 59.128 | present |
| 6 | Open gold triptych in a wall case | North wall, west of door | 28.5–30.5 | Lippo di Benivieni, 2021.131 | present |
| 7 | Madonna in a tabernacle frame | North wall, east of door | 37.5 | Perugino, 16.236 | present |
| 8–13 | Case A: man praying, woman in white headdress, ivory diptych, silver book cover on chains, open emblem book, painted drug jar | East wall, north of tracery door | 40.5–49.5 | 45.042, 34.861, 22.201, 34.016, 2023.17, 35.713 | present (6) |
| 14–18 | Case B: two profile plates, small gilt roundel, leaded-glass roundel, enamel plaque | East wall, south of tracery door | 4.5, 52.5–56.5 | 46.391, 57.302, 51.105, 2017.29, 34.024 (probable) | present (5) |
| 19 | Grey tufted bench on dark legs | Centre | 62.5 | none | placeholder (plain black slab) |

| Fixture | Footage (6383) | Build |
| --- | --- | --- |
| Labels on case aprons, beside wall works, on platform risers (about 12) | 9.5–12.5, 23.5, 37.5, 43.5 | placeholder (blank cards) |
| Wall text, title ending "…and Meaning", north wall | 34.5 | missing |
| Lettered strip over the north door | 62.5, 72.5 | missing |
| Slot vent above the north door | 62.5, 72.5 | present |
| Exit sign by the tracery door | 2.5, 66.5 | missing |
| North door leaves, open into this room | 32.5, 62.5 | present |
| Pointed white plaster recess holding the tracery on this side | 2.5, 66.5 | placeholder (plain rectangular opening) |
| Shuttered window and sill | 60.5, 70.5 | present |
| Low white platform under the textiles | 6.5–12.5, 60.5 | present |
| Ceiling track with spots | 60.5–64.5 | present |
| Thin floor frames under the four wall cases | 23.5, 28.5, 40.5, 54.5 | missing |
| Two security domes | 60.5, 64.5 | missing |
| Straight oak floor, grey walls, flat ceiling, baseboard | throughout | present |

### 1.4 European gallery (the long "adjacent gallery")

Sources: `IMG_6384.MOV` (from the south end), `IMG_6385.MOV` (north end), `IMG_6386.MOV` (west wall, ceiling, both ends). The west wall carries the secretary; the east wall is the one shared with the Hall. The build has four works, two plain piers and the south door leaves, and nothing else.

| # | Object | Where | Footage | Identification | Basis | Build |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Chalk drawing of a woman's head in profile | North end wall, west of door | 6385 0.5–1.5, 7.5 | Thomas Lawrence; title looks like "Mrs. Wolff, ca. 1815" | label | missing |
| 2 | Large painted roundel in an acrylic box (earlier file: stained glass) | North end wall, east of door | 6384 101.5–102.5 | none | look | missing |
| 3 | Wall shelf case below the roundel, 6 or more small objects | North end wall, east of door | 6384 101.5–103.5 | none | look | missing |
| 4 | White long-sleeved dress on a black mannequin, tall glass case on a platform | North-west corner | 6385 3.5–5.5 | none | look | missing |
| 5 | Drop-front secretary on a white platform | West wall | 6385 10.5–21.5 | 80.106 | repo | present (no platform) |
| 6 | Black-framed etching of an Egyptian-style wall design | West wall | 6385 22.5–24.5; 6386 64.5 | first label line looks like "Giovanni Battista Piranesi" | label, low confidence | missing |
| 7 | Arab horsemen, carved gilt frame | West wall | 6385 26.5–28.5 | Delacroix, 35.786 | repo | present |
| 8 | Domed church front with steps and a crowd, upright | West wall, upper of a stacked pair | 6386 46.5–51.5 | Francesco Guardi, *Scuola di San Marco with Loggia Erected for Benediction of Pope Pius VI…*, ca. 1782 | label | missing |
| 9 | Dark hall with a masked crowd, wide | West wall, lower of the pair | 6386 46.5–51.5 | second entry on the same label: *Main Salon in the Ridotto, Venice* | label | missing |
| 10 | Venice canal view | West wall | 6386 36.5–38.5 | label not legible | look | missing |
| 11 | Christ with angels, ribbed gilt frame | West wall | 6386 30.5–34.5 | Fetti, 36.003 | repo | **wrong position** (built about 7 m from the north end; the footage puts it near the middle) |
| 12 | Embroidered panel: vase of flowers, parrots, scroll border, in a white mount | West wall | 6386 24.5–28.5 | none | look | missing |
| 13 | Wall pedestal case under no. 12, five objects: stoneware jug with silver mounts, tall covered glass goblet, small wine glass, blue glass bowl with gilt handles, dark metal cup | West wall | 6386 24.5–28.5 | none | look | missing |
| 14 | Two upright black-framed etchings | West wall | 6386 20.5–22.5 | none | look | missing (2) |
| 15 | Christ on the cold stone, black and gilt frame | West wall, southern quarter | 6386 16.5–18.5 | Goltzius, 61.006 | repo | **wrong position** (built at mid-gallery; the footage puts it beside the majolica case near the south end) |
| 16 | Two wide black-framed prints, large white mounts | West wall, south end | 6384 26.5–28.5 | none | look | missing (2) |
| 17 | Dark bronze ornamental relief in an acrylic wall case | West wall, by the south-west corner | 6384 24.5 | none | look | missing |
| 18 | Carved pale stone tabernacle on a tall pedestal | South end wall, west of door | 6384 16.5–20.5 | Domenico Gagini, *Tabernacle*, 06.057 | repo | missing |
| 19 | Small gilt standing figure in a wall case | South end wall, east of door | 6384 0.5–2.5 | "Northern Italian (circle of Benvenuto Cellini), *Apollo*, ca. 1540" | label | missing |
| 20 | Small Risen Christ in a gilt architectural frame | South end wall, east end | 6384 0.5–2.5 | Previtali, 16.237 | repo | missing |
| 21 | Perseus on a winged horse, Andromeda at the rock, sea monster | East wall, south end | 6384 6.5 | "Giuseppe Cesari, called Cavaliere d'Arpino", *Perseus and Andromeda* | label | missing |
| 22 | Black-framed landscape engraving | East wall | 6384 8.5 | looks like "After Pieter Bruegel I, *River Landscape with Mercury Abducting Psyche*" | label, medium confidence | missing |
| 23 | Large mythological scene: reclining nude, putti, cloud | East wall | 6384 43.5, 54.5 | none in the repo; the composition is that of Poussin's *Venus and Adonis* | look; inferred | missing |
| 24 | Adoration of the Magi, panel in a gilt Gothic frame with openwork cresting | East wall | 6384 57.5–59.5 | label title begins "The Ado…" | label, partial | missing |
| 25 | Gold-ground Crucifixion with a red banner | East wall | 6384 62.5–68.5 | *Crucifixion*, 69.197 | repo | missing |
| 26 | Cream and gold embroidered textile in a white mount | East wall | 6384 69.5 | candidate 46.256 | repo (candidate only) | missing |
| 27 | Tea scene: woman in white at a table, maid, two men, dog | East wall | 6384 71.5–73.5 | none | look | missing |
| 28 | Young man in a brown coat with an open book, shell-crested gilt frame | East wall | 6384 75.5–77.5 | none | look | missing |
| 29 | Small group of men in eighteenth-century dress, one with a cello | East wall | 6384 79.5–84.5 | none | look | missing |
| 30 | Red textile with a central medallion and floral border, hung on a full-height white display panel that stands on a white platform | East wall, toward the north end | 6384 86.5–88.5; 6386 67.5–68.5 | none | look | textile missing; panel is a placeholder (two plain piers) |
| 31 | Bombé commode with gilt mounts and a marble top, on the white platform | East wall, north end | 6384 90.5–95.5; 6386 67.5 | none | look | missing |
| 32 | White painted plate in an acrylic box on the commode | East wall, north end | 6384 90.5–95.5 | none | look | missing |
| 33 | Man in a pink coat holding a brush | East wall, north-east corner | 6384 97.5–99.5 | none | look | missing |
| 34 | Floor case, 9 or more objects: pierced silver basket with handle, three armorial porcelain plates, two porcelain figures and a small covered pot on a riser, silver coffee pot, small teapot | Floor, north end | 6385 30.5–37 | none | look | missing |
| 35 | Black bench | Floor, middle | 6386 42.5 | none | look | missing |
| 36 | Floor case: inlaid table cabinet and a flat inlaid board | Floor, centre | 6386 83.5–84.5 | none | look | missing (2) |
| 37 | Floor case, 10 or more objects: bronze mortar and pestle, six-sided inlaid lidded box, blue-and-white two-handled jar, two maiolica plates, small gilt roundel, gilt relief casket, small brass dish, three small metal objects | Floor, by the west wall, south end | 6386 0.5–14.5; 6384 30.5–32.5 | none | look | missing |
| 38 | Crouching muscular bearded male figure, terracotta colour, on a grey pedestal under a hood | Floor, south end | 6384 34.5–40.5 | none | look | missing |

Count: 35 single objects (rows 14 and 16 are two each) plus at least 32 objects inside the five multi-object cases (rows 3, 13, 34, 36, 37) gives at least 67. Present: 4.

| Fixture | Footage | Build |
| --- | --- | --- |
| Labels (about 35) | throughout | missing |
| Four wall texts, one titled "Unearthing the Past" | 6385 29.5 (the same one at 6386 53.5); 6386 20.5; 6384 22.5, 57.5 | missing |
| Exit sign over the north door | 6386 66.5 | missing |
| Exit sign over the south door | 6384 12–14.5; 6386 96.5 | missing |
| North door: panelled reveal with a folded leaf | 6385 0.5–1.5 | placeholder (reveal built, leaf not) |
| South door: two leaves open into the Renaissance room | 6386 100.5–104.5 | present |
| White platforms under the dress case, the secretary, and the commode with its panel | 6385 3.5–21.5; 6384 86.5–95.5 | missing |
| Projecting white display panel on the east wall | 6384 86.5–88.5 | placeholder (two plain piers; I saw one panel) |
| Low vents: three square grids on the east wall, a louvre in the south-east corner, one on the north end wall | 6384 5, 6.5, 71.5–73.5, 97.5, 101.5 | missing |
| High slot vents | 6386 67.5; 6384 86.5 | missing |
| Thermostat | 6384 5 | missing |
| Ceiling tracks with spots | 6386 66.5–81.5 | missing |
| Security domes | 6386 67.5–68.5; 6384 12 | missing |
| Thin floor frame under the roundel case | 6384 101.5 | missing |
| Floor, walls, baseboard | throughout | present |

### 1.5 Rockefeller

Source: `IMG_6380.MOV` 120–240 s. Identifications: repo.

| # | Object | Where | Footage (6380) | Identification (repo) | Build |
| --- | --- | --- | --- | --- | --- |
| 1 | Bookcase with painted ovals | North wall, centre | 144–156 | 2017.74.9 | present |
| 2–21 | 20 ceramic figures and vessels: 3 on top, 7 + 5 + 5 on the shelves (counted on the full-size frame at 152.25) | On the bookcase | 152.25 | 2017.74.14 to .29 and .32 | present (20) |
| 22–23 | Two gilt mirrors | North wall, either side of the bookcase | 142.5–144, 156, 208 | 2017.74.4.2 and .4.1 | present (2) |
| 24 | Portrait of a woman in a lace shawl | North wall, above the bookcase | 145.5, 152.25 | Constable, *Mrs. Edwards*, 58.197 | present |
| 25–26 | Two wavy-back armchairs | North wall, outer ends | 142.5, 156–157, 208 | 2017.74.7.1 and .7.2 | present (2) |
| 27 | Floral settee | West wall | 136.5, 198.5–200 | 2017.74.5 | present |
| 28 | Portrait of a young man in a black hat | West wall, above the settee | 136.5 | Romany, *Portrait of the Dancer, Auguste Vestris*, 2009.9 | present |
| 29 | Marble bust on a white plinth | West wall, north | 139.5–142 | Chinard, *Madame Récamier*, 37.201 | present |
| 30 | Dark armchair with interlaced loops in the back | South-west corner | 130.5–134.5, 193.5–195.5 | 2017.74.12 (platform label reads "Robert Manwaring … Armchair, ca. 1760") | present |
| 31 | Half-round table on four curved legs | West wall, between chair and settee | 130.5, 136.5 | *Writing Table*, 2017.74.8 | placeholder (box top on four straight legs) |
| 32 | Brown needlework textile in an acrylic-boxed white mount | West wall, above the chair and table | 130.5–136.5, 195.5 | none | **missing** |
| 33–34 | Two stacked landscape prints, gilt frames, cream mounts | South wall, west of the door, under the sconce | 130.5–132.5, 187.5–191.5 | none | **missing** (2) |
| 35–36 | Two gilt wall sconces | South wall, either side of the door | 125.5, 189.5–191.5, 236.5 | 2017.74.6.3 and .6.4 | present (2) |
| 37 | Wallpaper panel in a white mount | East wall, north | 159.5–160.5, 210.25 | *Arabesque Wallpaper*, 34.912 | present |
| 38–49 | Gold service, 12 pieces in a case on a solid pedestal | East wall | 160.5–174, 166.25 | 2017.74.38 group | present (12) |
| 50–56 | Pink service, 7 pieces in a wall-hung case | South wall, east of the door | 123–127.5, 176–179.5 | 2017.74.39 group (label reads "Worcester Porcelain Company … Dragons-in-Compartments Dinner Service, ca. 1810") | present (7) |
| 57–58 | Two white biscuit porcelain figure groups on the central pedestal | Centre | 123.5, 223.5–226.5 | Vincennes, *Neptune* and *Amphitrite as River Deity*, 2017.74.31.1 and .2 | **missing** (2); the pedestal is built and empty |

The pink case in the footage is a deep white box on the wall with thin rod legs down to a thin frame lying on the floor; the build has a thin tray on four legs. I count it as present.

| Fixture | Footage (6380) | Build |
| --- | --- | --- |
| Labels: wall labels, sloped blocks on the platform, case labels (about 14) | 132.5–136.5, 152.25, 166.25, 177.5, 193.5 | missing |
| Wall text "The Artist's Profession", south wall, east | 127.5, 180.5 | missing |
| Lettered strip over the south door | 236.5 | missing |
| Slot vents | 223.5, 236.5 | present |
| Exit sign over the east door | 238.5 | missing |
| South door: panelled reveal with a folded leaf | 130.5–132.5, 187.5 | placeholder (reveal built, leaf not) |
| East door casing | 174.5 | present |
| White platform along the west and north walls | 130.5–136.5, 152.25 | present |
| Ceiling track loop with spots | 223.5, 234.5 | present (as short rails) |
| Thin floor frame under the pink case | 125.5–127.5, 177.5 | missing |
| Security domes, ceiling detector | 223.5 | missing |
| Straight oak floor, walls, baseboard | throughout | present |

### 1.6 Purple elevator-5 connector

Source: `IMG_6380.MOV` 102–104.5, 118–122.5, 240–254.5. No artworks.

| Fixture | Footage (6380) | Build |
| --- | --- | --- |
| Elevator doors with a large "5", purple wall | 120–122.5, 250.5–251 | present |
| Call button panel | 120.5–121.5 | missing |
| Black wall opposite | 102.5–104.5, 240–246.5 | present |
| Blue-lit wayfinding screen on the black wall | 9.5, 100.5, 240–244 | missing |
| Black panelled double doors with a brass knob | 100.5, 240–246.5 | missing |
| Red fire-alarm pull station | 100.5, 252–254.5 | missing |
| Three recessed ceiling lights | 102.5–104.5 | missing |
| Cased openings at both ends | 102.5, 118 | present |
| Boards along the corridor | 102.5 | present |

### 1.7 Grey French gallery

Source: `IMG_6380.MOV` 0–50 and 80–118. Also 6379 170.5–177.5 and 6381 20.5–31.5, 84.5.

| # | Object | Where | Footage (6380) | Identification | Basis | Build |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Two horses and a cart under a stone arch | West wall, next to the connector door | 5.5–8 | "Théodore Géricault, *A Cart Loaded with Kegs*" | label | **missing** |
| 2 | Forest with a pale cliff | West wall, north | 2.5 | Courbet, *Jura Landscape*, 43.571 | repo | present |
| 3 | Dark stormy landscape with sheep | North wall, first after the wall text | 19.5–22.5 | "Edward Mitchell Bannister, *Landscape with Shepherdess, Sheep, and Cows*" | label | **missing** |
| 4 | Wide overcast landscape | North wall | 24.5–26.5 | Daubigny, *Landscape*, 73.120 | repo | **missing** |
| 5 | Small river view | North wall, east | 28.5–30.5 | Corot, 24.089 | repo | present |
| 6 | Ruined towers on a hill | South wall, east | 85.5–87.5 | Villeneuve, *View of a Roman Aqueduct, near Tivoli*, 1998.35 | repo | **missing** |
| 7 | Waterfalls and a hill town | South wall | 90.5–92.5 | Bertin, *Tivoli*, 56.214 | repo; label reads "Jean-Victor Bertin" | present |
| 8 | The Colosseum | South wall, next to the Hall door | 94.5–96.5 | Pannini, *The Colosseum*, 56.094 | repo | **missing** |
| 9 | Small low-horizon landscape, bronze-gilt frame | On the pier between the Hall door and the connector door | 100.5–105.5 | none | look | **missing** |
| 10 | White marble: a hand holding a rough block, on a low white plinth | Centre, before the columns, on the connector axis | 16.5–17.5, 36.5–39.5 | Rodin, *The Hand of God*, 23.005 | repo | **missing** |

| Fixture | Footage (6380) | Build |
| --- | --- | --- |
| Label beside each painting, label on the Rodin plinth | 2.5–8, 21.5, 85.5–96.5 | placeholder (blank cards on the three built paintings) |
| Wall text east of the piano door | 14.5; 6379 177.5 | missing |
| Hanging wires from a rail above every painting | 2.5–8, 85.5–96.5 | missing |
| Exit sign over the piano door | 14.5 | missing |
| Piano door leaf | 0.5, 14.5 | present |
| Hall door: panelled reveal with folded leaves | 98.5–100.5 | present |
| Two columns with Ionic capitals, end pilasters, beam | 16.5–17.5, 35.5 | present |
| Dentil cornice on the beam | 35.5, 44.5 | missing |
| Grey stone threshold band under the columns | 31.5, 43; 6381 0.5 | missing |
| Low vents: a louvre and a square grid on the south wall | 80–83, 85.5–87.5 | missing |
| High slot vents, south wall | 37.5 | missing |
| Ceiling tracks with spots | 16.5, 108–116 | missing |
| Security domes | 12.5, 100.5 | missing |
| Herringbone floor, grey walls, baseboard | throughout | present |

### 1.8 Lion stair landing

Source: `IMG_6387.MOV` 0–46 and 82–85. Also 6382 18.5–22.5 and 6344 0–6. The stair itself is section 4.

| # | Object | Where | Footage (6387) | Identification | Basis | Build |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Blue glazed-brick lion in a wide white frame | North wall, east of the modern door | 0.5–4, 10–11, 41–42.5 | *Panel with Striding Lion*, 34.652 | repo | present |
| 2 | Black wheeled rack of folding chairs, parked at the balustrade | South edge of the landing | 6–7; 6382 20.25; 6344 3 | temporary equipment | look | missing |

| Fixture | Footage (6387) | Build |
| --- | --- | --- |
| Small label right of the lion | 41 | missing |
| Tall grey text panel between the modern door and the lion | 10–11, 42.5 | missing |
| Level sign "5" with a directory, beside the medieval door | 7–8, 44.5 | missing |
| Wall text beside the medieval door | 9, 13 | missing |
| Fire strobe, pull station and a white access panel beside the sculpture door | 5 | missing |
| Slot vents above the lion wall | 10–11, 42.5 | present (1 of 2) |
| Cornice | 5–12 | present |
| Flat ceiling with a track, spots and a detector | 8–12 | missing (the landing has no ceiling) |
| Three doorways with their leaves | 5, 8, 10 | present |
| Floor of large pale grey and beige blocks in a pinwheel pattern | 5–12, 42.5–45.5 | placeholder (warm oak basket-weave) |
| Stair | see section 4 | placeholder |
| Security domes | 0.5–4 | missing |

### 1.9 Modern painting gallery

Source: `IMG_6387.MOV` 46–82. Identifications: repo.

| # | Object | Where | Footage (6387) | Identification (repo) | Build |
| --- | --- | --- | --- | --- | --- |
| 1 | Very large crowded Cubist scene | West wall | 47.5–49.5, 77.5–80.5 | Le Fauconnier, *Mountaineers Attacked by Bears*, 1995.043 | present |
| 2 | Still life with a green pumpkin | North wall | 73.5–74.5 | Matisse, 57.037 | present |
| 3 | River landscape | North wall | 70.5–72.5 | Cézanne, 43.255 | present |
| 4 | Gilt seated figure in a case on a pedestal | East wall, between the windows | 51.5, 59.5–68 | Duchamp-Villon, *Seated Woman*, 67.089 | present |
| 5 | Cubist still life with a newspaper | South wall | 52.5–54.5 | Braque, 48.248 | present |
| 6 | Oval head in a white box frame | South wall, toward the windows | 55.5–57.5 | Villon, 70.058 | present |
| 7 | Grey tufted bench on dark legs | Centre | 47.5–50.5 | none | placeholder (plain black slab) |

| Fixture | Footage (6387) | Build |
| --- | --- | --- |
| Labels beside the six works and beside the far doorway | 53.5, 56.5, 69.25–71.5, 73.5, 77.5 | missing |
| Wall text right of the entry | 81.5, 84.5 | missing |
| Exit sign over the entry, inside | 82.5–84.5 | missing |
| Entry leaves with push bars | 46.5, 82.5 | present |
| Three low vent panels: one on the west wall, one each side of the entry | 47.5–48.5, 81.5–84.5 | missing |
| High vent above the large painting | 46.5–47.5 | missing |
| Two sash windows with blinds, sills and panelled aprons | 51.5, 58.5 | present |
| Far doorway casing | 69.5 | present |
| Lettered strip over the far doorway (not legible) | 68.5–69.5 | missing |
| Ceiling track loops with spots | 47.5–50.5 | present (three straight tracks) |
| Stone threshold with two floor outlets | 46.5–47.5 | missing |
| Security domes | 48.5, 52.5 | missing |
| Floor, walls, ceiling, baseboard | throughout | present |

## 2. Counts and missing lists, most visible first

The counts are in the table at the top. The missing display objects, room by room, ordered by how easily a visitor would notice the gap:

| Room | Present / seen | Missing, most visible first |
| --- | --- | --- |
| Grand Gallery | 25 / 25 | Nothing. Fixtures only: low vent grilles, the wall text by N1, the thermostat. |
| Dark medieval room | 18 / 24 | Crucified Christ · St. Anthony Abbot 16.243 · Head of Christ 59.131 · Angel of the Annunciation 37.114 · bust-length figure · stone relief |
| Light Renaissance room | 19 / 19 | Nothing. Fixtures only: wall text, exit sign, door strip, floor frames. |
| European gallery | 4 / 67+ | Floor: silver case, crouching figure case, cabinet case, majolica case, bench · East wall: Crucifixion 69.197, mythological scene, Perseus and Andromeda, red textile panel, commode and plate, tea scene, portrait with book, Adoration, gold textile, genre scene, artist portrait, Bruegel print · West wall: dress case, Guardi pair, canal view, floral textile and glass case, Piranesi print, two etchings, two prints, bronze relief · End walls: Tabernacle 06.057, Apollo case, Previtali 16.237, roundel and small-object case, Lawrence drawing |
| Rockefeller | 53 / 58 | Vincennes pair on the central pedestal · brown textile · two stacked prints |
| Purple connector | 0 / 0 | No objects. Fixtures: screen, black double doors, call button. |
| Grey French gallery | 3 / 10 | Rodin 23.005 · Géricault cart · Pannini 56.094 · Villeneuve 1998.35 · Daubigny 73.120 · Bannister · pier landscape |
| Lion stair landing | 1 / 2 | Chair rack (temporary). Fixtures: sign "5", text panel, the stair itself. |
| Modern painting gallery | 7 / 7 | Nothing. Fixtures only: labels, exit sign, vents. |

## 3. The spaces that are not integrated

The build has four doorway stubs labelled "threshold study limit". Each is an empty box with oak boards and plain walls. Nothing beyond the doorway is modelled.

| Stub in the build | What the footage shows beyond the doorway | How much is filmed | Enough to build? |
| --- | --- | --- | --- |
| Ionic marble-stair stub, 1.6 × 6.0 m behind the columns | A marble stair hall on this floor: pale marble floor in a large diagonal checker, an Art Nouveau carved chimneypiece about 3 m tall with a mirror and green tiles, a straight marble flight of about 14 steps, two quarter-turns of winders past a tall three-part window, an upper landing with a balustrade round the well, three doorways and a blown-glass chandelier. On the hall's south side: a round-arched niche with a stair going down, and a lit passage to a further gallery. | 6380 45.5–82.5; all of 6381 (99 s). Every side of the hall, every flight, the upper landing. | **Yes**: the hall, the stair and the upper landing. Not the rooms off the upper landing, the passage gallery or the stair down. |
| Piano-stair stub, 2.0 × 1.6 m behind the grey gallery's north door | A black landing with an iron balustrade, then a black stair down to a double-height skylit room one floor below. A strip over its elevator reads "SKYLIGHT GALLERY" (full-size frames 6379 8.0–9.4). In it: a black grand piano and bench, five modern works high on the walls, elevator "4" with the same purple reveal as elevator "5", a wayfinding screen, an exit double door to a dark room, a closet door, a small vestibule. Two gridded laylights, dentil cornice. | All of 6379 (182 s), from both levels, all four walls and the ceiling. | **Yes**, completely. Not the dark room or the vestibule beyond their doors. |
| White sculpture gallery stub, 1.5 × 2.0 m east of the landing | Pale blue walls; a large round white stepped plinth with five or more marble heads and torsos on pedestals; two tall arched windows on the left; a row of small white-mounted reliefs on the back wall; two brown panels on the right. | 6387 0.5–5 and 36–39.5, through the open door only, about 12 survey frames. | **No.** One viewing direction. Enough to dress the stub as a view, not a walkable room. |
| Modern adjoining gallery stub, 1.3 × 1.6 m | The same oak boards and grey walls; two or more blinded sash windows on the garden side; a gilt-framed portrait of a figure in a pale dress between them. | 6387 59–69.5, through the doorway, about 8 frames. | **No.** |

Spaces seen in the footage that `geometry.json` does not have at all:

| Space | What the footage shows | Enough to build? |
| --- | --- | --- |
| **Metcalf Auditorium** (the earlier agent's identification from a museum photograph) | All of 6378 (180 s). A raked hall with about 13 rows of fixed seats with maple backs, maple wall panels, a raised maple stage with a lectern, speakers and a lighting bar, side doors with exit signs, a side lobby with steps and blue chairs, a rear aisle with black slat benches and a booth window, a rear ramp with a rail. No artworks. The clip ends pushing through an exit door into a bright white lobby. | **Yes** as a room. **No filmed connection** to any gallery. |
| Gallery beyond the lit passage off the marble stair hall | 6380 48.5–50.5, 70–72; 6381 93.5. A short passage with two cased openings, then a room with grey walls, an oak floor, a row of three or more small gilt-framed pictures and a framed figure painting. Not recorded in any earlier inventory. | No. |
| Three rooms off the marble stair's upper landing | 6381 37.5–64.5. A warm-lit gallery of floor cases with a sign on a post; a lit corridor; double doors with an exit sign. | No. Thresholds only. |
| Rooms off the Skylight Gallery | 6379 22.5, 74.5, 105.5–112.5. A dark room behind the exit doors; a vestibule with an arched niche and steps down. | No. |
| The lion stairwell's other floors | 6387 15–34.5. The floor below (dark floor, stacked chairs) and the balcony above, seen from this landing. | No. |

### 3.1 What is in the three spaces that can be built

None of this is in the build. Every identification is my own description; the repository has none for these objects.

**Skylight Gallery** (`IMG_6379.MOV`):

| Object or fixture | Where | Footage (6379) |
| --- | --- | --- |
| Black grand piano, lid shut, and a black tufted piano bench | Lower floor, in a corner | 3.5, 13.5, 105.5 |
| Large tan monochrome square canvas | High on the wall above the upper landing | 16.5, 38.5, 42.5, 127.5 |
| Large pale-teal many-sided shaped canvas | High, on the next wall | 13.5, 46.5, 105.5, 127.5 |
| White square panel with a black scalloped loop drawn on it | High, above the exit doors | 19.5, 46.5, 133.5 |
| Large painting: a heap of drawn fragments on a yellow ground under a pale blue sky | High, right of the white panel | 6.5, 19.5, 133.5, 157.5 |
| White grid relief with a green edge | High, by the upper stair | 6.5, 49.5, 137.5 |
| Elevator "4": cream doors, purple reveal, white casing, strip reading "SKYLIGHT GALLERY" | Lower floor | 8.0–9.4 |
| Wayfinding screen and a grey directory plaque | Left of the elevator | 6.5–8.5 |
| Exit double door with push bars, to a dark room | Lower floor | 105.5–112.5 |
| Closet door with a louvre; cased opening to a vestibule with an arched niche and steps down; fire strobe and pull stations | Under the upper landing | 22.5, 74.5, 92.5 |
| Black stair: curved bottom step, iron scroll newel, iron balusters with heart scrolls, wood handrail, wall handrail, a half-landing in the corner | Along one wall | 6.5, 26.5–34.5, 74.5–84.5, 101.5, 119.5–127.5 |
| Upper landing: black floor, balustrade on two sides, white panelled door to the grey gallery | Upper level | 34.5–38.5, 149.5, 170.5–177.5 |
| Two gridded laylights, panelled ceiling, dentil cornice, track heads; a square vent and two cameras in one corner | Ceiling | 16.5–19.5, 42.5–49.5, 141.5 |
| Labels beside the two lower works; pale straight oak boards, light grey walls, white baseboard | Lower floor | 137.5, 0.5–13.5 |

**Marble stair hall** (`IMG_6380.MOV` 45.5–82.5, `IMG_6381.MOV`):

| Object or fixture | Where | Footage |
| --- | --- | --- |
| Art Nouveau chimneypiece: carved wood, arched mirrored overmantel with a carved landscape, two leaning female figures, green tile surround, about 3 m tall, with a wall label to its right | South-east of the hall, under the stair's upper run | 6380 51.5–66.5; 6381 6.5, 17.5 |
| Blown-glass chandelier: white and clear tendrils round a dark core | Over the well, before the window | 6381 31.5, 44.5, 54.5–58.5 |
| Marble floor in a large diagonal checker, grey marble skirting | Lower hall | 6380 46.5–50.5; 6381 0.5, 93.5–97.5 |
| Stair: curved bottom step with an iron scroll newel, about 14 marble steps with dark strips, two quarter-turns of winders, iron scroll balusters, wood handrail, wall handrail | East wall, then round the well | 6381 3.5–17.5, 68.5–88.5 |
| Three-part window: arched centre sash, two side sashes, engaged columns, perforated sill grille | Half-landing | 6381 23.5–26.5, 68.5, 76.5 |
| Upper landing: pale stone tiles with a border, balustrade round the well, cornice, ceiling lights, three doorways | Floor above | 6381 31.5–51.5, 64.5 |
| Doorway under the stair with an exit sign; round-arched niche with a stair going down; lit passage to a further gallery; fire pull stations | Lower hall, east and south sides | 6381 97.5; 6380 46.5–50.5, 70–78 |

**Metcalf Auditorium** (`IMG_6378.MOV`):

| Object or fixture | Where | Footage (6378) |
| --- | --- | --- |
| Fixed seats, about 13 rows, black upholstery, maple backs and arms, grey carpet | The house | 1.5, 9.5, 39.5–49.5, 102–119.5 |
| Raised maple stage with a two-step block; maple back wall; black lighting bar | Front | 12–31, 39.5 |
| Lectern with a side shelf and a microphone | Stage, left | 49.5, 79.5–89.5 |
| Black line-array speakers | Either side of the stage | 9.5, 49.5 |
| Side doors with push bars, exit signs and fire pull stations | Front left and right | 49.5, 59.5 |
| Side lobby: four maple steps, steel rail, blue shell chairs | Through the front side door | 72–79 |
| Stacked chairs, a table and a cabinet (temporary) | Stage wing | 90–101.5 |
| Maple wall panels, white upper walls, ceiling with long light slots and round lights | Throughout | 1.5, 9.5 |
| Black slat benches; booth window with equipment | Rear cross-aisle | 132–167.5, 168.5 |
| Ramp with a maple half-wall and steel rail; waste bin, sign on a post, mat, store door, exit door to a white lobby | Rear side | 170.5–179.5 |

### 3.2 Which one is "the one room"

This is my inference; the owner's words do not name it.

1. *Metcalf Auditorium, most plausible.* Three of the ten clips are spent entirely on spaces the build lacks: 6378 (auditorium), 6379 (Skylight Gallery) and 6381 (marble stair). The two stair spaces at least have a doorway stub. The auditorium has no trace in `geometry.json`. The earlier agent's survey file states "Auditorium-to-museum route not filmed. Do not invent a connecting corridor", so it was set aside on purpose and never came back.
2. *Skylight Gallery, runner-up.* It has the most content of any unbuilt space (a piano and five works), it is a named gallery, and a visitor reaches its door from the grey gallery and finds a closet-sized box. The earlier files call it only "piano stairs", which hides that it is a room.
3. *If the owner means a room that is in the build but empty*, it is the European gallery: a 26 m room with 4 of at least 67 objects.
4. *A view defect, noted in passing.* In the atlas pictures the east-looking view of the modern painting gallery (`build/museum-atlas/modern-painting-gallery-0-e.png`) and the west-looking views of the European gallery (`adjacent-gallery-0-w.png` to `-3-w.png`) show only the Hall's wall: the camera for that direction sits inside the Hall, and the Hall wall is not cut away. Both rooms are built, but from that side they cannot be seen. I did not run the build to check that it behaves the same live.

Supporting only, not a measurement: on the museum's 2020 floor-five diagram (`risd-floor5-map-2020.png` in the earlier agent's evidence folder, `/home/reidsurmeier/orca/workspaces/risd-godot/collection-reconstruction/docs/evidence/collection-reconstruction/`) the Grand Gallery has a strip of three "European" rooms along its garden side. Read against the footage, the modern painting gallery is the one nearest the lion landing, its far doorway leads into the middle one, and the lit passage off the marble stair hall leads into the third. That would make two unbuilt rooms between the marble stair hall and the modern gallery. The same diagram shows the stair to "Floor 4" where the Skylight Gallery is, and one elevator beside it serving both floors. The auditorium is on neither the floor-five nor the floor-three-and-four diagram.

## 4. The stairwell at the lion landing

Footage: 6387 5–12 (a pan across the whole landing), 13–34.5 (looking down the well, then up), 41–46 (the pan back); 6382 18.5–22.5 (seen through the medieval door); 6344 0–6. Build: `build_lion_modern_rooms()` in `collection_rooms/remodel_room.gd` and the `lion stair landing` room in `geometry.json`.

| | In the footage | In the build |
| --- | --- | --- |
| 1. Kind of stair | One open-well stair. Each storey climbs three walls: south along the west wall, east along the south wall, north along the east wall. | Two separate straight flights, side by side, both running south. |
| 2. Flight up | Starts just south of the medieval door, right after the "5" sign. About 10 steps south along the west wall, winders round a curved corner, a long second run east along the south wall, winders again, a third run north along the east wall to a balcony landing on the next floor. | Starts in the right place, against the west wall, then runs straight for 18 treads and 3.8 m and stops 3.2 m up with nothing there. |
| 3. Flight down | Starts on the east side, beside the sculpture door: its wall handrail begins at that door's fire panel. Runs south along the east wall under the up stair's third run, then winds round the same well. | Starts 0.4 m east of the flight up, in the west half of the landing, and runs straight to 3.2 m below with nothing there. |
| 4. The well | An open rectangular well with rounded corners between the flights. From the balustrade you see down two storeys. | A 3.0 × 3.9 m hole only under the two flights. Where the real well and flight down are, the build has solid floor (the patch named "landing east floor"). |
| 5. Landing edge | One balustrade across the landing's south edge, between the foot of the flight up and the head of the flight down. | A straight guard along the east edge of the hole. |
| 6. Winders and curved corners | Two per storey, with a curved white stringer. | None. |
| 7. Other floors | A balcony landing above; a half-landing with a sash window below; a dark floor with stacked chairs at the bottom. | None. |
| 8. Steps | Grey stone treads with dark anti-slip strips, on a white moulded stringer with a curved underside. | Oak treads, ivory risers, no stringer. |
| 9. Balustrade | Black square iron bars with small collars, a scroll panel at intervals, a continuous wood handrail ending in a scroll at the bottom step, and a second handrail on the wall. | One square post per tread with three collars and a straight rail. No scroll panels, no scroll end, no wall rail. |
| 10. Light | A rectangular laylight of about 3 × 4 panes over the well, a sash window on the outer wall at the half-landing below, four or more oval wall lamps, a ceiling track with spots over the landing. | None. The landing and stair have no ceiling. |
| 11. Landing floor | Large pale grey and beige blocks in a pinwheel pattern, each block one plain slab. | Warm oak basket-weave: 1 m squares of five strips. |
| 12. Wall colours | Grey: the west wall north of the medieval door, and the sculpture-door wall. White: the lion wall, the west wall south of the medieval door, the stairwell. | One off-white plaster on every wall. |
| 13. Lion relief | On the north wall east of the modern door, in a wide white frame, with a small label to its right and a tall grey text panel between it and the door. | Present on the correct wall with its frame and one vent. No label, no text panel. |
| 14. Doors and signs | Medieval door: leaves open onto the landing. Modern door: leaves open into the modern room. Sculpture door: leaves open into the sculpture gallery. Sign "5" with a directory, fire devices and an access panel by the sculpture door, chair rack at the balustrade. | The three doors are on the right walls and swing the right way. None of the signs, devices or the rack. |

## 5. Build list, in order

Source frames are survey frames in `~/risd-godot-ingestion/collection-expansion/survey-2fps/<clip>/`, named by frame number (2 × seconds + 1). Take the full-size frame from the clip at the same second when detail matters.

| Order | What to add | Why first | Source frames |
| --- | --- | --- | --- |
| 1 | **Medieval south wall and the Angel**: Head of Christ 59.131 on an octagonal pedestal, the stone relief, the Crucified Christ over its low platform, the bust figure, St. Anthony Abbot 16.243 on its projecting backing, the Angel 37.114 on its pedestal. | Six objects, three already identified. The crucifix is what the Hall's portal frames. | IMG_6382 000058–000066 (head), 000070–000074 (relief), 000078–000096 (crucifix, platform), 000090–000102 (bust), 000108–000116 (St. Anthony), 000120–000124 (Angel). Whole wall in one view: IMG_6382 000156; `~/risd-godot-ingestion/sfm-6344/images/0013.jpg`–`0031.jpg`. |
| 2 | **Grey gallery**: Rodin 23.005 on its plinth, then Géricault, Pannini 56.094, Villeneuve 1998.35, Daubigny 73.120, Bannister, the pier landscape. | Seven objects in a small room that every route crosses. Sizes are in the repo for four of them. | Rodin: IMG_6380 000034–000036, 000074–000080; IMG_6381 000042, 000064, 000170. Paintings: IMG_6380 000012–000017, 000040–000046, 000050–000054, 000172–000176, 000190–000194, 000202–000212. Room: IMG_6380 000072–000080; IMG_6379 000342. |
| 3 | **European gallery**, 63 objects. First the five floor pieces (silver case, bench, cabinet case, majolica case, crouching figure). Then the east wall (ten works, the textile panel, the commode). Then the west wall and the two end walls. Move the Fetti and the Goltzius south while there. | The largest count by far, and the room reads as empty. | Floor: IMG_6385 000062–000075; IMG_6386 000086, 000168–000170, 000002–000030; IMG_6384 000070–000082. East wall, south to north: IMG_6384 000014, 000018, 000088, 000116–000120, 000126–000138, 000140, 000144–000148, 000152–000156, 000160–000170, 000174–000178, 000182–000192, 000196–000200. West wall, south to north: IMG_6384 000050–000058; IMG_6386 000034–000038, 000042–000046, 000050–000058, 000062–000070, 000074–000078, 000094–000104, 000130; IMG_6385 000046–000058, 000022–000044, 000008–000012. End walls: IMG_6384 000002–000006, 000034–000042, 000204–000208; IMG_6385 000002–000004, 000016. Whole room: IMG_6386 000134–000138, 000180–000192. |
| 4 | **Rebuild the stairwell** as an open-well stair (section 4), with the pale block floor, the two wall colours, the sign "5", the text panel and a ceiling. | The present stair ends in mid-air; the footage is complete for this floor. | IMG_6387 000011–000025 (pan), 000027–000070 (down and up the well), 000083–000093, 000166–000170; IMG_6382 000038–000046; `sfm-6344/images/0001.jpg`–`0013.jpg`. |
| 5 | **The unbuilt rooms.** Skylight Gallery first: it replaces the piano-stair stub and needs no invented connection. Then the marble stair hall behind the columns. The auditorium once the owner says where it attaches. | These are the "room that hasn't been integrated" candidates. | Skylight Gallery: IMG_6379 000008, 000014–000018, 000034–000040, 000046, 000054–000078, 000086–000100, 000150–000256, 000268–000284, 000300–000356. Marble stair hall: IMG_6380 000092–000157; IMG_6381 000002–000196. Auditorium: IMG_6378 000004–000040, 000060, 000080–000120, 000150, 000172–000212, 000236–000300, 000338–000360. |
| 6 | **Rockefeller leftovers and the fixture pass.** The Vincennes pair, the brown textile, the two prints. Then, in every room: labels, wall texts, exit signs, door strips, low vents, security domes, floor frames under wall cases; ceiling tracks in the grey and European galleries. | Small, and they finish rooms that are otherwise complete. | Rockefeller: IMG_6380 000448–000454, 000262–000274, 000376–000392, 000256. Fixtures: the times in section 1. |

Notes for the builder, all inferred from the build's own numbers:

1. The pier between the Hall door and the connector door in the grey gallery is 0.70 m wide in `geometry.json`. The painting on it and its label need about 1 m.
2. The Vincennes pair has an earlier paid generation that was never reconciled (`video-inventory.json`, "possibly spent; no resubmission"). Re-running it is a spend decision for the owner.
3. Label and wall-text wording is not legible for most objects. Blank cards are what the footage supports.

## 6. What I could not see or identify

1. **Label text.** Most labels cannot be read even in full-size frames. The names I did read are marked "label" in section 1. I did not look any of them up in the museum catalogue, so none has an accession number yet: Géricault, Bannister, Guardi (two), Cesari, Lawrence, the Apollo, the Bruegel print, the Piranesi print.
2. **Objects with no identification at all.** European gallery: rows 2–4, 10, 12–14, 16, 17, 23, 24, 26–38. Medieval room: the relief, the bust figure, the iron screen; the crucifix has only a candidate. Rockefeller: the brown textile and the two prints. Grey gallery: the pier landscape. Skylight Gallery: all five works. Marble stair hall: the chimneypiece and the chandelier.
3. **Exact counts inside cases.** The silver case (9 or more), the majolica case (10 or more) and the small-object case under the roundel (6 or more) are lower bounds. The seven objects in the medieval tall case and the two leaves in the low case are the earlier agent's count, which matches what I saw.
4. **Positions.** Nothing here is measured. The two "wrong position" calls come from the order of objects along the wall and the walking time between them.
5. **Rooms seen only through a door.** The white sculpture gallery, the modern adjoining gallery, the gallery beyond the lit passage, the three rooms off the marble stair's upper landing, the rooms off the Skylight Gallery. I cannot say whether the adjoining gallery and the passage gallery are two rooms or one.
6. **How the auditorium connects.** Not filmed. It is not on the two floor diagrams the earlier agent saved.
7. **A second pier in the European gallery.** I saw one projecting panel on the east wall. The build has two piers; the earlier agent cites 6386 44.25 for the second and I did not confirm it.
8. **Step counts and sizes on the stair.** I counted about 10 steps in the first run up, from two frames (6387 15 and 28). The other runs I could not count.
9. **The Hall.** IMG_6344 is an earlier visit than the ten clips. What the ten clips show of the Hall through its doors agrees with it. I looked at every third frame of it, not every frame. I did not open the other earlier clip, `IMG_6343.MOV`.
10. **The build itself.** I did not run it. Build status comes from the atlas pictures and from reading the scripts. The atlas camera cannot see the west wall of the European gallery from inside, so those four works are confirmed from the script and from the other three views.

## 7. Open questions for the owner

1. Which room is "the one room": the auditorium, or the Skylight Gallery with the piano? If the auditorium, where should it attach, given that no route to it was filmed?
2. Should temporary things be built: the chair rack on the landing, the stacked chairs in the auditorium's stage wing?
3. Labels and wall texts: blank cards, or legible wording? Most wording cannot be read from the footage.
4. The Vincennes pair for Rockefeller's central pedestal: re-run the earlier paid generation that was never reconciled, or make it another way?
5. Catalogue lookups for the nine works identified here only by their labels. I made one plain request to the museum's catalogue API from this machine; it was refused (HTTP 403), and I did not try to get round that. The earlier agent's catalogue workflow would give accession numbers and sizes.

## Appendix A. Where this differs from the earlier inventories

| Earlier file says | What I saw |
| --- | --- |
| Rockefeller: "four vertically stacked prints flanking gallery door" | Two stacked prints, west of the door only (6380 187.5–191.5). |
| European far-east painting: "vertical white Christ against blue clouds" | Perseus and Andromeda; label reads Giuseppe Cesari (6384 6.5). |
| European far end: "bronze standing figure … identity pending" (file id `far-bronze-christ`) | Label reads "*Apollo*, ca. 1540 … circle of Benvenuto Cellini" (6384 2.5). |
| Grey gallery "coach-landscape", no match | Label reads Géricault, *A Cart Loaded with Kegs* (6380 8.0). |
| Grey gallery "small-dark-cloud-landscape", no match | Label reads Edward Mitchell Bannister (6380 21.5). |
| European "landscapes-stacked", unmatched | One label, two entries, both Francesco Guardi (6386 51.5). |
| European "gothic-madonna: small religious panel" | An Adoration of the Magi (6384 59.5). |
| "Skylit piano stairs" | A room named SKYLIGHT GALLERY (6379 8.0–9.4). |
| Marble stair hall: fireplace, stair, window, chandelier, descending niche | Also a lit passage to a further gallery (6380 48.5–50.5, 70–72). |

## Appendix B. Opening a source frame, and my scratch

The survey frames are stored sideways. All ten clips come upright with a quarter-turn clockwise. For a full-size frame:

```sh
ffmpeg -noautorotate -ss 38.5 -i ~/risd-godot-ingestion/collection-expansion/verified/IMG_6382.MOV \
  -frames:v 1 -vf transpose=clock out.png
```

Do not rely on ffmpeg's automatic rotation: it turns IMG_6381 and IMG_6382 upside down and leaves IMG_6378 and IMG_6387 sideways. The Hall frames in `~/risd-godot-ingestion/sfm-6344/images/` are already upright, two per second, frame N at (N − 1) / 2 seconds.

Scratch, safe to delete: `build/audit-inventory/` (26 MB, ignored by git): my viewing notes, upright contact sheets made from the existing survey frames, and three small helper scripts. No video frame I extracted is kept.
