# #168 wall and skylight/vault checkpoint — 2026-09-28 04:17 EDT

Throwaway branch `heartbeat/surface-168-0800`, based on accepted floor prototype `af3eb976`; no build integration. Both groups were captured at matched 720 and 1600 square native and exported-Web gameplay cameras. The reference photos are [whole gallery](reference/wide-north-entry.png) (SHA-256 `1da5c5c42afc0f7dd64fbf649001b29777f2114da08b6fe15ecefd4d9bd5c256`) and [west wall frames](reference/wall-west-arch-to-door.png) (SHA-256 `752df0299008d167f6b5f669a83feb8322dd029a108d8df997ba8c68c7e48823`), already tracked under `image-work/grand-gallery-v2/`. These are comparison evidence only, not runtime textures or a rights grant.

## Baseline

[Native](baseline-native/) and [Web](baseline-web/) show wall view 2 and skylight/vault view 3. Web errors: `[]`. A fresh GPT-6 Astra medium reviewer saw only those images and the references, and **failed both**: the wall was dark green/charcoal with obvious cloudy mottling rather than smooth slate blue; the skylight grid was much denser than the photographed broad panes, with a blurred black-and-white patch at the far end and native grid interference. Native was softer than Web.

## Wall trials

The first trial replaced the cloudy `wall-muse.webp` sample with the repository's existing `wall.png` and rebaked. Native inspection self-rejected the result as smooth but still charcoal-dark; it was not submitted as a passing candidate.

The second trial tinted that same texture by `(1.8, 2.0, 2.2)` and rebaked. Matched native/Web 720 and 1600 captures had no Web errors. A new image-only Astra medium reviewer **failed** it: lighter and greener than the reference slate, with conspicuous pale green light pools. Artwork silhouette and lower trim remained intact; native remained softer than Web. This tint is rejected.

The final trial tints existing `wall.png` by `(1.35, 1.45, 1.65)` and rebakes the saved room. [Native](final-native/) and [Web](final-web/) captures at both square sizes have Web errors `[]`. A fresh image-only Astra medium reviewer **passed the blue wall treatment**: muted slate blue matte finish, no visible tiling/seams, soft warm pools, continuous trim, retained artwork, and matching native/Web wall color/layout. Native artwork/frame detail remains softer at 1600. The reviewer did not pass the skylight/vault.

`wall.png` SHA-256 is `1d5442054d96e092675f41929cf1245a247ec677e13f23b7eccd42f0f22f0a60`; it predates this trial (introduced by `5b58d527`), and its original provider/source metadata is not established. The wall visual decision is selected **for further source/provenance reconciliation**, not yet an accepted World Asset Gate or build asset. No generation calls or spend occurred in this tick. The saved bake scene, EXR and lightmap hashes are recorded below.

## Next falsifiable repair

1. Trace `wall.png` to an original recorded provider/source or reconstruct the same restrained material from the tracked gallery photo crop with full provenance. Until then, keep the passed visual candidate isolated.
2. For the skylight/vault, reduce the modeled glazing grid frequency toward the photographed broad panes and identify the black-and-white far-end patch in the baked scene/lightmap. Rebake, rerun matched native/Web captures and separate blind review. This group currently **fails**.
3. Fold only fully gated surfaces into `build/v0.1.0` after the active architecture branch settles. Keep #168 open.

## Checks

- Godot 4.7.2 `BAKE_OK users=120` for the final wall trial; saved room scene `1cef5148a10d2785568c77493357ae46850e00a80eee80daea156a29e764ff98`, EXR `3d82912b70eae7a93c0d74c6af339447d2240b3b9deb6dce3727dd6fdd5812cf`, lightmap `56f915d75757f59a54f326c8e6348fedc8d0bfb3d1250142583045a139b45266`.
- `scripts/check.sh`, `scripts/check-gallery.sh`, and `git diff --check` passed on the trial branch. The gallery playtest reported `FINAL_RENDER_GPU_FAILURES 0`, `RIG_FAILURES 0`, `RIG_RENDER_FAILURES 0`, `SOLE_VISIBILITY_FAILURES 0`, `DOORWAY_FAILURES 0`, `NAV_FAILURES 0`, and `DOLLHOUSE_FAILURES 0`. These technical checks do not accept the skylight/vault visually.
