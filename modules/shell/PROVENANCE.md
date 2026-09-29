# Shell visual provenance

## Collection expansion prototype — issues #178, #183

The new frame trial lives outside runtime dependencies in
[`image-work/collection-expansion-frame`](../../image-work/collection-expansion-frame/README.md).
It is not an accepted game asset.

- Source: user Proton museum video IMG_6386.MOV, 2 fps sample 122 (nominal 60.5 s),
  CUDA-decoded native frame, canvas-plane rectification. Source hash and transform:
  `image-work/collection-expansion-frame/source.json`.
- Provider/model: OpenRouter / `meta/muse-image`; one output; recorded actual cost
  **$0.010000**, run `run-ed0aaab20f6b84b6db0db31b`. Retain the run's unknown spend
  state and never-resubmit flag; no additional request was made.
- Exact existing Grand Gallery source-preserving frame prompt SHA256:
  `8857d37da73e411814c24d8e9d449a1182fe8e6116af6cf6e7eed67273346949`.
- Native result SHA256:
  `66c667d5786e50dc2a786f01e0435aee65b188f496d5814bf9687a6eb6ebbb76`.
- The separate authentic painting is RISD 35.786, *Arabs Traveling*;
  [museum source](https://risdmuseum.org/art-design/collection/arabs-traveling-35786).
  Image hash/rights evidence appears in the anchor research and trial review.
- Keying, texture, catalogue scale and geometry hashes are in the trial's
  `review.json`. Full run records are archived with reconstruction evidence.
- Visual state: trial inspected in Godot on RTX 4070 SUPER. No batch acceptance,
  measured frame depth, room lighting bake, sculpture generation or finished
  connected-map claim. Existing assets retain their existing adjacent records.
