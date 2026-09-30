extends Control
## THROWAWAY UI PROTOTYPE: three desktop arrangements are selected by `?variant=A|B|C`.
## Paint wells load pigment; dragging through a white tray mixes visible puddles with Mixbox.
## Ported from figma-ui-ux-qwen-pipeline prototype/painting-tool-mixbox @ d2faa30
## viewer-godot/scripts/paint_palette_prototype.gd: the global class_name
## dropped, the pixel and Mixbox paths
## moved into this module, the hover pointer taken from mouse events (see _input). The desktop fixes
## smear variant A (the `?variant=` switcher stayed behind).
## Reach it through interface.gd only.

signal color_changed(color: Color)
signal state_changed
signal tool_selected(tool: String)
signal pointer_changed
signal sound_cue_requested(cue: String)

const Mixbox = preload("res://modules/sketchbook/mixbox/mixbox.gd")
const SoundCues := preload("res://modules/sound_cues/interface.gd")
const ANRI_INTERIOR := preload("res://modules/sketchbook/assets/paintbox/palette-window-v7.png")
const PALETTE := preload("res://modules/sketchbook/assets/paintbox/palette-white.png")
const BRUSH_REST := preload("res://modules/sketchbook/assets/paintbox/cat-brush-rest.png")
const BRUSH := preload("res://modules/sketchbook/assets/paintbox/watercolor-brush.png")
const BRUSH_SHADER := preload("res://modules/sketchbook/assets/paintbox/brush-tip.gdshader")
const TITLE_HEIGHT := 22.0
const BORDER := 4.0
const MIX_CUE_INTERVAL := 1.4
const ANRI_PALETTE_SOURCE := Rect2(68, 108, 398, 365)
const WELL_START_X := 95.0 / 532.0
const WELL_STEP_X := 23.0 / 532.0
const WELL_Y := [150.0 / 532.0, 338.0 / 532.0]
const WELL_HIT := Vector2(10.5 / 532.0, 24.0 / 532.0)
const ANRI_WELL_START_X := (95.0 - ANRI_PALETTE_SOURCE.position.x) / ANRI_PALETTE_SOURCE.size.x
const ANRI_WELL_STEP_X := 23.0 / ANRI_PALETTE_SOURCE.size.x
const ANRI_WELL_Y := [
	(150.0 - ANRI_PALETTE_SOURCE.position.y) / ANRI_PALETTE_SOURCE.size.y,
	(338.0 - ANRI_PALETTE_SOURCE.position.y) / ANRI_PALETTE_SOURCE.size.y
]
const ANRI_WELL_HIT := Vector2(10.5, 24.0) / ANRI_PALETTE_SOURCE.size
const TRAYS := [
	Rect2(82.0 / 532.0, 181.0 / 532.0, 116.0 / 532.0, 104.0 / 532.0),
	Rect2(202.0 / 532.0, 181.0 / 532.0, 130.0 / 532.0, 104.0 / 532.0),
	Rect2(336.0 / 532.0, 181.0 / 532.0, 118.0 / 532.0, 104.0 / 532.0),
	Rect2(82.0 / 532.0, 371.0 / 532.0, 372.0 / 532.0, 91.0 / 532.0),
]
const ANRI_TRAYS := [
	Rect2(
		(Vector2(82, 181) - ANRI_PALETTE_SOURCE.position) / ANRI_PALETTE_SOURCE.size,
		Vector2(116, 104) / ANRI_PALETTE_SOURCE.size
	),
	Rect2(
		(Vector2(202, 181) - ANRI_PALETTE_SOURCE.position) / ANRI_PALETTE_SOURCE.size,
		Vector2(130, 104) / ANRI_PALETTE_SOURCE.size
	),
	Rect2(
		(Vector2(336, 181) - ANRI_PALETTE_SOURCE.position) / ANRI_PALETTE_SOURCE.size,
		Vector2(118, 104) / ANRI_PALETTE_SOURCE.size
	),
	Rect2(
		(Vector2(82, 371) - ANRI_PALETTE_SOURCE.position) / ANRI_PALETTE_SOURCE.size,
		Vector2(372, 91) / ANRI_PALETTE_SOURCE.size
	),
]
static var _blank_cursor: ImageTexture

