# Mesh placing (#264): evidence

## The build ships no placed mesh

`place_mesh()` is in the room code and proved, but no shipped room calls it yet. The Head of
Christ (59.131) is the photograph slab it was, and still on the floor's shortfall list.

## Pictures: a mesh in a real room, at commit `2432986c`

For the proof a 6,000-triangle copy of the museum scan of Portrait of Hadrian (59.050) stood where
the Head of Christ belongs, in the medieval room, through a full rebuild (`BAKE_OK users=1553`,
430 probes). It was a different object from its caption, so it was taken out again. Each pair is
the same camera before and after (`capture.gd` here: fixed points in Hall-local metres, 45 degree
lens); before is the build at `3ab5c2c4`.

1. `1-front-before-after.jpg`: from the room, facing the south wall.
2. `2-oblique-before-after.jpg`: the slab's extruded brown side against a head with a profile.
3. `3-side-before-after.jpg`: from the west along the wall. Before, a brown plank; after, a head.
   The scan has no back: its flat cut and a few red texture faults show from here.
4. `4-playtest-inspect-zoom-room.jpg`: the playtest's pictures at that commit: the mesh clicked
   and inspected, its zoom page, the room's south view.

At that commit: `check.sh` passed, `main_build_check.gd` and `click_route_check.gd` had no
failures (166 cut-away bodies, one more than before: the mesh), and the playtest's views and
objects passes for the medieval room gave 5 views, 13 objects, 0 failures. The same objects pass
without the cut-away fix failed with `59.131#47: the work is not drawn in its own inspection`.

Measured cost of that mesh in the pack: imported scene 128 KB, texture 197 KB, baked copy in
`room.tscn` +394 KB, lightmap +87 KB: 806 KB for 6,000 triangles and a 1024 px texture.

## What proves it now

`placed_mesh_check.gd`, run by `scripts/check.sh`: the rooms are built with one fixture mesh (the
visitor's own model, 1.8 m, on clear floor in the grey French gallery) only when the run asks for
it. The check asserts it stands at its catalogue height, is drawn with its own texture unshaded
like the rooms' other works, has a collider, blocks walking, is a cut-away body, is registered as
a work, is still drawn when a visitor walks up and opens it, and is gone from another room's
stage. With the cut-away fix removed it fails: `the mesh is not drawn in its own inspection`.
The Web export was not run here.
