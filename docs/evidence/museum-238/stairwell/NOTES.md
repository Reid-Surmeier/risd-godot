# Stairwell at the lion stair landing (Issue #238)

Branch `room/stairwell`, cut from `8fca73d3`. This is a first version, **not baked**: the
coordinator stopped all bakes and will bake once after merging. `scripts/rebuild_rooms.sh --draft`
passes its architecture check; every picture here is an unbaked render.

## What is built

1. One open-well stair in place of the two straight flights. Each storey has three runs and two
   quarter landings: south up the west wall (9 risers), east along the south wall (11), north up
   the east wall (9) to the floor above. The same storey is built again below the landing, so the
   flight down starts on the east side beside the sculpture door and passes under the flight up.
2. The well: open between the runs, 3.36 m by 2.74 m, lined below the floor, with a dark floor one
   storey down and a closed wall under the landing edge.
3. One balustrade along the landing's south edge, joined to the handrails of both flights. Plain
   square bars, two to a tread; a wood handrail on the well side and a second one on the wall.
4. Grey treads with dark anti-slip strips, a white stringer and a sloped plaster soffit.
5. The landing floor: pale and grey-beige slabs, two to a square, set on the diagonal.
6. Two wall colours: grey on the west and east walls of the landing, white on the lion wall, the
   south wall and the stairwell's part of the west wall.
7. A ceiling over the landing, the edge of the floor above with its balustrade, the stairwell's
   upper walls and a laylight of 3 by 4 panes. All of these hide when the camera is above 3.4 m,
   as the other rooms' ceilings do (`opaque_ceiling`, `ceiling_details`). The run that arrives at
   the floor above hides with them, so from above the stair ends at its second landing.
8. Walking: the floor void is the whole stairwell, the collision floor stops at the landing edge,
   and one invisible guard crosses the room there. Baseboards no longer hang in the well.

## Measurements and the frames they came from