var brush_color := Color("#00458f")
var title_bar: Control
var tool_reference: TextureRect
var image_rect := Rect2()
var smear_variant := "A"
var mix_count := 0
var brush_cursor: TextureRect
var brush_stage: ColorRect
var brush_rest: TextureRect
var parked_brush: TextureRect
var hovering := false
var brush_active := false
var anri_mode := false
var _palette_image: Image
var _tray_images: Array[Image] = []
var _tray_textures: Array[ImageTexture] = []
var _paint_pixels := 0
var _mixing := false
var _mix_cue_elapsed := 0.0
var _drag_pigment := brush_color
var _last_deposit := Vector2(-10, -10)
var _hover_uv := Vector2(-1, -1)
var _stamp_index := 0
var _pointer := Vector2(-100000, -100000)


func set_anri_mode(enabled: bool) -> void:
	anri_mode = enabled
	custom_minimum_size = Vector2(320, 700) if enabled else Vector2(300, 330)
	if is_node_ready():
		tool_reference.visible = false
		brush_stage.visible = enabled
		_layout()


func _ready() -> void:
	custom_minimum_size = Vector2(320, 700) if anri_mode else Vector2(300, 330)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_STOP
	_palette_image = PALETTE.get_image()
	if _blank_cursor == null:
		var blank := Image.create(8, 8, false, Image.FORMAT_RGBA8)
		blank.fill(Color.TRANSPARENT)
		_blank_cursor = ImageTexture.create_from_image(blank)
	var tray_source_size := ANRI_PALETTE_SOURCE.size if anri_mode else Vector2(532, 532)
	for tray in _active_trays():
		var pixels := Vector2i(Vector2(tray.size * tray_source_size).ceil())
		var image := Image.create(pixels.x, pixels.y, false, Image.FORMAT_RGBA8)
		image.fill(Color.TRANSPARENT)
		_tray_images.append(image)
		_tray_textures.append(ImageTexture.create_from_image(image))
	title_bar = Control.new()
	title_bar.name = "title-bar"
	title_bar.mouse_default_cursor_shape = CURSOR_DRAG
	title_bar.tooltip_text = "Drag the paintbox"
	add_child(title_bar)
	tool_reference = TextureRect.new()
	tool_reference.name = "muse-reconstructed-interior"
	tool_reference.texture = ANRI_INTERIOR
	tool_reference.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tool_reference.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tool_reference.mouse_filter = MOUSE_FILTER_IGNORE
	tool_reference.visible = false
	add_child(tool_reference)
	brush_stage = ColorRect.new()
	brush_stage.name = "live-brush-stage"
	brush_stage.color = Color.WHITE
	brush_stage.mouse_filter = MOUSE_FILTER_IGNORE
	brush_stage.visible = anri_mode
	add_child(brush_stage)
	brush_rest = TextureRect.new()
	brush_rest.name = "cat-brush-rest"
	brush_rest.texture = BRUSH_REST
	brush_rest.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	brush_rest.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	brush_rest.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(brush_rest)
	parked_brush = _make_brush("parked-brush")
	add_child(parked_brush)
	brush_cursor = _make_brush("palette-brush-cursor")
	brush_cursor.visible = false
	brush_cursor.z_index = 20
	add_child(brush_cursor)
	resized.connect(_layout)
	set_process(true)
	_layout()
	_update_brush_color()


func _make_brush(node_name: String) -> TextureRect:
	var brush := TextureRect.new()
	brush.name = node_name
	brush.texture = BRUSH
	brush.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	brush.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	brush.mouse_filter = MOUSE_FILTER_IGNORE
	var brush_material := ShaderMaterial.new()
	brush_material.shader = BRUSH_SHADER
	brush.material = brush_material
	return brush


func _layout() -> void:
	title_bar.position = Vector2(BORDER, BORDER)
	title_bar.size = Vector2(size.x - BORDER * 2.0, TITLE_HEIGHT - BORDER)
	tool_reference.position = Vector2(BORDER, TITLE_HEIGHT + BORDER)
	if anri_mode:
		var k := size.x / 1484.0
		title_bar.size.y = 92 * k
		tool_reference.position = Vector2.ZERO
		tool_reference.size = size
		# Register the retained source palette in the owner's 1484x3072 assembly.
		image_rect = Rect2(Vector2(180, 1363) * k, ANRI_PALETTE_SOURCE.size * 2.72 * k)
		brush_stage.position = Vector2(20, 2370) * k
		brush_stage.size = Vector2(1440, 650) * k
	else:
		tool_reference.size = Vector2.ZERO
		brush_stage.size = Vector2.ZERO
		var available := size - Vector2(BORDER * 2.0, TITLE_HEIGHT + BORDER * 2.0)
		var side := minf(available.x, available.y - 104.0)
		image_rect = Rect2(
			Vector2((size.x - side) / 2.0, TITLE_HEIGHT + BORDER), Vector2(side, side)
		)
	var rest_center := (
		(
			tool_reference.position
			+ Vector2(tool_reference.size.x * 0.5, tool_reference.size.y * 0.885)
		)
		if anri_mode
		else Vector2(size.x * 0.5, image_rect.end.y + 52.0)
	)
	brush_rest.size = Vector2(112, 108) if anri_mode else Vector2(92, 90)
	brush_rest.position = rest_center - brush_rest.size * 0.5
	brush_rest.visible = true
	parked_brush.size = Vector2(170, 158) if anri_mode else Vector2(132, 122)
	parked_brush.position = rest_center - parked_brush.size * 0.5 + Vector2(4, -6)
	parked_brush.visible = not brush_active
	brush_cursor.size = Vector2(130, 120)
	queue_redraw()
	state_changed.emit()


