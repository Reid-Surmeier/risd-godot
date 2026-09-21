## The approved WebSurfer raster as an interactive Playground window. No text or replacement UI is
## drawn: invisible controls move pixels sampled from the source image for presses and scrolling.
extends Control

const SOURCE_SIZE := Vector2(1616, 1568)
const CROP_TOP := 88.0
const VISIBLE_SIZE := Vector2(1616, 1407)
const CONTENT_RECT := Rect2(58, 685, 1425, 720)
const SCROLL_RECT := Rect2(1548, 278, 58, 1149)
const RESIZE_RECT := Rect2(1540, 1425, 76, 70)
const MAX_CONTENT_SCROLL := 240.0
const NAV_ITEMS := [
	{"name": "Visit", "rect": Rect2(72, 582, 183, 67), "scroll": 0.0},
	{"name": "Art and Design", "rect": Rect2(282, 582, 255, 67), "scroll": 0.2},
	{"name": "Join / Give", "rect": Rect2(565, 582, 198, 67), "scroll": 0.4},
	{"name": "Users", "rect": Rect2(792, 582, 98, 67), "scroll": 0.6},
	{"name": "Exhibitions and Events", "rect": Rect2(917, 582, 320, 67), "scroll": 0.0},
	{"name": "Watch / Read", "rect": Rect2(1262, 582, 228, 67), "scroll": 1.0},
]

var window_material := ShaderMaterial.new()
var scroll_progress := 0.0
var current_page := "Exhibitions and Events"
var scroll_tween: Tween
var dragging_scrollbar := false
var resizing := false
var resize_start_pointer := Vector2.ZERO
var resize_start_scale := 1.0
var nav_buttons: Array[Button] = []
var scroll_input := Control.new()
var resize_input := Control.new()
var image: TextureRect


func _ready() -> void:
	clip_contents = true
	_build_asset()
	_build_input()
	resized.connect(_layout_input)
	_layout_input()


