# Doorway prototype — issue #160

This branch is a throwaway asset experiment, not accepted runtime art. Existing
gallery asset provenance remains in `image-work/grand-gallery-v4/README.md` and
`image-work/gallery-dollhouse-materials/README.md`.

The new `prototype/gallery_walk4/textures/ivory-trim.svg` is authored vector
albedo, sampled by explicit UV1 coordinates on modeled molding profiles. Its
subtle ivory bands are a material interpretation of the photographed trim,
not recovered museum texture or an AI-generated image. Authoring provider:
local Godot/SVG. Model: none. Paid calls: 0. Cost: USD 0.
SHA-256: `89a3ccde5dfb4d78c4023e35e1ae9b3cc457ecb240b67994ba3af7612951c776`.

Source references, unchanged:

- `image-work/grand-gallery-v4/surfaces/references/door-far-crop.png`:
  `f27b73f89da8bb6cda3718f9c6e71c5d4f6ab7fc3ae825fc002c87290f41622c`.
- `image-work/grand-gallery-v4/surfaces/references/wall-crop.png`:
  `d5050b20d1b2919efba3a551372b2b3a952d027d618a9130c634f703736decd5`.

The full phone photo, capture date, and original crop coordinates remain
unverified, as documented by #153. Dimensions retain the preexisting opening.
Existing Muse wall and oak pixels are reused unchanged; the far wall gets a
material tint and local offline light. No new Muse invocation is claimed.
Godot 4.7.2 unwraps UV2 and bakes the saved room lightmap; there are no runtime
lights in the showcase. Bake hashes and captures are recorded in
`docs/evidence/doorway-160/`.

## Repair after the first blind review

The far-door photograph is removed from both the saved geometry and source
builder. Cream walls, ceiling, returning trim and the rear paneled doorway
are modeled. The former live-game placeholder recess is also removed for
this door, so gameplay shows the same baked asset as the fixed views.

The recess floor reuses the existing `textures/oak.png` without editing its
pixels (original v4 Muse oak-grain pass; recipe and reference prompt under
`image-work/grand-gallery-v4/surfaces/`). SHA-256:
`ea9d9966c0295584c531e5550aab372fee9d53662ffe12fd2553014c9ebaec0e`.
The authored vector `textures/exit-sign.svg` uses explicit path lettering,
not a font-dependent raster. Provider: local SVG. Model: none. Cost: USD 0.
SHA-256: `7f15231b789fb9539d2affcb90fcc593735f446191877a9427179ddfec9a1e07`.
No new image-generation calls were made for the repair.

## Cornice trial — issue #167

The cornice uses the same photographed doorway reference above plus
`image-work/grand-gallery-v4/surfaces/references/door-arch-crop.png`
(`6db20b89ef019e278646ae736268f5ff2e77d9a378d71d4c87ea8e7232bcf858`).
The photographs support pale rounded plaster relief, not exact section
dimensions. The existing prototype envelope is retained. Local authored
geometry supplies a roll and cove, UV1 supplies material coordinates, and
Godot 4.7.2 unwraps 25 mm UV2 and bakes the saved lightmap. A neutral fill is
isolated to this plaster material; no global room light is changed.

The hand-authored `prototype/gallery_walk4/textures/cornice-ivory.svg`
retains its pale ivory base, with the earlier decorative horizontal lines
removed because perpendicular extrusion UVs made them look like joints.
SHA-256: `69a315944cfca068373c0220beda9134b87df87b272607deb6bb48e736264bff`.
Provider: local Godot/SVG. Model: none. Paid calls: 0. Cost: USD 0.
The visible cornice batch passed independent Astra-medium image-only review;
it remains isolated from the build branch. The arch and benches are not
passed by that verdict. Evidence, bake hashes and the scoped gate are in
`docs/evidence/architecture-167/RESULT.md`.
