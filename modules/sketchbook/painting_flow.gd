extends Control
## Native Cover Flow using the same catalogue and images as the browser prototype.
## Canvas strips use the existing paper-turn projection approach; no additional rendering library.

const Errors := preload("res://modules/sketchbook/errors.gd")
const SOURCE := "res://prototypes/painting-coverflow/web/"
const STRIPS := 16
var title_bar := Control.new()
var stage := Control.new()
var slider := HSlider.new()
var frame := NinePatchRect.new()
var textures: Array[Texture2D] = []
var cards: Array = []
var selected := 2
var location := 2.0
var velocity := 0.0
var enlarged := false
var dragging := false
var moved := false
var anchor := Vector2.ZERO
var start_location := 0.0
var ticks := 0
var floor_shadow: GradientTexture2D
var window_style := StyleBoxFlat.new()


static func create() -> Dictionary:
	var catalog_path := SOURCE + "paintings.json"
	if not FileAccess.file_exists(catalog_path):
		return Errors.err(Errors.ASSET_MISSING, catalog_path)
	var catalog: Variant = JSON.parse_string(FileAccess.get_file_as_string(catalog_path))
	if not catalog is Array or catalog.is_empty():
		return Errors.err(Errors.ASSET_MISSING, "Invalid painting catalogue: " + catalog_path)
	var frame_path := SOURCE + "assets/window.png"
	if not ResourceLoader.exists(frame_path) or not load(frame_path) is Texture2D:
		return Errors.err(Errors.ASSET_MISSING, frame_path)
	var images: Array[Texture2D] = []
	for artwork in catalog:
		if not artwork is Dictionary or not artwork.get("localImage") is String:
			return Errors.err(Errors.ASSET_MISSING, "Invalid painting entry: " + catalog_path)
		var path: String = SOURCE + artwork.localImage
		if not ResourceLoader.exists(path):
			return Errors.err(Errors.ASSET_MISSING, path)
		var texture := load(path) as Texture2D
		if texture == null:
			return Errors.err(Errors.ASSET_MISSING, path)
		images.append(texture)
	var window = load("res://modules/sketchbook/painting_flow.gd").new()
	window.textures = images
	return Errors.ok(window)


func _ready() -> void:
	custom_minimum_size = Vector2(420, 260)
	texture_filter = TEXTURE_FILTER_LINEAR
	window_style.bg_color = Color.WHITE
	window_style.set_corner_radius_all(7)
	# The current Shell supplies the same movable window shadow as the other desktop windows.
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color(0, 0, 0, 0.26), Color(0, 0, 0, 0)])
	floor_shadow = GradientTexture2D.new()
	floor_shadow.gradient = gradient
	floor_shadow.fill = GradientTexture2D.FILL_RADIAL
	floor_shadow.fill_from = Vector2(0.5, 0.5)
	floor_shadow.fill_to = Vector2(1, 0.5)
	floor_shadow.width = 256
	floor_shadow.height = 64
	stage.clip_contents = true
	stage.focus_mode = FOCUS_ALL
	stage.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	stage.tooltip_text = \
		"Click a painting to select it; click again to enlarge. Drag or scroll to browse."
	stage.draw.connect(_draw_stage)
	stage.gui_input.connect(_stage_input)
	add_child(stage)
	# Nine-patch the original blue window, excluding its minimap interior. Chroma key removes
	# only the source's exterior magenta, leaving its rounded blue corners and highlights intact.
	var atlas := AtlasTexture.new()
	atlas.atlas = load(SOURCE + "assets/window.png")
	atlas.region = Rect2(8, 12, 1440, 658)
	frame.texture = atlas
	frame.draw_center = false
	frame.patch_margin_left = 30
	frame.patch_margin_top = 126
	frame.patch_margin_right = 27
	frame.patch_margin_bottom = 30
	frame.scale = Vector2(0.3, 0.3)
	frame.mouse_filter = MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = "shader_type canvas_item; void fragment(){if(COLOR.r>0.5 && COLOR.b>0.5 && COLOR.g<0.4){COLOR.a=0.0;}}"
	var material := ShaderMaterial.new()
	material.shader = shader
	frame.material = material
	add_child(frame)
	title_bar.mouse_default_cursor_shape = CURSOR_DRAG
	title_bar.tooltip_text = "Drag painting viewer"
	add_child(title_bar)
	slider.min_value = 0
	slider.max_value = textures.size() - 1
	slider.step = 1
	slider.value = selected
	slider.scrollable = false
	slider.tooltip_text = "Choose painting"
	slider.value_changed.connect(func(value): _select(int(value)))
	add_child(slider)
	resized.connect(_layout)
	visibility_changed.connect(func(): dragging = false)
	_layout()


func _layout() -> void:
	frame.size = size / frame.scale
	title_bar.position = Vector2(10, 3)
	title_bar.size = Vector2(size.x - 20, 32)
	stage.position = Vector2(10, 39)
	stage.size = size - Vector2(20, 73)
	slider.position = Vector2(size.x * 0.15, size.y - 31)
	slider.size = Vector2(size.x * 0.7, 20)
	queue_redraw()
	stage.queue_redraw()


func _draw() -> void:
	draw_style_box(window_style, Rect2(Vector2(3, 3), size - Vector2(6, 6)))


func _select(index: int) -> void:
	selected = clampi(index, 0, textures.size() - 1)
	slider.set_value_no_signal(selected)
	stage.queue_redraw()


