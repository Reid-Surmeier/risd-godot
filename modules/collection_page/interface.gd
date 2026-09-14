## The collection_page seam. Other modules reference this file only. Frozen: changing it is an Issue.
##
## The Collection Tab's Tenant is prototype-81's Image Viewer desktop (map #23, owner correction:
## a Tab shows the prototype's whole desktop with all its windows, exactly as its reference
## screenshot). On the Page's white desktop: the eight RO HUD windows — equipment, options,
## search filters, status, trade, chat room, party, the bottom bar — each the owner's own
## screenshot with its magenta border keyed out, and the Image Viewer window, whose header and
## footer ("number of works: 12") are patched from the reference sheet and whose body is a
## vertical-only scroll of the seven artworks cut from that same sheet at fixed size. Every window
## drags by its title bar (the bottom bar anywhere on its surface), a press raises it to the top,
## only the topmost window under the pointer takes the drag, and a drag stops at the Page's edge;
## the viewer also resizes by its bottom-right corner. The desktop lays its windows out from the
## reference's 1944x1280 review coordinates fitted to the Page, and re-fits on a Page resize.
## The other controls inside the windows are decorative, as in the prototype.
##
## Tenant contract (shell/interface.gd): create(deps) returns a full-rect Control that lays itself
## out from its own size / resized; state() is the harness probe; the Shell freezes the Page while
## hidden (no _process, no input) and resumes it intact. No font is used.
##
## Every public function returns { ok: bool, value: Variant, error: Variant }; errors are the
## values in errors.gd; nothing is raised across this seam.
class_name CollectionPageInterface
extends RefCounted

const Errors := preload("res://modules/collection_page/errors.gd")
const _Impl := preload("res://modules/collection_page/viewer.gd")


## Build the desktop. `deps` is what the Shell passes, { "key": String }; the key is recorded.
## Every pixel file is checked first: returns ok(Control) or err(ASSET_MISSING, path).
static func create(deps: Dictionary) -> Dictionary:
	return _Impl.create(deps)


## The harness probe, in the Tenant's own pixels:
## ok({ key, ticks, inputs, size: Vector2, factor, action: "" | "drag" | "resize",
##      windows: [{ name, rect: Rect2, drag_height, order }] (the eight HUD windows and "viewer",
##          in the tree order that is also their stacking order — the last is on top),
##      viewer: { rect: Rect2, scale, scroll, scroll_max, body: Rect2 (the visible artwork area),
##          cards: [Rect2] (the seven artworks, in the sheet's order, unclipped) } }).
## `ticks` counts _process frames and `inputs` counts _input events: both stand still while the
## Page is frozen.
static func state(tenant: Control) -> Dictionary:
	return tenant.state()
