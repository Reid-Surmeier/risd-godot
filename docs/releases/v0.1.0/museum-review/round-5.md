VERDICT: NOT DONE

# Independent museum playtest, round 5 — 8 October 2026

Reviewer: Claude (Opus 5.5), working alone, browser only. No game code, assets or git state changed. Owner deadline: Friday 9 October 2026, 13:00 EDT.

**Build.** `d284e66e`, played as `https://windows-wsl.taile06c45.ts.net/museum-latest-75d82bf6/d284e66e.html` between 14:14 and 15:00 EDT. Every load named that page. At 14:59 the link itself began redirecting to `10f7c0b9.html`; I stopped, told the lead, and on the lead's word spent one more fresh load on `10f7c0b9`. Everything in this report is `d284e66e` except the section "Build 10f7c0b9" near the end. The verdict holds for both.

**How.** GPU headless Chrome (ANGLE gl-egl on the RTX), 1280 × 800, real key and mouse events. Five fresh loads: three for the first doorway, one for the Hall checks, and that fourth load carried on as one 45-minute session with 72 room changes. 50 doorway legs were recorded at 15 frames a second and read as contact sheets; the first doorways were recorded at 30 and 60. Positions and frame gaps come from the game's opt-in `?qa-perf` probe. Brightness and black share were read inside the page on every game frame (`performance.now()` after the game's own frame callback), or from the screencast where the probe was off.

**Words.** VERIFIED: I reproduced it and looked at it. INFERRED: concluded without reproducing. KNOWN: in round 4, the census or the builder's listed limits. NEW: in none of them. "Black share" is the part of the game picture darker than 14 in 255.

## What changed since round 4

| # | Change | Result | Number |
| --- | --- | --- | --- |
| 1 | Room vanishing to black before the wipe, seven doors | **FIXED for a straight crossing. NOT FIXED for a diagonal or a sidestep** at the Skylight, Hall and Rockefeller doors (finding 2) | Straight, centre line and 0.3–0.5 m either side: biggest one-frame rise in black 1–4 points at all seven doors (round 4: 41–58 points). Diagonal, Skylight → grey: 12% → 53% in one frame |
| 2 | Hall inspection from a fresh load | **FIXED** | S2 57.227 opened twice before leaving the Hall: the work fills the upper picture, no blank or black wall on any of 238 frames in or back |
| 3 | "Other wall" during a room change | **FIXED** | Hidden from the first frame after the change at three doors (Hall → medieval with only the Hall built, medieval → Hall, grey → Hall); 14 presses ignored, view never turned |
| 4 | Zoom caption over a magnified picture | **FIXED** | Caption put away at one notch and fully in, back at the fitted size; Hall work S2 and added-room work 29.280 |
| 5 | Click on a dark doorway, low and high | **WORKS, with a fault** (finding 5) | Portal clicked high: stops 0.15 m past the door line. Grey gallery's Hall door clicked low: stops 0.5 m past. Both open with a black band |
| 6 | First doorway | **NOT FIXED** (finding 1) | Black 15.3–16.3 s, one frozen frame of 14.4–15.2 s, keys answer 17.2–17.7 s after the room change, on four of four first doorways. A second black after the room is shown: **not seen**, 0 of 381 frames after opening |
| 7 | Casings, reveal, ceilings, EXIT signs, three sculptures | Mixed (findings 3, 7, 9, 10) | All three sculptures open, caption and zoom correct. The Renaissance reveal reads as a black hole. The ceilings cannot be seen in the default view; their effect is that the rooms under them are the dimmest hung rooms |

## What works

VERIFIED on `d284e66e`:

