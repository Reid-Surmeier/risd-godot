# Modules

Hand-maintained, one row per `MODULE.md`. Read this first; open a module's `MODULE.md` for the detail.

Runtime modules use Godot 4.7.2 and GDScript. Their public functions return `{ ok, value, error }`; `testing` and `review` are workflow support modules with the public files listed below.

| Module | Purpose | Interface | Depends on |
| --- | --- | --- | --- |
| [`testing`](testing/MODULE.md) | Support harness, fixtures, and deterministic adapters used by acceptance tests | `testing/interface.gd`, `testing/harness_base.gd` | — |
| [`sound_cues`](modules/sound_cues/MODULE.md) | Canonical Mr. Baby Paint feedback for generic controls, paint refill, artwork save, and menu close | `modules/sound_cues/interface.gd` | — |
| [`tab_strip`](modules/tab_strip/MODULE.md) | The Windows Live / IE7 toolbar with tabs opened from the blank New Tab stub or fixed by the caller, each owning a page | `modules/tab_strip/interface.gd` | `sound_cues` |
| [`shell`](modules/shell/MODULE.md) | The one Control the game runs in: seven fixed Tabs on the strip along the bottom, each Tab's Tenant created lazily on first show, cross-faded in and frozen while hidden | `modules/shell/interface.gd` | `tab_strip`, `atlas`, `sketchbook`, `sculpture_viewer`, `video_player`, `playground_page`, `flowers_page`, `collection_data`, `sound_cues` (the demo scene's registry and adapters) |
| [`atlas`](modules/atlas/MODULE.md) | The Map Tab's draggable Pixel Atlas desktop and zoomable world | `modules/atlas/interface.gd` | — |
| [`sketchbook`](modules/sketchbook/MODULE.md) | The Sketchbook Tab's book, paint tools, unframed painting viewer, and separate framed painting | `modules/sketchbook/interface.gd` | `collection_data`, `sculpture_viewer`, `sound_cues` |
| [`sculpture_viewer`](modules/sculpture_viewer/MODULE.md) | The 3D Viewer Tab's retained catalogue and live viewer windows | `modules/sculpture_viewer/interface.gd` | `sound_cues` |
| [`video_player`](modules/video_player/MODULE.md) | The Video Player Tab's Fly Through and Information windows | `modules/video_player/interface.gd` | — |
| [`playground_page`](modules/playground_page/MODULE.md) | The Playground Tab's retained windows, saved RISD works, journal, and WebSurfer | `modules/playground_page/interface.gd` | `collection_data` |
| [`flowers_page`](modules/flowers_page/MODULE.md) | The Flowers Tab's self-hosted Ruffle presentation | `modules/flowers_page/interface.gd` | — |
| [`collection_data`](modules/collection_data/MODULE.md) | Validated artwork search plus browser-local saved works shared by Playground and Sketchbook | `modules/collection_data/interface.gd` | — |
| [`review`](review/MODULE.md) | Support contract for SHA-bound release review records | `review/MODULE.md`, `docs/releases/<version>/REVIEW.md` | — |

Ten runtime modules and two support modules. `modules/shell/demo.gd` is the composition root: it creates shared collection-data and sound-cue adapters, then registers the seven fixed Tenants. `shell.gd` itself knows only the `tab_strip` seam. The Collection Page is currently composed directly in `demo.gd`; it is not presented as a separate module.