func _process(delta: float) -> void:
	ticks += 1
	if dragging or (absf(location - selected) < 0.0001 and absf(velocity) < 0.0001):
		return
	var dt := minf(delta, 1.0 / 30.0)
	var difference := location - selected
	var decay := exp(-18.0 * dt)
	location = selected + (difference + (velocity + 18.0 * difference) * dt) * decay
	velocity = (velocity - 18.0 * (velocity + 18.0 * difference) * dt) * decay
	stage.queue_redraw()


func _project(index: int, u: float, v: float) -> Vector2:
	var texture := textures[index]
	var factor := minf(
		stage.size.x * 0.42 / texture.get_width(), (stage.size.y - 38) / texture.get_height()
	)
	var dimensions := texture.get_size() * factor
	var distance := index - location
	var turn := minf(1.0, absf(distance))
	var x := (
		signf(distance)
		* (stage.size.x * 0.31 * turn + maxf(0, absf(distance) - 1) * stage.size.x * 0.078)
	)
	var angle := deg_to_rad(-signf(distance) * 62 * turn)
	var local_x := (u - 0.5) * dimensions.x
	var depth := -local_x * sin(angle) - 120 * turn
	var perspective := 1500.0 / (1500.0 - depth)
	return Vector2(
		stage.size.x / 2 + (x + local_x * cos(angle)) * perspective,
		stage.size.y - 26 + (v - 1) * dimensions.y * perspective
	)


func _draw_stage() -> void:
	cards.clear()
	if textures.is_empty():
		return
	if enlarged:
		var texture := textures[selected]
		var factor := minf(
			(stage.size.x - 20) / texture.get_width(), (stage.size.y - 8) / texture.get_height()
		)
		var dimensions := texture.get_size() * factor
		stage.draw_texture_rect(texture, Rect2((stage.size - dimensions) / 2, dimensions), false)
		return
	var order := range(textures.size())
	order.sort_custom(func(a, b): return absf(a - location) > absf(b - location))
	for index in order:
		var quad := PackedVector2Array(
			[
				_project(index, 0, 0),
				_project(index, 1, 0),
				_project(index, 1, 1),
				_project(index, 0, 1)
			]
		)
		cards.append({"index": index, "quad": quad})
		var left := quad[3]
		var right := quad[2]
		stage.draw_texture_rect(
			floor_shadow, Rect2(left.x - 18, left.y - 7, right.x - left.x + 36, 34), false
		)
		for strip in STRIPS:
			var u0 := float(strip) / STRIPS
			var u1 := float(strip + 1) / STRIPS
			var points := PackedVector2Array(
				[
					_project(index, u0, 0),
					_project(index, u1, 0),
					_project(index, u1, 1),
					_project(index, u0, 1)
				]
			)
			var uv := PackedVector2Array(
				[Vector2(u0, 0), Vector2(u1, 0), Vector2(u1, 1), Vector2(u0, 1)]
			)
			stage.draw_polygon(points, PackedColorArray([Color.WHITE]), uv, textures[index])


func _hit(point: Vector2) -> int:
	for i in range(cards.size() - 1, -1, -1):
		if Geometry2D.is_point_in_polygon(point, cards[i].quad):
			return cards[i].index
	return -1


func _stage_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (
			event.pressed
			and (
				event.button_index
				in [
					MOUSE_BUTTON_WHEEL_UP,
					MOUSE_BUTTON_WHEEL_DOWN,
					MOUSE_BUTTON_WHEEL_LEFT,
					MOUSE_BUTTON_WHEEL_RIGHT
				]
			)
		):
			# Godot Web maps positive DOM deltaX to WHEEL_LEFT (content moves left).
			_select(
				(
					selected
					+ (
						1
						if event.button_index in [MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_LEFT]
						else -1
					)
				)
			)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			stage.grab_focus()
			if event.pressed:
				dragging = true
				moved = false
				anchor = event.position
				start_location = location
			elif dragging:
				dragging = false
				if moved:
					_select(roundi(location))
				elif enlarged:
					enlarged = false
				else:
					var hit := _hit(event.position)
					if hit == selected:
						enlarged = true
					elif hit >= 0:
						_select(hit)
				stage.queue_redraw()
		stage.accept_event()
	elif event is InputEventMouseMotion and dragging and not enlarged:
		if event.position.distance_to(anchor) > 6:
			moved = true
		if moved:
			location = clampf(
				start_location + (anchor.x - event.position.x) / (stage.size.x * 0.31),
				0,
				textures.size() - 1
			)
			velocity = 0
			stage.queue_redraw()
		stage.accept_event()
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_LEFT:
				_select(selected - 1)
			KEY_RIGHT:
				_select(selected + 1)
			KEY_HOME:
				_select(0)
			KEY_END:
				_select(textures.size() - 1)
			KEY_ENTER, KEY_SPACE:
				enlarged = not enlarged
			KEY_ESCAPE:
				enlarged = false
			_:
				return
		stage.queue_redraw()
		stage.accept_event()


func qa_state() -> Dictionary:
	var hits := []
	var transform := stage.get_global_transform()
	for card in cards:
		var points := []
		for point in card.quad:
			var global: Vector2 = transform * point
			points.append([global.x, global.y])
		hits.append({"index": card.index, "points": points})
	var rect := slider.get_global_rect()
	return {
		"selected": selected,
		"position": location,
		"enlarged": enlarged,
		"ticks": ticks,
		"count": textures.size(),
		"cards": hits,
		"slider": [rect.position.x, rect.position.y, rect.size.x, rect.size.y]
	}
