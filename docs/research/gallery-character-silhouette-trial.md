# Visitor shirt silhouette trial

An isolated original-model revision at `gallery-character-silhouette` commit `32d6388` replaces the narrow rounded torso with a boxier short-sleeved striped shirt and adds small thumb contours. It preserves the same cap, face, 41-bone skin, 76 animations, and gallery lighting. The full RTX comparison and native checks remain in that worktree at `docs/evidence/gallery-character-silhouette/README.md`.

An anonymous high-effort still-image review narrowly preferred the fuller candidate (B) over the current model (A) at 1600 and 720 pixels, but called its broad hem barrel-shaped and the gain modest. The side-pose still could not certify moving quality. Native rig/contact checks passed, both exported browser runs completed 480 motion ticks on the RTX renderer, and frame intervals stayed at about 16.7–16.8 ms.

**Decision: keep isolated.** At the embedded size, this small shirt change does not solve the remaining character specificity and light-response gap. The current model remains the default; further minor shirt width changes are not justified by this comparison.
