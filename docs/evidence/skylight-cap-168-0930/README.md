# Gallery skylight cap trial — 2026-09-28

Issue: [Close the gallery surface World Asset Gate](https://github.com/Reid-Surmeier/risd-godot/issues/168). Isolated prototype; no candidate here is integrated in `build/v0.1.0`.

The tracked [RISD reference](reference.png) is comparison evidence only. The existing skylight texture is the recorded Grand Gallery Muse asset, SHA-256 `5de8accfe1a91a4e4e6b3951329579076ae43479227b2959375a4d7ea431c86c`; no new generation or paid request occurred.

The [before capture](before-native-720.png) showed a disconnected black/white patch where glazing meets the far plaster. The first [cap-winding repair](after-native-720.png) rebaked the room and replaced that patch with continuous plaster. Independent GPT-6 Astra, medium effort, image-only review: **PASS for far-end termination**, **FAIL for the full skylight/vault** because of heavy dark side strips and a sharp triangular light wedge, which the reference lacks. The reviewer was given only the reference, before, and final images.

A second [lighting trial](shadowless-native-720.png) disabled the offline directional shadow. A separate independent GPT-6 Astra, medium effort, image-only review **FAILed** the full group: two dark lobes and a bright triangle remained, the far rim read as a pale slab, and the glazing/rails were too harsh. The trial was reverted.

The third trial separates both plaster end caps from the main vault mesh for independent lightmap UV unwrapping, while retaining the corrected far cap winding. Its outcome and final checks are recorded below.

The [third capture](separate-cap-native-720.png) changed 8,409 pixels versus the first repair, but an independent GPT-6 Astra medium image-only review again **FAILed** the full group: a broad flat white band, triangular light patch and rounded shadows on the end vault, and heavy dark glazing ribs with bright white centers. Splitting the cap lightmap UVs therefore did not remove the visual failure.

Next falsifiable repair: capture separate cap lightmaps with each bake light class isolated to identify the light or occluder responsible for the fan-shaped patch, then remove that cause and compare the same camera in native and exported Web. Tune the grid only after the cap reads as a smooth recessed plaster end. The existing blue-wall source gate also remains open, so no surface is folded into the build.

Rebake: Godot 4.7.2 `BAKE_PREPARE surfaces=121 result=0`, `BAKE_OK users=120`. The editor also emitted `Condition "p_I->data != this" is true` and an exit-time absolute-node-path error after BAKE_OK; the rendered capture was inspected and the command exited zero. Native 720-square capture ran without reported errors. No Web visual proof was obtained this tick. No paid request; USD 0.

`scripts/check.sh`, `scripts/check-gallery.sh`, and `git diff --check` passed on this isolated third candidate. The gallery check reported zero failures in its final-render, rig, sole, doorway, navigation and dollhouse probes, including 23/23 artworks. Its technical result cannot override the blind visual FAIL. The source photograph is held as tracked comparison evidence and is not a redistribution-rights finding.

Current bake hashes: `room.exr` `2c63c2935d0d142abd727801b421eebd87e72ac060bc9c2c5465243ab255af13`; `room.lmbake` `777aff47ba948d49886d49cd368c0b6254e1975440281ab8a1a74255d5a0f3f5`; `room.tscn` `b9a57ff5828942b84cc53fde98acc8d7b031612a58516b14766dd7f7ea588fcd`.
