# Square gallery display trial — #161

Source: `build/v0.1.0` at `1dc02507`. The throwaway harness is [`modules/shell/playtest/display_161/capture.gd`](../../../modules/shell/playtest/display_161/capture.gd). It mounted the actual 1080×1080 Square Stage, selected Collection, held one gallery pose, and captured three modes at the same 1080×972 Tenant size. All 23 painting records remained. Native Godot 4.7.2 Compatibility ran on Mesa llvmpipe; these captures do not establish exported-browser output or performance.

## Sealed blind still review

Only [`evidence/A.png`](evidence/A.png), [`B.png`](evidence/B.png), [`C.png`](evidence/C.png), the [Animal Crossing reference](evidence/reference-ac.png), and the [gallery floor reference](evidence/reference-gallery-floor.png) went to an independent GPT-6 Astra reviewer at medium effort. No code, mode key, prior verdict, or implementation narrative was supplied. The reviewer reported before the key was opened:

> B is the strongest passing variant for a modest improvement: A has fine diagonal striping across the parquet, B reduces that distracting texture while retaining readable herringbone, painting edges, white trim and character features, whereas C softens the floor but also visibly blurs painting detail, trim edges and the face; all three remain darker and more uniformly brown than the bright AC reference and more repetitive and contrasty than the subdued gallery-floor reference. This is a preliminary still-only pass for B, with motion stability, shimmer and temporal blur unassessed and requiring moving-image review.

After that verdict, the key was opened: A = current RGB6 raster dither with 0.5 copy filter; B = diagnostic bypass; C = RGB6 raster dither with full copy filter. The still result favors bypass narrowly, but it does **not** select a runtime finish. Existing #140 matched-motion review found no two-scene winner between its tested modes, and this new square-stage bypass has no motion or browser comparison yet. The old red-cap gallery character in these captures also predates the selected #159 New Horizons visitor prototype.

## Checks and next test

The capture command passed and printed `PASS: matched square display modes; 23 paintings=23`. `scripts/check.sh` and `git diff --check` passed after moving the harness inside Shell. The first attempt in a fresh worktree failed because Godot assets had not been imported; `godot --headless --editor --path . --import` resolved that setup issue. No runtime files or frozen interface, errors, or acceptance tests changed.

Next, replay the same entrance, walking, turn, artwork, and white-room paths for **bypass versus current** at 1080 square in native and exported Web, with identical camera/actor state and a real #159 visitor. A fresh image/video-only Astra-medium reviewer must check motion shimmer, artwork and trim edges, whites, and temporal blur. Retain bypass only if it improves at least two scenes without a new visible motion defect or >10% frame-time regression; otherwise keep the current default. #167 architecture and #168 surface failures remain independent World Asset Gate blockers.

SHA-256 of blind files:

| File | SHA-256 |
| --- | --- |
| A.png | `be608e90dcdc6cffac5d04dbeba114e3d71417e88ca23ad44783c32fcf3f8d0b` |
| B.png | `3f6771001c9d887e3f2fe0a7a676157ba176f73b78e64dc604d3e72de7cbe628` |
| C.png | `bfb2dcbcb859c892e9fdc74034ddf78584ba0f06ecaf4c90c4b5bda6f7c6ad45` |
| reference-ac.png | `e93bd4b3ccb60f4bb6c7fc7331286dff27337be13a173d2a9164a49708ca3a6f` |
| reference-gallery-floor.png | `d7636e7c478a7d423cf0fede9544cac9c5b40544babee1c088de983a57672b12` |

Spend: USD 0.
