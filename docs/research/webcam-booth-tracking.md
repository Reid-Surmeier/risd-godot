# Live expression tracking for the webcam portrait

Research for [Add local live expression tracking after the basic booth](https://github.com/Reid-Surmeier/risd-godot/issues/203), 2026-09-30. No paid requests, dependency installation, Git changes or issue changes were made. Only this report was written; downloads and browser test workers were held in memory and discarded after testing.

## Decision

Keep the generated portrait as a 2D texture. Add one local MediaPipe worker reading the existing camera video, then use a small CanvasItem deformation shader on the existing portrait TextureRect. This is the smallest route in the current `webcam-booth/main.gd`: Godot already has that TextureRect and a ShaderMaterial pattern for loading. CanvasItem shaders can sample `TEXTURE` using modified `UV`; a Polygon2D also supports texture coordinates and indexed subpolygons, but requires constructing and updating a mesh that this prototype does not otherwise need. Both are supported platform features. [Godot CanvasItem shaders](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/canvas_item_shader.html), [Godot Polygon2D](https://docs.godotengine.org/en/stable/classes/class_polygon2d.html).

This produces approximate blink, smile, jaw stretch and small portrait motion. It does not reconstruct a rigged 3D head. A single still cannot reveal teeth, mouth interiors, hidden cheeks or eyelids that were never pictured; UV deformation stretches existing pixels. The user's board explicitly allowed an image plus face shifting, so those limits need not block this route. Treat large angle head turns and accurate new facial appearances as future work requiring additional imagery or geometry.

## Exact dependency and assets

No `@mediapipe/tasks-vision` package or FaceLandmarker model was found in this worktree's `node_modules`, the global npm tree or the host cache. The npm publisher registry's stable `latest` tag was **1.0.1** when checked; nightly was `1.1.0-rc.20260929`. Pin the tested stable version rather than a floating `latest`. The official guide identifies this package and explains the model/WASM initialization. [Published package metadata](https://registry.npmjs.org/@mediapipe/tasks-vision), [Official Web guide](https://developers.google.com/edge/mediapipe/solutions/vision/face_landmarker/web_js).

Package archive: [tasks-vision-1.0.1.tgz](https://registry.npmjs.org/@mediapipe/tasks-vision/-/tasks-vision-1.0.1.tgz), SHA-256 `ee318eaa3d42230aa10910d114faf2a488c577c4e4d33c7cb04126924aca505f`. Registry SHA-512 integrity: `sha512-rvRE2FmAZ6ZxKSw7wq+e+jQDpN3t1B/tD2mJz9SmAzb1msoDkd4dMoE4wAh8Z30Um0PQwLiHr9QtomhmXk3aUQ==`.

Model: [FaceLandmarker float16 version 1](https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/1/face_landmarker.task). Use this explicit `/1/` URL, not `/latest/`. This is the model bundle linked by Google's task overview. [Official model description](https://developers.google.com/edge/mediapipe/solutions/vision/face_landmarker#models).

Hashes below were computed from the downloaded package archive and model, not inferred from filenames:

| Asset inside package, except model | Bytes | SHA-256 |
| --- | ---: | --- |
| `vision_bundle.js` | 155465 | `98db72469ffb176f5e9f2687be0f70783893aca681f7789c34b872b0a764371a` |
| `vision_bundle.mjs` | 155439 | `d885630c297c0b20b1fe86096cb06291c4c8080876f27852e724f24ac603713f` |
| `wasm/vision_wasm_internal.js` | 323377 | `e170ee67dd4e16c1a6fcd8840a206687e5a59b22c20e4a902bc445b095454d73` |
| `wasm/vision_wasm_internal.wasm` | 11756954 | `8da277a733926eacd0474b8704b36742d6ec3231c57a860c5b889dff8f1df886` |
| `wasm/vision_wasm_nosimd_internal.js` | 323180 | `e81d715a3d42cc3373602eb2f7aff795d164934db680e32496b65dab537f9658` |
| `wasm/vision_wasm_nosimd_internal.wasm` | 10960242 | `a28483cd42e74e855bf5ebdb6b40d9b66a5b49e35e95020bc97669e6822a3192` |
| `wasm/vision_wasm_module_internal.js` | 323415 | `da8934057f147b622e82cfb4c0dbd85461c598e268588b5a8ba9ca963a8ff82d` |
| `wasm/vision_wasm_module_internal.wasm` | 11756972 | `2dabd8e23c60984628beb7bb338764c81a08e6837145273f59578684b5d53c1b` |
| `face_landmarker.task` | 3758596 | `64184e229b263107bc2b804c6625db1341ff2bb731874b0bcc2fe6544e0bc9ff` |

For the tested classic worker, use `vision_bundle.js` plus SIMD and non-SIMD WASM/loader pairs and the model. The resolver selected `vision_wasm_internal.js` and `vision_wasm_internal.wasm` on this Chrome host. Keep the non-SIMD fallback for other devices. The extra module pair is present in the archive but was not requested by this classic-worker probe. Serve them beside the booth under one local asset directory; do not add a runtime npm dependency solely to copy these files. Retain their license, package pin and provenance, and follow the repo's source-vendoring rule when adopting the library.

## Tested worker setup

The classic bundle exports **`Vision`**, with a capital V. Using lowercase `vision` failed with `ReferenceError`; this was corrected before successful inference. This initialization ran successfully in a browser worker:

```js
importScripts('/tracking/vision_bundle.js');
const fileset = await Vision.FilesetResolver.forVisionTasks('/tracking/wasm');
const tracker = await Vision.FaceLandmarker.createFromOptions(fileset, {
  baseOptions: {modelAssetPath: '/tracking/face_landmarker.task', delegate: 'CPU'},
  runningMode: 'VIDEO', numFaces: 1,
  outputFaceBlendshapes: true, outputFacialTransformationMatrixes: true
});
// Receive a transferred ImageBitmap and an increasing millisecond timestamp.
const result = tracker.detectForVideo(bitmap, timestamp);
bitmap.close();
```

`detectForVideo` is synchronous, so keep it off the Godot/browser UI thread. The official guide recommends workers for that reason. `numFaces: 1` enables the task's smoothing. Use a single pending inference, approximately 10 Hz to start, and transfer an ImageBitmap instead of posting base64 image strings. Skip frames while busy; close transferred bitmaps on both success and failure. This scheduling cap is a proposed implementation choice. A browser worker does not require enabling Godot Web threads or SharedArrayBuffer. [Official worker and options guidance](https://developers.google.com/edge/mediapipe/solutions/vision/face_landmarker/web_js), [FaceLandmarker source](https://github.com/google-ai-edge/mediapipe/blob/master/mediapipe/tasks/web/vision/face_landmarker/face_landmarker.ts).

The camera adapter currently owns a private video object. Add scoped tracking access within that adapter rather than opening another camera. Keep the camera stream alive while displaying the portrait. Stop frame production on reset/explosion and invalidate the portrait session token; discard any result belonging to the prior portrait. Close the tracker/terminate its worker on exit. If tracking initialization or inference fails, the fuse and camera reset must still work.

## Map measurements onto portrait pixels

Read blendshapes by `categoryName`, not by numeric position. Send only the five relevant finite, clamped `[0,1]` values plus face-present state, timestamp and optional pose measurements through the existing JavaScriptBridge pattern. MediaPipe results expose named classifications and a flattened pose matrix; their implementation resets absent-face results rather than preserving old values. [Result construction](https://github.com/google-ai-edge/mediapipe/blob/master/mediapipe/tasks/web/vision/face_landmarker/face_landmarker.ts).

| Measurement | Small 2D effect |
| --- | --- |
| `eyeBlinkLeft`, `eyeBlinkRight` | Locally compress the corresponding eye's pixels toward the lid center; undo on reopening. Account for preview mirroring exactly once. |
| `mouthSmileLeft`, `mouthSmileRight` | Move each mouth corner slightly outward and upward with a smooth spatial falloff. |
| `jawOpen` | Stretch/displace the lower lip and chin downward within the face region. This is an opening gesture, not newly generated teeth or mouth interior. |
| Head pose | Apply small relative in-plane tilt and horizontal/vertical face motion. Clamp it to preserve the image; do not pretend a plane can reveal the head's sides. |

Detect anchors on each accepted generated portrait once in **IMAGE** mode before enabling deformation. Original-camera landmark coordinates cannot be reused unchanged on a differently cropped/generated face. Use the returned eye/lip contour positions to define shader centers and radii; the bundle exports eye/lip connections. Switching the tracker between IMAGE and VIDEO rebuilds its graph, so do that only for initialization/anchor analysis, then restore VIDEO before live frames. If no generated-image face is found, retain the portrait static and report tracking unavailable; arbitrary default eye locations are not verified alignment.

For the current accepted sample, IMAGE inference succeeded. Averaging eye-corner indices `33/133` and `362/263` gave approximate texture UV eye centers `(0.4293, 0.4078)` and `(0.5670, 0.4071)`. Averaging mouth corners `61/291` gave `(0.4999, 0.5499)`. These are measured values for this one image, not universal model constants. They match the visible face after inspection. Use upper/lower eyelid contours for effect radius, not just these centers.

Subtract a neutral baseline and bound the response so the still's original expression is preserved at calibration. A small time-based interpolation avoids rendering noise. Missing/stale tracking should ease effects back to zero. A proposed stale threshold is 0.5 seconds; this is policy, not MediaPipe's model guarantee. The neutral fixture photo already measured nonzero blink scores, so treating every raw score as a binary closed eye would be visibly wrong.

For pose, the tested matrix had translation at entries 12–14 and affine bottom values at 3/7/11/15, consistent with column-major 4×4 storage. The Web result interface itself only promises flattened data, not an Euler convention. Either test the current pin's matrix-to-Godot conversion explicitly and calibrate mirror/sign conventions, or initially use the two eye centers for in-plane tilt and face center displacement. Do not hard-code arbitrary Euler indexing without that check. The geometry source maps a canonical face to observed landmarks, not to the generated portrait's geometry. [Geometry pipeline](https://github.com/google-ai-edge/mediapipe/blob/master/mediapipe/tasks/cc/vision/face_geometry/libs/geometry_pipeline.cc).

If a shader cannot pass visual inspection, the native alternative is a regular triangulated Polygon2D grid over the image, fixed texture-pixel UVs and smoothly weighted vertex displacement. Keep outer vertices fixed and cap displacement to avoid flipped triangles. Assign a modified PackedVector2Array back to `polygon`, because property access returns a copy. This alternative needs no triangulation library; the grid's two triangles per cell are explicit. It remains 2D deformation. [Polygon2D property rules](https://docs.godotengine.org/en/stable/classes/class_polygon2d.html).

## Actual browser evidence

Ran Chrome `154.0.8037.57` through global Playwright `/home/reidsurmeier/.npm-global/lib/node_modules/playwright/index.mjs`, headless, with `--no-sandbox --enable-unsafe-swiftshader` for host software WebGL. The latter is a test-host launch flag, not a requirement for the owner's real browser. The model ran in a classic worker with CPU delegate and transferred ImageBitmaps. An in-memory HTTP server served the exact downloaded assets and fixtures; no source image was uploaded to a provider.

The successful assertion-based VIDEO probe used the full `1024×761` reference photo three times, then a same-size white image, then the photo again. It passed face-count sequence **`[1,1,1,0,1]`**. Every detected face had 478 landmarks, 52 named blendshapes, five finite selected coefficients in `[0,1]` and a 16-value pose matrix. Measured detection times were `155.2, 27.8, 28.0, 20.7, 28.1` ms; these are one host's smoke-test timings, not a mobile performance guarantee.

First-frame coefficients: `jawOpen=0.001509`, `eyeBlinkLeft=0.167772`, `eyeBlinkRight=0.108187`, `mouthSmileLeft=0.051811`, `mouthSmileRight=0.041540`. Source photo SHA-256: `1265c94186f7b11d019060b819ad486d9ae2a8fc909acd0b70226fd5532fc395`.

A separate IMAGE-mode worker detected both the original photo and `webcam-booth/assets/sample-portrait.webp`, each with 478 landmarks, producing the anchors above. Portrait SHA-256: `3001131179a4d8b5270024864ab79ef5aab75b7831f267d728a88423204d11b7`. That second probe loaded the exact version through jsDelivr; the first successful VIDEO probe served publisher-archive bytes locally.

An exploratory VIDEO run changed the source from full photo to a differently cropped image and observed a no-face frame before reacquisition. A test that assumed every crop immediately yielded a face failed. This reinforces keeping camera dimensions/framing stable and handling temporary face absence. Earlier exploratory failures were test setup errors (bundle global casing and switching IMAGE/VIDEO without restoring the required mode); no runtime result is claimed from those failures.

## Acceptance for implementation

1. Repeat the real model worker probe: face, repeated frames, no face and reacquisition. Assert all five named coefficients, finite bounds and increasing timestamps. Test worker/model-load failure separately.
2. Inject recorded extreme controls independently: each eye closes/reopens, each smile side moves, jaw changes, and neutral resets. Inspect screenshots for movement at the actual eyes/mouth, unchanged frame/gloves and bounded distortion. Verify mirror mapping with asymmetric controls.
3. Capture an actual generated portrait and analyze its anchors; handle no detected face honestly. Texture pixel changes are visual proof, while a synthetic score alone is only adapter evidence.
4. Reset/explode during pending inference: late messages cannot deform the next portrait; camera capture remains available; no second camera stream or accumulating bitmap queue exists. Model failure must not stall the ten-second fuse.
5. Real camera HTTPS check on the owner's device: smile, blink, open mouth, move head, leave frame and return. Verify responsive rendering and all existing capture/fuse/explosion tests. This research tested static fixtures, not live human expressions or the final deformation shader.

MediaPipe's project states that task inference processes input on-device; downloaded JavaScript/WASM/model assets remain network requests. Self-host the pinned assets to make that distinction clear and avoid floating dependencies. [MediaPipe Web Vision README](https://github.com/google-ai-edge/mediapipe/blob/master/mediapipe/tasks/web/vision/README.md).
