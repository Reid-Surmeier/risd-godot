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

## Five-second failure diagnosis

The former static HTTPS share was reproduced deterministically: one stroke committed, the editor disappeared after five seconds, and a second stroke was rejected. The cause is tldraw's production-license enforcement, not network loss, pointer interception, or a stroke-state leak. In tldraw 5.3.2, `LicenseProvider` schedules the unlicensed production editor to hide after `LICENSE_TIMEOUT = 5000`.

The compliant prototype fix is to serve the Vite development build over the tailnet. It remains a development environment even when the audited share supplies HTTPS. No license check is removed, patched, or spoofed. A production deployment requires a valid trial, hobby, or commercial key under tldraw's [current licensing terms](https://tldraw.dev/community/license).

Regression coverage now proves that the full generated opening loads, a second stroke commits after a 12-second dwell, and 50 strokes commit without the editor disappearing. The same three checks can run against a remote share by setting `PLAYWRIGHT_BASE_URL`.

## Generated-source continuation

The complete Qwen Sketchbook v003 final is imported byte-identically as `prototypes/kidpix-tldraw/public/sketchbook-final.png`, SHA-256 `95828700b6b679c70cc1fefee01d1670d6a96e650f5ee22836bb649e44905ace`. It is shown as the opening state and only positioned, scaled, and faded through CSS. This continuation made zero model requests and incurred zero new generation cost.
