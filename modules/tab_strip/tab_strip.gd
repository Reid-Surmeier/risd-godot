## TabStrip implementation. Reach it through interface.gd only.
##
## Every pixel comes from the sliced Muse toolbar in assets/ (layout.json maps them); the
## strip draws nothing by hand. Geometry is in source pixels (bar height 161). The bar is
## as wide as the caller makes it: the stars stay left, the icon cluster stays right, the
## pinstripes fill the middle, and tabs live between them.
extends Control

const Errors := preload("res://modules/tab_strip/errors.gd")
const ASSETS := "res://modules/tab_strip/assets/"

signal tab_opened(index: int)
signal tab_settled(index: int)
signal tab_titled(index: int)
signal tab_selected(index: int)
signal tab_closed(index: int)

const PRESS_SECONDS := 0.1
const GROW_SECONDS := 0.4
const CONNECTING_SECONDS := 0.95
const CLOSE_SECONDS := 0.3
const SLIDE_SECONDS := 0.2
const STUB_PINK := Color8(247, 239, 244)
const STUB_PRESSED := Color8(228, 218, 226)

var _layout: Dictionary = {}
var _tex: Dictionary = {}
var _tabs: Array = []  # [{node, mid, right, icon, clip, label, dots, close, label_key, width, page}]
var _stub: TextureButton
var _right_cluster: TextureRect
var _stripes: TextureRect
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
	for name in ["bar_stripes", "stars", "right_cluster", "tab_left", "tab_mid", "tab_right",
			"stub_idle", "stub_pressed", "icon_windows_flag", "icon_page", "icon_close",
			"icon_close_pressed", "label_windows_live", "label_connecting", "label_blank_page",
			"label_dots"]:
		var t = load(ASSETS + name + ".png")
		if t == null:
			return Errors.err(Errors.ASSET_MISSING, name)
		_tex[name] = t
	return Errors.ok()


func _ready() -> void:
	var w: float = max(size.x, _layout.bar_background[2])
	custom_minimum_size = Vector2(0, _layout.bar_height)
	_stripes = TextureRect.new()
	_stripes.name = "bar_stripes"
	_stripes.texture = _tex.bar_stripes
	_stripes.stretch_mode = TextureRect.STRETCH_TILE
	_stripes.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stripes)
	_sprite("stars", Vector2.ZERO)
	_right_cluster = _sprite("right_cluster", Vector2.ZERO)
	_stub = TextureButton.new()
	_stub.name = "NewTabStub"
	_stub.texture_normal = _tex.stub_idle
	_stub.texture_pressed = _tex.stub_pressed
	_stub.texture_hover = _tex.stub_idle
	_stub.size = Vector2(_layout.stub.w, _layout.stub.h)
	_stub.pressed.connect(func(): open_new_tab())
	add_child(_stub)  # behind every tab, like the source stub
	var first := _make_tab("windows_live", _layout.tab.first_tab_x, _layout.tab.full_width)
	_add_page(first, "windows_live")
	set_bar_width(w)
	select_tab(0)
	resized.connect(func(): set_bar_width(size.x))


## The bar spans `width` source pixels: right cluster pinned at the right, stripes in between.
func set_bar_width(width: float) -> void:
	if _stripes == null:
		return
	width = max(width, _layout.stars[2] + _layout.right_cluster_w)
	size = Vector2(width, _layout.bar_height)
	_stripes.size = Vector2(width, _layout.bar_height)
	_right_cluster.position = Vector2(width - _layout.right_cluster_w, 0)
	_layout_tabs()


func _tabs_max_right() -> float:
	return _right_cluster.position.x + _layout.right_cluster_icons_offset - 40


func _sprite(name: String, pos: Vector2) -> TextureRect:
	var r := TextureRect.new()
	r.name = name
	r.texture = _tex[name]
	r.position = pos
	r.stretch_mode = TextureRect.STRETCH_KEEP
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(r)
	return r


