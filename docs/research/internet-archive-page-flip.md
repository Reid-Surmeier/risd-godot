# Internet Archive two-page flip reference

Date: 2026-08-30

## Decision

Recreate the interaction independently; do not embed or copy Internet Archive BookReader code or assets. The useful idea is a **virtual flip**: two rigid page faces rotate around a fixed center seam while the opposite page stays still. Keep the sketchbook image as the visible book, give it persistent outer paper edges and a center seam, and clip each page's drawing surface so no mark can enter the cover, seam, page edges, or surrounding UI.

The source inspection below is pinned to BookReader commit [`18c1983071b2f4a5426fb35467c280ded87653c0`](https://github.com/internetarchive/bookreader/tree/18c1983071b2f4a5426fb35467c280ded87653c0), package version `5.0.0-117`.

## Observable interaction contract

- The supplied URL is a serialized reader state: `page/n7/mode/2up`. The live item declares left-to-right progression and places leaf 7 on the left and leaf 8 on the right. [Exact reader](https://archive.org/details/bub_gb_IigEAAAAMBAJ/page/n7/mode/2up), [live BookReader data](https://ia800603.us.archive.org/BookReader/BookReaderJSIA.php?id=bub_gb_IigEAAAAMBAJ&itemPath=/2/items/bub_gb_IigEAAAAMBAJ&server=ia800603.us.archive.org&format=json&subPrefix=bub_gb_IigEAAAAMBAJ&requestUri=/details/bub_gb_IigEAAAAMBAJ/page/n7/mode/2up), [URL-state format](https://github.com/internetarchive/bookreader/blob/18c1983071b2f4a5426fb35467c280ded87653c0/README.md#L128-L142)
- In a live check, clicking the right page advanced one spread from `n7` to `n9`, and pressing Left returned to `n7`. The source maps both page-side clicks and Left/Right keys to directional turns, resolved according to reading direction. [page click handling](https://github.com/internetarchive/bookreader/blob/18c1983071b2f4a5426fb35467c280ded87653c0/src/BookReader/Mode2UpLit.js#L635-L686), [keyboard handling](https://github.com/internetarchive/bookreader/blob/18c1983071b2f4a5426fb35467c280ded87653c0/src/BookReader.js#L850-L914)
- Thin stacked-page bands remain visible at the outer edges. Hovering identifies a leaf, and clicking jumps to the corresponding leaf; this is separate from clicking a visible page to turn one spread. [leaf-edge renderer and hit mapping](https://github.com/internetarchive/bookreader/blob/18c1983071b2f4a5426fb35467c280ded87653c0/src/BookReader/Mode2UpLit.js#L348-L412), [edge interaction](https://github.com/internetarchive/bookreader/blob/18c1983071b2f4a5426fb35467c280ded87653c0/src/BookReader/Mode2UpLit.js#L689-L785)
- The default turn lasts 400 ms with `ease-in`. BookReader coordinates four animations: book recentering, a moving page-edge strip, the outgoing page rotating from `0°` to `±180°`, and the incoming page rotating from the opposite `±180°` back to `0°`. A second request is ignored while a flip is active. [flip implementation](https://github.com/internetarchive/bookreader/blob/18c1983071b2f4a5426fb35467c280ded87653c0/src/BookReader/Mode2UpLit.js#L495-L630), [default speed](https://github.com/internetarchive/bookreader/blob/18c1983071b2f4a5426fb35467c280ded87653c0/src/BookReader/options.js#L34-L35)
- The visual trick is deliberately simple: hidden backfaces, gutter-side transform origins, `preserve-3d`, z-index staging, and a repeating paper-edge texture. It does not deform or curl a page mesh. [two-page styles](https://github.com/internetarchive/bookreader/blob/18c1983071b2f4a5426fb35467c280ded87653c0/src/css/_BRpages.scss#L103-L235)

## Independent implementation pattern

Use one authoritative `spread_index` and three states: `idle`, `turning_forward`, and `turning_back`. Store ink per leaf, clip it to that leaf's white-paper polygon, and snapshot the two involved leaf surfaces when a turn starts. Swap the authoritative spread only when the motion finishes. BookReader similarly models explicit left/right pages, caches page containers, and pre-renders two neighboring leaves on either side. [spread model](https://github.com/internetarchive/bookreader/blob/18c1983071b2f4a5426fb35467c280ded87653c0/src/BookReader/BookModel.js#L199-L211), [render window](https://github.com/internetarchive/bookreader/blob/18c1983071b2f4a5426fb35467c280ded87653c0/src/BookReader/Mode2UpLit.js#L423-L438)

For React/CSS:

1. Keep static left and right page layers plus temporary outgoing, incoming, and moving-edge layers inside a `perspective` container.
2. For a forward left-to-right turn, hinge the outgoing right page on its left edge and rotate `0 → -180deg`; hinge the incoming left face on its right edge and rotate `180deg → 0`. Reverse signs and sides when turning back.
3. Keep a narrow center-seam overlay fixed above the non-turning pages but below the active page face. Use a restrained seam shadow and outer edge bands; do not add sparkle or particle effects.
4. Disable page input during the 400 ms turn, then atomically replace the visible spread. The drawing canvas remains clipped and should not receive pointer events while its leaf is moving.

For Godot, use the same state machine. A `SubViewport` per leaf can supply a stable ink texture to page-face quads; an `AnimationPlayer` can rotate the active faces around a gutter pivot. A cheaper 2D prototype can fake the hinge with two `scale.x` half-turns and a face swap at zero width. Keep the seam and outer paper-edge controls outside the drawable `SubViewport` so clipping is structural, not merely visual.

## Accessibility and reduced motion

- Preserve real, focusable controls named “Flip left” and “Flip right”; support Left/Right, PageUp/PageDown in two-page mode, and Home/End. BookReader exposes those keyboard routes and uses actual buttons for its controls. [keyboard routes](https://github.com/internetarchive/bookreader/blob/18c1983071b2f4a5426fb35467c280ded87653c0/src/BookReader.js#L850-L914), [button renderer](https://github.com/internetarchive/bookreader/blob/18c1983071b2f4a5426fb35467c280ded87653c0/src/BookReader/Navbar/Navbar.js#L36-L70)
- Announce the new spread after the state swap, not during every animation frame. BookReader gives its page slider ARIA values and conditionally turns the current-page text into a status region for announced changes. [navigation accessibility](https://github.com/internetarchive/bookreader/blob/18c1983071b2f4a5426fb35467c280ded87653c0/src/BookReader/Navbar/Navbar.js#L301-L353)
- The pinned source has no `prefers-reduced-motion` or equivalent detection, and its adapter does not forward the documented `noAnimate` option. Treat that as a gap: when reduced motion is requested, replace the rotation with an immediate spread swap while retaining the same focus, announcement, and page state. [adapter](https://github.com/internetarchive/bookreader/blob/18c1983071b2f4a5426fb35467c280ded87653c0/src/BookReader/Mode2Up.js#L72-L82), [internal non-smooth path](https://github.com/internetarchive/bookreader/blob/18c1983071b2f4a5426fb35467c280ded87653c0/src/BookReader/Mode2UpLit.js#L193-L201)

## License and asset constraints

BookReader is AGPL-3.0. Copying or adapting its implementation would bring the license's modified-work, source-distribution, notice, and network-source-offer obligations; a modified version served over a network must offer its corresponding source to remote users. [package license](https://github.com/internetarchive/bookreader/blob/18c1983071b2f4a5426fb35467c280ded87653c0/package.json#L1-L28), [modified-source terms](https://github.com/internetarchive/bookreader/blob/18c1983071b2f4a5426fb35467c280ded87653c0/LICENSE#L196-L231), [network clause](https://github.com/internetarchive/bookreader/blob/18c1983071b2f4a5426fb35467c280ded87653c0/LICENSE#L540-L559)

The linked *Vibe* item is useful only as a behavior reference here. Its official metadata identifies a September 1993 magazine scan sourced from Google Books but supplies neither a `rights` nor `licenseurl` field. Accessibility on Archive.org is not evidence of an open reuse license, so do not ship its page scans. Use the supplied sketchbook image and independently authored paper-edge/seam treatment instead. [official item metadata](https://archive.org/metadata/bub_gb_IigEAAAAMBAJ)
