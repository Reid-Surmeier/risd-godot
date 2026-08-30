# The icon set

## What this is

The icon system for the Godot collection-browser game. Reid drew five icons first — filter, highlights, is-sculpture, has-image, see-in-3D — in a glossy isometric early-2000s style (Windows XP Luna / Frutiger Aero family). This note records the grammar those five establish, fifty icons specified against it, and which of them already exist in licensed icon sets rather than needing to be drawn.

Live version of batch one: https://claude.ai/code/artifact/ea9e3ecc-4139-4e3e-b1fc-9393a9857a76

## The grammar

Three materials, and the material carries the meaning:

- **Marble white** is the object. A thing from the collection.
- **Cobalt blue** is the verb. The action being taken on the object.
- **Gold** is attention or reward, and nothing else. Never colour a noun gold.

Five compositions, all derived from the original five:

| Pattern | Source icon | Description |
| --- | --- | --- |
| P1 Pure tool | filter | All cobalt, no marble. The icon *is* the instrument. |
| P2 Tool + emission | highlights | A cobalt instrument throwing gold. Gold is the verb's output. |
| P3 Object on plinth | sculpture | Marble form on a cobalt plinth. The category-filter family. |
| P4 Object + corner badge | has image | Small square badge lower-right. State, not category. |
| P5 Object + verb wrap | see in 3D | Cobalt arrows embracing a marble form. Transforms in place. |

Rules:

- **One light.** Upper-left, hard. 1–2 px specular top-left, two-pixel core shadow bottom-right, one soft contact ellipse.
- **One warm pixel.** At most one gold element per icon. Two golds and neither reads.
- **Silhouette test.** Fill flat black at 32 px. If you cannot name it, redraw the outer shape before shading.

Build spec: 64x64 canvas, also export 32 and 16. 2:1 isometric, three-quarter top-down. 2 px outline at #0D1E4D. Four-step ramp per material. Contact shadow a 2 px ellipse at 40% alpha.

Palette:

| Token | Hex |
| --- | --- |
| Cobalt deep | #12307E |
| Cobalt | #2059D8 |
| Cobalt lit | #58A3F5 |
| Marble | #EFE9DD |
| Marble shade | #B6AC99 |
| Gold | #F0B323 |
| Gold lit | #FFE08A |

## Batch one — 25 icons

Reid selected 23 of these across two rounds on 2026-08-29. NAV-04 Wing dial was reinstated in round two. Two remain unselected: MED-04 Deep zoom and MED-05 Record only. They are kept here rather than deleted.

### A · Media and state — pattern P4

**MED-01 · Has video** — Object has moving image: a process film, an interview, a performance record.
- Form: marble frame with a dark navy screen; cobalt film-strip badge overlapping lower-right, sprocket holes punched through.
- Tell: a gold play triangle inside the badge, the only warm pixel.

**MED-02 · Has audio** — An audio guide stop, oral history, or recorded sound exists.
- Form: the record frame with a cobalt gramophone-horn badge, bell turned three-quarters toward the viewer.
- Tell: three gold arcs stepping out of the bell, each a pixel thinner than the last.

**MED-03 · Multiple views** — More than one photograph: verso, detail, installation, before conservation.
- Form: three frames fanned back and left, front one full marble with its picture intact.
- Tell: the two rear frames drop all interior detail and flatten to cobalt silhouettes, so the stack reads as depth not clutter.

**MED-04 · Deep zoom** *(not selected)* — Gigapixel capture; push in to brushstroke level.
- Form: a cobalt loupe over the corner of a canvas, glass one step lighter than the ground beneath.
- Tell: the weave inside the lens drawn at 4x the pixel size of the weave outside it.

**MED-05 · Record only** *(not selected)* — Catalogued but unphotographed.
- Form: an empty frame desaturated toward marble-shade, a typed catalogue card standing in front.
- Tell: no cobalt anywhere. Absence drawn as absence.

### B · Collection departments — pattern P3

**DEP-01 · Painting**
- Form: a small canvas in a gold-cornered frame on the plinth, turned three-quarters so its left edge shows.
- Tell: two stretcher bars on that turned edge. It says object, not image.

**DEP-02 · Prints and drawings**
- Form: a printed sheet lifting off its block at the near corner, a cobalt baren disc alongside.
- Tell: the curl of the paper, two rows of carved relief showing on the block underneath.

**DEP-03 · Costume and textiles**
- Form: a marble dress form on the plinth, no head, shoulders squared, cobalt tape measure looped once at the waist.
- Tell: the tape's loose tail hanging down the front, one gold pin at the left shoulder.

