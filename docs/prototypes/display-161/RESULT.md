# Square gallery display trial — #161

Source: `build/v0.1.0` at `1dc02507`. The throwaway harness is [`modules/shell/playtest/display_161/capture.gd`](../../../modules/shell/playtest/display_161/capture.gd). It mounted the actual 1080×1080 Square Stage, selected Collection, held one gallery pose, and captured three modes at the same 1080×972 Tenant size. All 23 painting records remained. Native Godot 4.7.2 Compatibility ran on Mesa llvmpipe; these captures do not establish exported-browser output or performance.

## Sealed blind still review

Only [`evidence/A.png`](evidence/A.png), [`B.png`](evidence/B.png), [`C.png`](evidence/C.png), the [Animal Crossing reference](evidence/reference-ac.png), and the [gallery floor reference](evidence/reference-gallery-floor.png) went to an independent GPT-6 Astra reviewer at medium effort. No code, mode key, prior verdict, or implementation narrative was supplied. The reviewer reported before the key was opened:

> B is the strongest passing variant for a modest improvement: A has fine diagonal striping across the parquet, B reduces that distracting texture while retaining readable herringbone, painting edges, white trim and character features, whereas C softens the floor but also visibly blurs painting detail, trim edges and the face; all three remain darker and more uniformly brown than the bright AC reference and more repetitive and contrasty than the subdued gallery-floor reference. This is a preliminary still-only pass for B, with motion stability, shimmer and temporal blur unassessed and requiring moving-image review.

After that verdict, the key was opened: A = current RGB6 raster dither with 0.5 copy filter; B = diagnostic bypass; C = RGB6 raster dither with full copy filter. The still result favors bypass narrowly, but it does **not** select a runtime finish. Existing #140 matched-motion review found no two-scene winner between its tested modes. The old red-cap gallery character in these captures also predates the selected #159 New Horizons visitor prototype.

## Native moving control — 2026-09-28

[`motion.gd`](../../../modules/shell/playtest/display_161/motion.gd) replays the same 60 fixed simulation steps at 30 fps in the actual 1080-square Shell for two anonymous modes. It resets the gallery position, heading, path, velocity and animation phase before each replay, then walks and turns the existing visitor. Both modes retain 23 paintings and the 1080×972 Tenant area. Each produces a 1080×1080, two-second [clip and contact sheet](evidence/motion/index.html). This is one warm-gallery path on native Godot 4.7.2 Compatibility/Mesa llvmpipe, with the **older red-cap visitor**, not the selected #159 source character.

Two independent GPT-6 Astra medium-effort reviewers received only the two reference images, anonymous A/B clips, sheets and frames. The first found **neither earns a clear motion-quality pass**: A has more floor grain but streaks during the wall turn; B sharpens painting and bench silhouettes but makes the parquet flat and segmented; both retain rough gold-frame/trim edges. The final capture adds an exact position/yaw parity assertion and resets the rig clock. A fresh second blind reviewer provisionally preferred A's more cohesive floor and softer painting edges; B's alternating plank pattern and jagged gold edges were more conspicuous. Both preserve readable character and whites, but the reviewer noticed a character-pose mismatch in frames 010–011 despite matching controller position/yaw. Neither reviewer could watch continuous playback, so full-speed flicker and temporal stability remain unverified. Only after each verdict was the key disclosed: **A = current**, **B = bypass**. No runtime finish is selected, and the existing current default stays in place.

Native instrumented frame intervals have medians of 97.76 ms (A) and 99.04 ms (B) on llvmpipe. They are diagnostic only: software rendering with PNG capture between frames cannot establish the 10% browser frame-time gate. The selected visitor and #167/#168 world assets remain open.

The final native clips have SHA-256 `daf24eef9874bd79a8260c40ef0028957d3db5056172923c63700fb0a7a3a854` (A) and `d6c45c905d5a81584220cdd9bbfd7875e48cb6aefb9c3daa1ef40dfa39f75b6c` (B).

