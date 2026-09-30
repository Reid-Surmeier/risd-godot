## The Pixel Atlas desktop: the prototype's whole desktop on the Page — the four supplied raster
## panels (minimap, itinerary, chat, notification) and the map window, all draggable, a press
## raising the pressed one; the map window resizable and collapsible (sliced from
## assets/window-frame.png), its body a SubViewport holding atlas.gd. Reach it through
## interface.gd only.
##
## Ported from qwen-pipeline-experiments prototype/atlas-5 @ 421f1cc atlas_window.gd (the panels
## arranged in 08dae0d, draggable in c0b7fc5). Left behind: the under-750-px phone layout, the
## clear-colour override, the JavaScriptBridge publishes and the touch paths (a desktop-only
## Tenant). Changed: it lays out from its own size / resized (never the root viewport) and
## pointer positions are made local to it.
extends Control

const Errors := preload("res://modules/atlas/errors.gd")

const ROOT := "res://modules/atlas/"
const INSET := Vector2(36, 94)
const FRAME_EXTRA := Vector2(72, 136)
## The prototype's desktop composition (the owner's reference): panels and map window in the
## 1950x1280 desktop's pixels. _fit_window scales it uniformly and fills the Page with it (#63).
const DESKTOP_SIZE := Vector2(1950, 1280)
const FRAME_RECT := Rect2(450, 58, 1158, 954)
const PANEL_RECTS := {
	"minimap": Rect2(10, 72, 413, 371),
	"itinerary": Rect2(18, 445, 397, 553),
	"chat": Rect2(10, 1028, 540, 251),
	"notification": Rect2(1674, 1200, 272, 79),
}
## The map window's right and bottom edges in native pixels from the desktop's right and bottom:
## right, the desktop's own right margin (the notification ends 4 px from it); bottom, the native
## gap that keeps it clear of the chat below.
const FRAME_FAR_GAP := Vector2(4, 268)

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
var panels: Dictionary = {}
var minimap_heading := ColorRect.new()
const ARTWORK_POPUP_SIZE := Vector2(800, 600)
const ARTWORK_SCALE := 0.5

var artwork_window := Control.new()
var artwork_chrome := Control.new()
var artwork_page := ScrollContainer.new()
var artwork_content := VBoxContainer.new()
var artwork_image := TextureRect.new()
var artwork_bubble := Label.new()
var moving_window: Control
var locked := false
var collapsed := false
var expanded_size := Vector2.ZERO
var action := ""
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
	t.map.artwork_requested = Callable(t, "_show_artwork")
	t.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return Errors.ok(t)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for id in PANEL_RECTS:
		var panel := TextureRect.new()
		panel.name = id
		panel.tooltip_text = "Drag to move"
		panel.texture = load(ROOT + "assets/desktop/" + id + ".png")
		panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		panel.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(panel)
		panels[id] = panel
	minimap_heading.color = Color("#e8f4f7")
	minimap_heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panels.minimap.add_child(minimap_heading)
	var label := Label.new()
	label.text = "MINI MAP"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color("#385e78"))
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	minimap_heading.add_child(label)
	frame.name = "map"
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)
	minimize.ignore_texture_size = true
	minimize.tooltip_text = "Collapse / expand map"
	minimize.pressed.connect(_collapse)
	lock_button.ignore_texture_size = true
	lock_button.tooltip_text = "Lock / unlock window position and size"
	lock_button.pressed.connect(
		func():
			locked = not locked
			lock_button.tooltip_text = "Unlock window" if locked else "Lock window"
	)
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
	_build_artwork_window()
	resized.connect(_fit_window)
	_fit_window()
	viewport.add_child(map)
	for window in panels.values() + [frame, artwork_window]:
		_add_scale_grip(window)