- All 13 doorways were crossed both ways at a walk (50 recorded legs). Keys answer 2.46–2.58 s after the doorway on 34 of 35 timed crossings; the picture is black 0.98–1.23 s. The visitor never ended outside the floor.
- No flicker. In a walked square in each of nine rooms, plus the length of the European gallery and of the Hall, 5,379 frames were sampled: no frame differs from both its neighbours by more than 2.5 in 255. No frame took longer than 100 ms in any of them.
- No page error, no failed request, no `SCRIPT ERROR` in 45 minutes and 72 room changes. Console as before: 229 invalid-UID warnings a load.
- Captions are right on the six works opened: S2 57.227, Head of Christ 59.131, Saint Peter 20.254, Angel 37.114, The Woodcutters 29.280, Velvet Cover 23.307X. Each zoom page showed the picture with its caption under it.
- Furniture stops the visitor in the five places walked into (Hall bench, European pedestals, modern bench, Rockefeller chair, medieval cases). Nothing was walked through.
- EXIT signs are lettered where seen: the stone portal's Hall side, the European gallery's north door, the grey gallery's Hall door, the purple connector.

## Findings, in the order a visitor meets them

### 1. The first doorway is still black and frozen for about a quarter of a minute.

**VERIFIED · BLOCKS · KNOWN (round 4 finding 1) · NOT FIXED.** What a visitor sees: the wipe closes on the first doorway and the picture stays black, still and silent for 15 to 16 seconds; nothing says the game is working. Where: the first doorway used after loading; stone portal and the Hall's grey door; keys or a click. Reproduce: (1) open the page fresh; (2) click the floor, hold W into the dark doorway; (3) count.

| Fresh load | First door | Black on screen | Page frozen (one frame) | Keys answer after the room change | Black again after the room is shown |
| --- | --- | --- | --- | --- | --- |
| 1, probe and in-page sampler | stone portal, W held | 15.9 s | 14.9 s | 17.7 s | no, 0 of 129 frames |
| 2, probe and in-page sampler | Hall's grey door, key held | 15.3 s | 14.4 s | 17.2 s | no, 0 of 157 frames |
| 3, no probe, no sampler, 60 fps screencast | stone portal, W held | 16.3 s | 15.2 s | not timed | no, 0 of 95 frames |
| 4, after 4.5 minutes idle in the Hall | stone portal, by a click on its dark | 16.2 s | 15.1 s | not timed | no |

First picture: 20.5, 19.9, 20.8 and about 20 s. The game's probe splits the freeze into 11.4–11.9 s and 2.5–3.6 s. `REMODEL_READY` is logged 10–11 s into the black: the added rooms are still built at the first doorway, also when the visitor has stood in the Hall for minutes first. Round 4 measured 16.2–17.6 s on `8df78247`. The lead's "room appears, one or two black frames, room again" was not reproduced on any of the four.

Evidence: [portal](../../../evidence/review-round-5/01-first-doorway-portal-15.9s-black.jpg), [grey door](../../../evidence/review-round-5/02-first-doorway-grey-15.3s-black.jpg), [no probe](../../../evidence/review-round-5/20-first-doorway-no-probe-16.3s-black.jpg); per-frame rows `F-portal-49722-lum.json`, `F-grey-65585-lum.json`.

### 2. Step sideways in a deep doorway, or cross it on a diagonal, and the room vanishes to black.

**VERIFIED · BLOCKS · KNOWN picture (round 4 finding 2), NEW trigger.** What a visitor sees: standing between the cheeks of the doorway, half a metre off its centre line, the room's walls are gone in one frame; paintings, a door leaf and the casing hang in black. It stays that way for as long as the visitor stands there, and a wipe started from there closes on that picture. Where: Skylight Gallery's door (from inside the Skylight), the grey gallery's Hall door (from the grey side), Rockefeller's door to the European gallery (from Rockefeller); default view; walk. Reproduce: (1) in the Skylight Gallery stand left of the door's centre line; (2) hold W and A together into the doorway; (3) watch the quarter-second before the wipe.

