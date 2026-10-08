# Main Hall: nine frames at their filmed width, baked again (#266)

Nine Hall frames were built wider than the frames in the museum. Each now takes a measured
moulding width (`band_m`, metres, left / top / right / bottom) in `gallery_walk4/works.json`,
which `painting_asset.gd` `build_framed()` uses in place of the frame texture's own proportion.
Canvas sizes are unchanged and no painting moved.

`1-footage-before-after.jpg`: for each of the nine, the footage redrawn square-on to the wall, the
build before, and the build after, all at 70 px per metre and centred on the canvas.

## The bands

Read on `IMG_6344.MOV`: the work's own catalogue picture is matched to video frames (SIFT, RANSAC
homography) and the wall is redrawn square-on at 300 px per metre from the catalogue canvas size;
the band is the distance from the canvas edge to the frame's outer edge (`measure_band.py.txt`).
Error about 0.02 m a side. "Audit" is `docs/research/2026-10-01-museum-artwork-size-audit.md`
section 2, a separate reading (0.015 m).

| work | built before, l/t/r/b (m) | read here | audit | now | built / now |
|---|---|---|---|---|---|
| S2 57.227 | 0.229 / 0.251 / 0.229 / 0.246 | 0.097 / 0.10 / 0.095 / 0.103, 73.8 s | 0.085 / 0.10 / 0.085 / 0.08 | 0.09 / 0.10 / 0.09 / 0.09 | 2.6 |
| S1 56.096 | 0.111 / 0.118 / 0.111 / 0.118 | left 0.06, right 0.077; bottom 0.11 with its shadow; top not in frame; 35-37 s, a close oblique view, the only one that matches | left 0.06, bottom 0.055 | 0.065 all round | 1.8 |
| E1 63.061 | 0.178 / 0.168 / 0.179 / 0.168 | 0.098 / 0.10 / 0.09 / 0.082, 152.4 s | 0.09 / 0.09 / 0.085 / 0.095 | 0.09 all round | 1.9 |
| W10 60.107 | 0.202 / 0.185 / 0.199 / 0.190 | 0.14 / 0.175 / 0.16 / 0.15-0.22, 131.6 s; the moulding alone is 0.10-0.13 and the sight opening is about 0.04 m bigger than the catalogue canvas | 0.13 / 0.12 / 0.15 / 0.14 | 0.14 / 0.15 / 0.14 / 0.15 | 1.3 |
| W5 57.157 | 0.138 / 0.144 / 0.138 / 0.144 | 0.113 / 0.097 / not read / 0.107, 100.6 s | 0.11 / 0.115 / 0.11 / 0.115 | 0.11 / 0.105 / 0.11 / 0.11 | 1.3 |
| W7 44.161 | 0.263 / 0.251 / 0.262 / 0.235 | 0.18 / 0.20 / 0.23 / 0.19-0.24, 111.2 s (oblique) | 0.19 / 0.20 / 0.20 / 0.20 | 0.19 / 0.20 / 0.20 / 0.20 | 1.3 |
| W9 62.058 | 0.131 / 0.134 / 0.131 / 0.129 | 0.10 / 0.093 / 0.09 / 0.103, 126.8 s | 0.11 / 0.09 / 0.09 / 0.11 | 0.10 all round | 1.3 |
| E4 1987.056 | 0.144 / 0.139 / 0.142 / 0.137 | 0.093 / 0.103 / 0.122 / 0.098, 167.6 s (95 matches, the weakest) | 0.11 / 0.11 / 0.11 / 0.115 | 0.105 all round | 1.3 |
| E5 2003.105 | 0.346 / 0.451 / 0.350 / 0.352 | 0.268 / rail 0.318 / 0.263 / 0.257, 61.0 s | 0.27 / 0.45 with the crest / 0.27 / 0.26 | 0.27 / 0.45 / 0.27 / 0.26 | 1.3 (sides, bottom) |

