extends Control

signal closed

const PaperTurn := preload("res://modules/playground_page/journal_paper_turn.gd")
const SOURCE_SIZE := Vector2(1138, 864)
const PAGE_RECT := Rect2(555, 194, 561, 616)
const CONTENT_RECT := Rect2(560, 258, 525, 415)
const RINGS_RECT := Rect2(400, 194, 155, 616)
const RAIL_RECT := Rect2(24, 194, 288, 615)
const BLANK_PIXEL := Vector2(1070, 690)
const ORIGINAL_ENTRY := "DEAR DIARY !! I LOOOVE THIS THING HAHAHAHAHAHAHA!! i decorated my room and and and my ROOMIE IS JUST SO CUTE !!!!!!!!!!\n\ni dont think my dad knew how much i would use this thing but nextrooms with my friends is like hanging with them 24/7 lol"
const ICON_RECT := Rect2(7, 5, 43, 43)
const CLOSE_RECT := Rect2(1090, 3, 42, 45)
const PREVIOUS_RECT := Rect2(672, 730, 68, 82)
const NEXT_RECT := Rect2(842, 730, 72, 82)
const TABS := [Rect2(9, 125, 257, 58), Rect2(266, 125, 222, 58), Rect2(488, 125, 239, 58)]

var image := TextureRect.new()
var editor := TextEdit.new()
var journal_material := ShaderMaterial.new()
var rail := ScrollContainer.new()
var turn: PaperTurn
var face_viewport: SubViewport
var face_paper: TextureRect
var face_editor: TextEdit
var rings := TextureRect.new()
var page_index := 0
var diary_index := 0
var selected_entry := "02-16-1996"
var turning := false
var _turn: Tween
var _loading_text := false
var _pages := {"0:0": ORIGINAL_ENTRY}


func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	var background := ColorRect.new()
	background.color = Color.WHITE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	journal_material.shader = _journal_shader()
	image.texture = preload("res://modules/playground_page/assets/sketchbook-journal.png")
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_SCALE
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image.material = journal_material
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(image)
	_build_editor()
	_build_rail()
	_build_turn()
	_add_button("Home", ICON_RECT, _show_home)
	_add_button("Close", CLOSE_RECT, _close)
	for index in TABS.size():
		_add_button("Journal%d" % index, TABS[index], _select_diary.bind(index))
	_add_button("Previous", PREVIOUS_RECT, _previous_page)
	_add_button("Next", NEXT_RECT, _next_page)
	resized.connect(_layout_buttons)
	_layout_buttons()
	_apply_state()
	assert(PAGE_RECT.end.x <= SOURCE_SIZE.x and PAGE_RECT.end.y <= SOURCE_SIZE.y)


func _build_editor() -> void:
	_style_editor(editor)
	editor.name = "DiaryText"
	editor.text_changed.connect(_save_page_text)
	add_child(editor)
	_load_page_text()


func _style_editor(target: TextEdit) -> void:
	var font: FontFile = preload("res://modules/playground_page/assets/fonts/PixelMplus12-Regular.ttf").duplicate()
	font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	target.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	target.scroll_fit_content_height = true
	target.add_theme_font_override("font", font)
	target.add_theme_color_override("font_color", Color("292929"))
	target.add_theme_color_override("caret_color", Color.BLACK)
	target.add_theme_color_override("font_shadow_color", Color("b8b8b8"))
	target.add_theme_constant_override("caret_width", 2)
	target.add_theme_constant_override("shadow_offset_x", 2)
	target.add_theme_constant_override("shadow_offset_y", 2)
	target.add_theme_constant_override("line_spacing", 7)
	for style_name in ["normal", "focus", "read_only"]:
		target.add_theme_stylebox_override(style_name, StyleBoxEmpty.new())


func _build_rail() -> void:
	rail.name = "DiaryEntries"
	rail.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	rail.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	rail.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 0)
	rail.add_child(list)
	for spec in [
		[Rect2(24, 194, 288, 58), false],
		[Rect2(24, 252, 288, 100), false],
		[Rect2(24, 352, 288, 100), false],
		[Rect2(24, 452, 288, 101), false],
		[Rect2(24, 553, 288, 102), false],
		[Rect2(24, 655, 288, 154), true],
		[Rect2(24, 352, 288, 100), false],
		[Rect2(24, 452, 288, 101), false],
	]:
		list.add_child(_rail_slice(spec[0], spec[1]))
	add_child(rail)