**DEP-04 · Silver and decorative arts** — the Gorham holdings; Providence's own industry.
- Form: a bellied teapot in polished marble-white, cobalt reflections pooled in the lower curve, spout left.
- Tell: a four-pixel gold star glint on the shoulder of the pot.

**DEP-05 · Ancient Egypt**
- Form: a canopic jar with a jackal-head stopper, cobalt banding at neck and base.
- Tell: the silhouette deliberately breaks the bust shape. Animal head over a cylinder survives 32 px where a sarcophagus would read as a blob.

**DEP-06 · Asian art**
- Form: a Buddha head on the plinth, eyes closed, ears long, shown frontally rather than three-quarters.
- Tell: gold on the ushnisha and urna only, so it never competes with DEP-04's glint.

### C · Gallery and wayfinding

**NAV-01 · On view now** — this object is in a gallery you can walk to.
- Form: a gallery doorway at three-quarters, cobalt jamb, dark interior, warm light spilling across the floor toward the viewer.
- Tell: the gold floor-spill wedge. The light says open, not the door.

**NAV-02 · In storage** — catalogued but not on the floor. Pairs with NAV-01 as one toggle.
- Form: a stencilled wooden crate in marble-shade timber, cobalt steel banding at the corners, lid shut.
- Tell: a stencilled accession number in navy across the face, and no gold at all. The exact negative of NAV-01.

**NAV-03 · Gallery map**
- Form: an isometric folded floorplan, rooms in two cobalt values, two fold creases.
- Tell: a gold pin standing proud of the paper with its own hard shadow. The only element with height.

**NAV-04 · Wing dial** *(selected, round two)*
- Form: a brass-and-cobalt elevator dial, arc of ticks across the top, bevelled housing.
- Tell: the gold needle off-centre right, the only asymmetric element.

### D · The record

**REC-01 · Provenance** — chain of ownership.
- Form: three small marble labels on a cobalt chain, descending and diminishing toward the back.
- Tell: the topmost label is blank. Provenance runs out, and drawing that gap is more honest than a complete chain.

**REC-02 · Date and era**
- Form: a marble hourglass in a cobalt frame, bulbs slightly flattened so it does not read as a bow tie.
- Tell: cobalt sand mid-fall, a single one-pixel column between the bulbs.

**REC-03 · Maker** — artist, workshop, or unidentified.
- Form: a nameplate on an angled stand, cobalt plate with a bevelled marble edge, quill laid diagonally across.
- Tell: the engraving is three carved pixel strokes, never letterforms. Real text turns to mud below 48 px.

**REC-04 · Materials and technique**
- Form: a chisel and a brush crossed over a cobalt disc, marble handles, cobalt ferrules.
- Tell: the chisel bevel is the brightest cluster, at the crossing point where the eye lands.

**REC-05 · Dimensions** — pattern P5.
- Form: a cobalt tape arcing around a marble cube, hooked over the near corner.
- Tell: evenly spaced gold ticks. Without them it is a ribbon; with them it is a measurement.

### E · Player and collection

**ACT-01 · Favourite** — add to my collection.
- Form: a shallow cobalt velvet tray from above-front, gold star seated in the well.
- Tell: the star casts its shadow *inside* the well. Empty state: same tray, star as a two-pixel outline.

**ACT-02 · Compare** — hold two objects side by side.
- Form: two frames shoulder to shoulder, left marble and detailed, right flat cobalt and waiting.
- Tell: a single bright gold column dead centre, full height. Reads as a seam, not a decoration.

**ACT-03 · Sketchbook** — draw from the object.
- Form: a spiral-bound book open flat, cobalt pencil in the gutter, a bust in loose line on the right page.
- Tell: the drawing is unfinished, the contour stops halfway down the shoulder. An invitation, not a record.

**ACT-04 · More like this**
- Form: one marble bust forward, two smaller cobalt busts set back left and right, joined by hairline cobalt nodes.
- Tell: only the front bust has a face. The satellites are pure silhouette; the hierarchy is the meaning.

**ACT-05 · Random object** — the serendipity button, and the best answer to an empty search.
- Form: a card-catalogue drawer half open, cobalt front, brass-gold pull, one card flying up and out.
- Tell: gold sparkle at the card's top corner with two motion streaks below. The only icon depicting an instant rather than a state.

## Batch two — 25 more

Proposed 2026-08-29. Reviewed the same day: **B departments (all five), NAV-05/06/07, REC-06 to REC-09 and all five UI chrome icons are selected.** The five media badges (MED-06 to MED-10) and the three player icons (ACT-06 to ACT-08) are not yet reviewed. Two more were requested in review and are specified at the end of section E.

