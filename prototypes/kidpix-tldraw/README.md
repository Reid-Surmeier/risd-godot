# RISD Sketchbook tldraw prototype

Throwaway primary-source prototype for [Prototype: choose the RISD Sketchbook drawing contract](https://github.com/Reid-Surmeier/risd-godot/issues/16).

Question: which of three drawing surfaces should define the later native Godot interaction contract?

- `A` — faithful Kid Pix fixed canvas
- `B` — modern tldraw studio
- `C` — hybrid RISD floating Sketchbook window, the default

Run from the repository root:

```bash
npm run prototype:kidpix
```

Then open `/?variant=A`, `/?variant=B`, or `/?variant=C`.

Verify the interaction contract through Chromium:

```bash
npm run prototype:kidpix:test
```

The browser suite covers mouse and synthesized touch drawing, cursor hotspot alignment, real Draw-shape commits, functional eraser/undo/clear/color/thickness controls, window dragging, variant routing, in-memory reset, a 12-second dwell regression, and a 50-stroke endurance run.

## Qwen opening and pencil scale

Variant C begins with the complete Qwen Sketchbook v003 final, then crossfades into the blank page. **Replay opening** shows it again. `public/sketchbook-final.png` is byte-identical to the approved source; its generation record and SHA-256 are in `public/sketchbook-final.provenance.json`.

The Pencil slider changes only the cursor artwork from 96–240 px. The default is 160 px. Brush thickness remains a separate Stroke control, and resizing the cursor does not move its fixed graphite-tip hotspot.

To change the allowed scale in code, edit the `min`, `max`, `step`, and initial `pencilSize` values in `src/App.tsx`. The CSS animations live in `src/styles.css`: `pencil-hover`, `pencil-press`, `spark-spin`, `window-arrive`, and `opening-sequence`. Every nonessential animation is disabled by `prefers-reduced-motion`.

## Tailnet development share

tldraw 5.3.2 hides an unlicensed production build after five seconds. Do not disable that check and do not use the static `dist` directory as the live evaluation surface. Serve the Vite development build through the audited tailnet share instead:

```bash
npm --prefix prototypes/kidpix-tldraw run dev -- --host 0.0.0.0 --port 4173
python3 ~/agentic-workflow/scripts/share.py 4173 --label risd-sketchbook-qwen --reason "Review the Sketchbook interaction" --keep 3d
VITE_SHARE_BASE=/<printed-share-path>/ npm --prefix prototypes/kidpix-tldraw run dev -- --host 0.0.0.0 --port 4173
```

Use the first server only long enough for the share tool to probe port 4173, then stop it and restart with `VITE_SHARE_BASE`. That value must match the path printed by the share command. The development server remains visibly marked as a throwaway prototype and retains tldraw's development-use contract.

This code is intentionally disposable. It stores drawings only in memory, uses tldraw only for development evaluation, and must not be promoted directly into the Godot product.

The pencil PNG is prototype-only derived evidence from Qwen Sketchbook v003. Its source identity and derivation are recorded in `public/pencil-prototype.provenance.json`. It is not a certified RISD Icon or Motion Pass.