| Where | Input | Change in one frame | Lasts |
| --- | --- | --- | --- |
| Skylight → grey | W+A from (-0.6, -34.6) | black share 12% → 53%, 0.26 s before the room change | through the closing wipe |
| grey → Hall | W+A from (-0.5, -27.8) | black share 24% → 48% | the visitor wedges on the door cheek at (0.6, -26.65); no wipe; room stays gone |
| Skylight door, standing in it at (0, -33.53) | A, then D | mean brightness 111 → 63 (three times, both cheeks) | 2.6 s, until stepping back to the centre |
| grey gallery's Hall door, standing at (0, -26.67) | A, then D | 52 → 34, 42 → 35, 52 → 33.5 | 2.6 s |
| Rockefeller, by the European-gallery door | W to the door 0.1–0.3 m right of centre, then A | 67 → 44 or 45, on 3 of 4 runs (not on the one that came up 0.5 m left of centre) | until stepping away |
| the grey side of the Skylight door, same sidesteps | | none | |
| the same three doors walked straight through, centre and 0.3–0.5 m off | W | 1–2 points | |

INFERRED: the cut-away still drops the room when the visitor is inside the reveal and near a cheek; the fix covers the centre of the reveal only. The Hall side of the grey door and the European side of the Rockefeller door were not measured cleanly.

Evidence: [three doors, sidestep](../../../evidence/review-round-5/06-room-vanishes-when-visitor-steps-aside-in-a-doorway.jpg), [diagonal crossing](../../../evidence/review-round-5/08-diagonal-crossing-room-vanishes.jpg); sheets `REV-grey-hall-sheet.jpg`, `REV-skylight2-sheet.jpg`, `POP-rock2-sheet.jpg`.

### 3. No two rooms are lit alike; the brightest is 2.8 times the dimmest hung room.

**VERIFIED · BLOCKS by the owner's own words ("the inconsistent lighting") · KNOWN (census), measured on this build.** What a visitor sees: the Skylight Gallery and the Hall are bright; one wipe later the grey gallery, the European gallery and the connector are dim and brown-grey, with the works no brighter than the walls. Mean brightness of the game picture, four views per standpoint, 0 to 1:

| Room | Mean | Room | Mean |
| --- | --- | --- | --- |
| Skylight Gallery | 0.58 | lion landing | 0.31 |
| Main Hall | 0.51 | grey French gallery | 0.30 |
| modern gallery | 0.42 | dark medieval room | 0.28 |
| marble stair hall | 0.36 | European gallery, middle | 0.24 |
| Rockefeller | 0.33 | European gallery, north end | 0.21 |
| European gallery, south end | 0.32 | purple connector | 0.18 (32–54% of it black) |
| Renaissance room | 0.31 | | |

Beyond what the lead listed: the grey French gallery under its new ceiling is as dim as the Renaissance room (0.30); the north end of the European gallery is darker than the dark medieval room (0.21 against 0.28); in the medieval room the three new sculptures are unlit, the Angel worst (finding 11). The European gallery's south end has two warm pools on otherwise unlit walls.

Evidence: [six rooms](../../../evidence/review-round-5/18-room-brightness-compared.jpg), [European gallery](../../../evidence/review-round-5/17-european-gallery-dim.jpg).

### 4. Arriving in the Main Hall from the grey gallery, the picture is floor and one bench.

**VERIFIED · POLISH · KNOWN (round 4 finding 5) · NOT FIXED.** Three keyed arrivals and one clicked arrival opened on herringbone only; the two views along the Hall show no wall from the middle of the room either. Reproduce: (1) grey gallery; (2) walk through the Hall door; (3) look. Evidence: [arrivals, bottom right](../../../evidence/review-round-5/15-arrivals-west-and-north-rooms.jpg), [sheet](../../../evidence/review-round-5/11-item1-straight-crossings-fixed.jpg).

### 5. A click on a doorway leaves the visitor on the threshold with a black band across the picture.

**VERIFIED · POLISH · NEW.** What a visitor sees: after clicking a dark doorway the visitor walks through, the wipe plays, and the new room opens with its bottom edge black: 18% of the picture at the stone portal, about 12% arriving in the Hall from the grey gallery. The band stays until the visitor is moved. With the keys the same doors put the visitor 1.6 m in and the band is gone. Where: stone portal from the Hall (clicked high in its dark), the grey gallery's Hall door (clicked low). Reproduce: (1) stand in the Hall facing the portal; (2) click the dark of the doorway; (3) wait for the room to open. Evidence: [both arrivals](../../../evidence/review-round-5/03-click-doorway-ends-on-threshold-black-band.jpg).