### A · Media and state — pattern P4

**MED-06 · Point cloud** *(unreviewed)* — a 3D scan exists. Distinct from see-in-3D, which is the verb.
- Form: the record frame with a cobalt badge holding a bust rendered only as scattered dots, density heavier along the contour.
- Tell: the dots thin to nothing at the top of the head. Scans always fail somewhere, and that honest gap is what separates this from a solid silhouette.

**MED-07 · Conservation view** *(unreviewed)* — X-ray, UV, raking light.
- Form: the marble bust with three cyan-cobalt scan bands crossing horizontally; inside the bands the form goes negative, dark where it was light.
- Tell: an old repair drawn as a bright seam visible only inside one band.

**MED-08 · Verso** *(unreviewed)* — the back of the object is photographed.
- Form: a frame flipped face-down showing the stretcher cross-brace, two paper collection labels and a wax stamp.
- Tell: the labels are the subject, not the canvas. Slightly askew, one corner lifting.

**MED-09 · Detail crops** *(unreviewed)* — curated close-ups.
- Form: a marble frame with a cobalt crop rectangle pulled out of its lower-right quadrant, floating forward with a hard shadow.
- Tell: four one-pixel L brackets at the crop's corners.

**MED-10 · Colour palette** *(unreviewed)* — dominant colours extracted from the image.
- Form: five chips fanning out of the frame's edge like a paint deck, each flat colour with a bevelled marble border.
- Tell: the only icon in the set allowed hues outside cobalt, gold and marble. That exception is the whole point.

### B · Collection departments — pattern P3

**DEP-07 · Photography**
- Form: a plate camera on the plinth, marble bellows extended, cobalt body, lens board three-quarter turned.
- Tell: four visible bellows pleats alternating light and shade. Nothing else in the set has that rhythm.

**DEP-08 · Furniture**
- Form: a blockfront chest on the plinth, three drawers, cobalt brasses, the front reading as two convex bays and one concave.
- Tell: the shell carving on the top drawer, six radiating marble ridges, no gold.

**DEP-09 · Ceramics and glass**
- Form: a footed amphora on the plinth, marble body, cobalt banded ornament at the shoulder, two handles.
- Tell: one handle drawn in front of the body and one behind. That is what sells roundness at 32 px.

**DEP-10 · Contemporary**
- Form: a cobalt neon tube bent into a loose knot, hovering above the plinth rather than resting on it, thin gold glow bleeding onto the plinth top.
- Tell: the only department icon whose object does not touch its plinth.

**DEP-11 · Coins and medals**
- Form: three discs on the plinth, two lying flat and overlapping, one standing on edge behind, marble with cobalt relief.
- Tell: the standing disc shows a profile head in two-pixel relief; the flat ones show only rim.

### C · Gallery and wayfinding

**NAV-05 · In this room** — other objects near this one.
- Form: a plan fragment of a single gallery, cobalt walls, four small marble dots on the floor and one gold dot.
- Tell: the gold dot is the object you are on, and the walls are cut off at the canvas edge so it reads as a fragment, not a whole map.

**NAV-06 · Not accessible** — closed gallery, deinstalled, restricted.
- Form: the NAV-01 doorway with a cobalt barrier rope across it and the interior light switched off.
- Tell: the rope's catenary sag. A straight bar reads as a prohibition sign; a sagging rope reads as a museum.

**NAV-07 · Sit with it** — a bench, a slow-looking prompt.
- Form: a gallery bench in three-quarter view, marble slab seat, cobalt legs, empty.
- Tell: a long soft shadow pooling under it, longer than any other icon's. That is how emptiness reads as invitation.

### D · The record

**REC-06 · Accession number**
- Form: a catalogue card standing upright, cobalt rule lines, a punched rod hole at the bottom centre.
- Tell: the number typed as evenly spaced two-pixel blocks top-left, never legible glyphs.

**REC-07 · Credit line** — how it came to the museum, and from whom.
- Form: a small brass-cobalt donor plaque on two legs, face polished enough to hold a marble reflection.
- Tell: one gold highlight running the full width of the top bevel.

**REC-08 · Exhibition history** — where this object has been shown.
- Form: three exhibition banners hanging at different depths, front marble, rear two cobalt, each a different length.
- Tell: the staggered bottom edges. Equal lengths read as a flag row; unequal reads as a history.

**REC-09 · Condition** — stable, fragile, under treatment.
- Form: a marble bust with a fine cobalt crack from temple to jaw and a small cobalt caliper measuring it.
- Tell: the crack is one pixel wide and never breaks the outline. Damage inside an intact silhouette.

