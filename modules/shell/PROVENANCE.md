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

The #168 trial changes no image pixels. Independent blind review rejected the
world-space full-floor image because its painted herringbone overlapped the
modeled planks, and rejected the first per-board UV revision because geometry
was still too dense. The current isolated candidate samples one interior
`oak-muse.webp` board strip with restrained UV crop, tone and warmth variation.
Only the modeled geometry defines herringbone. UV1 was remapped locally per
plank; the modeled planks were broadened as a visual trial, not as measured
RISD dimensions. Its latest unselected material also samples only a heavily
filtered 4×4 mip of the `floor.png` pass for broad colour variation; no second
herringbone detail is intended. Matched diagnostic renders isolated the
remaining repeated V stripe to `oak-muse.webp`'s cross-board luminance band,
not to the lightmap or board-colour tint. The current seventh trial subtracts
a blurred mip-5 version of that same source oak sample, retaining authored
fine grain but removing the broad reused band. A restrained geometry-derived
board join restores some plank readability at 720 without resampling the source
stripe. Its rebaked native and exported-Web 720/1600 evidence **failed** fresh
independent image-only review: native 720 flattened near the doorway, Web 720
retained regular V columns, and 1600 grain/finish remained too uniform.
Four subsequent shader-only previews were self-rejected without a rebake.
The RISD crop does not resolve enough distinct wood grain, the Muse oak pass
contradicts its no-boards/no-large-knots prompt, and the Muse floor pass has
its own herringbone that doubles the modeled geometry. A new source-led
board-level edit is needed before visual selection. Flat-albedo capture showed tiny dark specks
persist without oak pixels, and a trial removing floor shadow casting did not
remove them; that
no-benefit change was reverted. The speck source remains unresolved.
Godot 4.7.2 regenerated the saved UV2/lightmap scene. Authoring provider:
local GDScript/shader. Image-generation provider/model/count/cost for this
trial: none / none / 0 / USD 0. Native and Web before/after captures and the
blind-review status are recorded in `docs/evidence/floor-168/README.md`. The
seventh floor candidate failed independent blind acceptance; this is not a
runtime-selected asset.

## Source-guided board-atlas trial — issue #168

One new Muse edit output was submitted through OpenRouter as a bounded floor
repair. The input order was the local RISD floor crop above, then the rejected
`oak-muse.webp` texture above as a material-family reference only. Their hashes,
the exact prompt, and the frozen plan are in `image-work/floor-168-board/`.
Provider/model: OpenRouter `meta/muse-image`; count: 1. Run:
`run-082b39a8176407a9c5f4c563`. The pipeline reserved USD 0.01;
the run state records actual cost USD 0.01 but retains `spendState: unknown`
for retry safety, and the
run must not be resubmitted. The materialized WebP and this prototype's
`textures/oak-board-atlas-168.webp` have SHA-256
`07ba958b7c4008687578c117c2eef80d2a232f3612da799e3557b24e96d98190`.
An independent image-only atlas preflight found four distinct plausible oak
faces, but flagged brighter yellow-gold contrast and pale scratches. It is
only input to the trial, not a pass of the rendered gallery floor. The atlas
remains outside the selected build. Its final 720/1600 native and exported-Web
captures failed fresh independent image-only review: repeated V columns,
comb-like grain, flat finish and native/Web sharpness difference. Evidence and
the unselected bake are retained in `docs/evidence/floor-168/`.

## Second source-photo oak atlas trial — issue #168

The tenth floor experiment uses two reference-only photographs of this exact
gallery from [Site Specific's Radeke Museum renovation page](https://www.sitespecificllc.com/rhode-island-school-of-design-radeke-museum).
The ordered 2500×1667 sources, exact URLs, SHA-256 hashes and prompt are in
`image-work/floor-168-board-v2/`; the photographs are not shipped as textures.
OpenRouter `meta/muse-image` returned one eight-face diffuse atlas at actual
recorded cost USD 0.01, run `run-e098a83f7967ea5cc2ba2c2e`, SHA-256
`8b568b890e7ffa5a2ef86173b21222b3bc6374d7abea15be5ea1865532524aec`.
The run is never-resubmit. Independent image-only review accepted its source
appearance only, with warmer/tile-seam caveats. The modeled-board rebake passed
technically, but a first native/Web world-asset review failed the
continuous-chevron impression, faint end joints and uniform finish. A
no-rebake seam/tone correction then passed a fresh native/Web image-only
review with minor sheen/grain and scene-wide native-softness reservations.
This is the selected floor visual candidate, pending navigation and build
integration checks; it is not acceptance of the wall or skylight batches.
the current build retains the previous floor.

## Blue wall visual trial — issue #168, 2026-09-28

The isolated `heartbeat/surface-168-0800` trial reuses the existing
`prototype/gallery_walk4/textures/wall.png` unchanged (SHA-256
`1d5442054d96e092675f41929cf1245a247ec677e13f23b7eccd42f0f22f0a60`),
with a `(1.35, 1.45, 1.65)` material tint and a new Godot 4.7.2 lightmap.
The texture entered the repository at `5b58d527`; its original provider and
source recipe are not established. Comparison references are the already
tracked `image-work/grand-gallery-v2/source/wide-north-entry.png` and
`image-work/grand-gallery-v2/references/wall-west-arch-to-door.png`, hashes
and exact blind visual findings in `docs/evidence/surface-168-0800/README.md`.
The reviewer passed the *visible wall*; World Asset Gate provenance remains
open, so this is not a selected build asset. No generated image, paid provider
call, or spend occurred in this trial.

## Isolated vault cap trial — issue #168, 2026-09-28

The `heartbeat/skylight-168-1000` trial derives its cap geometry and Godot
lightmap from `prototype/gallery_walk4/walk4.gd` and `bake/prepare.gd`; the
unchanged Muse skylight input is SHA-256
`5de8accfe1a91a4e4e6b3951329579076ae43479227b2959375a4d7ea431c86c`.
The final cap trial's `room.exr` / `room.lmbake` / `room.tscn` hashes and three
blind-review failures are in `docs/evidence/skylight-cap-168-1000/README.md`.
Provider none, generation count 0, cost USD 0. The trial is rejected and is
not folded into the build.