func _rail_slice(source_rect: Rect2, opens_entry: bool) -> Control:
	var holder := Control.new()
	holder.set_meta("source_height", source_rect.size.y)
	holder.custom_minimum_size = source_rect.size
	var texture := AtlasTexture.new()
	texture.atlas = image.texture
	texture.region = source_rect
	var pixels := TextureRect.new()
	pixels.texture = texture
	pixels.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pixels.stretch_mode = TextureRect.STRETCH_SCALE
	pixels.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pixels.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	holder.add_child(pixels)
	if opens_entry:
		var button := Button.new()
		button.name = "Entry"
		button.flat = true
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		button.pressed.connect(_open_entry)
		holder.add_child(button)
	return holder


func _build_turn() -> void:
	face_viewport = SubViewport.new()
	face_viewport.name = "journal-turn-face"
	face_viewport.transparent_bg = false
	face_viewport.disable_3d = true
	face_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	face_viewport.msaa_2d = Viewport.MSAA_4X
	var paper := ColorRect.new()
	paper.color = PaperTurn.CREAM
	paper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	face_viewport.add_child(paper)
	face_paper = TextureRect.new()
	face_paper.texture = image.texture
	face_paper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face_paper.stretch_mode = TextureRect.STRETCH_SCALE
	face_viewport.add_child(face_paper)
	face_editor = TextEdit.new()
	_style_editor(face_editor)
	face_editor.editable = false
	face_editor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	face_viewport.add_child(face_editor)
	add_child(face_viewport)
	turn = PaperTurn.new()
	turn.name = "journal-paper-turn"
	turn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	turn.visible = false
	add_child(turn)
	var ring_texture := AtlasTexture.new()
	ring_texture.atlas = image.texture
	ring_texture.region = RINGS_RECT
	rings.texture = ring_texture
	rings.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rings.stretch_mode = TextureRect.STRETCH_SCALE
	rings.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rings)


func _journal_shader() -> Shader:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
render_mode unshaded;

uniform vec4 press_rect = vec4(0.0);
uniform float press_offset = 0.0;
uniform vec4 selected_rect = vec4(9.0, 125.0, 257.0, 58.0);
uniform vec4 content_rect = vec4(560.0, 258.0, 525.0, 415.0);
uniform vec2 blank_pixel = vec2(1070.0, 690.0);
uniform int page_index = 0;

bool inside(vec2 p, vec4 r) {
	return p.x >= r.x && p.x < r.x + r.z && p.y >= r.y && p.y < r.y + r.w;
}

