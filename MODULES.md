# Modules

Hand-maintained, one row per `MODULE.md`. Read this first; open a module's `MODULE.md` for the detail.

**Language: GDScript.** The host forces it — Godot 4.7.2 — so the repository skips the template's TypeScript and Effect parts. A module's interface is `interface.gd`, its errors are `errors.gd`, and public functions return an explicit result rather than raising: `{ ok: bool, value: Variant, error: Variant }`. Errors are values here for the same reason Effect makes them values elsewhere.

| Module | Purpose | Interface | Depends on |
| --- | --- | --- | --- |
| [`testing`](testing/MODULE.md) | The harness, fixtures, and test doubles every other module's acceptance tests use | `testing/interface.gd` | — |
| [`tab_strip`](modules/tab_strip/MODULE.md) | The Windows Live / IE7 toolbar with tabs opened from the blank New Tab stub or fixed by the caller, each owning a page | `modules/tab_strip/interface.gd` | — |
| [`shell`](modules/shell/MODULE.md) | The one Control the game runs in: seven fixed Tabs on the strip along the bottom, each Tab's Tenant created lazily on first show, cross-faded in and frozen while hidden | `modules/shell/interface.gd` | `tab_strip`, `atlas`, `collection_page`, `playground_page`, `phone_page` (the demo scene's registry) |
| [`atlas`](modules/atlas/MODULE.md) | The Pixel Atlas as the Map Tab's Tenant: the prototype's whole desktop — four draggable raster panels around a draggable, resizable map window whose SubViewport holds the zoomable pixel world — frozen with the Page | `modules/atlas/interface.gd` | `shell` |
| [`video_player`](modules/video_player/MODULE.md) | The Video Player Tab's Tenant: the Fly Through viewer window on its white desktop, eight artwork tiles of which five play a RISD Museum video, the source-cut controls always shown, paused while hidden | `modules/video_player/interface.gd` | `shell` |
| [`collection_page`](modules/collection_page/MODULE.md) | The Collection Tab's Tenant: prototype-81's Image Viewer desktop — the eight RO HUD windows and the Image Viewer with its seven artworks, every window draggable and stacking by press, frozen with the Page | `modules/collection_page/interface.gd` | `shell` |
| [`playground_page`](modules/playground_page/MODULE.md) | The Playground Tab's Tenant as a draft mockup: the owner's Digital Playground reference at native size, centred on white | `modules/playground_page/interface.gd` | `shell` |
| [`phone_page`](modules/phone_page/MODULE.md) | The Phone Tab's Tenant as a draft mockup: the owner's Nokia handset reference at native size, centred on white | `modules/phone_page/interface.gd` | `shell` |
| [`review`](review/MODULE.md) | The packet an independent blind reviewer receives, and the acceptance contract it judges against | `review/interface.gd` | — |

8 module(s). `tab_strip` is the first game module and `shell` (the main scene) hosts the Tenants; `atlas` (the Map Tab) and `collection_page` (the Collection Tab) are the ported Tenants; `playground_page` and `phone_page` are the two draft mockups the owner added as Tabs; the Tenant modules are decided on the wayfinder map #23, not invented here.
