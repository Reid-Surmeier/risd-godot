Blind visual review — refined museum candidates

Verdict: NOT-EXACT.

Scope: I inspected only the supplied target, the two candidate screenshots, and the separate lighting reference. No code or earlier review was consulted. The lighting reference was used only for the handling of illuminated and shaded white surfaces and the appearance of baked illumination; its room design is not a target. These stills provide no audio evidence.

Measurements
Coordinates are approximate visual measurements in native screenshot pixels, with an uncertainty of roughly 5–10 pixels for the large target and 2–4 pixels for the candidates. Active viewport means the scene inside the decorative frame, excluding frame, desktop, video controls, and surrounding page. Character height means the central human avatar from head/hat to soles, excluding its floor shadow. The target play button partly obscures the head.

Target screenshot: 3508 × 2269. Active viewport approximately x=160–3213, y=113–1920: 3053 × 1807. Central avatar top approximately y=970, soles y=1565: height approximately 595 pixels, or 32.9% of active height. Soles are approximately 80.4% down the active viewport, leaving 19.6% below. Avatar horizontal center is approximately 47.5% across the active viewport.

01-dollhouse-baked.png: 1920 × 1080. Active viewport approximately x=644–1347, y=210–679: 703 × 469. Avatar top approximately y=432, soles y=582: height approximately 150 pixels, or 32.0% of active height. Soles are approximately 79.3% down the active viewport, leaving 20.7% below. Horizontal center is approximately 50.1% across.

04-other-wall.png: same viewport and approximately the same character measurements as 01. The different wall does not visibly disrupt character scale or screen placement.

Interpretation: character scale and vertical feet placement are close. The candidate is about one percentage point smaller in viewport height and its feet about one percentage point higher. That is not the main remaining mismatch. The active scene aspect ratio differs: approximately 1.69 in the target versus 1.50 in the candidates. The scene occupies approximately 87% of screenshot width in the target versus 37% in the candidate desktop screenshots; comparisons must therefore normalize to the active viewport rather than the entire screenshot.

Three largest remaining gaps

1. Room depth and camera composition. The target has a strongly readable dollhouse interior: receding side walls, a high downward view, and floor extending between and around room objects. Both candidates show a frontal strip of wall and an open floor wedge. The small avatar alone cannot establish the same room depth. Keep the museum and its collection, but its room geometry and camera currently convey a shallow gallery stage more than the target’s inhabited miniature room.

2. Material frequency. The parquet is a dense field of fine diagonal stripes, especially conspicuous on the brighter other-wall view. It competes with the avatar and paintings instead of reading as the broad, softly filtered surface shapes in the target. A fine regular raster texture is also visible across the screenshot/frame. There is no single giant grid dominating the scene, but the high-frequency floor pattern still prevents a convincing soft Animal Crossing material treatment. Paintings are comparatively soft and remain legible.

3. Lighting shape and white-face separation. The first view has soft warm floor variation and wall illumination, but the dark gray/olive wall pools look mottled, while the other-wall floor becomes broadly pale rather than clearly separated warm local pools. The narrow pale baseboard offers little bright-face/shaded-face modeling. The lighting-only reference has distinctly different values on illuminated and shaded white architectural faces, with coherent broad shading. The candidates need that readable face separation and more intentional pool placement, without copying the reference room.

Useful qualities and regression limits

The avatar’s normalized size, feet position, large head, and grounded soft shadow are useful and already close to the target’s placement. Both candidate views retain identifiable museum art and show different wall collections with a visible “Other wall” control. That supports the presence of two views, but screenshots cannot prove click behavior, walking access, or that every painting can be reached.

I cannot call any change an improvement or a regression relative to an unseen previous implementation. Within these two supplied states, the brighter other-wall floor makes the fine parquet pattern more conspicuous and flattens the sense of localized light; the first view has stronger floor light/shade separation. The screenshots support a useful visual direction, not an exact-match signoff.
