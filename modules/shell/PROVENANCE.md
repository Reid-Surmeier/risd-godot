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

## Collection doorway validation — September 29, 20:35 UTC heartbeat

Local COLMAP CUDA 4.2.1 / RTX 4070 SUPER, zero paid calls, **$0** this tick.
Source: frozen `sfm-calibrated-doorway-v1/sparse/0` and withheld Proton video
samples in the ingestion workspace. The model hashes, per-frame results,
source paths and artifact hashes are recorded in
[`heartbeat-20260929T2035/provenance.json`](../../docs/evidence/collection-reconstruction/heartbeat-20260929T2035/provenance.json)
and its `audit.json`. Generator sources are `calibrated_audit.py` and
`doorway_geometry.py` beside the existing reconstruction prototype helpers.

49/69 held-out views meet the original support rule; 46/69 pass the disjoint
fit/test point diagnostic. The corrected 61-view CUDA depth trial fused 19,815
points. The casing-plane surface trial **failed**, including a 0.501 provisional
metre corner/floor discrepancy. Images are diagnostic evidence, not runtime
textures, accepted geometry, collision surfaces or a completed museum map.
Bookcase scale remains provisional; the independent canvas trial found no
supported views. Existing Muse receipts and never-resubmit flags are unchanged.
