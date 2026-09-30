# Prototype asset provenance

Generated sample portrait accepted only for this prototype under owner-delegated application review. One OpenRouter Muse output; $0.01 counted once. No final full-booth asset acceptance is implied.

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
- Live captures do not receive this as their generated likeness; the interface explicitly labels it as the pre-generated sample-photo portrait. Runtime generation is a later implementation ticket.
