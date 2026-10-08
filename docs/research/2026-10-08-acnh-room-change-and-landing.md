# How Animal Crossing: New Horizons changes rooms, and how a landing resolves

Research for [#255](https://github.com/Reid-Surmeier/risd-godot/issues/255), written 2026-10-08 against `build/v0.1.0` at `6863e8a3`. It feeds the doorway prototype [#260](https://github.com/Reid-Surmeier/risd-godot/issues/260). This file and the six pictures beside it are the only things added. Nothing was run in the engine and no paid call was made.

**The answer.** Every doorway in the New Horizons museum is a hard scene change behind a black circular wipe: outdoors to the entrance hall, the hall to each wing, room to room inside the bug, fossil and fish wings, and the café. Sixty of them were measured across four captures and the wipe is the same curve every time: 28 frames (0.93 s) to close, a black hold while the next room loads, 19 frames (0.63 s) to open. The visitor walks into a dark opening on its own, the camera stops following, and on the far side the visitor walks in on its own before control comes back. Only one room exists at a time, so a neighbouring room is never on screen: a doorway shows black or a glow, never the next room. Stairs and level changes inside one room are an ordinary walk with the camera following. The earlier note's "rooms that join through a doorway keep no transition" holds only for the art gallery, which is one large room.

**For this game:** make each room (or each group that is truly one open space) the only thing drawn, put a black card in every doorway, and change rooms under the measured wipe. The first prototype can do this by switching visibility under the wipe with everything still loaded; loading one room at a time is the second step.

How to read the labels: **VERIFIED** means I looked at the frames, ran the measurement, or read the cited file myself. **INFERRED** means reasoned from something adjacent; the row says from what. Timings are in frames of the 30 frames-a-second game, then milliseconds.

How this was made. Two background readers were started on 7 October and stopped mid-work when the login expired, before either wrote its findings. Their downloads, scripts and per-frame data survived. I re-ran the aggregation and the easing fit on that data, looked at the frame sheets cited below, and read the datamined files directly. Anything I only saw in a reader's logged output and did not re-run is marked.

## 1. Sources

| Key | Source | What was used |
| --- | --- | --- |
| A | bloodrive65, [100% Complete Museum Tour (Bugs, Art, Fossils, Fish & Brewster) [4K]](https://www.youtube.com/watch?v=5u3V2sfaSHc), uploaded 2024-04-10, 37:50. Fetched at 854×480, 30 fps. | 21 doorways, the whole tour. A 4K 60 fps upload of a 30 fps game, so probably emulated or upscaled; its loading times do not transfer. |
| B | MonkeyKingHero, [A walk around a complete Art Gallery Museum](https://www.youtube.com/watch?v=4nWg4mjpjFc), uploaded 2020-04-24, 2:12, 1280×720 at 30 fps. | The art gallery in one unbroken walk. |
| J | BeardBear, [Museum 100% Completed Showcase](https://www.youtube.com/watch?v=DkSPsUuQOZk), uploaded 2020-03-20, 21:19, 1080p30 upload fetched at 480p. | 13 doorways in the bug and fish wings. The uploader has cut the loading out (see T6). |
| K | NintendoLegacy, [Museum 100% Completed Showcase](https://www.youtube.com/watch?v=fW6R2_WcpKw), uploaded 2022-09-22, 8:54, 1080p30 upload fetched at 360p and one section at 720p. | 11 doorways, loading left in. The frame sheets 01 and 02 are from this one. |
| L | XCageGame, [Gameplay Walkthrough Part 4 - Museum Tour](https://www.youtube.com/watch?v=vi78Mv0z4Q0), uploaded 2020-03-19, 52:15, no commentary, fetched at 640×360, 30 fps. | 15 doorways from launch week. |
| P | McSpazzy, `acnh-csv` at [`129e7aca`](https://github.com/McSpazzy/acnh-csv/blob/129e7acab3536be56ac6edbc37575316da918ccd/PlayerStateParam.csv) and `acnh-yml` at [`e208e6ec`](https://github.com/McSpazzy/acnh-yml/blob/e208e6ec37c03c8e3fab4daa09e7036cb575b306/Actor/PlayerActor.yml). | Tables dumped from the game's own data: the player's 315 named states and its movement parameters. Community dumps of game files, not Nintendo-published. |
| M | tmouh, `acnh-60fps`, [`docs/measured.md` at `20fef5b1`](https://github.com/tmouh/acnh-60fps/blob/20fef5b10310e4e9fe9a75419103e9f8021fa6f6/docs/measured.md). | A mod author's timings of the unmodified game, read from game state in an emulator. Quoted, not re-measured. |
| V | Crossing Games, [How to short/long jump with the vaulting pole](https://www.youtube.com/watch?v=IVmVVfhg75A), 1280×720 at 30 fps. Upload date not recorded. | One vault landing, frame by frame. |
| S | `n64decomp/sm64` at [`9921382a`](https://github.com/n64decomp/sm64/tree/9921382a68bb0c865e5e45eb594d9c64db59b1af), already the repo's jump reference in `character-opus-primary-sources-2026-10-01.md`. | The landing rule. |

None of the captures states its hardware. K, L and B show loading holds of 2.9–5.6 s and a native 30 fps cadence; that is consistent with a Switch and proves nothing more.

Method. Each doorway was cut from the video with its original timestamps, and a script fitted a circle to the edge of the black mask on every frame (`iris.py`, a convex-hull fit with the picture border excluded). Radii are given as a share of the picture's half-diagonal, so 1.0 is the circle just reaching the corners. The scripts and data are in the session scratchpad and are not committed; the footage has to be fetched again to re-run them.

## 2. What happens at each threshold

| # | Threshold | What happens | Read from | |
| --- | --- | --- | --- | --- |
| T1 | Outdoors → entrance hall | Wipe, load, wipe. Close 28 f, black 4.66 s, open visible 15–19 f. | K 0:54.87–1:00.90 (picture 01, 02); A 0:03.2–0:08.4 | VERIFIED |
| T2 | Entrance hall → a wing, and back (bugs, fossils, fish, art, café) | The same wipe. | A: 10 crossings between 0:13 and 37:29; K 4:54.9; J 0:15, 8:17; picture 04 | VERIFIED |
| T3 | Room → room inside the bug wing | The same wipe, with a load. The camera does not travel between the rooms. | A 1:05.2 (picture 03), 2:17.4, 4:11.8; K 5:16.8, 5:33.6; J 4:21, 5:38 | VERIFIED |
| T4 | Room → room inside the fossil wing and the fish wing | The same wipe. | A 22:14.1, 24:45.0, 26:11.3, 26:30.7 (fossils); 29:49.8, 33:10.1, 35:35.8 (fish) | VERIFIED from the data and the scan pictures; I viewed the bug-wing sheet, not each of these |
| T5 | Stairs and level changes inside one room | No transition. The visitor walks, the camera follows and re-frames as the visitor climbs. Seen on the entrance hall's stair up to the art-gallery arch, and on the fish room's stair down to its lower floor. | A 7:34.4–7:37.0 (picture 04); J 16:15–16:25 (picture 05) | VERIFIED |
| T6 | Inside the art gallery | No transition anywhere. Source A has no wipe between entering at 7:39 and leaving at 21:01. | A, list of all 21 wipes found by a brightness scan of the whole video; `2026-10-01-acnh-museum-polish-spec.md` row T3 | VERIFIED as far as the scan goes; the scan was the reader's and I did not re-run it |

The phases, the same at every doorway:

| Phase | Length | What is on screen | |
| --- | --- | --- | --- |
| Walk-out | About 1.1 s before the wipe is first seen | The visitor steps into the opening and goes dark; the camera stops following and holds. | VERIFIED on two crossings: K 0:53.73 → 0:54.87 (picture 01) and A 7:37.97 → 7:39.07 (picture 04). INFERRED that this is scripted, from the state names in section 4. |
| Wipe closes | **28 frames, 933 ms**, from the circle touching the corners to black. From 60% of the half-diagonal to black is 19 frames in 50 of 59 measured closes and 18 in the other 9. | A hard-edged black mask with a round hole, centred on the picture, not on the visitor. The scene inside the hole does not dim. | VERIFIED, 59 closes across A, J, K, L; edge and centring by eye on pictures 01–03 |
| Black | 2.9–5.8 s where the loading is left in (A 3.0–5.8, K 4.4–5.6, L 2.9–4.0). A small loading icon appears at the lower right after 7–33 frames of plain black in A and K (median 16 frames, 0.53 s). | Black. | VERIFIED |
| Wipe opens | **19 frames, 633 ms**, from black to the corners. To 60% takes 12 frames in 37 of 60, 13 in 15 and 11 in 8. | The same mask opening on the new room, already lit, camera already in place. | VERIFIED, 60 opens |
| Walk-in | About 0.6 s, overlapping the opening | The visitor is already through the door and walks a few steps into the room, then stands. | VERIFIED on K 1:00.60–1:01.20 (picture 02). INFERRED that it is scripted. |
| Camera after | Still until the visitor moves | In K the camera first moves 1.0–1.8 s after the wipe clears; where the player is already pushing the stick it moves on the next frame. | VERIFIED for K01 by eye; the per-crossing figures are from the reader's logged output, not re-run |

The curve. The median radius, frame by frame, over all 60 crossings:

| | Radius as a share of the half-diagonal, one value per frame |
| --- | --- |
| Closing, 28 frames | 0.971 0.934 0.896 0.856 0.815 0.772 0.729 0.685 0.641 0.597 0.552 0.508 0.464 0.421 0.378 0.337 0.297 0.259 0.222 0.187 0.155 0.125 0.098 0.073 0.052 0.034 0.020 0.008 |
| Opening, 18 frames | 0.019 0.042 0.073 0.110 0.154 0.204 0.258 0.316 0.378 0.442 0.507 0.574 0.641 0.707 0.772 0.835 0.895 0.952 |

A smoothstep ease (3x² − 2x³) fits both to within 0.002 of the half-diagonal; a straight line misses by 0.04. The fit says the circle starts larger than the picture: **1.19 × the half-diagonal → 0 over 40 frames (1.33 s) to close, and 0 → 1.19 over 27 frames (0.89 s) to open**, of which the first 12 closing frames and the last 8 opening frames are off screen. The opening is the same curve run 1.5 times as fast (slope 1.4998 between the two tables). VERIFIED: I recomputed the medians and re-ran the fit.

The wipe's centre sits 1.2–1.9% of the picture height above the middle in every source. I take that as centred. INFERRED: the size of the offset differs by capture (1.2% in A, 1.85% in J, K and L), so some of it may be the capture.

What J shows. BeardBear's holds are 0.4–0.8 s with no loading icon, and in one of thirteen the icon is on screen for three frames. INFERRED: the uploader trimmed the loading. It means the shortest hold in an unedited capture, 2.9 s, is loading time and not a design choice, which agrees with the earlier note.

Sound. Measured as a level envelope on K 4:54–5:02 and L 8:46–8:54; nobody listened to it. The room's sound falls about 15 dB while the wipe closes. During the black there is only a quiet low-frequency bed with a pulse about once a second; everything above 3 kHz is gone. As the wipe opens the full-band sound of the new room is back within 0.2 s and at its normal level in about 0.4–0.6 s. VERIFIED as an envelope. What the bed is, and whether a distinct door sound plays, could not be established this way.

## 3. How neighbouring rooms are kept off the screen

| | Finding | Read from | |
| --- | --- | --- | --- |
| O1 | **One room at a time.** Each wing room is its own loaded scene, so there is nothing next door to show. | Section 2: every door between rooms is a load | VERIFIED |
| O2 | **A doorway shows black or a glow, never the next room.** The entrance hall's arches and the outdoor door are flat dark openings; the visitor darkens walking into them. A door to a brighter room is a flat bright card. | Pictures 01, 02, 04 (dark); picture 03, top of the fountain room (bright); polish spec rows L10, S3 | VERIFIED |
| O3 | **No near wall exists.** The room is a set open toward the camera; the floor ends in a dark flat edge along the bottom of the picture. Nothing fades or dissolves. | Polish spec row R1; nothing in the frames I viewed contradicts it | VERIFIED there, not re-measured here |
| O4 | **Far and side walls fill the picture.** In the frames viewed, no pixel shows space over a wall top. | Pictures 02–05 | VERIFIED for those frames only |
| O5 | **The camera never crosses a threshold.** It holds before the wipe and is already settled after it. Inside a room it follows continuously, stairs included. | Section 2 | VERIFIED |

There is no wall cut-away and no fog in any frame I looked at. The whole answer is room-sized sets, opaque doorways and a wipe.

## 4. Walk, run and landing

[#259](https://github.com/Reid-Surmeier/risd-godot/issues/259) fixed the cycle restarts and the standing landing on 7 October, so this section is short: what the sources say, and how the fix and its three leftovers sit against them.

| | Finding | Source | |
| --- | --- | --- | --- |
| M1 | Free ground movement is three states: `Wait`, `Move`, `Turn`. Walking and running are not separate states. | P, `PlayerStateParam.csv`, column `StateName` | VERIFIED |
| M2 | The run on B is called "dash" in the data, and speed chases a target in steps rather than switching: `mWalkRunSpeedChaseStep` 0.4, `mDashSpeedChaseStep` 0.75, `mStickMorphSpeed` 0.2. | P, `PlayerActor.yml` | VERIFIED that the names and values are there; INFERRED what each one does |
| M3 | Doors and room changes have their own player states: `StageWalkOut`, `StageWalkIn`, `StageWalkInUseBgCheck`, `StageStairsInUp`, `StageStairsInDown`, `StageStairsOut`, `DoorIn`, `DoorOut`, `WaitAfterWarp`. | P, same file | VERIFIED names; INFERRED that these are the walk-out and walk-in seen in section 2 |
| M4 | The game has no jump. Its nearest things are `JumpValleyReady` → `JumpValley` (the hop over a hole or a narrow stream), `LongStickJumpReady` → `LongStickJump` (the vaulting pole), a shared `Landing`, and `Tumble` (tripping). Each jump has a "ready" state before it. | P, same file | VERIFIED names; INFERRED which action each one is |
| M5 | Walk 3.74 and run 5.38 tiles a second. The hop takes 0.83 s, the vault 1.50 s. Reversing while running plays a skid of 0.567 s over 1.14 tiles. | M | VERIFIED that the source says so; not re-measured |
| M6 | A vault landing: feet down, a deep bow for about 8 frames, up by frame 16 (0.53 s), then standing. It ends in the idle pose, not in a walk. | V 0:27.20–0:27.73, picture 06 | VERIFIED, one clip |
| M7 | The repo's jump reference is Super Mario 64. There, the take-off is on the input frame with no crouch, the landing window is 4 frames (`sJumpLandAction = {4, …}`), and after it the land clip plays out to idle unless any stick or button input cancels it. | S, [`mario_actions_moving.c` L26–28](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_moving.c#L26-L28), [`mario_actions_stationary.c` L830–837](https://github.com/n64decomp/sm64/blob/9921382a68bb0c865e5e45eb594d9c64db59b1af/src/game/mario_actions_stationary.c#L830-L837); `character-opus-primary-sources-2026-10-01.md` lines 81–96 | VERIFIED |

Not measured: blend times between idle, walk and run in New Horizons, and whether the stride phase carries across a change of speed. The reader had frame sheets for both and no written numbers when it stopped; I did not redo them because #259 already carries the stride across (0 restarts in its recordings).

## 5. What this means for this game

### The doorway

Today (`modules/shell/prototype/collection_reconstruction/main_build_walk.gd`): all sixteen areas of `geometry.json` are one scene, loaded at start (line 106). Crossing a doorway changes nothing on screen (lines 828–839). Both neighbouring groups are drawn on purpose, "visible through their doors" (line 1158), and a per-frame rule hides any whole room that falls between the camera and the visitor (lines 1194–1198). That last rule is what the owner sees as "the old room cut off … this black". The only cover in the code is a 0.22 s white flash kept for the old test room (`walk4.gd` lines 2283–2284).

Recommended, in the order to build it:

1. **One stage on screen.** A stage is one room, or a group with no door between its parts (as the art gallery is one room, T6). Draw only the visitor's stage. `_parts` and `_walls` already carry a room index for every node (lines 49–50), so this is a visibility rule, not a new data structure. [O1]
2. **A black card in every doorway**, just behind the arch, unlit and opaque; a bright card instead where the next stage is much brighter. Never the next room's geometry. This replaces line 1158 and makes the whole-room hiding at 1194–1198 unnecessary. [O2]
3. **The change itself**, at 30 frames a second:

| Step | Length | What to do | From |
| --- | --- | --- | --- |
| Commit | — | When the visitor is `SWAP_DEPTH` into the doorway and heading through (the test at lines 850–857). Take the keys away; walk the visitor straight on along the door's axis; stop the camera following; darken the visitor over about 0.3 s. | Walk-out row; M3. The 0.3 s is taste. |
| Wait | 0.7 s | Nothing else changes. | 1.1 s seen from camera stop to the wipe appearing, less the 0.4 s the wipe spends off screen. Two readings. |
| Close | 1.33 s, the last 0.93 s visible | A black full-screen rectangle with a round hole centred on the picture, hard edge, radius 1.19 × half-diagonal → 0, smoothstep. | Measured curve |
| Black | 0.5 s at least | Hide the old stage, show the new one, put the visitor about 1 m outside the arrival door on its axis, call `_update_camera(1.0)` so the camera is already settled, reset foot contacts. Show a small spinner at the lower right only if this runs past about 0.5 s. | The game shows plain black for a median 0.53 s before its loading icon comes up (7–33 frames); the rest of its hold is loading. Using that as the floor is a choice, not a measured design minimum. |
| Open | 0.89 s, the first 0.63 s visible | The same hole, 0 → 1.19, smoothstep. The visitor walks in about 1 m meanwhile. | Measured curve; walk-in row |
| Hand back | at about 0.6 s into the open | Give the keys back. The camera has not moved yet. Arm the return door only once the visitor has left its trigger. | Walk-in row; the re-arm rule is from `animal-crossing-room-transitions.md` |

   From commit to control that is about 3.1 s (0.7 + 1.33 + 0.5 + 0.6), of which 1.6 s is visible wipe. It is the game's own pace and the owner asked for "slower … or some occlusion". If it drags when walked, shorten the wait first, then scale close and open together and keep their 3:2 ratio. Those are taste calls, not measurements.
4. **Sound.** Fade the room's sound down about 15 dB over the close and bring the new room's up over 0.4 s as the wipe opens. [Sound paragraph] A door sound is not established and should not be invented.
5. **Stairs and steps inside a stage get no transition**; the camera follows. [T5]
6. **Wipe, not fade.** #260 says "fade". The game uses a round wipe at every door; the GameCube game used a white fade for its museum doors (`animal-crossing-room-transitions.md`). The wipe is one `ColorRect` with a short canvas shader in place of `_portal_flash`. INFERRED that this costs about the same as a fade; not built.

For the first prototype, steps 1–3 can run with every room still loaded: the wipe covers a visibility switch. That answers what the owner asked to react to. Loading one stage at a time, which is what would shorten the start-up stall, is a second step, because the rooms are one scene with one baked lightmap today.

### The locomotion state machine

Keep what #259 built: one stride carried across gait changes, landing in stride as a short squash straight back into the gait, skid on the reversal. Against the sources:

| #259 leftover | What the sources say | Recommendation |
| --- | --- | --- |
| Landing in stride is 6 ticks of squash | SM64's window is 4 frames at 30 a second, 133 ms, then the gait if the stick is held (M7). New Horizons' own landing is a 0.53 s bow into idle (M6), but that follows a scripted vault, not a jump under control. | Keep the short squash when moving (`JUMP_SQUASH` 0.067 s, `visitor.gd` line 21) and the full 0.23 s landing only with no input. It matches the reference the repo chose. |
| Take-off is an abrupt 0.1 s blend | SM64 takes off on the input frame with no crouch (M7). New Horizons puts a "ready" state before each of its jumps (M4). | Either is defensible. Leaving it is consistent with the reference. A longer crouch is taste and the owner's call. |
| A sprinting 90° turn drops to the walk clip for about 14 frames | The gait is chosen from instantaneous speed (`sprint := speed > SPRINT_FROM`, line 238). New Horizons has one `Move` state whose speed chases a target in steps (M1, M2). | Choose the gait from what is asked for (Shift held), not from the speed this frame, so a dip in speed through a turn does not change the clip. INFERRED from M1–M2; small change, not built. |
| A walk-speed turn-round takes half a second | `Turn` is its own state (M1); reversing at a run is a 0.567 s skid (M5). | Not enough evidence to give a number for the walk. Leave it. |

## 6. What could not be established

1. **Hardware.** No capture states whether it is a Switch or an emulator. The wipe curve is identical in all four, so it does not matter for the wipe; it does for loading times.
2. **Whether the player keeps control during the walk-out and walk-in.** The frames show the walk and the data has states named for it; no input display was available to prove the stick is ignored.
3. **The sounds.** Only a level envelope was measured. Whether a door or wipe sound plays, and what the low bed during the black is, need someone to listen.
4. **What is outside a room's walls.** Nothing shows in the frames viewed; nobody looked with a free camera.
5. **Per-crossing camera timings** (how long the camera is still before each wipe and after it) come from the reader's logged output for 40 crossings and range from 0.03 to 2.8 s before. I checked two by eye. The spread is probably the camera reaching the edge of its room before the visitor reaches the door, which is INFERRED.
6. **Blend times and stride phase in New Horizons** (section 4, last paragraph).
7. **How loading one stage at a time behaves in the Web export**, including whether background loading works without threads there. Not looked at; it belongs to the second step of the prototype.
8. **The four fossil and fish crossings in T4** are in the data with the same curve; I viewed the bug-wing sheet and the scan thumbnails, not a full sheet of each.

## Pictures

In `2026-10-08-acnh-room-change-and-landing/`. Each tile is stamped with its time in the source video.

| File | Source and time | What to look at | SHA-256, first 16 |
| --- | --- | --- | --- |
| `01-outdoors-to-hall-walk-in-and-iris.jpg` | K 0:51.6–0:55.7, 7.5 tiles a second | The visitor walks into the dark door and darkens; the camera holds from 0:53.7; the wipe closes on the picture's centre. | `3758035daec19bce` |
| `02-hall-arrival-iris-open-and-walk-in.jpg` | K 1:00.40–1:02.37, every frame, cropped | The wipe opens on the lit hall; the visitor walks in until about 1:01.2 and stands; the doorway behind is flat black. | `1595a9397c3f5298` |
| `03-bug-room-to-bug-room.jpg` | A 1:02.9–1:12.9 | One bug room to the next is a wipe and a load, not a walk. The door at the top of the second room is a bright card. | `f71a966032013602` |
| `04-hall-stairs-then-dark-arch.jpg` | A 7:32.2–7:38.4, 5 tiles a second | The stairs are an ordinary walk with the camera following; the arch at the top is black and the visitor darkens in it. | `27b6b4d62a845312` |
| `05-fish-room-stairs-no-wipe.jpg` | J 16:15–16:24.75, 4 tiles a second | A stair down to a lower floor inside one fish room: no wipe, the camera re-frames. | `24bf2406ca2cdb9e` |
| `06-vault-landing.jpg` | V 0:26.93–0:27.90, every frame | Touchdown at 0:27.20, a bow, upright by 0:27.73. | `c8fda600329a99ea` |

Builds on and does not repeat: `2026-10-01-acnh-museum-polish-spec.md` (camera, light, rows T1–T3, R1, L10, S3), `animal-crossing-room-transitions.md` (cover, swap, reveal, re-arm, from the GameCube game), `character-opus-primary-sources-2026-10-01.md` (the SM64 jump).