func _build_artwork_window() -> void:
	artwork_window.name = "artwork"
	artwork_window.visible = false
	artwork_window.size = ARTWORK_POPUP_SIZE
	artwork_window.clip_contents = true
	add_child(artwork_window)
	artwork_chrome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	artwork_chrome.size = ARTWORK_POPUP_SIZE
	artwork_chrome.draw.connect(_draw_artwork_frame)
	artwork_window.add_child(artwork_chrome)
	artwork_page.position = INSET * ARTWORK_SCALE
	artwork_page.size = ARTWORK_POPUP_SIZE - FRAME_EXTRA * ARTWORK_SCALE
	artwork_page.clip_contents = true
	artwork_page.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	artwork_page.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	artwork_window.add_child(artwork_page)
	artwork_content.custom_minimum_size = Vector2(artwork_page.size.x, 0)
	artwork_content.add_theme_constant_override("separation", 11)
	artwork_page.add_child(artwork_content)
	artwork_image.custom_minimum_size = Vector2(artwork_page.size.x, 0)
	artwork_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	artwork_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	artwork_content.add_child(artwork_image)
	artwork_bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	artwork_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	artwork_bubble.add_theme_color_override("font_color", Color.BLACK)
	artwork_bubble.add_theme_font_override("font", load(ROOT + "fonts/PixelMplus12-Regular.ttf"))
	artwork_bubble.add_theme_font_size_override("font_size", 16)
	artwork_bubble.custom_minimum_size = Vector2(artwork_page.size.x, 56)
	artwork_content.add_child(artwork_bubble)


func _show_artwork(item: Dictionary, marker: int) -> void:
	var image: Texture2D = load(ROOT + item.image_path)
	artwork_image.texture = image
	artwork_image.custom_minimum_size = Vector2(
		artwork_page.size.x, artwork_page.size.x * image.get_height() / image.get_width()
	)
	artwork_bubble.text = "%s\n%s\nMarker %d" % [item.title, item.maker, marker]
	artwork_page.scroll_vertical = 0
	artwork_window.position = Vector2(size.x - artwork_window.size.x - 24, 28).max(Vector2(12, 12))
	artwork_window.visible = true
	move_child(artwork_window, get_child_count() - 1)


func _artwork_patch(source: Rect2, destination: Rect2) -> void:
	if destination.size.x > 0 and destination.size.y > 0:
		artwork_chrome.draw_texture_rect_region(frame_texture, destination, source)


func _draw_artwork_frame() -> void:
	# The preview reuses the map window's source slices: no generated border or scrollbar remains.
	var w := artwork_window.size.x
	var h := artwork_window.size.y
	var scale := ARTWORK_SCALE
	var top := roundf(94 * scale)
	var right := roundf(100 * scale)
	var left := minf(roundf(850 * scale), w - right)
	_artwork_patch(Rect2(0, 0, left / scale, 94), Rect2(0, 0, left, top))
	_artwork_patch(Rect2(850, 0, 774, 94), Rect2(left, 0, w - left - right, top))
	_artwork_patch(Rect2(1624, 0, 100, 94), Rect2(w - right, 0, right, top))
	var side := roundf(36 * scale)
	var corner := roundf(56 * scale)
	var bottom := roundf(42 * scale)
	var corner_height := roundf(62 * scale)
	_artwork_patch(Rect2(0, 94, 36, 1268), Rect2(0, top, side, h - top - corner_height))
	_artwork_patch(Rect2(1688, 94, 36, 1268), Rect2(w - side, top, side, h - top - corner_height))
	_artwork_patch(Rect2(0, 1362, 56, 62), Rect2(0, h - corner_height, corner, corner_height))
	_artwork_patch(
		Rect2(1668, 1362, 56, 62), Rect2(w - corner, h - corner_height, corner, corner_height)
	)
	_artwork_patch(Rect2(56, 1382, 1612, 42), Rect2(corner, h - bottom, w - corner * 2, bottom))


