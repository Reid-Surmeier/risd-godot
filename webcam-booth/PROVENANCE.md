# Booth asset provenance

Generated assets are accepted for the isolated booth under owner-delegated application review. Native tool states are preserved independently of application acceptance. Actual charges and reservations are recorded separately.

The four PNGs are Figma MCP visual exports, reduced by the MCP service from uploaded board nodes. Original-source download URLs returned empty bodies; those bodies were discarded. They are review/fixture art, not certified final artwork. Node mapping: camera-frame=1:4, photo-fixture=1:399, portrait-fixture=1:5, glove-frame-reference=1:398. Source: https://www.figma.com/board/T3TSj0MQ2a26sdSLDB6l7A/Untitled?node-id=1-623. The portrait fixture still contains the reference character/hand; the glove/frame image still contains its original painting and background. No identity preservation or transparent frame is claimed.

`loading.gdshader` is copied byte-for-byte from RISD `modules/video_player/loading.gdshader` at commit 55e7c3b7f048a5a7a27b71fc962c040e7aa5893e. It is independent source in this prototype, with no import from the RISD application. Provider: existing project source, cost $0.

| Asset | SHA-256 |
| --- | --- |
| glove-frame-reference.png | `c7f00e420806f12f679c3cd5e5b2afb8353577b4296c8c321c94b97b1c313af8` |
| portrait-fixture.png | `35d354cc27f11c9cc1b6f6d6a40c45b00eb12168320e5d7873d1603d98e955f9` |
| camera-frame.png | `41501d6814a33e44be6e07503273a75e1c0a0f6312fa3bf1bd7e34219cc82a06` |
| photo-fixture.png | `1265c94186f7b11d019060b819ad486d9ae2a8fc909acd0b70226fd5532fc395` |
| loading.gdshader | `872e26851dbad2f27776b001732cd3be4613818791aa7821e09efb18ed15858f` |

## Muse sample-photo pilot

- Provider/model/count: OpenRouter / meta/muse-image / 1. Exact ordered references are photo-fixture.png (identity) then portrait-fixture.png (style). Prompt, recipe, reference hashes and immutable Objective live in image-work/ and .qwen-pipeline/.
- Run: run-c7bee15e9bbcf76387025838. Materialized native image: WebP, 1600×1600, SHA-256 `3001131179a4d8b5270024864ab79ef5aab75b7831f267d728a88423204d11b7`. Requested size was 1024×1024; actual dimensions are provider output.
- Receipt actualCostUsd=0.010000, costState=actual; retained tool spendState=unknown and retryState=never-resubmit. These describe one pilot, counted once as $0.01 against the $10 ceiling. Receipt and Run remain under artifacts/image-generation/runs/. No receipt is edited and no retry is permitted.
- Review: independent gpt-6.1-sol/high visually compared both exact references and the exact output hash; accepted recognizable supplied adult, red shirt, neck/shoulders, polygon facets, blue gradient and spiral sun, with the Wario character/hand/text excluded. Stylized facial proportions and clipped sun rays are recorded limitations. humanReviewed=false; this is owner-delegated application-level prototype acceptance. Tool human-review flags remain unchanged.
- Live captures do not receive this as their generated likeness; the interface explicitly labels it as the pre-generated sample-photo portrait. Live captures use their own generated portrait through the server adapter.

## Live-generation proof

Initial paid browser proof traversed the actual camera capture bridge with Chromium synthetic hardware. A final source audit found that the injected fixture dimensions differed from the existing ImageTexture, so this historical check establishes the live route, not fixture likeness. The final pixel-verified source proof below supersedes that claim. Run `run-a1d8f3344390bd9375b41e65`, OpenRouter `meta/muse-image`, one image, actual receipt $0.010000; diagnostic spendState unknown is the same counted liability. Captured PNG hash d22a370ce2829ffbbd9b51ce52019b522443a5843acf9b40a61a27edcc2ff339; output hash c0f322b05da2bc8da92f03db1f969ac5874b6693b8ced3cb6011db20ba7397c7. Runtime request/result bytes were deleted after delivery; only hashes/run/cost are retained in the private receipt. Provider retention is not controlled by this deletion. Evidence: review/evidence/paid-loop.json and 09/10 screenshots.

## Reference frame and fuse anchors

