# Provenance of modules/sketchbook

Every file below was copied unchanged (the four scripts excepted, see their headers) from
`Reid-Surmeier/figma-ui-ux-qwen-pipeline`, branch `prototype/painting-tool-mixbox`, commit `7ee5e9c`,
folder `painting-tool-prototype/viewer-godot/`, on 2026-09-13. SHA-256 is of the source file at that
commit, which for every non-script file is also the byte-identical copy here. Only the sketchbook
window travelled: the catalogue and viewer windows (`modules/sculpture_viewer`), the Mixbox paintbox
(`scripts/paint_palette_prototype.gd`, `assets/paintbox/`) and `addons/mixbox` (Mixbox 2.0, CC BY-NC 4.0
— left out of v0.1.0 per ticket #32; the licence question is #36; no Mixbox file is in this
repository), `addons/stagehand` and the QA rig, the two one-node scenes, `project.godot` and
`export_presets.cfg` stayed behind. The sketchbook draws in tldraw's one ink colour and needs no
palette. Nothing here is hand-drawn.

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
| `assets/pencil-prototype.png` | the web prototype's pencil cursor, copied from the kidpix-tldraw prototype | no separate record; see gaps |
| the ink | `freehand.gd` is a line-by-line GDScript port of tldraw 5.3.2 `shapes/shared/freehand` (a perfect-freehand fork); `drawing_surface.gd` uses tldraw's size-m draw settings (4.5 px, `#4465e9`) | `docs/research/prototype-dependencies.md` gap (e) |

Gaps carried from `docs/research/prototype-dependencies.md`: the window chrome has no rights statement
beyond "owner supplied"; the page picture's owner approval is pending; the pencil has no record of its
own; the tldraw licence travels with the port and is not quoted here; the Muse run folder lives outside
any repository.

## Files

| File | Source path | SHA-256 | Note |
| --- | --- | --- | --- |
| `modules/sketchbook/desktop.gd` | `viewer-godot/scripts/desktop.gd` | `9ead517d9351d5a83c400fa75229a85cb01444aff15dc96f14ad3c4234aa8549` | ported (edited; see the script header) |
| `modules/sketchbook/sketchbook_window.gd` | `viewer-godot/scripts/sketchbook_window.gd` | `d146e0adc407d9ee0d074db1364712e173e198c1fc1c5bfc6c98c40bb26df4e5` | ported (class_names dropped, paths, resize delta; see the header) |
| `modules/sketchbook/drawing_surface.gd` | `viewer-godot/scripts/drawing_surface.gd` | `ab3ce55b9d5ee13833376cc220d63626d4c2643787e2b674bb9ef0743f5a4817` | ported (class_name dropped, pencil path; see the header) |
| `modules/sketchbook/freehand.gd` | `viewer-godot/scripts/freehand.gd` | `fac33b39956fccd7a711ab3e44e7a7c6d87c469c64c4a5541f602dd533be695f` | ported (class_name dropped; see the header) |
| `modules/sketchbook/paper_turn.gd` | `viewer-godot/scripts/paper_turn.gd` | `29da53d67d0e023f833558e05571b05b365351f960758d619c92b614e81a09fb` | ported (class_name dropped; see the header) |
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
| `modules/sketchbook/assets/pencil-prototype.png` | `viewer-godot/assets/sketchbook/pencil-prototype.png` | `12f346529cd418bf1977ce14421c400bf2f136ea74195f3ecb64af18ef04e8b1` | the pencil cursor |
| `modules/sketchbook/assets/window-chrome.provenance.json` | `viewer-godot/assets/sketchbook/window-chrome.provenance.json` | `be71901eee78764987875754b74dbedc990861c50230042e848403866b117c40` | the chrome's Muse record |
| `modules/sketchbook/assets/sketchbook-page-v005-soft-384.provenance.json` | `viewer-godot/assets/sketchbook/sketchbook-page-v005-soft-384.provenance.json` | `ae32828fd9aab49bfd20fbac1df409d70126519d8e60a36d690fcf45815a112e` | the page's record |