## The desktop fills the Page (#63): one uniform scale s = min(page / DESKTOP_SIZE) for all the
## raster art; each panel keeps its native distance, times s, to the page edges it sits nearest
## (by its centre), and the map window takes the leftover — its left edge keeps its place beside the
## left panels, its bottom its gap above the chat, while its top and right run to the page edge
## minus the desktop's own native margin (FRAME_FAR_GAP). Re-laid out on every resize.
func _fit_window() -> void:
	if get_meta("windows_adjusted", false):
		set_meta("scaling", false)
		for window in panels.values() + [frame, artwork_window]:
			window.scale = (
				Vector2.ONE
				* minf(window.scale.x, minf(size.x / window.size.x, size.y / window.size.y))
			)
			window.position = window.position.clamp(
				Vector2.ZERO, (size - window.size * window.scale).max(Vector2.ZERO)
			)
		return
	# Compact Pages use the selected #164 heading in place of the baked clock.
	minimap_heading.visible = size.x * DESKTOP_SIZE.y < size.y * DESKTOP_SIZE.x
	action = ""
	moving_window = null
	if size.x < 2 or size.y < 2:
		return
	var scale := minf(size.x / DESKTOP_SIZE.x, size.y / DESKTOP_SIZE.y)
	for id in panels:
		var r: Rect2 = PANEL_RECTS[id]
		var at := r.position * scale
		var far := size - (DESKTOP_SIZE - r.position) * scale
		if r.get_center().x > DESKTOP_SIZE.x / 2:
			at.x = far.x
		if r.get_center().y > DESKTOP_SIZE.y / 2:
			at.y = far.y
		panels[id].position = at.round()
		panels[id].size = (r.size * scale).round()
	minimap_heading.position = Vector2(panels.minimap.size.x * 0.07, 0)
	minimap_heading.size = Vector2(panels.minimap.size.x * 0.74, panels.minimap.size.y * 0.35)
	frame.position = (FRAME_RECT.position * scale).round()
	frame.size = (size - FRAME_FAR_GAP * scale).round() - frame.position
	chrome_scale = minf(1.0, FRAME_RECT.size.x / 1724.0 * scale)
	collapsed = false
	container.visible = true
	_layout()


func _layout() -> void:
	minimize.position = (Vector2(44, 42) * chrome_scale).round()
	minimize.size = (Vector2(44, 44) * chrome_scale).round()
	lock_button.position = Vector2(
		frame.size.x - roundf(86 * chrome_scale), roundf(42 * chrome_scale)
	)
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


## The topmost window (panel or map frame) under a pointer in the Tenant's own pixels.
func _top_window_at(pointer: Vector2) -> Control:
	var windows := get_children()
	windows.reverse()
	for window in windows:
		if (
			window is Control
			and window.is_visible_in_tree()
			and Rect2(window.position, window.size * window.scale).has_point(pointer)
		):
			return window
	return null


## The desktop's mouse handling (a desktop-only Tenant): a press raises the window under it; a
## panel drags from anywhere, the map frame by its title bar and resizes by its edges; the wheel
## over a panel is swallowed so the map beneath does not zoom. A press on the map body is left for
## the SubViewportContainer to forward to the map (pan, zoom); the keys always are.
func _input(event: InputEvent) -> void:
	inputs += 1
	if get_meta("scaling", false):
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		for window in panels.values() + [frame, artwork_window]:
			var grip := window.get_node_or_null("ProportionalResize") as Control
			if (
				grip != null
				and grip.is_visible_in_tree()
				and grip.get_global_rect().has_point(event.position)
			):
				return
	if event is InputEventMouse and event.device == -1:
		return
	if (
		event is InputEventMouseButton
		and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]
	):
		var over := _top_window_at(make_canvas_position_local(event.position))
		if over != null and over != frame and over != artwork_window:
			get_viewport().set_input_as_handled()
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
		var target := _top_window_at(pointer)
		if target == null:
			return
		move_child(target, get_child_count() - 1)
		var rect := Rect2(target.position, target.size * target.scale)
		if target == artwork_window:
			var artwork_local := (pointer - rect.position) / target.scale
			if artwork_local.y < roundf(94 * ARTWORK_SCALE):
				action = "drag"
			else:
				return
		elif target == frame:
			if locked:
				return
			var local := (pointer - rect.position) / target.scale
			if (
				local.y >= 30 * chrome_scale
				and local.y < 94 * chrome_scale
				and local.x > 90 * chrome_scale
				and local.x < target.size.x - 100 * chrome_scale
			):
				action = "drag"
			else:
				return
		else:
			action = "drag"
		moving_window = target
		start_pointer = pointer
		start_rect = rect
	elif released:
		if action.is_empty():
			return
		action = ""
		moving_window = null
	elif motion and not action.is_empty():
		var delta := pointer - start_pointer
		if action == "drag":
			moving_window.position = (start_rect.position + delta).clamp(
				Vector2(-offset_left, 0),
				(size - moving_window.size * moving_window.scale).max(Vector2.ZERO)
			)
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
	_patch(
		Rect2(0, 1424 - source_height, 56, source_height),
		Rect2(0, h - corner_height, corner, corner_height)
	)
	_patch(
		Rect2(1668, 1424 - source_height, 56, source_height),
		Rect2(w - corner, h - corner_height, corner, corner_height)
	)
	_patch(Rect2(56, 1382, 1612, 42), Rect2(corner, h - bottom, w - corner * 2, bottom))


