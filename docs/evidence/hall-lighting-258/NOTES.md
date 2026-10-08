# Main Hall: original light restored, wall patches removed (#258)

Branch `fix/hall-lighting-258`. The owner, 7 Oct, after playing the build: "The center room
should go back to the original lighting it was in. It shouldn't be this dark room that it's in
right now." and "there's like sort of some glitching ... with some of the painting walls."

Each picture is the same camera at three states: the commit just before the re-light
(`a29ad9e9`), the build the owner played (`88b7c207`), and this branch. All rendered here on
the Web build's renderer (GL Compatibility, `--rendering-driver opengl3`, 960 x 640).

## Which light is "the original"

The Hall's lightmap (`baked/room.exr`, `room.lmbake`) is the same file, byte for byte, in
every commit from `dbfe2393` (29 Sep, "Warm gallery light and floor") to `a29ad9e9` (1 Oct):
git blob `2fd8b38b` and `4497d86f` throughout. `b40d0091` (1 Oct, the New Horizons re-light)
is the first commit that replaces it. So the light the owner saw and approved on 26-30 Sep is
the light of `a29ad9e9`, and that is what is restored. The Web screenshot recorded on 29 Sep
(`docs/evidence/collection-interaction-189/web/gameplay.png`) shows the same warm floor,
white skirting and grey-green wall.

## What changed

1. `gallery_walk4/bake/prepare.gd`: every lamp value is back to what it was at `a29ad9e9`
   (fill 0.55, spots 6.8 at 25 degrees aimed at the painting's centre, daylight 0.35 across
   the Hall, environment 0.18, skirting and cornice glow 0.55 and 0.35). The only lamp that
   differs from then is the portal fill, which follows the shallow portal of `76a2758b`.
2. The Hall is baked again with those values (`BAKE_OK users=137`, 139 surfaces, 7 min 34 s).
   The old lightmap could not simply be put back: the white label cards and the shallow
   portal came after it and change the Hall's surfaces.
3. Kept from since the re-light: the white label cards under each frame, click-to-inspect,
   the shallow portal, the doorways into the added rooms. `walk4.gd` is not touched.
4. `collection_reconstruction/remodel_room.gd`: the two piers of the European gallery stop
   2 cm short of the Hall's wall (see below), and the added rooms are rebuilt with
   `scripts/rebuild_rooms.sh` (`BAKE_OK`, 1554 lightmap users, 430 probes).

## Whole-picture brightness (mean display luma, 0 to 1)

| View | Before the re-light | Current build | This branch |
| --- | --- | --- | --- |
| west wall, near bay | 0.407 | 0.174 | 0.413 |
| west wall, middle | 0.432 | 0.221 | 0.445 |
| west wall, far bay | 0.438 | 0.239 | 0.441 |
| east wall, near bay | 0.450 | 0.206 | 0.454 |
| east wall, middle | 0.494 | 0.248 | 0.499 |
| east wall, far bay | 0.488 | 0.237 | 0.491 |
| far-end wall | 0.529 | 0.304 | 0.520 |
| arch-end wall | 0.418 | 0.212 | 0.410 |
| follow view down the Hall | 0.463 | 0.210 | 0.467 |
| follow view back | 0.472 | 0.226 | 0.477 |
| mean of the ten | 0.459 | 0.228 | 0.462 |

The current build is half as bright as the approved Hall. This branch is within 0.013 of the
approved Hall in every view. It is not pixel-identical: it is a new bake, and the label
cards, the portal and the rooms seen through the two doors have changed since 1 Oct.

## The pale patches on the wall

They are not lightmap texels. They are two white piers of the European gallery, the room
behind the Hall's west wall (`remodel_room.gd`, `build_adjacent_gallery`, there since 30 Sep).
Each pier was built with its back face exactly on the Hall's west wall (x = -5.000 m in Hall
metres; pier box -5.44 to -5.00). The Hall's wall is a sheet with no thickness, so the two
surfaces share one plane and the renderer shows one or the other pixel by pixel: horizontal
bars seen square on, a zig-zag seen at an angle. Each pier's foot also reached 2.5 cm into
the Hall. Evidence, in `9-cause-of-the-patches.jpg`, all on the current build:

1. Hide the added rooms and the patches go.
2. Remove the Hall's lightmap and the patches stay, lit, on a black wall.
3. Hide the Hall and the two piers stand exactly where the patches were (z -20.15 to -19.25
   and -24.9 to -24.0, 3.5 m tall).

The patches were already there before the re-light (`2-west-wall-far-bay.jpg`, left panel):
pale bars on a grey-green wall. The re-light turned the wall nearly black and made them
glaring. The rooms were attached to the Hall on 1 Oct, so the builds of 27-30 Sep never
showed them.

