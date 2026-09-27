# Muse character identity: motion-study review

Agent visual review, 2026-09-26. **humanReviewed: false. accepted: false. certified: false.** Suitability: proceed to a bounded motion study, not final runtime acceptance.

Source: `artifacts/image-generation/runs/run-3a63fae0e86ebe17f53fddda/materialized/image-01.webp`, 1600 × 1600 RGB, four 800 × 800 cells. Source was viewed and read for measurements; no pixels were edited. Exact source hash and read-only threshold method are in [identity-measurements.json](identity-measurements.json).

## Visual findings

The four views depict a coherent identity: red folded cap, short brown hair, cream shirt, dark navy shorts, tan legs, brown shoes. The shirt mark stays on the front and disappears on the back. Hat and hair masses largely agree through the two side profiles. Limb placement and the large rounded head are recognizably in the Animal Crossing family. The official [GameCube human references](https://www.nintendo.co.jp/ngc/gaej/game/chara01.gif) support short bodies, oversized heads and simple mitten hands; this candidate is a credible study interpretation, not recovered Nintendo geometry.

**Camera mismatch remains:** these are nearly level front/back/profile views, not convincing 45° downward views. Little top surface is visible on the shoulders/shoes. Using these unchanged in the existing steep gallery camera may retain the “upright cardboard sprite” reading. Supply the actual camera angle to motion generation and inspect the result; do not label this sheet camera-correct.

The head plus cap is about 58% of visible height. Front visible width/height is about 0.673, materially wider than the previous character's 0.471 silhouette ratio. That can be an intentional cartoon identity, but the prior scale/framing constants must be remeasured after replacement. Do not independently stretch each directional crop to one square: the genuine side profile is narrower.

Front and back arms are held slightly away from the torso; side arms hang down. This is a small pose discontinuity rather than proof of a broken identity. A view switch while idle may visibly alter the arm silhouette. The cap's folded tip and exact hair outline also need scrutiny in turns; four plausible stills do not prove a consistent 3D volume. Shading is smooth and clean, somewhat more polished than the low-resolution game capture. Final viewport filtering can reduce detail, but an overlay cannot correct camera or pose inconsistency.

The saturated green background is uniform to the eye, with no cast floor shadow, lettering or surrounding objects. This is useful for matte extraction. RGB output has no native alpha; compressed edge colors require inspection after keying, especially around brown hair, hands and shoes. No green garment is visible.

## Useful bounds

Coordinates below are local to each 800 × 800 cell; x1/y1 are exclusive. Threshold excludes pixels where green >180 and exceeds both red and blue by 1.5×. These are practical matte estimates, not perfect semantic masks.

| View | Cell origin | Visible bounds x0,y0,x1,y1 | Width × height | Bounds centre x | Sole baseline y |
|---|---|---|---|---|---|
| Front | 0,0 | 160,46,643,764 | 483 × 718 | 401.5 | 764 |
| Back | 800,0 | 164,45,648,763 | 484 × 718 | 406.0 | 763 |
| Left | 0,800 | 184,37,609,763 | 425 × 726 | 396.5 | 763 |
| Right | 800,800 | 196,37,621,763 | 425 × 726 | 408.5 | 763 |

Use the complete equal-size 800 × 800 cells as the conservative source anchors: they preserve almost identical baselines and leave room around hands. Baselines differ only one pixel; the side views are about 1.1% taller. For runtime registration, align the floor baseline and body/feet pivot, not each image's head bounding-box centre. The slight ±8.5-pixel centre spread will otherwise cause lateral popping. Side-profile feet project under x≈390 (left) and x≈415 (right), visually estimated, so the head-centre measurement is not a root-motion pivot. Padded optional crops are recorded in JSON but were not created.

## Next motion study

A rear-view in-place walk is suitable for testing identity retention, floor contacts, hand swing, camera stability and the loop seam. A separate front/three-quarter look-and-wave study can test face/head changes and gestures. Do not assume a single rear walk establishes all-direction navigation or independent head/hand control. Check consistency against these exact stills and the supplied real game motion before any acceptance.