func _make_tab(label_key: String, x: float, width: float) -> Dictionary:
	var t: Dictionary = _layout.tab
	var node := Control.new()
	node.name = "Tab%d" % _tabs.size()
	node.position = Vector2(x, t.y)
	node.size = Vector2(width, t.height)
	node.clip_contents = true
	var left := _piece(node, _tex.tab_left, TextureRect.STRETCH_KEEP)
	var mid := _piece(node, _tex.tab_mid, TextureRect.STRETCH_SCALE)
	mid.position = Vector2(t.left_w, 0)
	var right := _piece(node, _tex.tab_right, TextureRect.STRETCH_KEEP)
	var icon := _piece(node, null, TextureRect.STRETCH_KEEP)
	var clip := Control.new()
	clip.name = "LabelClip"
	clip.clip_contents = true
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip.position = Vector2(_layout.label_windows_live[0], _layout.label_windows_live[1])
	node.add_child(clip)
	var label := _piece(clip, null, TextureRect.STRETCH_KEEP)
	var dots := _piece(node, _tex.label_dots, TextureRect.STRETCH_KEEP)
	dots.name = "Dots"
	dots.visible = false
	var close := TextureButton.new()
	close.name = "Close"
	close.texture_normal = _tex.icon_close
	close.texture_pressed = _tex.icon_close_pressed
	close.texture_hover = _tex.icon_close
	close.size = Vector2(_layout.close.w, _layout.close.h)
	close.visible = false
	node.add_child(close)
	var index := _tabs.size()
	node.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			select_tab(_tabs.find(_tab_of(node))))
	close.pressed.connect(func(): close_tab(_tabs.find(_tab_of(node))))
	add_child(node)
	if not _tabs.is_empty():
		move_child(node, _tabs[-1].node.get_index())  # behind its left neighbour: one clean join
	var tab := {"node": node, "mid": mid, "right": right, "icon": icon, "clip": clip, "label": label,
			"dots": dots, "close": close, "label_key": "", "width": width, "page": null}
	_tabs.append(tab)
	_set_label(tab, label_key)
	_set_tab_width(tab, width)
	return tab


func _tab_of(node: Control) -> Dictionary:
	for tab in _tabs:
		if tab.node == node:
			return tab
	return {}


func _piece(parent: Control, texture, stretch: int) -> TextureRect:
	var r := TextureRect.new()
	r.texture = texture
	r.stretch_mode = stretch
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(r)
	return r


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
	_fit_label(tab)


## The label gets the room between its left edge and the close button; when it does not fit,
## it is cut at the last whole glyph that fits and the "..." glyph follows (IE7 truncation).
func _fit_label(tab: Dictionary) -> void:
	var t: Dictionary = _layout.tab
	var label_x: float = _layout.label_windows_live[0]
	var close_x: float = tab.width - _layout.close.margin_right - _layout.close.w
	tab.close.position = Vector2(close_x, _layout.label_windows_live[1] + (66 - _layout.close.h) / 2.0)
	var room: float = close_x - 12 - label_x
	var full: float = tab.label.texture.get_width() if tab.label.texture else 0.0
	var dots_w: float = tab.dots.texture.get_width()
	if full <= room:
		tab.clip.size = Vector2(full, 66)
		tab.dots.visible = false
	else:
		var cut: float = max(0.0, room - dots_w)
		tab.clip.size = Vector2(cut, 66)
		tab.dots.position = Vector2(label_x + cut, _layout.label_windows_live[1])
		tab.dots.visible = cut > 0


func _set_tab_width(tab: Dictionary, width: float) -> void:
	var t: Dictionary = _layout.tab
	tab.width = width
	tab.node.size.x = width
	tab.mid.size = Vector2(max(0.0, width - t.left_w - t.right_w), t.height)
	tab.right.position = Vector2(width - t.right_w, 0)
	_fit_label(tab)


## Tabs sit at a fixed pitch while they fit; when the row is full they all shrink (IE7 behaviour).
func _fitted_width(count: int) -> float:
	var t: Dictionary = _layout.tab
	var overlap: float = t.full_width - _layout.tab_pitch
	var room: float = _tabs_max_right() - t.first_tab_x - _layout.stub.w + _layout.stub.gap_from_tab_right * -1.0
	var w: float = (room + overlap * (count - 1)) / count
	return min(t.full_width, w)


func _layout_tabs() -> void:
	if _tabs.is_empty():
		return
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
	var final_w := _fitted_width(_tabs.size() + 1)
	var tab := _make_tab("connecting", 0.0, final_w)
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
	tab.dots.modulate.a = a
	_layout_stub()


