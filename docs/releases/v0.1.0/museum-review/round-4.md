VERDICT: NOT DONE

# Independent museum playtest, round 4 — 8 October 2026

Reviewer: Claude (Opus 5.5), working alone. No game code or assets changed. Owner deadline: Friday 9 October 2026, 13:00.

**Two builds.** The brief named build `bc33bcc3` at `https://windows-wsl.taile06c45.ts.net/museum-latest-75d82bf6/`. All 38 legs, the Hall, the zoom pages and the rapid cases were played on `bc33bcc3` (its page `bc33bcc3.html` is still served). While I was playing, the link was re-pointed to build `88f5ccbf` (#281, "build the added rooms at the first doorway, in the wipe's black"). I re-played the key doors on `88f5ccbf` and say so wherever a number comes from it. The verdict covers both: each has a blocking fault.

Played in GPU headless Chrome (ANGLE gl-egl on the RTX) with real key and mouse events, 1280 × 800, recorded at 10 frames a second and read as contact sheets. Positions and frame gaps come from the game's own opt-in `?qa-perf` probe. 68 room changes were recorded (59 on `bc33bcc3`, 9 on `88f5ccbf`).

VERIFIED means reproduced and looked at by this reviewer. INFERRED means concluded without reproducing. Round 3's six findings and the two 8 October censuses are not re-reported.

## What works

VERIFIED on `bc33bcc3`: the round wipe plays at all nine doorways that change the stage, both directions, at a walk and at a sprint. The visitor walks on into the doorway, the camera holds, the wipe closes, the next room opens already lit with the visitor lit and standing 1.6 m inside (0.6 m at the Hall's grey door), and the keys work again 2.45–2.56 s after the doorway on 46 of 49 timed crossings (the other three are first entries, finding 3). The picture is near-black for 1.1–1.3 s. In 68 changes the visitor never ended outside the floor, stuck, or facing a wall. Nothing of another room shows through a doorway. Turning round at once, sprinting, jumping, clicking, holding a diagonal, pressing Escape, sliding in along a wall, and a click route that crosses a doorway all end in a normal arrival.

VERIFIED: the Hall is evenly lit from all four views at three standpoints, with no patch, dark pool or brightness flicker (mean picture brightness steady to 0.1 in 255 over six stills). Seven Hall zoom pages opened on the right work with the caption under it and a sharp large photograph; walk, run and jump changes behave as described.

## Findings, in the order a visitor meets them

### 1. On the build the link serves now, the first doorway stays black for about 16 seconds.

**VERIFIED · BLOCKS · build `88f5ccbf` only.** What a visitor sees: the wipe closes on the stone portal and the picture stays completely black, silent and still for about a quarter of a minute before the medieval room opens. Where: the first doorway used after loading; measured at the stone portal, the door the start position faces. Reproduce: (1) open the link fresh; (2) click the floor once and hold W into the dark doorway; (3) count.

| Run | Black on screen | Frozen frames (game's probe) |
| --- | --- | --- |
| `88f5ccbf`, fresh load 1 | 16.1 s | one recorder gap of 14.8 s |
| `88f5ccbf`, fresh load 2 | 15.5 s | 11.2 s, then 3.2 s |
| `bc33bcc3`, same crossing, first time | 2.5 s | 0.48 s, then 1.49 s |

What the change bought: first picture at 31.7, 32.4 and 32.7 s on `88f5ccbf` against 42.4 and 45.4 s on `bc33bcc3`. Ten to thirteen seconds left the loader and about thirteen arrived at the first doorway, in black, with no sign that anything is happening. Later first entries on `88f5ccbf` are clean (Hall → grey, first time: 1.1 s black, one 0.25 s hitch). Timings are from this shared host; the owner's machine will differ in size, not in kind.

Evidence: [first doorway on 88f5ccbf](../../../evidence/review-round-4/04-first-doorway-16s-black-88f5ccbf.jpg); scratch `N1b-hall-medieval-88f.mp4`, `N1c-hall-medieval-88f-first.mp4`.

### 2. Leaving a room through a deep doorway, the whole room vanishes to black before the wipe starts.

**VERIFIED · BLOCKS · both builds.** What a visitor sees: the moment the visitor steps into the doorway, the room's walls, floor and furniture are gone and the door casing hangs in black with a strip of floor (at the Rockefeller door one table floats beside it); the wipe then closes on that picture. This is the owner's complaint ("I just see the old room cut off … this black") still happening, in one direction, at the three doors that have a deep reveal. Where: Skylight → grey gallery, grey gallery → Main Hall, Rockefeller → long gallery; WASD, walk or sprint. The opposite direction through the same doors is clean, as are the other ten connections. Reproduce: (1) stand in the Skylight Gallery in front of its door; (2) hold the key that walks through it; (3) watch the second before the wipe.

| Leaving | Share of the picture that is black | Room change logged | Wipe first visible |
| --- | --- | --- | --- |
| Skylight → grey, walk | 7% → 65% in one frame at 1.57 s | 2.19 s | about 2.8 s |
| grey → Hall, walk | 21% → 62% at 1.86 s | 2.37 s | about 2.9 s |
| Rockefeller → long gallery, walk | 18% → 65% at 1.75 s | 2.33 s | about 2.9 s |
| the same three at a sprint | jump 0.15–0.2 s before the change | | held through the closing wipe |
| every other recorded change | largest one-frame rise before the change: 10 points | | |
| `88f5ccbf`: Skylight → grey, grey → Hall | 6% → 72%, 16% → 67%, 0.5–0.6 s before the change | | |

At a walk the broken picture is on screen for about 1.2 s before any wipe can be seen. INFERRED: while the visitor stands in a reveal threshold that is joined to the room being left, the cut-away stops drawing that room; the wipe then holds the picture it was given.

Evidence: [three doors and a control](../../../evidence/review-round-4/02-room-vanishes-before-wipe.jpg); scratch `L2-skylight-grey-walk.mp4`, `M1-grey-hall-walk.mp4`, `H2-rockefeller-adjacent-walk.mp4`, sprint `L4`, `M3`, `H4`, `88f5ccbf` repeats `N7`, `N8`, and `legstats.py`.

### 3. The first time through a doorway the picture freezes as the wipe starts and the black lasts about twice as long.

**VERIFIED · POLISH · build `bc33bcc3`** (on `88f5ccbf` finding 1 replaces it). What a visitor sees: on the very first doorway the visitor stops mid-step for half a second, the wipe closes, and the screen stays black for about two and a half seconds; it is over four seconds before the keys work again. Later crossings of the same door are clean. Reproduce: (1) load `bc33bcc3.html` fresh; (2) hold W from the start position into the medieval room; (3) walk back and through again to compare.

| First entry | Freeze at wipe start | Black on screen | Keys back after the doorway |
| --- | --- | --- | --- |
| Hall → medieval (stone portal) | 0.48 s, then 1.49 s under the black | 2.5 s | 4.2 s |
| medieval → Renaissance | 0.66 s | 1.8 s | 3.0 s |
| medieval → lion landing | 0.40 s | 1.6 s | 2.8 s |
| the other five first entries (modern, long gallery, Rockefeller, grey, Skylight) | none measured | 1.1–1.3 s | 2.5 s |
| any repeat crossing | none | 1.1–1.3 s | 2.45–2.56 s |

INFERRED: the next room's meshes and textures are first drawn under the wipe; round 3's portal freeze is the same cost, now mostly hidden by the black.

Evidence: [first and third time through the stone portal](../../../evidence/review-round-4/01-first-entry-freeze.jpg); scratch `A1-hall-medieval-walk.mp4`, `A1-trace.json`, `A5-*`, `B1-*`, `C1-*`.

### 4. Arriving in the Main Hall from the grey gallery, the picture that opens is nothing but floor.

**VERIFIED · POLISH.** What a visitor sees: the wipe opens on herringbone boards and one bench; no wall and no painting is in the picture, and it stays that way the length of the Hall until Q, E or "Other wall" is pressed. For the room with all 23 paintings this is the weakest arrival in the building. Where: grey gallery → Hall, any gait; the same view is what the Hall shows whenever the camera looks along it. Reproduce: (1) stand in the grey gallery facing the Hall door; (2) walk through; (3) keep walking.

Evidence: [arrival at a walk and at a sprint](../../../evidence/review-round-4/06-hall-arrival-all-floor.jpg), [Hall views](../../../evidence/review-round-4/11-hall-lighting-all-views.jpg) turns 0 and 2; scratch `M1-grey-hall-walk.mp4`, `R8-skylight-grey-hall-sprint-two-doors.mp4`.

### 5. "Other wall" appears over the old room and can be pressed while the wipe closes.

**VERIFIED · POLISH.** What a visitor sees: walking from the medieval room (or the grey gallery) into the Hall, the "Other wall" button pops onto the picture of the room being left as soon as the doorway is crossed. Pressed then, the Hall opens turned side-on with the stone portal's flank and black over about 40% of the picture and the visitor wedged beside the door. Where: medieval → Hall and grey → Hall; mouse. Reproduce: (1) walk from the medieval room into the Hall; (2) click "Other wall" as the wipe starts to close; (3) wait for the room to open. Escape and floor clicks during a wipe are ignored, as they should be; this button is not.

Evidence: [button during the wipe and the view it leaves](../../../evidence/review-round-4/05-other-wall-during-wipe.jpg); scratch `U4-other-wall-during-wipe.mp4`.

### 6. Magnifying a zoom page drags the picture over its caption.

**VERIFIED · POLISH.** What a visitor sees: the caption sits under the work when the zoom page opens, but after wheeling in, the three caption lines stay where they were and are drawn across the enlarged painting. Where: any Hall zoom page; mouse wheel. Reproduce: (1) click a Hall painting, click it again; (2) wheel in eight notches over the picture; (3) read the bottom third.

Evidence: [W9 as opened and magnified](../../../evidence/review-round-4/03-zoom-caption-over-magnified-work.jpg).

### 7. At two doors the room opens with the visitor behind furniture.

**VERIFIED · MINOR.** What a visitor sees: Renaissance → medieval opens with a tall dark case between the camera and the visitor; Renaissance → long gallery puts a pedestal case on the door's axis 2.8 m in, so holding the key walks the visitor behind it and stops. Reproduce: (1) walk each door at a walk; (2) keep the key held.

Evidence: [both arrivals](../../../evidence/review-round-4/14-arrivals-behind-furniture.jpg); scratch `B2-*`, `G1-*`.

## Measured, inside the limits the builder already listed

Not counted as findings. VERIFIED numbers for the builder:

- **Side doors.** Before the wipe the picture is 38–59% black at the medieval ↔ Renaissance, medieval ↔ landing and Rockefeller ↔ purple doors; at landing ↔ modern the arrival picture stays 20–36% black. With the view turned side-on to a door (after Q or "Other wall") the visitor walks out of sight behind the wall before the wipe. [Sheet](../../../evidence/review-round-4/07-side-doors-half-black.jpg).
- **Sound.** The audio graph is silent at rest, 0.057–0.095 RMS while walking, the same 0.057 through the closing wipe, zero in the black, 0.048 as it opens. No fade either way.
- **No wipe inside a stage.** Grey ↔ marble hall, purple ↔ grey, landing ↔ sculpture stub and modern ↔ adjoining stub cross without a wipe, as built. The two stubs are a floor patch in black with 44–54% of the picture black. [Sheet](../../../evidence/review-round-4/15-stubs-no-wipe.jpg).
- **Turning round.** Reversing the key at the doorway gives two full wipes back to back, 5.3 s without control, with the room entered on screen for under a second. [Sheet](../../../evidence/review-round-4/16-turn-round-and-two-doors.jpg).

## All 38 crossing legs

Build `bc33bcc3`. Numbers are the harness's own leg order (`museum_playtest.gd --only=doors`). W and S are the scratch recordings at a walk and at a sprint. Legs 27–38 are the two halves of a reveal doorway; they were played as part of the full crossing, not started or stopped inside the reveal.

| # | Leg | W | S | Result |
| --- | --- | --- | --- | --- |
| 1 | Hall → grey | M2 | M4 | pass |
| 2 | grey → Hall | M1 | M3 | **finding 2** (room gone before the wipe); arrival is finding 4 |
| 3 | Hall → medieval | A1, A5 | A3 | pass; first time: finding 3 (finding 1 on `88f5ccbf`) |
| 4 | medieval → Hall | A2, A6 | A4 | pass; "Other wall" shows during the wipe (finding 5) |
| 5 | Rockefeller → long gallery | H2 | H4 | **finding 2** |
| 6 | long gallery → Rockefeller | H1, H5 | H3 | pass |
| 7 | Rockefeller → purple connector | I1, I5 | I3 | pass; 46% black before, side door |
| 8 | purple connector → Rockefeller | I2 | I4 | pass; 59% black before, side door |
| 9 | long gallery → Renaissance | G2 | G4 | pass |
| 10 | Renaissance → long gallery | G1, G5 | G3 | pass; pedestal on the axis (finding 7) |
| 11 | Renaissance → medieval | B2 | B4 | pass; arrives behind a case (finding 7); 44% black before |
| 12 | medieval → Renaissance | B1, B5 | B3 | pass; first time 0.66 s freeze; 53% black before |
| 13 | medieval → lion landing | C1, C5 | C3 | pass; first time 0.40 s freeze; 46% black before |
| 14 | lion landing → medieval | C2, C6 | C4 | pass; 44% black before |
| 15 | lion landing → modern | D1, D5 | D3 | pass; arrival 35% black |
| 16 | modern → lion landing | D2, D6 | D4 | pass; arrival 21% black |
| 17 | lion landing → sculpture stub | E1 | E3 | no wipe, as built; 44% black |
| 18 | sculpture stub → lion landing | E2 | E4 | no wipe, as built |
| 19 | purple connector → grey | J1 | J3 | no wipe, as built |
| 20 | grey → purple connector | J2 | J4 | no wipe, as built |
| 21 | grey → marble stair hall | K1 | K3 | no wipe, as built; clean |
| 22 | marble stair hall → grey | K2 | K4 | no wipe, as built; clean |
| 23 | grey → Skylight | L1, L5 | L3 | pass |
| 24 | Skylight → grey | L2 | L4 | **finding 2** |
| 25 | modern → adjoining stub | F1 | F3 | no wipe, as built; 54% black |
| 26 | adjoining stub → modern | F2 | F4 | no wipe, as built |
| 27 | Hall reveal → grey | M2 | M4 | pass (the walk-in under the wipe) |
| 28 | grey → Hall reveal | M1 | M3 | **finding 2**: the room goes as the reveal is entered |
| 29 | Hall reveal → Hall | M1 | M3 | wipe plays |
| 30 | Hall → Hall reveal | M2 | M4 | pass |
| 31 | Rockefeller reveal → Rockefeller | H1 | H3 | pass (the walk-in under the wipe) |
| 32 | Rockefeller → Rockefeller reveal | H2 | H4 | **finding 2** |
| 33 | Rockefeller reveal → long gallery | H2 | H4 | wipe plays |
| 34 | long gallery → Rockefeller reveal | H1 | H3 | pass |
| 35 | Skylight reveal → Skylight | L1 | L3 | pass (the walk-in under the wipe) |
| 36 | Skylight → Skylight reveal | L2 | L4 | **finding 2** |
| 37 | Skylight reveal → grey | L2 | L4 | wipe plays |
| 38 | grey → Skylight reveal | L1 | L3 | pass |

Six legs carry finding 2; 32 pass or behave as built. [A crossing that works](../../../evidence/review-round-4/08-clean-crossing-landing-modern.jpg).

Rapid cases, all VERIFIED on `bc33bcc3`:

| Case | Recording | Result |
| --- | --- | --- |
| Turn round the moment the room changes | R1 | two wipes back to back, normal arrival |
| Jump three times during the wipe | R2 | the visitor hops as the wipe opens; normal arrival |
| Click the floor twice during the wipe | R3 | clicks ignored; arrives 0.85 m in instead of 1.6 m |
| Escape twice during the wipe | U5 | ignored |
| "Other wall" during the wipe | U4 | accepted: finding 5 |
| Diagonal held into the portal | A7 | walks straight in, diagonal resumes when the keys return |
| Along the wall into the portal | U6 | enters; visitor hidden behind the stone with the view side-on |
| Two doors in one sprint (Skylight → grey → Hall) | R8 | two clean wipes 4.3 s apart, apart from finding 2 at each |
| Click the dark doorway from the Hall | U2 | routed as floor through the door; wipe; arrives |
| Inspection beside the portal | U1 | opens and closes cleanly |

## The Hall and its zoom pages

VERIFIED on `bc33bcc3`. Camera turned through four views at the south end, middle and north end: evenly lit, no patch, no dark pool. [Sheet](../../../evidence/review-round-4/11-hall-lighting-all-views.jpg). The other nine rooms were turned through four views each; none is mostly black or mostly one wall (worst: lion landing 38% black, standing by its door). Sheets [a](../../../evidence/review-round-4/09-camera-turns-a.jpg) and [b](../../../evidence/review-round-4/10-camera-turns-b.jpg).

| Work | Large photograph | Response after the second click |
| --- | --- | --- |
| E8 (62.064) | 674 KB | 0.10 s |
| E5 | 1,884 KB | 0.14 s |
| E6 | 1,639 KB | 0.13 s |
| W5 | 2,060 KB | 0.11 s |
| W6 | 1,046 KB | 0.12 s |
| W8 | 1,131 KB | 0.11 s |
| W9 (62.058), throttled to 2 MiB/s with 100 ms latency | 1,297 KB | headers 0.23 s, complete 0.93 s |

Each opened on the work that was clicked (`NAV_PICK` matched), with the caption in three lines under the frame and a close cross top right. While the photograph loads the packed picture is already in place and is replaced without a flash. Wheeled in, the photograph is sharp to the brushwork. Escape closes the zoom page and the inspection together and leaves the visitor in front of the work. [Sheet](../../../evidence/review-round-4/12-zoom-pages.jpg). These fetches come from the same host as the game; a real connection will be slower, which the throttled row estimates.

Walk, run, jump: one stride through Shift down, up and down again (speed ramps 1.2 ↔ 3.0 m/s with no restart), a jump at a run lands back into the run, and a floor click under a held key leaves the speed at 1.2 m/s. [Sheet](../../../evidence/review-round-4/13-gait-and-running-jump.jpg).

## Regression sweep

VERIFIED. First picture (`game-shown`): 45.4 s and 42.4 s on `bc33bcc3` (two loads; the link changed before a third), 31.7, 32.4 and 32.7 s on `88f5ccbf`. No page errors, no failed requests, no `SCRIPT ERROR`. Console as in round 3: 924 invalid-UID warnings with their stack lines across four loads, four MSAA warnings, one 404 for `favicon.ico`. Sound plays (levels above).

## Ten things to fix first

INFERRED order: by how soon and how hard a visitor meets each.

1. **Finding 1** — on `88f5ccbf`, the 16 s of black at the first doorway. Put the room build back behind the loader, or keep the picture alive and say something while it runs.
2. **Finding 2** — keep the room drawn while the visitor is in its own reveal, at the Skylight, Hall and Rockefeller doors.
3. **Finding 3** — the half-second freeze before the first wipe on `bc33bcc3`; whichever build ships, the first doorway must not hitch.
4. **Finding 4** — open the Hall from the grey gallery on a view with paintings in it.
5. **Side doors** (builder's listed limit) — hold the camera at the room's edge; today up to 59% of the picture is black before the wipe.
6. **Finding 5** — hide "Other wall" until the wipe has opened.
7. **Finding 6** — move or hide the zoom caption when the picture is magnified.
8. **Finding 7** — clear the two arrivals that open behind furniture.
9. **Sound** (builder's listed limit) — fade the steps with the wipe; today they stop dead.
10. **Stubs** (known) — the two stub doors walk onto a floor patch in black with no wipe.

## What could not be tested

- Sound was measured, not heard. Whether the steps suit the floor, and how the silence in the black feels, is untested.
- Only Linux headless Chrome on a shared host. Safari, Firefox, touch and the owner's machine were not tried; every duration here will differ there.
- `88f5ccbf` was re-played at five doors only (stone portal twice, Hall ↔ grey, grey → Skylight, Skylight → grey, grey → Hall). Its other 30 legs, its Hall and its zoom pages are INFERRED from `bc33bcc3`.
- Reveal halves (legs 27–38) were not started or stopped inside the reveal. INFERRED: standing still in the Skylight, Hall or Rockefeller reveal leaves the room gone for as long as the visitor stands there.
- The follow view (F6 panel) was not used; all turns are the dollhouse view's four sides.
- Stride phase and foot contact were judged from 10-frame-a-second sheets, not measured; the engine acceptance check (`visitor174_check.gd`) was not re-run.
- A click on a work in the next room cannot be made: the next room is not drawn. One click on the dark doorway was routed as floor; hidden works behind the black were not probed systematically.
- Double-click magnify on the zoom page was not exercised (the driver's double click did not register as one); wheel zoom was.
- The engine harness's doorway pass was not re-run.

Scratch recordings, traces and scripts: `build/review-round-4/` in the `wt-medieval` worktree (101 MB, git-ignored). Evidence: sixteen sheets under `docs/evidence/review-round-4/`, each under 300 KB.
