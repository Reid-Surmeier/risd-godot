## Native Collection search controls and results. Callers use interface.gd and the injected
## collection_data handle only.
extends Node

const Data := preload("res://modules/collection_data/interface.gd")
const FONT_PATH := "res://modules/collection_page/assets/PixelMplus12-Regular.ttf"
const SNAPSHOT_EXPIRED := "collection_data.snapshot_expired"
const SORTS := ["title_asc", "title_desc", "date_asc", "date_desc"]
const SORT_LABELS := ["Title (A→Z)", "Title (Z→A)", "Date (old→new)", "Date (new→old)"]

var page: Control
var data_handle: Variant
var image_fetch: Callable
var body := ColorRect.new()
var results := ColorRect.new()
var footer := ColorRect.new()
var query := LineEdit.new()
var sort := OptionButton.new()
var category := OptionButton.new()
var has_image := CheckBox.new()
var ok := Button.new()
var cancel := Button.new()
var retry := Button.new()
var previous := Button.new()
var next := Button.new()
var status := Label.new()
var count := Label.new()
var scroll := ScrollContainer.new()
var cards := HFlowContainer.new()
var details := PanelContainer.new()
var font: Font
var phase := "idle"
var applied := {"q": "", "category": "All", "sort": "date_asc", "has_image": true, "page": 1}
var last_successful: Dictionary = applied.duplicate(true)
var response: Dictionary = {}
var selected := ""
var requests := 0
var completions := 0
var ignored_completions := 0
var generation := 0
var images_loaded := 0
var image_failures := 0
var layout_key := ""
var pending_result: Dictionary = {}


func _ready() -> void:
	font = load(FONT_PATH)
	body.color = Color("f2f1ef")
	body.mouse_filter = Control.MOUSE_FILTER_STOP
	page.find_child("filters", true, false).add_child(body)
	results.color = Color.WHITE
	results.mouse_filter = Control.MOUSE_FILTER_STOP
	results.clip_contents = true
	page.frame.add_child(results)
	footer.color = Color("f6f6f6")
	footer.mouse_filter = Control.MOUSE_FILTER_STOP
	page.frame.add_child(footer)
	_build_filters()
	_build_results()
	page.visibility_changed.connect(_resume_pending)
	_layout()
	_apply()


func _process(_delta: float) -> void:
	var filter_panel: Control = page.find_child("filters", true, false)
	var key := str(filter_panel.size) + str(page.frame.size) + str(page.scroll.position) + str(page.scroll.size)
	if key != layout_key:
		_layout()


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
	box.content_margin_left = 4
	box.content_margin_right = 4
	return box


func _theme_control(control: Control) -> void:
	control.add_theme_font_override("font", font)
	for color_name in ["font_color", "font_focus_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color"]:
		control.add_theme_color_override(color_name, Color("243e58"))
	for style_name in ["normal", "focus", "hover", "pressed"]:
		control.add_theme_stylebox_override(style_name, _field_style(Color("dcecff") if style_name in ["focus", "hover"] else Color("fafafa")))


func _build_filters() -> void:
	for label_spec in [["Search", "Search"], ["Sort", "Sort"], ["Category", "Medium"]]:
		var label := _label(label_spec[1])
		label.name = label_spec[0] + "Label"
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		body.add_child(label)
	query.name = "Query"
	query.placeholder_text = "artist, title, keyword"
	query.clear_button_enabled = true
	query.text_submitted.connect(func(_value: String) -> void: _apply())
	_theme_control(query)
	body.add_child(query)
	sort.name = "Sort"
	sort.fit_to_longest_item = false
	for label_text in SORT_LABELS:
		sort.add_item(label_text)
	sort.select(SORTS.find("date_asc"))
	_theme_control(sort)
	body.add_child(sort)
	category.name = "Category"
	category.fit_to_longest_item = false
	category.add_item("All")
	category.add_item("Painting")
	_theme_control(category)
	body.add_child(category)
	has_image.name = "HasImage"
	has_image.text = "Has Image"
	has_image.button_pressed = true
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
	status.name = "SearchStatus"
	status.add_theme_font_override("font", font)
	status.add_theme_color_override("font_color", Color("243e58"))
	status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	results.add_child(status)
	scroll.name = "Results"
	scroll.focus_mode = Control.FOCUS_ALL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	results.add_child(scroll)
	cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards.add_theme_constant_override("h_separation", 8)
	cards.add_theme_constant_override("v_separation", 8)
	scroll.add_child(cards)
	retry.name = "Retry"
	retry.text = "Retry"
	retry.visible = false
	retry.pressed.connect(_retry)
	_theme_control(retry)
	results.add_child(retry)
	details.name = "Details"
	details.visible = false
	details.add_theme_stylebox_override("panel", _field_style(Color("eef5fb")))
	results.add_child(details)
	count.add_theme_font_override("font", font)
	count.add_theme_color_override("font_color", Color("243e58"))
	count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.add_child(count)
	for button in [previous, next]:
		_theme_control(button)
		footer.add_child(button)
	previous.name = "Previous"
	previous.text = "←"
	previous.pressed.connect(func() -> void: _page(-1))
	next.name = "Next"
	next.text = "→"
	next.pressed.connect(func() -> void: _page(1))


