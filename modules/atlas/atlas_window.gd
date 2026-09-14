## The Pixel Atlas map window: one draggable, resizable, collapsible frame (sliced from
## assets/window-frame.png) whose body is a SubViewport holding atlas.gd. Reach it through
## interface.gd only.
##
## Ported from qwen-pipeline-experiments prototype/atlas-5 @ 421f1cc atlas_window.gd. Left behind:
## the four desktop panels, the under-750-px phone layout, the clear-colour override and the
## JavaScriptBridge publishes. Changed: it lays out from its own size / resized (never the root
## viewport) and pointer positions are made local to it.
extends Control

const Errors := preload("res://modules/atlas/errors.gd")

const ROOT := "res://modules/atlas/"
const INSET := Vector2(36, 94)
const FRAME_EXTRA := Vector2(72, 136)
const FRAME_SIZE := Vector2(1158, 954)  # the prototype's map window on its 1950x1280 desktop
const MARGIN := 24.0

var key := ""
var ticks := 0
var inputs := 0
var frame := Control.new()
var chrome := Control.new()
var frame_texture: Texture2D
var chrome_scale := 1.0
var minimize := TextureButton.new()
var lock_button := TextureButton.new()
var container := SubViewportContainer.new()
var viewport := SubViewport.new()
var map: Node2D
var locked := false
var collapsed := false
var expanded_size := Vector2.ZERO
var action := ""
var edges := Vector2i.ZERO
var start_pointer := Vector2.ZERO
var start_rect := Rect2()


static func create(deps: Dictionary) -> Dictionary:
	if not FileAccess.file_exists(ROOT + "atlas.json"):
		return Errors.err(Errors.ASSET_MISSING, ROOT + "atlas.json")
	var atlas = JSON.parse_string(FileAccess.get_file_as_string(ROOT + "atlas.json"))
	if not (atlas is Dictionary and atlas.has("regions")):
		return Errors.err(Errors.ASSET_MISSING, ROOT + "atlas.json (unreadable)")
	if not FileAccess.file_exists(ROOT + "close-cities.json"):
		return Errors.err(Errors.ASSET_MISSING, ROOT + "close-cities.json")
	var t = load(ROOT + "atlas_window.gd").new()
	t.key = deps.get("key", "")
	t.name = "Atlas"
	t.frame_texture = load(ROOT + "assets/window-frame.png")
	t.map = load(ROOT + "atlas.gd").new()
	t.map.atlas = atlas
	t.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return Errors.ok(t)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.name = "map"
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)
	minimize.ignore_texture_size = true
	minimize.tooltip_text = "Collapse / expand map"
	minimize.pressed.connect(_collapse)
	lock_button.ignore_texture_size = true
	lock_button.tooltip_text = "Lock / unlock window position and size"
	lock_button.pressed.connect(func():
		locked = not locked
		lock_button.tooltip_text = "Unlock window" if locked else "Lock window")
	container.stretch = true
	container.clip_contents = true
	frame.add_child(container)
	chrome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chrome.draw.connect(_draw_frame)
	frame.add_child(chrome)
	frame.add_child(minimize)
	frame.add_child(lock_button)
	viewport.gui_embed_subwindows = true
	# UPDATE_ALWAYS as in the prototype. The SubViewportContainer owns this from here: it sets the
	# SubViewport to UPDATE_DISABLED when hidden and back to UPDATE_ALWAYS when shown, so a hidden
	# Page renders nothing (measured in the playtest: update mode 0 and the frame's draw calls back
	# at the white-page count while the Map Tab is hidden). process_mode DISABLED stops the rest.
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container.add_child(viewport)
	resized.connect(_fit_window)
	_fit_window()
	viewport.add_child(map)


## The window opens centred at the largest FRAME_SIZE-proportioned rect that fits with a margin;
## a Page resize re-fits it, as the prototype's desktop did on a viewport resize.
func _fit_window() -> void:
	action = ""
	if size.x < 2 or size.y < 2:
		return
	var scale := minf((size.x - 2 * MARGIN) / FRAME_SIZE.x, (size.y - 2 * MARGIN) / FRAME_SIZE.y)
	frame.size = (FRAME_SIZE * scale).round()
	frame.position = ((size - frame.size) / 2).round()
	chrome_scale = minf(1.0, frame.size.x / 1724.0)
	collapsed = false
	container.visible = true
	_layout()


func _layout() -> void:
	minimize.position = (Vector2(44, 42) * chrome_scale).round()
	minimize.size = (Vector2(44, 44) * chrome_scale).round()
	lock_button.position = Vector2(frame.size.x - roundf(86 * chrome_scale), roundf(42 * chrome_scale))
	lock_button.size = minimize.size
	container.position = (INSET * chrome_scale).round()
	if not collapsed:
		container.size = (frame.size - (FRAME_EXTRA * chrome_scale).round()).max(Vector2(2, 2))
	chrome.size = frame.size
	chrome.queue_redraw()


