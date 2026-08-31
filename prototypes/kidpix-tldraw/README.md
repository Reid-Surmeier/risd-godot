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

Variant D is a separate UI question: whether the book works better as the only content inside pale-blue Japanese game-style window chrome. It uses the smooth v005 Qwen candidate, keeps the pencil cursor and page flip, removes every Sketchbook editing control, and places neutral previous/next buttons in a footer outside the paper. The original owner screenshot is stored only as a source reference; none of its icons, labels, skill grid, statistics, or game assets are reused.

Variant E asks a different layout question: whether keeping the selected museum-object viewer directly above the drawing window improves reference drawing. Its top panel is a deterministic crop of the owner-supplied composition reference; the lower window reuses D's pencil-only bounded book, center gutter, and external page navigation. Both panels remain static, in-memory prototype evidence rather than production application structure.

The v005 base image has no baked-in pencil because the live pencil cursor supplies the tool. Its layered paper perimeter and recessed center gutter remain visible below and above the transparent tldraw surface. The raw v005 image is pending owner approval.

Variants D and E display `sketchbook-page-v005-soft-384.png`, a versioned 384×384 Lanczos derivative of the untouched 1024×1024 candidate. Only 32 px of empty exterior margin is removed from each source edge before downsampling; every page edge and corner remains visible. The utility windows are sized around the square book so it leaves only a narrow white ridge at the fitted 100% view. Compact footer controls zoom the complete book, drawing surface, gutter, and page-turn geometry together to 125% or 150%. Exact crop, resize, and hash provenance is recorded beside the derivative.

## Selected Sketchbook surface and page turn

Variant A places a transparent tldraw surface over the two cream page interiors in the raw Qwen v004 candidate. The exterior white field, stacked paper edge, and center seam remain visible generated pixels. Pointer input is structurally limited to the page hitbox, so dragging on the surrounding field or outer paper edge cannot create a shape.

The **Previous spread** and **Next spread** controls run an independently authored 520 ms, two-face CSS paper turn. Its front, back, underlay, and moving edge reuse the existing hash-locked book image rather than adding a separately generated animation asset. Every numbered spread is a native tldraw document page: a new spread starts blank, and returning to an old spread restores its drawing for the current browser session. Reduced-motion mode swaps spreads immediately. The behavior research and source/license constraints are recorded in [`docs/research/internet-archive-page-flip.md`](../../docs/research/internet-archive-page-flip.md).

`public/sketchbook-page-v004.png` is byte-identical to the Qwen run artifact. Its SHA-256, OpenRouter model, output count, cost estimate, and pending owner-approval state are recorded in `public/sketchbook-page-v004.provenance.json`. It is a prototype candidate, not an approved final asset.

## Qwen opening and pencil scale

Variant C begins with the complete Qwen Sketchbook v003 final, then crossfades into the blank page. **Replay opening** shows it again. `public/sketchbook-final.png` is byte-identical to the approved source; its generation record and SHA-256 are in `public/sketchbook-final.provenance.json`.

The Pencil slider changes only the cursor artwork from 96–240 px. The default is 160 px. Brush thickness remains a separate Stroke control, and resizing the cursor does not move its fixed graphite-tip hotspot.

The former cursor offset was caused by placing a `position: fixed` cursor inside the book stage's CSS `perspective` containing block. Perspective now lives on the temporary flipping page transform, so the visible graphite tip stays on the viewport pointer while the page turn retains its 3D hinge.

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
