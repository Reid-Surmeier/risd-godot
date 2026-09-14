# Modules

Hand-maintained, one row per `MODULE.md`. Read this first; open a module's `MODULE.md` for the detail.

**Language: GDScript.** The host forces it — Godot 4.7.2 — so the repository skips the template's TypeScript and Effect parts. A module's interface is `interface.gd`, its errors are `errors.gd`, and public functions return an explicit result rather than raising: `{ ok: bool, value: Variant, error: Variant }`. Errors are values here for the same reason Effect makes them values elsewhere.

| Module | Purpose | Interface | Depends on |
| --- | --- | --- | --- |
| [`testing`](testing/MODULE.md) | The harness, fixtures, and test doubles every other module's acceptance tests use | `testing/interface.gd` | — |
| [`tab_strip`](modules/tab_strip/MODULE.md) | The Windows Live / IE7 toolbar with tabs opened from the blank New Tab stub or fixed by the caller, each owning a page | `modules/tab_strip/interface.gd` | — |
| [`shell`](modules/shell/MODULE.md) | The one Control the game runs in: six fixed Tabs over the strip, each Tab's Tenant created lazily on first show and frozen while hidden | `modules/shell/interface.gd` | `tab_strip` |
| [`atlas`](modules/atlas/MODULE.md) | The Pixel Atlas as the Map Tab's Tenant: one draggable, resizable map window on the Page whose SubViewport holds the zoomable pixel world, frozen with the Page | `modules/atlas/interface.gd` | — |
| [`review`](review/MODULE.md) | The packet an independent blind reviewer receives, and the acceptance contract it judges against | `review/interface.gd` | — |

5 module(s). `tab_strip` is the first game module and `shell` (the main scene) hosts the Tenants; the Tenant modules are decided on the wayfinder map #23, not invented here. `atlas` is the first Tenant (the Map Tab).