## Changed from the prototype: the pointer is the last mouse event's position, not a poll of the OS
## pointer (get_local_mouse_position on the root viewport reads the OS cursor, which an event pushed
## through Input.parse_input_event never moves). A real mouse behaves the same.
func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		_pointer = make_canvas_position_local(event.position)


func _process(delta: float) -> void:
	var mouse := _pointer
	var next_hovering := image_rect.has_point(mouse) and Rect2(Vector2.ZERO, size).has_point(mouse)
	if next_hovering != hovering:
		hovering = next_hovering
		brush_cursor.visible = hovering
		if hovering:
			Input.set_custom_mouse_cursor(_blank_cursor)
		else:  # the shell's arrow when it set one (hover-glow prototype), else the system arrow
			Input.set_custom_mouse_cursor(
				Engine.get_meta("arrow_cursor") if Engine.has_meta("arrow_cursor") else null,
				Input.CURSOR_ARROW,
				(
					Engine.get_meta("arrow_cursor").get_meta("tip")
					if Engine.has_meta("arrow_cursor")
					else Vector2.ZERO
				)
			)
		pointer_changed.emit()
		state_changed.emit()
	if hovering:
		brush_cursor.position = mouse - Vector2(3, 3)
	if _mixing:
		_mix_cue_elapsed += delta
		if _mix_cue_elapsed >= MIX_CUE_INTERVAL:
			_mix_cue_elapsed = 0.0
			sound_cue_requested.emit(SoundCues.MIXING)


func set_brush_active(active: bool) -> void:
	brush_active = active
	parked_brush.visible = not brush_active


func _update_brush_color() -> void:
	for brush in [parked_brush, brush_cursor]:
		(brush.material as ShaderMaterial).set_shader_parameter("pigment_color", brush_color)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#ffffff"))
	draw_rect(Rect2(Vector2.ZERO, size), Color("#24282b"), false, 2.0)
	if anri_mode:
		draw_texture_rect(ANRI_INTERIOR, Rect2(tool_reference.position, tool_reference.size), false)
	else:
		draw_rect(
			Rect2(BORDER, BORDER, size.x - BORDER * 2.0, TITLE_HEIGHT - BORDER), Color("#9bc4df")
		)
		draw_line(
			Vector2(BORDER, TITLE_HEIGHT),
			Vector2(size.x - BORDER, TITLE_HEIGHT),
			Color("#4d6778"),
			1.0
		)
	if not anri_mode:
		draw_string(
			ThemeDB.fallback_font,
			Vector2(10, 17),
			"Paintbox · soft smear",
			HORIZONTAL_ALIGNMENT_LEFT,
			size.x - 52,
			13,
			Color("#14222b")
		)
		draw_rect(Rect2(size.x - 30, 7, 17, 11), brush_color)
		draw_rect(Rect2(size.x - 31, 6, 19, 13), Color("#172027"), false, 1.0)
	if not anri_mode:
		draw_texture_rect(PALETTE, image_rect, false)
	var trays := _active_trays()
	for index in range(trays.size()):
		var tray: Rect2 = trays[index]
		draw_texture_rect(
			_tray_textures[index],
			Rect2(
				image_rect.position + tray.position * image_rect.size, tray.size * image_rect.size
			),
			false
		)
	var hovered_tray := _tray_at(_hover_uv)
	if hovered_tray >= 0:
		var rect: Rect2 = trays[hovered_tray]
		draw_rect(
			Rect2(
				image_rect.position + rect.position * image_rect.size, rect.size * image_rect.size
			),
			Color(brush_color, 0.7),
			false,
			2.0
		)


