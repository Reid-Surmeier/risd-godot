## Native selected A layout, issue #164. Snapshot assets remain owned by this Tenant.
extends Control

const Errors := preload("res://modules/playground_page/errors.gd")
const Data := preload("res://modules/collection_data/interface.gd")
const CATALOG := "res://modules/playground_page/assets/square/catalog.json"
const PAGES := {"explore": "Explore", "all": "All Blocks", "channels": "Channels", \
	"search": "Search"}
const INK := Color("232323")
const MUTED := Color("686868")
const GREEN := Color("00854c")

var key := "playground"
var page := "explore"
var query := ""
var material_filter := ""
var sort_order := 0
var images_only := true
var saved_only := false
var channel := ""
var saved_ids: Array = []
var arena: Array = []
var works: Array = []
var results: Array = []
var data_handle: Variant
var ticks := 0
var inputs := 0
var canvas := Control.new()
var content := Control.new()
var scroll := ScrollContainer.new()
var title := Label.new()
var navigation := HBoxContainer.new()
var detail: Control
var status := ""
var compact := false
var content_width := 1008.0


static func create(deps: Dictionary) -> Dictionary:
	if not FileAccess.file_exists(CATALOG):
		return Errors.err(Errors.ASSET_MISSING, CATALOG)
	var catalog: Variant = JSON.parse_string(FileAccess.get_file_as_string(CATALOG))
	if not catalog is Dictionary or not catalog.get("arena") is Array or not catalog.get("works") \
		is Array:
		return Errors.err(Errors.ASSET_MISSING, CATALOG)
	for record in catalog.arena + catalog.works:
		if not ResourceLoader.exists(record.texture):
			return Errors.err(Errors.ASSET_MISSING, record.texture)
	var tenant = load("res://modules/playground_page/square_pages.gd").new()
	tenant.key = deps.get("key", "playground")
	tenant.data_handle = deps.collection_data
	tenant.arena = catalog.arena
	tenant.works = catalog.works
	tenant.arena.sort_custom(func(a, b): return a.connected_at > b.connected_at)
	tenant.name = "PlaygroundPage"
	tenant.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return Errors.ok(tenant)


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var theme := Theme.new()
	theme.default_font_size = 16
	theme.default_font = load( \
		"res://modules/playground_page/assets/fonts/LiberationSans-Regular.ttf").duplicate()
	theme.default_font.fallbacks = [load( \
		"res://modules/playground_page/assets/fonts/WenQuanYi-Hangul.ttf")]
	theme.set_color("font_color", "Label", INK)
	theme.set_color("font_color", "LineEdit", INK)
	theme.set_color("font_placeholder_color", "LineEdit", MUTED)
	theme.set_stylebox("normal", "LineEdit", _box(Color.WHITE, Color("999999"), 12))
	theme.set_stylebox("focus", "LineEdit", _box(Color.WHITE, GREEN, 12))
	self.theme = theme
	var background := ColorRect.new()
	background.color = Color.WHITE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	add_child(canvas)
	canvas.add_child(title)
	title.position = Vector2(36, 28)
	title.add_theme_font_size_override("font_size", 31)
	var motto := _label("Collect, connect, come back.", 13, MUTED)
	motto.name = "Motto"
	motto.position = Vector2(870, 43)
	canvas.add_child(motto)
	canvas.add_child(navigation)
	navigation.position = Vector2(36, 87)
	navigation.add_theme_constant_override("separation", 30)
	for id in PAGES:
		var button := _button(PAGES[id], func(): show_page(id), 16, true)
		button.name = "Page_" + id
		button.custom_minimum_size.y = 34
		navigation.add_child(button)
	var line := ColorRect.new()
	line.name = "Divider"
	line.color = Color("dddddd")
	line.position = Vector2(36, 144)
	line.size = Vector2(1008, 1)
	canvas.add_child(line)
	canvas.add_child(scroll)
	scroll.position = Vector2(36, 172)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.add_child(content)
	content.custom_minimum_size.x = 1008
	resized.connect(_layout)
	visibility_changed.connect(_refresh_saved)
	_load_public_saves()
	_layout()
	_render()
	_refresh_saved()


