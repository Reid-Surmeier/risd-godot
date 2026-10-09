# Independent Viewer image review — September 29

GPT-6 Astra, medium; fresh context, images only. References: `modules/sculpture_viewer/assets/setup/panel-2x.png`, scans `20260811121459-front.png` and `20260811122415-front.png`. Candidates: `docs/evidence/scan-windows-192/web/before.png`, `adjusted.png`, `portrait.png`, runtime `8694316e`. Reviewer received no code, rationale or earlier verdicts.

- **Artwork/scan identity — PASS.** Before clearly matches the terracotta figure seated among skulls. Adjusted shows a darker rear-facing view consistent with that sculpture, though a front reference cannot verify rear details. Portrait recognizably matches the tall carved stone relief, including arched top and stepped base. Pink museum lettering, object imagery and retro chat panels retain reference identity.
- **Proportions — PASS for visible states.** Sculptures retain plausible proportions at different viewer sizes; collection objects/chat panels show no obvious stretching. Portrait preserves overall desktop proportions through scaling and white margins.
- **Readability — FAIL at supplied portrait size.** Catalogue labels, object information, chat text and player controls are too small to read reliably. Square captures retain readable primary navigation/major controls, but catalogue captions and descriptive text are already very small.
- **Containment — PASS with overlap caveat.** Visible geometry stays inside the player without apparent clipping; windows remain inside the desktop. Moved chat panels overlap the lower catalogue and obscure some content. Stills cannot establish whether this overlap was intended.
- **Interactions/motion — NEEDS-EVIDENCE.** Distinct rendered states cannot establish dragging, resizing, rotation continuity, controls or restoration. No other obvious image defect observed.

## Scope disposition, separate from blind findings

#173 requires uniform scaling of a fixed square, including narrow portrait viewports; #192 allows user-adjusted proportions and overlapping retained windows. The source layout is not silently reflowed to address this finding. #192's native/browser interaction packet separately verifies input; it does not turn the image review into motion acceptance. Readability and continuous motion remain explicit #162 limits requiring owner disposition or a scoped correction. No full-build owner approval is inferred.
