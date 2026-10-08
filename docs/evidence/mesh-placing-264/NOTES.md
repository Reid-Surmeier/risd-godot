# Mesh placing (#264): evidence

Tree: `feat/mesh-placing-264`, rooms rebuilt from it on 8 Oct 2026 (`BAKE_OK users=1553`, 430 probes).

## Pictures

Each pair is the same camera before and after (`capture.gd` in this folder: fixed points in
Hall-local metres, 45 degree lens). Before is the build at `3ab5c2c4`.

1. `1-front-before-after.jpg`: from the room, facing the south wall.
2. `2-oblique-before-after.jpg`: the slab's extruded brown side against a head with a profile.
3. `3-side-before-after.jpg`: from the west along the wall. Before, a brown plank; after, a head.
   The scan has no back: its flat cut and a few red texture faults show from here.
4. `4-playtest-inspect-zoom-room.jpg`: the playtest's own pictures after: the work clicked and
   inspected, its zoom page, the room's south view.

The mesh is a stand-in: the museum's scan of Portrait of Hadrian (59.050) stands where the Head
of Christ or a Saint (59.131) belongs, so the caption and zoom page describe a different object
from the one drawn. It is listed as `stand_in_mesh`, below the floor.

## What was run on this tree

| Check | Result |
| --- | --- |
| `scripts/check.sh` | `checks passed`; floor: 177 works, 69 shortfalls; scene: 177 built, 177 declared, no failures |
| `main_build_check.gd` | no failures, 430 probes, 166 cut-away bodies (was 165: the mesh) |
| `click_route_check.gd` | 16 tests, no failures |
| `museum_playtest.gd --only=views,objects --rooms=dark-medieval-room` | 5 views, 13 objects, 0 failures |
| The same objects pass before the cut-away fix | fails: `59.131#47: the work is not drawn in its own inspection` |

## What the mesh costs in the pack (measured in this tree)

Imported scene 128 KB, texture 197 KB, baked copy in `room.tscn` +394 KB, lightmap +87 KB: 806 KB
for 6,000 triangles and a 1024 px texture. Other sizes were measured in a scratch project with the
same steps: 1,000 triangles 28 KB as a scene; textures 21 KB at 256 px, 64 KB at 512 px.
The Web export was not run here.
