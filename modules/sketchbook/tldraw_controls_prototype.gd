extends PanelContainer
## THROWAWAY IN-GAME PROTOTYPE. Interaction follows tldraw v5.3.2's StylePanel and QuickActions:
## discrete opacity, size choices, tools, and separately enabled undo/redo. Source is vendored in
## repos/tldraw/packages/tldraw/src/lib/ui/components/{StylePanel,QuickActions}/.

const OPACITIES := [0.1, 0.25, 0.5, 0.75, 1.0]
const SIZES := {"S": 2.5, "M": 4.5, "L": 8.0, "XL": 13.0}

var surface: Control
var title_bar := Control.new()
var opacity_slider := HSlider.new()
var undo_button := Button.new()
var redo_button := Button.new()
var selected_size := "M"

func configure(next_surface: Control) -> void:
	surface = next_surface

func _ready() -> void:
	name = "tldraw-controls-prototype"
	custom_minimum_size = Vector2(244, 178)
	add_theme_stylebox_override("panel", _style())
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	add_child(column)
	title_bar.name = "title-bar"
	title_bar.custom_minimum_size = Vector2(0, 24)
	title_bar.mouse_default_cursor_shape = Control.CURSOR_DRAG
	column.add_child(title_bar)
	var title := Label.new()
	title.text = "Tldraw controls · prototype"
	title.position = Vector2(9, 3)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.add_theme_font_size_override("font_size", 13)
	title_bar.add_child(title)
	var actions := HBoxContainer.new()
	column.add_child(actions)
	undo_button = _button("↶", "Undo")
	undo_button.pressed.connect(surface.undo)
	actions.add_child(undo_button)
	redo_button = _button("↷", "Redo")
	redo_button.pressed.connect(surface.redo)
	actions.add_child(redo_button)
	for item in [["↖", "select", "Cursor"], ["✋", "hand", "Hand"], ["✎", "draw", "Pen"], ["⌫", "eraser", "Eraser"]]:
		var tool_button := _button(item[0], item[2])
		tool_button.pressed.connect(func(): surface.set_tool(item[1]); _sync())
		actions.add_child(tool_button)
	var size_row := HBoxContainer.new()
	column.add_child(size_row)
	for label in SIZES:
		var size_button := _button(label, "%s pen" % label)
		size_button.pressed.connect(func(): selected_size = label; _apply_style())
		size_row.add_child(size_button)
	var opacity_row := HBoxContainer.new()
	column.add_child(opacity_row)
	var opacity_label := Label.new()
	opacity_label.text = "Opacity"
	opacity_label.custom_minimum_size = Vector2(58, 0)
	opacity_row.add_child(opacity_label)
	opacity_slider.min_value = 0
	opacity_slider.max_value = OPACITIES.size() - 1
	opacity_slider.step = 1
	opacity_slider.value = OPACITIES.size() - 1
	opacity_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	opacity_slider.tooltip_text = "Opacity: 10%, 25%, 50%, 75%, 100%"
	opacity_slider.value_changed.connect(func(_value): _apply_style())
	opacity_row.add_child(opacity_slider)
	surface.strokes_changed.connect(_sync)
	_apply_style()
	_sync()

func _button(text: String, hint: String) -> Button:
	var button := Button.new()
	button.text = text
	button.tooltip_text = hint
	button.custom_minimum_size = Vector2(33, 25)
	return button

func _apply_style() -> void:
	surface.set_tool("draw")
	surface.set_pen_style(SIZES[selected_size], OPACITIES[int(opacity_slider.value)])
	_sync()

func _sync() -> void:
	if surface == null:
		return
	undo_button.disabled = not surface.can_undo()
	redo_button.disabled = not surface.can_redo()

func _style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("f6f8fc")
	style.border_color = Color("6f8cb1")
	style.set_border_width_all(2)
	style.set_corner_radius_all(5)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 5
	style.content_margin_bottom = 7
	return style
