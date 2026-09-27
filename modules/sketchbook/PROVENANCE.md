# Provenance of modules/sketchbook

Every file below was copied unchanged (the scripts marked "ported" excepted, see their headers) from
`Reid-Surmeier/figma-ui-ux-qwen-pipeline`, branch `prototype/painting-tool-mixbox`, commit `d2faa30`
(`d2faa306c05516c081c59f5af336d21841ed6a7e`, "fix: show paintbox on performance route", 2026-09-13),
folder `painting-tool-prototype/`, on 2026-09-14 (tickets #48, #49: the owner reversed ticket #32's
"Mixbox left out"). SHA-256 is of the source file at that commit (`git show d2faa30:<path> | sha256sum`),
which for every file not marked "ported" is also the byte-identical copy here. The sketchbook window,
its chrome, the page picture, `freehand.gd` and `paper_turn.gd` are the same bytes at `d2faa30` as at the
`7ee5e9c` the first port took. What travelled: the book, the Mixbox paintbox with its brush and cat rest,
and Mixbox itself. What stayed behind: the catalogue and viewer windows (`modules/sculpture_viewer`),
`addons/stagehand` and the QA rig (`tests/`, `qa.sh`, the Playwright specs), the A/B/C variant switcher
(variant A is fixed), `main.tscn`, `desktop.tscn`, `project.godot` and `export_presets.cfg`.
`assets/sketchbook/pencil-prototype.png` is no longer loaded at `d2faa30` (the brush replaced the pencil)
and was removed from this module. Nothing here is hand-drawn.

## Mixbox licence (recorded as the prototype ships it; not resolved here)

`mixbox/` is Mixbox 2.0 by Secret Weapons (Sarka Sochorova and Ondrej Jamriska), the Godot port the
prototype reports as "2.0 upstream a1bdb75". **Licence: Creative Commons Attribution-NonCommercial 4.0
International (CC BY-NC 4.0).** Where the prototype ships it: `painting-tool-prototype/godot/addons/mixbox/LICENSE`
(reached from `viewer-godot/addons`, a symlink to `../godot/addons`), whose first lines read "Mixbox is
licensed for non-commercial use under the CC BY-NC 4.0 license below. If you want to obtain commercial
license, please contact: mixbox@scrtwpns.com", followed by the full CC BY-NC 4.0 text; and the header of
`godot/addons/mixbox/mixbox.gd`: "MIXBOX 2.0 (c) 2022 Secret Weapons. All rights reserved. License:
Creative Commons Attribution-NonCommercial 4.0". Both notices are kept here byte for byte
(`mixbox/LICENSE`, `mixbox/mixbox.gd`). It is non-commercial use only; the road after (a commercial
licence, a permissive replacement, or no paintbox) is ticket #36's, not this module's. The attribution
CC BY asks for is not shown inside the game yet.

**Rights: pending on ticket #35.** The window chrome (`ro-*.png`) is the bytes of a third-party
game window the owner supplied, with Muse-drawn title lettering and button glyphs; the page picture
records `source_owner_approval: "pending"`; `freehand.gd` is a port of tldraw 5.3.2 code whose
licence terms have not been read into any record here. They ship as draft-mockup evidence, exactly
as the other prototypes' pixels do; nothing in this module asserts a licence for them.

## Where the pixels come from (records copied or pointed at)

