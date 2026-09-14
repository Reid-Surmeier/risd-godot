# Provenance of modules/sculpture_viewer

Every file below was copied unchanged (the two scripts excepted, see their headers) from
`Reid-Surmeier/figma-ui-ux-qwen-pipeline`, branch `prototype/painting-tool-mixbox`, commit `7ee5e9c`,
folder `painting-tool-prototype/viewer-godot/`, on 2026-09-13. SHA-256 is of the source file at that
commit, which for every non-script file is also the byte-identical copy here. Only the desktop's
catalogue and viewer windows travelled: the sketchbook window (`modules/sketchbook`), the Mixbox
paintbox and `addons/mixbox` (CC BY-NC 4.0, left out per ticket #32; licence question #36),
`addons/stagehand` and the QA rig (`qa.sh`, `run-*.sh`, `serve-web.mjs`, `tests/`, the Playwright
config), the two one-node scenes (`desktop.tscn`, `main.tscn`; the nodes are built in code here),
`project.godot`, `export_presets.cfg`, the unused `assets/qwen-v001..v003`, `assets/source-v002` and
`assets/clean-ui/{audio,menu,next,play,previous}-*.png` (nothing loads them) stayed behind. Nothing here
is hand-drawn.

**Rights: pending on ticket #35.** The Buddha scan is museum-object material with no accession or
licence record; the clean media-player plate and the catalogue picture are owner-supplied screenshots
with no rights statement. They ship here as draft-mockup evidence, exactly as the other prototypes'
pixels do; nothing in this module asserts a licence for them.

## Where the pixels come from (records in the source repository)

| Pixels | Origin | Record |
| --- | --- | --- |
| `assets/models/proton-buddha-3124123123.glb` | seated Buddha, object 3124123123 of the owner's local Proton Drive OBJ snapshot (673,605 vertices), decimated to 61,523 vertices / 119,999 polygons, height normalised to 4.5, UVs preserved | `references/statue-viewer-v002/model-provenance.json` (source OBJ sha256 `bc2b8eb9…8454f0`) |
| `assets/models/3124123123.jpg` | the scan's own 6568x6192 gold texture from the same snapshot, bytes unchanged | same record (`source_texture_sha256` `f9712f0c…499f1f`, matches the copy). Godot imports it capped at 2048 px: `3124123123.jpg.import` is force-tracked here for that one setting (`process/size_limit=2048`), as the prototype tracked it |
| `assets/clean-ui/background.png`, `assets/clean-ui/timer-source.png` | crops of the owner-approved 1600x1360 clean media-player Reference Screen at exact half scale (800x680) | `references/statue-viewer-clean/source.json` (reference sha256 `2b5dab93…d6889`, provenance pointer into `qwen-image-pipeline/.orca/outputs/statue-player-fit-20260906/correction-2/verification.json`); `scripts/build_statue_viewer_clean_ui.sh` |
| `assets/control-motion/{previous,next,play-pause,audio,menu,scrubber}.png` (24-frame atlases), `track-empty.png`, `track-fill.png` | Muse (`meta/muse-image`) anchor + Seedance 2.5 (`bytedance/seedance-2.5`) take via OpenRouter, 1.40635 USD actual, 24 real video frames per control cut by `scripts/extract_statue_control_motion.py` | `references/statue-control-motion/provenance.json`, `media-verification.json`, `seedance.mp4` (sha256 `5877ae0a…6d4fd`); `assets/control-motion/extraction.json` here is the cut record |
| `assets/catalogue/sidebar.png` | owner-supplied 2276x5101 screenshot of a catalogue sidebar; one draggable image, its depicted links and buttons are artwork | `references/statue-viewer-desktop/source.json` (sha256 matches the copy; layout: canvas 1440x972, sidebar at (72, 34) 400 wide, viewer at (600, 34) 800x680 x0.985) |

Gaps carried from `docs/research/prototype-dependencies.md`: the Buddha scan has no owner, licence or
museum accession record; the catalogue picture and the clean plate have no rights statement beyond
"owner supplied"; the Muse / Seedance records live in the other repository and are pointed at, not copied.

## Files

| File | Source path | SHA-256 | Note |
| --- | --- | --- | --- |
| `modules/sculpture_viewer/desktop.gd` | `viewer-godot/scripts/desktop.gd` | `9ead517d9351d5a83c400fa75229a85cb01444aff15dc96f14ad3c4234aa8549` | ported (edited; see the script header) |
| `modules/sculpture_viewer/viewer.gd` | `viewer-godot/scripts/main.gd` | `c000424bf86b82883beea0517a4ce05e4afa2971550622cfd511b52306a3fce2` | ported (edited; see the script header) |
| `modules/sculpture_viewer/shaders/player_base.gdshader` | `viewer-godot/shaders/player_base.gdshader` | `f0361b958812154e84c98cf945e85a16ed24d7a46fa183e22381c5178f1d639b` | erases the plate's baked controls (800x680) |
| `modules/sculpture_viewer/shaders/control_face.gdshader` | `viewer-godot/shaders/control_face.gdshader` | `9d036b761db008f826d6314db43529bb87cd59e258d62304217c1d5f28466bce` | button face / navigation / progress rail |
| `modules/sculpture_viewer/assets/models/proton-buddha-3124123123.glb` | `viewer-godot/assets/models/proton-buddha-3124123123.glb` | `3944df2113c8f642a103e3609d9a6f92671ca5e2ea59d69616521a975ab273e9` | the Buddha scan (rights pending, #35) |
| `modules/sculpture_viewer/assets/models/3124123123.jpg` | `viewer-godot/assets/models/3124123123.jpg` | `f9712f0c6287600bf56b175ec4d174e6ac71c9eb24744415f15f37dbe4499b1f` | its gold texture (rights pending, #35) |
| `modules/sculpture_viewer/assets/clean-ui/background.png` | `viewer-godot/assets/clean-ui/background.png` | `ac0dec254487ae99007c7d2d77a2af888f4afeba1be122ee2ab2bfb91d1cce60` | the clean media-player plate, 800x680 |
| `modules/sculpture_viewer/assets/clean-ui/timer-source.png` | `viewer-godot/assets/clean-ui/timer-source.png` | `de74f97f96fa092cab7a3057cac096ea2e06f6e777203630d88dd189424e3baa` | the "04:21" timer face |
| `modules/sculpture_viewer/assets/control-motion/previous.png` | `viewer-godot/assets/control-motion/previous.png` | `d7e68d18645100390d047b974a8a00c317976fb2cf467ff395d24ab3e4470d53` | 24-frame Seedance atlas |
| `modules/sculpture_viewer/assets/control-motion/next.png` | `viewer-godot/assets/control-motion/next.png` | `755255bbb7a0b77736d50095551e4f62047166eeaf33dd48abe68ba6857259d8` | 24-frame Seedance atlas |
| `modules/sculpture_viewer/assets/control-motion/play-pause.png` | `viewer-godot/assets/control-motion/play-pause.png` | `0533bb863665c6ce74fe6dc3e01528205640afe5bed1fe723696cfecba48d3b3` | 24-frame Seedance atlas |
| `modules/sculpture_viewer/assets/control-motion/audio.png` | `viewer-godot/assets/control-motion/audio.png` | `217d11cc385b3232587e1274b130c6fe037b52f0e308f3608e0e6849f6d93cf5` | 24-frame Seedance atlas |
| `modules/sculpture_viewer/assets/control-motion/menu.png` | `viewer-godot/assets/control-motion/menu.png` | `4d4ce41303aa42264e63084fc8c7260a004de72f5c7659d80da5ee374c1ad43d` | 24-frame Seedance atlas |
| `modules/sculpture_viewer/assets/control-motion/scrubber.png` | `viewer-godot/assets/control-motion/scrubber.png` | `cb4b1b1ded08163df0f98e82913952f61dd4140ff617f0064ceff72f2202a50d` | 24-frame Seedance atlas, circular alpha |
| `modules/sculpture_viewer/assets/control-motion/track-empty.png` | `viewer-godot/assets/control-motion/track-empty.png` | `fc4fc43b08121a08d133164fa2895a9244215b24f201c85a9b214e522310c557` | progress rail |
| `modules/sculpture_viewer/assets/control-motion/track-fill.png` | `viewer-godot/assets/control-motion/track-fill.png` | `2af20f635bbfff11321f43383e2969bfbbc84bb436cf54d3d74061d34ac48b25` | progress rail fill |
| `modules/sculpture_viewer/assets/control-motion/extraction.json` | `viewer-godot/assets/control-motion/extraction.json` | `6d7cc975bdc5d7125049b50c4218baf3a1a7adcb6f21fcfacd1694e6ee3c4c59` | the frame-cut record (not loaded) |
| `modules/sculpture_viewer/assets/catalogue/sidebar.png` | `viewer-godot/assets/catalogue/sidebar.png` | `575489dd8a67f905ed5aadc0f081a0c82e158fdf1599cc63703ea88b2b430c0e` | the catalogue picture, owner-supplied (see gaps) |