func _layout() -> void:
	if not is_instance_valid(page) or not is_instance_valid(page.frame):
		return
	var filter_panel: Control = page.find_child("filters", true, false)
	var drag_height: float = filter_panel.get_meta("drag_height")
	body.position = Vector2(3, drag_height)
	body.size = filter_panel.size - Vector2(6, drag_height + 3)
	var s := minf(body.size.x / 502.0, body.size.y / 196.0)
	var fs := maxi(7, roundi(14 * s))
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
	results.position = page.scroll.position
	results.size = page.scroll.size
	var page_font := maxi(7, roundi(14 * page.factor))
	status.position = Vector2(8, 3)
	status.size = Vector2(results.size.x - 16, 27)
	status.add_theme_font_size_override("font_size", page_font)
	scroll.position = Vector2(8, 31)
	scroll.size = Vector2(results.size.x - 16, results.size.y - 37)
	cards.custom_minimum_size.x = scroll.size.x
	retry.position = Vector2(12, 44)
	retry.size = Vector2(maxf(52, 90 * page.factor), maxf(20, 30 * page.factor))
	retry.add_theme_font_size_override("font_size", page_font)
	details.position = Vector2(results.size.x * 0.58, 34)
	details.size = Vector2(results.size.x * 0.40, results.size.y - 42)
	var footer_height := maxf(22, 120 * page.pixel_scale)
	footer.position = Vector2(6, page.frame.size.y - 6 - footer_height)
	footer.size = Vector2(page.frame.size.x * 0.62, footer_height)
	count.position = Vector2(4, 1)
	count.size = Vector2(footer.size.x * 0.65, footer_height - 2)
	count.add_theme_font_size_override("font_size", page_font)
	for i in 2:
		var button: Button = [previous, next][i]
		button.position = Vector2(footer.size.x - 74 + i * 36, 1)
		button.size = Vector2(34, footer_height - 2)
		button.add_theme_font_size_override("font_size", page_font)
	_layout_cards()
	layout_key = str(filter_panel.size) + str(page.frame.size) + str(page.scroll.position) + str(page.scroll.size)


func _place(control: Control, rect: Rect2, scale: float) -> void:
	control.position = rect.position * scale
	control.size = rect.size * scale


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if sort.get_popup().visible:
			sort.get_popup().hide()
		elif category.get_popup().visible:
			category.get_popup().hide()
		else:
			_cancel()
		get_viewport().set_input_as_handled()


func _draft() -> Dictionary:
	return {"q": query.text, "category": category.get_item_text(category.selected), "sort": SORTS[sort.selected],
		"has_image": has_image.button_pressed, "page": 1}


func _restore(values: Dictionary) -> void:
	query.text = values.q
	sort.select(maxi(0, SORTS.find(values.sort)))
	var category_index := -1
	for i in category.item_count:
		if category.get_item_text(i) == values.category:
			category_index = i
			break
	category.select(maxi(0, category_index))
	has_image.button_pressed = values.has_image


func _apply() -> void:
	applied = _draft()
	_dispatch(applied)


func _retry() -> void:
	var retry_query := applied.duplicate(true)
	if phase == "snapshot_expired":
		retry_query.erase("snapshot")
		retry_query.page = 1
	applied = retry_query
	_dispatch(retry_query)


func _cancel() -> void:
	generation += 1
	_restore(last_successful)
	applied = last_successful.duplicate(true)
	phase = "results" if not response.is_empty() else "idle"
	retry.visible = false
	_show_result_status()
	_focus_results.call_deferred()


