## The Playground desktop (owner correction 2026-09-14, ticket #62): the owner's layout picture as a
## working page. Left, the Digital Playground (PostPet) window; a middle column of the options,
## Search filters and trade windows with the Global Chatroom at the bottom; right, the Nokia phone.
## Every window is a raster (assets/, PROVENANCE.md), draggable by its title bar (the phone by its
## whole surface), raised by a press, stopped at the Page's edge. Reach it through interface.gd only.
##
## Layout (ticket #63): the desktop is DESKTOP px natively (the layout picture's windows plus a
## MARGIN on every side, measured by template-matching each asset into the picture). The Page's size
## S gives s = min(S.x / D.x, S.y / D.y) for all art. The leftover on the other axis goes to the
## PostPet window: its rect runs to the middle column (right) and to the bottom margin, and it is
## drawn in bands at the uniform scale, only a flat one-pixel column per band and one flat row of its
## picture drawn wider or taller to fill (the same patch technique as the Collection
## viewer's chrome). The middle column and the phone anchor to the right edge; the chat window anchors
## to the bottom edge, the rest to the top. Re-laid out on every resize.
extends ColorRect

const Errors := preload("res://modules/playground_page/errors.gd")
const ROOT := "res://modules/playground_page/"
const DESKTOP := Vector2(2171, 1185)
const MARGIN := 24.0
# The PostPet picture's bands (source rows) and the column each band stretches at: a column where the
# band has no horizontal step at all (title bar, balloons, the panel right of the stickers, the info
# box right of its text), so every band grows by the same width and the edges stay aligned. Row
# STRETCH_Y (band 3, one pixel, max horizontal-neighbour step 14 across the width) takes the height.
const BANDS := [0, 45, 95, 203, 204, 660, 803]
const BAND_COLUMNS := [246, 344, 730, 730, 730, 703]
const STRETCH_Y_BAND := 3
# name, file, native position in DESKTOP px, art scale (desktop px per source px), title height in
# desktop px (0: the whole surface drags), anchor ("left" | "right" | "right_bottom"), keyed border
# width in source px (0: no magenta key)
const WINDOWS := [
	["postpet", "postpet.png", Vector2(24, 24), 1.41560, 64.0, "left", 0.0],
	["options", "options.png", Vector2(1253, 24), 0.23921, 30.0, "right", 32.0],
	["filters", "filters.png", Vector2(1253, 238), 0.91402, 31.0, "right", 3.0],
	["trade", "trade.png", Vector2(1247, 508), 0.23730, 31.0, "right", 32.0],
	["chat", "chat.png", Vector2(1266, 898), 0.26358, 33.0, "right_bottom", 32.0],
	["phone", "phone.png", Vector2(1767, 25), 1.41264, 0.0, "right", 0.0],
]

var key := ""
var ticks := 0
var inputs := 0
var factor := 1.0
var action := ""
var windows: Array[Control] = []
var _active: Control
var _start_pointer := Vector2.ZERO
var _start_position := Vector2.ZERO


static func create(deps: Dictionary) -> Dictionary:
	for entry in WINDOWS:
		if not ResourceLoader.exists(ROOT + "assets/" + entry[1]):
			return Errors.err(Errors.ASSET_MISSING, ROOT + "assets/" + entry[1])
	var page = load(ROOT + "playground_page.gd").new()
	page.key = deps.get("key", "")
	page.name = "PlaygroundPage"
	page.color = Color.WHITE
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return Errors.ok(page)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR  # the art is scaled; nearest would alias it
	for entry in WINDOWS:
		var texture: Texture2D = load(ROOT + "assets/" + entry[1])
		var window: Control
		if entry[0] == "postpet":
			window = Control.new()
			window.draw.connect(_draw_postpet.bind(window, texture))
		else:
			var rect := TextureRect.new()
			rect.texture = texture
			rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			if entry[6] > 0.0:
				var material := ShaderMaterial.new()
				material.shader = preload("res://modules/playground_page/remove-pink.gdshader")
				material.set_shader_parameter("border_width", entry[6])
				rect.material = material
			window = rect
		window.name = entry[0]
		window.mouse_filter = Control.MOUSE_FILTER_STOP
		window.set_meta("native", texture.get_size())
		add_child(window)
		windows.append(window)
	resized.connect(_fit)
	_fit()


