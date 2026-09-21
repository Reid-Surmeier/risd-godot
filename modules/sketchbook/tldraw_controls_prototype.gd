extends PanelContainer
## THROWAWAY IN-GAME PROTOTYPE. Interaction follows tldraw v5.3.2's StylePanel and QuickActions:
## discrete opacity, size choices, tools, and separately enabled undo/redo. Source is vendored in
## repos/tldraw/packages/tldraw/src/lib/ui/components/{StylePanel,QuickActions}/.

const OPACITIES := [0.1, 0.25, 0.5, 0.75, 1.0]
const SIZES := {"S": 2.5, "M": 4.5, "L": 8.0, "XL": 13.0}

var surface: Control
var title_bar := Panel.new()
var undo_button: Button
var redo_button: Button
var choice_buttons: Array[Button] = []
var selected_tool := "draw"
var selected_size := "M"
var selected_opacity := 4

func configure(next_surface: Control) -> void:
	surface = next_surface

func _ready() -> void:
	name = "tldraw-controls-prototype"
	custom_minimum_size = Vector2(250, 170)
	add_theme_stylebox_override("panel", _style())
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	add_child(column)
	title_bar.name = "title-bar"
	title_bar.custom_minimum_size = Vector2(0, 23)
	title_bar.mouse_default_cursor_shape = Control.CURSOR_DRAG
	title_bar.add_theme_stylebox_override("panel", _button_style(Color("b8d6e8"), Color("37566b")))
	column.add_child(title_bar)
	var title := Label.new()
	title.text = "Tldraw controls"
	title.position = Vector2(9, 3)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", Color("26374a"))
	title_bar.add_child(title)
	var tools := HBoxContainer.new()
	tools.add_theme_constant_override("separation", 2)
	column.add_child(tools)
	for item in [["Cursor", "select"], ["Hand", "hand"], ["Pen", "draw"], ["Eraser", "eraser"]]:
		var tool_button := _choice(item[0], "tool", item[1])
		tool_button.pressed.connect(_select_tool.bind(String(item[1])))
		tools.add_child(tool_button)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 2)
	column.add_child(actions)
	undo_button = _button("Undo", "Undo")
	undo_button.pressed.connect(surface.undo)
	actions.add_child(undo_button)
	redo_button = _button("Redo", "Redo")
	redo_button.pressed.connect(surface.redo)
	actions.add_child(redo_button)
	var size_row := HBoxContainer.new()
	size_row.add_theme_constant_override("separation", 2)
	column.add_child(size_row)
	for label in SIZES:
		var size_button := _choice(label, "size", label)
		size_button.pressed.connect(_select_size.bind(String(label)))
		size_row.add_child(size_button)
	var opacity_row := HBoxContainer.new()
	opacity_row.add_theme_constant_override("separation", 2)
	column.add_child(opacity_row)
	for index in OPACITIES.size():
		var opacity_button := _choice("%d%%" % int(OPACITIES[index] * 100.0), "opacity", index)
		opacity_button.pressed.connect(_select_opacity.bind(index))
		opacity_row.add_child(opacity_button)
	surface.strokes_changed.connect(_sync)
	_apply_style()
	_sync()

func _button(text: String, hint: String) -> Button:
	var button := Button.new()
	button.text = text
	button.tooltip_text = hint
	button.custom_minimum_size = Vector2(45, 24)
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_color_override("font_color", Color("172027"))
	button.add_theme_color_override("font_pressed_color", Color("174f89"))
	button.add_theme_stylebox_override("normal", _button_style(Color("ffffff"), Color("7b8c97")))
	button.add_theme_stylebox_override("hover", _button_style(Color("edf6fb"), Color("37566b")))
	button.add_theme_stylebox_override("pressed", _button_style(Color("d7eaf5"), Color("37566b")))
	return button

func _choice(label: String, kind: String, value: Variant) -> Button:
	var button := _button(label, label)
	button.toggle_mode = true
	button.set_meta("label", label)
	button.set_meta("kind", kind)
	button.set_meta("value", value)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choice_buttons.append(button)
	return button

func _apply_style() -> void:
	selected_tool = "draw"
	surface.set_tool(selected_tool)
	surface.set_pen_style(SIZES[selected_size], OPACITIES[selected_opacity])
	_sync()

func _select_tool(next: String) -> void:
	selected_tool = next
	surface.set_tool(next)
	_sync()

func _select_size(next: String) -> void:
	selected_size = next
	_apply_style()

func _select_opacity(next: int) -> void:
	selected_opacity = next
	_apply_style()

func _sync() -> void:
	if surface == null:
		return
	undo_button.disabled = not surface.can_undo()
	redo_button.disabled = not surface.can_redo()
	for button in choice_buttons:
		var selected: bool = (button.get_meta("kind") == "tool" and button.get_meta("value") == selected_tool
			or button.get_meta("kind") == "size" and button.get_meta("value") == selected_size
			or button.get_meta("kind") == "opacity" and button.get_meta("value") == selected_opacity)
		button.text = ("%s %s" % ["(*)" if selected else "( )", button.get_meta("label")])
		button.button_pressed = selected

func _exit_tree() -> void:
	if surface != null and surface.strokes_changed.is_connected(_sync):
		surface.strokes_changed.disconnect(_sync)

func _style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("f6f8fc")
	style.border_color = Color("d100d1")
	style.set_border_width_all(2)
	style.set_corner_radius_all(1)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 5
	style.content_margin_bottom = 7
	return style

func qa_state() -> Dictionary:
	return {
		"tool": selected_tool,
		"size": selected_size,
		"width": SIZES[selected_size],
		"opacity": OPACITIES[selected_opacity],
		"undo_enabled": not undo_button.disabled,
		"redo_enabled": not redo_button.disabled,
	}

func _button_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(1)
	style.content_margin_left = 4
	style.content_margin_right = 4
	return style