func select_tab(index: int) -> Dictionary:
	if index < 0 or index >= _tabs.size():
		return Errors.err(Errors.INDEX_OUT_OF_RANGE, str(index))
	_active = index
	for i in _tabs.size():
		_tabs[i].page.visible = (i == index)
		_tabs[i].close.visible = (i == index)  # IE7 shows the close button on the active tab only
	emit_signal("tab_selected", index)
	return Errors.ok(index)


## Close tab `index`: its page goes with it, the row re-lays out, and the neighbour on the left
## (or the first tab) becomes active. The last remaining tab cannot be closed.
func close_tab(index: int) -> Dictionary:
	if index < 0 or index >= _tabs.size():
		return Errors.err(Errors.INDEX_OUT_OF_RANGE, str(index))
	if _tabs.size() == 1:
		return Errors.err(Errors.NO_ROOM, "the last tab stays open")
	if _opening:
		return Errors.err(Errors.OPEN_IN_PROGRESS)
	_opening = true
	var tab: Dictionary = _tabs[index]
	var from_w: float = tab.width
	tab.close.visible = false
	_tween = create_tween()
	# the tab folds back into a stub where it stands: contents fade, then width/height/tint reverse the grow
	_tween.tween_method(func(s: float): _shrink(tab, from_w, s), 1.0, 0.0, CLOSE_SECONDS) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_callback(func():
		_tabs.remove_at(index)
		tab.page.queue_free()
		tab.node.queue_free()
		for i in _tabs.size():
			_tabs[i].node.name = "Tab%d" % i
			_tabs[i].page.name = "Page%d" % i
		_slide_row_closed()
		emit_signal("tab_closed", index)
		select_tab(clamp(index - 1 if index > 0 else 0, 0, _tabs.size() - 1)))
	return Errors.ok(_tabs.size() - 1)


func _shrink(tab: Dictionary, from_w: float, s: float) -> void:
	# s runs 1 -> 0; contents vanish in the first third, the shape follows
	var a: float = clamp((s - 0.66) / 0.34, 0.0, 1.0)
	tab.icon.modulate.a = a
	tab.label.modulate.a = a
	tab.dots.modulate.a = a
	var t: Dictionary = _layout.tab
	tab.node.scale = Vector2(1.0, lerp(_layout.stub.h / float(t.height), 1.0, s))
	_set_tab_width(tab, lerp(float(_layout.stub.w), from_w, s))
	tab.node.position.y = lerp(float(_layout.stub.y), float(t.y), s)
	tab.node.modulate = STUB_PINK.lerp(Color.WHITE, s)
	if tab.node == _tabs[-1].node:
		_layout_stub()


## After a close, the remaining tabs and the stub slide to their new places instead of jumping.
func _slide_row_closed() -> void:
	var w := _fitted_width(_tabs.size())
	var x: float = _layout.tab.first_tab_x
	var slide := create_tween().set_parallel(true)
	for tab in _tabs:
		slide.tween_method(func(v: float): _set_tab_width(tab, v), tab.width, w, SLIDE_SECONDS) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		slide.tween_property(tab.node, "position:x", x, SLIDE_SECONDS) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		x += w - (_layout.tab.full_width - _layout.tab_pitch)
	var stub_x: float = x - (w - (_layout.tab.full_width - _layout.tab_pitch)) + w + _layout.stub.gap_from_tab_right
	slide.tween_property(_stub, "position:x", stub_x, SLIDE_SECONDS) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	slide.chain().tween_callback(func():
		_opening = false
		_layout_tabs())


func state() -> Dictionary:
	var tabs := []
	for tab in _tabs:
		tabs.append({"label": tab.label_key, "rect": Rect2(tab.node.position, tab.node.size * tab.node.scale),
				"page_visible": tab.page.visible, "truncated": tab.dots.visible,
				"close_rect": Rect2(tab.node.position + tab.close.position, tab.close.size) if tab.close.visible else Rect2()})
	return Errors.ok({"count": _tabs.size(), "active": _active, "tabs": tabs, "opening": _opening,
			"bar_width": size.x})


func stub_rect() -> Rect2:
	return Rect2(_stub.position, _stub.size)