### E · Player and collection

**ACT-06 · Send a postcard** *(unreviewed)*
- Form: a postcard at a slight angle, marble face with a cobalt image block, gold stamp upper-right.
- Tell: three cobalt address rules on the right half, so it reads as back and front at once. That contradiction is how a postcard is recognised.

**ACT-07 · Visit stamps** *(unreviewed)* — the passport of what you have seen.
- Form: an open passport spread, marble pages, cobalt cover, a gold rubber stamp mid-strike above with its shadow on the page.
- Tell: two stamps already landed and rotated off-square. Perfect alignment kills it.

**ACT-08 · Ask a curator** *(unreviewed)*
- Form: a marble bust with a cobalt speech bubble rising from behind its left shoulder, tail pointing down to the bust.
- Tell: one gold question mark inside, and the bubble overlaps the bust outline so the two share a plane.

### F · Interface chrome — new group, all selected

The browser has no utility icons yet. A results grid cannot ship without these, and they are the ones most likely to be adaptable from an existing set rather than drawn.

**UI-01 · Search**
- Form: a cobalt magnifier over a marble bust, the bust cropped by the lens rim so only an eye and brow show inside.
- Tell: what is inside the glass is a fragment, not a whole small bust. Fragments read as searching.

**UI-02 · Clear filters**
- Form: the existing funnel, upright and empty, one gold droplet falling clear of the spout.
- Tell: reuse the original funnel exactly and change only its contents. The pairing is the meaning.

**UI-03 · View toggle** — grid or list.
- Form: a hinged cobalt plate, left half a 2x2 of marble tiles, right half three stacked marble rules, folded so one half faces the viewer.
- Tell: the fold. Two flat halves side by side read as a diagram; the fold reads as a switch.

**UI-04 · Sort order**
- Form: three marble frames stacked stepwise, largest forward, a cobalt arrow running down their left edges.
- Tell: the arrowhead is gold and sits at the bottom, so direction reads before the shapes do.

**UI-05 · Visitor badge** — your account, your session, your saved work.
- Form: a lanyard badge hanging askew, cobalt clip, marble card, small gold sticker in the corner.
- Tell: the cord runs off the top edge of the canvas. Nothing else in the set breaks the frame.

## Existing icons that could work

The useful split, and it falls exactly along the grammar: **the verbs have already been drawn by somebody else; the nouns have not.** Every cobalt instrument in this set — search, sort, compare, filter, clear, link, measure, time — exists in the early-2000s open-source icon themes in the same glossy isometric idiom. Every marble object — the bust, the plinth, the dress form, the canopic jar, the teapot, the crate — has to be original, and that is precisely what makes the set look like this museum instead of a desktop.

### Sources worth mining, with licences

