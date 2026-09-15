## Issue #75 prototype only: native controls and fixture result states laid over the accepted
## Collection chrome. Production integration belongs to #79.
extends Control

const Page := preload("res://modules/collection_page/interface.gd")
const FONT_PATH := "res://modules/atlas/fonts/PixelMplus12-Regular.ttf"
const IMAGE_PATHS := [
	"res://docs/evidence/collection-search/images/b7e66eee6aac0ed42db55788dd2d2cd2e65fa3128b6599c769f140eff71e0ce6.jpg",
	"res://docs/evidence/collection-search/images/f50520a15ef1eb172fc00e472bd117be00d2f4f3136fb6949d4e06752ba6a50b.jpg",
]
const RECORDS := [
	{"title": "A Walk by the Sea", "maker": "Claude Monet", "date": "1866", "category": "Painting", "image": 0,
		"source": "RISD Museum · 11.036", "credit": "Gift of Mrs. Murray S. Danforth"},
	{"title": "The Seine at Argenteuil", "maker": "Claude Monet", "date": "1874", "category": "Painting", "image": 1,
		"source": "RISD Museum · 43.213", "credit": "Museum Appropriation Fund"},
	{"title": "Missing image example", "maker": "Prototype fixture", "date": "1900", "category": "Drawing", "image": -1,
		"source": "Fixture only", "credit": "Image unavailable"},
]

var page: Control
var body := ColorRect.new()
var results := ColorRect.new()
var query := LineEdit.new()
var sort := OptionButton.new()
var category := OptionButton.new()
var has_image := CheckBox.new()
var ok := Button.new()
var cancel := Button.new()
var status := Label.new()
var cards := Control.new()
var details := PanelContainer.new()
var retry := Button.new()
var font: Font
var applied := {"query": "", "sort": 0, "category": 0, "has_image": false}
var phase := "results"
var visible_count := 3
var selected := -1
var save_state := "save"
var requests := 0
var generation := 0


static func create(deps: Dictionary) -> Dictionary:
	var made: Dictionary = Page.create(deps)
	if not made.ok:
		return made
	var prototype = load("res://prototypes/collection_search_controls/prototype.gd").new()
	prototype.name = "CollectionSearchPrototype"
	prototype.page = made.value
	prototype.page.name = "AcceptedCollectionPage"
	prototype.page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	prototype.add_child(prototype.page)
	prototype.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return {"ok": true, "value": prototype, "error": null}


func _ready() -> void:
	font = load(FONT_PATH)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	body.color = Color("f2f1ef")
	body.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(body)
	results.color = Color.WHITE
	results.mouse_filter = Control.MOUSE_FILTER_STOP
	results.clip_contents = true
	add_child(results)
	_build_filters()
	_build_results()
	resized.connect(_layout)
	_layout()
	_show_results()


func _label(text_value: String) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_font_override("font", font)
	label.add_theme_color_override("font_color", Color("243e58"))
	return label


func _field_style(color: Color = Color("fafafa")) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = Color("8799a5")
	box.set_border_width_all(1)
	box.set_corner_radius_all(2)
	box.content_margin_left = 5
	box.content_margin_right = 5
	return box


func _theme_control(control: Control) -> void:
	control.add_theme_font_override("font", font)
	control.add_theme_color_override("font_color", Color("243e58"))
	control.add_theme_font_size_override("font_size", 14)
	for style_name in ["normal", "focus", "hover", "pressed"]:
		control.add_theme_stylebox_override(style_name, _field_style(Color("dcecff") if style_name in ["focus", "hover"] else Color("fafafa")))


func _build_filters() -> void:
	for label_text in ["Search", "Sort", "Category"]:
		var label := _label(label_text)
		label.name = label_text + "Label"
		body.add_child(label)
	query.name = "Query"
	query.placeholder_text = "artist, title, keyword"
	query.clear_button_enabled = true
	query.text_submitted.connect(func(_value: String) -> void: _apply())
	_theme_control(query)
	body.add_child(query)
	sort.name = "Sort"
	for text in ["Title (A→Z)", "Date (new→old)", "Date (old→new)"]:
		sort.add_item(text)
	_theme_control(sort)
	body.add_child(sort)
	category.name = "Category"
	for text in ["All categories", "Painting", "Drawing"]:
		category.add_item(text)
	_theme_control(category)
	body.add_child(category)
	has_image.name = "HasImage"
	has_image.text = "Has Image"
	_theme_control(has_image)
	body.add_child(has_image)
	ok.name = "OK"
	ok.text = "OK"
	ok.pressed.connect(_apply)
	_theme_control(ok)
	body.add_child(ok)
	cancel.name = "Cancel"
	cancel.text = "cancel"
	cancel.pressed.connect(_cancel)
	_theme_control(cancel)
	body.add_child(cancel)


