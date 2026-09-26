# Painting Cover Flow viewer

Issue [#127](https://github.com/Reid-Surmeier/risd-godot/issues/127). Standalone browser interaction for the approved blue window: six real RISD paintings, white floor and soft shadows. This is not yet embedded into the Godot app.

Run from the repository root:

```sh
python3 -m http.server 8137 --bind 127.0.0.1 --directory prototypes/painting-coverflow/web
```

Publish that port with the share skill for remote access. Scroll, drag/swipe, click a side painting, use arrow keys or the slider. Click the center painting or View painting to enlarge it; Escape closes. Home/End reach the ends. Reduced-motion users get immediate selection updates.

`web/paintings.json` reuses the existing `risd-3dscans` catalog; it is a six-painting snapshot, not a live search of the whole collection. Museum images are unchanged local copies so navigation does not depend on cross-origin API calls. Original URLs, hashes and catalog revision are recorded in `PROVENANCE.json`. Two catalog entries visibly depict drawings and were excluded. Some existing source links go to the collection landing page rather than an individual object.

The supplied window PNG is used as a CSS border image; no frame or painting pixels were generated or rewritten. Native CSS transforms rotate and translate cards; a critically damped spring gives interruptible motion. Each card owns its floor shadow. Native dialog, buttons and range input provide keyboard and accessibility behavior.

Rebuild after a controller edit (the repository already pins Effect):

```sh
bun build prototypes/painting-coverflow/viewer.ts --target browser --minify --outfile prototypes/painting-coverflow/web/viewer.js
```

Browser acceptance uses an existing Playwright installation: `PLAYWRIGHT_MODULE=/path/to/playwright/index.mjs CHROMIUM_PATH=/path/to/chrome node prototypes/painting-coverflow/acceptance.mjs`. Those variables are optional when Playwright and its browser are installed in the normal locations. `VIEWER_URL` overrides the local test address. Screenshots land in `evidence/`. The motion research records the Apple video inspected before implementation.
