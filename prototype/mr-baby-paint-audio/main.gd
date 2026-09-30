extends Control

const VARIANTS := ["A", "B", "C"]
const VARIANT_NAMES := {
	"A": "Grouped shelves",
	"B": "Alphabetical lab",
	"C": "Task tabs",
}
const GROUPS := [
	"Interface feedback",
	"Windows and modals",
	"Tools and materials",
	"Drawing gestures",
	"Fill and sand",
	"Canvas and history",
	"Capture and startup",
]
const CONTEXT := {
	"Interface feedback": "Hover, press, click, confirmation, and volume feedback.",
	"Windows and modals": "Opening, closing, muting, and dismissing interface layers.",
	"Tools and materials": "Choosing a brush, colour, character, or shape; placing shapes.",
	"Drawing gestures": "Marks, circles, and longer drawing motions.",
	"Fill and sand": "Starting, sustaining, cancelling, or stopping fills and pours.",
	"Canvas and history": "Clearing the canvas and undo/redo outcomes.",
	"Capture and startup": "Screenshot feedback and splash-screen moments.",
}

var player := AudioStreamPlayer.new()
var content := VBoxContainer.new()
var status := Label.new()
var status_text := "Nothing playing"
var variant := "A"


func _ready() -> void:
	variant = _variant_from_url()
	add_child(player)
	_build_page()


func _build_page() -> void:
	for child in get_children():
		if child != player:
			child.queue_free()

	var background := ColorRect.new()
	background.color = Color("#f4efe3")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var page := VBoxContainer.new()
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 20)
	page.add_theme_constant_override("separation", 12)
	add_child(page)

	var title := Label.new()
	title.text = "MR. BABY PAINT · SOUND AUDITION"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("#222222"))
	page.add_child(title)

	var intro := Label.new()
	intro.text = "77 original game streams · inferred groups, exact filenames · tap any sound to compare"
	intro.add_theme_font_size_override("font_size", 16)
	intro.add_theme_color_override("font_color", Color("#665f53"))
	page.add_child(intro)

	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 10)
	status = Label.new()
	status.text = status_text
	status.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status.add_theme_color_override("font_color", Color("#173a71"))
	controls.add_child(status)
	var stop := Button.new()
	stop.text = "■ Stop"
	stop.pressed.connect(_stop)
	controls.add_child(stop)
	page.add_child(controls)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.add_child(scroll)
	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	scroll.add_child(content)

	match variant:
		"B":
			_build_alphabetical()
		"C":
			_build_tabs()
		_:
			_build_grouped()
	_build_switcher()


func _build_grouped() -> void:
	for group in GROUPS:
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", _panel_style(Color("#fffdf8"), Color("#d0c4ae")))
		var section := VBoxContainer.new()
		section.add_theme_constant_override("separation", 7)
		panel.add_child(section)
		section.add_child(_heading(group, 22))
		var note := Label.new()
		note.text = CONTEXT[group]
		note.add_theme_color_override("font_color", Color("#665f53"))
		section.add_child(note)
		var flow := HFlowContainer.new()
		flow.add_theme_constant_override("h_separation", 8)
		flow.add_theme_constant_override("v_separation", 8)
		for path in _sounds_in(group):
			flow.add_child(_sound_button(path, true))
		section.add_child(flow)
		content.add_child(panel)


func _build_alphabetical() -> void:
	content.add_child(_heading("Alphabetical lab", 22))
	var paths := _all_sounds()
	paths.sort()
	for path in paths:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		var group := Label.new()
		group.text = _group_for(path)
		group.custom_minimum_size = Vector2(190, 42)
		group.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		group.add_theme_color_override("font_color", Color("#665f53"))
		row.add_child(group)
		var button := _sound_button(path, false)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(button)
		content.add_child(row)


func _build_tabs() -> void:
	var tabs := TabContainer.new()
	tabs.custom_minimum_size = Vector2(0, 640)
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for group in GROUPS:
		var tab := VBoxContainer.new()
		tab.name = group.replace(" and ", " + ")
		tab.add_theme_constant_override("separation", 14)
		var note := Label.new()
		note.text = CONTEXT[group]
		note.add_theme_font_size_override("font_size", 18)
		note.add_theme_color_override("font_color", Color("#665f53"))
		tab.add_child(note)
		var flow := HFlowContainer.new()
		flow.add_theme_constant_override("h_separation", 10)
		flow.add_theme_constant_override("v_separation", 10)
		for path in _sounds_in(group):
			flow.add_child(_sound_button(path, true))
		tab.add_child(flow)
		tabs.add_child(tab)
	content.add_child(tabs)