Left as built: E6 37.104 (built 0.125, read 0.107, audit 0.105: within the reading error twice
over) and the twelve the audit calls right. S1's top and bottom and W10's top and bottom are the
least certain numbers here. The frame texture is stretched to the new width, not redrawn.

## What else changed, and why

1. `walk4.gd` lays the long walls out from each frame's width, so a narrower frame would have
   slid every painting on its wall. `painting_asset.gd` now also records `slot`, the framed size
   at the texture's own proportion, and the two layout lines in `_build_paintings()` use `slot.x`.
   Those two lines and the `band_m` argument are the only lines of `walk4.gd` touched. The gaps
   between frames are wider by the band removed.
2. S2 and E5 hung by "frame bottom ~ 0.5 m", which would have dropped their canvases 0.16 m and
   0.05 m with the thinner frame. Their `hang` is re-written as the same place: S2
   "centre ~ 2.079 m" (was 2.0785), E5 "centre ~ 2.007 m" (was 2.0065).
3. `native_cpu_arrays.res` regenerated (`prepare_cpu_geometry.gd`): the Hall asserts without it.
   `modules/shell/character/launch_geometry.res`, which that script also rewrites, was put back.
4. Not changed: the reading page still draws its flat frame at the texture's proportion
   (`walk4.gd` near line 2683). Each label card follows its frame's lower corner by the existing rule.
   A reader now stands a little closer to S2 and S1 (`p.outer.y * 1.1`, as before).

## The bake

