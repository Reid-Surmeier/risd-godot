## Throwaway isolated review surface for the live Muse-backed Collection filter.
extends Control

const FRAME := "res://modules/collection_page/assets/muse-filter-frame.webp"
const FONT := "res://modules/collection_page/assets/PixelMplus12-Regular.ttf"

var panel := TextureRect.new()
var body := ColorRect.new()
var font: Font
var has_image := CheckBox.new()
var none := CheckBox.new()


func _ready() -> void:
	font = load(FONT)
	var frame_image := Image.new()
	frame_image.load_webp_from_buffer(FileAccess.get_file_as_bytes(FRAME))
	var frame := AtlasTexture.new()
	frame.atlas = ImageTexture.create_from_image(frame_image)
	frame.region = Rect2(12, 526, 520, 220)
	panel.texture = frame
	panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	add_child(panel)
	body.color = Color("f2f1ef")
	panel.add_child(body)
	_build_controls()
	resized.connect(_layout)
	_layout()


func _style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("fafafa")
	style.border_color = Color("8799a5")
	style.set_border_width_all(1)
	style.content_margin_left = 4
	style.content_margin_right = 4
	return style


func _label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", font)
	label.add_theme_color_override("font_color", Color("243e58"))
	body.add_child(label)
	return label


func _control(control: Control) -> void:
	control.add_theme_font_override("font", font)
	control.add_theme_color_override("font_color", Color("243e58"))
	for state in ["normal", "focus", "hover", "pressed"]:
		control.add_theme_stylebox_override(state, _style())
	body.add_child(control)


func _build_controls() -> void:
	for text in ["Custom Filters :", "Sort by :", "Medium :", "View :", "Pw. :"]:
		_label(text)
	var query := LineEdit.new()
	_control(query)
	var sort := OptionButton.new()
	for text in ["Date (old→new)", "Date (new→old)", "Title (A→Z)", "Title (Z→A)"]:
		sort.add_item(text)
	_control(sort)
	var medium := OptionButton.new()
	medium.add_item("All")
	medium.add_item("Painting")
	_control(medium)
	has_image.text = "Has Image"
	has_image.button_pressed = true
	has_image.toggled.connect(func(pressed: bool) -> void: none.set_pressed_no_signal(not pressed))
	_control(has_image)
	none.text = "None"
	none.toggled.connect(func(pressed: bool) -> void: has_image.set_pressed_no_signal(not pressed))
	_control(none)
	var password := LineEdit.new()
	_control(password)
	for text in ["OK", "cancel"]:
		var button := Button.new()
		button.text = text
		if text == "cancel": button.pressed.connect(func() -> void: query.clear())
		_control(button)


func _layout() -> void:
	var scale := minf(size.x / 780.0, size.y / 430.0)
	panel.size = Vector2(650, 275) * scale
	panel.position = (size - panel.size) / 2.0
	body.position = Vector2(4, 46) * scale
	body.size = panel.size - Vector2(8, 50) * scale
	var children := body.get_children()
	for child_node in children:
		var child := child_node as Control
		child.add_theme_font_size_override("font_size", maxi(8, roundi(15 * scale)))
	var rects := [Rect2(12, 22, 150, 26), Rect2(12, 63, 80, 26), Rect2(244, 63, 78, 26), Rect2(12, 102, 54, 26), Rect2(284, 102, 48, 26), Rect2(172, 19, 322, 31), Rect2(96, 60, 119, 31), Rect2(329, 60, 165, 31), Rect2(69, 99, 109, 30), Rect2(178, 99, 102, 30), Rect2(340, 99, 154, 30), Rect2(346, 168, 76, 31), Rect2(428, 168, 66, 31)]
	for index in children.size():
		var child := children[index] as Control
		child.position = rects[index].position * scale
		child.size = rects[index].size * scale