func _build_switcher() -> void:
	var bar := HBoxContainer.new()
	bar.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	bar.position = Vector2(-170, -66)
	bar.size = Vector2(340, 46)
	bar.add_theme_constant_override("separation", 8)
	add_child(bar)
	var previous := Button.new()
	previous.text = "←"
	previous.custom_minimum_size = Vector2(46, 46)
	previous.pressed.connect(func(): _switch_variant(-1))
	bar.add_child(previous)
	var label := Label.new()
	label.text = "%s · %s" % [variant, VARIANT_NAMES[variant]]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(220, 46)
	label.add_theme_color_override("font_color", Color("#ffffff"))
	label.add_theme_stylebox_override("normal", _panel_style(Color("#222222"), Color("#222222")))
	bar.add_child(label)
	var next := Button.new()
	next.text = "→"
	next.custom_minimum_size = Vector2(46, 46)
	next.pressed.connect(func(): _switch_variant(1))
	bar.add_child(next)


func _sound_button(path: String, compact: bool) -> Button:
	var button := Button.new()
	button.text = "▶  " + _display_name(path)
	button.tooltip_text = path.get_file()
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(250 if compact else 0, 46)
	button.add_theme_font_size_override("font_size", 14)
	button.pressed.connect(func(): _play(path))
	return button


func _play(path: String) -> void:
	player.stop()
	player.stream = load(path)
	player.play()
	status_text = "Playing · %s  —  %s" % [_display_name(path), _group_for(path)]
	status.text = status_text


func _stop() -> void:
	player.stop()
	status_text = "Stopped"
	status.text = status_text


func _all_sounds() -> Array[String]:
	var paths: Array[String] = []
	for name in DirAccess.get_files_at("res://sounds"):
		if name.ends_with(".res"):
			paths.append("res://sounds/" + name)
	return paths


func _sounds_in(group: String) -> Array[String]:
	var matches: Array[String] = []
	for path in _all_sounds():
		if _group_for(path) == group:
			matches.append(path)
	matches.sort()
	return matches


func _group_for(path: String) -> String:
	var name := path.get_file().to_lower()
	if name.begins_with("fill") or name.begins_with("stop_fill") or name.begins_with("pour_sand"):
		return "Fill and sand"
	if name.begins_with("draw"):
		return "Drawing gestures"
	if (
		name.begins_with("empty_canvas")
		or name.begins_with("undo")
		or name.begins_with("redo")
		or name.begins_with("no_undo")
	):
		return "Canvas and history"
	if name.begins_with("screenshot") or name.begins_with("splash_screen"):
		return "Capture and startup"
	if (
		name.begins_with("close_")
		or name.begins_with("open_")
		or name.begins_with("modal_")
		or name.begins_with("mute")
	):
		return "Windows and modals"
	if (
		name.begins_with("brush_")
		or name.begins_with("color_")
		or name.begins_with("pick_")
		or name.begins_with("place_")
	):
		return "Tools and materials"
	return "Interface feedback"


func _display_name(path: String) -> String:
	var name := path.get_file().trim_suffix(".res").trim_suffix(".wav").replace("_", " ")
	return name.capitalize()


func _heading(text: String, size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color("#222222"))
	return label


func _panel_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style


func _variant_from_url() -> String:
	if OS.has_feature("web"):
		var value = JavaScriptBridge.eval(
			"new URLSearchParams(window.location.search).get('variant') || 'A'"
		)
		if value in VARIANTS:
			return value
	return "A"


func _switch_variant(direction: int) -> void:
	var index := wrapi(VARIANTS.find(variant) + direction, 0, VARIANTS.size())
	variant = VARIANTS[index]
	if OS.has_feature("web"):
		JavaScriptBridge.eval("history.replaceState(null, '', '?variant=%s')" % variant)
	_build_page()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.pressed and event.keycode == KEY_LEFT:
		_switch_variant(-1)
	elif event.pressed and event.keycode == KEY_RIGHT:
		_switch_variant(1)
