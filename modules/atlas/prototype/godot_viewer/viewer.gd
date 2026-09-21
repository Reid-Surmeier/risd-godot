extends Control

# Standalone QA prototype: click either map badge to swap the page image.
const POPUP_SIZE := Vector2(1696, 1216)
const PAGE_RECT := Rect2(61, 140, 1602, 1020)
const CONTENT_WIDTH := 1566.0
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
var content := VBoxContainer.new()
var painting := TextureRect.new()
var description := Label.new()
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
	# Crop Muse's exterior glow so this reads as a window, not a floating card.
	template.position = Vector2(-44, -44)
	template.size = Vector2(1784, 1304)
	popup.add_child(template)
	page.position = PAGE_RECT.position
	page.size = PAGE_RECT.size
	page.clip_contents = true
	page.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_style_scrollbar(page.get_v_scroll_bar())
	popup.add_child(page)
	content.custom_minimum_size = Vector2(CONTENT_WIDTH, 0)
	content.add_theme_constant_override("separation", 22)
	page.add_child(content)
	painting.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	painting.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	content.add_child(painting)
	description.add_theme_font_size_override("font_size", 30)
	description.add_theme_color_override("font_color", Color.BLACK)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.custom_minimum_size = Vector2(CONTENT_WIDTH, 112)
	content.add_child(description)
	var drag_handle := Control.new()
	drag_handle.position = Vector2(60, 30)
	drag_handle.size = Vector2(1570, 110)
	drag_handle.mouse_filter = Control.MOUSE_FILTER_STOP
	drag_handle.gui_input.connect(_drag_input)
	popup.add_child(drag_handle)


func _show_artwork(number: int) -> void:
	var texture: Texture2D = load(ARTWORKS[number])
	painting.texture = texture
	painting.custom_minimum_size = Vector2(CONTENT_WIDTH, CONTENT_WIDTH * texture.get_height() / texture.get_width())
	if number == 8:
		description.text = "A Walk in the Meadows at Argenteuil\nClaude Monet · 1873\nMarker 8"
	else:
		description.text = "The Seine Near its Estuary, Honfleur\nClaude Monet · ca. 1868\nMarker 14"
	page.scroll_vertical = 0
	popup.show()
	_layout()


func _style_scrollbar(bar: VScrollBar) -> void:
	bar.custom_minimum_size = Vector2(34, 0)
	var track := StyleBoxFlat.new()
	track.bg_color = Color("eeeeee")
	track.border_color = Color("9a9a9a")
	track.set_border_width_all(2)
	var thumb := StyleBoxFlat.new()
	thumb.bg_color = Color("aaaaaa")
	thumb.border_color = Color("555555")
	thumb.set_border_width_all(2)
	thumb.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("scroll", track)
	bar.add_theme_stylebox_override("grabber", thumb)
	bar.add_theme_stylebox_override("grabber_highlight", thumb)


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
