# Passage-floor shared-edge repair — #177

Two interior passage pixels changed from dark to magenta with only the background color changed. The saved Surface010 had989 unmatched interior triangle edges. Canonicalized shared endpoints and edge subdivision reduce that to0; background-only Web pairs report0 interior background pixels at720/1600 (red2 at720 before). Only four serialized passage mesh data lines change; all other scene bytes, textures/materials and saved EXR/LMBake hashes match.

`walk4.gd` uses the local passage helper for source geometry; repair.gd applies it to the saved mesh with interpolated UV/color/UV2, preserving lightmap/materials. The main gallery helper remains unchanged. No generation, bake, provider call or spend.

Reproduce: materialize `git show 477b34b5:modules/shell/prototype/gallery_walk4/baked/room.tscn` at `/tmp/risd-passage-177-current/source-room.tscn`; run repair.gd with Godot. edges.gd checks the current scene or accepts a source-scene path after `--`; old returns1/new0. pixels.py accepts normal/magenta PNGs; old2 returns1/new0 returns0. export.py temporarily sets only the private main scene/preset and restores original config bytes in finally. capture.cjs accepts the isolated URL/output directory; native.gd exports720/1600 views.

First fixture omitted its new script, causing a readiness timeout; missing-script.log identifies the actual packaging error. Explicit script inclusion/editor import repairs the fixture. First geometry attempt left9 overlapping edge records due nearly coincident clipped corners; first-repair-rejected.log is retained. Canonicalization removes them. These failed attempts were not visual passes or startup-performance measurements.

Baseline passes with13 known exit warnings. Mainfloor edge, owner source/camera/cushion and world supports/vents/23caption checks pass. Independent focused source review finds no breach/correctness/simplification issue. Fresh native/Web image-only review provisionally passes visible floor integrity/contact and broad warm style; strict renderer parity and seamless plank/material transition are flagged. Final square full-app capture, changed-group disposition, private export and PR166 update still pending.177/162/map149 and final owner acceptance stay open.


## Exact complete-build follow-through

Runtime6b41f770 exported and copied to durable build/review-6b41f770. HTML/boot/game/wasm gzip HTTPS hashes match export-integrity.json. Fullapp seven-tab/four-live-main-hover-scan/Playground/six-distinct-gallery/five-fit captures pass errors[]. All18 actual browser window/grip checks plus centered Collection/X/Escape/fullscreen/tab return, drawing, movement/release/Hair36/all23paintings/F8/F9 pass.

https://windows-wsl.taile06c45.ts.net/risd-passage-current-01a0f078/

Fresh independent Astra medium changed-group square review passes visible floor repair/style preservation; strict native/Web contrast parity fails as an existing appearance difference, and stills cannot clear temporal/unseen geometry. Complete blind disposition is in blind-review.md. This clears the bounded reproduced passage-gap finding; it does not close177's final owner gate,162 or149. No issue/release/owner acceptance inferred.