func _process(_delta: float) -> void:
	ticks += 1


func _input(_event: InputEvent) -> void:
	inputs += 1


func _layout() -> void:
	var was_compact := compact
	compact = size.x < 800
	var logical_width := 540.0 if compact else 1080.0
	var factor := size.x / logical_width
	canvas.scale = Vector2.ONE * factor
	canvas.size = Vector2(logical_width, size.y / maxf(factor, 0.01))
	content_width = logical_width - 72
	content.custom_minimum_size.x = content_width
	scroll.size = Vector2(content_width + 14, maxf(50, canvas.size.y - 186))
	canvas.get_node("Motto").visible = not compact
	canvas.get_node("Divider").size.x = content_width
	if is_instance_valid(detail):
		detail.queue_free()
	if was_compact != compact:
		_render()


func show_page(next: String) -> Dictionary:
	if next == "all_blocks":
		next = "all"
	if not PAGES.has(next):
		return Errors.err(Errors.PAGE_UNKNOWN, next)
	page = next
	channel = ""
	if is_node_ready():
		_render()
	return Errors.ok(page)


func state() -> Dictionary:
	return Errors.ok({"key": key, "page": page, "query": query, "channel": channel,
		"results": results.map(func(record): return record.id), "saved_ids": saved_ids.duplicate(),
		"connections": arena.map(func(record): return record.connected_at), "size": size,
		"ticks": ticks, "inputs": inputs, "storage_status": status})


func _box(fill: Color, border: Color, padding: int = 0) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(1)
	box.content_margin_left = padding
	box.content_margin_right = padding
	box.content_margin_top = padding / 2.0
	box.content_margin_bottom = padding / 2.0
	return box