OpenRouter Muse generated one frame donor (`run-5910233e53d2706dc83b67d2`, actual $0.01, donor SHA256 9124408c885ecfbe90066b54ca9aa01a32442d956c583c730697e5665bcb4009) from the board glove/frame reference. Four faceted white gloves, ornate gold frame, no source painting. `image-work/key-frame.py` mechanically removes the green matte; actual PNG alpha and empty center are asserted. Native alpha was not claimed. Source prompt/recipe/plan and donor are retained in image-work; runtime uses only assets/glove-frame.png, SHA256 ef7d6135dcde264daf41beca7e56f24a5f3ef4892ddd4979006360f4a6737544.

A second $0.01 Muse anchor (`run-ffd94d1e215418ca04e46b1a`, donor SHA256 e89a5e33225c0f3d8d7001ad06fbaf2bbbdccfe5031fde1943bde19f37be5499) adapts the inspected lavender Wario-head fuse. Original gameplay URL/timing and historical limits are in motion research. Opening still and plain-green end anchor are mechanically normalized to1280×720 for a single Seedance2.5 eleven-second request: ten seconds fuse, then burst/clear. Motion Run run-16c6dd84b5c249fa0282d930 has a known $2.55195 receipt; do not resubmit.

All application visual acceptance is owner-delegated, humanReviewed=false. Generated art is not evidence of an original game animation.

## Accepted motion assembly

Seedance2.5 returned silent1280×720, 11.041667seconds (one extra frame), actual $2.55195. Native Run remains **failed / VIDEO_MEDIA_INVALID**, unchanged. Independent ffprobe/pixel inspection found the first upper-canvas burst at9.333333seconds. `motion-work/assemble.py` deterministically retimes fuse→10seconds and burst/clear→1second, trims and transcodes to1024×576 Theora for Godot. Separate application acceptance passes: 264 decoded display frames, 11.000seconds, first upper-canvas burst10.000seconds, full opaque cover10.5seconds, green-keyed finalframe. Theora omits repeated coded packets (258), so displayed CFR frames—not codec packet count—are the temporal test surface. Independent reviewer reproduced these facts. Runtime hash 5b7a3ae46cea341001e02b31ba941835be267fc3ce69cf7e411c48930dc50940; viewed exported03portrait,04explosion and05reset. No paid retry occurred. Ledger conservatively counts256cents for this2.55195receipt, plus four1centimages:260cents reserved/received, $2.59195 actual.

## On-device tracking pin

MediaPipe tasks-vision1.0.1 and FaceLandmarker float16/v1 are served locally; tracking/pins.json records exact archive/asset hashes. Source reference is git-subtree-squashed under repos/mediapipe at tasks-vision@1.0.1. Because publisher metadata exposes no gitHead or upstream release ref, this is an exact npm-archive snapshot including its shipped source-map content, not a guessed upstream checkout. Never import repos/mediapipe. Native worker checks detect478points/52blendshapes and portrait anchors, then photo→no-face→recovery. Live adapter uses the existing video stream at10Hz with one pending inference. Shader deformation is bounded2D; before/after screenshots use explicitly simulated blendshapes, while actual worker inference is separately asserted. No physical camera/3D reconstruction is claimed.

## Final source-verified capture proof

Run run-12716948540ebcf3a56007a4, one Muse image through OpenRouter, actual $0.010000. The test decodes the outgoing capture PNG and compares every RGB pixel with the injected320×240 source before allowing dispatch. Exported20-final-portrait shows the supplied bald adult/red shirt, facets, neck/shoulders, blue gradient and spiral sun;19loading and21reset complete the real10second loop. Temporary capture/output/provider-response payloads are removed; hash/cost records remain. Earlier final-loop timing failure and two non-pixel-verified synthetic proofs remain labelled historical evidence, each counted once. No physical webcam was used.

Current cumulative actual spend: $2.62195, seven one-cent Muse images plus one $2.55195 Seedance motion. Conservative rounded ledger: 263cents of1000. Unknown additional liability: $0. Recorded snapshot: review/SPEND.json.

## Public timeout validation — 2026-09-30, Issue214

Review evidence22-public-timeout-fixed.png/json: one deliberate OpenRouter meta/muse-image portrait using the declared assets/photo-fixture.png through the real browser capture bridge, input pixel equality checked before submission. Runrun-ded2660c3e9d6b9d319f33af. One image,$0.01reservation, actual spend unknown; inputSHA256c93d04f8758ac2004b33b9e55d0fc079c057948a058972602788dab19917a5b6, outputSHA256670973ea5e0995acc40faabf269b1232c2af14c32e9361738ab03d14ba2f7bfb. Public capture took55.742seconds; portrait/explosion/reset passed. Review screenshot is evidence only, not a runtime dependency or owner webcam recording. Native receipt/hash/cost records remain; image payloads deleted.