func _build_results() -> void:
	status.name = "FixtureStatus"
	status.add_theme_font_override("font", font)
	status.add_theme_color_override("font_color", Color("243e58"))
	results.add_child(status)
	cards.name = "FixtureCards"
	results.add_child(cards)
	retry.name = "Retry"
	retry.text = "Retry"
	retry.visible = false
	retry.pressed.connect(_apply)
	_theme_control(retry)
	results.add_child(retry)
	details.name = "Details"
	details.visible = false
	details.add_theme_stylebox_override("panel", _field_style(Color("eef5fb")))
	results.add_child(details)


func _filter_panel() -> Control:
	return page.find_child("filters", true, false)


func _layout() -> void:
	if not is_instance_valid(page) or not is_instance_valid(page.frame):
		return
	var filter_panel := _filter_panel()
	if filter_panel == null:
		return
	var drag_height: float = filter_panel.get_meta("drag_height")
	body.position = filter_panel.position + Vector2(3, drag_height)
	body.size = filter_panel.size - Vector2(6, drag_height + 3)
	var s := minf(body.size.x / 502.0, body.size.y / 196.0)
	var fs := maxi(10, roundi(14 * s))
	for control in body.get_children():
		control.add_theme_font_size_override("font_size", fs)
	_place(body.get_node("SearchLabel"), Rect2(8, 8, 78, 30), s)
	_place(query, Rect2(82, 7, 412, 31), s)
	_place(body.get_node("SortLabel"), Rect2(8, 48, 44, 30), s)
	_place(sort, Rect2(48, 47, 142, 31), s)
	_place(body.get_node("CategoryLabel"), Rect2(202, 48, 78, 30), s)
	_place(category, Rect2(278, 47, 216, 31), s)
	_place(has_image, Rect2(8, 88, 150, 30), s)
	_place(ok, Rect2(332, 154, 76, 31), s)
	_place(cancel, Rect2(414, 154, 80, 31), s)
	results.position = page.frame.position + page.scroll.position
	results.size = page.scroll.size
	status.position = Vector2(10, 5)
	status.size = Vector2(results.size.x - 20, 28)
	status.add_theme_font_size_override("font_size", maxi(11, roundi(15 * page.factor)))
	cards.position = Vector2(10, 36)
	cards.size = Vector2(results.size.x - 20, results.size.y - 44)
	retry.position = Vector2(12, 70)
	retry.size = Vector2(100, 34)
	details.position = Vector2(results.size.x * 0.60, 40)
	details.size = Vector2(results.size.x * 0.38, results.size.y - 52)
	_layout_cards()


func _place(control: Control, rect: Rect2, scale: float) -> void:
	control.position = rect.position * scale
	control.size = rect.size * scale


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		_cancel()
		get_viewport().set_input_as_handled()


func _draft() -> Dictionary:
	return {"query": query.text, "sort": sort.selected, "category": category.selected, "has_image": has_image.button_pressed}


func _restore(values: Dictionary) -> void:
	query.text = values.query
	sort.select(values.sort)
	category.select(values.category)
	has_image.button_pressed = values.has_image


func _apply() -> void:
	applied = _draft()
	requests += 1
	generation += 1
	var current := generation
	phase = "loading"
	status.text = "PROTOTYPE FIXTURES · Searching… showing %d previous result%s" % [visible_count, "" if visible_count == 1 else "s"]
	retry.visible = false
	await get_tree().create_timer(0.35).timeout
	if current != generation:
		return
	if applied.query.strip_edges().to_lower() == "fail":
		_show_error()
	else:
		_show_results()


func _cancel() -> void:
	generation += 1
	_restore(applied)
	phase = "results"
	status.text = "PROTOTYPE FIXTURES · Cancelled · %d result%s" % [visible_count, "" if visible_count == 1 else "s"]
	retry.visible = false


func _matching_records() -> Array:
	var needle: String = applied.query.strip_edges().to_lower()
	if needle == "none":
		return []
	var found := []
	for i in RECORDS.size():
		var record: Dictionary = RECORDS[i]
		if applied.has_image and record.image < 0:
			continue
		if applied.category > 0 and record.category != category.get_item_text(applied.category):
			continue
		if needle != "" and needle not in (record.title + " " + record.maker).to_lower():
			continue
		found.append(i)
	found.sort_custom(func(a: int, b: int) -> bool:
		if applied.sort == 0: return RECORDS[a].title < RECORDS[b].title
		return int(RECORDS[a].date) > int(RECORDS[b].date) if applied.sort == 1 else int(RECORDS[a].date) < int(RECORDS[b].date))
	return found


func _clear_cards() -> void:
	for child in cards.get_children():
		child.queue_free()
	details.visible = false
	selected = -1
	save_state = "save"