Fix: the piers and feet stop 2 cm short of the wall; their fronts, the side the European
gallery sees, did not move. A scan of every drawn room mesh from six Hall views found no
other surface on or inside the Hall's four wall planes (19 meshes touched the Hall's box
before, 15 after: the four removed are the two piers and two feet; the rest meet it edge-on
at the doorways).

## Neighbouring rooms

The Hall's lightmap only lights the Hall's own surfaces; the added rooms have their own.
Measured from inside two neighbours, current build against this branch:

| View | Mean luma, current | This branch | Pixels differing by more than 3% |
| --- | --- | --- | --- |
| European gallery, facing the Hall wall, far bay | 0.590 | 0.590 | 0.0% |
| European gallery, facing the Hall wall, middle | 0.537 | 0.537 | 0.0% |
| grey gallery, looking through the door into the Hall | 0.380 | 0.400 | 7.9% |
| medieval room, looking through the portal into the Hall | 0.321 | 0.368 | 17.0% |

In the last two the only pixels that change are the Hall's own floor and walls seen through
the doorway (looked at side by side).

## Checks

All on `677ea9b2` (this branch merged with build `b707d92c`) unless a commit is named.

1. `scripts/check.sh`: `checks passed`, exit 0. `git diff --check` against the build: clean.
2. Museum playtest, `--only=views,objects`: 110 views, 177 objects, 0 script errors. All 23
   Hall paintings: "inspected, zoomed and closed". All 25 Hall and threshold views pass
   (largest flat share 0.269 against the 0.45 limit; the visitor is in every one).
   Two failures, neither in the Hall:
   - `2011.60` chandelier, marble stair hall, cannot be clicked. Known: it is the one failure
     the build's own census records (`docs/playtest/census-2026-10-08-rooms.md`).
   - `23.307X` Velvet Cover, Renaissance room, "the zoom page's picture is blank", a check
     that arrived with #271 in the merge. Run again for that work alone on the same commit
     it passes (blank share 0.175, "inspected, zoomed and closed"). So it is intermittent,
     like the blank zoom page #271 describes and could not reproduce. Not run on the build
     tip without this branch.
   The same pass before that merge (`5667a0dd`): 110 views, 177 objects, one failure, the
   chandelier.
3. The Hall's own rendered checks (`scripts/check-gallery.sh` list plus the five of the
   re-light's notes), on `5667a0dd`; the failing ones were also run on the build tip
   `e731ba74`:
   - pass: `visitor_check`, `rig/check`, `doorway_check`, `navigation_check`,
     `owner_repair_check`, `render_diagnostics_check`, `portal_traversal_check`,
     `cutaway_floor_check`.
   - fail the same way on the build tip, line for line: `final_render_check` (1 failure),
     `shot` (E6 half-visible), `rig/render_check` and `rig/contact_check` (script errors
     against the newer visitor; they hang and were stopped by `timeout`).
   - `dollhouse_shot`: 29 failures here, 30 on the build tip. The one this branch removes is
     "baked surface is black with runtime lights removed", the dark Hall. The other 29 are
     the same lines on both.
4. Wall-plane scan after the rebuild, on `677ea9b2`'s tree: no room mesh on or inside the
   Hall's wall planes.

## Pictures

1. `1-west-wall.jpg`, `2-west-wall-far-bay.jpg`, `3-east-wall.jpg`, `4-far-end-wall.jpg`,
   `5-arch-end-wall.jpg`: each wall at the three states.
2. `6-owner-view.jpg`: the owner's screenshot, then the same three paintings from the same
   side at the three states. The patch between the first two paintings is in the first three
   panels and gone in the fourth.
3. `7-follow-down-the-hall.jpg`: the walking view.
4. `8-european-gallery-side-of-the-wall.jpg`: the other side of the wall, with the piers.
   The middle and right panels are the same picture; the left one is the 1 Oct room before
   its contents were built.
5. `9-cause-of-the-patches.jpg`: the three tests above.

## Still not right, seen while doing this

1. The label cards read cream, not white, under the warm light (they are painted `#e9e4d4`
   and sit below the lamp pools). The re-light's notes said the same of the dark version.
2. The long walls read grey-green rather than blue-grey: the warm fill on blue-grey paint.
   This is the approved look, not a regression; the two end walls read bluer.
3. `bake/measure_light.gd` measures the New Horizons targets of #238 and fails on this light
   by design. It is not run by any check. `baked/lamps.json` has no reader.
4. The bake editor rewrites 20 texture `.import` files to VRAM compression (undoing the lossy
   import of `88b7c207`); they were restored by hand and the trap is in `bake/README.md`.
5. The piers are not treated as part of their wall by the cut-away in `main_build_walk.gd`
   (`_collect_parts` gives a wall side only to things hung above 0.25 m), so they stay when
   the European gallery's east wall is cut away. With 2 cm of clearance that no longer
   shows in the Hall; it is noted in case another wall-height solid is stood against a
   shared wall.
