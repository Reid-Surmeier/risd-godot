# Webcam booth: browser capture and later expression tracking

Research decision for [Research: browser webcam capture and later expression tracking in standalone Godot](https://github.com/Reid-Surmeier/risd-godot/issues/196), 2026-09-29. No paid requests were made.

## Recommendation

Build a standalone Godot project in this isolated worktree. Use Compatibility rendering and the installed single-threaded Web template. Put browser camera access in one small JavaScript adapter loaded by the project's custom HTML shell; Godot owns the booth states and explosion. Keep the live `<video muted autoplay playsinline>` preview in the browser and transfer only the captured image into Godot. This avoids encoding or copying every preview frame into WebAssembly. Godot officially supports browser adapters through `JavaScriptBridge`, custom HTML shells and Head Include. Web export requires WebGL 2.0; Compatibility is the supported renderer, and single-threaded export avoids the cross-origin isolation headers required by threaded builds. This implementation choice follows those supported features; its complete exported loop still needs prototype verification. [Godot JavaScriptBridge](https://docs.godotengine.org/en/stable/tutorials/platform/web/javascript_bridge.html), [Godot Web export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html).

Use a top-level HTTPS page on the owner's device. `navigator.mediaDevices` is a secure-context API. Request `{video: {facingMode: "user", width: {ideal: 640}, height: {ideal: 480}}, audio: false}` from the camera-start button; avoid mandatory dimensions that reject otherwise usable cameras. Wait for an actual video frame before enabling Capture. Draw that frame into a bounded canvas, then encode PNG once. The browser standard supports video input to `drawImage` and canvas image serialization. [W3C camera specification](https://www.w3.org/TR/mediacapture-streams/), [HTML canvas specification](https://html.spec.whatwg.org/multipage/canvas.html#dom-context-2d-drawimage).

For the smallest bridge, return the canvas PNG data URL as a string, strip its prefix and base64-decode in Godot, then call `Image.load_png_from_buffer` and create an `ImageTexture`. A typed-byte path is also supported through `JavaScriptBridge.eval`, but is unnecessary until image size or profiling calls for it. Preserve references to any Godot-created JavaScript callbacks; bridge callbacks receive one Array argument. Reject empty or undecodable image data. [Godot JavaScriptBridge conversion and callback rules](https://docs.godotengine.org/en/stable/tutorials/platform/web/javascript_bridge.html), [Godot Image PNG loading](https://docs.godotengine.org/en/stable/classes/class_image.html#class-image-method-load-png-from-buffer).

Recommended basic loop: **camera → capture → generating → portrait with ten-second fuse → explosion → camera**. Start the fuse when the accepted portrait is displayed, so generation latency does not consume its viewing time. This timing is a design recommendation, not a fact inferred from an untested animation. Preserve one live camera stream through repeated captures. On reset, discard the captured pixels, generated portrait, timers and object URLs; on exit, stop every stream track and clear `video.srcObject`. `stop()` moves a track to `ended`; it does not itself fire the normal ended event. [W3C track lifecycle](https://www.w3.org/TR/mediacapture-streams/#dom-mediastreamtrack-stop).

## Verified local state

| Inspection | Observed result |
| --- | --- |
| `godot --version` | `4.7.2.stable.official.ed1daf0bf` |
| `readlink -f /home/reidsurmeier/bin/godot` | `/home/reidsurmeier/.local/opt/godot-4.7.2/Godot_v4.7.2-stable_linux.x86_64` |
| Export-template version file | `/home/reidsurmeier/.local/share/godot/export_templates/4.7.2.stable/version.txt` contains `4.7.2.stable` |
| Web templates | Matching `web_nothreads_debug.zip` and `web_nothreads_release.zip` exist; release archive includes `godot.js`, `godot.wasm` and `godot.html` |
| Browser | `/usr/bin/google-chrome`, `Google Chrome 154.0.8037.57` |
| Browser automation | Global `/home/reidsurmeier/.npm-global/lib/node_modules/playwright/index.mjs`; root package does not resolve `playwright` locally |
| Camera hardware | No `/dev/video*` device is exposed on this host |
| Existing repo pattern | `export_presets.cfg` already disables threads; `modules/collection_data/playtest/browser.mjs` imports Playwright from `PLAYWRIGHT_MODULE` and records browser errors/screenshots |

The existing RISD export script packages the Shell and its media; give the standalone booth its own export command rather than invoking that script. Installed matching templates are verified; a successful standalone booth export was not claimed by this research.

### Browser probe actually run

Ran an in-memory Node HTTP server and a headless Chrome instance through the installed Playwright module, with `--use-fake-device-for-media-stream`, camera permission granted by BrowserContext and no microphone permission. No project or fixture files were created for the probe. Chromium's fake camera switch is a first-party testing feature, and Playwright supports per-context camera permission grants. [Chromium media switches](https://chromium.googlesource.com/chromium/src.git/+/cc79060bcce11b0cb6fafa673a2a20dcb12bd077/media/base/media_switches.cc), [Playwright permissions](https://playwright.dev/docs/api/class-browsercontext#browser-context-grant-permissions).

Observed and asserted:

- Browser secure-context status was `true` on the local loopback test origin; camera dimensions were `640×480` before cleanup.
- Three successive video frames produced PNG blobs of `4566`, `4897` and `5135` bytes. Each decoded through `createImageBitmap` to `320×240`; PNG signatures were checked in the preceding probe.
- One video track remained live during repeated captures; zero audio tracks were requested; explicit cleanup changed the video track to `ended`.
- A separate context with camera permission denied returned `NotAllowedError`.

This is evidence for browser camera/capture/repetition/cleanup plumbing, not proof of portrait generation, the Godot bridge, explosion, HTTPS deployment, mobile camera behavior or expression detection. The synthetic camera is a test pattern, not a face. Loopback is used only inside automated host checks; the owner's review link must be published through the share skill using HTTPS.

## Failure handling and full-loop acceptance

These are recommended acceptance requirements for the prototype, not tests already passed:

1. **Two complete unpaid fixture loops:** Camera Start obtains one stream; Capture snapshots the displayed frame; a deterministic generator returns a portrait; the visible fuse lasts ten seconds; explosion removes it and returns to a usable camera. Repeat Capture without a page reload or additional stream. Inspect full-page browser screenshots at camera, portrait, explosion and reset in wide and narrow viewports. A DOM video must be included in the screenshot and aligned with the Godot viewport.
2. **Permission/device failure:** Exercise `NotAllowedError`, absent-device failure and a camera promise that never resolves. Show a readable recoverable state with Retry. Do not enable Capture until nonzero video dimensions and a decoded frame exist. If a timed-out camera request later resolves, immediately stop that stale stream so it cannot secretly become a second camera session.
3. **Generation failure:** Bound the waiting state with a documented generation timeout, reject failed HTTP responses and invalid images, and return to Camera with Retry. The timeout is separate from the ten-second portrait fuse. Use a monotonically increasing capture token: only the active token can display a result. Reset or timeout invalidates it. A result arriving late must not revive a portrait or overwrite a newer capture. Abort local fetch where possible; an aborted provider request is still potentially spent and must not trigger an automatic paid retry.
4. **Duplicate capture/reset:** Rapid double-clicks produce one pending request. Reset during generation cancels local state; repeated Reset is harmless. A generation result for capture A cannot replace capture B. On close, stream tracks end and image references/object URLs are released. Keep fixture generator controls out of the ordinary booth UI.
5. **Remote-device evidence:** Export the actual standalone Godot project, publish the page through the share skill and verify browser secure-context status. On a real device, test camera permission, framing/mirroring, Capture, ten-second portrait fuse, explosion and repeated capture. Also background the tab during the fuse: compute expiration from an absolute deadline and recheck on resume, because Godot's Web frame processing can pause in background tabs. Automated fixture results do not substitute for this hardware/browser check. [Godot background processing](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html#background-processing).

Prefer injecting a test camera through `page.addInitScript` that returns a canvas `captureStream`, or Chromium's fake-camera switch for the real `getUserMedia` path. Inject generator outcomes separately: immediate success, rejected response, never resolving, delayed success after reset and delayed A after B. `captureStream` is specified for canvas sources; `addInitScript` runs before page scripts. [W3C canvas capture](https://w3c.github.io/mediacapture-fromelement/#dom-htmlcanvaselement-capturestream), [Playwright init scripts](https://playwright.dev/docs/api/class-page#page-add-init-script).

## Expression tracking after the basic booth

Keep tracking out of the first capture loop. A later browser adapter can reuse the same camera video with MediaPipe FaceLandmarker, video running mode, one face, `outputFaceBlendshapes: true` and optional `outputFacialTransformationMatrixes: true`. The implementation exposes landmarks, blendshape categories and transformation matrices, and requires a model asset plus a WASM fileset. `detectForVideo` returns synchronously: calling it on every frame can stall the single-threaded booth. Start with a capped inference cadence and measure frame time; move it into a worker if that check fails. Report face absence explicitly and return controls toward neutral rather than freezing the last expression indefinitely. These scheduling/absence rules are implementation recommendations. [MediaPipe FaceLandmarker implementation](https://github.com/google-ai-edge/mediapipe/blob/master/mediapipe/tasks/web/vision/face_landmarker/face_landmarker.ts), [MediaPipe Web Vision README](https://github.com/google-ai-edge/mediapipe/blob/master/mediapipe/tasks/web/vision/README.md).

A generated PNG/WebP portrait remains a **2D image**, even if it depicts a sculpted head. MediaPipe supplies tracked face features; it does not turn that still into a custom rigged 3D head. A true turning, expression-driven portrait needs separate mesh geometry, material/UV mapping and deformation targets or a rig; a textured plane only offers a 2D or shallow 2.5D presentation. Treat choosing/building that geometry as a later decision rather than promising it from image generation. The MediaPipe Web result here contains face measurements, not the generated portrait's mesh. [MediaPipe result handling](https://github.com/google-ai-edge/mediapipe/blob/master/mediapipe/tasks/web/vision/face_landmarker/face_landmarker.ts).

Pin the selected MediaPipe package/model versions and record their hashes when this phase starts. Its model execution is on-device according to the project's Web README; CDN/model downloads are separate network requests. This research did not install MediaPipe or benchmark inference. The official FaceLandmarker guide failed to load through the research browser; first-party source and README were read instead. [MediaPipe Web processing and assets](https://github.com/google-ai-edge/mediapipe/blob/master/mediapipe/tasks/web/vision/README.md).

## Remaining limitations

- No blocker in installed Godot/Web-template/Chrome tooling was found. Exported bridge behavior, real-device HTTPS camera access and the full booth loop remain unverified until the prototype.
- This host cannot verify a physical webcam locally; synthetic cameras test plumbing only.
- Generated-portrait provider availability, exact pricing, server credential handling and identity/style fidelity belong to the companion generation research decision. They were not exercised here.
- The ten-second fuse begins after a successful portrait result in this recommendation. Timeouts, late results and replay behavior need explicit checks before any paid end-to-end attempt.
