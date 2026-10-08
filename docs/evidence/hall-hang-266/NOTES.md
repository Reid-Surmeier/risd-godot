# Main Hall re-baked at the new hang heights (#266)

The commit before this one (`a956f04e`) moved 21 Hall paintings and resized seven in
`gallery_walk4/works.json`. What a visitor sees in the Hall is its saved bake, so the Hall was
baked again here with the same lamps (`bake/prepare.gd` is unchanged since #258: fill 0.55, one
6.8 spot at 25 degrees aimed at each painting's centre, daylight 0.35, environment 0.18). The
lamps follow the paintings because they are aimed from `works.json`.

Bake: `python3 modules/shell/prototype/gallery_walk4/bake/run.py`, `BAKE_PREPARE surfaces=139`,
`BAKE_OK users=137` (the same two counts as the #258 bake), 7 min 18 s, run alone under the room
rebuild lock. The editor rewrote 42 texture `.import` files; they were put back with
`git checkout` and the project re-imported headless, as `bake/README.md` says.

## Pictures

Seven fixed cameras, the game's own renderer (`--display-driver x11 --rendering-driver opengl3`),
taken on the build's bake (byte-identical to `origin/build/v0.1.0`) and again after this bake.
The four wall views are orthographic and square on (60.6 px per metre on the long walls, 100 on
the end walls), so a height can be read off them.

1. `1-long-walls-before-above-after.jpg`: west wall before, after; east wall before, after.
2. `2-end-walls-footage-before-after.jpg`: far-end wall (footage IMG_6344 26.0 s, before, after);
   arch-end wall (footage 178.6 s, before, after); the follow view; an oblique view.

Seen in them: every painting, its frame, the darker wall under it and its lamp pool sit together
at the new height; the wall, floor, skirting and cornice read the same. Each label card moved
with its frame, and where a frame used to hang too low for a card under it the card is now below
the frame's lower corner instead of beside it (`walk4.gd` `_place`, unchanged).

## Brightness, whole picture (mean display luma, 0 to 1)

| view | mean luma before | after | diff |
|---|---|---|---|
| 1-west | 0.350 | 0.352 | +0.001 |
| 2-east | 0.367 | 0.367 | +0.000 |
| 3-far | 0.333 | 0.332 | -0.001 |
| 4-arch | 0.290 | 0.290 | -0.000 |
| 5-follow | 0.449 | 0.449 | -0.000 |
| 6-oblique | 0.476 | 0.475 | -0.000 |
| 7-floor | 0.561 | 0.558 | -0.002 |

## Away from the paintings

| region | mean luma before | after | diff | mean RGB diff | share of pixels differing > 3 % |
|---|---|---|---|---|---|
| 1-west: skirting (0.03-0.20 m) | 0.600 | 0.598 | -0.0018 | -0.0025 -0.0017 -0.0006 | 0.7 % |
| 1-west: wall above 4.6 m, below the cornice | 0.300 | 0.300 | +0.0004 | +0.0002 +0.0004 +0.0006 | 0.5 % |
| 1-west: cornice and above (> 5.8 m) | 0.657 | 0.657 | -0.0001 | -0.0003 -0.0001 -0.0000 | 0.0 % |
| 1-west: wall columns > 0.9 m from any frame, 0.3-4.6 m | 0.214 | 0.214 | -0.0001 | +0.0000 -0.0001 -0.0003 | 4.8 % |
| 2-east: skirting (0.03-0.20 m) | 0.736 | 0.730 | -0.0064 | -0.0105 -0.0056 -0.0017 | 0.2 % |
| 2-east: wall above 4.6 m, below the cornice | 0.303 | 0.303 | -0.0001 | -0.0002 -0.0001 -0.0001 | 0.0 % |
| 2-east: cornice and above (> 5.8 m) | 0.656 | 0.656 | -0.0001 | -0.0002 -0.0001 -0.0000 | 0.0 % |
| 2-east: wall columns > 0.9 m from any frame, 0.3-4.6 m | 0.225 | 0.225 | -0.0001 | +0.0002 -0.0001 -0.0004 | 1.0 % |
| 3-far: skirting (0.03-0.20 m) | 0.476 | 0.461 | -0.0151 | -0.0206 -0.0143 -0.0066 | 37.3 % |
| 3-far: wall above 4.6 m, below the cornice | 0.284 | 0.284 | -0.0001 | -0.0002 -0.0001 -0.0001 | 0.0 % |
| 3-far: cornice and above (> 5.8 m) | 0.673 | 0.673 | -0.0002 | -0.0003 -0.0002 -0.0001 | 0.0 % |
| 3-far: wall columns > 0.9 m from any frame, 0.3-4.6 m | 0.265 | 0.265 | +0.0002 | +0.0001 +0.0002 +0.0002 | 3.4 % |
| 4-arch: skirting (0.03-0.20 m) | 0.405 | 0.401 | -0.0040 | -0.0052 -0.0038 -0.0019 | 1.3 % |
| 4-arch: wall above 4.6 m, below the cornice | 0.275 | 0.275 | -0.0001 | -0.0001 -0.0000 +0.0000 | 0.0 % |
| 4-arch: cornice and above (> 5.8 m) | 0.617 | 0.617 | -0.0001 | -0.0002 -0.0001 -0.0000 | 0.0 % |
| 4-arch: wall columns > 0.9 m from any frame, 0.3-4.6 m | 0.231 | 0.231 | +0.0002 | +0.0002 +0.0002 -0.0000 | 0.9 % |
| 7-floor: whole plan | 0.561 | 0.558 | -0.0023 | -0.0035 -0.0022 -0.0007 | 5.9 % |
| 7-floor: middle 6 m of the floor | 0.540 | 0.541 | +0.0006 | +0.0005 +0.0006 +0.0005 | 1.1 % |
| 5-follow: lower half (floor) | 0.531 | 0.531 | -0.0000 | +0.0001 -0.0001 -0.0002 | 4.7 % |

The far-end wall's skirting is 0.015 darker under N1 and N2: both were raised (0.34 and 0.22 m)
and their pools went up with them. Nothing else differs by more than 0.007.

## Each painting's move, measured

The before picture's frame box slid up and down the after picture; the best fit is the measured
move. Resized works (W2, W3, W5, W6, W7, E1, E8) are not in this table; they were looked at.

| work | expected move (m) | measured move (m) | difference (m) | residual at best | one pixel (m) |
|---|---|---|---|---|---|
| W1 | +0.180 | +0.181 | +0.001 | 0.0817 | 0.017 |
| W4 | +0.150 | +0.148 | -0.002 | 0.0543 | 0.017 |
| W8 | +0.249 | +0.247 | -0.002 | 0.0869 | 0.017 |
| W9 | +0.180 | +0.181 | +0.001 | 0.0943 | 0.017 |
| W10 | +0.180 | +0.181 | +0.001 | 0.0923 | 0.017 |
| E2 | +0.170 | +0.165 | -0.005 | 0.1028 | 0.017 |
| E3 | +0.190 | +0.198 | +0.008 | 0.0989 | 0.017 |
| E4 | +0.160 | +0.165 | +0.005 | 0.0677 | 0.017 |
| E5 | +0.000 | +0.000 | +0.000 | 0.1123 | 0.017 |
| E6 | +0.140 | +0.132 | -0.008 | 0.1089 | 0.017 |
| E7 | +0.170 | +0.165 | -0.005 | 0.0992 | 0.017 |
| E9 | +0.140 | +0.148 | +0.008 | 0.0917 | 0.017 |
| N1 | +0.342 | +0.340 | -0.002 | 0.0136 | 0.010 |
| N2 | +0.215 | +0.220 | +0.005 | 0.0259 | 0.010 |
| S1 | +0.119 | +0.120 | +0.001 | 0.0044 | 0.010 |
| S2 | +0.000 | +0.000 | -0.000 | 0.0000 | 0.010 |
worst difference 0.008 m


## Checks after the bake

1. `museum_playtest.gd --only=objects --objects=W2,E8,E5,S2,N1,W6,W7`: 7 objects, 0 failures.
2. `museum_playtest.gd --only=interaction`: 9 checks, 1 failure, not in the Hall: "a click in a
   doorway did not walk through: Skylight Gallery, south". Both Hall checks ("reading a Hall work
   frames it", at launch and with the rooms built: the click is inside the picture) and the Hall's
   own wall and doorway clicks pass. Whether the Skylight failure is there without this bake was
   not run.
3. `visitor174_check.gd`: PASS.
4. `scripts/check.sh`: stops at REPRESENTATION_CHECK with four failures (recamier, 06.057,
   83.152, 37.201), the four known on the integration tree.

`hall_capture.gd.txt` and `hall_compare.py.txt` are the two scratch scripts that took and
compared the pictures (not part of the game).
