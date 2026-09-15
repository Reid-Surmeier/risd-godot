## The Sketchbook Tenant: the painting-tool prototype's desktop (variant A, "Sidecar studio") — the
## Mixbox paintbox window with its cat brush rest on the left, the native sketchbook window on the
## right — laid out from the Tenant's own size by the fill rule of ticket #63. Both windows drag by
## their title bars and raise on click; the brush leaves the rest while the pointer is over the palette
## or the page and goes back to it otherwise. Reach it through interface.gd only.
##
## Ported from figma-ui-ux-qwen-pipeline prototype/painting-tool-mixbox @ d2faa30
## viewer-godot/scripts/desktop.gd (enable_paint_prototype("A"), _sync_brush_rest, the drag and raise).
## Left behind: the catalogue and viewer windows (the 3D Viewer Tenant), the A/B/C switcher and its
## Left / Right key cycling, the ?variant / ?perf / ?turn-seconds levers, the perf telemetry and the
## JavaScriptBridge publishes. Changed: the composition is cropped to the two windows with the
## prototype's own right and bottom margins (60, 52), scaled uniformly to the Page and the leftover
## axis given to the book (_fit); pointer positions are made local to the desktop.
extends Control

const Errors := preload("res://modules/sketchbook/errors.gd")

const ROOT := "res://modules/sketchbook/"
## The native composition: variant A's windows (paintbox 170,345 550x575; book 750,365 630x545 on the
## prototype's 1440x972 canvas) moved in to the prototype's right/bottom margins, the book 10 px taller
## so both windows share the bottom edge and the composition's margin is NATIVE_MARGIN on every side.
const NATIVE_MARGIN := Vector2(60, 52)
const DESKTOP_SIZE := Vector2(1330, 679)
const PAINTBOX_SLOT := Rect2(60, 52, 550, 575)
const BOOK_SLOT := Rect2(640, 72, 630, 555)
const REQUIRED := [
	"ro-top-left.png", "ro-top-mid.png", "ro-top-right.png", "ro-left.png", "ro-right.png", "ro-bottom-left.png",
	"ro-bottom-mid.png", "ro-bottom-right.png", "ro-btn-prev.png", "ro-btn-prev-disabled.png", "ro-btn-next.png",
	"sketchbook-page-v005-soft-384.png", "paintbox/palette-white.png", "paintbox/watercolor-brush.png",
	"paintbox/cat-brush-rest.png", "paintbox/brush-tip.gdshader",
]

var key := ""
var ticks := 0
var inputs := 0
var desktop := Control.new()
var windows: Array[Control] = []
var sketchbook: Control
var paintbox: Control
var dragged_window: Control
var drag_offset := Vector2.ZERO
var _slots := {}  # window -> the Rect2 the last _fit gave it


static func create(deps: Dictionary) -> Dictionary:
	for name in REQUIRED:
		if not ResourceLoader.exists(ROOT + "assets/" + name):
			return Errors.err(Errors.ASSET_MISSING, ROOT + "assets/" + name)
	if not ResourceLoader.exists(ROOT + "mixbox/mixbox.gd"):
		return Errors.err(Errors.ASSET_MISSING, ROOT + "mixbox/mixbox.gd")
	var t = load(ROOT + "desktop.gd").new()
	t.key = deps.get("key", "")
	t.name = "Sketchbook"
	t.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return Errors.ok(t)


func _ready() -> void:
	# The prototype's project filtered linearly; this project's default is nearest. Children inherit.
	texture_filter = TEXTURE_FILTER_LINEAR
	desktop.name = "desktop"
	desktop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(desktop)
	var paper := ColorRect.new()
	paper.color = Color.WHITE
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	paper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	desktop.add_child(paper)
	sketchbook = load(ROOT + "sketchbook_window.gd").new()
	sketchbook.name = "sketchbook-window"
	desktop.add_child(sketchbook)
	windows.append(sketchbook)
	sketchbook.title_bar.gui_input.connect(func(event): _drag_handle_input(event, sketchbook))
	paintbox = load(ROOT + "paintbox.gd").new()
	paintbox.name = "paintbox-window"
	desktop.add_child(paintbox)
	windows.append(paintbox)
	paintbox.title_bar.gui_input.connect(func(event): _drag_handle_input(event, paintbox))
	paintbox.color_changed.connect(sketchbook.surface.set_ink_color)
	paintbox.pointer_changed.connect(_sync_brush_rest)
	sketchbook.surface.pointer_changed.connect(_sync_brush_rest)
	sketchbook.surface.set_ink_color(paintbox.brush_color)
	paintbox.set_smear_variant("A")
	_sync_brush_rest()
	visibility_changed.connect(_on_visibility_changed)
	resized.connect(_fit)
	_fit()


func _sync_brush_rest() -> void:
	paintbox.set_brush_active(paintbox.hovering or sketchbook.surface.hovering)


## Hidden with the pointer over the palette or the page: give the arrow back (both hide it) and park
## the brush, since the frozen Page gets no mouse-exit.
func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		return
	Input.set_custom_mouse_cursor(null)
	if paintbox.hovering:
		paintbox.hovering = false
		paintbox.brush_cursor.visible = false
	_sync_brush_rest()