func _focus_results() -> void:
	for child in cards.get_children():
		if child is PanelContainer and not child.is_queued_for_deletion():
			child.grab_focus()
			return
	scroll.grab_focus()


func _page(delta: int) -> void:
	if response.is_empty():
		return
	var page_query := applied.duplicate(true)
	page_query.page = int(response.page) + delta
	page_query.snapshot = response.corpus.snapshot
	if page_query.page < 1:
		return
	applied = page_query
	_dispatch(page_query)


func _dispatch(search_query: Dictionary) -> void:
	generation += 1
	var current := generation
	requests += 1
	phase = "loading"
	retry.visible = false
	status.text = "Searching RISD… showing previous results"
	var dispatched: Dictionary = Data.search(data_handle, search_query, func(result: Dictionary) -> void: _received(current, result))
	if not dispatched.ok:
		_received(current, dispatched)


func _received(current: int, result: Dictionary) -> void:
	if not page.is_visible_in_tree():
		if pending_result.is_empty() or current > pending_result.generation:
			pending_result = {"generation": current, "result": result}
		return
	if current != generation:
		ignored_completions += 1
		return
	completions += 1
	if not result.ok:
		phase = "snapshot_expired" if result.error.code == SNAPSHOT_EXPIRED else "error"
		status.text = "Snapshot expired · apply again" if phase == "snapshot_expired" else "RISD search unavailable · previous results kept"
		retry.visible = true
		return
	response = result.value
	last_successful = applied.duplicate(true)
	phase = "results"
	_update_categories(response.categories)
	_render_response()


func _resume_pending() -> void:
	if not page.is_visible_in_tree() or pending_result.is_empty():
		return
	var waiting := pending_result
	pending_result = {}
	_received(waiting.generation, waiting.result)


func _update_categories(values: Array) -> void:
	var chosen := category.get_item_text(category.selected)
	category.clear()
	category.add_item("All")
	for value in values:
		if value != "All":
			category.add_item(value)
	for i in category.item_count:
		if category.get_item_text(i) == chosen:
			category.select(i)
			return
	category.select(0)


func _render_response() -> void:
	if response.is_empty():
		status.text = "Search RISD artworks"
		count.text = "No search yet"
		return
	for child in cards.get_children():
		cards.remove_child(child)
		child.queue_free()
	details.visible = false
	selected = ""
	images_loaded = 0
	image_failures = 0
	_show_result_status()
	previous.disabled = response.page <= 1
	next.disabled = response.page * response.page_size >= response.total
	if response.items.is_empty():
		var empty := _label("No works match these filters. Change a filter and press OK.")
		empty.name = "EmptyState"
		empty.add_theme_font_size_override("font_size", maxi(8, roundi(15 * page.factor)))
		cards.add_child(empty)
		return
	for artwork in response.items:
		cards.add_child(_card(artwork))
	_layout_cards()


func _show_result_status() -> void:
	if response.is_empty():
		return
	var corpus: Dictionary = response.corpus
	status.text = "%d result%s · %s · %s %s" % [response.total, "" if response.total == 1 else "s", corpus.coverage,
		corpus.upstream_status, corpus.fetched_at.left(10)]
	count.text = "%d result%s · page %d" % [response.total, "" if response.total == 1 else "s", response.page]


func _card(artwork: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.name = "Card_" + artwork.web_id
	card.focus_mode = Control.FOCUS_ALL
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.add_theme_stylebox_override("panel", _field_style(Color("f6f7f7")))
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 2)
	card.add_child(column)
	var image := TextureRect.new()
	image.name = "Image"
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.size_flags_vertical = Control.SIZE_EXPAND_FILL
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(image)
	var missing := _label("IMAGE UNAVAILABLE")
	missing.name = "ImageUnavailable"
	missing.visible = artwork.image == null
	missing.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	missing.add_theme_color_override("font_color", Color("6e7680"))
	column.add_child(missing)
	if artwork.image != null:
		_load_image(artwork.image, image, missing)
	for text_value in _identity_lines(artwork):
		var line := _label(text_value)
		line.clip_text = true
		line.tooltip_text = text_value
		line.add_theme_font_size_override("font_size", maxi(7, roundi(12 * page.factor)))
		column.add_child(line)
	card.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_select(artwork)
		elif event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ENTER, KEY_SPACE]:
			_select(artwork)
			get_viewport().set_input_as_handled())
	card.set_meta("artwork", artwork)
	return card


