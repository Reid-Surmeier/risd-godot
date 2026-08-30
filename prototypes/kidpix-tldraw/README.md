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

The browser suite covers mouse and synthesized touch drawing, cursor hotspot alignment, real Draw-shape commits, functional eraser/undo/clear/color/thickness controls, window dragging, variant routing, and in-memory reset.

This code is intentionally disposable. It stores drawings only in memory, uses tldraw only for development evaluation, and must not be promoted directly into the Godot product.

The pencil PNG is prototype-only derived evidence from Qwen Sketchbook v003. Its source identity and derivation are recorded in `public/pencil-prototype.provenance.json`. It is not a certified RISD Icon.
