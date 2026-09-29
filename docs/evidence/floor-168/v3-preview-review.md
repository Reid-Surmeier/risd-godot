# Independent image-only preview review — GPT-6 Astra, medium

PASS for the preview gate. Inspected all eight new preview PNGs and four controlled native before images, using the previously inspected browser controls and gallery references.

| Criterion | Verdict | Evidence |
|---|---|---|
| Source fidelity,720 gameplay | PASS | Pale oak, varied board tones, and clear herringbone read consistently in native and browser views. |
| Source fidelity,1600 detail | PASS | Curved grain and irregular streaks now give foreground boards recognizable wood character, resolving the earlier uniformly striped appearance. |
| Grain/repetition | PASS | Some similar cathedral-grain motifs recur, but no conspicuous repeating tile or matching blocks dominate these views. Grain is more pronounced than in the reference photos; this remains a limitation rather than a blocker. |
| Joins/contact | PASS | Board joins meet cleanly without black separator contamination. Bench feet, under-bench shadow, baseboards, and doorway all meet the floor plausibly. |
| Painting/trim preservation | PASS | Matched controls preserve the painting subjects and frames, doorway, and baseboards in both renderers. Controlled native images resolve the earlier frame discrepancy. |

Native captures remain softer than browser captures across the whole scene. These stills do not establish motion stability, and this verdict applies only to the supplied preview—not the pending saved-bake evidence.

## Follow-up technical correction

The initial final-bake attempt emitted OpVectorExtractDynamic unsupported from the offline renderer. Its owned child was terminated; the existing bake runner restored the previous assets and project settings. Crop lookup now uses explicit branches with identical row values. A fresh bake is running; no pass is inferred from the preview.
