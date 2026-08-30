# Kid Pix pencil behavior and tldraw prototype research

Date: 2026-08-30

## Decision

Use tldraw 5.3.2 only as the throwaway browser interaction laboratory. Keep the production RISD application native to Godot. The visible pencil is a pointer-following overlay; the actual mark is a tldraw Draw shape.

## Primary-source findings

- tldraw permits development use, but production use requires an appropriate trial, commercial, or hobby license. The prototype must not silently become production code. [tldraw license](https://tldraw.dev/community/license)
- tldraw's Draw tool produces freehand Draw shapes and owns the stroke records needed for the prototype. [Draw shape](https://tldraw.dev/sdk-features/draw-shape)
- tldraw tools receive pointer handlers through its tool state system, while the editor cursor accepts only declared cursor types. A custom artwork cursor is therefore cleaner as a pointer-events-disabled overlay. [Tools](https://tldraw.dev/sdk-features/tools), [cursors](https://tldraw.dev/sdk-features/cursors), [coordinate systems](https://tldraw.dev/examples/coordinate-system)
- JSKidPix's pencil records the start on pointer down, draws connected round segments on movement, and draws the final segment on pointer up. Its CSS declares a bitmap cursor with a `7 16` hotspot. [pencil behavior](https://github.com/vikrum/kidpix/blob/99c67f3427d229f7db60b03dcf19df4d8c2a8ecf/js/tools/pixelpencil.js), [cursor declaration](https://github.com/vikrum/kidpix/blob/99c67f3427d229f7db60b03dcf19df4d8c2a8ecf/css/kidpix.css#L239-L241)
- JSKidPix is treated as GPL-3.0 because its root license says GPL even though package metadata conflicts. No JSKidPix code or archived Kid Pix artwork is copied. [JSKidPix license](https://github.com/vikrum/kidpix/blob/99c67f3427d229f7db60b03dcf19df4d8c2a8ecf/LICENSE)
- KiddoPaint at immutable commit `140ca297683db82daedccae321b519f10f3fde0d` is the cleaner MIT implementation reference if behavior comparison is needed. [KiddoPaint source](https://github.com/vikrum/kiddopaint/tree/140ca297683db82daedccae321b519f10f3fde0d), [license](https://github.com/vikrum/kiddopaint/blob/140ca297683db82daedccae321b519f10f3fde0d/LICENSE)
- Godot can reproduce the selected contract through native GUI input and line rendering. Embedding tldraw would create a second browser-only rendering and input system. [custom GUI controls](https://docs.godotengine.org/en/stable/tutorials/ui/custom_gui_controls.html), [Line2D](https://docs.godotengine.org/en/stable/classes/class_line2d.html)

## Prototype constraints

- No historical Kid Pix binary, image, sound, or cursor asset is included.
- No source is copied from JSKidPix or KiddoPaint.
- The current Qwen pencil is prototype-only and is not a certified RISD Icon.
- No state persists after reload.
