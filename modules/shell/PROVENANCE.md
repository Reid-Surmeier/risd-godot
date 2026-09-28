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

## Oak floor trial — issue #168

The recorded RISD Grand Gallery phone-photo crop at
`image-work/grand-gallery-v4/surfaces/references/floor-crop.png` is SHA-256
`d7636e7c478a7d423cf0fede9544cac9c5b40544babee1c088de983a57672b12`.
The original full-resolution phone file, capture date and crop coordinates
remain unverified. The initial floor's pre-existing Muse oak-grain pass at
`prototype/gallery_walk4/textures/oak-muse.webp` is SHA-256
`bb6f54cd7f4f423babaaacf8107dc735bb7fcb45118cacba9725bbbd3cb600c1`.
The rejected fine-strip trial sampled the existing finer Muse
`prototype/gallery_walk4/textures/oak.png`, SHA-256
`ea9d9966c0295584c531e5550aab372fee9d53662ffe12fd2553014c9ebaec0e`.
Its independent blind review failed the repeated comb-grain gate. The next
source-led trial instead samples existing Muse herringbone
`prototype/gallery_walk4/textures/floor.png`, SHA-256
`e4bda4edcd4c83bed11cc1d38eba9d5a7924aa822a9ce0a710a71a145d49ad1f`,
whose recorded generation input is the RISD floor crop above.
The original prompt and input hashes are in
`image-work/grand-gallery-v4/surfaces/generation-preflight.json`.

The #168 trial changes no image pixels. It uses a neutral material tint and
samples the source-guided herringbone albedo continuously in world space over
the modeled planks, avoiding the failed per-board fine-grain reset. The
herringbone geometry, authored plank UVs, and polygon count remain.
Godot 4.7.2 regenerated the saved UV2/lightmap scene. Authoring provider:
local GDScript/shader. Image-generation provider/model/count/cost for this
trial: none / none / 0 / USD 0. Native and Web before/after captures and the
blind-review status are recorded in `docs/evidence/floor-168/README.md`. The
world-space candidate awaits independent blind acceptance; this is not a
runtime-selected asset.
