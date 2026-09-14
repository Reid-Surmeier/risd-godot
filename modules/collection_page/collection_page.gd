## The Collection page Tenant: built by interface.gd's create; everything in here is free to change.
## Sliced pixels (header, Info box, object cut-outs) come from the files PROVENANCE.md lists and
## are shown at 2x with the project's nearest filter; everything else is a white surface with text.
extends Control

signal card_selected(record: Dictionary)

const Errors := preload("res://modules/collection_page/errors.gd")
const ASSETS := "res://modules/collection_page/assets/"
const ICONS := "res://assets/icons/set/"  # the owner's stills (ticket #27); not a module, no seam
const REQUIRED: Array[String] = ["id", "title", "maker", "department", "medium", "year"]
const FLAGS: Array[String] = ["has_image", "has_video", "has_3d"]
const SORT_VALUES: Array[String] = ["none", "newest", "oldest"]
const MEDIUM_ALL := "All"
const MARGIN := 24.0
const SLICE_SCALE := 2.0  # the reference window is 859 px wide; the page is 1440..1920
const CARD_W := 280.0
const THUMB_H := 200.0
const CARD_H := 296.0
const GAP := 16.0

var key := ""
var _records: Array = []
var _mediums: Array = []
var _filter := {"medium": MEDIUM_ALL, "sort": "none", "has_image": false}
var _font: Font
var _tex: Dictionary = {}
var _header: TextureRect
var _info: TextureRect
var _row: HBoxContainer
var _controls: Dictionary = {}
var _count: Label
var _scroll: ScrollContainer
var _grid: HFlowContainer
var _cards: Array = []


static func create(deps: Dictionary) -> Dictionary:
	var page = load("res://modules/collection_page/collection_page.gd").new()
	page.key = deps.get("key", "")
	page.name = "CollectionPage"
	var loaded: Dictionary = page._load_records(deps.get("data_path", "res://modules/collection_page/data/collection.json"))
	if not loaded.ok:
		return loaded
	var assets: Dictionary = page._load_assets()
	if not assets.ok:
		return assets
	page._build()
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return Errors.ok(page)


func _load_records(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return Errors.err(Errors.DATA_MISSING, path)
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (parsed is Dictionary) or not (parsed.get("records") is Array):
		return Errors.err(Errors.DATA_INVALID, "%s: expected { records: [...] }" % path)
	var mediums := {}
	for r in parsed.records:
		if not (r is Dictionary):
			return Errors.err(Errors.DATA_INVALID, "a record is not an object")
		for k in REQUIRED:
			if not r.has(k):
				return Errors.err(Errors.DATA_INVALID, "record %s has no %s" % [str(r.get("id", "?")), k])
		for f in FLAGS:
			if not (r.get(f) is bool):
				return Errors.err(Errors.DATA_INVALID, "record %s: %s is not a bool" % [r.id, f])
		if not (r.year is float or r.year is int):
			return Errors.err(Errors.DATA_INVALID, "record %s: year is not a number" % r.id)
		mediums[r.medium] = true
	_records = parsed.records
	_mediums = mediums.keys()
	_mediums.sort()
	return Errors.ok(_records.size())


func _load_assets() -> Dictionary:
	var font_path := ASSETS + "LiberationSans-Regular.ttf"
	if not ResourceLoader.exists(font_path):
		return Errors.err(Errors.ASSET_MISSING, font_path)
	_font = load(font_path)
	var files: Array = ["header.png", "info_box.png"]
	for r in _records:
		if r.get("thumbnail", "") != "":
			files.append(r.thumbnail)
	for f in files:
		if not ResourceLoader.exists(ASSETS + f):
			return Errors.err(Errors.ASSET_MISSING, ASSETS + f)
		_tex[f] = load(ASSETS + f)
	for icon in ["MED-01-has-video.png", "MED-06-point-cloud.png"]:
		_tex[icon] = load(ICONS + icon) if ResourceLoader.exists(ICONS + icon) else null
	return Errors.ok()


func _label(text: String, px: int) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", px)
	l.add_theme_color_override("font_color", Color.BLACK)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _sprite(file: String) -> TextureRect:
	var t := TextureRect.new()
	t.texture = _tex[file]
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_SCALE
	t.size = _tex[file].get_size() * SLICE_SCALE
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(t)
	return t


func _control(name: String, on_click: Callable) -> Label:
	var l := _label("", 22)
	l.name = name
	l.mouse_filter = Control.MOUSE_FILTER_STOP
	l.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	l.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			on_click.call())
	_row.add_child(l)
	_controls[name] = l
	return l


func _build() -> void:
	var ground := ColorRect.new()
	ground.color = Color.WHITE
	ground.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ground.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ground)
	_header = _sprite("header.png")
	_row = HBoxContainer.new()
	_row.add_theme_constant_override("separation", 28)
	add_child(_row)
	_control("medium", func() -> void:
		var all: Array = [MEDIUM_ALL] + _mediums
		set_filter({"medium": all[(all.find(_filter.medium) + 1) % all.size()]}))
	_control("sort", func() -> void:
		set_filter({"sort": SORT_VALUES[(SORT_VALUES.find(_filter.sort) + 1) % SORT_VALUES.size()]}))
	_control("has_image", func() -> void: set_filter({"has_image": not _filter.has_image}))
	_count = _label("", 22)
	_row.add_child(_count)
	_scroll = ScrollContainer.new()
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(_scroll)
	_grid = HFlowContainer.new()
	_grid.add_theme_constant_override("h_separation", int(GAP))
	_grid.add_theme_constant_override("v_separation", int(GAP))
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(_grid)
	_info = _sprite("info_box.png")
	resized.connect(_layout)
	_layout()
	_refresh()