### 6. In the marble stair hall the fireplace wall pops out of existence near the closed double door.

**VERIFIED twice · POLISH · NEW.** What a visitor sees: walking toward the double door at the back of the stair hall, the wall on the left, with the fireplace surround 83.152, turns black in one frame and the floor in front of it goes dark; it comes back in one frame on stepping away. Mean brightness 95 → 74 and back, the same on both runs. Reproduce: (1) stand in the stair hall at about (7.6, -30.1); (2) hold W for two seconds, then A; (3) watch the left of the picture. Evidence: [sheet](../../../evidence/review-round-5/07-marble-hall-fireplace-wall-pops-out.jpg).

### 7. After reading Saint Peter or the Angel, the visitor is hidden behind the free-standing pier.

**VERIFIED 2 of 2 · POLISH · NEW.** What a visitor sees: the inspection closes and the room is shown with a tall dark slab in the middle of the picture and the visitor behind it; a sliver of hat shows at its edge. Where: dark medieval room, after 20.254 or 37.114; the visitor stands at about (-2.9, 4.0). Reproduce: (1) enter the medieval room; (2) click the small stone figure right of the crucifix; (3) press Escape. After the Head of Christ the visitor is left by the east wall with 42% of the picture black (the known room-edge limit). Evidence: [both](../../../evidence/review-round-5/04-visitor-hidden-behind-pier-after-inspection.jpg).

### 8. The first time into the Renaissance room the game freezes for three quarters of a second.

**VERIFIED once · POLISH · KNOWN (round 4 finding 4: 0.66 s).** One frame of 0.74 s as the wipe closes, black 1.78 s, keys back 3.2 s; the second time 2.5 s. No other first entry froze for more than 0.13 s (landing, modern, European, Rockefeller, connector, grey, marble, Skylight). Evidence: [sheet, top](../../../evidence/review-round-5/14-side-doors-half-black.jpg).

### 9. The Renaissance room's new north door reads as a black hole with a striped sill.

**VERIFIED from three views · POLISH · NEW.** What a visitor sees: from inside, a white moulded casing round a black rectangle with five or six light and dark stripes across its foot; from the side, a grey frame round two black panels standing in the room; from the European gallery, a brown casing the colour of the wall round black. The panelling of the reveal cannot be read from any of them. Reproduce: (1) Renaissance room; (2) press Q twice; (3) look at the door. Evidence: [stills and enlargements](../../../evidence/review-round-5/16-renaissance-north-door-reveal.jpg).

### 10. The three medieval sculptures: two read well, the Angel does not.

**VERIFIED · POLISH · NEW.**

| Work | Camera side | Against its photograph | Faults |
| --- | --- | --- | --- |
| Head of Christ 59.131 | front | a modelled head with the photograph's face, beard and red cheeks; reads as the same object | small in the picture; stands on a dark drum; nothing floats or pokes through |
| Saint Peter 20.254 | front, a little from its right | a modelled bust with the arm across the chest; reads as the same object, greyer than the photograph | small; the visitor's hat fills the lower right corner |
| Angel of the Annunciation 37.114 | front | a thin dark figure; the red cloak and green robe of the photograph are nearly black | unlit; the caption panel covers its feet and pedestal; Saint Peter stands in the lens at the same size and brighter, with the gold triptych edge-on behind him |

On the Angel's zoom page the photograph has its top right corner cut off on a diagonal and two stray fragments, red and black, on its left edge. None of the three pokes through a wall, floats, or sits inside its pedestal. No large photograph is fetched for any of them; the packed picture is what the zoom page shows. Evidence: [all three](../../../evidence/review-round-5/05-three-medieval-sculptures-inspect-and-zoom.jpg), [the Angel](../../../evidence/review-round-5/19-angel-inspection-dark-zoom-photo-cut-corner.jpg).

### 11. A thump twice as loud as a footstep sounds out of step.

