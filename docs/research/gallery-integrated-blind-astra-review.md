# Blind Astra review of integrated red-cap gallery

Source: anonymous media review of exported runtime `c601383`, before the later directional head-turn fix. Reviewer inspected only the two supplied Animal Crossing reference images and the integrated default-route entry, white-room, and real-input motion captures in `docs/evidence/gallery-display-finish/integrated-input/`. Verdict and observations below are the reviewer’s, not a signoff.

**Verdict: No—recognizably Animal Crossing-inspired, but not yet convincingly “being in Animal Crossing in a museum.”** The proportions and grounding work better than the lighting, material cohesion, and character animation.

I could not save `/tmp/gallery-final-character-blind-report.md`: this session permits filesystem reads only. The report follows.

**Inspection scope**

Only the six named media were inspected. The museum reference was treated as a lighting/material reference, not a layout requirement. I examined the supplied 720-wide screenshot directly, the larger screenshots, and decoded motion sequences, including closely spaced turn/reversal frames. Small-size comparisons used an approximately 324 × 216 play area matching the embedded screenshot. Motion findings concern sampled frame progression, not real-time playback feel.

**Character observations**

The character is appropriately prominent. In `entry.png`, its roughly 125-pixel height occupies about one-third of the inner scene height; in `white-720.png`, it remains approximately 70 pixels tall. That is broadly compatible with the house reference’s large, readable player character. It is not too small merely because the surrounding desktop occupies much of the screenshot. Placement is centered horizontally and below the scene midpoint, leaving useful room ahead.

Foot-ground contact is credible overall. The boots meet a compact, soft shadow in `white.png` and `white-720.png`; I see no persistent, conspicuous gap beneath the standing character. Walking frames show alternating feet and changing leg silhouettes. The shadow helps grounding, although its soft dark lobes communicate less precise sole contact than the character’s crisp outline.

The character has real visual volume: profile and rear views reveal head depth, separate arms, a projecting torso, and distinct boots. It does not read as a flat billboard. However, much of that volume comes from silhouette and overlap rather than convincing surface shading.

**Remaining visible defects, ranked**

1. **The room and character do not share a convincing lighting treatment.**
   **Evidence:** `entry.png`; clip approximately **0–9.1 seconds** versus **9.6–12.4 seconds**; `white.png`.
   The gallery gives the skin, shirt, boots, and floor a broadly muddy brown darkness. In the white room, skin becomes very pale and the shirt’s light bands lose much of their shading. The cap remains a comparatively flat maroon patch in both. The references retain clearer separation between illuminated surfaces, shaded forms, and materials. There is an observable room-dependent brightness change, but that alone does not establish a convincing baked-light appearance. The white fade visible around **9.4 seconds** is a transition, not evidence of an instantaneous lighting fault.

2. **The doorway threshold has conspicuous broken white markings.**
   **Evidence:** `entry.png`; clip **0.033, 3.967, and 9.033 seconds**.
   Besides the central white directional triangle, thin white fragments and irregular strips interrupt the brown threshold. These remain visible at embedded size and make the floor/door junction look unfinished. The images establish the appearance, not whether its cause is geometry, texture, or something else.

3. **The head and cap look materially flatter than the reference character.**
   **Evidence:** `white.png`, `white-720.png`; clip **2.400–2.667** and **10.700–11.167 seconds**.
   The cap reads predominantly as a broad colored disk with a dark lower band. The pale head and hands have little readable tonal modeling at the smaller size. The house reference’s hair, head, clothes, and shoes have stronger rounded light-to-dark transitions. The new character has depth, but often resembles assembled simple shapes rather than one softly modeled figure.

4. **Turns blend through intermediate orientations, but the upper body remains stiff.**
   **Evidence:** clip **2.200–2.800**, **3.767–4.167**, and **10.633–11.167 seconds**.
   These sequences show progressive rotation rather than a single front/back pose swap. Feet alternate and hands swing, so the animation is visibly functioning. However, the head closely follows the torso’s heading, and the round hands swing with little readable independent gesture or settling. The overall impression is a turning toy with cycling limbs. I cannot establish a precise foot-sliding defect from these samples.

5. **The display texture does not convincingly unify the scene.**
   **Evidence:** `entry.png`, `white-720.png`, and embedded-size clip samples.
   The ornamental surround has conspicuous fine texture, while the interior mixes detailed paintings and parquet with broad, nearly untextured character and wall surfaces. At embedded size, the room reads as softened contemporary 3D more than a cohesive older-console image. The museum reference integrates painting detail, architectural shading, and image softness more consistently.

**Not assessable**

These media cannot establish whether lighting is actually baked, input latency, reliable frame pacing, animation implementation, or console-specific rendering behavior. Fine fingers, eye movement, and subtle head settling are not reliably readable at embedded size. The white room’s intended purpose is unknown, so its lack of exhibits is not itself counted as a defect. Compression, scaling, and capture effects prevent attributing softness, pixel patterns, or edge artifacts to GameCube hardware.