func _gui_input(event: InputEvent) -> void:
	if (
		anri_mode
		and event is InputEventMouseButton
		and event.pressed
		and event.button_index == MOUSE_BUTTON_LEFT
	):
		var source_point: Vector2 = event.position * 1484.0 / size.x
		if Rect2(1010, 450, 370, 430).has_point(source_point):
			tool_selected.emit("draw")
			accept_event()
			return
		if Rect2(1005, 975, 330, 330).has_point(source_point):
			tool_selected.emit("eraser")
			accept_event()
			return
	if event is InputEventMouseMotion:
		_hover_uv = _uv(event.position)
		mouse_default_cursor_shape = (
			CURSOR_POINTING_HAND
			if _well_at(_hover_uv) >= 0
			else CURSOR_CROSS if _tray_at(_hover_uv) >= 0 else CURSOR_ARROW
		)
		if _mixing and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_deposit(_hover_uv)
		queue_redraw()
		accept_event()
	elif event is InputEventMouseButton:
		var uv := _uv(event.position)
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var well := _well_at(uv)
				if well >= 0:
					brush_color = _sample_well(well)
					_update_brush_color()
					color_changed.emit(brush_color)
					sound_cue_requested.emit(SoundCues.REFILL)
					state_changed.emit()
					queue_redraw()
				elif _tray_at(uv) >= 0:
					_mixing = true
					_mix_cue_elapsed = 0.0
					sound_cue_requested.emit(SoundCues.MIXING)
					_drag_pigment = brush_color
					_last_deposit = Vector2(-10, -10)
					_deposit(uv)
			else:
				_mixing = false
				_mix_cue_elapsed = 0.0
			accept_event()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var tray := _tray_at(uv)
			if tray >= 0:
				_clear_tray(tray)
				queue_redraw()
				state_changed.emit()
				accept_event()


func _uv(point: Vector2) -> Vector2:
	return (point - image_rect.position) / image_rect.size


func _well_at(uv: Vector2) -> int:
	var hit := _active_well_hit()
	for row in range(2):
		for column in range(_well_column_count()):
			var center := _well_center(row, column)
			if absf(uv.x - center.x) <= hit.x and absf(uv.y - center.y) <= hit.y:
				return row * 16 + column
	return -1


func _well_center(row: int, column: int) -> Vector2:
	var start_x := ANRI_WELL_START_X if anri_mode else WELL_START_X
	var step_x := ANRI_WELL_STEP_X if anri_mode else WELL_STEP_X
	var rows := ANRI_WELL_Y if anri_mode else WELL_Y
	return Vector2(start_x + step_x * column, rows[row])


func _active_well_hit() -> Vector2:
	return ANRI_WELL_HIT if anri_mode else WELL_HIT


func _well_column_count() -> int:
	return 16


func _tray_at(uv: Vector2) -> int:
	var trays := _active_trays()
	for index in range(trays.size()):
		if trays[index].has_point(uv):
			return index
	return -1


func _active_trays() -> Array:
	return ANRI_TRAYS if anri_mode else TRAYS


func _sample_well(index: int) -> Color:
	var row := index / 16
	var column := index % 16
	var uv := Vector2(WELL_START_X + WELL_STEP_X * column, WELL_Y[row])
	var center := Vector2i(Vector2(_palette_image.get_size()) * uv)
	var bounds := Rect2i(center - Vector2i(8, 20), Vector2i(17, 41)).intersection(
		Rect2i(Vector2i.ZERO, _palette_image.get_size())
	)
	var pigment := _palette_image.get_pixelv(center)
	var best_score := -1.0
	for y in range(bounds.position.y, bounds.end.y):
		for x in range(bounds.position.x, bounds.end.x):
			var sample := _palette_image.get_pixel(x, y)
			var high := maxf(sample.r, maxf(sample.g, sample.b))
			var low := minf(sample.r, minf(sample.g, sample.b))
			var score := (
				(high - low) * 2.0
				+ (1.0 - (sample.r + sample.g + sample.b) / 3.0) * 0.35
				- absf(x - center.x) * 0.01
			)
			if sample.a > 0.9 and score > best_score:
				best_score = score
				pigment = sample
	return pigment


func _deposit(uv: Vector2) -> void:
	var tray := _tray_at(uv)
	if tray < 0:
		return
	var from := uv if _tray_at(_last_deposit) != tray else _last_deposit
	var distance := from.distance_to(uv) * 532.0
	var steps := maxi(1, int(ceil(distance / 2.0)))
	var direction := (uv - from).normalized() if distance > 0.1 else Vector2.RIGHT
	for step in range(1, steps + 1):
		_stamp(tray, from.lerp(uv, float(step) / steps), direction)
	_last_deposit = uv
	_tray_textures[tray].update(_tray_images[tray])
	_update_brush_color()
	color_changed.emit(brush_color)
	state_changed.emit()
	queue_redraw()