func _button(text: String, action: Callable, font_size: int = 14, flat: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", GREEN)
	button.add_theme_color_override("font_pressed_color", GREEN)
	button.add_theme_stylebox_override("normal", StyleBoxEmpty.new() if flat else _box(Color.WHITE, \
		Color("d1d1d1"), 12))
	button.add_theme_stylebox_override("hover", StyleBoxEmpty.new() if flat else _box(Color.WHITE, \
		GREEN, 12))
	button.add_theme_stylebox_override("pressed", _box(Color("eeeeee"), GREEN, 12))
	button.add_theme_stylebox_override("focus", _box(Color(0, 0, 0, 0), GREEN, 0))
	button.pressed.connect(action)
	return button


func _label(text: String, font_size: int = 14, color: Color = INK) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _put(node: Control, rect: Rect2, parent: Control = content) -> void:
	parent.add_child(node)
	node.position = rect.position
	node.size = rect.size


func _render(preserve_scroll: bool = false) -> void:
	var previous_scroll := scroll.scroll_vertical
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()
	title.text = "Playground / " + PAGES[page]
	for button in navigation.get_children():
		var selected: bool = button.name == "Page_" + page
		var box := _box(Color.WHITE, INK, 0)
		box.set_border_width_all(0)
		box.border_width_bottom = 2 if selected else 0
		button.add_theme_stylebox_override("normal", box)
		button.add_theme_stylebox_override("hover", box)
		button.add_theme_stylebox_override("pressed", box)
		button.add_theme_color_override("font_color", INK if selected else MUTED)
	scroll.set_deferred("scroll_vertical", previous_scroll if preserve_scroll else 0)
	if page == "channels" and channel.is_empty():
		_channels()
		return
	results = _filtered()
	var heading: String = {"explore": "Recent connections", "all": "All Blocks", "channels": channel,
		"search": "Search the RISD collection"}[page]
	_put(_label(heading, 24), Rect2(0, 0, content_width, 34))
	var count := _label("%d %s%s" % [results.size(), "works" if page == "search" else "blocks",
		" · newest connection first" if page == "explore" else ""], 13, MUTED)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_put(count, Rect2(0, 34, content_width, 26) if compact else Rect2(705, 2, 303, 30))
	if not status.is_empty() and status != "available":
		count.text = "Save unavailable — try again"
		count.add_theme_color_override("font_color", Color("aa2222"))
	var top := 74.0 if compact else 52.0
	if page == "search":
		top = _search_controls()
	elif page == "all":
		_put(_button("Saved on this browser" if saved_only else "Show saved on this browser", func():
			saved_only = not saved_only
			_render()), Rect2(0, 68 if compact else 52, 225, 39))
		_put(_label("Public Are.na blocks + RISD works", 13, MUTED), Rect2(0, 112, content_width, \
			30) if compact else Rect2(240, 56, 500, 30))
		top = 152 if compact else 111
	elif not channel.is_empty():
		_put(_button("Back to Channels", func(): show_page("channels")), Rect2(0, \
			68 if compact else 46, 130, 32))
		top = 114 if compact else 98
	var height := 397.0 if page == "explore" else 346.0
	var columns := 1 if compact else 3
	for i in results.size():
		_card(results[i], Vector2((i % columns) * 345, top + (i / columns) * height))
	if results.is_empty():
		var message := \
			"No works match this search. Try an artist, object, title, or clear the filters." if page == \
			"search" else "Nothing here yet. Save a block from Explore or Search to collect it here."
		_put(_label(message, 16, MUTED), Rect2(0, top + 30, content_width, 70))
	content.custom_minimum_size.y = top + maxf(100, \
		ceil(float(results.size()) / columns) * height) + 24


func _filtered() -> Array:
	var list: Array = arena.duplicate() if page == "explore" else works.duplicate() if page == \
		"search" else arena + works
	if not channel.is_empty():
		list = _groups()[channel]
	if page == "all" and saved_only:
		list = list.filter(func(record): return str(record.id) in saved_ids)
	if page == "search":
		var terms := query.to_lower().split(" ", false)
		list = list.filter(func(record):
			var haystack: String = (record.title + " " + " ".join(record.makers) + " " + record.materials \
				+ " " + record.accession).to_lower()
			for term in terms:
				if not haystack.contains(term):
					return false
			return (material_filter.is_empty() or record.materials == material_filter) and (not \
				images_only or not record.texture.is_empty()))
		list.sort_custom(func(a, b):
			if sort_order == 0:
				return a.title.naturalnocasecmp_to(b.title) < 0
			return a.year_from < b.year_from if sort_order == 1 else a.year_from > b.year_from)
	return list


func _card(record: Dictionary, position: Vector2) -> void:
	var card := Control.new()
	var width := content_width if compact else 318.0
	_put(card, Rect2(position, Vector2(width, 375)))
	var top := 0.0
	if page == "explore":
		var date := Time.get_datetime_dict_from_datetime_string(record.connected_at, false)
		var connection := "%s connected\nto %s · Sep %d, %02d:%02d UTC" % [record.connector, \
			record.channel, date.day, date.hour, date.minute]
		_put(_label(connection, 12, MUTED), Rect2(0, 0, width, 42), card)
		top = 51
	var art := _button("", func(): _detail(record))
	art.tooltip_text = "Open " + record.title
	art.add_theme_stylebox_override("normal", _box(Color("fafafa"), Color("e5e5e5")))
	_put(art, Rect2(0, top, width, 205), card)
	var image := _image(record)
	_put(image, Rect2(15, 15, width - 30, 175), art)
	if record.source_width < 200:
		image.size.y = 130
		_put(_label("Small source preview", 12, MUTED), Rect2(85, 159, 180, 25), art)
	var caption := _label(record.title)
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_put(caption, Rect2(0, top + 216, width, 42), card)
	caption.max_lines_visible = 2
	caption.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	var byline_top := top + 262
	var byline: String = ", ".join(record.makers) + " · " + str(int(record.year_from)) if \
		record.has("makers") else record.type
	if record.source_width < 200:
		byline += " · Low-res source"
	var by := _label(byline, 13, MUTED)
	by.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_put(by, Rect2(0, byline_top, width, 22), card)
	var save := _button("Saved here" if str(record.id) in saved_ids else "+ Save here", \
		func(): _save(record), 12)
	save.name = "Save_" + str(record.id).replace(":", "_")
	_put(save, Rect2(0, byline_top + 30, 101, 28), card)


func _image(record: Dictionary) -> TextureRect:
	var image := TextureRect.new()
	image.texture = load(record.texture)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED if record.source_width < 200 else \
		TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return image


func _search_controls() -> float:
	var field := LineEdit.new()
	field.name = "SearchQuery"
	field.placeholder_text = "Search artists, objects, and titles"
	field.text = query
	field.max_length = 256
	field.text_changed.connect(func(text): query = text)
	var search := func(_text = ""):
		_render()
	field.text_submitted.connect(search)
	_put(field, Rect2(0, 68 if compact else 52, content_width if compact else 742, 46))
	field.grab_focus.call_deferred()
	_put(_button("Search", search, 16), Rect2(0, 122, 80, 40) if compact else Rect2(756, 55, 80, 40))
	_put(_button("Random object", func(): _detail(works.pick_random()), 16), Rect2(96, 122, 158, \
		40) if compact else Rect2(850, 55, 158, 40))
	var materials := ["All materials"]
	for record in works:
		if record.materials not in materials:
			materials.append(record.materials)
	_put(_choice(materials, 0 if material_filter.is_empty() else materials.find(material_filter), \
		func(index):
		material_filter = "" if index == 0 else materials[index]
		_render()), Rect2(0, 172, content_width, 40) if compact else Rect2(0, 112, 430, 40))
	_put(_choice(["Title A–Z", "Oldest first", "Newest first"], sort_order, func(index):
		sort_order = index
		_render()), Rect2(0, 222, 147, 40) if compact else Rect2(444, 112, 147, 40))
	_put(_button("Images: " + ("yes" if images_only else "any"), func():
		images_only = not images_only
		_render(), 14, true), Rect2(162, 222, 124, 40) if compact else Rect2(606, 112, 124, 40))
	_put(_button("Clear", func():
		query = ""
		material_filter = ""
		sort_order = 0
		images_only = true
		_render(), 16), Rect2(304, 222, 69, 40) if compact else Rect2(744, 112, 69, 40))
	var note := _label( \
		"Search sample: 25 verified public-domain paintings. Museum records open from each work.", 13, \
		MUTED)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_put(note, Rect2(0, 274 if compact else 168, content_width, 42))
	return 330 if compact else 207


func _choice(items: Array, selected: int, action: Callable) -> OptionButton:
	var choice := OptionButton.new()
	choice.fit_to_longest_item = false
	for item in items:
		choice.add_item(item)
	choice.select(selected)
	choice.add_theme_color_override("font_color", INK)
	choice.add_theme_color_override("font_hover_color", GREEN)
	choice.add_theme_stylebox_override("normal", _box(Color.WHITE, Color("cccccc"), 12))
	choice.add_theme_stylebox_override("hover", _box(Color.WHITE, GREEN, 12))
	choice.add_theme_stylebox_override("pressed", _box(Color("eeeeee"), GREEN, 12))
	choice.add_theme_stylebox_override("focus", _box(Color(0, 0, 0, 0), GREEN))
	choice.get_popup().add_theme_stylebox_override("panel", _box(Color.WHITE, Color("cccccc"), 8))
	choice.get_popup().add_theme_color_override("font_color", INK)
	choice.get_popup().add_theme_color_override("font_hover_color", GREEN)
	choice.get_popup().add_theme_stylebox_override("hover", _box(Color("eeeeee"), Color("eeeeee")))
	choice.item_selected.connect(action)
	return choice


func _groups() -> Dictionary:
	var landscape := RegEx.create_from_string( \
		"(?i)landscape|tenby|sea|coast|river|sunset|venice|land|water")
	var figures := RegEx.create_from_string("(?i)portrait|woman|girl|man|lady|boy")
	return {"Public connections": arena,
		"Land & water": works.filter(func(record): return landscape.search(record.title) != null),
		"Faces & figures": works.filter(func(record): return figures.search(record.title) != null),
		"Saved on this browser": (arena + works).filter(func(record): return str(record.id) in saved_ids)}


func _channels() -> void:
	results = []
	_put(_label("Channels", 24), Rect2(0, 0, content_width, 34))
	_put(_label("4 fixed groups", 13, MUTED), Rect2(content_width - 100, 0, 100, 34))
	var groups := _groups()
	var index := 0
	var columns := 1 if compact else 3
	var width := content_width if compact else 318.0
	for group in groups:
		var list: Array = groups[group]
		var button := _button("", func():
			channel = group
			_render())
		button.name = "Channel_" + str(index)
		button.add_theme_stylebox_override("normal", _box(Color.WHITE, GREEN))
		_put(button, Rect2((index % columns) * 345, 58 + (index / columns) * 264, width, 236))
		var heading := _label(group, 22, GREEN)
		heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_put(heading, Rect2(8, 20, width - 16, 36), button)
		for i in mini(3, list.size()):
			_put(_image(list[i]), Rect2((width - 274) / 2 + i * 94, 70, 86, 88), button)
		var source := "Source channel by Rin Lee" if index == 0 else "Collected by you · this browser" \
			if index == 3 else "RISD Museum works"
		var meta := _label(source + "\n%d blocks · %s" % [list.size(), \
			"browser-local" if index == 3 else "snapshot Sep 2026"], 12, MUTED)
		meta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_put(meta, Rect2(8, 178, width - 16, 45), button)
		index += 1
	content.custom_minimum_size.y = 58 + ceil(4.0 / columns) * 264


func _detail(record: Dictionary) -> void:
	if is_instance_valid(detail):
		detail.queue_free()
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.45)
	detail = shade
	canvas.add_child(detail)
	detail.size = canvas.size
	var panel := Panel.new()
	panel.add_theme_stylebox_override("panel", _box(Color.WHITE, Color("999999")))
	var width := canvas.size.x - 40 if compact else 820.0
	_put(panel, Rect2(20 if compact else 130, 30, width, minf(810, canvas.size.y - 60)), detail)
	_put(_button("Close ×", func(): detail.queue_free()), Rect2(width - 130, 18, 105, 36), panel)
	var heading := _label(record.title, 23)
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_put(heading, Rect2(26, 60, width - 52, 60), panel)
	_put(_image(record), Rect2(26, 128, width - 52, maxf(40, panel.size.y - 300)), panel)
	var byline: String = ", ".join(record.makers) if record.has("makers") else record.connector
	_put(_label(byline, 16), Rect2(26, panel.size.y - 146, width - 52, 28), panel)
	_put(_label(record.get("materials", "Public Are.na block"), 14, MUTED), Rect2(26, \
		panel.size.y - 113, width - 52, 26), panel)
	var url: String = record.get("source_url", record.get("source", ""))
	_put(_button("Open museum record" if record.has("makers") else "Open Are.na block", \
		func(): OS.shell_open(url), 16), Rect2(26, panel.size.y - 65, 240, 38), panel)