`python3 modules/shell/prototype/gallery_walk4/bake/run.py` under `flock /tmp/risd-rebuild-rooms.lock`:
`BAKE_PREPARE surfaces=139`, `BAKE_OK users=137` (the counts of the two bakes before it), 8 min 27 s.
`bake/prepare.gd` is unchanged; `baked/lamps.json` has 333 values of which two differ, by 0.001 m
(E5's lamp follows its centre, 2.006 to 2.007). The editor rewrote 42 `.import` files; they were put
back with `git checkout` and the project re-imported headless. A first bake with four of the nine was
stopped part-way and its runner restored the previous bake (checked equal to the commit) before
this one ran.

## Pictures and numbers

`hall_capture.gd.txt` takes the seven fixed cameras of `docs/evidence/hall-hang-266` plus a close
square-on view of every work (200 px per metre, camera on the canvas centre), with the game's
renderer (`--display-driver x11 --rendering-driver opengl3`), and writes what the saved bake holds
for each work. "Before" is the bake of the commit before this one. Two before captures differ only
where the visitor stands (mean 0.05 of 255 on the long walls; nothing on the end walls or the close
views). `frames_compare.py.txt` made everything below.

## Model: centre and outer size of every work (paintings.json)

largest centre move over all 23 works: 0.0007 m
works whose outer size changed: W5 W7 W9 W10 E1 E4 E5 S1 S2

## Brightness, whole picture (mean display luma, 0 to 1)

| view | before | after | diff |
|---|---|---|---|
| 1-west | 0.351 | 0.350 | -0.001 |
| 2-east | 0.366 | 0.366 | -0.000 |
| 3-far | 0.332 | 0.332 | +0.000 |
| 4-arch | 0.290 | 0.287 | -0.003 |
| 5-follow | 0.449 | 0.449 | -0.000 |
| 6-oblique | 0.475 | 0.475 | +0.000 |
| 7-floor | 0.558 | 0.559 | +0.000 |

## Away from the paintings

| region | mean luma before | after | diff | share of pixels differing > 3 % |
|---|---|---|---|---|
| 1-west: skirting (0.03-0.20 m) | 0.600 | 0.600 | +0.0000 | 0.0 % |
| 1-west: wall above 4.6 m, below the cornice | 0.384 | 0.384 | +0.0002 | 0.0 % |
| 1-west: cornice and above (> 5.8 m) | 0.654 | 0.655 | +0.0002 | 0.0 % |
| 1-west: wall columns > 0.9 m from any frame, 0.3-4.6 m | 0.214 | 0.215 | +0.0003 | 1.0 % |
| 2-east: skirting (0.03-0.20 m) | 0.730 | 0.730 | +0.0000 | 0.0 % |
| 2-east: wall above 4.6 m, below the cornice | 0.385 | 0.386 | +0.0001 | 0.0 % |
| 2-east: cornice and above (> 5.8 m) | 0.653 | 0.653 | +0.0002 | 0.0 % |
| 2-east: wall columns > 0.9 m from any frame, 0.3-4.6 m | 0.224 | 0.225 | +0.0006 | 0.9 % |
| 3-far: skirting (0.03-0.20 m) | 0.458 | 0.458 | +0.0003 | 0.0 % |
| 3-far: wall above 4.6 m, below the cornice | 0.375 | 0.375 | +0.0002 | 0.0 % |
| 3-far: cornice and above (> 5.8 m) | 0.671 | 0.671 | +0.0002 | 0.0 % |
| 3-far: wall columns > 0.9 m from any frame, 0.3-4.6 m | 0.265 | 0.266 | +0.0001 | 0.1 % |
| 4-arch: skirting (0.03-0.20 m) | 0.398 | 0.398 | +0.0001 | 0.0 % |
| 4-arch: wall above 4.6 m, below the cornice | 0.353 | 0.353 | +0.0001 | 0.0 % |
| 4-arch: cornice and above (> 5.8 m) | 0.616 | 0.616 | +0.0001 | 0.0 % |
| 4-arch: wall columns > 0.9 m from any frame, 0.3-4.6 m | 0.230 | 0.230 | +0.0001 | 0.0 % |
| 7-floor: whole plan | 0.558 | 0.559 | +0.0003 | 0.0 % |
| 7-floor: middle of the floor | 0.558 | 0.559 | +0.0005 | 0.1 % |
| 5-follow: lower half (floor) | 0.521 | 0.520 | -0.0000 | 1.4 % |

## Works whose frame did not change: their box on the wall views, before against after

| work | mean abs RGB diff in the frame box | share of pixels differing > 3 % |
|---|---|---|
| W1 | 0.0000 | 0.0 % |
| W2 | 0.0000 | 0.0 % |
| W3 | 0.0000 | 0.0 % |
| W4 | 0.0000 | 0.0 % |
| W6 | 0.0006 | 0.2 % |
| W8 | 0.0000 | 0.0 % |
| E2 | 0.0002 | 0.0 % |
| E3 | 0.0004 | 0.3 % |
| E6 | 0.0002 | 0.3 % |
| E7 | 0.0000 | 0.0 % |
| E8 | 0.0000 | 0.0 % |
| E9 | 0.0000 | 0.0 % |
| N1 | 0.0000 | 0.0 % |
| N2 | 0.0000 | 0.0 % |

## What the saved bake holds: each work's frame box and canvas box (baked/room.tscn meshes)

| work | band l/t/r/b in works.json (m) | frame box before (m) | frame box after (m) | canvas + bands (m) | after minus that (m) | canvas box centre moved (m) |
|---|---|---|---|---|---|---|
| S1 **changed** | 0.065/0.065/0.065/0.065 | 1.885 x 2.382 | 1.794 x 2.276 | 1.794 x 2.276 | +0.0000, +0.0000 | 0.0000 |
| S2 **changed** | 0.090/0.100/0.090/0.090 | 2.287 x 3.157 | 2.009 x 2.851 | 2.009 x 2.851 | +0.0000, +0.0000 | 0.0004 |
| W1 | texture's own | 1.352 x 1.096 | 1.352 x 1.096 | 1.352 x 1.096 | -0.0000, -0.0000 | 0.0000 |
| W2 | texture's own | 1.567 x 2.278 | 1.567 x 2.278 | 1.567 x 2.278 | +0.0000, +0.0000 | 0.0000 |
| W3 | texture's own | 1.040 x 1.266 | 1.040 x 1.266 | 1.040 x 1.266 | +0.0000, +0.0000 | 0.0000 |
| W4 | texture's own | 1.265 x 1.416 | 1.265 x 1.416 | 1.265 x 1.416 | -0.0000, +0.0000 | 0.0000 |
| W5 **changed** | 0.110/0.105/0.110/0.110 | 1.610 x 1.869 | 1.554 x 1.796 | 1.554 x 1.796 | +0.0000, +0.0000 | 0.0000 |
| W6 | shaped canvas, no frame | 1.976 x 3.306 | 1.976 x 3.306 | | | 0.0000 |
| W7 **changed** | 0.190/0.200/0.200/0.200 | 2.230 x 1.708 | 2.095 x 1.622 | 2.095 x 1.622 | -0.0000, -0.0000 | 0.0000 |
| W8 | texture's own | 1.352 x 2.241 | 1.352 x 2.241 | 1.352 x 2.241 | -0.0000, +0.0000 | 0.0000 |
| W9 **changed** | 0.100/0.100/0.100/0.100 | 1.926 x 1.359 | 1.864 x 1.295 | 1.864 x 1.295 | -0.0000, +0.0000 | 0.0000 |
| W10 **changed** | 0.140/0.150/0.140/0.150 | 2.007 x 1.597 | 1.887 x 1.522 | 1.887 x 1.522 | +0.0000, -0.0000 | 0.0000 |
| N1 | texture's own | 1.636 x 2.456 | 1.636 x 2.456 | 1.636 x 2.456 | +0.0000, +0.0000 | 0.0000 |
| N2 | texture's own | 1.808 x 2.860 | 1.808 x 2.860 | 1.808 x 2.860 | -0.0000, -0.0000 | 0.0000 |
| E1 **changed** | 0.090/0.090/0.090/0.090 | 2.503 x 1.803 | 2.326 x 1.647 | 2.326 x 1.647 | +0.0000, -0.0000 | 0.0000 |
| E2 | texture's own | 1.288 x 1.552 | 1.288 x 1.552 | 1.288 x 1.552 | -0.0000, +0.0000 | 0.0000 |
| E3 | texture's own | 1.290 x 1.098 | 1.290 x 1.098 | 1.290 x 1.098 | -0.0000, -0.0000 | 0.0000 |
| E4 **changed** | 0.105/0.105/0.105/0.105 | 1.912 x 1.473 | 1.836 x 1.407 | 1.836 x 1.407 | -0.0000, +0.0000 | 0.0000 |
| E5 **changed** | 0.270/0.450/0.270/0.260 | 2.436 x 3.013 | 2.280 x 2.920 | 2.280 x 2.920 | +0.0000, +0.0000 | 0.0007 |
| E6 | texture's own | 1.733 x 1.389 | 1.733 x 1.389 | 1.733 x 1.389 | -0.0000, -0.0000 | 0.0000 |
| E7 | texture's own | 1.843 x 1.347 | 1.843 x 1.347 | 1.843 x 1.347 | +0.0000, -0.0000 | 0.0000 |
| E8 | texture's own | 1.504 x 2.322 | 1.504 x 2.322 | 1.504 x 2.322 | -0.0000, +0.0000 | 0.0000 |
| E9 | texture's own | 1.805 x 1.496 | 1.805 x 1.496 | 1.805 x 1.496 | -0.0000, -0.0000 | 0.0000 |

worst frame box against canvas + bands: 0.0000 m; worst canvas box move: 0.0007 m

## Close views (200 px per metre, camera fixed on the canvas centre): slide-and-fit of the canvas, and the frame's outer size read in the picture

The canvas (5 cm in from its edge) of the before picture is slid over the after picture, up to 4 px each way; the best fit is the move.
The frame's outer size is read where its edge has contrast against the wall (the reading is kept only where the same reading on the before picture gives the known before size to 0.03 m).

| work | canvas move at best fit (px; 1 px = 0.005 m) | mean abs luma diff at best fit | outer expected after (m) | width read after (m) | height read after (m) |
|---|---|---|---|---|---|
| S1 **changed** | 0, 0 | 0.0000 | 1.794 x 2.276 | 1.795 (+0.001) | 2.285 (+0.009) |
| S2 **changed** | 0, 0 | 0.0007 | 2.009 x 2.851 | 2.025 (+0.016) | 2.865 (+0.014) |
| W1 | 0, 0 | 0.0000 | 1.352 x 1.096 | 1.360 (+0.008) | 1.110 (+0.014) |
| W2 | 0, 0 | 0.0000 | 1.567 x 2.278 | 1.565 (-0.002) | edge not readable |
| W3 | 0, 0 | 0.0000 | 1.040 x 1.266 | 1.045 (+0.005) | 1.280 (+0.014) |
| W4 | 0, 0 | 0.0000 | 1.265 x 1.416 | 1.270 (+0.005) | 1.425 (+0.009) |
| W5 **changed** | 0, 0 | 0.0000 | 1.554 x 1.796 | 1.570 (+0.016) | edge not readable |
| W6 | 0, 0 | 0.0000 | 1.980 x 3.310 | 1.965 (-0.015) | edge not readable |
| W7 **changed** | 0, 0 | 0.0000 | 2.095 x 1.622 | 2.090 (-0.005) | edge not readable |
| W8 | 0, 0 | 0.0000 | 1.352 x 2.241 | 1.360 (+0.008) | edge not readable |
| W9 **changed** | 0, 0 | 0.0000 | 1.864 x 1.295 | 1.880 (+0.016) | 1.310 (+0.015) |
| W10 **changed** | 0, 0 | 0.0000 | 1.887 x 1.522 | 1.895 (+0.008) | 1.535 (+0.013) |
| N1 | 0, 0 | 0.0000 | 1.636 x 2.456 | 1.650 (+0.014) | 2.465 (+0.009) |
| N2 | 0, 0 | 0.0000 | 1.808 x 2.860 | edge not readable | 2.875 (+0.015) |
| E1 **changed** | 0, 0 | 0.0000 | 2.326 x 1.647 | 2.335 (+0.009) | edge not readable |
| E2 | 0, 0 | 0.0000 | 1.288 x 1.552 | edge not readable | 1.540 (-0.012) |
| E3 | 0, 0 | 0.0000 | 1.290 x 1.098 | 1.290 (-0.000) | 1.100 (+0.002) |
| E4 **changed** | 0, 0 | 0.0000 | 1.836 x 1.407 | 1.845 (+0.009) | 1.420 (+0.013) |
| E5 **changed** | 0, 0 | 0.0034 | 2.280 x 2.920 | edge not readable | edge not readable |
| E6 | 0, 0 | 0.0000 | 1.733 x 1.389 | 1.735 (+0.002) | 1.395 (+0.006) |
| E7 | 0, 0 | 0.0000 | 1.843 x 1.347 | 1.825 (-0.018) | 1.320 (-0.027) |
| E8 | 0, 0 | 0.0000 | 1.504 x 2.322 | 1.505 (+0.001) | edge not readable |
| E9 | 0, 0 | 0.0000 | 1.805 x 1.496 | 1.815 (+0.010) | 1.510 (+0.014) |

works whose canvas fits best at a move other than 0, 0: 0

## Checks after the bake

1. `museum_playtest.gd --only=objects --objects=S2,S1,E1,W10,W5,W7,W9,E4,E5,W2,E8,N1`: 12 objects, 0 failures.
2. `museum_playtest.gd --only=interaction`: 9 checks, 0 failures.
3. `visitor174_check.gd` with `--fixed-fps 60`: PASS. Without `--fixed-fps`, on a loaded host
   (load 13), it reported two walking-speed faults (0.19 to 4.69 m/s); that is frame timing.
4. `scripts/check.sh`: stops at REPRESENTATION_CHECK with the 16 lines known on this tree, none a
   Hall work: st-george, flute-player, hudibras, recamier in the build and not declared; 2017.46,
   2000.103.3, 06.057, 83.152 declared as mesh and not placed; 2017.74.16, 2017.74.17, 37.201,
   2017.74.14, 1998.107, 41.012, 42.219, 44.541 declared and not in the build.
5. `git diff --check`: clean.
