# Stone portal depth (#238)

Branch `room/portal-depth`, cut from `d85c0e20`. The owner said: "large stone archway is too far
out". The Romanesque portal (RISD 40.014) between the Main Hall and the medieval room was a
1.2 m stone tunnel with the columns in front of it. It is now a shallow frontispiece against
the wall, as in the footage (`survey-2fps/IMG_6382/000004` to `000020`). The opening's width
and height are unchanged.

## Measured

Bounds of the two baked portal meshes, read from the running game before and after (Hall
metres: the Hall's end wall is z = 0, its plaster reveal ends at z = 0.45, the medieval room is
z 0 to 6.1).

| | Before | After |
| --- | --- | --- |
| `Surface004` (stone), z | 0.45 to 2.22 | 0.02 to 1.22 |
| `Surface005` (carved capitals, friezes, outer band), z | 1.586 to 2.254 | 0.586 to 1.254 |
| Stone beyond the end of the plaster reveal | 1.77 m | 0.77 m |
| Stone beyond the wall plane (z = 0) | 2.22 m | 1.22 m |
| Where the visitor leaves the stone (`PORTAL_MOUTH`) | 2.2 | 1.2 |

x and y did not move: x -2.09 to 2.09; y 0 to 4.136 (stone), 1.867 to 4.217 (carving).
The medieval room gains 1.0 m of free floor in front of the portal; nothing in it was moved.

## What changed

1. `PORTAL_DEPTH` 1.2 to 0.2 (`walk4.gd`). The masonry behind the columns is 0.2 m, not 1.2 m.
2. The backing now reaches the wall. With thin masonry the piers stood 0.45 m off the wall
   with the back of the plaster reveal showing in the gap, so the pier courses and the two
   outer arch orders run back to z = 0.02, behind the reveal. The inner order crosses the
   reveal's head, so it stops at the reveal's end (it would have reached 1 cm into it).
3. One constant, `PORTAL_MOUTH` in `walk4.gd` (reveal 0.45 + `PORTAL_DEPTH` + 0.55 = 1.2),
   replaces the literal 2.2 and everything that copied it.
4. The Hall was re-baked (`bake/run.py`, 6 min 32 s, `BAKE_OK users=137`, 139 surfaces as
   before), then re-imported.

## Files and lines

