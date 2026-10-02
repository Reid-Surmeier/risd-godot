# Main Hall light (#238)

Branch `room/light-hall`, cut from `a29ad9e9`. The Hall's bake lights were changed toward the
finish spec (`docs/research/2026-10-01-acnh-museum-polish-spec.md`, section 4, step 3), the Hall
was re-baked, and the label plates became white cards. Oak, wall colour, camera, geometry and
shaders are untouched.

## The five targets

Read by `modules/shell/prototype/gallery_walk4/bake/measure_light.gd` from six standard
dollhouse views (30 degrees down, 23 degree lens, 12 m; the visitor 2.4 m from the wall, three
places along each long wall), at the game's own 480 x 320, as display luma (Rec. 709 weights on
the encoded values), the way the spec sampled the footage. The zones are defined in the
script's comments. Numbers are the pixel-weighted result over the six views.

| Target | Wanted | Before (`a29ad9e9`) | After |
| --- | --- | --- | --- |
| 1. wall away from pools / wall in a pool | at most 0.33 | 0.797 FAIL | 0.181 PASS |
| 2. canvases / lit floor | at least 1.20 | 0.497 FAIL | 1.231 PASS |
| 3. lit floor / floor at the room's edge | at least 2.00 | 1.000 FAIL | 1.841 FAIL |
| 4. label card red / blue | at most 1.25 | 1.477 FAIL | 1.202 PASS |
| 5. whole-picture mean | 0.20 to 0.30 | 0.449 FAIL | 0.219 PASS |

| Zone (display luma) | Before | After |
| --- | --- | --- |
| canvases | 0.317 | 0.317 |
| wall in a pool (just above a frame) | 0.370 | 0.387 |
| wall away from pools | 0.295 | 0.070 |
| lit floor (brightest half-metre band) | 0.637 | 0.257 |
| floor at the wall's foot | 0.637 | 0.140 |

Floor luma by half-metre band out from the wall, before: [0.637, 0.588, 0.557, 0.554, 0.551, 0.553, 0.56, 0.557]; after: [0.14, 0.139, 0.16, 0.183, 0.206, 0.229, 0.25, 0.257].
Label card on screen, red over blue: before 1.477 on a plate painted
`#a3afb8` (itself 0.886, so a white card would have read about 1.67);
after 1.202 on a card painted `#e9e4d4` (itself 1.099).