| Pixels | Origin | Record |
| --- | --- | --- |
| `assets/ro-{top,bottom}-{left,mid,right}.png`, `ro-left.png`, `ro-right.png`, `ro-btn-{prev,prev-disabled,next}.png` | slices of the owner's reference window (`references/ro-window.png`, sha256 `b3f47fee…926f7ff`) with the title lettering and the button glyphs redrawn by Muse (`meta/muse-image` via OpenRouter, 5 requests, 0.05 USD) in deterministic region Assembly | `assets/window-chrome.provenance.json` here (runs, assembly regions, hashes); the run folder is `~/muse-runs/sketchbook-window-chrome` outside any repository |
| `assets/sketchbook-page-v005-soft-384.png` | the kidpix-tldraw prototype's `sketchbook-page-v005.png` cropped to 960x960 and Lanczos-downsampled to 384x384 | `assets/sketchbook-page-v005-soft-384.provenance.json` here (`source_owner_approval: "pending"`) |
| `assets/paintbox/palette-white.png` | owner-approved Muse edit of a watercolour palette: white plastic, transparent background, no shadow | `assets/paintbox/palette-white.provenance.json` here (source path outside any repository, sha256) |
| `assets/paintbox/watercolor-brush.png`, `assets/paintbox/cat-brush-rest.png` | one Muse edit (`meta/muse-image` via OpenRouter, 1 request, 0.01 USD, run `run-9f4d5100ab5314e3e526c0f6`) split into the brush and the cat rest; its record says "visual prototype; owner approval remains unverified" | `assets/paintbox/brush-kit.provenance.json` here |
| `assets/paintbox/brush-tip.gdshader` | the prototype's shader tinting the bristles with the carried pigment | code, no record |
| pigment mixing | Mixbox 2.0's latent pigment model (`mixbox/mixbox.res` is its lookup table) | the licence section above |
| the ink | `freehand.gd` is a line-by-line GDScript port of tldraw 5.3.2 `shapes/shared/freehand` (a perfect-freehand fork); `drawing_surface.gd` uses tldraw's size-m draw settings (4.5 px; the colour is the pigment the brush carries) | `docs/research/prototype-dependencies.md` gap (e) |

Gaps carried from `docs/research/prototype-dependencies.md`: the window chrome has no rights statement
beyond "owner supplied"; the page picture's owner approval is pending; the brush kit's owner approval is unverified; the tldraw licence travels with the port and is not quoted here; the Muse run folder lives outside
any repository.

## Files

