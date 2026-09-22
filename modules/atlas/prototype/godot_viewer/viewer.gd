extends Control

# Standalone QA prototype: click either map badge to swap the page image.
const POPUP_SIZE := Vector2(1696, 1216)
const PAGE_RECT := Rect2(102, 174, 1452, 946)
const TEMPLATE := "res://assets/information-window-template.webp"
const TERRAIN := "res://assets/terrain.png"
const FONT := "res://assets/PixelMplus12-Regular.ttf"
const ARTWORKS := {
	8: "res://assets/marker-8.jpg",
	14: "res://assets/marker-14.jpg",
}

var popup := Control.new()
var template := TextureRect.new()
var page := ScrollContainer.new()
var painting := TextureRect.new()
var dragging := false


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var map := TextureRect.new()
	map.texture = load(TERRAIN)
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


func _add_marker(text: String, at: Vector2, number: int, color: Color) -> void:
	var marker := Button.new()
	marker.text = text
	marker.position = Vector2(size.x * at.x, size.y * at.y)
	marker.size = Vector2(38, 30)
	marker.add_theme_font_override("font", load(FONT))
	marker.add_theme_font_size_override("font_size", 18)
	marker.add_theme_color_override("font_color", Color.WHITE)
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(0)
	marker.add_theme_stylebox_override("normal", style)
	marker.pressed.connect(func(): _show_artwork(number))
	add_child(marker)


func _build_popup() -> void:
	popup.name = "InformationPreview"
	popup.size = POPUP_SIZE
	popup.clip_contents = true
	popup.hide()
	add_child(popup)
	template.texture = load(TEMPLATE)
	template.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	template.stretch_mode = TextureRect.STRETCH_SCALE
	template.mouse_filter = Control.MOUSE_FILTER_IGNORE
	template.size = POPUP_SIZE
	popup.add_child(template)
	page.position = PAGE_RECT.position
	page.size = PAGE_RECT.size
	page.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.get_v_scroll_bar().hide()
	popup.add_child(page)
	painting.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	painting.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	page.add_child(painting)
	var drag_handle := Control.new()
	drag_handle.position = Vector2(60, 30)
	drag_handle.size = Vector2(1570, 110)
	drag_handle.mouse_filter = Control.MOUSE_FILTER_STOP
	drag_handle.gui_input.connect(_drag_input)
	popup.add_child(drag_handle)


func _show_artwork(number: int) -> void:
	var texture: Texture2D = load(ARTWORKS[number])
	painting.texture = texture
	painting.custom_minimum_size = Vector2(PAGE_RECT.size.x, PAGE_RECT.size.x * texture.get_height() / texture.get_width())
	page.scroll_vertical = 0
	popup.show()
	_layout()


func _drag_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		dragging = event.pressed
	elif event is InputEventMouseMotion and dragging:
		popup.position += event.relative / popup.scale
		popup.position = popup.position.clamp(Vector2.ZERO, (size - popup.size * popup.scale).max(Vector2.ZERO))


func _layout() -> void:
	var scale := minf(1.0, minf((size.x - 32.0) / POPUP_SIZE.x, (size.y - 32.0) / POPUP_SIZE.y))
	popup.scale = Vector2.ONE * scale
	if not dragging:
		popup.position = Vector2(size.x - POPUP_SIZE.x * scale - 24, 24).max(Vector2(8, 8))