func _layout() -> void:
	_header.position = Vector2(MARGIN, 16)
	_row.position = Vector2(MARGIN, _header.position.y + _header.size.y + 12)
	_row.size = Vector2(size.x - 2 * MARGIN, 32)
	_info.position = Vector2(MARGIN, size.y - _info.size.y - 16)
	_scroll.position = Vector2(MARGIN, _row.position.y + _row.size.y + 16)
	_scroll.size = Vector2(size.x - 2 * MARGIN, max(0.0, _info.position.y - 16 - _scroll.position.y))


func _make_card(record: Dictionary) -> Control:
	var card := Control.new()
	card.custom_minimum_size = Vector2(CARD_W, CARD_H)
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			card_selected.emit(record))
	if record.get("thumbnail", "") != "":
		var thumb := TextureRect.new()
		thumb.texture = _tex[record.thumbnail]
		thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		thumb.size = Vector2(CARD_W, THUMB_H)
		thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(thumb)
	var badge: String = "MED-01-has-video.png" if record.has_video else ("MED-06-point-cloud.png" if record.has_3d else "")
	if badge != "" and _tex[badge] != null:
		var b := TextureRect.new()
		b.texture = _tex[badge]
		b.position = Vector2(CARD_W - 64, 0)
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(b)
	_line(card, record.title, 17, THUMB_H + 6, 46, true)
	_line(card, "%s, %s" % [record.maker, _year_text(record.year)], 14, THUMB_H + 54, 20)
	var dept := _line(card, "%s / %s" % [record.department, record.medium], 14, THUMB_H + 74, 20)
	dept.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35))
	return card


## One clipped text line on a card; clip and wrap are set before the size so the Label's minimum
## size does not grow to the full text width.
func _line(card: Control, text: String, px: int, y: float, h: float, wrap: bool = false) -> Label:
	var l := _label(text, px)
	l.clip_text = true
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.max_lines_visible = 2
	l.position = Vector2(0, y)
	l.size = Vector2(CARD_W, h)
	card.add_child(l)
	return l


static func _year_text(year) -> String:
	return "%d BCE" % int(-year) if year < 0 else str(int(year))


func _shown() -> Array:
	var shown: Array = _records.filter(func(r: Dictionary) -> bool:
		return (_filter.medium == MEDIUM_ALL or r.medium == _filter.medium) and (not _filter.has_image or r.has_image))
	if _filter.sort != "none":
		var newest: bool = _filter.sort == "newest"
		shown.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			if a.year == b.year:
				return a.id < b.id
			return a.year > b.year if newest else a.year < b.year)
	return shown


func _refresh() -> void:
	for c in _grid.get_children():
		_grid.remove_child(c)
		c.queue_free()
	_cards = []
	for r in _shown():
		var node := _make_card(r)
		_grid.add_child(node)
		_cards.append({"id": r.id, "title": r.title, "node": node})
	_count.text = "%d of %d objects" % [_cards.size(), _records.size()]
	_controls.medium.text = "[ Medium: %s ]" % _filter.medium
	_controls.sort.text = "[ Sort by date: %s ]" % _filter.sort
	_controls.has_image.text = "[ Has image: %s ]" % ("on" if _filter.has_image else "off")


func set_filter(filter: Dictionary) -> Dictionary:
	var next: Dictionary = _filter.duplicate()
	for k in filter:
		var v = filter[k]
		match k:
			"medium":
				if not (v is String) or (v != MEDIUM_ALL and not _mediums.has(v)):
					return Errors.err(Errors.FILTER_INVALID, "medium %s" % str(v))
			"sort":
				if not (v is String) or not SORT_VALUES.has(v):
					return Errors.err(Errors.FILTER_INVALID, "sort %s" % str(v))
			"has_image":
				if not (v is bool):
					return Errors.err(Errors.FILTER_INVALID, "has_image must be a bool")
			_:
				return Errors.err(Errors.FILTER_INVALID, "unknown key %s" % str(k))
		next[k] = v
	_filter = next
	_refresh()
	return state()


func _local_rect(node: Control) -> Rect2:
	return Rect2(get_global_transform().affine_inverse() * node.global_position, node.size)


func state() -> Dictionary:
	var cards := []
	for c in _cards:
		cards.append({"id": c.id, "title": c.title, "rect": _local_rect(c.node)})
	var controls := {}
	for n in _controls:
		controls[n] = _local_rect(_controls[n])
	return Errors.ok({"total": _records.size(), "count": _cards.size(), "filter": _filter.duplicate(),
			"mediums": _mediums.duplicate(), "cards": cards, "controls": controls, "size": size})
