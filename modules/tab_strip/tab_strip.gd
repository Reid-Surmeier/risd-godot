## TabStrip implementation. Reach it through interface.gd only.
##
## Every pixel comes from the sliced Muse toolbar in assets/ (layout.json maps them); the
## strip draws nothing by hand. Geometry is in source pixels: the bar is 3135x161.
extends Control

const Errors := preload("res://modules/tab_strip/errors.gd")
const ASSETS := "res://modules/tab_strip/assets/"

signal tab_opened(index: int)
signal tab_settled(index: int)
signal tab_titled(index: int)
signal tab_selected(index: int)

const PRESS_SECONDS := 0.1
const GROW_SECONDS := 0.4
const CONNECTING_SECONDS := 0.95
const STUB_PINK := Color8(247, 239, 244)
const STUB_PRESSED := Color8(228, 218, 226)

var _layout: Dictionary = {}
var _tex: Dictionary = {}
var _tabs: Array = []  # [{node, mid, right, icon, label, label_key, width, page}]
var _stub: TextureButton
var _page_stack: Control
var _active := -1
var _opening := false
var _tween: Tween


static func create(page_stack: Control) -> Dictionary:
	var strip = load("res://modules/tab_strip/tab_strip.gd").new()
	strip._page_stack = page_stack
	var loaded: Dictionary = strip._load_assets()
	if not loaded.ok:
		return loaded
	return Errors.ok(strip)


func _load_assets() -> Dictionary:
	var f := FileAccess.open(ASSETS + "layout.json", FileAccess.READ)
	if f == null:
		return Errors.err(Errors.ASSET_MISSING, "layout.json")
	_layout = JSON.parse_string(f.get_as_text())
	for name in ["bar_background", "stars", "right_cluster", "tab_left", "tab_mid", "tab_right",
			"stub_idle", "stub_pressed", "icon_windows_flag", "icon_page",
			"label_windows_live", "label_connecting", "label_blank_page"]:
		var t = load(ASSETS + name + ".png")
		if t == null:
			return Errors.err(Errors.ASSET_MISSING, name)
		_tex[name] = t
	return Errors.ok()


func _ready() -> void:
	custom_minimum_size = Vector2(_layout.bar_background[2], _layout.bar_height)
	size = custom_minimum_size
	_sprite("bar_background", Vector2.ZERO)
	_sprite("stars", Vector2(_layout.stars[0], 0))
	_sprite("right_cluster", Vector2(_layout.right_cluster[0], 0))
	_stub = TextureButton.new()
	_stub.name = "NewTabStub"
	_stub.texture_normal = _tex.stub_idle
	_stub.texture_pressed = _tex.stub_pressed
	_stub.texture_hover = _tex.stub_idle
	_stub.size = Vector2(_layout.stub.w, _layout.stub.h)
	_stub.pressed.connect(func(): open_new_tab())
	var first := _make_tab("windows_live", _layout.tab.first_tab_x, _layout.tab.full_width)
	add_child(_stub)
	_add_page(first, "windows_live")
	_layout_tabs()
	select_tab(0)


func _sprite(name: String, pos: Vector2) -> TextureRect:
	var r := TextureRect.new()
	r.name = name
	r.texture = _tex[name]
	r.position = pos
	r.stretch_mode = TextureRect.STRETCH_KEEP
	add_child(r)
	return r


func _make_tab(label_key: String, x: float, width: float) -> Dictionary:
	var t: Dictionary = _layout.tab
	var node := Control.new()
	node.name = "Tab%d" % _tabs.size()
	node.position = Vector2(x, t.y)
	node.size = Vector2(width, t.height)
	node.clip_contents = true
	var left := TextureRect.new()
	left.texture = _tex.tab_left
	left.stretch_mode = TextureRect.STRETCH_KEEP
	left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_child(left)
	var mid := TextureRect.new()
	mid.texture = _tex.tab_mid
	mid.stretch_mode = TextureRect.STRETCH_SCALE
	mid.position = Vector2(t.left_w, 0)
	mid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_child(mid)
	var right := TextureRect.new()
	right.texture = _tex.tab_right
	right.stretch_mode = TextureRect.STRETCH_KEEP
	right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_child(right)
	var icon := TextureRect.new()
	icon.stretch_mode = TextureRect.STRETCH_KEEP
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_child(icon)
	var label := TextureRect.new()
	label.stretch_mode = TextureRect.STRETCH_KEEP
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.position = Vector2(_layout.label_windows_live[0], _layout.label_windows_live[1])
	node.add_child(label)
	var index := _tabs.size()
	node.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			select_tab(index))
	add_child(node)
	var tab := {"node": node, "mid": mid, "right": right, "icon": icon, "label": label,
			"label_key": "", "width": width, "page": null}
	_tabs.append(tab)
	_set_label(tab, label_key)
	_set_tab_width(tab, width)
	return tab


func _set_label(tab: Dictionary, key: String) -> void:
	tab.label_key = key
	match key:
		"windows_live":
			tab.icon.texture = _tex.icon_windows_flag
			tab.icon.position = Vector2(_layout.flag[0], _layout.flag[1])
			tab.label.texture = _tex.label_windows_live
		"connecting":
			tab.icon.texture = _tex.icon_page
			tab.icon.position = Vector2(_layout.page_icon[0], _layout.page_icon[1])
			tab.label.texture = _tex.label_connecting
		"blank_page":
			tab.icon.texture = _tex.icon_page
			tab.icon.position = Vector2(_layout.page_icon[0], _layout.page_icon[1])
			tab.label.texture = _tex.label_blank_page


