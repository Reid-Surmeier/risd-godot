# Kid Pix Deluxe 4 video and source-code research

Date: 2026-08-30

## Answer

The supplied clip depicts the 2004-era Windows release of **Kid Pix Deluxe 4**. It is a strong behavioral reference for the RISD Sketchbook, including its fixed paint zone, contextual tool trays, tool-shaped pointer, whole-canvas effects, library objects, and animation playback. It is not evidence of the original implementation.

I found **no public release of Riverdeep/The Learning Company's original source code** in the primary-source catalogs and repositories checked. I did find a directly relevant community reverse-engineering project, `Open-KidPix-Deluxe`, but it is an unfinished .NET/WPF reimplementation—not leaked or released original source—and it has no license. Treat it as a behavior and file-format research lead only unless its author grants an explicit license.

Rebuilding the interaction cleanly in Godot is feasible. Copying the original program's art, sounds, animation frames, or archived binaries into the RISD application is not the safe route; those materials remain proprietary.

## What the clip is

- YouTube's own metadata names the video **“Kid Pix Deluxe 4 2004 (Old PC game)”**, attributes it to Mis / `@MiseryCakes`, and describes it as “Gameplay of Kid Pix Deluxe 4 2004.” It was uploaded February 16, 2024 and runs 19:36. [YouTube video](https://www.youtube.com/watch?v=sMo-qaZ-_6M), [official YouTube oEmbed metadata](https://www.youtube.com/oembed?url=https%3A%2F%2Fwww.youtube.com%2Fwatch%3Fv%3DsMo-qaZ-_6M&format=json)
- At 0:05, the splash visibly identifies Kid Pix, The Learning Company, and a 2000–2004 Riverdeep copyright. That is direct evidence for the 2004-era product family; the exact “Deluxe 4” label comes from the uploader's first-party metadata rather than a legible version label on this splash. [0:05 splash](https://www.youtube.com/watch?v=sMo-qaZ-_6M&t=5s)
- An archived 2004 Windows/Macintosh CD-ROM record contains a 585,678,848-byte ISO with SHA-1 `8f1a77e002e1fc509f313ea72b8f617578f0131a`. This is an archived **binary distribution**, not source code, and its record supplies no reuse license. [archive record and file manifest](https://archive.org/metadata/kid-pix-deluxe-4)
- The contemporary Kid Pix Deluxe 4 for Schools manual states copyright 2000–2004 Riverdeep Interactive Learning Limited and its licensors, with the respective rights reserved. It documents the same Paint Zone vocabulary and behaviors visible in the clip. [archived product manual](https://archive.org/details/manualzilla-id-6859507)

The video does not establish the exact retail/school/home edition, internal data model, algorithms, file formats, frame timings, or source license. Those require separate evidence.

## Behaviors worth reverse-engineering

| Clip region | Directly observable contract |
| --- | --- |
| [1:00–2:00](https://www.youtube.com/watch?v=sMo-qaZ-_6M&t=60s) | A left vertical tool rail stays fixed while a bottom contextual library swaps complete photo backgrounds, coloring pages, and scene templates. |
| [2:00–8:00](https://www.youtube.com/watch?v=sMo-qaZ-_6M&t=120s) | Drawing and region fills operate on the central page; the bottom tray changes among solid colors, gradients, patterns, and textures; a larger color picker opens over the work. |
| [8:45–10:20](https://www.youtube.com/watch?v=sMo-qaZ-_6M&t=525s) | Whole-canvas effects recolor, emboss, monochrome, warp, and ripple the current image. |
| [9:45–15:00](https://www.youtube.com/watch?v=sMo-qaZ-_6M&t=585s) | Category trays place repeated clip-art/stamp imagery, while brush presets create spirals, icicles, rainbow paths, and dense repeated marks. |
| [15:00](https://www.youtube.com/watch?v=sMo-qaZ-_6M&t=900s) | Textured freehand strokes remain responsive over a photographic background. |
| [17:30](https://www.youtube.com/watch?v=sMo-qaZ-_6M&t=1050s) | Four drawing media, size dots, freehand/line modes, and filled/outline shapes appear together; the active cursor is a small tool-shaped crayon or pencil rather than a system arrow. |
| [18:40 onward](https://www.youtube.com/watch?v=sMo-qaZ-_6M&t=1120s) | A dark object-animation stage exposes category libraries, play/stop controls, independent illustrated objects, and visible transform/animation handles. |

The product manual independently describes four drawing tools—Pencil, Chalk, Crayon, and Marker—with size and shape modes; realistic and “wacky” paint; moving spray objects; movable/resizable stickers; and animations that move during page playback. This makes the manual a better behavior specification than guessing from individual frames. [archived product manual](https://archive.org/details/manualzilla-id-6859507)

## Source-code finding

### Exact-version community reverse engineering

[`JDrocks450/Open-KidPix-Deluxe` at commit `10d59b574b088778e112cffe1c5cd6ba3f25a20f`](https://github.com/JDrocks450/Open-KidPix-Deluxe/tree/10d59b574b088778e112cffe1c5cd6ba3f25a20f) describes itself as a preservation project for Kid Pix Deluxe 4. The repository contains C#/.NET 9 WPF application code, canvas/brush code, and importers for the program's Mohawk `MHK` resources.

This repository is useful for three narrow questions:

- It records a stroke as a start/current position, interpolates continuous pencil motion, and commits the stroke when input ends. [community canvas implementation](https://github.com/JDrocks450/Open-KidPix-Deluxe/blob/10d59b574b088778e112cffe1c5cd6ba3f25a20f/KidPix.API.AppService/Render/KidPixArtCanvas.cs#L67-L131)
- Its UI animation adapter supports loop, reverse-loop, boomerang, and play-once timelines made from `BMH` frames. The default interval is `1000/15` milliseconds. This is evidence about the reimplementation's design, not proof of the original program's exact timing. [community animation adapter](https://github.com/JDrocks450/Open-KidPix-Deluxe/blob/10d59b574b088778e112cffe1c5cd6ba3f25a20f/KidPix.App/UI/Brushes/KPImageBrush.cs#L171-L199), [playback logic](https://github.com/JDrocks450/Open-KidPix-Deluxe/blob/10d59b574b088778e112cffe1c5cd6ba3f25a20f/KidPix.App/UI/Brushes/KPImageBrush.cs#L276-L381)
- Its pencil, chalk, crayon, and highlighter buttons declare short play-once or boomerang frame ranges, providing a concrete model for animated tool feedback. [community tool-tray declarations](https://github.com/JDrocks450/Open-KidPix-Deluxe/blob/10d59b574b088778e112cffe1c5cd6ba3f25a20f/KidPix.App/UI/Pages/Easel/ToolSubpage.xaml#L105-L128)

It is not a self-contained substitute for the 2004 application:

- It hard-codes `C:\Program Files (x86)\The Learning Company\Kid Pix Deluxe 4\Data\` and imports the original installed `MHK` archives for visible resources. [resource-link code](https://github.com/JDrocks450/Open-KidPix-Deluxe/blob/10d59b574b088778e112cffe1c5cd6ba3f25a20f/KidPix.App/UI/Util/KidPixUILibrary.cs#L25-L38)
- It still declares unsupported bitmap paths and incomplete decompression cases. [24-bit bitmap limitation](https://github.com/JDrocks450/Open-KidPix-Deluxe/blob/10d59b574b088778e112cffe1c5cd6ba3f25a20f/KidPix.API/Importer/Graphics/MHWKBitmapImporter.cs#L57-L68), [dictionary-size limitation](https://github.com/JDrocks450/Open-KidPix-Deluxe/blob/10d59b574b088778e112cffe1c5cd6ba3f25a20f/KidPix.API/Importer/Graphics/Brushes/BMPLZDecompressor.cs#L24-L36)
- The pinned tree has no `LICENSE`, `COPYING`, or equivalent grant, and GitHub's repository-license endpoint returns no license. Source visibility alone does not authorize copying or redistribution. [pinned repository tree](https://github.com/JDrocks450/Open-KidPix-Deluxe/tree/10d59b574b088778e112cffe1c5cd6ba3f25a20f), [GitHub license endpoint](https://api.github.com/repos/JDrocks450/Open-KidPix-Deluxe/license)

### Other code references are different products

- [JSKidPix at `99c67f3427d229f7db60b03dcf19df4d8c2a8ecf`](https://github.com/vikrum/kidpix/tree/99c67f3427d229f7db60b03dcf19df4d8c2a8ecf) is a browser recreation of an older Kid Pix interaction style, not Kid Pix Deluxe 4. Its root license is GPL-3.0, so copied code would carry GPL obligations. [license](https://github.com/vikrum/kidpix/blob/99c67f3427d229f7db60b03dcf19df4d8c2a8ecf/LICENSE)
- [KiddoPaint at `140ca297683db82daedccae321b519f10f3fde0d`](https://github.com/vikrum/kiddopaint/tree/140ca297683db82daedccae321b519f10f3fde0d) is an MIT-licensed, Kid Pix-inspired web application. It is the cleanest reusable code reference of the three, but it is not a pixel- or behavior-exact implementation of the clip. [MIT license](https://github.com/vikrum/kiddopaint/blob/140ca297683db82daedccae321b519f10f3fde0d/LICENSE)

## Reuse decision

| Evidence/source | Use it for | Do not reuse directly |
| --- | --- | --- |
| Supplied YouTube clip | Interaction timing, layout, state changes, tool feedback, acceptance traces | Video frames, music/audio, or embedded artwork |
| 2004 manual and archived CD record | Canonical feature vocabulary and behavioral inventory; hashes for provenance | Original executables, library art, sounds, fonts, or animation frames |
| `Open-KidPix-Deluxe` | Read-only implementation and file-format research; hypotheses to verify independently | Code or imported assets without an explicit license from the author/rightsholder |
| JSKidPix | GPL-compatible behavioral study | Code in a non-GPL RISD application |
| KiddoPaint | MIT-licensed algorithm/reference patterns, with attribution and license retention | Claims of exact Deluxe 4 parity |

## Recommended Godot reconstruction

Build a clean native Godot interpretation around independently authored RISD/Qwen assets:

1. Make the video timestamps and manual behaviors the acceptance contract, not a source of extractable art.
2. Keep cursor scale separate from brush radius. Offer visible pencil scales such as `1.0×`, `1.5×`, `2.0×`, and `3.0×`, preserving one fixed tip hotspot so a larger pencil does not move the drawn point.
3. Add short original microanimations for hover, press, active-tool bounce, pencil tilt/drag, release recoil, tray changes, undo, and clear. Use play-once and boomerang timelines as behavioral patterns, but create new frames.
4. Model placed stickers/animations as independent Godot objects with position, scale, selection handles, playback state, and optional flatten-to-canvas behavior.
5. Use the community `MHK` importer only to understand file organization if necessary. Do not make the RISD runtime depend on an original Kid Pix installation or ship extracted proprietary frames.

This path can reproduce the video's character and responsiveness while keeping the implementation native, testable, and legally separable from the 2004 assets and the unlicensed community reimplementation.
