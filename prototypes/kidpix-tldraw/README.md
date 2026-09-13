# RISD Sketchbook tldraw prototype

Throwaway primary-source prototype for [Prototype: choose the RISD Sketchbook drawing contract](https://github.com/Reid-Surmeier/risd-godot/issues/16).

Question: which of three drawing surfaces should define the later native Godot interaction contract?

- `A` — generated open-Sketchbook drawing surface, the selected default
- `B` — modern tldraw studio
- `C` — hybrid RISD floating Sketchbook window
- `D` — smooth Moleskine-style Sketchbook inside a Japanese game utility window
- `E` — museum-object reference viewer above the live Sketchbook window

Run from the repository root:

```bash
npm run prototype:kidpix
```

Then open `/?variant=A` through `/?variant=E`.

Verify the interaction contract through Chromium:

```bash
npm run prototype:kidpix:test
```

The browser suite covers the v004 image hash and dimensions, drawing clipped to the cream page interior, persistent per-spread page turns, absence of the removed sparkle, mouse and synthesized touch drawing, cursor hotspot alignment, real Draw-shape commits, functional eraser/undo/clear/color/thickness controls, window dragging, variant routing, a CDN-blocked editor mount, a 12-second dwell regression, and a 50-stroke endurance run. Headless Chromium runs with GPU rasterization disabled because its SwiftShader path deadlocks while painting tldraw on this WSL host; Firefox and ordinary interactive browsers do not need that test-only flag.

Variant D follows the September 8 owner desktop layout: museum objects, the large head reference and statue player across the top; a calligraphy palette, the live Sketchbook and chat beneath. The four supplied panels are static images, copied unchanged with hashes in `public/desktop-panels.provenance.json`. Only the head portion of the existing reference is displayed, using CSS clipping. The desktop and book scale their layout dimensions together to fit the browser width and height, retaining the 4:3 fitted spread and panel arrangement. Browser resizing refits the desktop; the book grip and zoom controls still allow deliberate enlargement. Variant D has no prototype switcher or reserved bottom strip. Its window chrome is the owner's Ragnarok-style equipment window reference, cut as a 9-slice from the reference bytes (`public/ro-*.png`): title bar with gem, minimize and close, the purple and cyan border, and the two button frames are untouched reference pixels. Only the word "Sketchbook" and the "<" / ">" glyphs came from Muse region edits, composited back onto the reference at its own 1x grid with zero changed pixels outside the declared text regions; run IDs, regions, hashes and the fidelity counts are in `public/window-chrome.provenance.json`. The chrome renders 1:1 at the reference's own pixel size whatever the window width, as in the owner's trade-window reference; widening only tiles the bar and edges. D has no spread counter or zoom controls. The book retains drawing, resize and independent spreads; the image panels do not implement chat, playback or palette controls.

Variant E asks a different layout question: whether keeping the selected museum-object viewer directly above the drawing window improves reference drawing. Its top panel is a deterministic crop of the owner-supplied composition reference; the lower window reuses D's pencil-only bounded book, center gutter, and external page navigation. Both panels remain static, in-memory prototype evidence rather than production application structure.

The v005 base image has no baked-in pencil because the live pencil cursor supplies the tool. Its layered paper perimeter and recessed center gutter remain visible below and above the transparent tldraw surface. The raw v005 image is pending owner approval.

Live tldraw marks use a deterministic SVG displacement map that stays flat across the outer page regions and bows gently toward the center binding. Page navigation exports the outgoing tldraw viewport to a transparent one-pixel-ratio PNG before animation and places the correct half on both faces of the moving sheet, so populated spreads remain visible during forward and backward turns.

Variants D and E display `sketchbook-page-v005-soft-384.png`, a versioned 384×384 Lanczos derivative of the untouched 1024×1024 candidate. Only 32 px of empty exterior margin is removed from each source edge before downsampling; every page edge and corner remains visible. The stage widens that source into a 4:3 open spread so each page has more horizontal drawing room. A resize observer refits the complete spread against both content dimensions whenever the utility window is resized, leaving only a narrow white ridge at 100%. Compact footer controls zoom the complete book, drawing surface, gutter, and page-turn geometry together to 125% or 150%. Exact crop, resize, and hash provenance is recorded beside the derivative.

## Selected Sketchbook surface and page turn

Variant A places a transparent tldraw surface over the two cream page interiors in the raw Qwen v004 candidate. The exterior white field, stacked paper edge, and center seam remain visible generated pixels. Pointer input is structurally limited to the page hitbox, so dragging on the surrounding field or outer paper edge cannot create a shape.

The **Previous spread** and **Next spread** controls run an independently authored 520 ms, two-face CSS paper turn. Its front, back, underlay, and moving edge reuse the existing hash-locked book image rather than adding a separately generated animation asset. Every numbered spread is a native tldraw document page: a new spread starts blank, and returning to an old spread restores its drawing for the current browser session. Reduced-motion mode swaps spreads immediately. The behavior research and source/license constraints are recorded in [`docs/research/internet-archive-page-flip.md`](../../docs/research/internet-archive-page-flip.md).

`public/sketchbook-page-v004.png` is byte-identical to the Qwen run artifact. Its SHA-256, OpenRouter model, output count, cost estimate, and pending owner-approval state are recorded in `public/sketchbook-page-v004.provenance.json`. It is a prototype candidate, not an approved final asset.

## Qwen opening and pencil scale

Variant C begins with the complete Qwen Sketchbook v003 final, then crossfades into the blank page. **Replay opening** shows it again. `public/sketchbook-final.png` is byte-identical to the approved source; its generation record and SHA-256 are in `public/sketchbook-final.provenance.json`.

The Pencil slider changes only the cursor artwork from 96–240 px. The default is 160 px. Brush thickness remains a separate Stroke control, and resizing the cursor does not move its fixed graphite-tip hotspot.

The pencil is rendered in a React portal directly under the document body, outside the book's filters, transforms, and clipping. Its graphite tip is the rotation/press origin. Pointer coordinates update the cursor element directly; only changes to pointer visibility, pressure, or button state update the diagnostic readout. This keeps hovering out of the workspace render loop and avoids repainting the filtered book just to move the pencil. The gutter curvature and page-turn drawings remain unchanged. At pointer-down, the editor refreshes its screen bounds once so scrolling or resizing immediately before drawing cannot start a stroke at the previous canvas position.

To change the allowed scale in code, edit the `min`, `max`, `step`, and initial `pencilSize` values in `src/App.tsx`. The CSS animations live in `src/styles.css`: `pencil-hover`, `pencil-press`, `paper-turn-forward`, `paper-turn-backward`, `page-underlay-reveal`, `window-arrive`, and `opening-sequence`. Every nonessential animation is disabled by `prefers-reduced-motion`.

## Tailnet development share

tldraw 5.3.2 hides an unlicensed production build after five seconds. Do not disable that check and do not use the static `dist` directory as the live evaluation surface. Serve the Vite development build through the audited tailnet share instead:

```bash
npm --prefix prototypes/kidpix-tldraw run dev -- --host 0.0.0.0 --port 4173
python3 ~/agentic-workflow/scripts/share.py 4173 --label risd-sketchbook-qwen --reason "Review the Sketchbook interaction" --keep 3d
VITE_SHARE_BASE=/<printed-share-path>/ npm --prefix prototypes/kidpix-tldraw run dev -- --host 0.0.0.0 --port 4173
```

Use the first server only long enough for the share tool to probe port 4173, then stop it and restart with `VITE_SHARE_BASE`. That value must match the path printed by the share command. The development server remains visibly marked as a throwaway prototype and retains tldraw's development-use contract.

The pencil-only editor also replaces tldraw's unused remote UI icon, embed, font, and translation catalogs with an empty local catalog plus a three-byte English fallback. Its mount callback is referentially stable, preventing tldraw 5.3.2 from rerunning the mount effect after every pointer-state update. The prototype therefore keeps drawing when `cdn.tldraw.com` is blocked and after the former timeout window.

This code is intentionally disposable. It stores drawings only in memory, uses tldraw only for development evaluation, and must not be promoted directly into the Godot product.

The pencil PNG is prototype-only derived evidence from Qwen Sketchbook v003. Its source identity and derivation are recorded in `public/pencil-prototype.provenance.json`. It is not a certified RISD Icon or Motion Pass.