| File | Lines | What |
| --- | --- | --- |
| `gallery_walk4/walk4.gd` | 85-91 | `PORTAL_DEPTH`, new `PORTAL_MOUTH` |
| | 1145-1152 | the stand-in room's far wall stays at 6.65 (was reveal + depth + 5.0, the same number), so 6.1 and 6.3 below it stay true |
| | 1262-1266, 1373-1375, 1443-1446 | `_portal_stone`: backing to the wall, inner order stops at the reveal |
| | 2850-2859, 2951-2953 | passage rule and follow-camera clamps read `PORTAL_MOUTH` |
| `collection_reconstruction/main_build_walk.gd` | 34-35, 763 | its own `PORTAL_MOUTH := 2.2` removed (walk4's is inherited); the stand-in room is hidden past `PORTAL_MOUTH + 0.1` (was 2.3) |
| `collection_reconstruction/retained_hall_room.gd` and its installed copy `collection_rooms/retained_hall_room.gd` | 41-45 | the two guard boxes read their depth from `Surface004` (were 1.77 m deep at z 29.425) |
| `gallery_walk4/bake/prepare.gd` | 288-291, 301 | portal fill light at `PORTAL_MOUTH + 1.8` (z 4.0 to 3.0): same distance to the stone as before |
| `playtest/museum_playtest.gd` | 97 | the Hall-to-medieval leg ends 0.9 m past `PORTAL_MOUTH` (was z 3.1) |
| `gallery_walk4/portal_traversal_check.gd` | 79-86 | its jamb test points follow `PORTAL_MOUTH` (were 2.0, 2.3, 2.199) |
| `gallery_walk4/baked/` | | `room.tscn`, `room.exr`, `room.lmbake`, `lamps.json` (only the portal fill's z) |

Left alone on purpose: `PORTAL_SIDE` 2.4 (the stone is as wide as before), `clampf(p.z, -0.2,
6.1)` and `eye.z` 6.3 (the stand-in room's far wall, not the mouth), `z -= 2.2` (track-lamp
spacing), the arch fill light at z = -1.8 (range 3 m, still covers the reveal and the stone).

## Checks

All on the re-baked tree, GL on the RTX (`gpu-env.sh`, `DISPLAY=:99`).

| Check | Result |
| --- | --- |
| `click_route_check.gd` | `CLICK_ROUTE_CHECK {"failures":[],"tests":16}` |
| `main_build_check.gd` | `MAIN_BUILD_CHECK {"failures":[],"probes":366,"removed_demo_triangles":1298}` |
| `visitor174_check.gd` | `PASS #236: accepted character, 24-bone rig, 23 paintings, ...` |
| `museum_playtest.gd --only=doors` | `MUSEUM_PLAYTEST {"doors":38,"failures":0,"objects":0,"rooms":0,"views":0}` |
| Portal legs in its report | Hall to medieval: arrived at (0, 1.91), 2.81 m, 5 footsteps; back: arrived at (0, -0.71) |
| Hall checks: `portal_traversal_check`, `navigation_check`, `doorway_check`, `owner_repair_check`, `render_diagnostics_check`, `cutaway_floor_check`, `portal_check` | all seven exit 0 |
| Baked stone against what `walk4.gd` builds now (bounds of both meshes) | equal |
| Floor in front of the portal (`_free`, x 1.5 and 2.2) | free from z 1.6; the guards now cover z 0.02 to 1.22 (were 0.44 to 2.21) |
| `git diff --check` | clean |
| `scripts/check.sh` | exit 1: eight seam-lint hits in `collection_rooms/*.gd` files this branch did not touch (their `painting_asset.gd` preload); no Godot error lines |

## Pictures (looked at, before beside after)

Taken from the game (`main_build_walk.gd`) at 960 x 640. Shots named `eye-...` use an
eye-level camera with every layer drawn; the others are the game's own dollhouse view.

1. `1-medieval-side-before-after.jpg`: from the medieval room. Front dollhouse view (visitor
   at z 3.4); eye-level front; the east jamb from the room; along the wall from the east;
   looking up under the arch. Before, a block the size of a small room with the visitor
   beside its front. After, the arch and its columns stand at the wall, the pier's side runs
   back to the wall with no gap, and the Hall shows through the opening.
2. `2-hall-side-before-after.jpg`: from the Hall. Dollhouse view at the door; the Hall seen
   from the east with the medieval room beyond the end wall; straight through the door;
   looking up at the door head. The white casing and plaster reveal are unchanged; the stone
   ring starts where the reveal ends, with no seam.

No gap, see-through seam, floating column or black face found in these views.

## Not done, not checked

1. The added rooms were not re-baked (`collection_rooms/addition_baked` is untouched), as
   instructed. The medieval floor and walls still carry light baked with the old block
   standing there. No dark footprint shows in the pictures, but that is the old bake.
2. `collection_rooms/retained_hall_room.gd` was edited by hand to match its source so the
   guards are right before the rooms are rebuilt; `main-build-adapter.json` still records its
   old hash until then.
3. The stone is still 1.22 m from the wall plane the room is built on: 0.45 plaster reveal,
   0.2 masonry, 0.57 columns and imposts. The footage reads as 0.6 to 0.8 m. Going further
   means shortening the reveal or compressing the column steps: a redesign, not done.
4. The pier's sides are dark: they face away from the one portal fill light, as the tunnel's
   sides did. From the Hall the top of the doorway now shows the room beyond rather than a
   stone soffit, because the stone there is 0.2 m deep.
5. Web export, the rooms/views/objects passes of the playtest and `scripts/check-gallery.sh`
   were not run.
6. The probe scripts and logs are scratch under `build/` (not committed); the loose
   pictures were deleted after the two sheets were made.
