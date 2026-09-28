# #168 oak floor — isolated source-led prototype

Question: does a restrained oak treatment close the floor portion of the World Asset Gate at the square gameplay camera without changing painting/trim identity? This is the independent `Reid-Surmeier/prototype-floor-168` worktree based on the selected #160 doorway at `ef4d8b76`, **not** a runtime integration. The other two #168 surface groups (blue wall and skylight/vault) remain outside this slice.

## Source and controlled views

The local RISD Grand Gallery phone-photo crop is [`floor-crop.png`](../../../image-work/grand-gallery-v4/surfaces/references/floor-crop.png), SHA-256 `d7636e7c478a7d423cf0fede9544cac9c5b40544babee1c088de983a57672b12`. The original full phone photo, capture date, and crop coordinates are still unverified (see #153); the crop is a style and pattern reference, not survey geometry. Existing modeled herringbone and UV islands come from `walk4.gd`. The prior floor uses existing Muse `textures/oak-muse.webp`, SHA-256 `bb6f54cd7f4f423babaaacf8107dc735bb7fcb45118cacba9725bbbd3cb600c1`, with its prompt and input hash in `image-work/grand-gallery-v4/surfaces/generation-preflight.json`. No new Muse call or raw texture edit was made; paid spend USD 0.

The [initial before packet](before-browser/) and [initial after packet](after-browser/) contain exported Web screenshots at **720×720 and 1600×1600** for two poses; matching native screenshots are in [before-native](before-native/) and [after-native](after-native/). View 0 is the existing gallery gameplay camera above the middle bench, looking to the far doorway; view 1 is a lower, close floor detail of the same room. Both expose adjacent trim and artwork as controls. The `floor_prototype_capture.gd` and `floor_prototype_browser.cjs` scripts reproduce the camera packet; the latter uses the actual exported Web scene, not a mockup. The initial browser-before run recorded only a generic missing-favicon 404; its screenshots rendered. The corrected after-browser check recorded `errors: []`.

## First blind review — fail and confound audit

An independent GPT-6 Astra medium **image-only** reviewer saw the reference and all 16 first-round captures. Verdict: **FAIL overall**. Muted tan tone and herringbone alignment improved, but the floor became too smooth/repetitive and the 720 native mid-distance pattern washed out. The reviewer also saw softer painting-frame relief and EXIT text in the first before/after comparison. The doorway/baseboard geometry remained aligned. The initial material reduced Muse grain contribution from `0.60` to `0.35`, changed the ground tint from `(0.64,0.44,0.25)` to `(0.69,0.58,0.47)`, and narrowed per-plank tone from `0.90–1.06` to `0.96–1.03`. That variant was **not selected**.

The frame/EXIT softness was a capture-control problem, not yet evidence of a floor regression: the initial before images came from a newly imported worktree before the editor's 3D-texture detection/reimport during the bake. Running the **same square native script read-only against the accepted #160 worktree after its established import** gives high-frequency edge measures at 1600 view 1 equal to the candidate: left gold frame `6.20` versus `6.20`, right silver frame `5.08` versus `5.08`, left painting canvas `4.95` versus `4.95`; EXIT `21.18` versus `21.10`. The initial fresh-cache before values were `9.47`, `6.66`, `7.29`, and `24.37`. The accepted #160 controlled baseline is in `base-native/` for the next blind review. The first packet remains as failed evidence, with its import-state confound disclosed rather than silently replaced.

## Second blind review — fail: comb repetition

The [second native packet](final-native/) and [second browser packet](final-browser/) used the finer Muse `textures/oak.png` (SHA-256 `ea9d9966c0295584c531e5550aab372fee9d53662ffe12fd2553014c9ebaec0e`), with a `0.05`-high strip sampled per modeled plank and a `3×` contrast boost. A fresh independent GPT-6 Astra medium image-only review **failed** the grain/detail gate: the floor tone and non-floor preservation passed, but at 1600 the wood showed repeated comb streaks and rectangular transverse patches; at 720 view 1 the distant herringbone became faint. Inspecting the source image and shader established the mechanism: the source `oak.png` already has dense horizontal fine lines, and narrowing plus amplifying it exposes the same lines on every plank. This candidate was **not selected**. Its final rebake, native and exported-Web evidence are retained.

## Third source-led candidate — fail: double herringbone

The [third native packet](parquet-native/) and [third exported-Web packet](parquet-browser/) use the existing Muse `textures/floor.png`, SHA-256 `e4bda4edcd4c83bed11cc1d38eba9d5a7924aa822a9ce0a710a71a145d49ad1f`. The original generation preflight records the RISD crop as its input and the prompt hash; this trial made **no new paid generation or pixel edit**. The shader sampled that broader herringbone albedo in continuous world space over the existing polygon planks. Godot 4.7.2 bake hashes were `room.tscn` `cd1e6a73836c334a146a19d0cc2ccd6627175637931878338d4855932e40bac7`, `room.exr` `c006c25a548e0360882525846fbe3e75d9278f24e159c766cf51eb2e7c353c47`, and `room.lmbake` `e2039646e2ea815e28c7cfccd08fff83271770b00e09f9d84fe9e8781215c853`; Web capture errors were empty. A new independent GPT-6 Astra medium **image-only** reviewer gave **FAIL**: at 1600, the full texture's zigzags overlap the modeled herringbone into angular double patterns; at 720, the boards are narrow and strongly outlined compared with the softer reference. Paintings, frames, doorway and trim remained placed. This candidate was **not selected**.

## Fourth candidate — fail: boards still too narrow

The [square native](boarduv-native/) and [exported-Web](boarduv-browser/) packet returned to existing source-guided Muse `oak-muse.webp`, sampling an interior strip of one source board with a varied horizontal crop per modeled plank. UV1 became local to each plank (`0–1` in both axes) and vertex-colour alpha carried its crop seed; the bake preserved that alpha while removing only authored occlusion from RGB. It avoided the amplified `oak.png` comb and the `floor.png` structural overlay: only the modeled geometry defined herringbone. The texture mixed at `0.55` with muted tint, source contrast was `1.4×`, and board tone varied `0.96–1.04`. Its bake succeeded: `room.tscn` SHA-256 `2d41afe7f76fe640f6fb53f17843bbac9584c63aae1ebf705ef5752a734ffd12`, `room.exr` `784c9a599a1b98ba32c3b6aa092784d460cce112db8c7221e97ccd7c9a30dfe7`, `room.lmbake` `27a3f06a5b58be6eb8108bd8d4a32a6472bcf792e55a2eba6b721cdaed465365`; Web errors were empty. A fresh independent GPT-6 Astra medium **image-only** review **failed**: 720 zigzag courses were much denser/narrower than the source and read like continuous chevrons; 1600 boards remained too uniform in hue and internal stripe. Artwork, doorway and trim placement stayed intact. This candidate was **not selected**.

## Fifth candidate — broader and muted, still too regular

The [native](broad-muted-native/) and [exported-Web](broad-muted-browser/) packet widened the modeled plank from `0.84×0.18` to `1.35×0.29` game units, a source-relative **visual trial**, not measured RISD floor dimensions. The board UV/crop structure remained, but one interior source-board region was varied slightly; source contrast was `1.1×`, material mix `0.42`, per-board tone `0.95–1.05`, warmth `±0.025`. This reduced the harsh three-strip banding visible in an intermediate self-rejected preview. The floor mesh's edge inclusion pad grew with board dimensions so broad planks still cover the room envelope. Godot 4.7.2 rebake succeeded (`BAKE_OK`): `room.tscn` SHA-256 `3464bcc4bca736df3bd011be5d7f351342eea4aa76c7753ca4f2e6c1bba0fa1a`, `room.exr` `d2d3eb82d8730428fb457ff86a48e3b9bd9eed2cb5bf6d2541dd635143fac1dc`, `room.lmbake` `1cb241c7293b3e9b00c4f69cb9ecc66b6adcfe86052439012914d01299dc1755`; Web errors were empty. Independent GPT-6 Astra medium **image-only** review **failed**: scale and muted palette were plausible, but similarly shaded V bands dominated at both sizes, with wood grain too regular/fine at 1600 compared with the reference's interrupted tones and patchy sheen. Placement and contact remained credible. This candidate was **not selected**.

## Sixth candidate — tonal interruption, source stripe still dominates

The [square native](varied-native/) and [exported-Web](varied-browser/) packet kept the broader modeled geometry and varied individual board tone (`0.92–1.08`), warmth (`±0.035`), and oak-source UV length/crop. A very low-frequency (4×4 mip) sample of existing source-photo-guided Muse `floor.png` contributed only diffuse colour patches, not its herringbone structure. No new image pixels or paid generation. The existing RISD crop remains the reference. Godot 4.7.2 rebake succeeded (`BAKE_OK`) with original floor shadow-casting restored: `room.tscn` SHA-256 `7388ac676a68f7ceda049c4ae2c41f9f5c86f894049a18d9dfcf07628387dfd7`, `room.exr` `eadb002d827dacc3d73e97e73a99930011058d5197bd2cf6e44122ec457ae95f`, `room.lmbake` `a7267d8e337b7cd136a2109e10f9c5b22291643fd92083d702d16d9c9569ced9`; Web errors were empty. Independent GPT-6 Astra medium **image-only** review **failed**: broad proportions and perspective credible, but continuous similarly shaded V bands persisted at 720/1600, with uniformly fine parallel grain. This candidate was **not selected**.

### Band-source isolation

Four matched 720 view-1 diagnostic captures are in [band-diagnostic](band-diagnostic/): constant albedo with baked lightmap (`lightmap-only`), full floor material without baked lighting (`material-only`), board colour only without baked lighting (`boardcolor-only`), and oak/photo texture only without board colour or lighting (`source-only`). The lightmap-only view has no repeating V stripe. The material-only and source-only views reproduce it; board colour alone shows only softer, irregular board shapes. This isolates the dominant repetition to the source oak strip's cross-board luminance gradient reused at the same UV.y on every plank, **not** the saved lightmap. The next candidate subtracts a blurred mip-5 sample of that same source strip from its full-resolution sample: high-frequency authored wood detail remains, while the repeated broad band is removed. Board tone and very-low-frequency photo-derived patches supply broader variation.

## Seventh candidate — source-grain detail without repeated board band

The stable copy of the reviewed seventh packet is [native](seventh-native/) and [exported Web](seventh-browser/). The A–D cheap-preview stills are preserved under [eighth-previews](eighth-previews/); their `/tmp` paths below identify the capture runs, not the only evidence copy.

The high-pass oak sample described above is in a bounded shader trial. No new image pixels, source dimensions, or geometry changes are made. The first native preview (`/tmp/risd-168-floor-highpass-final-native/`) eliminated the repeated V bands but made plank joins nearly invisible at 720, so it was self-rejected before blind review. A second preview restored only a soft antialiased join following each modeled board edge. Its strength was reduced from `0.035` to `0.020` after direct 720/1600 comparison with the soft RISD crop. The join is geometry-derived rather than a reused source-image gradient. Godot 4.7.2 rebake finished `BAKE_OK users=120`; the saved `room.tscn` SHA-256 is `0f8d17eb1eba8b78cf0814d63ea8abc6bc838459ca094ac6016d1d647e3eabdf`, `room.exr` is `e2e00fef6fbd2c68a3ba36c046f4a76a459c0b913ba2fb400863d353eae70fb0`, and `room.lmbake` is `2439decae1b0373681134e1a93ca5bb0e56c02896267600ecb4f87f1f34f8dc8`. Final matched native and exported-Web 720/1600 captures are in `/tmp/risd-168-floor-softjoin-final-native/` and `/tmp/risd-168-floor-softjoin-final-browser/`; the Web capture reports `errors: []`. Fresh independent GPT-6 Astra medium **image-only** review **failed**: at native 720 the floor near the doorway approaches a flat brown plane; browser 720 still shows regular V columns; at 1600 its fine grain and finish are too uniform and lack the source crop's irregular sheen. The reviewer also noted that the accepted control is not itself a faithful target, so its appearance must not be treated as the fidelity gate. This candidate was **not selected**, and the floor is not integrated into `build/v0.1.0`.

The source crop has grayscale mean `0.5254` and standard deviation `0.0480` (ImageMagick Gray); twelve equal-area tiles have means from `0.4658` to `0.5667`. These are photographic tonal bounds, not calibrated albedo or measured wood dimensions. Before another full bake, the next pass will compare small shader-only previews for source-led per-board and within-board irregularity, rather than merely widening random colours.

### Eighth-pass cheap previews — no rebake selected

All three kept the seventh packet's saved lightmap and geometry; these were shader-only previews, so they cannot be treated as a verified final bake. Trial A (`/tmp/risd-168-floor-trial-a-native/`) sampled five different horizontal oak-source rows with a source-derived board-tone term. Its 720 native view showed conspicuous dark transverse streaks where those rows crossed painted source-board bands; self-rejected. Trial B (`/tmp/risd-168-floor-trial-b-native/`) kept one source-row interior and added lengthwise low-frequency deviation relative to each board's center. It remained visibly indistinguishable from the failed seventh packet at 720/1600; self-rejected. Trial C (`/tmp/risd-168-floor-trial-c-native/`, `/tmp/risd-168-floor-trial-c-browser/`) reduced vertex board-tone contribution to 45% and strengthened only the heavily filtered, source-derived spatial patches. The exported 720 view softened the regular V columns but became too flat around the doorway; self-rejected. None of these justify a new expensive bake or blind review. The seventh packet's saved-bake source should remain checkpoint evidence until a materially better construction is previewed.

Trial D (`/tmp/risd-168-floor-trial-d-native/`, `/tmp/risd-168-floor-trial-d-browser/`) narrowed the sampled Muse oak y-range to `0.035` inside one apparent source board and normalized colour against its center. It removed the repeated row-boundary gradient but exposed disproportionately large, recurring oval knots and dark board blocks in the 1600 exported view. It, too, was self-rejected without a rebake. The shader was restored to the seventh saved-bake state after the preview; none of A–D is a selected runtime material.

### Source-resolution and generation limit

The available RISD crop is only `1080×620`, and direct inspection shows the wood streaks/finish are soft and not resolved enough to extract a full set of distinct board-grain patches. The original full phone photo, date, and exact crop coordinates are unverified. In contrast, accepted frame pass `frames2` retained each frame's rectified photographed outline and ornament as an explicit edit input, then used its generated image on 3D nine-slice geometry with baked lighting. The floor's existing Muse oak-grain prompt explicitly asked for **one continuous sheet, no boards, no seams, no knots larger than a fingernail**, but its `2240×1120` result visibly contains many broad board bands and large oval knots. Reusing those repeated bands in the modeled herringbone explains the failed grain trials. The other Muse floor image is `512×512` and already contains its own full herringbone layout; mapping it over separate modeled boards produced the rejected double pattern. These observed source/asset limits, not a missing shader dial, now block a source-faithful grain treatment. A fresh reference or a new explicitly board-level edit pass would be needed; neither is silently inferred or generated in this ticket. #168 stays open and unintegrated.

The checkpoint still passes `scripts/check.sh`, `git diff --check`, the focused native navigation script (`NAV_FAILURES 0`: both room round trips, floor clicks, drag/pan/orbit and all 23 painting targets), and the doorway-floor script (`DOORWAY_FAILURES 0`: eight original/baked, two-resolution views at 9/9 clear samples each). These are functional checks, **not** a visual pass for the floor.

### Ninth source-guided board-atlas trial — failed after bake

One new saved Muse edit pass used the RISD crop as first reference and the
rejected `oak-muse.webp` as second material-family reference. It returned a
four-row long-grain oak atlas at
`image-work/floor-168-board/artifacts/image-generation/runs/run-082b39a8176407a9c5f4c563/materialized/image-01.webp`
(SHA-256 `07ba958b7c4008687578c117c2eef80d2a232f3612da799e3557b24e96d98190`).
OpenRouter `meta/muse-image`, one request, USD 0.01 actual cost recorded in
the run state; `spendState: unknown` and `retryState: never-resubmit` bar a
blind retry. Full prompt, input hashes and
output limitations are in `image-work/floor-168-board/README.md` and the Shell
provenance. This is the first new paid source-guided floor pass under #168;
the prior seven candidates reused existing image pixels.

An independent Astra-medium image-only **atlas preflight** judged its four
plank faces plausible, but noted brighter/yellower colour and pale scratches.
The first native shader-only capture (0.55-wide source crop) was self-rejected:
fine detail disappeared and the room looked flat. A narrower 0.16-wide crop
improved grain legibility and tonal depth at 720/1600. A fresh independent
image-only comparison narrowly preferred that cheap B preview over the failed
seventh packet and allowed a full bake/Web gate, while explicitly observing
recurring V columns and too-even finish. Thus it is **not yet visually
accepted**. Godot 4.7.2 completed the ninth saved lightmap bake (`BAKE_OK
users=120`); saved scene/EXR/lightmap hashes are respectively
`cbe6a0a56fd8fae8075a457aacaf921d548261961f631f04f0419f2c24cb938b`,
`d6939d56611c8122c00e1458adf9314adf908c7d5c4c53faac00e75d6e9f2059`,
and `60c1abc37fbd4c1c010289ad113ea7e3fa27f78d7cb991f58fa1e01dd0659a88`.
The [saved native captures](board-atlas-baked-native/) and [exported-Web
captures](board-atlas-baked-browser/) cover two poses at 720 and 1600 square.
The Web capture reported `errors: []`; `scripts/check.sh` and
`git diff --check` passed. A fresh independent GPT-6 Astra medium image-only
review of the RISD crop and these eight final images gave **FAIL**: repeated V
columns still dominate, grain reads as parallel comb lines, board response is
uniformly matte/printed, and native captures are much softer than Web.
Individual board direction and tone are legible, but the result does not meet
the frame-level visual gate. This atlas and bake are **not selected** or
integrated; the failed trial and paid-run receipt are retained for diagnosis.

### Speck diagnosis, unresolved

Small black floor points at corresponding positions are also present in the accepted #160 baseline. A [flat-albedo before/after diagnostic](speck-diagnostic/) kept the same camera while eliminating oak texture from the shader. The points remained; disabling floor shadow casting in a trial rebake did **not** remove them either. Therefore source oak pixels, UV crop, and floor self-shadow are falsified as sole causes. The no-benefit shadow change was reverted; the later bake retains original shadow behavior. The points remain an unresolved saved-bake/render issue, not a fixed floor-texture claim.

### Tenth source-photo geometry/material trial — failed final visual gate

[Site Specific's Radeke Museum renovation photographs](https://www.sitespecificllc.com/rhode-island-school-of-design-radeke-museum)
show this same Grand Gallery at 2500×1667, including its complete floor.
Reference-only copies are in `image-work/floor-168-board-v2/references/`:
`gallery-2456.webp` SHA-256 `0038d6b413cf9a0489b8f96c1d0fc1c03d7faaa99a27fc1dad0c28195374df44`
and `gallery-2447.webp` SHA-256 `d10407d44ef26a46f98394360741fee4c0a15d19bc3a15861fe9a324f2b4cfab`.
These are source/style evidence, not runtime textures or redistribution grants.
They show lighter, broader parquet courses and a straight-plank perimeter that
the ninth model lacks. A first cheap geometry/material preview widened boards
from `1.35×0.29` to `1.9×0.36` game units and reduced grain/board contrast;
without a matching rebake it still looked dark and flat, so it is **not an
acceptance packet**. Two straight-plank courses now cover each long perimeter
side; exact dimensions remain a visual trial, not survey measurements. One
hash-locked Muse edit for eight distinct board faces completed under
`image-work/floor-168-board-v2/` at actual recorded cost USD 0.01. Its WebP
SHA-256 is `8b568b890e7ffa5a2ef86173b21222b3bc6374d7abea15be5ea1865532524aec`;
a fresh independent image-only review passed it as an input only, with
warm/tile-edge caveats. Godot 4.7.2 rebaked the modeled-floor trial (`BAKE_OK
users=120`). Saved scene/EXR/lightmap SHA-256 values are respectively
`8557aef7c14fa5c604e97293790d85d192bfb3edaa0644903bd738ed8c54d0eb`,
`d93510d6e86b8ef42303dde170dc2af8a19c0f6551707bd023c574cf49dec3fe`,
and `e21954a1723daf9691a67c58d347a495dd66210106e67e6ec69289684affe595`.
The final shader-only grain amount changed after this bake; no geometry or
lightmap did. Matched 720/1600 [native](tenth-native/) and
[exported-Web](tenth-browser/) captures completed with zero browser errors. A
fresh [image-only Astra-medium review](tenth-blind-review.md) of the two gallery
photos and eight final captures **failed**: end joints were too faint, so the
parquet read as continuous chevrons; grain/finish remained too uniform; native
was softer than Web. The pale palette, scale and room continuity were strengths.
The tenth trial is not selected. A no-rebake eleventh shader probe strengthens
only board-end joints and board-level tone. Its matched
[native](eleventh-native/) and [Web](eleventh-browser/) packet reported zero Web
errors, and a fresh [image-only Astra-medium review](eleventh-blind-review.md)
**passed** it as believable source-led herringbone oak at square gameplay
size. Minor reservations: relatively matte finish, fine/straight grain,
scene-wide softer native captures and scattered native dark specks. This
selects the floor *visual candidate*, subject to navigation/repository checks
and integration; it does not pass the wall/skylight groups in #168.
The ninth failure stays frozen at `e48034a9`.