**VERIFIED by measurement, not heard · MINOR · NEW.** Footsteps peak at 0.057 RMS and fall every 0.44 s at a walk. On 22 of 50 recorded legs, and five times in three walked squares in Rockefeller, one peak of 0.12–0.135 falls 0.14–0.6 s after a turn, a start or a bump, off the beat. In 16 seconds of walking, turning, reversing and two jumps in the Hall there was none. INFERRED: a landing or skid sound firing where it should not. Whether it is audible as a fault needs ears. Reproduce: (1) Rockefeller, stand mid-room; (2) walk W for two seconds, then A; (3) listen at the turn.

### 12. The caption panel opens empty.

**VERIFIED once · MINOR · NEW.** Inspecting S2, the dark caption panel is drawn with no text for about 0.4–0.5 s while the camera glides, then the three lines appear. The panel also covers the bottom eighth of the painting (KNOWN, census). Evidence: [glide sheet](../../../evidence/review-round-5/09-item2-hall-inspection-fixed.jpg).

### 13. Renaissance → European gallery still opens with the visitor behind a glass pedestal.

**VERIFIED · MINOR · KNOWN (round 4 finding 8) · NOT FIXED.** The walk-in ended against the case 2.8 m inside the door on 3 of 3 crossings; one was looked at frame by frame. Evidence: [arrivals, top left](../../../evidence/review-round-5/15-arrivals-west-and-north-rooms.jpg).

## Measured, inside limits already listed

Not counted as findings. VERIFIED.

- **Side doors, black before the wipe.** medieval → Renaissance 53%, Renaissance → medieval 46%, medieval ↔ landing 45%, landing → modern 44%, Rockefeller → connector 47%, connector → Rockefeller 65% (the visitor walks out of sight into the black). medieval → Hall grows a black band to 19%. [Sheet](../../../evidence/review-round-5/14-side-doors-half-black.jpg).
- **Stubs and connector.** With the visitor inside: sculpture stub up to 44% black, modern stub 38–55%, connector 32–58%. The room behind stays drawn. [Sheet](../../../evidence/review-round-5/13-item1-stub-doors-fixed.jpg).
- **Marble stair hall.** Flat grey slabs of the upper landing cross three of the four views. **European gallery, south standpoint.** A blank pale slab fills the lower left third of the fourth view (seen once).
- **Sound.** Silent at rest and in the black; footsteps at 0.035–0.057 RMS every 0.44 s walking and 0.28 s sprinting; jump landing 0.04.

## All doorways, straight crossing at a walk

Black share before the room change (highest), biggest one-frame rise in black before it, seconds of black, seconds until the keys answer.

| Door | There | Back |
| --- | --- | --- |
| Hall ↔ medieval | 11%, +1, 1.09 s, 2.48 s | 19%, +2, 1.05 s, 2.52 s |
| medieval ↔ Renaissance | 53%, +3, 1.09 s, 2.50 s (first time 1.78 s, 3.20 s) | 46%, +3, 1.03 s, 2.48 s |
| medieval ↔ landing | 45%, +4, 0.98 s, 2.47 s | 45%, +3, 1.02 s, 2.49 s |
| landing ↔ modern | 44%, +1, 1.11 s, 2.47 s | 36%, +1, 1.17 s, 2.50 s |
| landing ↔ sculpture stub | no wipe; 8–44% black, +2 | no wipe; +2 |
| modern ↔ adjoining stub | no wipe; 38–55% black, +1 | no wipe; +0 |
| Renaissance ↔ European | 26%, +2, 1.05 s, 2.53 s | 20%, +1, 1.18 s, 2.52 s |
| European ↔ Rockefeller | 27%, +2, 1.07 s, 2.52 s | 28%, +1, 1.11 s, 2.49 s |
| Rockefeller ↔ connector | 47%, +2, 1.16 s, 2.49 s | 65%, +2, 1.18 s, 2.49 s |
| connector ↔ grey | no wipe; 12–58% black, +1 | no wipe; +3 |
| grey ↔ marble stair hall | no wipe; 0–3% black, +0 | no wipe; 0–7%, +0 |
| grey ↔ Skylight | 37%, +2, 1.05 s, 2.49 s | 14%, +2, 1.07 s, 2.49 s |
| grey ↔ Hall | 31%, +2, 1.15 s, 2.49 s | 18%, +2, 1.07 s, 2.50 s |

