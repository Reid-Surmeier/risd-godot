## The collection_page seam. Other modules reference this file only. Frozen under issue #79.
##
## The Collection Tab's Tenant is prototype-81's Image Viewer desktop. The search-filter window
## contains native editable controls, and the Image Viewer contains verified results returned by
## collection_data with live count, provenance, freshness and selection details. The remaining
## seven HUD windows keep the owner's pixels with their magenta border keyed out. Every window
## drags by its title bar (the bottom bar anywhere on its surface), a press raises it to the top,
## only the topmost window under the pointer takes the drag, and a drag stops at the Page's edge;
## the viewer also resizes by its bottom-right corner. The desktop lays its windows out from the
## reference's 1944x1280 review coordinates fitted to the Page, and re-fits on a Page resize.
## Selecting a result exposes its attribution and a Save action. Saved is shown only after the
## shared collection_data transaction commits; repeats preserve the first snapshot and timestamp.
##
## Tenant contract (shell/interface.gd): create(deps) returns a full-rect Control that lays itself
## out from its own size / resized; state() is the harness probe; the Shell freezes the Page while
## hidden (no _process, no input) and resumes it intact. Native controls use the source pixel font.
##
## Every public function returns { ok: bool, value: Variant, error: Variant }; errors are the
## values in errors.gd; nothing is raised across this seam.
class_name CollectionPageInterface
extends RefCounted

const Errors := preload("res://modules/collection_page/errors.gd")
const _Impl := preload("res://modules/collection_page/viewer.gd")
const Data := preload("res://modules/collection_data/interface.gd")


## Build the desktop. `deps` includes a collection_data handle and image_fetch(sha256, done).
## Every pixel file is checked first: returns ok(Control) or err(ASSET_MISSING, path).
static func create(deps: Dictionary) -> Dictionary:
	if not deps.has("collection_data") or not Data.state(deps.collection_data).ok:
		return Errors.err(Errors.INVALID_DEPENDENCY, "A collection_data handle is required")
	if not deps.get("image_fetch") is Callable or not deps.image_fetch.is_valid():
		return Errors.err(Errors.INVALID_DEPENDENCY, "An image fetch operation is required")
	return _Impl.create(deps)


## The harness probe, in the Tenant's own pixels:
## ok({ key, ticks, inputs, size: Vector2, factor, action: "" | "drag" | "resize",
##      windows: [{ name, rect: Rect2, drag_height, order }] (the eight HUD windows and "viewer",
##          in the tree order that is also their stacking order — the last is on top),
##      viewer: { rect: Rect2, scale, scroll, scroll_max, body: Rect2 },
##      search: { phase, draft, applied, last_successful, requests, completions,
##          ignored_completions, response, items, selected, images_loaded, controls,
##          focus_owner, sort_popup, category_popup } }).
## `ticks` counts _process frames and `inputs` counts _input events: both stand still while the
## Page is frozen.
static func state(tenant: Control) -> Dictionary:
	return tenant.state()
