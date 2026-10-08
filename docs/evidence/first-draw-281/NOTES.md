# First draw of the rooms, and the Hall's camera during the stepped build (#281)

Engine, GL Compatibility (`--rendering-driver opengl3`), `--fixed-fps 60`, 8 October 2026, on
the installed rooms of that day (15 areas, no Impressionist rooms yet). No browser run: an
export was out of scope for this work.

## What was measured

The shell is launched and the visitor stands in the Hall until the rooms are built. Then a
clicked route goes through the stone portal into the medieval room, on into the Renaissance
room, and back to the lion stair landing. Every frame over 100 ms from the first click on is
recorded with the stage drawn and the wipe's clock.

| Where | Before, three runs (ms) | After, three runs (ms) |
| --- | --- | --- |
| The wipe begins at the portal (wipe 0.00) | 220, 221, 224 | none over 100 |
| Medieval room first shown (wipe 1.33) | 519, 532, 614 | none over 100 |
| Renaissance room first shown (wipe 1.33) | 393, 332, 389 | none over 100; 126 and 132 once |
| Lion stair landing first shown (wipe 1.33) | 198, 266 | none over 100 |

The cost moves to the wait in the Hall: 15 areas drawn once, one a frame, while the visitor
stands still; five of those frames take 260 to 390 ms. If a doorway is reached first they are
drawn under the wipe's mark. Consecutive frames of the Hall's picture differ by 0.01 to 0.03
of 255 while they are drawn: nothing of them is seen.

One "after" run of three had a run of 110 to 517 ms frames while the wipe was closing in the
Hall; the two before it and the two after it had none, and one "before" run had the same in
the Renaissance room. Other agents were using the machine (load average 10). Read as noise.

## Not cured: one long frame about 107 frames after the rooms are in place

0.9 to 1.5 s, in every run, before and after, with the visitor standing still or walking.
It needs the rooms: with the build held off there is none. Nothing in the scene changes in
that frame (21 objects and 21 draw calls before and after, texture memory the same), no
viewport's measured render time rises (root 1.7 ms, the walk 3.1 ms), and the picture does
not change. The time is spent between the draw's start and its end outside any viewport,
which points at the driver (GL on D3D12 under WSL here). Whether a browser has it is not known.

## The Hall's camera during the stepped build

The room scene makes its own camera the picture's as it enters the tree
(`doorway_walk.gd`, `camera.current = true`). Built in one call it is freed before a frame is
drawn. Built in steps, with the visitor waiting in the Hall, it stayed the picture's camera
for every frame of the build (29 of 29): the Hall black, the visitor huge.

![Before the fix: the last frame of the build, then the frame after it](hall-during-build-before-fix.jpg)

`_begin_rooms` now gives the picture back to the Hall's camera at once.

![After the fix: before the build, then twelve steps into it](hall-during-build-after-fix.jpg)
