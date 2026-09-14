## The sketchbook seam. Other modules reference this file only. Frozen: changing it is an Issue.
##
## The Sketchbook is the Sketchbook Tab's Tenant (map #23, ticket #32: two Tenants sharing nothing
## but the Shell; the book alone on its page; no Mixbox paintbox in v0.1.0). It satisfies the
## Shell's Tenant contract (modules/shell/interface.gd): create(deps) returns a full-rect Control
## that lays itself out from its own size / resized, and state() is the harness probe. Its Page is
## the prototype's desktop with the one native sketchbook window: the owner's Ragnarok-style chrome
## around the book, tldraw's freehand ink ported line by line (4.5 px, #4465e9, bowed toward the
## spine), one stroke list per spread, the 520 ms perspective paper turn on the arrows carrying the
## outgoing page's ink, the pencil cursor over the page. The window drags by its title bar and
## resizes from its corner; a hidden Page freezes it and its SubViewports stay quiet.
##
## Every public function returns { ok: bool, value: Variant, error: Variant }; errors are the
## values in errors.gd; nothing is raised across this seam.
class_name SketchbookInterface
extends RefCounted

const Errors := preload("res://modules/sketchbook/errors.gd")
const _Impl := preload("res://modules/sketchbook/desktop.gd")


## Build the Sketchbook Tenant. `deps` is what the Shell passes, { "key": String }; the key is
## recorded. Every pixel file the window loads is checked first: returns ok(Control) or
## err(ASSET_MISSING, path).
static func create(deps: Dictionary) -> Dictionary:
	return _Impl.create(deps)


## The harness probe. Rects are global pixels:
## ok({ key, ticks, inputs, size: Vector2 (the Tenant), desktop_scale, front_window, dragging,
##      window_rect: Rect2, page_rect: Rect2 (the drawable page), title_rect: Rect2,
##      controls: { previous, next: Rect2 }, window_visible, spread, strokes (on the open spread),
##      turning: "" | "forward" | "backward", turn_progress, last_turn_ms, previous_disabled,
##      drawing, hovering, last_stroke_points, ink_color, static_update_mode, face_update_mode }).
## `ticks` counts the desktop's _process frames and `inputs` its _input events: both stand still
## while the Page is frozen. The two update modes are the render_target_update_mode of the finished-
## ink SubViewport and of the paper-turn face SubViewport (0 = UPDATE_DISABLED: quiet).
static func state(tenant: Control) -> Dictionary:
	return tenant.state()
