# Cornice batch checkpoint — 2026-09-28 UTC

This is the isolated `prototype/167-cornice` trial, based on the selected #160 doorway prototype at `ef4d8b76`. No part of this batch is in the build branch. The arch/portal and two benches are unchanged and remain open under #167.

## Source and treatment

The RISD doorway crops show a pale upper molding. The skylight crop confirms the adjacent vault context but does not resolve the corner profile. These are photographic references, not survey dimensions:

| Reference | SHA-256 |
| --- | --- |
| [`door-far-crop.png`](reference/door-far-crop.png) | `f27b73f89da8bb6cda3718f9c6e71c5d4f6ab7fc3ae825fc002c87290f41622c` |
| [`door-arch-crop.png`](reference/door-arch-crop.png) | `6db20b89ef019e278646ae736268f5ff2e77d9a378d71d4c87ea8e7232bcf858` |
| [`skylight-crop.png`](reference/skylight-crop.png) | `1870aa6fc6576a4b3d5f17380106a34c294c2535ecaeba8f950a39b8cccd0091` |

The existing two upper boxes and sloped fascia were replaced by the already proven doorway `_trim_profile` extrusion on all four walls. The section has UV1 in metres and the existing bake adapter unwraps UV2 at 25 mm per texel. The hand-authored [`cornice-ivory.svg`](../../../modules/shell/prototype/gallery_walk4/textures/cornice-ivory.svg) derives from the accepted doorway ivory SVG with paler colors; SHA-256 `35595107453dbded8fa66610d0e6d759e8650c32dc6129c83fffcfbeb0adaa76`. A small material emission is isolated to this new texture in the saved-room bake. Provider: local manual SVG edit; count: one; cost: USD 0. No Muse call.

The latest saved bake hashes are `room.tscn` `9dfd7a4ec946f3a8f82f411d719b22f32339f0dbcb935f92dbd9b55e0026ee1c`, `room.exr` `530d815ebfce06813297d9d0f9ba42419d6b5807f42a7a244b8cead9e37a19cd`, and `room.lmbake` `95b92e91fd77afd3ac4528bfeffec69dd5db9246a6a54c17800cd9621c334f4b`.

## Visual evidence and review

[`before/`](before/) and [`browser-finish/`](browser-finish/) contain matched 720 and 1600 square views of the long wall and both upper corners; [`finish/`](finish/) contains the native Godot views. [`index.html`](index.html) is a side-by-side browser sheet. Three independent GPT-6 Astra medium image-only reviews saw only the reference crops and each candidate's final captures:

1. Initial candidate **FAIL**: high severity, both end-wall corners stopped against flat bands; medium, tan trim with strong dark stripes.
2. Continuous-profile repair **FAIL**: corners aligned and readable at 720, but the brown finish and wide dark bands still failed reference fidelity.
3. Pale SVG plus small emission **FAIL**: all six views remain too brown and too close to the ceiling color; long-wall views read as alternating flat stripes rather than softer molded plaster. Corner continuity and 720 readability pass. This is the current, unselected trial.

## Checks and next gate

The last complete run before the final material trial passed `scripts/check.sh`, `git diff --check`, and the gallery navigation check (`NAV_FAILURES 0`, 23 paintings). Each saved-room bake printed `BAKE_OK`; the editor also printed its existing teardown errors, so the exported Web comparison was checked independently. The final exported Web trial produced six square captures at 720/1600 with zero page errors (the only 404 in an earlier run was an unneeded favicon). Technical checks do not establish visual acceptance. Keep #167 open. Next falsifiable repair: raise the cornice-only material's pale diffuse contribution enough to separate broad faces from the ceiling, and round or bevel the dominant projecting edge to narrow the dark bands. Recapture these exact views and seek a fresh blind review before selecting or integrating it. The arch and benches remain separate batches with their own sources and reviews.