| File | Source path (under `painting-tool-prototype/`) | SHA-256 at d2faa30 | Note |
| --- | --- | --- | --- |
| `modules/sketchbook/desktop.gd` | `viewer-godot/scripts/desktop.gd` | `9c1670970975209be36f3494644731ca6127e4a949372e95922599a096adcbe0` | ported (edited: variant A fixed, the fill rule, the probe; see the header) |
| `modules/sketchbook/paintbox.gd` | `viewer-godot/scripts/paint_palette_prototype.gd` | `52aa9ae244749cd1f8a5005c2ae800e1f337fef94c4402f3ecd47c89af8eba2f` | ported (class_name dropped, paths, hover from mouse events; see the header) |
| `modules/sketchbook/sketchbook_window.gd` | `viewer-godot/scripts/sketchbook_window.gd` | `d146e0adc407d9ee0d074db1364712e173e198c1fc1c5bfc6c98c40bb26df4e5` | ported (class_names dropped, paths, resize delta; see the header) |
| `modules/sketchbook/drawing_surface.gd` | `viewer-godot/scripts/drawing_surface.gd` | `2c0a286045fcaad96a8dcc7afdd5aadaf1cfb7e7ca2942e86ab227e6d013b1e3` | ported (class_name dropped, paths; see the header) |
| `modules/sketchbook/freehand.gd` | `viewer-godot/scripts/freehand.gd` | `fac33b39956fccd7a711ab3e44e7a7c6d87c469c64c4a5541f602dd533be695f` | ported (class_name dropped; see the header) |
| `modules/sketchbook/paper_turn.gd` | `viewer-godot/scripts/paper_turn.gd` | `29da53d67d0e023f833558e05571b05b365351f960758d619c92b614e81a09fb` | ported (class_name dropped; see the header) |
| `modules/sketchbook/mixbox/mixbox.gd` | `godot/addons/mixbox/mixbox.gd` | `5d10a98ffb8fab237fea7dbd03e2bb0bf95edca5357fa75429097776a8eb0a14` | Mixbox 2.0 (CC BY-NC 4.0), notice kept |
| `modules/sketchbook/mixbox/mixbox.res` | `godot/addons/mixbox/mixbox.res` | `930c0ee996d7a4aaecbfd53476573a3a0f95947a672e4897132b8883066763bb` | Mixbox 2.0 lookup table (CC BY-NC 4.0) |
| `modules/sketchbook/mixbox/LICENSE` | `godot/addons/mixbox/LICENSE` | `4e4b6a193eee2fce7429988137b143b3be38cdd1e6fb9cfdca4507aa182254f3` | the Mixbox licence, CC BY-NC 4.0 |
| `modules/sketchbook/assets/paintbox/palette-white.png` | `viewer-godot/assets/paintbox/palette-white.png` | `c451c1003564c74e462c73826df7c7f75dfc16ace0791b6e4d03612ace1f4374` | the palette |
| `modules/sketchbook/assets/paintbox/palette-white.provenance.json` | `viewer-godot/assets/paintbox/palette-white.provenance.json` | `08491ff6535526d7aa07f4f98803c4b20f15a877eaef1e12b4537b64897a4946` | the palette's record |
| `modules/sketchbook/assets/paintbox/watercolor-brush.png` | `viewer-godot/assets/paintbox/watercolor-brush.png` | `1bff2a1cd9940fd84caa43b76427153eb020c3d08464c63bdd6319a639901820` | the brush |
| `modules/sketchbook/assets/paintbox/cat-brush-rest.png` | `viewer-godot/assets/paintbox/cat-brush-rest.png` | `c6ced676e7593c690d7743fbf4406c829093e7793b55317129e8bf269959d12e` | the cat brush rest |
| `modules/sketchbook/assets/paintbox/brush-kit.provenance.json` | `viewer-godot/assets/paintbox/brush-kit.provenance.json` | `9b460a01eae2b066bde8c5ecbc07314b2af65b79ca117656dc857040da3e150b` | the brush kit's Muse record |
| `modules/sketchbook/assets/paintbox/brush-tip.gdshader` | `viewer-godot/assets/paintbox/brush-tip.gdshader` | `a731c7da4f3dce87a352a61d65c215c1e658ce8bfd63f1a319c64f47c0c0daf6` | the bristle tint shader |
| `modules/sketchbook/assets/ro-top-left.png` | `viewer-godot/assets/sketchbook/ro-top-left.png` | `0657590110910674e1c6a3911987b661a6482021b5b9fd3b04a562e0de0160fb` | frame slice |
| `modules/sketchbook/assets/ro-top-mid.png` | `viewer-godot/assets/sketchbook/ro-top-mid.png` | `fe2a45be1b1827d808dc7aaa132936aa06978838acf1bae1610c664d3da4a5da` | frame slice, tiled |
| `modules/sketchbook/assets/ro-top-right.png` | `viewer-godot/assets/sketchbook/ro-top-right.png` | `fa20ebb9e57e9cfc7c190a4d25210b68145ecec69bf8a4c04682d1c8c047f82a` | frame slice |
| `modules/sketchbook/assets/ro-left.png` | `viewer-godot/assets/sketchbook/ro-left.png` | `be9c9adec194c4e9d7bf1a9f807d739b236eb9fe407466522f87c53a47e6bbca` | frame slice, tiled |
| `modules/sketchbook/assets/ro-right.png` | `viewer-godot/assets/sketchbook/ro-right.png` | `434fe53957e4192e21f13a507b89fb3fdb9504938d2a25881d19bcfa360f40b3` | frame slice, tiled |
| `modules/sketchbook/assets/ro-bottom-left.png` | `viewer-godot/assets/sketchbook/ro-bottom-left.png` | `3c00d6ba039fd5202e4484ab02678411e8d575f7c7af59cfa668d5f1bfef1edc` | frame slice |
| `modules/sketchbook/assets/ro-bottom-mid.png` | `viewer-godot/assets/sketchbook/ro-bottom-mid.png` | `f2c2ee12aa1620db64b88f7f8cf92e9ae0e84d03e914366f4e340b2fe50fa05b` | frame slice, tiled |
| `modules/sketchbook/assets/ro-bottom-right.png` | `viewer-godot/assets/sketchbook/ro-bottom-right.png` | `dd46f7c73fb6073b7ea728f3ce67c88c3222cc3e5f7aa548291248237651c9b6` | frame slice |
| `modules/sketchbook/assets/ro-btn-prev.png` | `viewer-godot/assets/sketchbook/ro-btn-prev.png` | `feacd64dd7fc39bf236e3bbd5f0c71ad3c9aa532f23b58d9a91d6c98481aefd1` | previous-page arrow |
| `modules/sketchbook/assets/ro-btn-prev-disabled.png` | `viewer-godot/assets/sketchbook/ro-btn-prev-disabled.png` | `25b1f3d1cec86dd8a19e2dfe188a86b85c69b1110a878398976006a5d25c286c` | previous-page arrow, disabled |
| `modules/sketchbook/assets/ro-btn-next.png` | `viewer-godot/assets/sketchbook/ro-btn-next.png` | `a6cc09ab0e6924fad06802c5ff011ec53517529d721573058114c54ba008ee33` | next-page arrow |
| `modules/sketchbook/assets/sketchbook-page-v005-soft-384.png` | `viewer-godot/assets/sketchbook/sketchbook-page-v005-soft-384.png` | `dfbedb206a11d4233632be95f6568253327db10b5942c9b3f0ce819dd8af9aa6` | the open book (approval pending) |
| `modules/sketchbook/assets/window-chrome.provenance.json` | `viewer-godot/assets/sketchbook/window-chrome.provenance.json` | `be71901eee78764987875754b74dbedc990861c50230042e848403866b117c40` | the chrome's Muse record |
| `modules/sketchbook/assets/sketchbook-page-v005-soft-384.provenance.json` | `viewer-godot/assets/sketchbook/sketchbook-page-v005-soft-384.provenance.json` | `ae32828fd9aab49bfd20fbac1df409d70126519d8e60a36d690fcf45815a112e` | the page's record |

