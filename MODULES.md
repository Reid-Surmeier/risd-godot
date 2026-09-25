# Modules

Hand-maintained, one row per `MODULE.md`. Read this first; open a module's `MODULE.md` for the detail.

**Language: GDScript.** The host forces it — Godot 4.7.2 — so the repository skips the template's TypeScript and Effect parts. A module's interface is `interface.gd`, its errors are `errors.gd`, and public functions return an explicit result rather than raising: `{ ok: bool, value: Variant, error: Variant }`. Errors are values here for the same reason Effect makes them values elsewhere.

| Module | Purpose | Interface | Depends on |
| --- | --- | --- | --- |
| [`testing`](testing/MODULE.md) | The harness, fixtures, and test doubles every other module's acceptance tests use | `testing/interface.gd` | — |
| [`sound_cues`](modules/sound_cues/MODULE.md) | Canonical Mr. Baby Paint feedback for generic controls, paint refill, artwork save, and menu close | `modules/sound_cues/interface.gd` | — |
| [`tab_strip`](modules/tab_strip/MODULE.md) | The Windows Live / IE7 toolbar with tabs opened from the blank New Tab stub or fixed by the caller, each owning a page | `modules/tab_strip/interface.gd` | `sound_cues` |
| [`shell`](modules/shell/MODULE.md) | The one Control the game runs in: seven fixed Tabs on the strip along the bottom, each Tab's Tenant created lazily on first show, cross-faded in and frozen while hidden | `modules/shell/interface.gd` | `tab_strip`, `atlas`, `sketchbook`, `sculpture_viewer`, `video_player`, `playground_page`, `flowers_page`, `collection_data`, `sound_cues` (the demo scene's registry and adapters) |
| [`atlas`](modules/atlas/MODULE.md) | The Pixel Atlas as the Map Tab's Tenant: the prototype's whole desktop — four draggable raster panels around a draggable, resizable map window whose SubViewport holds the zoomable pixel world — frozen with the Page | `modules/atlas/interface.gd` | `shell` |
| [`sketchbook`](modules/sketchbook/MODULE.md) | Saved RISD references above the unchanged Mixbox paintbox and native sketchbook windows | `modules/sketchbook/interface.gd` | `shell`, `collection_data`, `sound_cues` |
| [`sculpture_viewer`](modules/sculpture_viewer/MODULE.md) | The 3D Viewer Tab's Tenant: the RISD Museum setup screen — the setup window whose grid objects turn on hover (#110) and the 800x680 viewer window whose SubViewport holds the Buddha scan (drag-orbit, wheel zoom, transport controls) — draggable and stacking, frozen with the Page | `modules/sculpture_viewer/interface.gd` | `shell`, `sound_cues` |
| [`video_player`](modules/video_player/MODULE.md) | The Video Player Tab's Tenant: the Fly Through viewer window on its white desktop, eight artwork tiles of which five play a RISD Museum video, the source-cut controls always shown, paused while hidden | `modules/video_player/interface.gd` | `shell` |
| [`playground_page`](modules/playground_page/MODULE.md) | Retained window frames, browser-local RISD saves, and the draggable WebSurfer comparison window | `modules/playground_page/interface.gd` | `shell`, `collection_data` |
| [`flowers_page`](modules/flowers_page/MODULE.md) | The Flowers Tab's Tenant: Orisinal Flowers as ferryhalim.com runs it (the same SWFs on the same self-hosted Ruffle build), HTML over the canvas in one window on the Web, a still elsewhere | `modules/flowers_page/interface.gd` | `shell` |
| [`collection_data`](modules/collection_data/MODULE.md) | Validated artwork search plus browser-local saved works shared by Playground and Sketchbook | `modules/collection_data/interface.gd` | — |
| [`review`](review/MODULE.md) | The packet an independent blind reviewer receives, and the acceptance contract it judges against | `review/interface.gd` | — |

12 module(s). `sound_cues` owns the shared canonical audio feedback. `tab_strip` is the first game module and `shell` (the main scene) hosts the Tenants; `atlas` (the Map Tab), `sketchbook` (the Sketchbook Tab), `sculpture_viewer` (the 3D Viewer Tab), `video_player` (the Video Player Tab) are the ported Tenants; the Collection Tab shows the owner's framed page (2026-09-25), built in the demo scene; `playground_page` (the Playground Tab) is the owner's composite desktop, into which the Phone Tab folded (#62); `flowers_page` (the Flowers Tab, 2026-09-25) runs Orisinal Flowers; the Tenant modules are decided on the wayfinder map #23, not invented here.