func _stamp(tray_index: int, uv: Vector2, direction: Vector2) -> void:
	_stamp_index += 1
	var tray: Rect2 = _active_trays()[tray_index]
	var image := _tray_images[tray_index]
	var center := Vector2((uv - tray.position) / tray.size) * Vector2(image.get_size())
	var tangent := direction.normalized()
	var normal := Vector2(-tangent.y, tangent.x)
	var radius := Vector2(7.0, 6.0)
	if smear_variant == "B":
		radius = Vector2(10.0, 4.5)
	elif smear_variant == "C":
		radius = Vector2(9.0, 6.5)
	var bounds := (
		Rect2i(Vector2i((center - Vector2(12, 9)).floor()), Vector2i(25, 19))
		. intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	)
	var touched_mix := false
	var picked := Color.TRANSPARENT
	var picked_weight := 0.0
	for y in range(bounds.position.y, bounds.end.y):
		for x in range(bounds.position.x, bounds.end.x):
			var offset := Vector2(x + 0.5, y + 0.5) - center
			var along := offset.dot(tangent) / radius.x
			var across := offset.dot(normal) / radius.y
			var distance := sqrt(along * along + across * across)
			var existing := image.get_pixel(x, y)
			if distance <= 1.0 and existing.a > 0.05:
				var weight := existing.a * (1.0 - distance)
				picked = (
					existing
					if picked_weight == 0.0
					else mix_colors(picked, existing, weight / (picked_weight + weight))
				)
				picked_weight += weight
	if picked_weight > 0.0 and not picked.is_equal_approx(_drag_pigment):
		_drag_pigment = mix_colors(_drag_pigment, picked, 0.42)
		touched_mix = true
	for y in range(bounds.position.y, bounds.end.y):
		for x in range(bounds.position.x, bounds.end.x):
			var offset := Vector2(x + 0.5, y + 0.5) - center
			var along := offset.dot(tangent) / radius.x
			var across := offset.dot(normal) / radius.y
			var distance := sqrt(along * along + across * across)
			if smear_variant == "A":
				var angle := atan2(across, along)
				distance /= 1.0 + 0.055 * sin(angle * 5.0 + _stamp_index * 0.7)
			elif smear_variant == "B":
				distance = maxf(absf(along), absf(across))
			var alpha := clampf((1.0 - distance) / 0.18, 0.0, 1.0)
			if smear_variant == "C":
				alpha *= 0.12 + 0.88 * absf(sin(across * 7.0)) ** 5
			if alpha <= 0.0:
				continue
			var pixel := Vector2i(x, y)
			var existing := image.get_pixelv(pixel)
			var deposit := alpha * 0.26
			var mixed := (
				_drag_pigment
				if existing.a < 0.01
				else mix_colors(existing, _drag_pigment, deposit / (existing.a + deposit))
			)
			if existing.a >= 0.12 and not existing.is_equal_approx(_drag_pigment):
				touched_mix = true
			if existing.a < 0.01:
				_paint_pixels += 1
			image.set_pixelv(
				pixel,
				Color(
					mixed.r, mixed.g, mixed.b, minf(1.0, existing.a + deposit * (1.0 - existing.a))
				)
			)
	brush_color = _drag_pigment
	if touched_mix:
		mix_count += 1


func _clear_tray(index: int) -> void:
	_tray_images[index].fill(Color.TRANSPARENT)
	_tray_textures[index].update(_tray_images[index])
	_paint_pixels = 0
	mix_count = 0


func set_smear_variant(next: String) -> void:
	smear_variant = next if next in ["A", "B", "C"] else "A"
	for index in range(_tray_images.size()):
		_clear_tray(index)
	queue_redraw()


func mix_colors(first: Color, second: Color, ratio: float) -> Color:
	return Mixbox.lerp(first, second, ratio)


func qa_state() -> Dictionary:
	return {
		"brush_color": brush_color.to_html(false),
		"brush_tip_color": brush_color.to_html(false),
		"cursor_asset": "muse-watercolor-brush",
		"brush_active": brush_active,
		"brush_parked": not brush_active,
		"hovering": hovering,
		"paint_pixels": _paint_pixels,
		"mix_count": mix_count,
		"smear_variant": smear_variant,
		"image_rect":
		[image_rect.position.x, image_rect.position.y, image_rect.size.x, image_rect.size.y],
		"mixbox": "2.0 upstream a1bdb75",
	}
