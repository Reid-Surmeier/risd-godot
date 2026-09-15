## The sketchbook seam. Other modules reference this file only. Frozen: changing it is an Issue.
##
## The Sketchbook is the Sketchbook Tab's Tenant (map #23). It satisfies the Shell's Tenant contract
## (modules/shell/interface.gd): create(deps) returns a full-rect Control that lays itself out from its
## own size / resized, and state() is the harness probe. Its Page is the painting-tool prototype's
## desktop at d2faa30 (tickets #48, #49 — the owner put the Mixbox paintbox back): the paintbox window
## (the white palette's 32 wells load pigment, dragging through its four trays smears and mixes with
## Mixbox 2.0 pigment math, the brush carries what it picked up) with the cat brush rest below the
## palette, where the brush lies, tip in the carried pigment, whenever the pointer is off the palette
## and the page; and the native sketchbook window — the owner's Ragnarok-style chrome, tldraw's freehand
## ink ported line by line in the carried pigment, one stroke list per spread, the 520 ms perspective
## paper turn, the pigment-loaded brush cursor over the page. It lays out by the fill rule (ticket #63):
## saved RISD references sit above both working windows. Art scales uniformly by s = min(S / D), the
## book window takes the leftover axis. Both windows drag by their title bars; a hidden Page freezes it.
##
## Every public function returns { ok: bool, value: Variant, error: Variant }; errors are the
## values in errors.gd; nothing is raised across this seam.
class_name SketchbookInterface
extends RefCounted

const Errors := preload("res://modules/sketchbook/errors.gd")
const _Impl := preload("res://modules/sketchbook/desktop.gd")
const Data := preload("res://modules/collection_data/interface.gd")


## Build the Sketchbook Tenant. `deps` includes key, collection_data and image_fetch; the key is
## recorded. Every pixel file the window loads is checked first: returns ok(Control) or
## err(ASSET_MISSING, path).
static func create(deps: Dictionary) -> Dictionary:
	if not deps.has("collection_data") or not Data.state(deps.collection_data).ok:
		return Errors.err(Errors.INVALID_DEPENDENCY, "A collection_data handle is required")
	if not deps.get("image_fetch") is Callable or not deps.image_fetch.is_valid():
		return Errors.err(Errors.INVALID_DEPENDENCY, "An image fetch operation is required")
	return _Impl.create(deps)


## The harness probe. Rects are global pixels:
## ok({ key, ticks, inputs, size: Vector2 (the Tenant), desktop_scale (s), desktop_logical: Vector2 (S / s),
##      front_window, dragging, window_rect: Rect2 (the book window), page_rect: Rect2 (the drawable page),
##      title_rect: Rect2, controls: { previous, next: Rect2 }, window_visible, spread, strokes (on the open
##      spread), turning: "" | "forward" | "backward", turn_progress, last_turn_ms, previous_disabled,
##      drawing, hovering (over the page), last_stroke_points, ink_color, last_stroke_color,
##      brush_cursor_visible (over the page), static_update_mode, face_update_mode,
##      paintbox_rect, paintbox_title_rect, palette_rect, wells: Array[Rect2] (32, row by row),
##      trays: Array[Rect2] (4), rest_rect, parked_brush_rect: Rect2, brush_parked, brush_color,
##      brush_tip_color (html, no alpha), palette_hovering, palette_cursor_visible, mix_count,
##      paint_pixels, smear_variant, mixbox, saved_ids, selected_reference, storage_status,
##      reference_rect, reference_cards: [{id, rect}] }).
## `ticks` counts the desktop's _process frames and `inputs` its _input events: both stand still
## while the Page is frozen. The two update modes are the render_target_update_mode of the finished-
## ink SubViewport and of the paper-turn face SubViewport (0 = UPDATE_DISABLED: quiet).
static func state(tenant: Control) -> Dictionary:
	return tenant.state()
