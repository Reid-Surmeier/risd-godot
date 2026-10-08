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

## 2 to 5 and the deep reveal: seen unbaked only

These were looked at in the draft room project, where every room is drawn at once and nothing is
lit by the bake. The baked, in-game look is still to be judged from the integration rebuild.

- `2-4-unbaked-trim-exit-signs.jpg`: grey gallery north door, Rockefeller east door, European
  gallery north door: white casings and skirting; the two signs that were blank green boxes are
  lettered.
- `2-5-unbaked-piers-ceilings.jpg`: the European gallery's east wall with only the white display
  panel that IMG_6386 44.5/67.5 s shows (the two piers are gone); the new ceilings over the
  European gallery and Rockefeller. The grey gallery's ceiling is the same code and was not
  photographed.
- `reveal-unbaked-renaissance-north.jpg`: the Renaissance room's north door with the deep reveal:
  panelled cheeks, panelled soffit, threshold, fading to dark. In the game the far end is black;
  here the next room shows through.

To check in the baked game: the reveal is drawn only from its own room and never from the
European gallery; the 38 door crossings still pass and the wipe still triggers; the three new
ceilings close those rooms to the bake's daylight, so their lamps need setting for a ceiling (#274).

`reveal-unbaked-renaissance-european-both-sides.jpg` (later): the same doorway from the
Renaissance room (top) and from the European gallery (bottom), each with its own reveal. The
leaf is this door's own, two unequal panels (IMG_6386 102.75 s), folded flat on each cheek with
its knob (IMG_6383 62.5 s); the two leaves that stood open in the Renaissance room are gone.
In this draft view the other room's reveal also shows at the foot of the jambs, because the
draft draws every room; the game draws one.
