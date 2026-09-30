## The shell seam. Other modules reference this file only. Frozen: changing it is an Issue.
##
## The Shell is the page area with the tab strip along the bottom of the window: the one Control
## the game runs in. At launch it opens seven fixed Tabs in this order — map, sketchbook,
## 3d_viewer, video_player, collection, playground, flowers — with Collection active (the Phone Tab
## folded into the Playground desktop, owner correction 2026-09-14, ticket #62; Flowers added after
## Playground at the owner's request, 2026-09-25), and keeps the
## strip's stub, which opens Blank Pages. Each fixed Tab owns one Page, a plain white surface; the
## Tenant that lives in it is created lazily on the Tab's first show from the registry the caller
## passes in.
##
## Motion (map #23, owner correction). At launch the Collection tab grows in like a stub-opened
## tab (the strip's press and grow, PRESS_SECONDS + GROW_SECONDS) and its Page then fades in over
## FADE_SECONDS. On a tab click the strip dips the clicked tab (pressed tint, PRESS_SECONDS) and the
## new Page cross-fades in over FADE_SECONDS while the old one fades out; the freeze rule below is
## applied once the fade has settled (switch_settled).
##
## The Tenant contract (the Page seam, ticket #24). A Tenant module exposes
##     static func create(deps: Dictionary) -> { ok: bool, value: Control, error }
## on its interface.gd (or the registry holds a Callable with the same signature; the Shell
## passes deps = { "key": String }). The returned Control fills its Page — full-rect anchors —
## (`set_anchors_and_offsets_preset(PRESET_FULL_RECT)`; anchors alone keep a zero rect when the Page
## is already sized) and lays itself out from its own `size` / `resized`, never from the root
## viewport. It exposes
##     func state() -> { ok: bool, value: Dictionary, error }
## the harness probe. The Shell shows a Page with visible = true and process_mode INHERIT; it
## freezes a hidden Page with visible = false, process_mode PROCESS_MODE_DISABLED (no _process,
## no input callbacks, no tweens, no video) and releases any focus inside it; on show it resumes
## with state intact. Inner windows (drag, raise, stack) stay inside each Tenant; a Tenant may
## use real fonts inside its Page; the strip stays font-free. The worked example is
## playtest/dummy_tenant.gd.
##
## Every public function returns { ok: bool, value: Variant, error: Variant }; errors are the
## values in errors.gd; nothing is raised across this seam.
class_name ShellInterface
extends RefCounted

const Errors := preload("res://modules/shell/errors.gd")
const _Impl := preload("res://modules/shell/shell.gd")

## The fixed Tabs in launch order; the key is the tab_strip label key and the registry key.
const FIXED_TABS: Array[String] = [
	"map", "sketchbook", "3d_viewer", "video_player", "collection", "playground", "flowers"
]
const LAUNCH_TAB := "collection"
## The page cross-fade, in seconds. The value every acceptance test asserts against.
const FADE_SECONDS := 0.2


## Build the Shell: a full-rect Control (its own white ground, the PageStack filling the space
## above the bar, the TabStrip along the bottom fitted to its width and re-fitted on resize) with
## the seven fixed Tabs open and Collection active once its launch grow and fade have settled.
## `registry` maps a fixed key to the Tenant that lives in that Tab: a Script whose static
## create(deps) builds it, or a Callable with the same signature. A key with no entry shows a
## plain white Page. Returns ok(Shell node) or the tab_strip error that stopped it.
static func create(registry: Dictionary) -> Dictionary:
	return _Impl.create(registry)


## Make Tab `index` active and show its Page (cross-fade, no dip), creating its Tenant on the first
## show. Returns ok(index) or err(tab_strip.index_out_of_range).
static func select_tab(shell: Control, index: int) -> Dictionary:
	return shell.select_tab(index)


## Close a stub-opened Tab exactly as its close button does. A fixed Tab refuses with TAB_FIXED.
## Returns ok(remaining count) or err(TAB_FIXED | tab_strip.index_out_of_range | tab_strip.open_in_progress).
static func close_tab(shell: Control, index: int) -> Dictionary:
	return shell.close_tab(index)


## The state of a fixed Tab's Tenant, as its own state() reports it.
## Returns err(TENANT_MISSING) while no Tenant exists for `key` (no registry entry, or not shown
## yet), err(TENANT_FAILED) when its create failed, else the Tenant's own result.
static func tenant_state(shell: Control, key: String) -> Dictionary:
	return shell.tenant_state(key)


## Everything a harness needs, in the Shell's own pixels (the strip is scaled to fit):
## ok({ count, active, opening, pressed, switching, fixed_count, bar_rect, stub_rect,
##      tabs: [{ key, label, fixed, page_visible, frozen, tenant: null | String (error code),
##               rect, close_rect }] }).
## `frozen` is whether the Page's process_mode is DISABLED; `tenant` is null before creation or
## the error code if creation failed, "ok" once the Tenant lives in the Page; `pressed` is the
## strip's dipping tab or -1; `switching` is true while a Page cross-fade runs (two Pages may be
## visible then); `bar_rect` is where the strip sits.
static func state(shell: Control) -> Dictionary:
	return shell.state()

## Signals on the Shell node:
##   tenant_created(key: String)  — the Tenant for `key` now lives in its Page
##   switch_settled(index: int)   — the cross-fade to Tab `index` is done and the freeze rule applied
## The strip's own signals (tab_selected and the rest) are on the strip and are not re-emitted.