func _load_public_saves() -> void:
	var config := ConfigFile.new()
	if config.load("user://playground-blocks.cfg") == OK:
		var stored: Variant = config.get_value("saves", "ids", [])
		if stored is Array:
			for id in stored:
				if id is String:
					saved_ids.append(id)


func _refresh_saved() -> void:
	if not is_node_ready() or not is_visible_in_tree():
		return
	var dispatched := Data.saved(data_handle, func(result: Dictionary):
		if result.ok:
			for item in result.value.items:
				if item.artwork.id not in saved_ids:
					saved_ids.append(item.artwork.id)
			status = "available"
		else:
			status = result.error.code
		_render(true))
	if not dispatched.ok:
		status = dispatched.error.code


func _save(record: Dictionary) -> void:
	if str(record.id) in saved_ids:
		return
	if record.has("makers"):
		var artwork := record.duplicate(true)
		artwork.erase("texture")
		artwork.erase("source_width")
		var dispatched := Data.save(data_handle, artwork, func(result: Dictionary):
			if result.ok:
				saved_ids.append(str(record.id))
				status = "available"
			else:
				status = result.error.code
			_render(true))
		if not dispatched.ok:
			status = dispatched.error.code
			_render(true)
	else:
		var config := ConfigFile.new()
		var public_ids := saved_ids.filter(func(id): return not id.begins_with("risd:"))
		public_ids.append(str(record.id))
		config.set_value("saves", "ids", public_ids)
		if config.save("user://playground-blocks.cfg") == OK:
			saved_ids.append(str(record.id))
			status = "available"
		else:
			status = "Unable to save on this device"
		_render(true)
