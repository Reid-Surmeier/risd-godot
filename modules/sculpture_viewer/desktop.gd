## The 3D Viewer Tenant: the RISD Museum setup screen (Issue #110) — a white 2540x1680 ground with
## the setup panel window (the approved raster: header, the 40-object grid, form, Global Chatroom and
## friends list, drag only) whose animated objects turn on hover, and the 800x680 viewer window
## (viewer.gd) with the live Buddha scan where the screen's mock-up viewer stood — filling the Page at
## one uniform scale (#63). Windows drag by their handles, raise on click and stack. Reach it through
## interface.gd only.
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
## The setup screen at 1x (image-work/paintbox-3d-layout/sculpture-row-risd/review/
## paintbox-3d-risd-five-rows-text-refined-2x-v12.png halved).
const DESKTOP_SIZE := Vector2(2540, 1680)
const CATALOGUE_AT := Vector2.ZERO
const PANEL_SIZE := Vector2(1050, 1680)  # assets/setup/panel-2x.png, the raster's x 0..2100 at 2x
const VIEWER_SIZE := Vector2(800, 680)
## The mock-up viewer's frame in that raster: x 2143..4857, y 78.. at 2x.
const VIEWER_AT := Vector2(1071.5, 39)
const VIEWER_SCALE := 1357.0 / 800.0
## Grid cells whose object turns on hover: top-left in the desktop's 1x pixels (template-matched
## against the raster, exact), and the number of frames in assets/setup/turn/<name>.png, packed
## eight 216x200 tiles per row. Frame 0 is the approved icon.
const CELL_SIZE := Vector2(108, 100)
const TURNING := {
	"01-staff": [Vector2(40, 205), 41],
	"02-green-sculpture": [Vector2(165, 205), 73],
	"03-horse-rider": [Vector2(291, 205), 13],
	"04-gold-couch": [Vector2(418, 205), 61],
	"05-bust": [Vector2(531, 205), 73],
	"06-bowl": [Vector2(650, 205), 50],
	"07-bull": [Vector2(761, 205), 24],
	"08-dog": [Vector2(888, 205), 24],
	"1557236": [Vector2(165, 385), 73],
	"1552311": [Vector2(418, 385), 73],
	"1532371": [Vector2(531, 385), 73],
	"1487831": [Vector2(650, 385), 73],
	"1581601": [Vector2(761, 385), 25],
	"1573591": [Vector2(888, 385), 73],
	"1554066": [Vector2(165, 575), 73],
	"1548171": [Vector2(291, 575), 73],
	"1264886": [Vector2(418, 575), 25],
	"1344456": [Vector2(531, 575), 25],
}
const REQUIRED := [
	"assets/setup/panel-2x.png", "assets/clean-ui/background.png", "assets/clean-ui/timer-source.png",
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
	catalogue = _window("setup-window", CATALOGUE_AT, PANEL_SIZE)
	var artwork := TextureRect.new()
	artwork.texture = load(ROOT + "assets/setup/panel-2x.png")
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.size = catalogue.size
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Drawn at about a third of its pixels on a 1080p page; without mipmaps the type aliases.
	artwork.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	catalogue.add_child(artwork)
	catalogue.mouse_default_cursor_shape = Control.CURSOR_DRAG
	catalogue.gui_input.connect(func(event): _drag_handle_input(event, catalogue))
	catalogue.tooltip_text = "Drag to move the setup window"
	for cell_name in TURNING:
		var cell = load(ROOT + "turn_cell.gd").new()
		cell.name = "turn-" + cell_name
		cell.atlas = load(ROOT + "assets/setup/turn/%s.png" % cell_name)
		cell.frames = TURNING[cell_name][1]
		cell.position = TURNING[cell_name][0]
		cell.size = CELL_SIZE
		cell.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		catalogue.add_child(cell)
	viewer_window = _window("viewer-window", VIEWER_AT, VIEWER_SIZE)
	viewer_window.scale = Vector2(VIEWER_SCALE, VIEWER_SCALE)
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
## window art, the desktop's own pixels spanning the whole Page (size / s). The setup window and the
## viewer keep the places the setup screen gives them, the viewer exactly over the mock-up it
## replaces. Laid out again on every resize (a dragged window goes back to its place).
func _fit() -> void:
	if size.x < 2 or size.y < 2:
		return
	dragged_window = null
	var s := minf(size.x / DESKTOP_SIZE.x, size.y / DESKTOP_SIZE.y)
	desktop.scale = Vector2(s, s)
	desktop.position = Vector2.ZERO
	desktop.size = size / s
	catalogue.position = CATALOGUE_AT
	viewer_window.position = VIEWER_AT


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
			dragged_window.position = (desktop.make_canvas_position_local(event.position) - drag_offset).clamp(_margin_low(), limit)
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


## The top-left a window may be dragged to, in desktop px: the page's own left margin too, when this
## Tenant was placed with one (offset_left, e.g. the Shell's desktop-icon strip).
func _margin_low() -> Vector2:
	return Vector2(-offset_left / desktop.scale.x, 0)