## Native painting viewer, ticket #129

No new paid generation or replacement artwork. `painting_flow.gd` reuses the six unchanged museum JPGs, `paintings.json`, and the user-supplied blue minimap frame at `prototypes/painting-coverflow/web/`; hashes and source URLs remain in that prototype’s `PROVENANCE.json` and catalogue. The book texture and original page buttons listed above are unchanged. The supplied sketchbook screenshot is visual reference only. UI materials key the frame’s exterior magenta and remove the book’s white matte at draw time; source files are untouched. The original baked book shadow is retained.

## Restored owner revisions — #145, September 27, 2026

`assets/paintbox/palette-window-v7.png` is a byte-identical copy of the existing #126 review asset at `image-work/sketchbook-palette-window-20260926/review/palette-window-v7.png` in the preserved primary checkout. SHA-256: `e907cd84e4278ae029abb6a1e179673792a46681ae0a182c680f7f5ac985c8c8`. It includes the finished blue/silver border, white inkwell, upright pencil and pink eraser on the original stone. Its original Muse run records, source hashes and v7 assembly record are in the verified September 27 Proton preservation catalog. No image generation or bitmap editing occurred for this integration. Existing native paint mixing and the movable brush/rest are composed over the original artwork at runtime.

The exact owner-selected gold frame remains `assets/gold-frame/frame.png`, SHA-256 `2f0e9a5fc58513636dfb8cf5dc11346c38641a2b00785b15fcbeb64839158e28`. Commit `59292b6796fa16dcf9b112e73503a1db7b73f069` records the owner's choice of the original frame over the thinner variants. Issue #146 corrects #145's mistaken integration: this frame belongs only to the standalone flat painting and never to the Finder-like Cover Flow images.

The archived mountain/church reference is `assets/monet-reference.png` (historical filename), SHA-256 `98466904b0c8236ab03cf4ee43fe0a590d136974b36df1d030dd71af97aef705`. Its old white card margin is excluded at display time, as in the original framed-reference implementation. It is displayed in the separate gold-frame window; the viewer retains its six original images. No new artist attribution is inferred from the historical filename. Spend for #145 and #146: $0.