## Square exported-Web control — 2026-09-28

The existing browser replay adapter ran at **1080×1080** on an identified RTX 4070 SUPER / D3D12 WebGL renderer, in warm-gallery and white-room scenes. Its high-gradient material preflight changed 327,056 visible pixels. Each of four replays completed 479 sampled ticks; across paired modes, position, camera transform/yaw, space, 672×449 gallery viewport, visitor identity, phase, idle clock, yaw and bone-pose hash differed at **zero** sampled ticks. This is a stronger matched-pose control than the native clips, but it still uses the older red-cap visitor. The exported page produced one 404 and the known GLES3 2D-MSAA warning; no clean-console claim is made.

A fresh independent GPT-6 Astra medium-effort reviewer received only the two reference images and anonymous [Web stills, clips and contact sheets](evidence/web/index.html). Exact findings: neither variant improves both scenes without a visible tradeoff. In the warm gallery, B slightly smooths painting-frame and doorway edges while softening floor grain and painting detail; both floors remain repetitive and flatter than the reference. In the white room, B slightly smooths the character outline but adds faint vertical banding to flat whites, with bright door trim in both. Faces, shirt stripes and feet remain distinguishable. The reviewer decoded frames but could not watch continuous playback; no sampled double silhouettes or long trails appeared, while shimmer and temporal stability remain unresolved. **Web key, opened after review: A = bypass; B = current** (independent of the native packet's labels). Neither mode passes a new visual gate.

The first instrumented warm replay showed browser-frame medians of 33.3 ms bypass and 16.7 ms current; a repeat produced **33.3 ms for both**, so the apparent >10% difference is not stable evidence of a mode regression. The white-room medians were 16.7 ms for both. [Raw-summary metrics](evidence/web/summary.json) include post-draw medians/p95, GPU and pose parity. Screencast/telemetry overhead prevents a production performance claim. The current default remains. Next falsifiable repair: integrate the selected #159 source visitor into a square trial, replay warm/artwork/white paths with full-speed blind motion inspection, and measure uninstrumented browser frame times. Bypass must improve at least two scenes without a new visible defect or >10% regression to be selected; current is the fallback.

Web clip SHA-256: A warm `84556fee3d960207d2273139e33935dc72fe8457c7bbdd4bb83fdfea97eed1ce`; A white `5bac8531f9aa1b104ea3ebb9299cdfc20bd109b97bd6830cbfc0cfce19b0202a`; B warm `73c261975050414b67f6ef1dc0c15315d81be7f604ea0851f8f6fbc2d7ad1989`; B white `ef050c5e5a42f053dc7697930c16f25b4f46ed07d802e254380799486e5c4ec9`. Spend: USD 0.

## Earlier still-capture checks

The capture command passed and printed `PASS: matched square display modes; 23 paintings=23`. `scripts/check.sh` and `git diff --check` passed after moving the harness inside Shell. The first attempt in a fresh worktree failed because Godot assets had not been imported; `godot --headless --editor --path . --import` resolved that setup issue. No runtime files or frozen interface, errors, or acceptance tests changed.

SHA-256 of blind files:

| File | SHA-256 |
| --- | --- |
| A.png | `be608e90dcdc6cffac5d04dbeba114e3d71417e88ca23ad44783c32fcf3f8d0b` |
| B.png | `3f6771001c9d887e3f2fe0a7a676157ba176f73b78e64dc604d3e72de7cbe628` |
| C.png | `bfb2dcbcb859c892e9fdc74034ddf78584ba0f06ecaf4c90c4b5bda6f7c6ad45` |
| reference-ac.png | `e93bd4b3ccb60f4bb6c7fc7331286dff27337be13a173d2a9164a49708ca3a6f` |
| reference-gallery-floor.png | `d7636e7c478a7d423cf0fede9544cac9c5b40544babee1c088de983a57672b12` |

Spend: USD 0.