func _show_results() -> void:
	phase = "results"
	retry.visible = false
	_clear_cards()
	var found := _matching_records()
	visible_count = found.size()
	status.text = "PROTOTYPE FIXTURES · %d result%s · RISD source + credit retained" % [visible_count, "" if visible_count == 1 else "s"]
	if found.is_empty():
		var empty := _label("No works match these filters. Change a filter and press OK.")
		empty.name = "EmptyState"
		empty.position = Vector2(8, 18)
		empty.size = Vector2(cards.size.x - 16, 50)
		empty.add_theme_font_size_override("font_size", 16)
		cards.add_child(empty)
		return
	for record_index in found:
		cards.add_child(_card(record_index))
	_layout_cards()


func _card(record_index: int) -> PanelContainer:
	var record: Dictionary = RECORDS[record_index]
	var card := PanelContainer.new()
	card.name = "Card%d" % record_index
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.add_theme_stylebox_override("panel", _field_style(Color("f6f7f7")))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	card.add_child(column)
	if record.image >= 0:
		var image := TextureRect.new()
		image.texture = load(IMAGE_PATHS[record.image])
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.size_flags_vertical = Control.SIZE_EXPAND_FILL
		image.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.add_child(image)
	else:
		var missing := _label("IMAGE\nUNAVAILABLE")
		missing.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		missing.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		missing.size_flags_vertical = Control.SIZE_EXPAND_FILL
		missing.add_theme_color_override("font_color", Color("6e7680"))
		column.add_child(missing)
	for text_value in [record.title, "%s · %s" % [record.maker, record.date], record.source, record.credit]:
		var line := _label(text_value)
		line.clip_text = true
		line.tooltip_text = text_value
		line.add_theme_font_size_override("font_size", 12)
		column.add_child(line)
	card.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_select(record_index))
	return card


func _layout_cards() -> void:
	var children := cards.get_children()
	if children.is_empty():
		return
	var gap := 8.0
	var width := (cards.size.x - gap * 2.0) / 3.0
	for i in children.size():
		if children[i] is PanelContainer:
			children[i].position = Vector2(i * (width + gap), 0)
			children[i].size = Vector2(width, cards.size.y)


func _select(record_index: int) -> void:
	selected = record_index
	save_state = "save"
	for child in details.get_children():
		child.queue_free()
	var record: Dictionary = RECORDS[record_index]
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	details.add_child(column)
	for text_value in ["SELECTED FIXTURE", record.title, "%s · %s" % [record.maker, record.date], record.source, record.credit]:
		var line := _label(text_value)
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.add_theme_font_size_override("font_size", 13)
		column.add_child(line)
	var save := Button.new()
	save.name = "Save"
	save.text = "Save to Playground + Sketchbook"
	_theme_control(save)
	column.add_child(save)
	var save_status := _label("Save presentation fixture")
	save_status.name = "SaveStatus"
	column.add_child(save_status)
	var error := Button.new()
	error.name = "SaveError"
	error.text = "Preview save error"
	_theme_control(error)
	column.add_child(error)
	save.pressed.connect(func() -> void:
		save_state = "saved"
		save.text = "Saved"
		save.disabled = true
		save_status.text = "Saved presentation fixture")
	error.pressed.connect(func() -> void:
		save_state = "error"
		save_status.text = "Save error fixture · Retry remains available"
		save.disabled = false
		save.text = "Retry save")
	details.visible = true


func _show_error() -> void:
	generation += 1
	phase = "error"
	_clear_cards()
	status.text = "PROTOTYPE FIXTURE · Search failed · previous results preserved concept inspected"
	var error := _label("The museum search could not be reached. Your filters are still here.\nSave error presentation: browser storage unavailable.")
	error.name = "ErrorState"
	error.position = Vector2(8, 16)
	error.size = Vector2(cards.size.x - 16, 70)
	error.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	error.add_theme_font_size_override("font_size", 15)
	cards.add_child(error)
	retry.visible = true


func state() -> Dictionary:
	var controls := {}
	for control in [query, sort, category, has_image, ok, cancel, retry, details]:
		var rect: Rect2 = control.get_global_rect()
		controls[control.name] = [rect.position.x, rect.position.y, rect.size.x, rect.size.y]
	var popup := sort.get_popup()
	var category_menu := category.get_popup()
	return {"ok": true, "value": {"phase": phase, "draft": _draft(), "applied": applied.duplicate(), "visible_count": visible_count,
		"selected": selected, "save_state": save_state, "requests": requests, "controls": controls,
		"query_focused": query.has_focus(), "font_path": FONT_PATH,
		"sort_popup": {"visible": popup.visible, "position": [popup.position.x, popup.position.y], "size": [popup.size.x, popup.size.y]},
		"category_popup": {"visible": category_menu.visible, "position": [category_menu.position.x, category_menu.position.y], "size": [category_menu.size.x, category_menu.size.y]},
		"layout_reference_sha256": "e51cbb294653573b43432f623df7277a86adbeddb0d2f0d7c31b36928592075d"}, "error": null}
