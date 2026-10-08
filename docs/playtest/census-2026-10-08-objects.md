# Object census: all 177 registered objects, from the playtest pictures

Written 7 October 2026 for ticket #257 (map #249). Build played: `88b7c207`. Source: the 30 contact sheets and the single pictures in `build/museum-playtest/` of the `wt-runtime` worktree, one inspection picture and one zoom picture per object. 176 objects opened; the chandelier 2011.60 cannot be clicked and has no pictures.

How to read it. Every row was judged by looking at its two pictures (VERIFIED). Where a picture could not settle how an object is built, the builder code was read and the row says so (INFERRED). "Cannot tell" means the picture does not show it. Verdicts: **FINE** nothing wrong seen; **FIX** it works but something looks wrong (view, caption, zoom page, placement); **REBUILD** it needs a real mesh or a real frame. Any "NOT OK" in a row makes it at least FIX.

## Counts

**Verdicts:** REBUILD 71, FIX 56, FINE 50 (177).

**REBUILD by kind**

| Kind in the museum | REBUILD | of |
| --- | --- | --- |
| sculpture in the round | 26 | 27 |
| vessel | 26 | 42 |
| painting | 6 | 69 |
| relief | 5 | 11 |
| light fitting | 2 | 3 |
| furniture | 2 | 2 |
| case piece | 2 | 5 |
| textile | 1 | 7 |
| architectural piece | 1 | 1 |

**REBUILD by room**

| Room | REBUILD | of |
| --- | --- | --- |
| Grand Gallery | 0 | 23 |
| dark medieval room | 12 | 13 |
| light Renaissance room | 1 | 16 |
| adjacent gallery (the European gallery) | 23 | 51 |
| Rockefeller room | 33 | 50 |
| grey French gallery | 1 | 10 |
| modern painting gallery | 0 | 6 |
| Skylight Gallery | 0 | 5 |
| lion stair landing | 0 | 1 |
| marble stair hall | 1 | 2 |

**How the 92 three-dimensional objects are shown** (everything that is not a painting, print or textile)

| Shown as | Count |
| --- | --- |
| blob with a picture on the front | 32 |
| photo extruded along its outline | 19 |
| dish or disc with the photo on it | 16 |
| photo on a slab | 12 |
| flat picture, no modelled frame | 5 |
| hand-modelled solid | 5 |
| plain box | 2 |
| not seen | 1 |

The 85 paintings, prints and textiles: 65 framed, real frame; 19 flat picture, no modelled frame; 1 hand-modelled solid.

**Zoom page is not a usable preview: 7**

