## Throwaway layout study: a PostPet-like object tray beside the real Buddha 3D viewer.
## Run: godot --path . res://prototypes/postpet_viewer/prototype.tscn
extends Control

const Viewer := preload("res://prototypes/postpet_viewer/viewer.gd")
const OBJECTS := [
	["Buddha", "3D scan loaded", "obj_buddha.png"],
	["Lion standard", "Ancient bronze", "obj_bronze.png"],
	["Marble bust", "Roman portrait", "obj_bust.png"],
	["Seal pair", "Ivory carving", "obj_seals.png"],
]

var tray: PanelContainer
var selected_label: Label
var viewer_title: Label
var viewer: Control


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_resized()
	resized.connect(_resized)
	_build_tray()
	viewer = Viewer.new()
	viewer.name = "Buddha3DViewer"
	add_child(viewer)
	_build_caption()
	_resized()


func _panel_style(fill: Color, radius := 16, border := Color("#d1dce8"), width := 2) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.border_color = border
	style.border_width_left = width
	style.border_width_top = width
	style.border_width_right = width
	style.border_width_bottom = width
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	return style


func _label(text: String, size := 18, color := Color("#3e5161")) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _build_tray() -> void:
	tray = PanelContainer.new()
	tray.name = "object-tray"
	tray.add_theme_stylebox_override("panel", _panel_style(Color("#f9fcff"), 20, Color("#c9d9e8"), 2))
	add_child(tray)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	tray.add_child(column)
	var logo := _label("PostPet Museum", 28, Color("#f14f91"))
	column.add_child(logo)
	column.add_child(_label("Choose an object to place in your viewing tray.", 15))
	var divider := HSeparator.new()
	column.add_child(divider)
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 9)
	grid.add_theme_constant_override("v_separation", 9)
	column.add_child(grid)
	for index in OBJECTS.size():
		grid.add_child(_object_card(index))
	selected_label = _label("Viewing now: Buddha — rotate the scan at right.", 15, Color("#d1457d"))
	column.add_child(selected_label)
	var chat := _label("Global Chat\nSakumaRiri: Love the detail!\nANRI: At RISD? Nice!", 14, Color("#4f6a7d"))
	chat.add_theme_stylebox_override("normal", _panel_style(Color("#eef7fc"), 10, Color("#d8e7f1"), 1))
	column.add_child(chat)


func _object_card(index: int) -> Button:
	var object: Array = OBJECTS[index]
	var button := Button.new()
	button.name = "object-%s" % object[0].to_lower().replace(" ", "-")
	button.custom_minimum_size = Vector2(136, 170)
	button.tooltip_text = "%s — %s" % [object[0], object[1]]
	button.add_theme_stylebox_override("normal", _panel_style(Color.WHITE, 13, Color("#dbe6ef"), 1))
	button.add_theme_stylebox_override("hover", _panel_style(Color("#fff1f8"), 13, Color("#f28ab7"), 2))
	button.add_theme_stylebox_override("pressed", _panel_style(Color("#ffe2f0"), 13, Color("#e65b98"), 2))
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	button.add_child(column)
	var icon := TextureRect.new()
	icon.texture = load("res://prototypes/postpet_viewer/assets/%s" % object[2])
	icon.custom_minimum_size = Vector2(112, 104)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(icon)
	var title := _label(object[0], 16, Color("#48596a"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(title)
	var detail := _label(object[1], 12, Color("#8292a1"))
	detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(detail)
	button.pressed.connect(func(): _select_object(object))
	return button


func _build_caption() -> void:
	viewer_title = _label("RISD Object Viewer  •  Buddha", 20, Color("#5b6c7a"))
	viewer_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(viewer_title)


func _select_object(object: Array) -> void:
	selected_label.text = "Tray selection: %s — %s" % [object[0], object[1]]
	viewer_title.text = "RISD Object Viewer  •  Buddha scan  •  tray: %s" % object[0]


func _resized() -> void:
	if size.x < 20 or size.y < 20:
		return
	var margin := clampf(size.x * 0.025, 18.0, 44.0)
	var left_width := clampf(size.x * 0.30, 430.0, 460.0)
	if tray != null:
		tray.position = Vector2(margin, margin)
		tray.size = Vector2(left_width, size.y - margin * 2)
	var right_origin := Vector2(margin + left_width + margin, margin)
	var right_size := Vector2(size.x - right_origin.x - margin, size.y - margin * 2)
	if viewer_title != null:
		viewer_title.position = right_origin
		viewer_title.size = Vector2(right_size.x, 34)
	if viewer != null:
		var slot := Rect2(right_origin + Vector2(0, 42), right_size - Vector2(0, 42))
		var scale_factor := minf(slot.size.x / 800.0, slot.size.y / 680.0)
		viewer.scale = Vector2(scale_factor, scale_factor)
		viewer.position = slot.position + (slot.size - Vector2(800, 680) * scale_factor) * 0.5
