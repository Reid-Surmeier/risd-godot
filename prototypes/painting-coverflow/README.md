# Painting Cover Flow viewer

Issue [#127](https://github.com/Reid-Surmeier/risd-godot/issues/127). Standalone browser interaction for the approved blue window: six real RISD paintings, white floor and soft shadows. The native Sketchbook integration is described below.

Run from the repository root:

```sh
python3 -m http.server 8137 --bind 127.0.0.1 --directory prototypes/painting-coverflow/web
```

Publish that port with the share skill for remote access. Scroll, drag/swipe, click a side painting, use arrow keys or the slider. Click the center painting to enlarge it; Escape closes. Home/End reach the ends. Reduced-motion users get immediate selection updates.

`web/paintings.json` reuses the existing `risd-3dscans` catalog; it is a six-painting snapshot, not a live search of the whole collection. Museum images are unchanged local copies so navigation does not depend on cross-origin API calls. Original URLs, hashes and catalog revision are recorded in `PROVENANCE.json`. Two catalog entries visibly depict drawings and were excluded. Some existing source links go to the collection landing page rather than an individual object.

The supplied window PNG is used as a CSS border image; no frame or painting pixels were generated or rewritten. Native CSS transforms rotate and translate cards; a critically damped spring gives interruptible motion. Each card owns its floor shadow. Native dialog, buttons and range input provide keyboard and accessibility behavior.

Rebuild after a controller edit (the repository already pins Effect):

```sh
bun build prototypes/painting-coverflow/viewer.ts --target browser --minify --outfile prototypes/painting-coverflow/web/viewer.js
```

Browser acceptance uses an existing Playwright installation: `PLAYWRIGHT_MODULE=/path/to/playwright/index.mjs CHROMIUM_PATH=/path/to/chrome node prototypes/painting-coverflow/acceptance.mjs`. Those variables are optional when Playwright and its browser are installed in the normal locations. `VIEWER_URL` overrides the local test address. Screenshots land in `evidence/`. The motion research records the Apple video inspected before implementation.

Issue #128 removes the caption row and arrow buttons. The transparent 3D scene ignores pointer hits while painting buttons explicitly accept them, so the visible faces remain clickable. Browser acceptance covers center-face clicks on both side paintings.

## Embedded in Sketchbook (#129)

The native counterpart is `modules/sketchbook/painting_flow.gd`, sharing this catalogue and these original images. It participates in the actual Sketchbook desktop’s dragging, stacking and tab lifecycle. The book’s original texture now appears without outer chrome, retaining its edge shadow, drawing and page turns.

Current export: `build/web/2728281-dirty.html` in the `build/integrated` checkout. It is based on gallery-walk `84604cb`, a descendant of the owner’s `743907e` reference, with the Cover Flow changes applied. The original animated boot loader, gallery walk, seven tabs, sounds, desktop icons and current layout remain present.

Tailnet: https://windows-wsl.taile06c45.ts.net/sketchbook-coverflow-01a0df0c/2728281-dirty.html (open Sketchbook after loading). This supersedes the earlier export from `build/v0.1.0`; the old share now serves the corrected current build. The app uses the existing split boot/game pack exporter and original loading HTML. The new painting viewer uses the current Shell’s window shadow; the book retains its original baked shadow. No unrelated dirty files were moved from the older checkout.

Run `modules/sketchbook/playtest/coverflow.mjs` as described in the Sketchbook module document. Current evidence: `evidence/integrated/`; `evidence/native/` records the superseded older-base prototype. The updated acceptance check requires the loading animation to advance and exit before exercising the seven-tab build and Sketchbook controls. No new generation spend.
