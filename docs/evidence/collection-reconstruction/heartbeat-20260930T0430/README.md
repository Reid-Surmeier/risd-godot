# Collection casing support — 2026-09-30 04:30 UTC

Prototype #182 only. Two outer casing toes predict reserved frame 239 within
1.995 / 2.243 px using frames 238/244. Ray angles: 18.0 / 25.7 degrees.
All three poses already contributed to SfM; same-video, correlated evidence.
The toes are 1.96 / 4.14 provisional cm off the frozen corridor plane;
±3px pick sensitivity gives 7.57 / 5.17cm p95 displacement, omitting pose/scale
uncertainty. The small floor extension projects the left toe onto that plane.

Three grand-door queries 490/495/492 fail the unchanged ≥20 odd-point pose
inlier gate after targeted CUDA matching against 475 frozen references.
32–57 matched 3D correspondences do not establish supported poses. Preserve
the trial and cached database; do not repeat matching or infer geometry there.

All 24 native/Chrome movement-camera checks and real WASD round trip pass on
RTX 4070 SUPER. Browser 1100×760, ready 2.343s, sampled p95 16.67ms; native p95
8.33ms. Tiny-scene samples do not establish final performance budgets.

Repository/diff checks pass. Initial Shell playtest lost its X connection;
complete rerun has five failures, all in the previous eight failure names.
No runtime/frozen files, 3D Viewer or production integration changes. Paid $0.
Provenance includes generators, frozen model, inputs and evidence hashes.
