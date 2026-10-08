# Main Hall lighting, first trial: a warm spot on each painting, quieter fill (#266)

The owner, 8 October, on the build with the #258 light: "you don't have spotlights on objects warm
glow. the main room baked lighting is so bad." This is one trial bake for him to look at, not an
accepted setting. Before is the bake of `5766fe7f`.

## What was there, and what the trial changes (`gallery_walk4/bake/prepare.gd`)

The Hall already had one spot per painting, but five fills, daylight and the environment drowned
them, and a spot aimed at a painting's centre from 3.1 m above it is brightest on the wall over the
frame: the pale patches above the pictures.

| lamp | #258 (before) | trial | the dark #238 light he turned down on 7 Oct |
|---|---|---|---|
| five ceiling fills | 0.55, #ffe1b2 | 0.30, #ffe1b2 | 0.015 |
| daylight | 0.35 | 0.20 | 0.08 |
| environment | 0.18 | 0.10 | 0.03 |
| spot on each painting | 6.8, #ffd391 (about 4000 K), 25 degrees, aimed at the centre | 12, #ffb46b (3000 K), 28 degrees, aimed 0.3 m below the centre | 11, white |

Lamp positions (2.2 m out from the wall, 3.1 m above the painting's centre), the doorway, recess,
portal and arch fills, and the bake settings are unchanged.

## Pictures

Same seven cameras as `docs/evidence/hall-frames-266`, the game's renderer.

1. `1-end-walls-oblique-follow.jpg`: far-end wall (footage IMG_6344 26.0 s, before above after),
   arch-end wall (footage 178.6 s, before above after), the oblique view and the follow view
   (before left, after right).
2. `2-long-walls-before-above-after.jpg`: west wall, east wall.
3. `3-floor-before-above-after.jpg`: the floor plan.

Seen in them: each painting now sits in a warm pool that starts in an arc just above its frame
and runs down the wall to the skirting and onto the floor; the wall between pools and the wall
above them are darker than the pools; the floor is still warm oak; the ceiling is quieter. The
skirting and the floor at the foot of the long walls take a warm orange band where the pools meet
them. The canvases and frames look exactly as before: they are drawn unshaded, at their source
colour whatever the light (`bake/README.md`), so they do not brighten with the pool and the gold
does not catch it.

## Brightness, whole picture (mean display luma, 0 to 1)

| view | before | after | diff |
|---|---|---|---|
| 1-west | 0.350 | 0.318 | -0.033 |
| 2-east | 0.366 | 0.327 | -0.039 |
| 3-far | 0.332 | 0.305 | -0.027 |
| 4-arch | 0.287 | 0.251 | -0.036 |
| 5-follow | 0.449 | 0.390 | -0.059 |
| 6-oblique | 0.475 | 0.412 | -0.064 |
| 7-floor | 0.559 | 0.493 | -0.066 |

## Away from the paintings

| region | mean luma before | after | diff | share of pixels differing > 3 % |
|---|---|---|---|---|
| 1-west: skirting (0.03-0.20 m) | 0.600 | 0.585 | -0.0150 | 32.9 % |
| 1-west: wall above 4.6 m, below the cornice | 0.384 | 0.316 | -0.0682 | 99.5 % |
| 1-west: cornice and above (> 5.8 m) | 0.655 | 0.534 | -0.1204 | 99.6 % |
| 1-west: wall columns > 0.9 m from any frame, 0.3-4.6 m | 0.215 | 0.194 | -0.0209 | 76.0 % |
| 2-east: skirting (0.03-0.20 m) | 0.730 | 0.713 | -0.0165 | 90.2 % |
| 2-east: wall above 4.6 m, below the cornice | 0.386 | 0.316 | -0.0693 | 99.5 % |
| 2-east: cornice and above (> 5.8 m) | 0.653 | 0.534 | -0.1195 | 99.6 % |
| 2-east: wall columns > 0.9 m from any frame, 0.3-4.6 m | 0.226 | 0.195 | -0.0316 | 80.4 % |
| 3-far: skirting (0.03-0.20 m) | 0.458 | 0.449 | -0.0091 | 66.4 % |
| 3-far: wall above 4.6 m, below the cornice | 0.375 | 0.328 | -0.0469 | 99.9 % |
| 3-far: cornice and above (> 5.8 m) | 0.671 | 0.573 | -0.0973 | 99.6 % |
| 3-far: wall columns > 0.9 m from any frame, 0.3-4.6 m | 0.266 | 0.243 | -0.0225 | 55.8 % |
| 4-arch: skirting (0.03-0.20 m) | 0.398 | 0.391 | -0.0074 | 70.1 % |
| 4-arch: wall above 4.6 m, below the cornice | 0.353 | 0.286 | -0.0662 | 100.0 % |
| 4-arch: cornice and above (> 5.8 m) | 0.616 | 0.501 | -0.1146 | 99.7 % |
| 4-arch: wall columns > 0.9 m from any frame, 0.3-4.6 m | 0.245 | 0.215 | -0.0306 | 52.5 % |
| 7-floor: whole plan | 0.559 | 0.493 | -0.0659 | 99.0 % |
| 7-floor: middle of the floor | 0.559 | 0.466 | -0.0927 | 99.6 % |
| 5-follow: lower half (floor) | 0.520 | 0.442 | -0.0785 | 94.3 % |

## What did not move

Read from the saved bake: every frame box equals canvas plus bands and no canvas box moved (worst
0.0000 m, 23 works). Slide-and-fit of every canvas in its close view: 0, 0 px for all 23.
`BAKE_PREPARE surfaces=139`, `BAKE_OK users=137`, 8 min 51 s under the lock.

## Checks

1. `museum_playtest.gd --only=objects --objects=S2,S1,E1,W10,E5,N1,W6`: 7 objects, 0 failures.
2. `museum_playtest.gd --only=light,interaction`: interaction 9 checks, 0 failures. Light: 16 checks,
   15 failures, none of them the Main Hall: ten added rooms and five threshold spaces, each with no
   lamp on record (`lamps: 0`) on this tree. Not run on the bake before, so whether all 15 were
   there before is inferred from that.
3. `visitor174_check.gd --fixed-fps 60`: PASS.

## Going back

`git checkout 5766fe7f -- modules/shell/prototype/gallery_walk4/baked modules/shell/prototype/gallery_walk4/bake/prepare.gd`

## If he wants more or less

Stronger pools: spot 16 to 18 and fill 0.22. Less orange at the skirting: aim 0.15 m below the centre
instead of 0.3, or 25 degrees. Frames that catch the light would mean baking light onto the frame
meshes, which are narrow against 0.12 m lightmap texels: a separate trial.