func _build_asset() -> void:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
render_mode unshaded;
uniform float scroll_progress = 0.0;
uniform vec4 content_rect = vec4(58.0, 685.0, 1425.0, 720.0);
uniform vec4 scroll_rect = vec4(1548.0, 278.0, 58.0, 1149.0);
uniform float content_scroll = 240.0;
uniform vec4 pressed_rect = vec4(0.0);
uniform float press_offset = 0.0;
void fragment() {
	vec2 source_size = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 pixel = UV * source_size;
	vec2 sample_pixel = pixel;
	if (press_offset > 0.0 && pixel.x >= pressed_rect.x && pixel.x < pressed_rect.x + pressed_rect.z && pixel.y >= pressed_rect.y && pixel.y < pressed_rect.y + pressed_rect.w) {
		sample_pixel.y = clamp(pixel.y - press_offset, pressed_rect.y, pressed_rect.y + pressed_rect.w - 1.0);
	}
	if (scroll_progress > 0.0001 && pixel.x >= content_rect.x && pixel.x < content_rect.x + content_rect.z && pixel.y >= content_rect.y && pixel.y < content_rect.y + content_rect.w) {
		float shifted_y = pixel.y + scroll_progress * content_scroll;
		sample_pixel = shifted_y < content_rect.y + content_rect.w ? vec2(pixel.x, shifted_y) : vec2(1400.0, 700.0);
	}
	if (scroll_progress > 0.0001 && pixel.x >= scroll_rect.x && pixel.x < scroll_rect.x + scroll_rect.z && pixel.y >= scroll_rect.y && pixel.y < scroll_rect.y + scroll_rect.w) {
		float thumb_height = 710.0;
		float new_top = scroll_rect.y + scroll_progress * (scroll_rect.w - thumb_height);
		sample_pixel.y = pixel.y >= new_top && pixel.y < new_top + thumb_height ? scroll_rect.y + pixel.y - new_top : 1100.0;
	}
	COLOR = texture(TEXTURE, sample_pixel / source_size);
}
"""
	window_material.shader = shader
	window_material.set_shader_parameter("content_rect", Vector4(CONTENT_RECT.position.x, CONTENT_RECT.position.y, CONTENT_RECT.size.x, CONTENT_RECT.size.y))
	window_material.set_shader_parameter("scroll_rect", Vector4(SCROLL_RECT.position.x, SCROLL_RECT.position.y, SCROLL_RECT.size.x, SCROLL_RECT.size.y))
	window_material.set_shader_parameter("content_scroll", MAX_CONTENT_SCROLL)
	image = TextureRect.new()
	image.texture = preload("res://modules/playground_page/assets/websurfer-window.webp")
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_SCALE
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image.material = window_material
	add_child(image)


func _build_input() -> void:
	var wheel := Control.new()
	wheel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wheel.mouse_filter = Control.MOUSE_FILTER_PASS
	wheel.gui_input.connect(_on_wheel_input)
	add_child(wheel)
	for item in NAV_ITEMS:
		var button := Button.new()
		button.flat = true
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.button_down.connect(_press_button.bind(item.rect))
		button.button_up.connect(_release_button.bind(item.name, item.scroll))
		add_child(button)
		nav_buttons.append(button)
	scroll_input.mouse_default_cursor_shape = Control.CURSOR_VSIZE
	scroll_input.gui_input.connect(_on_scrollbar_input)
	add_child(scroll_input)
	resize_input.name = "ResizeGrip"
	resize_input.mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
	resize_input.gui_input.connect(_on_resize_input)
	add_child(resize_input)


func _layout_input() -> void:
	if nav_buttons.is_empty():
		return
	var scale_to_window := size / VISIBLE_SIZE
	image.position = Vector2(0, -CROP_TOP) * scale_to_window
	image.size = SOURCE_SIZE * scale_to_window
	for index in NAV_ITEMS.size():
		var source: Rect2 = NAV_ITEMS[index].rect
		nav_buttons[index].position = (source.position - Vector2(0, CROP_TOP)) * scale_to_window
		nav_buttons[index].size = source.size * scale_to_window
	scroll_input.position = (SCROLL_RECT.position - Vector2(0, CROP_TOP)) * scale_to_window
	scroll_input.size = SCROLL_RECT.size * scale_to_window
	resize_input.position = (RESIZE_RECT.position - Vector2(0, CROP_TOP)) * scale_to_window
	resize_input.size = RESIZE_RECT.size * scale_to_window
	set_meta("drag_height", (190.0 - CROP_TOP) * scale_to_window.y)


func _press_button(rect: Rect2) -> void:
	window_material.set_shader_parameter("pressed_rect", Vector4(rect.position.x, rect.position.y, rect.size.x, rect.size.y))
	window_material.set_shader_parameter("press_offset", 3.0)


func _release_button(page_name: String, target_scroll: float) -> void:
	window_material.set_shader_parameter("press_offset", 0.0)
	current_page = page_name
	_animate_scroll(target_scroll)


func _on_wheel_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_animate_scroll(scroll_progress + 0.2)
			accept_event()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_animate_scroll(scroll_progress - 0.2)
			accept_event()


func _on_scrollbar_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging_scrollbar = event.pressed
		if event.pressed:
			_set_scroll_from_pointer(event.position.y)
		accept_event()
	elif event is InputEventMouseMotion and dragging_scrollbar:
		_set_scroll_from_pointer(event.position.y)
		accept_event()


func _on_resize_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		resizing = event.pressed
		if event.pressed:
			resize_start_pointer = event.global_position
			resize_start_scale = size.y / VISIBLE_SIZE.y
		accept_event()
	elif event is InputEventMouseMotion and resizing:
		var delta: Vector2 = event.global_position - resize_start_pointer
		var dx: float = delta.x / VISIBLE_SIZE.x
		var dy: float = delta.y / VISIBLE_SIZE.y
		var scale_delta: float = dx if absf(dx) > absf(dy) else dy
		var page: Control = get_parent() as Control
		var max_scale: float = minf((page.size.x - position.x) / VISIBLE_SIZE.x, (page.size.y - position.y) / VISIBLE_SIZE.y)
		var next_scale: float = clampf(resize_start_scale + scale_delta, 0.25, max_scale)
		size = VISIBLE_SIZE * next_scale
		accept_event()


func _set_scroll_from_pointer(pointer_y: float) -> void:
	var thumb_height := 710.0 * size.y / VISIBLE_SIZE.y
	_set_scroll((pointer_y - thumb_height * 0.5) / (scroll_input.size.y - thumb_height))


func _animate_scroll(target: float) -> void:
	if scroll_tween and scroll_tween.is_valid():
		scroll_tween.kill()
	scroll_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	scroll_tween.tween_method(_set_scroll, scroll_progress, clampf(target, 0.0, 1.0), 0.18)


func _set_scroll(value: float) -> void:
	scroll_progress = clampf(value, 0.0, 1.0)
	window_material.set_shader_parameter("scroll_progress", scroll_progress)