void fragment() {
	vec2 texture_size = 1.0 / TEXTURE_PIXEL_SIZE;
	vec2 pixel = UV * texture_size;
	vec2 sample_pixel = pixel;

	if (inside(pixel, selected_rect)) {
		sample_pixel.y = clamp(pixel.y - 1.0, selected_rect.y, selected_rect.y + selected_rect.w - 1.0);
	}
	if (press_offset > 0.0 && inside(pixel, press_rect)) {
		sample_pixel.y = clamp(pixel.y - press_offset, press_rect.y, press_rect.y + press_rect.w - 1.0);
	}

	if (inside(pixel, content_rect)) {
		sample_pixel = blank_pixel;
	}
	if (page_index == 1 && inside(pixel, vec4(768.0, 745.0, 22.0, 36.0))) {
		sample_pixel = vec2(631.0, 639.0) + pixel - vec2(768.0, 745.0);
	} else if (page_index == 2 && inside(pixel, vec4(768.0, 745.0, 22.0, 36.0))) {
		sample_pixel = vec2(797.0, 745.0) + pixel - vec2(768.0, 745.0);
	}

	vec4 source = texture(TEXTURE, sample_pixel / texture_size);
	if (inside(pixel, vec4(7.0, 3.0, 43.0, 45.0)) || inside(pixel, vec4(1090.0, 3.0, 42.0, 45.0))) {
		float mono = dot(source.rgb, vec3(0.299, 0.587, 0.114));
		source.rgb = vec3(step(0.62, mono));
	}
	COLOR = source;
}
"""
	return shader


func _add_button(button_name: String, source_rect: Rect2, action: Callable) -> void:
	var button := Button.new()
	button.name = button_name
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.set_meta("source_rect", source_rect)
	button.button_down.connect(_press.bind(source_rect))
	button.button_up.connect(_release)
	button.pressed.connect(action)
	add_child(button)


func _layout_buttons() -> void:
	var scale := size / SOURCE_SIZE
	editor.position = CONTENT_RECT.position * scale
	editor.size = CONTENT_RECT.size * scale
	editor.add_theme_font_size_override("font_size", maxi(12, roundi(29.0 * scale.y)))
	editor.add_theme_constant_override("line_spacing", maxi(3, roundi(9.0 * scale.y)))
	rail.position = RAIL_RECT.position * scale
	rail.size = RAIL_RECT.size * scale
	var list: VBoxContainer = rail.get_child(0)
	list.custom_minimum_size.x = rail.size.x
	for child in list.get_children():
		var source_height: float = child.get_meta("source_height")
		child.custom_minimum_size = Vector2(rail.size.x, source_height * scale.y)
	var page := Rect2(PAGE_RECT.position * scale, PAGE_RECT.size * scale)
	face_viewport.size = Vector2i(ceili(page.size.x), ceili(page.size.y))
	face_paper.position = -PAGE_RECT.position * scale
	face_paper.size = size
	face_editor.position = (CONTENT_RECT.position - PAGE_RECT.position) * scale
	face_editor.size = CONTENT_RECT.size * scale
	face_editor.add_theme_font_size_override("font_size", maxi(12, roundi(29.0 * scale.y)))
	face_editor.add_theme_constant_override("line_spacing", maxi(3, roundi(9.0 * scale.y)))
	turn.position = Vector2.ZERO
	turn.size = size
	rings.position = RINGS_RECT.position * scale
	rings.size = RINGS_RECT.size * scale
	for button in find_children("*", "Button", false, false):
		if not button.has_meta("source_rect"):
			continue
		var rect: Rect2 = button.get_meta("source_rect")
		button.position = rect.position * scale
		button.size = rect.size * scale


func _press(rect: Rect2) -> void:
	journal_material.set_shader_parameter("press_rect", Vector4(rect.position.x, rect.position.y, rect.size.x, rect.size.y))
	journal_material.set_shader_parameter("press_offset", 3.0)


func _release() -> void:
	journal_material.set_shader_parameter("press_offset", 0.0)


func _show_home() -> void:
	_turn_to(0, -1.0, 0)


func _close() -> void:
	visible = false
	closed.emit()


func _select_diary(index: int) -> void:
	if index == diary_index or turning:
		return
	_turn_to(0, 1.0, index)


func _open_entry() -> void:
	if turning:
		return
	_turn_to(0, 1.0, 0)


func _previous_page() -> void:
	if page_index > 0:
		_turn_to(page_index - 1, -1.0)


func _next_page() -> void:
	if page_index < 2:
		_turn_to(page_index + 1, 1.0)


func _turn_to(target: int, _direction: float, target_diary: int = -1) -> void:
	if turning:
		return
	_save_page_text()
	turning = true
	editor.release_focus()
	_prepare_turn_face()
	page_index = target
	if target_diary >= 0:
		diary_index = target_diary
	selected_entry = "02-16-1996" if diary_index == 0 else ""
	_load_page_text()
	_apply_state()
	_turn = create_tween()
	_turn.tween_method(_set_turn_progress, 0.0, 1.0, 0.52)
	_turn.tween_callback(func() -> void:
		turn.visible = false
		face_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
		turning = false
		_apply_state())


func _set_turn_progress(value: float) -> void:
	turn.progress = value
	turn.queue_redraw()


func _prepare_turn_face() -> void:
	var scale := size / SOURCE_SIZE
	var page := Rect2(PAGE_RECT.position * scale, PAGE_RECT.size * scale)
	face_paper.material = journal_material.duplicate()
	face_editor.text = editor.text
	face_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	turn.direction = "forward"
	turn.progress = 0.0
	turn.hinge = page.position + Vector2(0.0, page.size.y / 2.0)
	turn.sheet_size = page.size
	turn.face = face_viewport.get_texture()
	turn.visible = true
	turn.queue_redraw()


func _apply_state() -> void:
	journal_material.set_shader_parameter("page_index", page_index)
	journal_material.set_shader_parameter("diary_index", diary_index)
	var tab: Rect2 = TABS[diary_index]
	journal_material.set_shader_parameter("selected_rect", Vector4(tab.position.x, tab.position.y, tab.size.x, tab.size.y))
	editor.editable = not turning
	get_node("Previous").disabled = page_index == 0 or turning
	get_node("Next").disabled = page_index == 2 or turning


func _page_key() -> String:
	return "%d:%d" % [diary_index, page_index]


func _save_page_text() -> void:
	if not _loading_text:
		_pages[_page_key()] = editor.text


func _load_page_text() -> void:
	_loading_text = true
	editor.text = _pages.get(_page_key(), "")
	_loading_text = false


func qa_state() -> Dictionary:
	return {"page": page_index + 1, "diary": diary_index, "entry": selected_entry,
		"text": editor.text, "turning": turning, "visible": visible,
		"rail_scroll": rail.scroll_vertical, "caret_color": editor.get_theme_color("caret_color")}


func title_button_at(local_point: Vector2) -> bool:
	var source_point := local_point * SOURCE_SIZE / size
	return ICON_RECT.has_point(source_point) or CLOSE_RECT.has_point(source_point)