Sheets for every leg are in the folder as `<leg>-sheet.jpg`; [three of them](../../../evidence/review-round-5/11-item1-straight-crossings-fixed.jpg), ["Other wall"](../../../evidence/review-round-5/12-item3-other-wall-fixed.jpg), [zoom pages](../../../evidence/review-round-5/10-item4-zoom-caption-fixed.jpg).

## The ten things to fix first before Friday 13:00

INFERRED order: how soon and how hard a visitor meets each.

1. **Finding 1.** The 15–16 s of black at the first doorway. Build the rooms while the visitor is in the Hall; four and a half idle minutes there are not used today.
2. **Finding 2.** Keep the room drawn everywhere inside the Skylight, Hall and Rockefeller reveals, not only on the centre line.
3. **Finding 3.** Bring the European gallery, the grey gallery, the connector and the medieval works up toward the Hall and the Skylight Gallery.
4. **Finding 4.** Open the Hall from the grey gallery on a view with paintings in it.
5. **Finding 5.** After a click on a doorway, walk the visitor as far in as the keys do.
6. **Finding 6.** Stop the fireplace wall popping in the marble stair hall.
7. **Finding 7.** Cut the medieval pier away, or stand the visitor clear of it, when an inspection closes.
8. **Side doors.** Up to 65% of the picture is black before the wipe at the connector and 53% at the Renaissance door.
9. **Findings 9 and 8.** Light the Renaissance reveal and remove the striped sill; take the 0.74 s freeze out of the first entry.
10. **Findings 10 to 13.** Light the Angel and replace its zoom photograph; find the thump; fill the caption panel before showing it; move the pedestal off the Renaissance door's axis.

## Build 10f7c0b9

VERIFIED, one fresh load of `10f7c0b9.html`, nine minutes, seven room changes, no page error and no `SCRIPT ERROR`. Each row was replayed with the same script as on `d284e66e`.

| Check | Result on `10f7c0b9` |
| --- | --- |
| First doorway (stone portal, W held) | **NOT FIXED.** Black 16.4 s (3.34 → 19.71 s after W down), one frozen frame of 15.2 s (probe: 10.6 s then 4.7 s), keys answer 18.0 s after the room change. First picture 21.0 s |
| Loading mark during the hold | Visible, and easy to miss: a grey ring about 12 pixels across in the bottom right corner of the picture, drawn on the last frame before the freeze. It cannot turn, because the page is frozen; it is gone when the frames resume |
| Finding 2, sidestep in the grey gallery's Hall doorway | **NOT FIXED.** 56 → 37, 46 → 39, 55 → 37 in one frame each |
| Finding 2, Skylight → grey on W+A | **NOT FIXED.** Black share 11% → 50% in one frame, 0.63 s before the room change |
| Finding 6, marble hall's fireplace wall | **NOT FIXED.** 94 → 74 and back, same place |
| Finding 7, visitor behind the pier after Saint Peter | **NOT FIXED.** Stands at (-2.72, 4.22), hidden but for a sliver |
| Works clear of the caption panel when read | **FIXED** on the five opened: Saint Peter, Crucified Christ, Christ in Majesty, Apostle 41.045, Hand of God. Saint Peter is also larger in the picture than on `d284e66e` |
| First zoom page of an added-room work (Hand of God 23.005) | Page and photograph in place 0.25–0.33 s after the click; no frame over 60 ms; **no network request at all** (also none for Apostle 41.045). The photograph comes out of the pack, not from the server |

The five new sculptures, each inspected and zoomed; captions and zoom photographs are right on all five:

