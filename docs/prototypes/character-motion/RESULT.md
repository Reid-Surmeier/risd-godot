# #171 — non-authentic motion on the sourced New Horizons rig

2026-09-28 UTC. **Native/Web playback and numerical contact checks pass; independent visual gate pending. No runtime asset accepted or installed.** This is a throwaway prototype, not Nintendo motion. #159 must remain blocked until the independent visual review and its other gates pass.

![Idle](evidence/front-idle.png)
![Side walk](evidence/side-walk.png)
![Gallery camera](evidence/gallery-walk.png)
![Back interaction](evidence/back-interact.png)

Continuous 18-second, 540-frame native captures: [front](evidence/front.mp4), [side](evidence/side.mp4), [back](evidence/back.mp4), [gallery camera](evidence/gallery.mp4). The [original Web replay](evidence/browser.webm) was rejected for slow playback and is retained as failure evidence. Its replacement is the [normal-speed Web replay with independent wall-clock overlay](evidence/browser-normal-speed.webm). [Rejected uncorrected transfer](evidence/raw-rejected.mp4) records the original contact failure.

## Preserved target and bounded donor

The target is the [#163 statically reviewed Hair36 candidate at cf4a17ae](https://github.com/Reid-Surmeier/risd-godot/blob/cf4a17ae/docs/prototypes/character-materials/RESULT.md), SHA-256 `a2e6e0948dafb5b0ac10ffdc7359c64fbe04371038f0265d9cb1e1af390e54c4`. Its 42-bone Godot rig contains the unchanged 36-joint body and the separately sourced Hair36 attachment. Body geometry, UVs, skin weights, inverse binds, local rest transforms, source PNGs and GLB bytes remain untouched. The earlier 44-bone assembly used Hair00; this trial changes neither assembly nor hair choice. Raw target assets stay in `/tmp/risd-171-motion`, outside the committed runtime.

The donor is the [pinned KayKit Rogue GLB](https://raw.githubusercontent.com/KayKit-Game-Assets/KayKit-Character-Pack-Adventures-1.0/672074b73ba276876a19e8816ecdc5241817ab47/addons/kaykit_character_pack_adventures/Characters/gltf/Rogue.glb), SHA-256 `e825437cd4d2ee9c1960b517a74a69101e33eb409ae7fa8cedc7134a998fbb7d`, creator Kay Lousberg, CC0. Only `Idle` (1.066667 s), `Walking_A` (1.066667 s), and `Interact` (1.3 s) are evaluated. This does not establish a Nintendo run or any native clip. The #151 native `CharactorAnimation.Nin_NX_NVN.zs`/BFSKA route remains open; no such payload was available for this trial. No paid generation or new provider call; spend USD 0.

## Transfer and observed correction

`trial.gd` samples donor global bone rotations relative to its rest pose, applies that rotation delta to the target rest basis, and reconstructs parent-relative rotations. Target bone translations/lengths and unmapped helper, skirt and hair bones retain their authored relationships. The two target root bones share normalized donor hip translation. The measured rest-skinned vertical extent is `0.187345907..17.017436981` source units; uniform scale `0.1039804237` gives 1.75 world units, and the floor offset removes the rest sole gap. Target hip-height/donor hip-height ratio is `11.4692592`.

Direct rotation/hip transfer failed: the actual sock mesh penetrated the floor by **0.0368793** world units, exceeding the proposed 0.01 limit. The next trial adapts the existing gallery visitor's two-bone contact solver to the target's additional helper-bone chains, retaining rest toe flex and adding a 0.031194-unit knee reserve. Merely locking a sole center still failed: during root turns, sole vertices rotated around that fixed center and drifted **0.158812** units. The final correction locks the planted foot's orientation in world space as well as its center. These are project-authored contact corrections, not donor or Nintendo animation.

The final native maximum floor penetration is **0.000000473** units, sole-center anchor error **0.000001094**, and actual planted-sole vertex drift **0.000001528**. Web reports the same penetration/center error and **0.000001475** vertex drift. The verifier follows 194 authored bottom-of-sock vertices (97 per foot), maintaining their vertex identity across each contiguous planted interval. Limits are 0.01 penetration and 0.02 horizontal vertex drift at 1.75 height. This proves the recorded numerical scenarios only; it does not substitute for visual approval.

The separate shirt audit measures 1,284 triangle edges over 540 poses. Edge-length ratios versus the rest-skinned shirt range from **0.690706 to 2.200075**. This is a substantial local stretch, not a garment-quality pass; inspect the sleeves/hem and interaction in the independent visual review. No automatic deformation threshold was invented to approve it.

The scripted scenarios cover idle, straight start/walk/release, diagonal walk, 90/180-degree turns, a turn to artwork, interruption of `Interact` at approximately 0.65 s by movement, a second release, project-authored head look, and a complete interaction. Translation uses the current gallery's 1.2-unit speed. At that speed the sampled walk runs at three times its source cadence: **accelerated walk, not a native run**. Front/side/back are full-body inspection views; the gallery view uses the existing camera's 23-degree FOV, 14.2-unit distance and 42-degree pitch at 600×600. This is an isolated camera/rig test, not a test of live gallery input, collision, artwork picking or animation-controller integration.

The original Web test exported with Godot 4.7.2's single-thread Compatibility template and completed 540 poses with no console/page errors. Its fixed 1/30-second pose step was tied to a loop that also waited for rendering and a timer. That made real playback slow, rather than merely retiming the recording. The independent reviewer passed the sampled poses/deformation but correctly withheld complete motion sign-off. See the measured correction below.

## Browser timing diagnosis and correction

The independent browser oracle observes each published demo timestamp through `requestAnimationFrame` and stamps it with browser `performance.now()`. Its four-second regression failed on the actual old export: **4.000 demo seconds / 6.4921 browser seconds = 0.6161×**. Removing only the extra timer also failed, in the opposite direction: **4.000 / 2.2841 = 1.7512×**. This distinguishes the fixed-per-iteration step from recording retiming or asset deformation. Raw observations are retained in `evidence/timing-before.json` and `evidence/timing-without-timer.json`.

The corrected browser loop samples actual elapsed time and uses its delta for locomotion, gait and turn interpolation. Offline native frames retain their deterministic 30 FPS sampling. Shader/skinning warm-up occurs visibly under “Preparing motion replay” before the playback clock begins. A separate DOM overlay uses browser `performance.now()`, rather than the engine's clock, to display wall time beside the demo timestamp. After 18 seconds it explicitly displays “COMPLETE”; heavyweight audit serialization happens afterwards and is not motion playback. No frame-rate conversion or video time-stretch is applied to the Playwright recording.

`browser.cjs` now asserts a wall/demo ratio within 5%; `timing.cjs` runs the same assertion through a short four-second capture. The real-time contact verifier accepts variable frame counts, checks scenario duration and monotonic sample gaps under 0.1 seconds, and retains the same floor/sole-vertex thresholds. The final full-run timing and geometry records are committed separately as `evidence/timing-normal-speed.json` and `evidence/browser-normal-speed-metrics.json.gz`. This proves timing on the tested Chromium/SwiftShader host; integration with live gallery input/collision remains outside this isolated prototype.

Final normal-speed result: **17.9872 demo seconds / 17.9827 browser seconds = 1.000250×**, 1,080 rendered observations. Frame intervals are 16.7 ms median, 16.8 ms p95, and 23.8 ms maximum. The real-time geometry check passes with maximum floor penetration **0.000000376**, planted sole-center error **0.000171321**, and planted sole-vertex drift **0.000133994** world units. The target GLB remains SHA-256 `a2e6e0948dafb5b0ac10ffdc7359c64fbe04371038f0265d9cb1e1af390e54c4`. Fresh independent visual review of this corrected-time recording remains pending; the earlier pose/deformation pass does not alone close the ticket.

![Independent browser and demo clocks during playback](evidence/browser-normal-speed-10s.png)
![Explicit completed playback before audit export](evidence/browser-normal-speed-complete.png)

## Reproduce and verify

Use the exact hashed GLBs above. Copy this folder's `trial.gd`, `trial.tscn`, `export_presets.cfg` and `project.godot.template` into an empty scratch project, naming the latter `project.godot`; put the inputs there as `character.glb` and `donor.glb`. Run `godot --headless --editor --path <scratch> --import`, then `MOTION_VIEW=front godot --path <scratch> trial.tscn`; repeat for `side`, `back`, and `gallery`. The trial writes full PNG sequences and world-space metrics into that scratch folder. Encode each PNG sequence at 30 FPS as shown by the committed MP4s.

`python3 docs/prototypes/character-motion/verify.py <scratch>/metrics-front.json <scratch>/metrics-side.json <scratch>/metrics-back.json <scratch>/metrics-gallery.json` passes. The stronger vertex check fails on the earlier center-only correction, so it does not merely repeat the solver's anchor assertion. `inspect.gd` inventories target/donor rigs; `garment_audit.gd` runs the same poses while comparing source shirt triangle edge lengths against rest.

The committed `evidence/native-metrics.json.gz` and `evidence/browser-metrics.json.gz` retain the complete frame/vertex records and can be passed directly to `verify.py`. `evidence/garment-audit.json` records the separate shirt result. `evidence/SHA256SUMS` binds the capture and metric artifacts.

Export the scratch project with `godot --headless --editor --path <scratch> --export-release Web /tmp/risd-171-web/index.html`, serve that folder privately on port 8171, then run `browser.cjs` with `PLAYWRIGHT_PATH` pointing to the already installed Playwright package. It records video, errors and metrics under `/tmp/risd-171-browser`; run `verify.py` on that metrics file too. Never publish the raw model payload as a runtime asset based on this test.

Repository `scripts/check.sh` passed after a fresh Godot editor import; `git diff --check` passed. The engine logged its existing exit-time object-leak warning, not a test failure. Independent GPT-6 Astra medium image/video-only review is requested on the final replacement evidence. Until that review is recorded, this ticket remains open and the visual gate remains pending.