func _fit() -> void:
	action = ""
	factor = minf(size.x / DESKTOP.x, size.y / DESKTOP.y)
	var s := factor
	var right_of_postpet := 0.0
	for index in WINDOWS.size():
		var entry: Array = WINDOWS[index]
		var window := windows[index]
		var native: Vector2 = window.get_meta("native") * float(entry[3])  # desktop px
		var at: Vector2 = entry[2]
		window.set_meta("drag_height", entry[4] * s if entry[4] > 0.0 else INF)
		match entry[5]:
			"left":
				window.position = at * s
				right_of_postpet = at.x + native.x
			"right":
				window.position = Vector2(size.x - (DESKTOP.x - at.x) * s, at.y * s)
			"right_bottom":
				window.position = Vector2(size.x - (DESKTOP.x - at.x) * s, size.y - (DESKTOP.y - at.y) * s)
		window.size = native * s
	# the main window takes the leftover: to the middle column on the right, to the margin at the bottom
	var postpet := windows[0]
	var right := size.x - (DESKTOP.x - right_of_postpet) * s
	var bottom := size.y - MARGIN * s
	postpet.size = Vector2(right, bottom) - postpet.position
	postpet.queue_redraw()


## The PostPet picture band by band at the uniform scale; in each band only its one-pixel column takes
## the extra width, and only the one-pixel band STRETCH_Y_BAND takes the extra height.
func _draw_postpet(window: Control, texture: Texture2D) -> void:
	var src: Vector2 = texture.get_size()
	var k: float = WINDOWS[0][3] * factor
	var extra: Vector2 = (window.size - src * k).max(Vector2.ZERO)
	var dy := 0.0
	for band in BAND_COLUMNS.size():
		var top: float = BANDS[band]
		var rows: float = BANDS[band + 1] - top
		var h: float = rows * k + (extra.y if band == STRETCH_Y_BAND else 0.0)
		var xs := [0.0, float(BAND_COLUMNS[band]), BAND_COLUMNS[band] + 1.0, src.x]
		var dx := 0.0
		for i in 3:
			var w: float = (xs[i + 1] - xs[i]) * k + (extra.x if i == 1 else 0.0)
			window.draw_texture_rect_region(texture, Rect2(dx, dy, w, h), Rect2(xs[i], top, xs[i + 1] - xs[i], rows))
			dx += w
		dy += h


## A press raises the topmost window under the pointer; on its title bar it starts a drag.
func _input(event: InputEvent) -> void:
	inputs += 1
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var pointer := make_canvas_position_local(event.position)
		if not event.pressed:
			if action.is_empty():
				return
			action = ""
			_active = null
		else:
			_active = null
			for window in windows:
				if window.get_rect().has_point(pointer) and (_active == null or window.get_index() > _active.get_index()):
					_active = window
			if _active == null:
				return
			move_child(_active, -1)
			if pointer.y - _active.position.y >= float(_active.get_meta("drag_height")):
				return
			action = "drag"
			_start_pointer = pointer
			_start_position = _active.position
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and not action.is_empty():
		var delta: Vector2 = make_canvas_position_local(event.position) - _start_pointer
		_active.position = (_start_position + delta).clamp(Vector2.ZERO, (size - _active.size).max(Vector2.ZERO))
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	ticks += 1


func state() -> Dictionary:
	var list := []
	for window in windows:
		var drag: float = window.get_meta("drag_height")
		list.append({"name": String(window.name), "rect": window.get_rect(), "order": window.get_index(),
				"drag_height": -1.0 if is_inf(drag) else drag})
	list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.order < b.order)
	return Errors.ok({"key": key, "ticks": ticks, "inputs": inputs, "size": size, "factor": factor,
			"desktop": DESKTOP, "margin": MARGIN, "action": action, "windows": list})
