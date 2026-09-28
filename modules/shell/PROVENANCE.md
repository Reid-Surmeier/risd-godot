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

## Stone portal first batch — issue #167, independently rejected

Source: owner-video still `image-work/grand-gallery-v2/source/arch-outside.png`,
SHA-256 `fdaaf16656bfd239bde16c849d78d0238d672f50bbee0034ad24de9336dfbc10`,
and the second still `image-work/grand-gallery-v4/frames2/references/portal-t19.png`,
SHA-256 `7532d1e6ecf472436b2c2ce0818878e4c10d28a786d1cb5ed4ff43189386e78f`.
The archive identifies the owner video `IMG_6344.MOV` near 19 seconds.

Manual Godot geometry models three nested orders, paired supports, plain
splayed capital masses, imposts and bases. The existing opening and tunnel
depth are retained; section offsets are bounded prototype parameters, not
survey data. No specific capital figures or foliage are invented. The
existing Muse `textures/stone.png` pixels are reused unchanged, SHA-256
`54f9436e284d82827459666b4d73c24e6bd0b54f62b3a44c810c57f9ddb6d882`.
UVs sample grain inside a stone block with physical face proportions; real
geometry supplies the radial joints. Source/limits: `PORTAL-SOURCE.md` in
the architecture evidence folder. Provider for new work: local Godot.
New image calls in that first batch: 0. New cost: USD 0. Independent image-only
review failed the capital mass, mechanical stone and passage transition;
see `docs/evidence/architecture-167/BLIND-REVIEW-PORTAL-1.md`.

## #167 portal capital modeling guide (not runtime art)

OpenRouter `meta/muse-image`, saved Muse edit, one output, declared/report
USD 0.010000; spend state remains `unknown` (no blind retry). Run
`run-98f29412a000da0b764a2be2`. Source: owner portal still
`image-work/grand-gallery-v2/source/arch-outside.png`; style-only reference:
`image-work/grand-gallery-v2/references/style-grand-gallery-final.png`.
Prompt/recipe/reference hashes and visual limitations are in
`image-work/architecture-167/README.md` and its saved plan.
Output `portal-capital-guide.webp` SHA-256
`5587dd51fd7f3eb2fc2531716b62bf6c0d7d6365b38cc6a35b0a759a3ae527f1`.
Self-inspection rejects exact ornamental fidelity: it regularizes/sharpens
details beyond the photo. Broad rounded/carved mass is a modeling guide only;
the image is not an accepted runtime decal or displacement asset.

The earlier authored-geometry trial used rounded lobes and scroll recesses,
thicker supports, real narrow arris bevels, quieter joints and multiple
interior-stone UV patches. The passage uses clipped modeled planks on the
same lattice as the gallery, below the retained y=0 live threshold. The
generated guide's invented iconography is not copied. This trial is not
independently accepted and has not entered the build branch.

### Post-portal4 repair, independently rejected as portal7

The source-only four-face capital relief is recorded in
`image-work/architecture-167/README.md`; local Godot provider, USD 0 additional
cost, JSON SHA-256 `8a38552770d32ec3b775ca1fda935d5231186bc91a2d8f4763988ca4f70880bc`.
It replaces the repeated analytic scroll motif with four individual owner-
photo cues. The shallow impost band and uneven arch joints are bounded
geometry interpretations, not surveyed dimensions or photogrammetric depth.
The rejected Muse guide remains excluded from runtime.

The white live threshold overlay is removed. Actual arch movement retains
world coordinates, modeled parquet and room lighting; the inherited far-
door QA room is unchanged. The depth-ID diagnostic cannot substitute for
native/exported walk images. Portal4's independent FAIL is preserved in
`docs/evidence/architecture-167/BLIND-REVIEW-PORTAL-4.md`.

### Portal8 source-led repair trial, not selected

Portal7 failed independently on repeated impost decoration, mirrored-looking
capital pairs, stretched stone, layered joins and the floor-pattern seam.
Exact findings are in `BLIND-REVIEW-PORTAL-7.md`; its packet stays immutable.
The next local Godot trial samples two separate owner-photo impost bands
instead of the analytic repeating diamond; capital bodies use individually
bounded profiles, not measured dimensions. No paid request or Muse output is
used. Source-only JSON SHA-256:
`796c7e6a0574ad37b12e82a9fd4d26a065169b0632030e428fea221fd611ef04`.
The source photo/hash and exact perspective quadrilaterals are recorded in
`image-work/architecture-167/README.md`. Additional provider cost: USD 0.

### Portal10 — six supports from closer official references, unreviewed

RISD Museum's full portal and capital-detail photographs supersede the soft
video cue for the next geometry trial. Primary links and photo hashes are
in `docs/evidence/architecture-167/PORTAL-CLOSER-SOURCES.md`. The photos are
inspection references only, not shipped textures. The local Godot script
produces six 96×96 bounded relief fields and two separate impost fields:
JSON SHA-256 `6cd956768fa19fec696533078f4020d42fd8eee4840c0b3953acdd87a0766314`.
Three staggered shafts per side and stepped impost sections are fitted to
the existing surround envelope; depth/proportions are visual interpretation,
not surveyed geometry. No additional paid call; USD 0. The old Muse guide
remains excluded. Independent acceptance is still required.

### Portal11/12 — authored form probes, not accepted runtime assets

Portal10's photo-luminance depth was self-rejected for noisy, pitted surfaces.
`portal_sculpt_relief_prepare.gd` now authors six smooth leaf/scroll/figural
fields and two-tier impost cuts using the official photographs as visual
references, without reading photo pixels. Provider: local Godot authoring;
paid generation count: 0; additional cost: USD 0. These are bounded visual
interpretations, not a scan or a surveyed reconstruction. The rejected Muse
guide remains excluded. Current authored JSON SHA-256:
`32567a93487a67818e12be440e7b6277305e0662efeed8c3b5f5fb143330f2ba`.
Generator SHA-256:
`f3e976887302a3690612f78de5bfcba8b9787e4fec3cb47f9f16b0ede9550b65`.
The directly lit flat-material probes are geometry diagnostics only. A
subsequent portal12 bake completed with 120 lightmap users; saved hashes and
native self-inspection limitations are in `PORTAL12-FORM.md`. Independent
acceptance remains pending; this candidate is not integrated.

### Portal13/14 — unaccepted source repair

Existing official portal references guide the outer fan-carved band and connected capital forms. Existing stone texture is unchanged; continuous UVs, slope-correct shaft normals and aligned imposts are geometry/material-coordinate corrections. No photo brightness used as depth. Local Godot authoring; zero paid calls, USD0. Saved room remains Portal12 until a new bake is explicitly recorded.

| Source | SHA-256 |
| --- | --- |
| `portal-capital-relief.json` | `25c7f5b414e6f519d81c29a2d6c0434a4a683a5b72dfb222b323a7af1574ec1b` |
| `portal_sculpt_relief_prepare.gd` | `88b95549164040aae8758c34ed79286b39fdf0ce8112247a6941c9bd2395bbeb` |
| `walk4.gd` | `af8f81bb121de29cecdc5d9a40a7a5057786cfa8107c739669a519341eb7211f` |
