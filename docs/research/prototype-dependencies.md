# What each prototype depends on before it can be ported

Date: 2026-09-13
Ticket: [Research: what each prototype depends on before it can be ported](https://github.com/Reid-Surmeier/risd-godot/issues/25), part of map #23.
Method: read-only inspection of the four source trees on disk (paths and commits below). Every claim is from a file in those trees; nothing was run.

All four prototypes and this repo pin **Godot 4.7.2-stable** (`run.sh` / `qa.sh` / `toolchain-lock.json`), so no engine change is involved. The shell here runs `stretch/mode="disabled"`, `default_texture_filter=0` (nearest), viewport 1920x420, and sets no `rendering_method` (`project.godot` on `feat/tab-strip`); every prototype sets `gl_compatibility` explicitly and two rely on linear filtering, so those are per-Tenant settings the port must carry on the nodes, not in `project.godot` (see "Settings that collide" at the end).

## 1. Pixel Atlas (Map tab)

Source: `~/qwen-pipeline-experiments/benchmarks/atlas-prototype/godot`, branch `prototype/atlas-5`, commit `421f1cc`. 285 tracked files, 34 MB.

**Carry**

| Kind | Files | Notes |
| --- | --- | --- |
| Scenes | `atlas_window.tscn` (root Control, script only), `atlas.tscn` (Node2D, script only) | Both scenes are one node plus a script; all UI is built in code. |
| Scripts | `atlas_window.gd` (239 lines), `atlas.gd` (500 lines) | `atlas_window.gd` is the draggable/resizable frame with a `SubViewport` holding `atlas.tscn`; it also lays out four raster desktop panels. `atlas.gd` is the map: camera, zoom tiers, city labels, geography tiles. |
| Shader | `geography.gdshader` (canvas_item, `map_zoom` uniform) | Signed-distance coastline outline for the close-zoom tiles. |
| Font | `fonts/PixelMplus12-Regular.ttf` (1.2 MB) + `fonts/LICENSE.txt` (M+ FONTS licence, free use/modify/distribute) | Loaded at runtime with `antialiasing = NONE` for close-city labels only. HUD `Label`/`OptionButton`/`Button` use Godot's default theme font. |
| Data | `atlas.json` (347 KB: world size, badges, regions, control points, annotations) and `close-cities.json` (3.8 MB, 40,846 GeoNames places) | Read with `FileAccess` at `res://`; the Web preset needs `include_filter="*.json"` or they are not exported. |
| Pixels, `assets/` | 11 regional sheets (`africa.png` … `usa.png`), per-region `-labels.png` and `-annotations.png` (22 files), `world.png`, `terrain.png`, `world-badges.png`, `window-frame.png` | Loaded by name from `atlas.gd` / `atlas_window.gd`. |
| Pixels, `assets/geography/` | 192 files: 48 tiles `{col}-{row}.png` plus `{col}-{row}-field.png` (~10 MB) | Loaded lazily by visible tile. |
| Pixels, `assets/desktop/` | `chat.png`, `itinerary.png`, `minimap.png`, `notification.png` | The four raster panels around the map window. |

**Leave behind:** `assets/*-detail.png` (10 files; gitignored, never loaded), `assets/window-title.png` (not referenced), `export_presets.cfg` (its `html/head_include` paints the page cyan and sets `image-rendering:pixelated`; the shell's preset owns that now), everything above `godot/` — `prepare_*.py` (asset assembly from `benchmarks/world-map` and `benchmarks/regional`), `verify_*.py`, `playtest*.mjs` (Playwright against `window.atlasState` / `window.atlasWindow`), `evidence/`, `generation/`, `reference/`, `run.sh` (exports then calls `share.py`). The `JavaScriptBridge.eval` publishes in `_publish()` (both scripts) exist only for those playtests; a port can keep or drop them.

**Project settings relied on:** `stretch/mode="disabled"` (the window script fits itself to `get_viewport_rect()` and has a phone layout under 750 px), `default_texture_filter=0` (nearest; `atlas.gd` also sets `TEXTURE_FILTER_NEAREST` on itself), `gl_compatibility`, `emulate_mouse_from_touch=true`, default clear colour `#83E5F7` (overridden to white by `atlas_window.gd` at `_ready`). No input map: keys are hard-coded (`Home`/`Esc` reset, `+`/`-` zoom, arrows pan) in `_unhandled_input`; `atlas_window.gd` handles drag/resize in `_input` and calls `set_input_as_handled()`. Input events with `device == -1` are ignored (a Playwright artefact guard). The map lives in its own `SubViewport` with `gui_embed_subwindows`, so it already isolates itself from a host page.

**Provenance on record:** world sheet and regional sheets are Muse (`meta/muse-image` via OpenRouter) generations logged in `benchmarks/world-map/pink-cyan-v001/ledger.json` and `benchmarks/regional/pink-cyan-v001/ledger.json`; five further Muse edits (Pacific fill, window title, three panel captions; $0.05 total) in `benchmarks/atlas-prototype/generation/ledger.json`. Geography from Natural Earth 1:10m v5.1.2 (public domain; URLs and SHA-256 in `reference/detail-sources.json`, `reference/sources.json`). Cities from GeoNames (CC BY 4.0; attribution in `reference/close-cities.json.gz`, `README.md`). Frame and panels: `reference/window-source.json`, `reference/desktop/assets.json` (hashes of owner-supplied inputs and outputs). None of these records sit inside `godot/`; the module's provenance file must copy the relevant hashes and ledger paths out.

**Gaps:** (a) `assets/desktop/*.png` and `assets/window-frame.png` derive from owner-pasted screenshots of a third-party game UI (`reference/desktop/sources.json` lists `/tmp/orca-paste-*.png`; the itinerary copy still reads Zeny/Lv.58 in `ledger.json`); no rights statement exists beyond "owner supplied". (b) GeoNames CC BY requires visible attribution in the shipped game, which the prototype does not show. (c) The Muse ledgers live in another repo; a port must snapshot them or the module's provenance file points at a checkout that may move.

## 2. Sculpture Viewer pair (3D Viewer tab + Sketchbook tab)

Source: `~/orca/workspaces/figma-ui-ux-qwen-pipeline/painting-tool-prototype/viewer-godot`, branch `prototype/painting-tool-mixbox`, commit `7ee5e9c`. 148 tracked files in `viewer-godot/` plus 46 in `godot/addons/` (symlinked in as `viewer-godot/addons`).

**Carry**

| Kind | Files | Notes |
| --- | --- | --- |
| Scenes | `desktop.tscn` (Control + `desktop.gd`), `main.tscn` (Control + `main.gd`) | `desktop.gd` preloads `main.tscn`, the sketchbook script and the paintbox script and builds the desktop; `main.gd` is the 3D viewer window. |
| Scripts, viewer | `scripts/main.gd` (696 lines) | `SubViewport` with the GLB, orbit/zoom, transport controls with 24-frame press atlases, shaders below. Keys hard-coded: arrows rotate/zoom, `Space`, `M`, `Home`, `Esc`. |
| Scripts, sketchbook | `scripts/sketchbook_window.gd` (326), `scripts/drawing_surface.gd` (322), `scripts/freehand.gd` (518, `class_name Freehand`), `scripts/paper_turn.gd` (136, `class_name PaperTurn`) | `freehand.gd` is a line-by-line GDScript port of tldraw 5.3.2's freehand ink (a perfect-freehand fork). `drawing_surface.gd` declares `class_name SketchbookDrawingSurface`. Global `class_name`s collide if two modules use the same names. |
| Scripts, paintbox | `scripts/paint_palette_prototype.gd` (177, `class_name PaintPalettePrototype`) | Throwaway; selects three layouts via `?variant=A|B|C`. Needs Mixbox (below). |
| Shaders | `shaders/player_base.gdshader` (erases the reference's baked controls at fixed pixel rectangles, hard-coded 800x680), `shaders/control_face.gdshader` (button face / progress rail) | Both assume the 800x680 canvas of the source screenshot. |
| Plugin | `addons/mixbox/` — `mixbox.gd`, `mixbox.res` (the LUT), `LICENSE` | Preloaded by the paintbox only. Vendored source in `painting-tool-prototype/repos/mixbox` (`VENDORED.md`: `scrtwpns/mixbox@a1bdb75`). |
| Model | `assets/models/proton-buddha-3124123123.glb` (5.4 MB, 120k tris) + `assets/models/3124123123.jpg` (11.3 MB source texture; the tracked `.import` caps it at 2048 px) | Provenance: `references/statue-viewer-v002/model-provenance.json` — decimated from a local "Proton Drive OBJ snapshot", object 3124123123, seated Buddha. |
| Pixels, viewer | `assets/clean-ui/background.png`, `assets/clean-ui/timer-source.png`, `assets/control-motion/{previous,next,play-pause,audio,menu,scrubber}.png`, `track-empty.png`, `track-fill.png`, `assets/control-motion/extraction.json` | Loaded by name in `main.gd`. `extraction.json` is the frame-extraction record from the Seedance video. |
| Pixels, desktop | `assets/catalogue/sidebar.png` (2.9 MB, 2276x5101; imported at 2048 max) | The catalogue window is this one image, drag only. |
| Pixels, sketchbook | `assets/sketchbook/ro-*.png` (12 frame slices and buttons), `sketchbook-page-v005-soft-384.png`, `pencil-prototype.png`, plus `window-chrome.provenance.json` and `sketchbook-page-v005-soft-384.provenance.json` | Frame slices are drawn 1:1 and tiled. |
| Pixels, paintbox | `assets/paintbox/palette-white.png` + `palette-white.provenance.json` | |
| Test hook loaded at runtime | `tests/transport_plate.gd` is `load()`ed by `main.gd` when the page URL has `?qa-plate` | Drop the branch or carry the file. |

**Leave behind:** `assets/qwen-v001/`, `qwen-v002/`, `qwen-v003/`, `source-v002/`, and the unused `assets/clean-ui/{audio,menu,next,play,previous}-*.png` (already excluded from the Web preset; nothing loads them). `addons/stagehand/` (46 files, 5.5k lines, `plugin.cfg` + the `StagehandServer` autoload in `project.godot`) is the godot-stagehand 0.4.0 in-game half of an MCP test rig; `run-stagehand-qa.sh` downloads its server binary and drives `tests/stagehand/viewer-runtime.json` under xvfb. `qa.sh` (pytest asset pipeline test, `tests/engine_contract.gd` headless, Web export, Playwright specs in `tests/*.spec.mjs` against `window.viewerQaState` / `window.desktopQaState` / `window.desktopPerf`, ImageMagick chrome-mask RMSE gate), `run-painting-prototype.sh`, `serve-web.mjs`, `playwright.config.mjs`, `export_presets.cfg`, `web/`. Node modules come from `painting-tool-prototype/prototype/`. URL switches read through `JavaScriptBridge` (`?qa-viewer`, `?qa-plate`, `?variant`, `?turn-seconds`, `?perf`, `?lod-bias`, `?no-shadow`) are QA levers; the Page seam should replace them with parameters or drop them.

**Project settings relied on:** viewport 1440x972 with `stretch/mode="canvas_items"` (the desktop lays out in those units and the viewer window is 800x680 source pixels scaled 0.985), `default_texture_filter=1` (linear — the viewer's photographic chrome and the GLB texture expect it; the shell's project-wide nearest filter will alias them unless the nodes set `texture_filter` themselves), `use_nearest_mipmap_filter=true`, `gl_compatibility`, `directional_shadow/size=1024`, `lod_change/threshold_pixels=4.0`, white clear colour, `emulate_mouse_from_touch`. `drawing_surface.gd:45` sets `Input.use_accumulated_input = false` so every pointer sample reaches the stroke; that is a global toggle a shared shell must agree to. No input map.

**Provenance on record:** `references/statue-viewer-clean/source.json` (owner-approved 1600x1360 reference, SHA-256, pointer into `qwen-image-pipeline/.orca/outputs/...verification.json`), `references/statue-control-motion/` (Muse anchor, Seedance 2.5 video, `provenance.json`, `media-verification.json`; README states $1.40635 through OpenRouter), `references/statue-viewer-desktop/source.json` (sidebar and layout hashes, zero generation), the three `*.provenance.json` inside `assets/`, `model-provenance.json` above.

**Gaps:** (a) **Mixbox is CC BY-NC 4.0** (`addons/mixbox/LICENSE`, header of `mixbox.gd`: "non-commercial use"; commercial licence by contacting scrtwpns). Shipping it in the game is an owner decision and needs the attribution line. (b) The seated Buddha scan: `model-provenance.json` names only a local Proton Drive OBJ snapshot; no owner, licence, or museum accession record. (c) `assets/sketchbook/ro-*.png` are the bytes of a third-party game window (`window-chrome.provenance.json` baseline `references/ro-window.png`; the script calls it "Ragnarok-style chrome"), and `assets/catalogue/sidebar.png` is an owner-supplied screenshot; neither has a rights statement. (d) `sketchbook-page-v005-soft-384.provenance.json` records `source_owner_approval: "pending"`. (e) `freehand.gd` ports tldraw 5.3.2 code; that package's `LICENSE.md` (in the kidpix prototype's `node_modules/tldraw`) points at the tldraw licence at github.com/tldraw/tldraw/blob/main/LICENSE.md, whose terms nobody has read into this record — the port carries whatever they say and cites no licence file. (f) The paintbox provenance points at `~/image-edits/...` outside any repo. (g) Splitting the pair: `desktop.gd` owns window stacking, drag, the perf/QA publishers, and instantiates all three windows; the viewer and sketchbook only share `desktop.gd` and no assets, so two Tenants is mechanically clean, but the catalogue window and the Mixbox paintbox belong to neither today (map "Not yet specified").

## 3. Video Player (Video Player tab)

Source: this repo, `origin/Reid-Surmeier/issue-20-video-player-usability` at `f2097ff`, folder `prototypes/video-player-usability/` (checked out at `~/orca/workspaces/risd-godot/issue-20-video-player-usability`).

**Carry**

| Kind | Files | Notes |
| --- | --- | --- |
| Scene | `main.tscn` (Control + `main.gd`) | |
| Script | `main.gd` (711 lines) | Builds the whole player in code: `VideoStreamPlayer`, five thumbnails, transport, Muse state textures, Seedance frame sequences, movable title bar. Keys hard-coded: `1`-`5`, `Space`, `M`, `F`, arrows (seek, or move when the title bar has focus). Publishes `window.risdPlayerState` every 30 frames on web. |
| Fonts | `assets/fonts/LiberationSans-{Regular,Bold}.bytes` + `LICENSE.txt` (Liberation Fonts, SIL OFL 1.1) | Stored as `.bytes` and loaded with `FileAccess.get_file_as_bytes` into a `FontFile` because the editor importer crashed on them (comment at `main.gd:640`). The Web preset must `include_filter` them. |
| Pixels | `assets/fly-through-v7.png` (1.2 MB, the 1536x1632 chrome plate), `assets/source-controls/*.png` + `manifest.json` (idle faces cropped from the plate), `assets/muse-controls/{idle,hover,pressed,settled}.png`, `assets/seedance-motion/*-{hover,pressed,settled}-{0..3}.png` (96 frames) + `manifest.json` + `verification.json`, `assets/thumbnails/{5 ids}.png` | Both manifests are parsed at runtime with `FileAccess`; same `include_filter` need. |
| Provenance already inside the folder | `assets/generation-provenance.json` (Muse run, crops, hashes), `assets/thumbnail-provenance.json` (FFmpeg grabs, hashes), `assets/seedance-motion/manifest.json` (job id, video hash) | The closest thing to the per-module provenance file the map asks for; its shape (schema_version, provider, model, counts, cost, hashes) is a candidate schema. |
| Media, **not in Git** | `media/{1191767929,1187745268,1014865523,1009870521,1008943970}.ogv` | `media/` is gitignored; `main.gd` loads `res://media/<id>.ogv`. The prepared Theora/Vorbis files live at `~/orca/workspaces/risd-godot/issue-18-vimeo-media/runs/issue-18-vimeo-media/prepared/` (45 MB for the first alone; total 66 min of video). `build-web.sh` re-encodes them to 480p/24fps for the browser. |

**Leave behind:** `run.sh`/`build-web.sh` (absolute paths into the issue-18 toolchain: Godot and a BtbN FFmpeg build, hashes in `docs/evidence/video-player-usability/toolchain-lock.json`), `web-export.cfg`, `prepare-source.py`, `conform-motion.py`, `tests/contract.gd`, `tests/browser-preview.cjs`, `tests/fidelity.py`, and on the branch outside the folder: `scripts/prepare_risd_vimeo_media.sh` (a wizard), `scripts/video_media_smoke/`, `docs/evidence/video-player-usability/` (review captures, `media-provenance.json`, `source-faithful-v2/`), `docs/research/native-vimeo-media-contract.md` (worth merging as-is; it is the media contract this port follows).

**Project settings relied on:** viewport 1536x1632 with `window_width_override` 768x816, `stretch/mode="canvas_items"`, `stretch/aspect="expand"` (the script positions everything in 1536x1632 source pixels), `default_texture_filter=1` (linear), `use_nearest_mipmap_filter=true`, `gl_compatibility`, white clear colour. No input map. The web build sets `html/head_include` to force a white page.

**Provenance on record:** `docs/evidence/video-player-usability/media-provenance.json` — per video: Vimeo id, public URL, owner "RISD Museum", permission reference (map #17), acquisition (yt-dlp via public embed HLS, no credentials), source and prepared hashes, codec facts. `toolchain-lock.json` pins Godot/FFmpeg/yt-dlp with hashes. Muse ($0.01) and Seedance ($1.41) runs in `source-faithful-v2/generation-provenance.json`.

**Gaps:** (a) The five videos are downloaded RISD Museum Vimeo uploads under an owner-recorded permission for a usability test; `native-vimeo-media-contract.md` says a "private, temporary review surface may carry the media only for the authorized usability test" — shipping them inside a public web export of the game is outside that record and needs the owner's say. (b) `fly-through-v7.png` is classed "owner-accepted screenshot authority" from a `/tmp/claude-fly-through-20260906` session; what it is a screenshot *of* (logo, subscriber text) is not stated. (c) The last three thumbnail tiles are disabled because their media was never supplied. (d) Media cannot live in the repo (size, and the policy in the contract), so the module needs a documented fetch/prepare step and a build that tolerates missing `.ogv` files (the script already `push_error`s and returns).

## 4. Image viewer chrome (borrowed by the Collection page)

Source: `~/qwen-image-pipeline-worktrees/prototype-81-image-viewer/godot/prototype-image-viewer`, branch `prototype/81-image-viewer`, commit `5d55209`. 54 tracked files.

**Carry (borrow)**

| Kind | Files | Notes |
| --- | --- | --- |
| Scene | `viewer.tscn` (Control + `viewer.gd`) | |
| Scripts | `viewer.gd` (162 lines), `desktop.gd` (48 lines) | `viewer.gd`: a resizable window whose body is a `ScrollContainer` > `HFlowContainer` of seven fixed-size cards cut from the reference at `ART_SCALE 0.375`; drag by title, resize by bottom-right grip, minimum 531x250; frame patching copied from `atlas_window.gd`. `desktop.gd`: eight raster panels placed in a 1944x1280 reference frame, draggable, z-order on click. |
| Shader | `remove-pink.gdshader` (keys magenta within the outer 32 px, `border_width` uniform) | |
| Pixels | `reference.png` (8.8 MB, 4591x2816; the seven artworks and the header/footer are sampled from it at runtime), `assets/{equipment,options,status,trade,chat,party,bottom}.png`, `assets/layout-reference.png` (2.1 MB; the "filters" panel is a region cut from it at runtime) | All are owner-pasted screenshots, unchanged bytes; hashes in `assets/SOURCES.md`. |

The card grid and filter chrome the map names are: the `HFlowContainer` card layout, the window frame with grip, and the "filters" panel region `[13, 550, 535, 245]` of `layout-reference.png`. Everything else in this prototype is decorative screenshot.

**Leave behind:** `evidence/` (22 screenshots + `playtest.json`), `playtest.mjs`, `run.sh`, `export_presets.cfg`, `web/`. `window.imageViewer` JavaScriptBridge publish in `viewer.gd`.

**Project settings relied on:** viewport 1200x800, `stretch/mode="disabled"` (script fits to the viewport), `gl_compatibility`, white clear, `emulate_mouse_from_touch`. Filter: project default (linear). No input map; no keys.

**Provenance / gaps:** `assets/SOURCES.md` records only paste filenames and hashes; the panels are third-party game-UI screenshots (same family as the atlas desktop panels) and `reference.png` is a screenshot of a collection page whose artworks are museum objects. No rights statement for either. No paid generation. For the Collection page the owner's reference image is new (map Notes), so only the two scripts and the shader need to travel; the screenshots do not.

## Settings that collide with the shell

| Setting | Shell (`feat/tab-strip`) | Atlas | Sculpture pair | Video | Image viewer |
| --- | --- | --- | --- | --- | --- |
| viewport | 1920x420 | 1440x900 | 1440x972 | 1536x1632 (window 768x816) | 1200x800 |
| stretch | disabled | disabled | canvas_items | canvas_items, expand | disabled |
| default_texture_filter | 0 nearest | 0 nearest | 1 linear | 1 linear | default (linear) |
| rendering_method | unset | gl_compatibility | gl_compatibility | gl_compatibility | gl_compatibility |
| autoloads / plugins | none | none | StagehandServer autoload, stagehand plugin (drop), mixbox (keep) | none | none |
| runtime-read files needing `include_filter` | `layout.json` | `*.json` | none | `assets/fonts/*.bytes`, two manifests | none |

Consequences for the port: (1) the two `canvas_items` prototypes lay out in fixed source pixels and expect the engine to scale; inside a `disabled`-stretch shell each Page must either wrap the Tenant in a `SubViewportContainer` with `stretch = true` (the atlas already does this for itself) or the Tenant must scale itself as the atlas and image viewer do. (2) Linear-filtered tenants must set `texture_filter` on their own CanvasItems. (3) The shell must set `gl_compatibility` before any Web export (every prototype does; the shell's preset currently inherits the default). (4) Every prototype hard-codes keys with no `InputMap`; the map's "keyboard shortcuts across tabs" item is real — `Home`, `Esc`, arrows and `Space` are claimed by three tenants each. (5) Three prototypes toggle global state (`RenderingServer.set_default_clear_color`, `Input.use_accumulated_input`, `history.replaceState` on the page URL); the Page seam has to forbid or own those.

## Provenance file for each module

The best existing shape is the video player's `assets/generation-provenance.json` (`schema_version`, `issue`, source authority with SHA-256 and classification, then one block per paid run: provider, model, requested/completed counts, actual cost, run record path, per-output hashes). The sculpture and atlas records add fields worth keeping: `classification` strings, `assembly` (what rectangle was edited, "changed_pixels_outside_region"), `spend_usd.cost_state`, and third-party source rows (`url`, `download_sha256`, `license`, `version`). One file per module with those fields covers all four; the licence gaps above become explicit rows with `license: "unknown"` until the owner fills them.

## Licence and provenance gaps, in one list

1. Mixbox: CC BY-NC 4.0; commercial use needs a licence from Secret Weapons. Owner decision before the Sketchbook paintbox ships.
2. tldraw freehand port (`freehand.gd`): the tldraw licence's terms travel with the port and have not been read into any record; no licence file is carried.
3. Third-party game-UI screenshots as chrome: atlas desktop panels and window frame, sculpture sketchbook `ro-*.png`, image-viewer panels. Owner-supplied, no rights record.
4. Museum-object material: the seated Buddha scan (Proton snapshot, no accession or rights row), the seven artworks inside `reference.png`, the five Vimeo videos (recorded permission covers a usability test, not a public export).
5. Attribution owed on screen or in the release page: GeoNames (CC BY 4.0), Liberation Sans (OFL), M+ FONTS, Natural Earth (public domain, attribution optional), Mixbox (CC BY-NC).
6. Records living outside the source tree that must be snapshotted into the module: both Muse ledgers for the atlas (`benchmarks/world-map`, `benchmarks/regional`), `~/muse-runs/sketchbook-window-chrome`, `~/image-edits/...` for the paintbox, `qwen-image-pipeline/.orca/outputs/...` for the clean viewer reference.
