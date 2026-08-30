# Kid Pix / tldraw prototype evidence

Date: 2026-08-30

Issue: [#16](https://github.com/Reid-Surmeier/risd-godot/issues/16)

Default: variant C, RISD hybrid Sketchbook

## Human-visible artifacts

| Artifact | SHA-256 |
| --- | --- |
| `screenshots/variant-A.png` | `a506a1fb898c6349b8a4ea5da27e74aea2abb73201073b0035b78d3ba6110bd4` |
| `screenshots/variant-B.png` | `858694045e120e80dec6ba029012745ac93d8378796f281cd9f4dc6e883e72b4` |
| `screenshots/variant-C.png` | `1aba5fc79e2cdd32140adf85be05fe708d82189a9a37c0a6253a1abe19f9b9a9` |
| `screenshots/variant-C-drawn.png` | `d91fbf43eaa43fdd137a107018b1726eb74f02ce8842b5a8b3d101c8d4295ea6` |

The screenshots are deterministic review evidence captured by the Chromium tests at a `1440 × 1000` viewport. Human visual and interaction approval remains open.

## Verification

- `npm run prototype:kidpix:check` — passed.
- `npm run prototype:kidpix:build` — passed; Vite transformed 817 modules and emitted the prototype bundle. The expected throwaway-prototype chunk-size warning remains.
- `npm run prototype:kidpix:test` — 10/10 passed in Chromium. This includes real mouse and synthesized touch strokes, cursor input transparency and hotspot position, tldraw Draw-shape commit, functional erasing, undo, clear, color, thickness, window drag, variant routing, and reset on reload.
- `./scripts/check.sh` — passed.
- `git diff --check` — passed.

## Generation and provenance

No new paid or model-backed request was made for this prototype. The pointer artwork is an alpha-only prototype extraction of an existing Qwen v003 result. Its source identity, derivation, source hash, and output hash are recorded in `prototypes/kidpix-tldraw/public/pencil-prototype.provenance.json`.

The pointer is interaction evidence only. It is not a production RISD Icon, and this tldraw browser prototype is not authorized for production embedding.