| What | Value built | Source |
| --- | --- | --- |
| Risers, west run | 9 (8 treads and the landing) | Counted: IMG_6387 000058 (28.5 s). IMG_6344 3.0 s agrees. |
| Risers, south run | 11 (10 tread ends between the landings) | Counted: IMG_6387 000014 (6.5 s). |
| Risers, east run | 9 | **Inferred** equal to the west run. At least 7 tread ends are visible in IMG_6387 000051 (25.0 s). |
| Corners | Quarter landings, not winders | Seen: flat platform with level skirting in IMG_6387 000059 (29.0 s), 000068 (33.5 s), 000031 (15.0 s); the corner below in 000043 (21.0 s) and 000039 (19.0 s). The upper south-east corner is **inferred**. |
| Rise over going | 0.49 (side runs), 0.52 (south run) | Measured 0.517: the south run seen side-on in IMG_6344 3.0 s (46.5 px rise per 90 px going). |
| Rise | 0.155 m | Ratios in IMG_6344 3.0 s: the flight is 6.84 risers wide and the landing rail 5.44 risers high. A 0.85 m door leaf gives 0.164 m, a 0.914 m rail gives 0.168 m. Built at 0.155 m so 29 risers and those ratios fit the room's existing well. |
| Going | 0.317 m (west, east), 0.296 m (south) | From the rise and the room's plan. |
| Width | 1.06 m (west, east), 1.10 m (south) | 6.84 risers. |
| Storey | 4.495 m (29 risers) | Follows from the counts. |
| Landing rail | 0.90 m; 0.84 m above a nosing | 5.44 risers is 0.84 m. |
| First riser | 1.1 m south of the medieval door's south jamb | Kept from the draft. IMG_6344 3.0 s puts it 1.3 times as far from the camera as that door's south reveal, which allows 1.1 to 1.7 m. |
| Laylight | 3 by 4 panes, 2.4 by 1.8 m | Panes counted in IMG_6387 000063 (31.0 s); size **inferred**. |
| Landing ceiling | 4.1 m (the room's height, unchanged) | By the door casing in IMG_6387 000028 (13.5 s) the real ceiling is nearer 3.85 m. |

The scale rests on the room's plan, which is itself unmeasured. The same frame shows the medieval
door leaf 2.82 times as high as wide, so the build's 2.7 m doors are probably too tall. Not mine to
change.

## Room-plan changes (`prepare_remodel.py`)

1. Bounds and the three openings: **unchanged**.
2. `floor_void`: `[10.55,13.55,33.715,37.615]` to `[10.55,16.15,33.715,37.615]` (full width).
3. `floor`: `basket-weave` to `stone-pinwheel`.
4. Collision patches removed: `landing east floor`, `ascending stair study`, `descending stair study`.
5. Walk trials: `landing_guard_blocked` moved to the new balustrade; `landing_stair_foot_blocked`
   and `landing_flight_down_blocked` added.

## Provisional

1. Everything is unbaked. The laylight is an emissive surface (energy 4.0) meant to light the well
   in the bake; that value has never been baked.
2. The slab pattern is a diagonal two-tone weave, not a rectified copy of the real paving.
3. The well's two south corners are square notches; the real stringer is curved there.
4. The soffit is one sloped plane per run; the real one sweeps round the corners.
5. The floor above is closed 1.2 m behind its balustrade, and the stairwell ceiling stands at 8.3 m.
6. Below, the real well goes down another storey and the floor below is open under this landing.

## Not done

Scroll panels and collars on the bars, the scroll at the head of the flight down, stone skirting,
the sash window at the lower landing, the oval wall lamps, the cornice (the two draft strips were
removed and not replaced), the ceiling track and spots, the sign "5" and its directory, the lion's
label, the grey text panel, the wall text, the fire devices and the access panel.

## What files outside my scope need

1. `remodel_room.gd` `build_rooms()`: the `basket-weave` branch is now dead. The default branch
   lays timber over the landing and `landing_additions.gd` takes it up again; a skip for
   `stone-pinwheel` there would be cleaner.
2. `remodel_bake.gd`: the landing now has a ceiling at 4.1 m, so its omni at (13.35, 3.8, 30.1) is
   the only light under it besides the lion spot. The omni at (14.4, 3.8, 35.915) hangs in the open
   well. Light levels must be looked at after the bake.
3. `main_build_check.gd` line 43: the stairwell reaches from 4.7 m below the floor to 8.3 m above
   it, so the probe count will not stay 350.
4. `remodel_review.gd` line 65: the ceiling count it asserts (3) was already wrong (5); it is now 7.

## How it was checked

1. `scripts/rebuild_rooms.sh --draft`: architecture check passes with no failures. The check now
   also fails if the stair or its guard is missing, does not fill its well, or does not reach the
   floor below.
2. I looked at 14 unbaked renders from eye height on the landing and from the medieval room, each
   against its footage frame. The stair is whole in all of them: no run ends in mid-air and no wall
   has a hole.
3. Not run: the bake, the walking self-check, the app's dollhouse views, the repo checks.

## Pictures

Each is footage, the build at `8fca73d3`, and this branch, left to right.

| File | Footage frame |
| --- | --- |
| `01-from-modern-door.jpg` | IMG_6344 3.0 s |
| `02-flight-up-and-west-wall.jpg` | IMG_6387 000015 |
| `03-across-the-well.jpg` | IMG_6387 000014 |
| `04-east-wall-and-flight-down.jpg` | IMG_6387 000012 |
| `05-down-the-well.jpg` | IMG_6387 000043 |
| `06-head-of-flight-down.jpg` | IMG_6387 000037 |
| `07-up-at-east-run.jpg` | IMG_6387 000051 |
| `08-laylight.jpg` | IMG_6387 000063 |
| `09-through-medieval-door.jpg` | IMG_6382 000041 |
| `10-lion-wall.jpg` | IMG_6387 000085 |
| `11-sculpture-door-wall.jpg` | IMG_6387 000075 |