## The fill rule (ticket #63). S is this Tenant's size, D the native composition. All art scales by
## s = min(S.x / D.x, S.y / D.y); the desktop's logical size becomes S / s, so the leftover axis E
## goes to the book window (wider or taller pages) while the paintbox keeps its native size, anchored
## to the top-left corner beside it. A window the user dragged or resized keeps that change
## relative to its slot, clamped inside the desktop.
func _fit() -> void:
	if size.x < 2 or size.y < 2:
		return
	var s := minf(size.x / DESKTOP_SIZE.x, size.y / DESKTOP_SIZE.y)
	var logical := size / s
	var extra := logical - DESKTOP_SIZE
	desktop.scale = Vector2(s, s)
	desktop.position = Vector2.ZERO
	desktop.size = logical
	_place(paintbox, PAINTBOX_SLOT)
	_place(sketchbook, Rect2(BOOK_SLOT.position, BOOK_SLOT.size + extra))


func _place(window: Control, slot: Rect2) -> void:
	var moved := Vector2.ZERO
	var grown := Vector2.ZERO
	if _slots.has(window):
		moved = window.position - _slots[window].position
		grown = window.size - _slots[window].size
	_slots[window] = slot
	window.size = (slot.size + grown).max(window.custom_minimum_size)
	window.position = (slot.position + moved).clamp(Vector2.ZERO, (desktop.size - window.size).max(Vector2.ZERO))


func _drag_handle_input(event: InputEvent, window: Control) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		dragged_window = window
		drag_offset = desktop.make_canvas_position_local(event.global_position) - window.position
		window.accept_event()


func _process(_delta: float) -> void:
	ticks += 1


## Window drag and raise, by the mouse, in the desktop's own pixels (the prototype's desktop.gd _input,
## less the variant key cycling).
func _input(event: InputEvent) -> void:
	inputs += 1
	if dragged_window != null:
		if event is InputEventMouseMotion:
			var limit := (desktop.size - dragged_window.size * dragged_window.scale).max(Vector2.ZERO)
			dragged_window.position = (desktop.make_canvas_position_local(event.position) - drag_offset).clamp(Vector2.ZERO, limit)
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			dragged_window = null
			get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var pointer := desktop.make_canvas_position_local(event.position)
		for index in range(windows.size() - 1, -1, -1):
			var window := windows[index]
			if Rect2(window.position, window.size * window.scale).has_point(pointer):
				desktop.move_child(window, -1)
				windows.erase(window)
				windows.append(window)
				break


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		dragged_window = null


## A Control's rect in global pixels, its own and its ancestors' scale applied.
static func _global_rect(c: Control) -> Rect2:
	return c.get_global_transform() * Rect2(Vector2.ZERO, c.size)


## The paintbox's palette-space rects in global pixels: the image, the 32 wells' hit boxes, the 4 trays.
func _paintbox_rects() -> Dictionary:
	var xf: Transform2D = paintbox.get_global_transform()
	var img: Rect2 = paintbox.image_rect
	var wells := []
	for row in range(2):
		for column in range(16):
			var c := Vector2(paintbox.WELL_START_X + paintbox.WELL_STEP_X * column, paintbox.WELL_Y[row])
			wells.append(xf * Rect2(img.position + (c - paintbox.WELL_HIT) * img.size, paintbox.WELL_HIT * 2.0 * img.size))
	var trays := []
	for tray in paintbox.TRAYS:
		trays.append(xf * Rect2(img.position + tray.position * img.size, tray.size * img.size))
	return {"palette_rect": xf * img, "wells": wells, "trays": trays}


## The harness probe (the Tenant contract): the desktop, the book's state and the paintbox's.
func state() -> Dictionary:
	var s: Dictionary = sketchbook.qa_state()
	var pointer: Dictionary = s.pointer
	var page: Rect2 = sketchbook.page_rect()
	var p: Dictionary = paintbox.qa_state()
	s.erase("pointer")
	s.erase("page_rect")
	s.merge({"key": key, "ticks": ticks, "inputs": inputs, "size": size, "desktop_scale": desktop.scale.x,
			"desktop_logical": desktop.size, "front_window": windows.back().name, "dragging": dragged_window != null,
			"window_rect": _global_rect(sketchbook), "title_rect": _global_rect(sketchbook.title_bar),
			"page_rect": sketchbook.get_global_transform() * page, "window_visible": sketchbook.visible,
			"controls": {"previous": _global_rect(sketchbook.previous_button), "next": _global_rect(sketchbook.next_button)},
			"drawing": pointer.drawing, "hovering": pointer.hovering, "last_stroke_points": pointer.last_stroke_points,
			"ink_color": pointer.ink_color, "last_stroke_color": pointer.last_stroke_color,
			"brush_cursor_visible": sketchbook.surface.pencil.visible,
			"static_update_mode": sketchbook.surface._static_viewport.render_target_update_mode,
			"face_update_mode": sketchbook.face_viewport.render_target_update_mode,
			"paintbox_rect": _global_rect(paintbox), "paintbox_title_rect": _global_rect(paintbox.title_bar),
			"rest_rect": _global_rect(paintbox.brush_rest), "parked_brush_rect": _global_rect(paintbox.parked_brush),
			"brush_parked": p.brush_parked, "brush_color": p.brush_color, "brush_tip_color": p.brush_tip_color,
			"palette_hovering": p.hovering, "palette_cursor_visible": paintbox.brush_cursor.visible,
			"mix_count": p.mix_count, "paint_pixels": p.paint_pixels, "smear_variant": p.smear_variant, "mixbox": p.mixbox})
	s.merge(_paintbox_rects())
	return Errors.ok(s)