func _set_tab_width(tab: Dictionary, width: float) -> void:
	var t: Dictionary = _layout.tab
	tab.width = width
	tab.node.size.x = width
	tab.mid.size = Vector2(max(0.0, width - t.left_w - t.right_w), t.height)
	tab.right.position = Vector2(width - t.right_w, 0)


## Tabs sit at a fixed pitch while they fit; when the row is full they all shrink (IE7 behaviour).
func _fitted_width(count: int) -> float:
	var t: Dictionary = _layout.tab
	var overlap: float = t.full_width - _layout.tab_pitch
	var room: float = _layout.tabs_max_right - t.first_tab_x - _layout.stub.w + _layout.stub.gap_from_tab_right * -1.0
	var w: float = (room + overlap * (count - 1)) / count
	return min(t.full_width, w)


func _layout_tabs() -> void:
	var w := _fitted_width(_tabs.size())
	var x: float = _layout.tab.first_tab_x
	for tab in _tabs:
		if not _opening or tab != _tabs[-1]:
			_set_tab_width(tab, w)
		tab.node.position.x = x
		x += tab.width - (_layout.tab.full_width - _layout.tab_pitch)
	_layout_stub()


func _layout_stub() -> void:
	var last: Dictionary = _tabs[-1]
	_stub.position = Vector2(last.node.position.x + last.width + _layout.stub.gap_from_tab_right, _layout.stub.y)


func _add_page(tab: Dictionary, key: String) -> void:
	var page := ColorRect.new()
	page.name = "Page%d" % (_tabs.size() - 1)
	page.color = Color.WHITE
	page.set_anchors_preset(Control.PRESET_FULL_RECT)
	var title := TextureRect.new()
	title.texture = _tex.label_blank_page if key != "windows_live" else _tex.label_windows_live
	title.stretch_mode = TextureRect.STRETCH_KEEP
	title.position = Vector2(40, 40)
	page.add_child(title)
	page.visible = false
	_page_stack.add_child(page)
	tab.page = page


# --- interface -------------------------------------------------------------------

func open_new_tab() -> Dictionary:
	if _opening:
		return Errors.err(Errors.OPEN_IN_PROGRESS)
	if _fitted_width(_tabs.size() + 1) < _layout.tab_min_width:
		return Errors.err(Errors.NO_ROOM, "%d tabs" % _tabs.size())
	_opening = true
	var t: Dictionary = _layout.tab
	var start_x: float = _stub.position.x - _layout.stub.gap_from_tab_right - t.full_width + _layout.tab_pitch
	var final_w := _fitted_width(_tabs.size() + 1)
	var tab := _make_tab("connecting", start_x, final_w)
	var index := _tabs.size() - 1
	_add_page(tab, "connecting")
	# the new tab starts exactly where and how the stub was (stub-sized, pressed tint, contents
	# hidden) and stands in for it while pressed; the real stub reappears riding on its right edge
	_layout_tabs()
	_grow(tab, final_w, 0.0)
	tab.node.modulate = STUB_PRESSED
	_stub.visible = false
	emit_signal("tab_opened", index)
	_tween = create_tween()
	_tween.tween_interval(PRESS_SECONDS)
	_tween.tween_callback(func(): _stub.visible = true)
	_tween.tween_method(func(s: float): _grow(tab, final_w, s), 0.0, 1.0, GROW_SECONDS) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_callback(func():
		_opening = false
		_layout_tabs()
		select_tab(index)
		emit_signal("tab_settled", index))
	_tween.tween_interval(CONNECTING_SECONDS)
	_tween.tween_callback(func():
		_set_label(tab, "blank_page")
		emit_signal("tab_titled", index))
	return Errors.ok(index)


func _grow(tab: Dictionary, final_w: float, s: float) -> void:
	var t: Dictionary = _layout.tab
	var sy: float = lerp(_layout.stub.h / float(t.height), 1.0, s)
	var w: float = lerp(float(_layout.stub.w), final_w, s)
	tab.node.scale = Vector2(1.0, sy)
	_set_tab_width(tab, w)
	tab.node.position.y = lerp(float(_layout.stub.y), float(t.y), s)
	tab.node.modulate = STUB_PINK.lerp(Color.WHITE, s)
	var a: float = clamp((s - 0.5) / 0.5, 0.0, 1.0)
	tab.icon.modulate.a = a
	tab.label.modulate.a = a
	_layout_stub()


func select_tab(index: int) -> Dictionary:
	if index < 0 or index >= _tabs.size():
		return Errors.err(Errors.INDEX_OUT_OF_RANGE, str(index))
	_active = index
	for i in _tabs.size():
		_tabs[i].page.visible = (i == index)
	emit_signal("tab_selected", index)
	return Errors.ok(index)


func state() -> Dictionary:
	var tabs := []
	for tab in _tabs:
		tabs.append({"label": tab.label_key, "rect": Rect2(tab.node.position, tab.node.size * tab.node.scale),
				"page_visible": tab.page.visible})
	return Errors.ok({"count": _tabs.size(), "active": _active, "tabs": tabs, "opening": _opening})


func stub_rect() -> Rect2:
	return Rect2(_stub.position, _stub.size)
