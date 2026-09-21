# Modules

Hand-maintained, one row per `MODULE.md`. Read this first; open a module's `MODULE.md` for the detail.

**Language: GDScript.** The host forces it — Godot 4.7.2 — so the repository skips the template's TypeScript and Effect parts. A module's interface is `interface.gd`, its errors are `errors.gd`, and public functions return an explicit result rather than raising: `{ ok: bool, value: Variant, error: Variant }`. Errors are values here for the same reason Effect makes them values elsewhere.

| Module | Purpose | Interface | Depends on |
| --- | --- | --- | --- |
| [`testing`](testing/MODULE.md) | The harness, fixtures, and test doubles every other module's acceptance tests use | `testing/interface.gd` | — |
| [`tab_strip`](modules/tab_strip/MODULE.md) | The Windows Live / IE7 toolbar with tabs opened from the blank New Tab stub or fixed by the caller, each owning a page | `modules/tab_strip/interface.gd` | — |
| [`shell`](modules/shell/MODULE.md) | The one Control the game runs in: six fixed Tabs on the strip along the bottom, each Tab's Tenant created lazily on first show, cross-faded in and frozen while hidden | `modules/shell/interface.gd` | `tab_strip`, `atlas`, `sketchbook`, `sculpture_viewer`, `video_player`, `collection_page`, `playground_page`, `collection_data` (the demo scene's registry and adapters) |
| [`atlas`](modules/atlas/MODULE.md) | The Pixel Atlas as the Map Tab's Tenant: the prototype's whole desktop — four draggable raster panels around a draggable, resizable map window whose SubViewport holds the zoomable pixel world — frozen with the Page | `modules/atlas/interface.gd` | `shell` |
| [`sketchbook`](modules/sketchbook/MODULE.md) | Saved RISD references above the unchanged Mixbox paintbox and native sketchbook windows | `modules/sketchbook/interface.gd` | `shell`, `collection_data` |
| [`sculpture_viewer`](modules/sculpture_viewer/MODULE.md) | The 3D Viewer Tab's Tenant: the Sculpture Viewer prototype's desktop — the catalogue window and the 800x680 viewer window whose SubViewport holds the Buddha scan (drag-orbit, wheel zoom, transport controls) — draggable and stacking, frozen with the Page | `modules/sculpture_viewer/interface.gd` | `shell` |
| [`video_player`](modules/video_player/MODULE.md) | The Video Player Tab's Tenant: the Fly Through viewer window on its white desktop, eight artwork tiles of which five play a RISD Museum video, the source-cut controls always shown, paused while hidden | `modules/video_player/interface.gd` | `shell` |
| [`collection_page`](modules/collection_page/MODULE.md) | Native RISD search controls and verified results inside the existing Image Viewer desktop | `modules/collection_page/interface.gd` | `shell`, `collection_data` |
| [`playground_page`](modules/playground_page/MODULE.md) | Retained window frames, browser-local RISD saves, and the draggable WebSurfer comparison window | `modules/playground_page/interface.gd` | `shell`, `collection_data` |
| [`collection_data`](modules/collection_data/MODULE.md) | Validated artwork search plus browser-local saved works shared by Collection, Playground and Sketchbook | `modules/collection_data/interface.gd` | — |
| [`review`](review/MODULE.md) | The packet an independent blind reviewer receives, and the acceptance contract it judges against | `review/interface.gd` | — |

11 module(s). `tab_strip` is the first game module and `shell` (the main scene) hosts the Tenants; `atlas` (the Map Tab), `sketchbook` (the Sketchbook Tab), `sculpture_viewer` (the 3D Viewer Tab), `video_player` (the Video Player Tab) and `collection_page` (the Collection Tab) are the ported Tenants; `playground_page` (the Playground Tab) is the owner's composite desktop, into which the Phone Tab folded (#62); the Tenant modules are decided on the wayfinder map #23, not invented here.