func _collapse() -> void:
	collapsed = not collapsed
	if collapsed:
		expanded_size = frame.size
		frame.size.y = roundf(136 * chrome_scale)
	else:
		frame.size = expanded_size
	container.visible = not collapsed
	_layout()


## Title-bar drag and edge resize of the frame, by the mouse (a desktop-only Tenant). A press on
## the map body is left for the SubViewportContainer to forward to the map (pan, zoom); the wheel
## and the keys always are.
func _input(event: InputEvent) -> void:
	inputs += 1
	if event is InputEventMouse and event.device == -1:
		return
	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		return
	var pointer := Vector2.ZERO
	var pressed := false
	var released := false
	var motion := false
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		pointer = make_canvas_position_local(event.position)
		pressed = event.pressed
		released = not event.pressed
	elif event is InputEventMouseMotion:
		pointer = make_canvas_position_local(event.position)
		motion = true
	else:
		return
	if pressed:
		var rect := frame.get_rect()
		if locked or not rect.has_point(pointer):
			return
		var local := pointer - rect.position
		edges = Vector2i(-1 if local.x < 10 else (1 if local.x > rect.size.x - 10 else 0),
				-1 if local.y < 10 else (1 if local.y > rect.size.y - 10 else 0))
		if edges != Vector2i.ZERO and not collapsed:
			action = "resize"
		elif local.y >= 30 * chrome_scale and local.y < 94 * chrome_scale \
				and local.x > 90 * chrome_scale and local.x < rect.size.x - 100 * chrome_scale:
			action = "drag"
		else:
			return
		start_pointer = pointer
		start_rect = rect
	elif released:
		if action.is_empty():
			return
		action = ""
	elif motion and not action.is_empty():
		var delta := pointer - start_pointer
		if action == "drag":
			frame.position = (start_rect.position + delta).clamp(Vector2.ZERO, (size - frame.size).max(Vector2.ZERO))
		else:
			var low := start_rect.position
			var high := start_rect.end
			var minimum := Vector2(300 + roundf(FRAME_EXTRA.x * chrome_scale), 280).min(size)
			for axis in [0, 1]:
				if edges[axis] < 0:
					low[axis] = clampf(low[axis] + delta[axis], 0, high[axis] - minimum[axis])
				if edges[axis] > 0:
					high[axis] = clampf(high[axis] + delta[axis], low[axis] + minimum[axis], size[axis])
			frame.position = low
			frame.size = high - low
		_layout()
	else:
		return
	get_viewport().set_input_as_handled()


func _patch(source: Rect2, destination: Rect2) -> void:
	if destination.size.x > 0 and destination.size.y > 0:
		chrome.draw_texture_rect_region(frame_texture, destination, source)


func _draw_frame() -> void:
	# Fixed source corners and title lettering; stretch only straight/empty runs.
	var w := frame.size.x
	var h := frame.size.y
	var top := roundf(94 * chrome_scale)
	var right := roundf(100 * chrome_scale)
	var left := minf(roundf(850 * chrome_scale), w - right)
	_patch(Rect2(0, 0, left / chrome_scale, 94), Rect2(0, 0, left, top))
	_patch(Rect2(850, 0, 774, 94), Rect2(left, 0, w - left - right, top))
	_patch(Rect2(1624, 0, 100, 94), Rect2(w - right, 0, right, top))
	var side := roundf(36 * chrome_scale)
	var corner := roundf(56 * chrome_scale)
	var bottom := roundf(42 * chrome_scale)
	var corner_height := roundf((42 if collapsed else 62) * chrome_scale)
	_patch(Rect2(0, 94, 36, 1268), Rect2(0, top, side, h - top - corner_height))
	_patch(Rect2(1688, 94, 36, 1268), Rect2(w - side, top, side, h - top - corner_height))
	var source_height := 42 if collapsed else 62
	_patch(Rect2(0, 1424 - source_height, 56, source_height), Rect2(0, h - corner_height, corner, corner_height))
	_patch(Rect2(1668, 1424 - source_height, 56, source_height), Rect2(w - corner, h - corner_height, corner, corner_height))
	_patch(Rect2(56, 1382, 1612, 42), Rect2(corner, h - bottom, w - corner * 2, bottom))


func _process(_delta: float) -> void:
	ticks += 1


## The harness probe (the Tenant contract): the map's own snapshot plus the window's state.
func state() -> Dictionary:
	var s: Dictionary = map.snapshot()
	s.merge({"key": key, "ticks": ticks, "inputs": inputs, "size": size, "frame": frame.get_rect(),
			"frame_global": frame.get_global_rect(),
			"map_rect": container.get_global_rect(), "chrome_scale": chrome_scale, "locked": locked,
			"collapsed": collapsed, "action": action, "viewport_update_mode": viewport.render_target_update_mode})
	return Errors.ok(s)