| Source | What it is | Licence | Use |
| --- | --- | --- | --- |
| [Crystal Project](https://www.iconfinder.com/iconsets/crystalproject) by Everaldo Coelho | ~2,488 icons, glossy blue, isometric, ships at 64x64 — the closest existing match to this style | LGPL | Best candidate. Adapt directly. |
| [Crystal Clear](https://www.iconarchive.com/show/crystal-clear-icons-by-everaldo.html) | 509 icons, same author, earlier | LGPL | Same. |
| [Nuvola](https://en.wikipedia.org/wiki/Nuvola) by David Vignoni | ~600 icons, softer and rounder than Crystal | LGPL 2.1 + addendum | Second choice; PNG and SVG. |
| [game-icons.net](https://game-icons.net/) | 4,180+ flat monochrome game icons | CC-BY 3.0, some public domain | Not the style, but ideal for the silhouette-first step. |
| [The Spriters Resource — PlayStation 2](https://www.spriters-resource.com/playstation_2/) | Ripped sprite and UI sheets, including an Essential PlayStation 2 UI sheet from the UK demo discs | Copyrighted game assets | **Reference only. Never ship.** |
| [Frutiger Aero Archive](https://frutigeraeroarchive.org/icons) | Curated archive of 2000s glossy icon sets and skins | Mixed, mostly unclear | Mood and reference. |

Note on LGPL: repainting or tracing a Crystal icon produces a derivative work, which stays LGPL and needs the licence text and attribution shipped with the game. Using one only as a *style* reference carries no obligation — style is not copyrightable, specific artwork is. The same line applies to the Windows XP Luna icons this whole set is descended from: the look is free, the files are Microsoft's.

### Likely Crystal Project matches to check

Filenames below are from KDE icon-naming convention and are **unverified** — download the set and grep before trusting any of them.

- UI-01 Search → `kfind`, `viewmag`
- UI-02 Clear filters → `filter`, `edit-clear`
- UI-03 View toggle → `view_icon`, `view_detailed`, `view_multicolumn`
- UI-04 Sort order → `sort_incr`
- ACT-02 Compare → `kompare` (the KDE diff icon is already two panels)
- ACT-01 Favourite → `bookmark`, `favorites` (already a gold star)
- ACT-05 Random → `roll`, `shuffle`
- ACT-06 Postcard → `mail_send`, `kmail`
- ACT-08 Ask a curator → `chat`, `kopete`
- MED-01 Has video → `video`, `film`, `kmplayer`
- MED-02 Has audio → `sound`, `kmix`
- MED-03 Multiple views → `image`, `kview`
- MED-04 Deep zoom → `viewmag+`
- REC-01 Provenance → `attach`, `link`, `chain`
- REC-02 Date and era → `history`, `clock`, `date`
- REC-04 Materials → `colorize`, `kolourpaint`
- REC-05 Dimensions → `kruler`, `measure`
- NAV-02 In storage → `package`, `kpackage`, `tar`
- UI-05 Visitor badge → `personal`, `identity`

Everything under **B · Departments** has no match anywhere and must be drawn. So must the plinth, the bust, MED-06 point cloud, MED-08 verso, NAV-07 bench, REC-08 exhibition history, and ACT-03 sketchbook.

## PS2-era references

The more useful question than "which PS2 icons can I take" is "which PS2-era games already solved a collection browser". Four worth studying, all for their interface logic rather than their art:

1. **Dark Cloud 2** (2002) — the camera and invention system is literally photograph an object, catalogue it, and unlock from the catalogue. The closest existing analogue to this game's core loop.
2. **Animal Crossing** (2001, GameCube) — the museum donation UI, and the difference it draws between an object you own, an object you have donated, and an object you have only seen.
3. **Katamari Damacy** (2004) — the collection grid, and how it makes an inventory of hundreds of objects feel like an achievement rather than a spreadsheet.
4. **Ico** and **Shadow of the Colossus** (2001, 2005) — for restraint. Almost no chrome at all, which is the argument against adding all fifty of these icons at once.

For actual pixels, the PlayStation 2 section of The Spriters Resource holds ripped UI sheets, and there is an Essential PlayStation 2 UI sheet taken from the UK demo discs — the system browser and memory-card interface. Copyrighted; study the bevels and the drop shadows, do not ship the files.

## Open questions

- Which repository does the Godot game live in? This note sits with the RISD Museum 3D Scans Website project because the icon set describes the same collection browser, but the Godot build was not located on disk on 2026-08-29.
- The department icons lean on RISD's signature holdings — Gorham silver, the Egyptian funerary material, the monumental Japanese Buddha, the costume and textiles collection. Those were written from memory and should be checked against the online collection before any form is committed to, since the specific object chosen is what makes each icon read as *this* museum.

### E · Player — two more, requested in review

**ACT-09 · Download image** — take the picture files with you, at the size you need.
- Form: a marble photograph sliding down into a shallow cobalt tray, three size chips fanned at the tray's lip like paper edges, largest at the back.
- Tell: the sheet is caught most of the way in, top edge still above the rim, and the gold arrow on it is short. It reads as arriving, not falling.

**ACT-10 · Download 3D scan** — the mesh files, at the resolution you can carry.
- Form: the marble bust drawn as wireframe over the same cobalt tray as ACT-09, its surface split into three vertical bands of decreasing polygon density.
- Tell: the density steps visibly between bands rather than blending. Three steps, never a gradient — the step *is* the resolution choice, and a gradient dies at 32 px.

Both reuse ACT-09's tray, the same way UI-02 reuses the original funnel. Reuse across a pair is now a fourth rule of the grammar: when two icons name the same verb on different objects, the verb is drawn identically.

## Production

Fifty-two icons is production work, not drawing practice. Charting is under way with `/wayfinder` against `Reid-Surmeier/Qwen-3-pro-Pipeline`; the intended route is the existing Asset Pass path (Qwen image pipeline) for the still icon, then the Seedance addon for the animation loop. Reference authority for the pixel treatment is Reid's own five icons plus the Ragnarok Online JP inventory window — soft blue-grey contact shadow, hard 2 px outline, no anti-aliasing on the silhouette. Every icon ships in two variants, with and without that drop shadow.

See the map issue on the Qwen pipeline repo for the open decisions.