Target 5 is judged against the dark-walled range because the Hall's walls are dark slate. The
pale-room range (0.35 to 0.40, the game's statue hall) cannot be met together with target 2:
canvases are unshaded and average 0.317 on screen, so the lit floor may be at most
0.264, and a picture that is half floor then cannot average 0.35.

## Light values changed (old to new)

All in `modules/shell/prototype/gallery_walk4/bake/prepare.gd`.

| Light | Old | New |
| --- | --- | --- |
| Fill omnis (five, on the centre line, 5.7 m up) | energy 0.55, `#ffe1b2` | energy 0.015, `#fff4dc` |
| Environment | 0.18 | 0.03 (colour `#dfd6c7` unchanged) |
| Daylight (directional) | energy 0.35, turned (-60, -75, 0): across the Hall onto the east wall; angular size 6 | energy 0.08, turned (-90, 0, 0): straight down through the glazing; angular size 15 (colour `#eff5ff` unchanged) |
| Painting spots (23) | energy 6.8; 25 degrees for all; angle attenuation 1.5; `#ffd391`; size 0.35; aimed at the painting's centre | energy 11; half-angle atan(0.62 x frame width / 3.80 m) held to 12-28 degrees (12.0 to 22.2 in this hang); angle attenuation 1.0; `#fffefb`; size 0.25; aimed a quarter of the frame's height above its centre |
| Far-doorway fill (0, 3.4, -23) | energy 0.8 | 0.26 |
| Arch fill (0, 2.5, -1.8) | energy 0.65 | 0.21 |
| Recess fill, portal fill (beyond the two doors) | 0.65, 0.9 | unchanged, so the doorways stay lit |
| Skirting glow (emission on the baked material) | 0.55 | 0.06 |
| Cornice and skylight-trim glow (emission) | 0.35 | 0.04 |

Where this departs from the spec's starting values, and why (each seen in a measured bake):

1. Fill is 3% of the old value, not a third. At 0.05 the floor at the wall's foot still read
   0.22 and the wall away from pools 0.09; targets 2 and 3 together need that floor under 0.13.
2. Spots are near white, not `#fff1d2`. The card's own paint is already cream (red 1.10 x blue)
   and the oak's bounce is warm: with `#fff6e8` the card measured red 1.31 x blue.
3. Spots are aimed a quarter of the frame's height above the centre and use angle attenuation
   1.0. Canvas and frame are unshaded, so a pool only shows on the wall around the frame; aimed
   at the centre with attenuation 2.0 the wall above the frames read 0.18 against 0.09 away
   (ratio 0.51), and the lower half of each cone lit the floor instead.
4. Daylight points straight down. In its old direction it washed the east wall and the floor
   at its foot (floor there 0.72 against 0.56 on the west side), which is a wall with no pools.
5. The skirting and cornice glow is a light in all but name (the code calls it "local neutral
   fill"); left at 0.55 the skirting would be the brightest thing in a dark room. It is a
   material value, so say if it should be put back.

## Lines touched outside `bake/` and `baked/`

`modules/shell/prototype/gallery_walk4/walk4.gd`, function `_place`, lines 2026-2038: the
comment (3 lines), `plate.size`, `caption.material_override` and `caption.position` (5 lines).
Nothing else in that file changed.

## Label cards

0.30 x 0.17 m, `#e9e4d4`, `caption_plate` metadata kept. 17 cards hang with their top edge 5 cm
below the frame's lower corner, right edge level with the frame's right edge (the side the
plate was on). Six frames hang with their bottom edge under 0.52 m, where a card below would
sit in the skirting (top at 0.28 m): W2, E5, E8, S2, N1, N2. Their card is beside the same
corner instead, 5 cm out, bottom edge level with the frame's. The frame edge used is
`outer`-based, as walk4's own `corners` are; E5 and N2 have uneven bands, so their real bottom
edge is 5 and 12 cm higher than that.
The card has no grey bars: only size, colour and position were asked for.
Bake pairing is unchanged: the prepared scene still has 139 surfaces in the same order, the
cards are still `Surface106`-`Surface109`, and the names `retained_hall_room.gd` relies on
(`Surface004`-`Surface011`) are the same meshes as before.

## `baked/lamps.json`

Written by `prepare.gd` from the Light3D nodes it has just built, so it cannot drift from the
bake. 37 entries, Hall metres: 23 `painting` (lamp position, the point it is aimed at), 5
`skylight` (the daylight is one directional lamp; the entries are points along the glazing's
centre line at 9 m, each with the floor point below it as target), 9 `fill` (the five centre
omnis and the four door fills). `energy` and `color` are the baked values.

## Pipeline

1. The old bake reproduces from unchanged sources: 139 surfaces prepared, `BAKE_OK users=137`,
   7 min 13 s. The result is close to the committed one but not identical (lightmap mean 0.331
   against 0.327; 4% of sampled texels differ by more than 0.02). Likely cause, from git
   history and not confirmed by a bake: the skirting's emission was added to `prepare.gd` in
   `583db13f`, after the last committed bake (`dbfe2393`); `room.tscn` was edited then, the
   lightmap was not re-baked.
2. Trap, seen: after a bake the editor leaves the previous lightmap texture in
   `.godot/imported/`, and the game shows the old light with the new probe data. Run
   `godot --headless --editor --import --path .` after every bake (checked here by comparing
   the cache's `source_md5` with `room.exr`).
3. Two bakes of the new light were possible in the time allowed; the second is committed.

## Checks

The five rendered Hall checks, run with `--rendering-method gl_compatibility` on `DISPLAY=:99`
(GL on the RTX), at the base commit and again on the final bake with the new cards:
`navigation_check`, `doorway_check`, `owner_repair_check`, `render_diagnostics_check`,
`portal_traversal_check`: all five exit 0 both times. No check script was edited.
Not run: the other harnesses in `scripts/check-gallery.sh`. Three of them hold brightness
thresholds that a darker Hall could cross and should be rerun: `dollhouse_shot.gd` (floor and
wall at the west wall above 0.08), `cutaway_floor_check.gd` (passage floor above 0.15, lit by
the unchanged portal fill) and `rig/render_check.gd` (the visitor's head by probe light alone).
`scripts/check.sh` was not run; `git diff --check` is clean.

## Pictures (looked at, before beside after)

1. `1-wall-west-*`, `2-wall-east-*`: before, an evenly lit olive wall, a glowing white skirting
   and a floor brighter than everything. After, slate walls nearly black, a pale arch of light
   over each frame, the paintings the brightest large things, the floor dark at the wall and
   lighter toward the middle of the Hall. Warm patches remain on the floor under the widest
   frames (their cones still reach the floor).
2. `3-bench-*`: the sun patch on the east wall's foot is gone; the floor is lighter down the
   middle than at the walls, but the difference is gentle, not a bright pool.
3. `4-follow-*`: an arch over every work down both walls; the vault is dim under a bright
   skylight.
4. `5-painting-and-label-*`: the card hangs under the frame's lower right corner and is easy to
   find, but reads grey (about 0.3), not white: it sits below the cone.
5. `6-visitor-five-places-*`: the visitor reads the same at all five places, neither dark nor
   blown out.

## Not achieved, and what remains

1. Target 3 fails: lit floor 0.257 against 0.140 at the wall's foot is 1.84, wanted 2.00. The
   floor at the wall's foot is lit by the spots' spill and bounce. Target 2 caps the lit floor
   at 0.264, so the foot of the wall has to come down to about 0.128: one more bake with the
   spots near energy 8 should do it (see next point). Not tried: the time ran out.
2. The pools are stronger than intended: the wall over a frame reads 0.387, above the canvases'
   average of 0.317. Target 1 would still pass with pools near 0.30.
3. The label cards read grey rather than white (item 4 above). Making them white needs either
   light of their own or an unshaded card, which is a material change.
4. The floor pool under the skylight is modest (0.26 against 0.14). A brighter one fails
   target 2 because the canvases cannot get brighter.
5. The void behind cut-away walls (`#20242a`, luma 0.14, set in `walk4.gd`) is now brighter
   than the unlit wall (0.07). Not a light, so not changed.
6. Lamp heads still do not glow, and the spots hang in mid-air 2.2 m from the wall rather than
   at the modelled track lamps (spec step 6, runtime).
7. The added rooms' bake (`collection_rooms/`) is untouched.
8. Scratch (bakes, pictures, logs) came to about 130 MB and was deleted; the worktree's import
   cache (`.godot/`, about 370 MB) stays with the worktree.


## The visitor at five places

Mean display luma of the visitor alone (its own lamp included), and after the re-bake the share
of its pixels over 0.97 (blown) and under 0.04 (lost).

| Place | Before mean | After mean | After blown | After dark |
| --- | --- | --- | --- | --- |
| arch-door | 0.411 | 0.365 | 0.0% | 0.7% |
| centre | 0.416 | 0.361 | 0.0% | 0.7% |
| east-wall | 0.401 | 0.358 | 0.0% | 0.7% |
| far-corner | 0.374 | 0.353 | 0.0% | 0.8% |
| west-wall | 0.410 | 0.356 | 0.0% | 0.7% |

Bake times on this host (software Vulkan, other agents baking at the same time): reproduction of
the old bake 7 min 13 s (8 min 26 s with preparation and editor start); final bake 8 min 30 s (9 min 41 s with preparation and editor start); the first bake of the new light took 12 min 54 s under heavier load.