func _identity_lines(artwork: Dictionary) -> Array:
	var maker := "Unknown maker" if artwork.makers.is_empty() else ", ".join(artwork.makers)
	return [artwork.title if artwork.title != "" else "Untitled", "%s · %s" % [maker, artwork.dating],
		"RISD Museum · " + artwork.accession, artwork.credit]


func _layout_cards() -> void:
	var columns := 2 if scroll.size.x < 700 else 3
	var width := floorf((scroll.size.x - 8.0 * (columns - 1)) / columns)
	var height := maxf(110, scroll.size.y - 6)
	for child in cards.get_children():
		if child is PanelContainer:
			child.custom_minimum_size = Vector2(width, height)


func _select(artwork: Dictionary) -> void:
	selected = artwork.id
	for child in details.get_children():
		child.queue_free()
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 5)
	details.add_child(column)
	var lines := _identity_lines(artwork)
	lines.push_front("SELECTED")
	lines.append(artwork.category + " · " + artwork.materials)
	lines.append(artwork.source_url)
	for text_value in lines:
		var line := _label(text_value)
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		line.add_theme_font_size_override("font_size", maxi(7, roundi(12 * page.factor)))
		column.add_child(line)
	details.visible = true


func _load_image(manifest: Dictionary, target: TextureRect, unavailable: Label) -> void:
	var image_generation := generation
	var target_id := target.get_instance_id()
	var unavailable_id := unavailable.get_instance_id()
	var completed := func(result: Dictionary) -> void:
		var live_target := instance_from_id(target_id) as TextureRect
		var live_unavailable := instance_from_id(unavailable_id) as Label
		if image_generation != generation or live_target == null or live_unavailable == null:
			return
		if not result.ok:
			live_unavailable.visible = true
			image_failures += 1
			return
		var bytes: PackedByteArray = result.value
		var context := HashingContext.new()
		context.start(HashingContext.HASH_SHA256)
		context.update(bytes)
		if context.finish().hex_encode() != manifest.sha256:
			live_unavailable.visible = true
			image_failures += 1
			return
		var decoded := Image.new()
		var decoded_ok := ERR_INVALID_PARAMETER
		match manifest.mime:
			"image/jpeg": decoded_ok = decoded.load_jpg_from_buffer(bytes)
			"image/png": decoded_ok = decoded.load_png_from_buffer(bytes)
			"image/webp": decoded_ok = decoded.load_webp_from_buffer(bytes)
		if decoded_ok == OK:
			live_target.texture = ImageTexture.create_from_image(decoded)
			images_loaded += 1
		else:
			live_unavailable.visible = true
			image_failures += 1
	var started: Dictionary = image_fetch.call(manifest.sha256, completed)
	if not started.ok:
		completed.call(started)


func state() -> Dictionary:
	var controls := {}
	for control in [query, sort, category, has_image, ok, cancel, retry, previous, next, details]:
		var rect: Rect2 = control.get_global_rect()
		controls[control.name] = rect
	var sort_popup := sort.get_popup()
	var category_popup := category.get_popup()
	var focus_owner := get_viewport().gui_get_focus_owner()
	var sort_items := []
	var category_items := []
	for i in sort.item_count:
		sort_items.append(sort.get_item_text(i))
	for i in category.item_count:
		category_items.append(category.get_item_text(i))
	var items := []
	for card in cards.get_children():
		if card.has_meta("artwork"):
			var image: TextureRect = card.find_child("Image", true, false)
			var unavailable: Label = card.find_child("ImageUnavailable", true, false)
			items.append({"id": card.get_meta("artwork").id, "rect": card.get_global_rect(),
				"has_texture": image != null and image.texture != null,
				"image_unavailable": unavailable != null and unavailable.visible})
	return {"phase": phase, "draft": _draft(), "applied": applied.duplicate(true), "last_successful": last_successful.duplicate(true),
		"requests": requests, "completions": completions, "ignored_completions": ignored_completions, "response": response.duplicate(true),
		"items": items, "selected": selected, "images_loaded": images_loaded, "image_failures": image_failures,
		"controls": controls, "query_focused": query.has_focus(),
		"focus_owner": focus_owner.name if focus_owner != null else "", "sort_items": sort_items, "category_items": category_items,
		"sort_popup": {"visible": sort_popup.visible, "position": sort_popup.position, "size": sort_popup.size},
		"category_popup": {"visible": category_popup.visible, "position": category_popup.position, "size": category_popup.size}}
