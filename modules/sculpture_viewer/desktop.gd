## The 3D Viewer Tenant: the Sculpture Viewer prototype's desktop — a white 1440x972 ground with
## the catalogue window (the sidebar picture, drag only) and the 800x680 viewer window (viewer.gd)
## — filling the Page at one uniform scale (#63). Windows drag by their handles, raise on click and stack. Reach it
## through interface.gd only.
##
## Ported from figma-ui-ux-qwen-pipeline prototype/painting-tool-mixbox @ 7ee5e9c
## viewer-godot/scripts/desktop.gd. Left behind: the sketchbook window and the Mixbox paintbox with
## its variant switcher (the Sketchbook Tenant; ticket #36), the ?qa-viewer isolation, the perf
## telemetry and the JavaScriptBridge publishes. Changed: the desktop is a child scaled to fit the
## Tenant's own size / resized (never the root viewport), pointer positions are made local to it,
## and the drag clamp is against the desktop, as the prototype's was.
extends Control

const Errors := preload("res://modules/sculpture_viewer/errors.gd")

const ROOT := "res://modules/sculpture_viewer/"
const DESKTOP_SIZE := Vector2(1440, 972)  # the prototype's canvas (references/statue-viewer-desktop)
const CATALOGUE_AT := Vector2(72, 34)
const VIEWER_SIZE := Vector2(800, 680)
## The viewer window's slot (#63): from its native top-left to the desktop's far edges less the
## desktop's native right margin (the viewer ends 52 px from it) and bottom margin (the catalogue
## ends 44 px from it).
const VIEWER_AT := Vector2(600, 34)
const VIEWER_FAR_GAP := Vector2(52, 44)
const REQUIRED := [
	"assets/catalogue/sidebar.png", "assets/clean-ui/background.png", "assets/clean-ui/timer-source.png",
	"assets/control-motion/previous.png", "assets/control-motion/next.png", "assets/control-motion/play-pause.png",
	"assets/control-motion/audio.png", "assets/control-motion/menu.png", "assets/control-motion/scrubber.png",
	"assets/control-motion/track-empty.png", "assets/control-motion/track-fill.png",
	"assets/models/proton-buddha-3124123123.glb", "assets/models/3124123123.jpg",
	"shaders/player_base.gdshader", "shaders/control_face.gdshader",
]

var key := ""
var ticks := 0
var inputs := 0
var desktop := Control.new()
var windows: Array[Control] = []
var catalogue: Control
var viewer_window: Control
var viewer: Control
var dragged_window: Control
var drag_offset := Vector2.ZERO


static func create(deps: Dictionary) -> Dictionary:
	for path in REQUIRED:
		if not ResourceLoader.exists(ROOT + path):
			return Errors.err(Errors.ASSET_MISSING, ROOT + path)
	var t = load(ROOT + "desktop.gd").new()
	t.key = deps.get("key", "")
	t.name = "SculptureViewer"
	t.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return Errors.ok(t)


## The same live 800x680 viewer used by the Tenant, for an owner-approved host such as Sketchbook.
static func embedded_viewer() -> Dictionary:
	for path in REQUIRED:
		if not ResourceLoader.exists(ROOT + path):
			return Errors.err(Errors.ASSET_MISSING, ROOT + path)
	var embedded = load(ROOT + "viewer.gd").new()
	embedded.name = "embedded-3d-viewer"
	return Errors.ok(embedded)


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
	catalogue = _window("catalogue-window", CATALOGUE_AT, Vector2(400, 400.0 * 5101 / 2276))
	var artwork := TextureRect.new()
	artwork.texture = load(ROOT + "assets/catalogue/sidebar.png")
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.size = catalogue.size
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	catalogue.add_child(artwork)
	catalogue.mouse_default_cursor_shape = Control.CURSOR_DRAG
	catalogue.gui_input.connect(func(event): _drag_handle_input(event, catalogue))
	catalogue.tooltip_text = "Drag to move the catalogue"
	viewer_window = _window("viewer-window", VIEWER_AT, VIEWER_SIZE)
	viewer_window.scale = Vector2(0.985, 0.985)  # the prototype's; _fit sizes it to its slot
	viewer = load(ROOT + "viewer.gd").new()
	viewer.name = "viewer"
	viewer_window.add_child(viewer)
	# These strips never cover the sculpture, arrow buttons or transport controls.
	for rect in [Rect2(12, 4, 776, 32), Rect2(12, 644, 776, 28)]:
		var handle := Control.new()
		handle.position = rect.position
		handle.size = rect.size
		handle.mouse_default_cursor_shape = Control.CURSOR_DRAG
		handle.tooltip_text = "Drag the frame to move the viewer"
		handle.gui_input.connect(func(event): _drag_handle_input(event, viewer_window))
		viewer_window.add_child(handle)
	resized.connect(_fit)
	_fit()


## The desktop fills the Page (#63): one uniform scale s = min(page / DESKTOP_SIZE) for all the
## window art, the desktop's own pixels spanning the whole Page (size / s). The catalogue keeps its
## native place by the top-left edges it sits nearest. The viewer window is a raster plate that
## cannot re-lay out, so it scales uniformly to the largest size that fits its slot — its native
## top-left to the page's right and bottom edges less the desktop's native margins — and centres
## there. Laid out again on every resize.
func _fit() -> void:
	if size.x < 2 or size.y < 2:
		return
	dragged_window = null
	var s := minf(size.x / DESKTOP_SIZE.x, size.y / DESKTOP_SIZE.y)
	desktop.scale = Vector2(s, s)
	desktop.position = Vector2.ZERO
	desktop.size = size / s
	catalogue.position = CATALOGUE_AT
	var slot := desktop.size - VIEWER_FAR_GAP - VIEWER_AT
	var k := minf(slot.x / VIEWER_SIZE.x, slot.y / VIEWER_SIZE.y)
	viewer_window.scale = Vector2(k, k)
	viewer_window.position = VIEWER_AT + (slot - VIEWER_SIZE * k) / 2


func _window(window_name: String, origin: Vector2, dimensions: Vector2) -> Control:
	var window := Control.new()
	window.name = window_name
	window.position = origin
	window.size = dimensions
	desktop.add_child(window)
	windows.append(window)
	return window


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


## The harness probe (the Tenant contract): the desktop's windows plus the viewer's own state.
func state() -> Dictionary:
	var s: Dictionary = viewer.qa_state()
	var controls := {}
	for entry in [["previous", viewer.previous_button], ["next", viewer.next_button], ["play-pause", viewer.play_button],
			["scrubber", viewer.progress_slider], ["audio", viewer.audio_button], ["menu", viewer.menu_button]]:
		controls[entry[0]] = _global_rect(entry[1])
	s.merge({"key": key, "ticks": ticks, "inputs": inputs, "size": size, "desktop_scale": desktop.scale.x,
			"pointer_scale": desktop.scale.x * viewer_window.scale.x, "front_window": windows.back().name, "dragging": dragged_window != null,
			"catalogue_rect": _global_rect(catalogue), "viewer_rect": _global_rect(viewer_window),
			"viewport_rect": _global_rect(viewer.viewport_container), "controls": controls,
			"viewport_update_mode": viewer.viewport_container.get_child(0).render_target_update_mode})
	return Errors.ok(s)
