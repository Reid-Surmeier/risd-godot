# Shader refinement decision at ed54e32

**Keep the current finish unchanged for the next lighting A/B.** Independent `blind_refined_review` reported no verified shader defect; its concrete finding is repeated pale wall-light caps above paintings. I inspected the current exported start and 1600px shell screenshots and the 6fps motion sample, and agree that this is a bake issue rather than a reason for more filtering, tint or noise.

Evidence inspected:
- `/tmp/candidate-entry-start.png`: white doorway/vestibule retains bright faces and readable edges; accepted character silhouette remains clean.
- `/tmp/candidate-entry-shell-1600.png`: no dominant 2×2 checker or abrupt CRT-exclusion seam inside the gallery; repeated light caps remain conspicuous.
- `/tmp/candidate-entry-motion-6fps.png`, sampled from `/tmp/candidate-entry.webm` (1600×900,30fps): room surfaces and broad light patterns follow the scene through walking/turning, without a gross independently animated overlay. A contact sheet cannot certify subtle temporal crawl.

Source review: `gamecube.gdshader` quantizes eight clamped native texels, uses the existing 0.5 copy-filter strength, and reconstructs bilinearly. No TIME/random offsets/warping or new runtime lights. Browser-safe texelFetch calls remain in fragment scope. No changes to shader, tests or accepted visitor were made.

Re-ran the persistent actual-GPU test using Godot4.7.2 Compatibility/OpenGLES3.1 on D3D12 RTX4070SUPER. `/tmp/gallery-current-final-render-check.log` reports:
- 1600 pixels at each filter strength0/0.5/1: worst channel errors0.002465/0.002614/0.002484 (<1/255).
- Black/white preservation checks pass.
- CRT+haze quiet region:1600 pixels, max error0; outside effect remains active (delta0.117647).
- Production mapping callbacks refresh resized/moved/hidden regions and CRT-toggle state before the QA timer interval.
- `FINAL_RENDER_GPU_FAILURES 0`, process exit0.

No before/after shader change is presented because independent evidence did not justify one. Keep shader and accepted character fixed while the bake agent tests energy8→6 with a0.3m lower target. The final combined export still needs moving browser review and performance measurement; native arithmetic checks do not establish those results.