func _process(_delta: float) -> void:
	ticks += 1


## The harness probe (the Tenant contract): the map's own snapshot plus the desktop's state.
func state() -> Dictionary:
	var s: Dictionary = map.snapshot()
	var panel_rects := {}
	for id in panels:
		panel_rects[id] = panels[id].get_rect()
	var stack: Array = []
	for window in get_children():
		if window == artwork_window:
			continue
		stack.append(str(window.name))
	s.merge(
		{
			"key": key,
			"ticks": ticks,
			"inputs": inputs,
			"size": size,
			"frame": frame.get_rect(),
			"frame_global": frame.get_global_rect(),
			"map_rect": container.get_global_rect(),
			"chrome_scale": chrome_scale,
			"locked": locked,
			"collapsed": collapsed,
			"action": action,
			"viewport_update_mode": viewport.render_target_update_mode,
			"panels": panel_rects,
			"stack": stack,
			"moving_window": str(moving_window.name) if moving_window != null else ""
		}
	)
	return Errors.ok(s)


# Resize the complete window with one scale, preserving content and input coordinates.
func _add_scale_grip(window: Control) -> void:
	var grip := Control.new()
	grip.name = "ProportionalResize"
	grip.size = Vector2(32, 32)
	grip.mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
	grip.tooltip_text = "Drag to resize proportionally"
	grip.draw.connect(
		func():
			grip.draw_rect(Rect2(Vector2.ZERO, grip.size), Color(0.3, 0.3, 0.3, 0.8))
			for inset in [10, 17, 24]:
				grip.draw_line(Vector2(inset, 28), Vector2(28, inset), Color.WHITE, 2.0)
	)
	window.add_child(grip)
	var fit := func(): grip.position = window.size - grip.size
	window.resized.connect(fit)
	fit.call()
	var gesture := {"active": false, "start": Vector2.ZERO, "scale": 1.0}
	get_window().focus_exited.connect(
		func():
			gesture.active = false
			set_meta("scaling", false)
	)
	window.visibility_changed.connect(
		func():
			gesture.active = false
			set_meta("scaling", false)
	)
	grip.gui_input.connect(
		func(event):
			if window == frame and (locked or collapsed):
				return
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
				gesture.active = event.pressed
				set_meta("scaling", event.pressed)
				if event.pressed:
					gesture.start = window.get_parent().make_canvas_position_local(
						event.global_position
					)
					gesture.scale = window.scale.x
					set_meta("windows_adjusted", true)
					window.get_parent().move_child(window, -1)
				grip.accept_event()
			elif event is InputEventMouseMotion and gesture.active and get_meta("scaling", false):
				var delta: Vector2 = (
					window.get_parent().make_canvas_position_local(event.global_position)
					- gesture.start
				)
				var available: Vector2 = window.get_parent().size - window.position
				var maximum := minf(available.x / window.size.x, available.y / window.size.y)
				var factor: float = (
					gesture.scale + delta.dot(window.size) / window.size.length_squared()
				)
				window.scale = Vector2.ONE * clampf(factor, minf(0.35, maximum), maximum)
				grip.accept_event()
	)
