extends Control

const POPUP_SIZE := Vector2(1180, 920)
const FRAME := preload("res://assets/muse-window-frame.webp")
const TERRAIN := preload("res://assets/terrain.png")
const FONT := preload("res://assets/PixelMplus12-Regular.ttf")
const ARTWORKS := {
	8: {"title": "A Walk in the Meadows at Argenteuil", "maker": "Claude Monet · 1873", "image": "res://assets/marker-8.jpg"},
	14: {"title": "The Seine Near its Estuary, Honfleur", "maker": "Claude Monet · ca. 1868", "image": "res://assets/marker-14.jpg"},
}

var popup := Control.new()
var frame_clip := Control.new()
var frame := TextureRect.new()
var scroll := ScrollContainer.new()
var painting := TextureRect.new()
var copy := VBoxContainer.new()
var title := Label.new()
var maker := Label.new()
var marker_copy := Label.new()
var dragging := false
var minimized := false


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var map := TextureRect.new()
	map.texture = TERRAIN
	map.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	map.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	map.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(map)
	_add_marker("8", Vector2(0.312, 0.34), 8, Color("608ab5"))
	_add_marker("14", Vector2(0.532, 0.21), 14, Color("ae5e8d"))
	_build_popup()
	resized.connect(_layout)
	_layout()
	_show_artwork(14)


func _add_marker(text: String, at: Vector2, number: int, color: Color) -> void:
	var marker := Button.new()
	marker.text = text
	marker.position = Vector2(size.x * at.x, size.y * at.y)
	marker.size = Vector2(38, 30)
	marker.add_theme_font_override("font", FONT)
	marker.add_theme_font_size_override("font_size", 18)
	marker.add_theme_color_override("font_color", Color.WHITE)
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(0)
	marker.add_theme_stylebox_override("normal", style)
	marker.pressed.connect(func(): _show_artwork(number))
	add_child(marker)


func _build_popup() -> void:
	popup.name = "ArtworkPreview"
	popup.size = POPUP_SIZE
	popup.clip_contents = true
	add_child(popup)
	frame_clip.clip_contents = true
	frame_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame_clip.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	popup.add_child(frame_clip)
	frame.texture = FRAME
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame_clip.add_child(frame)
	var preview := _label("PREVIEW", 24)
	preview.position = Vector2(82, 37)
	preview.custom_minimum_size = Vector2(300, 36)
	preview.autowrap_mode = TextServer.AUTOWRAP_OFF
	popup.add_child(preview)
	var drag_handle := Control.new()
	drag_handle.position = Vector2(62, 18)
	drag_handle.size = Vector2(900, 112)
	drag_handle.mouse_filter = Control.MOUSE_FILTER_STOP
	drag_handle.gui_input.connect(_drag_input)
	popup.add_child(drag_handle)
	_add_control("−", Vector2(1037, 47), Color("6195d7"), func(): _toggle_minimize())
	_add_control("×", Vector2(1080, 47), Color("c94b54"), func(): popup.hide())
	scroll.position = Vector2(76, 148)
	scroll.size = Vector2(974, 706)
	popup.add_child(scroll)
	copy.add_theme_constant_override("separation", 12)
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.custom_minimum_size = Vector2(958, 0)
	scroll.add_child(copy)
	painting.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	painting.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	copy.add_child(painting)
	copy.add_child(title)
	copy.add_child(maker)
	copy.add_child(marker_copy)


func _add_control(text: String, at: Vector2, color: Color, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.position = at
	button.size = Vector2(32, 29)
	button.add_theme_font_override("font", FONT)
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_color_override("font_color", Color.WHITE)
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("274b7a")
	style.set_border_width_all(2)
	button.add_theme_stylebox_override("normal", style)
	button.pressed.connect(action)
	popup.add_child(button)


func _label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("182b45"))
	label.modulate = Color("182b45")
	label.custom_minimum_size = Vector2(900, font_size + 8)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _show_artwork(number: int) -> void:
	var item: Dictionary = ARTWORKS[number]
	var texture: Texture2D = load(item.image)
	painting.texture = texture
	painting.custom_minimum_size = Vector2(958, 958.0 * texture.get_height() / texture.get_width())
	title.text = item.title
	maker.text = item.maker
	marker_copy.text = "Marker %d · prototype preview" % number
	for label in [title, maker, marker_copy]:
		label.add_theme_color_override("font_color", Color.BLACK)
		label.modulate = Color.WHITE
	popup.show()
	minimized = false
	_layout_popup()
	scroll.scroll_vertical = 0


func _toggle_minimize() -> void:
	minimized = not minimized
	_layout_popup()


func _drag_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
	elif event is InputEventMouseMotion and dragging:
		popup.position += event.relative / popup.scale
		popup.position = popup.position.clamp(Vector2.ZERO, (size - popup.size * popup.scale).max(Vector2.ZERO))


func _layout() -> void:
	_layout_popup()


func _layout_popup() -> void:
	popup.size = Vector2(POPUP_SIZE.x, 140 if minimized else POPUP_SIZE.y)
	var scale := minf(1.0, minf((size.x - 32.0) / POPUP_SIZE.x, (size.y - 32.0) / popup.size.y))
	popup.scale = Vector2.ONE * scale
	if not dragging:
		popup.position = Vector2(size.x - popup.size.x * scale - 24, 24).max(Vector2(8, 8))
	frame.size = popup.size
	frame.position = -popup.size * 0.1
	frame.size *= 1.2
	scroll.visible = not minimized