| Work | Camera side | Reads beside its photograph | Faults |
| --- | --- | --- | --- |
| The Crucified Christ 43.195 | front | a modelled figure with the photograph's pose; all of it in the picture | the caption panel lies over the glass case below it, not over the work |
| Christ in Majesty 69.196 | front | a pale relief, the seated figure legible | seen through the hood of the glass case that stands in front of it; the Head of Christ is in the lens beside it at the same size |
| Apostle 41.046 | front | small dark figure in its niche | the visitor's hat covers the left quarter; the right half of the picture is black |
| Apostle 41.045 | front | small dark figure in its niche | the Head of Christ, in profile and twice the Apostle's size, and the edge of another sculpture fill the right of the lens; the visitor's hat fills the lower left |
| The Hand of God 23.005 | front | a white marble mass with the hand's outline | flat white with little shading, so the carving is lost; stands on a plain box |

None of the five pokes through a wall, floats or sits in its pedestal.

Rooms on `10f7c0b9`, looked at once each:

- **Renaissance room.** The tufted bench, the hooded wall cases, the floor case, the platform under the textiles and the window are there. NEW · POLISH: the window is a flat blue-white rectangle, the brightest thing in the room, and the figure in the case in front of it is a black silhouette.
- **Medieval room's stair door.** White moulded casing, lettered EXIT sign, the two Apostles in niches either side. The reveal itself is black from inside the room; the fire-door cheeks cannot be read.

Evidence: [first doorway and loading ring](../../../evidence/review-round-5/21-10f7c0b9-first-doorway-16.4s-black-loading-ring.jpg), [Apostle and Christ in Majesty](../../../evidence/review-round-5/22-10f7c0b9-apostle-and-christ-in-majesty-crowded-lens.jpg), [pier, and the Renaissance room from four sides](../../../evidence/review-round-5/23-10f7c0b9-pier-still-hides-visitor-renaissance-room.jpg).

## What could not be tested

- On `10f7c0b9` only what the section above lists was played: one fresh load, nine minutes, seven room changes. The other doors, the brightness table, the sound and findings 4, 5, 8, 9, 11, 12 and 13 were not replayed on it.
- Sound was measured, not heard.
- Only Linux headless Chrome on a shared host. Safari, Firefox, touch and the owner's machine were not tried; every duration will differ there.
- The ceilings and most door-head mouldings cannot be seen in the default view; I judged the ceilings by their effect on brightness. I did not count the 19 cased door sides; about ten were looked at.
- Doorway clicks were made at two of the 13 doors, one high and one low. "A wall is not floor" was not replayed.
- The sidestep in a reveal was not measured on the Hall side of the grey door or the European side of the Rockefeller door: both runs crossed the door first. The portal and the side doors were not tried with a sidestep.
- Captions and zoom pages were opened for six works out of 177. Works hidden by the cut-away were not probed.
- The follow view, the other tabs, Shift held through reading, focus loss, turning round at a doorway and jumping during a wipe were not replayed (round 4 covered them on earlier builds).
- The second black after the first doorway opens was NOT REPRODUCED on five first doorways; the lead has since withdrawn it (a frame list sorted as text).
- Finding 11's cause, and finding 6's exact trigger line, were not isolated.

## What the engine harness should learn

The harness walks each doorway down its centre line with one key, which is the one path the vanishing-room fix covers; it should also cross every doorway on both diagonals and stop inside each reveal to step to each cheek, failing when the share of black in the picture rises by more than ten points in one frame outside a wipe. The same one-frame test, run while the visitor walks a square near every wall of every room, would have caught the marble hall's fireplace wall. After an inspection closes it should check that the visitor can be seen, as rule 3 does for standpoints, because the medieval pier hides the visitor exactly where two new works leave it. After a click on a doorway it should measure the black share of the picture the room opens on, and compare where the visitor stops with a keyed crossing. It should record the mean brightness of every room and fail when the brightest hung room is more than, say, one and a half times the dimmest. It should log the loudest sound peak per second of walking and fail when one is more than one and a half times a footstep. And because the engine run cannot see the Web build's first-doorway freeze, one browser check should time the first doorway of a fresh load and fail above two seconds of black.

Scratch files, sheets and scripts: this folder. Evidence: 23 JPEGs in `evidence/`, each under 300 KB. Recordings were deleted once their sheets were made.
