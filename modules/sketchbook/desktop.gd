## The Sketchbook Tenant: the Sculpture Viewer prototype's desktop with the book alone (ticket
## #32) — a white 1440x972 ground, scaled to fit the Page, holding the native sketchbook window
## (sketchbook_window.gd) where the prototype put it. The window drags by its title bar and raises
## on click. Reach it through interface.gd only.
##
## Ported from figma-ui-ux-qwen-pipeline prototype/painting-tool-mixbox @ 7ee5e9c
## viewer-godot/scripts/desktop.gd. Left behind: the catalogue and viewer windows (the 3D Viewer
## Tenant), the Mixbox paintbox with its variant switcher and key cycling (ticket #36), the
## ?turn-seconds lever, the perf telemetry and the JavaScriptBridge publishes. Changed: the desktop
## is a child scaled to fit the Tenant's own size / resized (never the root viewport), pointer
## positions are made local to it. The ~40 window-dragging lines are duplicated in
## modules/sculpture_viewer/desktop.gd on purpose (ticket #32; the stacking decision is #24's).
extends Control

const Errors := preload("res://modules/sketchbook/errors.gd")

const ROOT := "res://modules/sketchbook/"
const DESKTOP_SIZE := Vector2(1440, 972)  # the prototype's canvas
const REQUIRED := [
	"ro-top-left", "ro-top-mid", "ro-top-right", "ro-left", "ro-right", "ro-bottom-left", "ro-bottom-mid",
	"ro-bottom-right", "ro-btn-prev", "ro-btn-prev-disabled", "ro-btn-next", "sketchbook-page-v005-soft-384",
	"pencil-prototype",
]

var key := ""
var ticks := 0
var inputs := 0
var desktop := Control.new()
var windows: Array[Control] = []
var sketchbook: Control
var dragged_window: Control
var drag_offset := Vector2.ZERO


static func create(deps: Dictionary) -> Dictionary:
	for name in REQUIRED:
		if not ResourceLoader.exists(ROOT + "assets/" + name + ".png"):
			return Errors.err(Errors.ASSET_MISSING, ROOT + "assets/" + name + ".png")
	var t = load(ROOT + "desktop.gd").new()
	t.key = deps.get("key", "")
	t.name = "Sketchbook"
	t.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return Errors.ok(t)


func _ready() -> void:
	# The prototype's project filtered linearly; this project's default is nearest. Children inherit.
	texture_filter = TEXTURE_FILTER_LINEAR
	desktop.name = "desktop"
	desktop.size = DESKTOP_SIZE
	desktop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(desktop)
	var paper := ColorRect.new()
	paper.color = Color.WHITE
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	paper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	desktop.add_child(paper)
	sketchbook = load(ROOT + "sketchbook_window.gd").new()
	sketchbook.name = "sketchbook-window"
	sketchbook.position = Vector2(740, 460)
	sketchbook.size = Vector2(620, 500)
	desktop.add_child(sketchbook)
	windows.append(sketchbook)
	sketchbook.title_bar.gui_input.connect(func(event): _drag_handle_input(event, sketchbook))
	resized.connect(_fit)
	_fit()


## The desktop keeps the prototype's pixels 1:1 where they fit and shrinks to fit a smaller Page,
## centred either way.
func _fit() -> void:
	if size.x < 2 or size.y < 2:
		return
	var s := minf(1.0, minf(size.x / DESKTOP_SIZE.x, size.y / DESKTOP_SIZE.y))
	desktop.scale = Vector2(s, s)
	desktop.position = ((size - DESKTOP_SIZE * s) / 2).round()


func _drag_handle_input(event: InputEvent, window: Control) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		dragged_window = window
		drag_offset = desktop.make_canvas_position_local(event.global_position) - window.position
		window.accept_event()


func _process(_delta: float) -> void:
	ticks += 1


## Window drag and raise, by the mouse, in the desktop's own pixels (desktop.gd:206-250 of the
## prototype, less the paintbox key cycling).
func _input(event: InputEvent) -> void:
	inputs += 1
	if dragged_window != null:
		if event is InputEventMouseMotion:
			var limit := (DESKTOP_SIZE - dragged_window.size * dragged_window.scale).max(Vector2.ZERO)
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


## The harness probe (the Tenant contract): the desktop plus the window's own state.
func state() -> Dictionary:
	var s: Dictionary = sketchbook.qa_state()
	var pointer: Dictionary = s.pointer
	var page: Rect2 = sketchbook.page_rect()
	s.erase("pointer")
	s.erase("page_rect")
	s.merge({"key": key, "ticks": ticks, "inputs": inputs, "size": size, "desktop_scale": desktop.scale.x,
			"front_window": windows.back().name, "dragging": dragged_window != null,
			"window_rect": _global_rect(sketchbook), "title_rect": _global_rect(sketchbook.title_bar),
			"page_rect": sketchbook.get_global_transform() * page, "window_visible": sketchbook.visible,
			"controls": {"previous": _global_rect(sketchbook.previous_button), "next": _global_rect(sketchbook.next_button)},
			"drawing": pointer.drawing, "hovering": pointer.hovering, "last_stroke_points": pointer.last_stroke_points,
			"ink_color": pointer.ink_color,
			"static_update_mode": sketchbook.surface._static_viewport.render_target_update_mode,
			"face_update_mode": sketchbook.face_viewport.render_target_update_mode})
	return Errors.ok(s)
