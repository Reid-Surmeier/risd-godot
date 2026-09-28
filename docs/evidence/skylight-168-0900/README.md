# #168 skylight UV trial — 2026-09-28 05:15 EDT

Isolated prototype branch `heartbeat/skylight-168-0900`, based on the prior surface trial `f0099b60`. This is a rejected candidate, not a World Asset Gate pass or a build asset.

## Source and capture

- [RISD gallery photograph](reference.png), already tracked in the previous surface evidence; SHA-256 `1da5c5c42afc0f7dd64fbf649001b29777f2114da08b6fe15ecefd4d9bd5c256`. Comparison evidence only; it does not grant redistribution rights.
- Existing 256×256 Muse-derived `textures/skylight.png` from [Grand Gallery v4](../../../image-work/grand-gallery-v4/README.md) and [the earlier skylight decision](https://github.com/Reid-Surmeier/risd-godot/issues/121); SHA-256 `5de8accfe1a91a4e4e6b3951329579076ae43479227b2959375a4d7ea431c86c`. No new generation or paid request.
- [Before](before-native-720.png) is the preceding 720-square native gallery capture. [Final](final-native-720.png) is the trial's 720-square native SubViewport capture from `skylight_trial_shot.gd`; source and final hashes are recorded by `sha256sum` in this branch.

The first UV trial widened panes too far (`2.5` across the arch, `7.0` along the gallery). A blind GPT-6 Astra medium image-only review failed it: elongated large panes, milky white glass with cyan edges, heavy frames, segmented vault, and the same blurred dark end patch. Its capture was 700×469, so it was rejected before use as a square gameplay comparison.

The second trial uses `1.5` across the arch and `4.0` along the room, with a cooler glass tint; it was rebaked and captured square. A separate blind GPT-6 Astra medium reviewer saw only the reference and this final capture and returned **FAIL**:

1. Near panes remain tall narrow rectangles; thick transverse divisions interrupt the grid.
2. Glass has whitish centers and cyan edges, while the reference is more evenly blue.
3. Strong gradients and dark borders resemble glowing panels rather than soft daylight.
4. The semicircular end and triangular central shading are more pronounced than the reference.
5. A broad white strip and blurry black/white patch remain below the glazing, breaking the continuous plaster termination.

## Next falsifiable repair

Inspect the far-end cap, lunette, and their baked normals/lightmap in a close native diagnostic, then remove the dark patch at the same gameplay camera. Only after that, test near-square pane spacing and a flatter blue glazing material against both native and exported Web captures. Keep the candidate out of `build/v0.1.0` until separate blind review passes and provenance is complete.

## Technical checks

Godot 4.7.2 rebake printed `BAKE_PREPARE surfaces=121 result=0` and `BAKE_OK users=120`. `scripts/check.sh`, `scripts/check-gallery.sh`, and `git diff --check` passed; gallery probes reported zero final-render, rig, sole, doorway, navigation, and dollhouse failures. These checks do not establish visual acceptance.

The first Web export used this prototype branch's doorway main scene while exporting only the loader resources, so it failed to load that scene; it was rejected. Re-exporting with `boot_loader.tscn` as the temporary main scene mounted the game pack and reached `launch-settled`, but the 1080-square browser capture still showed the loading dots and did not reach a visible gallery. No exported-Web skylight comparison or Web visual pass is claimed. The branch's original `project.godot` was restored after export.