- 56.096 (S1) Wisdom and Strength (c.1572): the frame shows with a blank white middle, no painting
- 22.201 Diptych with scenes of the Nativity, the Crucifixion, and the Last Judgement: half the picture is a blank white leaf (the museum's own photograph)
- 2023.17 One Hundred Christian Emblems (Emblematum Christianorum Centuria): blurry
- 2025.19 Spectrum II: blurry
- 2026.3 Foreign Sign: blurry
- not identified (candidate 2017.74.32) Earthenware figure of a ewe and lamb: a generated faceted render, not a photograph of the work
- 2011.60 Gilded Frost and Jet Chandelier: no page, because it cannot be clicked

Two more zoom pages show the picture but a broken caption (every line is broken glyphs or black bars): 42.042 and E4. On most zoom pages the title line sits on top of, or behind, the bottom edge of the picture; that is one layout defect, noted per row, not counted here.

**Paintings with no real frame: 7 that should have one, and 5 contemporary canvases that are probably right without**

- Need a frame (REBUILD): 20.207, 21.250, 22.047 and 57.301 in the medieval room hang as cut-out photographs on pale boards; 16.243 (medieval) and 34.861 (Renaissance) are flat photographs whose frame is only part of the picture.
- W6 The Angel of Fame is a shaped canvas with a thin gold edge; whether the real one has a frame: cannot tell.
- Five contemporary canvases in the Skylight Gallery (69.094, 73.018, 2026.3, 2000.17, 2025.19) are unframed, which is plausible for them.

**Soft image although the catalogue holds a sharp one**

- Seen as soft in the playtest: 2023.17, 2025.19, 2026.3. All three are crops of the owner's video; the repo's source notes say the catalogue has no photograph of them online (INFERRED from `SOURCES.md` and the 1 Oct manifest; the live catalogue answered 403 to a plain fetch, so not re-checked). So: **0 verified cases** of a soft picture where a sharp catalogue one is known to exist.
- Low-resolution copies that look sharp at the 960 x 640 playtest window but will be soft on a larger screen (INFERRED from file sizes): all 27 European-gallery east-side works are stored at 600 px or less on the long side, the two Küssell prints 2024.17.5 and 2024.17.6 at 389 and 399 px, and the chandelier at 600 px. The same build holds 1324 px museum photographs for the west side, so sharper ones exist. The 27: 09.351, 1989.085, 2014.33, 2016.102.2, 2016.124, 2016.62, 2017.46, 2025.86, 21.482, 34.1371, 35.703, 37.009, 43.351, 44.674, 46.256, 51.272, 51.502, 53.349, 54.147.9, 54.186, 55.023.6H, 57.167, 57.281, 69.197, 75.023, 84.198.1032, 85.075.8.
- ewe-lamb shows a generated render, not a photograph; the museum publishes none.
- gold-cup-a, gold-cup-b and gold-ecuelle-clean show the museum's storage snapshots with a handwritten tag in them. They are the catalogue's own.

**Inspection view is wrong: 36**

- Seen edge-on, from the side or from behind (18): 69.196, 37.009, 2016.124, 2014.33, 09.351, 2016.62, 2016.102.2, 55.023.6H, 75.023, 54.147.9, 85.075.8, 43.351, 35.703, 1989.085, 51.502, 51.272, 44.674, 2000.103.3. Thirteen of them are photo cards on the European gallery's east platform: the camera looks along the cards, so the visitor sees a dark bar.
- Caption card covers part of the work (12): 32.246 (W6), 55.152 (W8), 2003.105 (E5), 62.064 (E8), 56.096 (S1), 57.227 (S2), 42.283 (N1), 60.039 (N2), 53.115, 53.349, 2000.17, 1995.043.
- Other (6): 69.094 (the black box piano covers the lower right corner; visitor beside); 73.018 (the black box piano covers the lower left); 2020.55 (small, off-centre, behind other case contents); 67.089 (the work is hidden behind the visitor's head; only blinds and wall show); 83.152 (the stair rail and balusters cross in front of it; visitor beside); 2011.60 (cannot be clicked from in front of it).

**Caption is wrong: 22**

- Title or other lines drawn as broken blocks (17): 63.061 (E1), 37.104 (E6), 33.204 (E7), 18.096 (E9), 60.039 (N2), 2016.80.89, 2016.80.91, 53.115, 63.066.45, 57.167, 54.186, 53.349, 21.482, 2025.86, 84.198.1032, 46.256, 42.072. Checked at full size on 21.482 and 2016.80.89: the text is solid white blocks, the lines below it are fine. Cause not looked for.
- Maker and number lines missing: E8, N1.
- A working description instead of a title, no maker, date or number: 34.024, ewe-lamb.
- No museum number: Saldanha Platter.
- Four-line titles that cover the painting: 53.115, 53.349.

**Supports.** Seven objects stand on plain white or grey boxes: the two Vincennes groups 2017.74.31.1 and .2, the Hand of God 23.005, the River God 44.674, the Récamier bust, and the gold tureen and ecuelle. Two vessels in the European west case (32.010, 52.533) stand on small grey boxes. The case pieces in the European gallery stand among plain grey, pink and olive boxes.

**Not among the 177.** The piano in the Skylight Gallery is a black box with legs, is not a registered object and cannot be clicked. It covers part of 69.094 and 73.018 in their inspection views.

## Against the retro's counts (#251)

The retro read the code: 87 flat works, 90 three-dimensional (31 photo slabs or cards, 34 blobs, 2 boxes, 11 dish profiles, 11 hand-coded solids, 1 chandelier, 0 meshes).

- By looking: 85 paintings, prints and textiles and 92 three-dimensional objects. The split differs because this census counts glass and metal roundels, the enamel plaque, the ivory diptych, the lion panel and the micromosaic tabletop as objects, not flat works.
- Nothing seen contradicts "0 imported meshes": no object in any picture is a modelled mesh of the real thing.
- 2 plain boxes: agreed (Commode 2017.46, Writing Desk 75.023).
- Blobs: 32 seen, against the retro's 34. By the code (INFERRED) 36 registered objects are one-picture volumes: 31 Rockefeller-room pieces, the two apostles, the two Vincennes groups and the Rodin. The two sconces and the two apostles read on screen as flat cut-outs and are counted with those here.
- Slabs: the retro's 31 lumps together what looks like two things on screen: 12 rectangular cards that still carry the photograph's grey backdrop, and 19 photographs cut to the object's outline and extruded.
- Dish profiles: the retro's 11 are confirmed in `catalogue-objects.json`; by eye 16 objects are a dish or disc with the photograph on it, because wall plates and roundels in the Renaissance and European rooms look the same.
- Hand-modelled solids seen among registered objects: 6 (triptych, emblem book, girdle book, albarello, God Save the Queens, Seated Woman). The retro's 11 includes unregistered case contents.

## The twenty objects a real mesh would change most

Ranked by size, how central the object is, how close the visitor walks, and whether the owner named it.

1. **83.152 Fireplace Surround**, marble stair hall. 3.5 m tall, the one large object in the stair hall; the owner named it. A photograph extruded 40 cm; its inspection view is crossed by the stair rail.
2. **2017.74.31.1 Neptune as River Deity**, Rockefeller room. The porcelain on the white plinth the owner named: on the central pedestal of the Rockefeller room, a one-picture blob on a plain box.
3. **2017.74.31.2 Amphitrite as River Deity**, Rockefeller room. Its pair on the same plinth.
4. **43.195 The Crucified Christ**, medieval room. 2.16 m crucifix, the largest thing in the medieval room; a cut-out photograph that turns into a plank from the side.
5. **59.131 Head of Christ or a Saint**, medieval room. 81 cm head on a plinth; cut-out photograph.
6. **20.254 Saint Peter**, medieval room. 76 cm stone figure on a plinth; cut-out photograph.
7. **37.114 Angel of the Annunciation**, medieval room. 1.52 m polychrome figure standing free on a pedestal; cut-out photograph.
8. **69.196 Christ in Majesty**, medieval room. 98 cm limestone relief on a plinth; cut-out photograph, and its inspection view is half hidden by a wall.
9. **23.005 The Hand of God**, grey French gallery. 1 m marble on a plinth in the grey French gallery; a blob on a plain box.
10. **2017.46 Commode**, European gallery. 1.45 m commode on the European gallery floor; a box with a photograph on the front and white backdrop beside the legs.
11. **75.023 Writing Desk (Schreibtisch)**, European gallery. Cabinet in its own case; a box, and the game shows it from behind as a plain brown block.
12. **2000.103.3 Dress**, European gallery. 1.5 m dress in a case; a flat cut-out that the inspection view shows edge-on.
13. **41.045 Apostle**, medieval room. 86 cm limestone figure in a dark niche; cut-out photograph.
14. **41.046 Apostle**, medieval room. Its pair.
15. **44.674 River God (The Virile Age; The Euphrates)**, European gallery. 48 cm terracotta on its own plinth; a photo card with the grey backdrop still on it.
16. **37.201 Bust of Madame Récamier**, Rockefeller room. 61 cm marble bust on a plinth in the Rockefeller room; a blob.
17. **06.057 Tabernacle**, European gallery. Marble tabernacle on a plinth; cut-out photograph with the opening filled white.
18. **2016.124 Cake Basket**, European gallery. Largest of the 13 registered photo cards on the European gallery's east platform; every card there needs the same treatment.
19. **2014.33 Coffeepot**, European gallery. Silver coffeepot on the same platform; a photo card among plain coloured boxes.
20. **2017.74.39.18a-c Dragons-in Compartments pattern covered tureen and stand**, Rockefeller room. 42 cm Worcester tureen, the biggest piece in its Rockefeller case; a blob.

Next in line: the two gilded wall sconces (88 cm cut-outs beside the mirror), the gold tureen, Apollo 73.079, the other eleven platform cards, the five vessels in the European west case, and the 20 shelf figures in the Rockefeller cabinet (small; they read tolerably from the front).

Two the owner will also see that this list cannot rank: the **piano** (a black box, not a registered object) and the **chandelier 2011.60** (never in a picture).

## What could not be judged

- Chandelier 2011.60: not clickable, and above the top edge of every view. Shape, size and caption unseen.
- Seated Woman 67.089: its inspection view shows only the visitor's head. Seen in the room view as a small gold faceted figure in a case; too small to say whether the solid is good enough.
- Sizes against the room: the pictures show nothing floating, sunk or wildly out of scale beside the visitor, but they cannot measure. The Küssell prints sit very small in their mounts: cannot tell if right. The 1 Oct size audit lists the open size questions.
- Which of a look-alike pair stands where (finches, parrots, baskets, dishes, plates, saucers, cups, bowls): cannot tell from the pictures.
- Whether the broken caption text is in the game or only in the headless capture: the pictures show it; a person at a browser should confirm.
- Whether the catalogue has sharper pictures for the low-resolution copies: the live site refused a plain fetch (403).

## Every object, by room

### Grand Gallery: 23 objects (REBUILD 0, FIX 13, FINE 10)

| Accession | Title | In the museum | Shown as | Inspection view | Zoom page | Caption | Image | Misplaced or mis-sized | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 23.332 (W1) | The Supper at Emmaus (c.1650) | painting | framed painting with a 3D frame | OK, visitor beside | OK in its frame (title hidden behind the frame foot) | OK | sharp | - | **FINE** |
| 56.177 (W2) | Christ at the Column (c.1635) | painting | framed painting with a 3D frame | OK, visitor beside | OK in its frame (title overlaps the frame foot) | OK | sharp | - | **FINE** |
| 62.019 (W3) | The Resurrection of Christ (c.1640) | painting | framed painting with a 3D frame | OK, visitor beside | OK in its frame (title overlaps the frame foot) | OK | sharp | - | **FINE** |
| 60.009 (W4) | Portrait of a Woman (1655) | painting | framed painting with a 3D frame | OK, visitor beside | OK in its frame (title overlaps the frame foot) | OK | sharp | - | **FINE** |
| 57.157 (W5) | Charity (c.1550) | painting | framed painting with a 3D frame (plain bevel) | OK, visitor beside | OK in its frame (title overlaps the frame foot) | OK | sharp | - | **FINE** |
| 32.246 (W6) | The Angel of Fame (c.1750) | painting | flat picture cut to its shaped outline, no frame | NOT OK: caption covers the lower quarter | OK | OK | sharp | shaped canvas with only a thin gold edge; whether the real one has a frame: cannot tell | **FIX** |
| 44.161 (W7) | A Musical Group (c.1730) | painting | framed painting with a 3D frame | OK, visitor beside | OK in its frame (title overlaps the frame foot) | OK | sharp | - | **FINE** |
| 55.152 (W8) | Allegorical Portrait of a Lady as Fortune (1676) | painting | framed painting with a 3D frame | NOT OK: caption covers the lower fifth; visitor in front | OK in its frame; title overruns the frame | OK | sharp | - | **FIX** |
| 62.058 (W9) | The Marriage of Peleus and Thetis (c.1610) | painting | framed painting with a 3D frame (plain bevel) | OK, visitor beside | OK in its frame (title overlaps the frame foot) | OK | sharp | - | **FINE** |
| 60.107 (W10) | Still Life with Figure (c.1660) | painting | framed painting with a 3D frame (plain bevel) | OK, visitor beside | OK in its frame (title overlaps the frame foot) | OK | sharp | - | **FINE** |
| 63.061 (E1) | Arsenal in a Ruined Basilica (c.1715) | painting | framed painting with a 3D frame (plain bevel) | OK, visitor beside | OK: shows the painting in its frame (title overlaps the frame foot) | NOT OK: title line is broken blocks | sharp | - | **FIX** |
| 18.264 (E2) | Portrait of Theodore Atkinson, Jr. (1757) | painting | framed painting with a 3D frame | OK | OK: painting in its frame (title overlaps the frame foot) | OK | sharp | - | **FINE** |
| 51.506 (E3) | Landscape with a Mill (c.1655) | painting | framed painting with a 3D frame | OK, visitor beside | picture OK; no caption visible on the page | OK | sharp | - | **FINE** |
| 1987.056 (E4) | A View of Paris from the Louvre (1835) | painting | framed painting with a 3D frame | OK, visitor beside | picture OK in its frame; all three caption lines are black bars | OK on the inspection card | sharp | - | **FIX** |
| 2003.105 (E5) | Portrait of Antoine-Georges-François de Chabaud-Latour and His Family (c.1806) | painting | framed painting with a 3D frame | NOT OK: three-line caption covers the lower third; frame crest cut by the top edge | picture OK in its frame; title too long, runs across the frame foot | OK but the title is three lines deep | sharp | - | **FIX** |
| 37.104 (E6) | Architectural Fantasy (c.1805) | painting | framed painting with a 3D frame | OK, visitor beside | OK in its frame (title overlaps the frame foot) | NOT OK: maker and number lines are broken blocks | sharp | - | **FIX** |
| 33.204 (E7) | The Ferry Boat (c.1645) | painting | framed painting with a 3D frame | OK, visitor beside | OK in its frame (title overlaps the frame foot) | NOT OK: maker and number lines are broken glyphs | sharp | - | **FIX** |
| 62.064 (E8) | Portrait of a Cavalier with his Hunting Dogs (c.1575) | painting | framed painting with a 3D frame | NOT OK: caption covers the lower third of the painting | OK in its frame (title overlaps the frame foot) | NOT OK: maker and number lines are missing | sharp | - | **FIX** |
| 18.096 (E9) | Hagar and Ishmael (c.1640) | painting | framed painting with a 3D frame | OK, visitor beside | frame cut off at the page edges (title overlaps) | NOT OK: maker and number lines are broken glyphs | sharp | - | **FIX** |
| 56.096 (S1) | Wisdom and Strength (c.1572) | painting | framed painting with a 3D frame | NOT OK: caption covers the lower quarter; visitor beside | NOT OK: the frame shows with a blank white middle, no painting | OK on the inspection card | none on the zoom page | - | **FIX** |
| 57.227 (S2) | The Virgin and Child Appearing to Saint Francis of Assisi (c.1599) | painting | framed painting with a 3D frame | NOT OK: caption covers the lower third | OK in its frame; title too long, runs across the frame foot | OK | sharp | - | **FIX** |
| 42.283 (N1) | Portrait of a Lady of the Hampden Family (c.1610) | painting | framed painting with a 3D frame | NOT OK: caption covers the lower quarter; visitor beside | OK in its frame (title and maker overlap the frame foot) | NOT OK: maker and number lines are missing | sharp | - | **FIX** |
| 60.039 (N2) | Portrait of Lady Sarah Ingestre (1827) | painting | framed painting with a 3D frame | NOT OK: caption covers the lower third | OK in its frame (title overlaps the frame foot) | NOT OK: maker and number lines are broken glyphs | sharp | - | **FIX** |

### dark medieval room: 13 objects (REBUILD 12, FIX 1, FINE 0)

| Accession | Title | In the museum | Shown as | Inspection view | Zoom page | Caption | Image | Misplaced or mis-sized | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 37.114 | Angel of the Annunciation | sculpture in the round | photo extruded along its outline, on a plinth | OK, visitor beside | OK; photo has a clipped corner (title overlaps picture) | OK | sharp | - | **REBUILD** |
| 16.243 | St. Anthony Abbot Enthroned | painting | flat picture cut to the gable outline, engaged frame is part of the photo, no modelled frame | OK, visitor beside | OK (title overlaps picture) | OK | sharp | - | **REBUILD** |
| 20.254 | Saint Peter | sculpture in the round | photo extruded along its outline on a dark plinth | OK, visitor beside | OK | OK | sharp | - | **REBUILD** |
| 43.195 | The Crucified Christ | sculpture in the round | photo extruded along its outline, fixed to the wall | OK, visitor beside | OK (title overlaps picture) | OK | sharp | - | **REBUILD** |
| 69.196 | Christ in Majesty | relief | photo extruded along its outline on a plinth | NOT OK: a black wall fills the left half and hides half the relief; seen from the side | OK (title overlaps picture) | OK | sharp | - | **REBUILD** |
| 59.131 | Head of Christ or a Saint | sculpture in the round | photo extruded along its outline, on a dark plinth (reads rounded from the front) | OK, visitor in front at the lower left | OK (title overlaps picture) | OK | sharp | - | **REBUILD** |
| 41.046 | Apostle | relief | photo extruded along its outline on a dark plinth | OK, visitor fills the lower left | OK (title overlaps picture) | OK | sharp | - | **REBUILD** |
| 41.045 | Apostle | relief | photo extruded along its outline on a dark plinth | OK, visitor fills the lower left | OK (title overlaps picture) | OK | sharp | - | **REBUILD** |
| 20.207 | Madonna and Child | painting | flat picture on a pale board, no frame | OK, visitor beside | OK | OK | sharp | - | **REBUILD** |
| 57.301 | Virgin of the Annunciation | painting | flat picture cut to its outline on a pale board, no frame | OK, visitor in front at the left | OK (title overlaps picture) | OK | sharp | - | **REBUILD** |
| 22.047 | The Taking of Saint Peter | painting | flat picture on a pale board, no frame | OK | OK (title overlaps picture) | OK | sharp | - | **REBUILD** |
| 21.250 | Mary Magdalene | painting | flat picture cut to its gable on a pale board, no frame | OK, visitor beside | OK (title overlaps picture) | OK | sharp | tabernacle frame was trimmed off the photo | **REBUILD** |
| 2020.55 | God Save the Queens | vessel | hand-modelled solid (small cylinder with the decal) | NOT OK: small, off-centre, behind other case contents | OK | OK | sharp | - | **FIX** |

### light Renaissance room: 16 objects (REBUILD 1, FIX 5, FINE 10)

| Accession | Title | In the museum | Shown as | Inspection view | Zoom page | Caption | Image | Misplaced or mis-sized | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 58.196 | Madonna and Child with Saint Barbara and Saint Catherine | painting | framed painting with a 3D frame | OK, visitor beside | OK (title hidden behind picture) | OK | sharp | - | **FINE** |
| 45.042 | Portrait of a Cleric | painting | framed painting with a 3D frame | OK but dim | OK (title hidden behind picture) | OK | sharp | - | **FINE** |
| 34.861 | Portrait of a Woman | painting | flat picture cut to its arch; the frame is part of the photo | OK but dim | OK (title overlaps picture) | OK | sharp | - | **REBUILD** |
| 22.201 | Diptych with scenes of the Nativity, the Crucifixion, and the Last Judgement | relief (ivory diptych) | flat photo panels laid on a sloped stand in a case | OK but dim; caption covers the case front | NOT OK: half the picture is a blank white leaf (the museum's own photograph) | OK (three-line title fits) | sharp | - | **FIX** |
| 34.016 | Book cover | case piece (girdle book) | hand-modelled solid: small dark box on a chain | OK but dim and small | OK | OK | sharp | - | **FIX** |
| 2023.17 | One Hundred Christian Emblems (Emblematum Christianorum Centuria) | case piece (book) | hand-modelled solid: open book with a blurred page image | caption covers the lower half | NOT OK: blurry | OK (three-line title fits) | visibly a video-frame crop; the museum publishes no photograph | - | **FIX** |
| 35.713 | Drug Jar (Albarello) | vessel | hand-modelled solid: turned jar profile with the photo wrapped on | OK but dim | OK | OK | sharp | - | **FINE** |
| 46.391 | Bella Donna Plate | vessel | dish with the photo on its face, on the wall | OK | OK | OK | sharp | - | **FINE** |
| 57.302 | Bella Donna Plate | vessel | dish with the photo on its face, on the wall | OK but dim | OK | OK | sharp | - | **FINE** |
| 51.105 | Death of the Virgin | relief (silver roundel) | disc with the photo on its face, tilted on a small white stand | small, dim, tilted away | OK (title overlaps picture) | OK | sharp | - | **FIX** |
| 2017.29 | The Virgin as the Woman of the Apocalypse | relief (glass roundel) | flat disc with the photo on its face, on the wall | OK but dark | OK | OK | sharp | - | **FINE** |
| not identified (candidate 34.024) | Small rectangular enamel plaque with figures on a blue ground | relief (enamel plaque) | flat photo card standing on a shelf | small, off-centre | OK | NOT OK: a working description, no maker, date or number | sharp | - | **FIX** |
| 2021.131 | Madonna Enthroned, with Saints and Angels | painting (triptych) | hand-modelled solid: three panels, wings angled, in a glass case | OK, visitor beside | OK | OK | sharp | - | **FINE** |
| 23.307X | Velvet Cover | textile | flat picture on a pale mount with a thin frame | OK, visitor beside | OK (title overlaps picture) | OK | sharp | - | **FINE** |
| 29.280 | The Woodcutters | textile | flat picture, no frame (right for a tapestry) | OK, visitor beside | OK (title overlaps picture) | OK | sharp | - | **FINE** |
| 16.236 | Madonna and Child | painting | framed painting with a 3D frame | OK, visitor beside | OK (title overlaps picture) | OK | sharp | - | **FINE** |

### adjacent gallery (the European gallery): 51 objects (REBUILD 23, FIX 15, FINE 13)

| Accession | Title | In the museum | Shown as | Inspection view | Zoom page | Caption | Image | Misplaced or mis-sized | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 55.091 | Door Knocker | relief (bronze door knocker) | photo cut to its outline on a pale board inside a glass box on the wall | OK | OK | OK | sharp | white fringe round the cut-out | **REBUILD** |
| 2024.17.5 | View of the Grand Fountain at the Villa d’Este (Veduta de la gran Fontana alla Vigna d’Este) | print | framed, thin black frame, wide mount, image very small | OK | OK | OK | sharp | image tiny inside its mount: cannot tell if right | **FINE** |
| 2024.17.6 | View of the Grand Fountain at the Villa d’Este (Veduta de la gran Fontana alla Vigna d’Este) | print | framed, thin black frame, wide mount, image very small | OK | OK | OK | sharp | image tiny inside its mount: cannot tell if right | **FINE** |
| 67.106.31 | Fruit Vendor (Fruttariol) | print | framed, thin black frame with a mount | OK | OK (title overlaps picture) | OK | sharp | - | **FINE** |
| 67.106.8 | Baked Goods Hawker (Zaletto) | print | framed, thin black frame with a mount | OK | OK (title overlaps picture) | OK | sharp | - | **FINE** |
| 85.075.6 | Textile | textile | flat picture in a pale mount on a grey board | OK, visitor beside | OK | OK | sharp | - | **FINE** |
| 42.042 | View of the Grand Canal, Venice, with Churches of the Scalzi and Santa Lucia | painting | framed painting with a 3D frame | OK; caption touches the frame foot | picture OK; all four caption lines are broken glyphs | OK on the inspection card | sharp | - | **FIX** |
| 24.508 | Main Salon in the Ridotto, Venice | painting | framed painting with a 3D frame | OK | OK (dark painting) | OK | sharp | - | **FINE** |
| 53.115 | Scuola di San Marco with Loggia Erected for Benediction of Pope Pius VI May 19, 1782, (Campo San Zanipolo) | painting | framed painting with a 3D frame | NOT OK: the four-line caption covers the lower half of the painting | picture OK; title too long, runs behind the picture | NOT OK: title is broken blocks and four lines deep | sharp | - | **FIX** |
| 63.066.45 | Egyptian Decoration of the Caffè degli Inglesi, Plate 45 from Diverse Maniere d’Adornare i Camminit | print | framed, thin black frame with a wide mount | OK | OK | NOT OK: three-line title is broken blocks | sharp | - | **FIX** |
| 57.167 | Perseus and Andromeda | painting | framed painting with a 3D frame | OK, visitor beside | OK (title hidden behind picture) | NOT OK: title line is broken blocks | sharp | - | **FIX** |
| 54.186 | Venus and Adonis | painting | framed painting with a 3D frame | OK, visitor beside | OK (title hidden behind picture) | NOT OK: title line missing but for a few specks | sharp | - | **FIX** |
| 69.197 | Crucifixion | painting | framed painting with a 3D frame | OK, visitor beside | picture OK; caption text almost invisible | OK | sharp | - | **FINE** |
| 34.1371 | A Meal at Home | painting | framed painting with a 3D frame | OK, visitor beside | picture OK; caption text almost invisible | OK | sharp | - | **FINE** |
| 57.281 | Portrait of an English Gentleman | painting | framed painting with a 3D frame | OK, visitor beside | OK (title hidden behind picture) | OK | sharp | - | **FINE** |
| 53.349 | A Caricature Group: Sir Charles Turner, Mr. Cook, Mr. John Woodyeare, and Rev. Dr. William Drake | painting | framed painting with a 3D frame | NOT OK: the four-line caption covers the lower half of the painting | picture OK; title too long, runs behind the picture | NOT OK: title is broken blocks and four lines deep | sharp | - | **FIX** |
| 21.482 | The Adoration of the Magi | painting | framed painting with a 3D frame | OK, visitor beside | OK | NOT OK: title line is broken white blocks | sharp | - | **FIX** |
| 2025.86 | Portrait of an Artist | painting | framed painting with a 3D frame | OK, visitor beside | OK (title hidden behind picture) | NOT OK: title line is broken white blocks | sharp | - | **FIX** |
| 84.198.1032 | River Landscape with Mercury Abducting Psyche | print | framed, thin black frame with a mount | OK | OK (title overlaps picture) | NOT OK: two-line title is broken coloured blocks | sharp | - | **FIX** |
| 46.256 | Cloth of Gold | textile | flat picture in a pale mount | OK, visitor in front at the lower right | OK (title overlaps picture) | NOT OK: title line is broken blocks | sharp | - | **FIX** |
| 42.072 | Mrs. Wolff | print (drawing) | framed, thin frame with a wide mount | OK | OK | NOT OK: title line is broken blocks | sharp | - | **FIX** |
| 1990.060 | Micromosaic Tabletop with Nine Views of Rome | case piece | flat picture: square card with photo backdrop on the wall, no frame | OK, visitor beside | OK (title overlaps picture) | OK | sharp | round tabletop shown as a square card | **FIX** |
| 73.079 | Apollo | sculpture in the round | photo extruded along its outline, in a glass case | OK but small | OK (title hidden behind picture) | OK | sharp | - | **REBUILD** |
| 16.237 | Risen Christ | painting | framed painting with a 3D frame | OK but a textile slab and the Cloth of Gold fill the left third of the view | OK (title overlaps picture) | OK | sharp | - | **FINE** |
| 35.786 | Arabs Traveling | painting | framed painting with a 3D frame | OK | OK (title hidden behind picture) | OK | sharp | - | **FINE** |
| 36.003 | Christ Ministered To by the Angels | painting | framed painting with a 3D frame | OK, visitor beside | OK (title hidden behind picture) | OK | sharp | - | **FINE** |
| 61.006 | Christ on the Cold Stone with Two Angels | painting | framed painting with a 3D frame | OK; a glass case crosses the foreground | OK (title overlaps picture) | OK | sharp | - | **FINE** |
| 37.009 | Cover | textile | flat picture, no frame | NOT OK: seen from far off and from the side (43 px wide); visitor fills the foreground | OK (title overlaps picture) | OK | sharp | - | **FIX** |
| 2017.46 | Commode | furniture | plain box with the photo on its front; white backdrop shows beside the legs; a white box with a plate card on top | OK, visitor beside | OK | OK | sharp | something white sits on the marble top | **REBUILD** |
| 2016.124 | Cake Basket | vessel | photo on a slab (card with backdrop) | NOT OK: seen at about 60 degrees | OK | OK | sharp | - | **REBUILD** |
| 2014.33 | Coffeepot | vessel | photo on a slab (card with backdrop) | NOT OK: seen from the side, small, off-centre among plain boxes | OK | OK | sharp | plain grey, pink and olive boxes around it | **REBUILD** |
| 09.351 | Plate with Scholten Impaling Hogenberg Coat of Arms | vessel | photo on a slab (card with the photo's grey backdrop) | NOT OK: seen from the side at the top-right edge, cut by the frame top; another slab's back fills the left | OK (title line overlaps picture) | OK | sharp | upright card on a case deck among other cards | **REBUILD** |
| 2016.62 | Plate with Colebrooke Impaling Hudson Coat of Arms | vessel | photo on a slab | NOT OK: seen edge-on (11 px wide), face not visible | OK | OK | sharp | - | **REBUILD** |
| 2016.102.2 | Plate with Elephant | vessel | photo on a slab (card with backdrop) | NOT OK: seen from the side at the right edge, top cut off | OK | OK | sharp | - | **REBUILD** |
| 55.023.6H (from the code; not shown in the game) | Saldanha Platter | vessel | photo on a slab | NOT OK: a grey panel and an edge-on slab fill the view; platter face not visible | OK | NOT OK: no museum number on either card | sharp | - | **REBUILD** |
| 75.023 | Writing Desk (Schreibtisch) | furniture | plain box with the photo on its front, in a glass case | NOT OK: seen from behind and the side; a plain brown box fills the view, the photo face is a sliver | OK | OK | sharp | - | **REBUILD** |
| 54.147.9 | Mortar (with Pestle 54.147.20) | vessel | photo on a slab | NOT OK: slab seen edge-on (11 px wide), face not visible | OK | OK | sharp | - | **REBUILD** |
| 85.075.8 | Casket | case piece | photo on a slab | NOT OK: slab seen edge-on (10 px wide), face not visible | OK | OK | sharp | - | **REBUILD** |
| 43.351 | Apothecary Jar (Orciuolo) | vessel | photo on a slab | NOT OK: slab seen edge-on (13 px wide), face not visible | OK | OK | sharp | - | **REBUILD** |
| 35.703 | Plate | vessel | photo on a slab | NOT OK: slab seen edge-on (21 px wide), face not visible | OK | OK | sharp | a dark disc lies flat on an olive box in front | **REBUILD** |
| 1989.085 | March Calendar Plate | vessel | disc with the photo on its face, on a peg | NOT OK: seen at about 45 degrees | OK | OK | sharp | row of photo cards beside it | **FIX** |
| 51.502 | Apollo and the Muses on Mount Parnassus | relief (silver-gilt roundel) | disc with the photo on its face, lying flat | NOT OK: seen edge-on (11 px high), face not visible | OK (title overlaps picture) | OK | sharp | - | **FIX** |
| 51.272 | Casket | case piece | photo on a slab | NOT OK: slab seen edge-on (10 px wide), face not visible | OK | OK | sharp | - | **REBUILD** |
| 44.674 | River God (The Virile Age; The Euphrates) | sculpture in the round | photo on a slab (card with the photo's grey backdrop) on a plain white plinth | NOT OK: card seen from the side | OK | OK | sharp | plain box plinth | **REBUILD** |
| 47.625 | Tigerware Jug | vessel | photo extruded along its outline, in a case | OK: frontal, one of four in view | OK (title overlaps picture) | OK | sharp | - | **REBUILD** |
| 45.188 | Stemmed cup with cover | vessel | photo extruded along its outline, in a case | OK: frontal, one of five in view | OK (title overlaps picture) | OK | sharp | - | **REBUILD** |
| 32.010 | Cup | vessel | photo extruded along its outline, on a small grey box in a case | OK: frontal, but one of five in view and not centred | OK (title hidden behind picture) | OK | sharp | small grey box under it | **REBUILD** |
| 73.060 | Bowl | vessel | photo extruded along its outline, in a case | OK | OK | OK | sharp | - | **REBUILD** |
| 52.533 | Owl Beaker | vessel | photo extruded along its outline, on a small grey box in a case | OK | OK (title hidden behind picture) | OK | sharp | small grey box under it | **REBUILD** |
| 2000.103.3 | Dress | textile (dress on a mannequin) | photo cut to its outline, 3 cm thick, in a case (from the code; the picture shows only its edge) | NOT OK: slab seen edge-on (7 px wide), dress not visible, visitor and a brown box fill the view | OK | OK | sharp | brown box beside it | **REBUILD** |
| 06.057 | Tabernacle | relief | photo extruded along its outline, on a plain plinth; the opening is filled with the photo's white backdrop | OK | OK | OK | sharp | the opening should be see-through | **REBUILD** |

### Rockefeller room: 50 objects (REBUILD 33, FIX 13, FINE 4)

| Accession | Title | In the museum | Shown as | Inspection view | Zoom page | Caption | Image | Misplaced or mis-sized | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 44.226 | Apparel textile length | textile | flat picture in a thin pale mount | OK, visitor beside | OK (title overlaps picture) | OK | sharp | - | **FINE** |
| 2016.80.89 | Cloisters' Wood | print (watercolour) | framed, thin gilt frame with a wide mount | OK | OK | NOT OK: title line is broken white blocks | sharp | - | **FIX** |
| 2016.80.91 | A Lady in a Park | print (watercolour) | framed, thin gilt frame with a wide mount | OK | OK | NOT OK: title line is broken white blocks | sharp | - | **FIX** |
| 58.197 | Portrait of Mrs. Edwards | painting | framed painting with a 3D frame | OK | OK (title hidden behind picture) | OK | sharp | - | **FINE** |
| 2009.9 | Portrait of the Dancer, Auguste Vestris | painting | framed painting with a 3D frame | OK, visitor beside | OK (title hidden behind picture) | OK | sharp | - | **FINE** |
| 34.912 | Arabesque Wallpaper | print (wallpaper) | flat picture in a pale mount | OK, visitor beside | OK (title overlaps picture) | OK | sharp | - | **FINE** |
| 2017.74.14 | St. George and the Dragon | sculpture in the round | blob with a picture on the front, on top of the cabinet | OK | OK | OK | sharp | - | **REBUILD** |
| 2017.74.16 | The Flute Player | sculpture in the round | blob with a picture on the front, on top of the cabinet | OK | OK | OK | sharp | - | **REBUILD** |
| 2017.74.17 | Hudibras | sculpture in the round | blob with a picture on the front, on top of the cabinet | OK | OK | OK (maker line wraps, fits) | sharp | - | **REBUILD** |
| 2017.74.18.ab | Brown Bear Jug and Cover | vessel | blob with a picture on the front, on the shelf cabinet | OK: frontal, one of many in view | OK | OK | sharp | - | **REBUILD** |
| 2017.74.19 | Horn-Player | sculpture in the round | blob with a picture on the front, on the shelf cabinet | OK: frontal but small; caption covers the shelf below | OK | OK | sharp | - | **REBUILD** |
| 2017.74.15.1 | Finch | sculpture in the round | blob with a picture on the front, on the shelf cabinet | OK: frontal but tiny; caption covers the shelf below | OK | OK | sharp | - | **REBUILD** |
| 2017.74.15.2 | Finch | sculpture in the round | blob with a picture on the front, on the shelf cabinet | OK: frontal but tiny; caption covers the shelf below | OK | OK | sharp | - | **REBUILD** |
| 2017.74.21 | Figure of a Bagpiper | sculpture in the round | blob with a picture on the front, on the shelf cabinet | OK: frontal, small, one of many in view | OK | OK | sharp | - | **REBUILD** |
| 2017.74.22.ab | Brown Bear Jug and Cover | vessel | blob with a picture on the front, on the shelf cabinet | OK: frontal, one of many in view | OK | OK | sharp | - | **REBUILD** |
| 2017.74.25 | Cream Jug | vessel | blob with a picture on the front, on the shelf cabinet | OK: frontal; caption covers the shelf below | OK | OK | sharp | - | **REBUILD** |
| 2017.74.27.1 | Parrot | sculpture in the round | blob with a picture on the front, on the shelf cabinet | OK | OK | OK | sharp | - | **REBUILD** |
| 2017.74.20 | Figure of a Fox | sculpture in the round | blob with a picture on the front, on the shelf cabinet | OK | OK | OK (maker line wraps, fits) | sharp | - | **REBUILD** |
| 2017.74.27.2 | Parrot | sculpture in the round | blob with a picture on the front, on the shelf cabinet | OK | OK | OK | sharp | - | **REBUILD** |
| 2017.74.24.ab | Agateware Teapot | vessel | blob with a picture on the front, on the shelf cabinet | OK: frontal, one of many in view | OK | OK | sharp | - | **REBUILD** |
| 2017.74.23 | Figure of a Shepherd | sculpture in the round | blob with a picture on the front, on the shelf cabinet | OK | OK | OK (maker line wraps, fits) | sharp | - | **REBUILD** |
| 2017.74.28.1 | Figural Candlestick | sculpture in the round | blob with a picture on the front, on the shelf cabinet | OK: frontal, one of many in view | OK | OK | sharp | - | **REBUILD** |
| 2017.74.29 | Model of a Cow | sculpture in the round | blob with a picture on the front, on the shelf cabinet | OK: frontal, one of many in view | OK | OK | sharp | - | **REBUILD** |
| 2017.74.28.2 | Figural Candlestick | sculpture in the round | blob with a picture on the front, on the shelf cabinet | OK: frontal, one of many in view | OK | OK | sharp | - | **REBUILD** |
| 2017.74.26 | Figure of a Parrot | sculpture in the round | blob with a picture on the front, on the shelf cabinet | OK | OK | OK | sharp | - | **REBUILD** |
| 37.201 | Bust of Madame Récamier | sculpture in the round | blob with a picture on the front, on a plain box plinth | OK | OK (title overlaps picture) | OK | sharp | plain box plinth | **REBUILD** |
| not identified (candidate 2017.74.32) | Earthenware figure of a ewe and lamb | sculpture in the round | blob with a picture on the front, on the shelf cabinet | OK: frontal, one of many in view | NOT OK: a generated faceted render, not a photograph of the work | NOT OK: a working description, no maker, date or number | generated picture; the museum publishes no photograph | - | **REBUILD** |
| 2017.74.6.3 | Wall Sconce | light fitting | photo extruded along its outline, on the wall (reads as a flat gold cut-out; the code builds it as a one-picture volume) | OK | OK (title overlaps picture) | OK | sharp | - | **REBUILD** |
| 2017.74.6.4 | Wall Sconce | light fitting | photo extruded along its outline, on the wall (reads as a flat gold cut-out; the code builds it as a one-picture volume) | OK | OK | OK | sharp | - | **REBUILD** |
| 2017.74.38.1a-c | Rockefeller Service Soup Tureen with Cover on Stand | vessel | blob with a picture on the front, faceted, on a grey box | OK; caption covers the pieces below | OK | OK | sharp | grey box under it | **REBUILD** |
| 2017.74.38.3a-c | Rockefeller Service Ecuelle with Cover | vessel | blob with a picture on the front, on a grey box | OK | OK: a storage snapshot with a tag and a date stamp | OK | sharp, not a studio photograph | grey box under it | **REBUILD** |
| 2017.74.38.4ab | Rockefeller Service Pierced Basket and Stand | vessel | turned dish profile with the photo mapped on; its stand propped upright behind | OK | OK | OK | sharp | stand stands on edge behind the basket; basket round, not oval or pierced | **FIX** |
| 2017.74.38.5ab | Rockefeller Service Pierced Basket and Stand | vessel | turned dish profile with the photo mapped on; its stand propped upright behind | OK | OK | OK | sharp | stand stands on edge behind the basket | **FIX** |
| 2017.74.38.11 | Rockefeller Service Square Dish | vessel | shallow dish lying flat | seen side-on as a thin strip (38 px high) | OK | OK | sharp | square outline: cannot tell | **FIX** |
| 2017.74.38.12 | Rockefeller Service Square Dish | vessel | shallow dish lying flat | seen side-on as a thin strip (40 px high) | OK | OK | sharp | square outline: cannot tell | **FIX** |
| 2017.74.38.23 | Rockefeller Service Dinner Plate | vessel | dish with the photo on its face, propped upright | partly hidden behind the basket in front | OK | OK | sharp | - | **FIX** |
| 2017.74.38.25 | Rockefeller Service Dinner Plate | vessel | dish with the photo on its face, propped upright | partly hidden behind the basket in front | OK | OK | sharp | - | **FIX** |
| 2017.74.38.9 | Rockefeller Service Saucer | vessel | shallow turned dish under the cup | tiny; cannot be told from the cup on it | OK | OK | sharp | - | **FIX** |
| 2017.74.38.10 | Rockefeller Service Saucer | vessel | shallow turned dish under the cup | tiny; cannot be told from the cup on it | OK | OK | sharp | - | **FIX** |
| 2017.74.38.7 | Rockefeller Service Cup | vessel | blob with a picture on the front (small), on its saucer | OK but small | OK: a storage snapshot with a handwritten tag (the museum's own) | OK | sharp, not a studio photograph | - | **REBUILD** |
| 2017.74.38.8 | Rockefeller Service Cup | vessel | blob with a picture on the front (small), on its saucer | OK but small | OK: a storage snapshot with a handwritten tag (the museum's own) | OK | sharp, not a studio photograph | - | **REBUILD** |
| 2017.74.39.18a-c | Dragons-in Compartments pattern covered tureen and stand | vessel | blob with a picture on the front | OK | OK | OK | sharp | - | **REBUILD** |
| 2017.74.39.19a-c | Dragons-in Compartments pattern covered sauce tureen and stand | vessel | blob with a picture on the front | OK | OK | OK | sharp | - | **REBUILD** |
| 2017.74.39.3 | Dragons-in Compartments pattern compote | vessel | blob with a picture on the front, low, in a case | seen side-on; foot not visible | OK | OK | sharp | - | **REBUILD** |
| 2017.74.39.12 | Dragons-in Compartments pattern square bowl | vessel | shallow dish lying flat in a case | seen side-on as a thin strip | OK | OK | sharp | - | **FIX** |
| 2017.74.39.13 | Dragons-in Compartments pattern square bowl | vessel | shallow dish lying flat in a case | seen side-on as a thin strip | OK | OK | sharp | - | **FIX** |
| 2017.74.39.2 | Dragons-in Compartments pattern dish | vessel | shallow dish lying flat in a case | seen side-on as a thin strip | OK | OK | sharp | - | **FIX** |
| 2017.74.39.20 | Dragons-in Compartments pattern ladle | vessel | blob with a picture on the front, lying in front of the tureen | small; hard to pick out | OK | OK | sharp | - | **REBUILD** |
| 2017.74.31.1 | Neptune as River Deity | sculpture in the round | blob with a picture on the front, on a plain white box plinth | OK | OK | OK | sharp | plain box plinth | **REBUILD** |
| 2017.74.31.2 | Amphitrite as River Deity | sculpture in the round | blob with a picture on the front, on a plain white box plinth | OK | OK | OK | sharp | plain box plinth | **REBUILD** |

### grey French gallery: 10 objects (REBUILD 1, FIX 0, FINE 9)

| Accession | Title | In the museum | Shown as | Inspection view | Zoom page | Caption | Image | Misplaced or mis-sized | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 43.539 | A Cart Loaded with Kegs (Le Haquet) | painting | framed painting with a 3D frame | OK | OK (title overlaps picture) | OK | sharp | - | **FINE** |
| 2023.53 | Landscape with shepherdess, sheep and cows | painting | framed painting with a 3D frame | OK | OK (title hidden behind picture) | OK | sharp | - | **FINE** |
| 73.120 | Landscape | painting | framed painting with a 3D frame | OK | OK | OK | sharp | - | **FINE** |
| 56.099 | The Celian Hill from the Palatine | painting | framed painting with a 3D frame | OK | OK (title hidden behind picture) | OK | sharp | - | **FINE** |
| 56.094 | The Colosseum | painting | framed painting with a 3D frame | OK | OK | OK | sharp | - | **FINE** |
| 1998.35 | View of a Roman Aqueduct, near Tivoli | painting | framed painting with a 3D frame | OK | OK | OK | sharp | - | **FINE** |
| 43.571 | Jura Landscape (Paysage de Jura) | painting | framed painting with a 3D frame | OK | OK (title hidden behind picture) | OK | sharp | - | **FINE** |
| 24.089 | Banks of a River Dominated in the Distance by Hills | painting | framed painting with a 3D frame | OK | OK | OK | sharp | - | **FINE** |
| 56.214 | Tivoli | painting | framed painting with a 3D frame | OK; visitor's head shows under the caption | OK (title hidden behind picture) | OK | sharp | - | **FINE** |
| 23.005 | The Hand of God | sculpture in the round | blob with a picture on the front, on a plain box plinth | OK, visitor beside | OK (title overlaps picture) | OK | sharp | plain box plinth | **REBUILD** |

### modern painting gallery: 6 objects (REBUILD 0, FIX 2, FINE 4)

| Accession | Title | In the museum | Shown as | Inspection view | Zoom page | Caption | Image | Misplaced or mis-sized | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 48.248 | Still Life | painting | framed painting with a 3D frame | OK | OK | OK | sharp | - | **FINE** |
| 70.058 | Head of a Woman | painting | framed painting: white rectangular frame with an oval opening | OK, visitor beside | OK (title overlaps picture) | OK | sharp | - | **FINE** |
| 1995.043 | Mountaineers Attacked by Bears | painting | framed painting with a thin 3D frame | NOT OK: caption covers the lower third | OK (title hidden behind picture) | OK | sharp | - | **FIX** |
| 57.037 | The Green Pumpkin | painting | framed painting with a 3D frame | OK, visitor beside | OK (title hidden behind picture) | OK | sharp | - | **FINE** |
| 43.255 | On the Banks of a River (Au Bord d'une Rivière) | painting | framed painting with a 3D frame | OK | OK (title overlaps picture) | OK | sharp | size against frame: cannot tell | **FINE** |
| 67.089 | Seated Woman | sculpture in the round | hand-modelled faceted solid in a wall case (seen only in the room view, too small to judge its likeness) | NOT OK: the work is hidden behind the visitor's head; only blinds and wall show | OK (title overlaps picture) | OK | sharp | - | **FIX** |

### Skylight Gallery: 5 objects (REBUILD 0, FIX 5, FINE 0)

| Accession | Title | In the museum | Shown as | Inspection view | Zoom page | Caption | Image | Misplaced or mis-sized | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 69.094 | Untitled | painting | flat canvas, no frame (contemporary) | NOT OK: the black box piano covers the lower right corner; visitor beside | OK | OK | sharp | - | **FIX** |
| 2025.19 | Spectrum II | painting | flat canvas, no frame (contemporary) | OK, visitor beside | NOT OK: blurry | OK | soft | - | **FIX** |
| 73.018 | Distorted Circle within a Polygon II | painting | flat shaped canvas, no frame (contemporary) | NOT OK: the black box piano covers the lower left | OK (title overlaps picture) | OK | sharp | - | **FIX** |
| 2026.3 | Foreign Sign | painting | flat canvas, no frame (contemporary) | OK, visitor beside | NOT OK: blurry | OK | soft | - | **FIX** |
| 2000.17 | Pile | painting | flat canvas with depth, no frame (contemporary, unframed is plausible) | NOT OK: caption covers the lower third | OK | OK | sharp | - | **FIX** |

### lion stair landing: 1 objects (REBUILD 0, FIX 1, FINE 0)

| Accession | Title | In the museum | Shown as | Inspection view | Zoom page | Caption | Image | Misplaced or mis-sized | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 34.652 | Panel with Striding Lion | relief | flat picture in a thin pale tray frame on the wall | OK | OK | OK | sharp | low relief shown flat | **FIX** |

### marble stair hall: 2 objects (REBUILD 1, FIX 1, FINE 0)

| Accession | Title | In the museum | Shown as | Inspection view | Zoom page | Caption | Image | Misplaced or mis-sized | Verdict |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 83.152 | Fireplace Surround | architectural piece | photo extruded along its outline | NOT OK: the stair rail and balusters cross in front of it; visitor beside | OK but shown small because the picture is tall; an in-gallery photograph with wall, floor and a wall label in it (title overlaps picture) | OK (maker line wraps to two lines, fits) | sharp | stands behind the stair | **REBUILD** |
| 2011.60 | Gilded Frost and Jet Chandelier | light fitting | cannot tell: never in any playtest picture (the builder calls it a procedural chandelier) | NOT OK: cannot be clicked from in front of it | NOT OK: no page, because it cannot be clicked | cannot tell: no caption ever shown | cannot tell (the build holds a 600 x 450 px picture) | cannot tell: it hangs above the top of every view | **FIX** |
