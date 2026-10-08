# Trim kit (#273): evidence

Pictures are from a local rebuild of this branch; the branch carries sources only, no bake.
`door_capture.gd` takes each doorway from the game's dollhouse camera and from close.

## 1. Doorway casing

`0-footage-doorways.jpg`: the doorway in the footage (IMG_6383 62.5 s, IMG_6380 236.5 s,
IMG_6385 1.0 s): a white moulded casing about 15 cm wide, flush on the wall, a deep reveal with
a panelled soffit, the leaf folded into the reveal.

`1-casing-<room>-<side>.jpg`: before on the left, after on the right; game camera above, close
below. Before: a flat textured strip on slab jambs standing 13 cm out of the wall. After: one
section (bead, fascia, ogee, back band; 18 facets) swept up the jamb, across the head and down,
mitred, flush on the wall, with a lining back to the plane the two rooms share. Every cased
opening `build_rooms()` makes uses it: 19 door sides in 11 rooms and stubs (the architecture check counts them).

Still plain:
- The reveal is 6 cm deep on each side. Two rooms share one wall plane in the plan, so there is
  no thickness for the footage's 0.5 to 0.9 m panelled reveal; only the three doors that already
  have a threshold room (Hall to grey gallery, Rockefeller to European gallery, Skylight) have one.
- No folded leaf is added; the leaves that existed are unchanged.
- The casing takes the room's light, so in an unlit room it reads grey until the lighting ticket
  (#274) lands.

Checks on the rebuilt tree: architecture check no failures; playtest doors 38 crossings and views
110 pictures, 0 failures; `scripts/check.sh` passes.
