## TabStrip implementation. Reach it through interface.gd only.
##
## Every pixel comes from the sliced Muse toolbar in assets/ (layout.json maps them); the
## strip draws nothing by hand. Geometry is in source pixels (bar height 161). The bar is
## as wide as the caller makes it: the stars stay left, the icon cluster stays right, the
## pinstripes fill the middle, and tabs live between them.
extends Control

const Errors := preload("res://modules/tab_strip/errors.gd")
const SoundCues := preload("res://modules/sound_cues/interface.gd")
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
const FADE_SECONDS := 0.2  # the legacy active tint fade; reviewed fixed-tab stills switch at once
const SEA_BLUE := Color8(131, 229, 247)  # #83e5f7, the atlas world map's ocean (modules/atlas/assets/terrain.png)
const ACTIVE_TINT := 0.12  # how much of the sea blue the active tab's face carries (Issue #45)
const FIXED_TAB_WIDTH := 380.0
const FIXED_TAB_SCALE := 0.65
const STUB_PINK := Color8(247, 239, 244)
const STUB_PRESSED := Color8(228, 218, 226)
const DIP_PX := 6.0  # how far a clicked tab drops while it shows the pressed tint

var _layout: Dictionary = {}
var _tex: Dictionary = {}
var _tabs: Array = []  # [{node, left, mid, right, icon, clip, label, dots, close, label_key, width, page, fixed, tint, tint_to, fade}]
var _stub: TextureButton
var _right_cluster: TextureRect
var _stripes: TextureRect
var _page_stack: Control
var _active := -1
var _opening := false
var _tween: Tween
var _press_tween: Tween
var _pressed := -1  # the tab dipping under a click, or -1
var _windows_live_tab := true
var _compact_fixed_shell := false
var _reduce_motion := false


static func create(page_stack: Control, windows_live_tab: bool = true) -> Dictionary:
	var strip = load("res://modules/tab_strip/tab_strip.gd").new()
	strip._page_stack = page_stack
	strip._windows_live_tab = windows_live_tab
	strip._compact_fixed_shell = not windows_live_tab
	var loaded: Dictionary = strip._load_assets()
	if not loaded.ok:
		return loaded
	return Errors.ok(strip)


func _load_assets() -> Dictionary:
	if OS.has_feature("web"):
		_reduce_motion = bool(JavaScriptBridge.eval("matchMedia('(prefers-reduced-motion: reduce)').matches"))
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
	for key in _layout.get("labels", {}):  # the fixed tabs' titles (#29): label_<key>.png
		var t = load(ASSETS + _layout.labels[key])
		if t == null:
			return Errors.err(Errors.ASSET_MISSING, _layout.labels[key])
		_tex["label_" + key] = t
	for key in ["map", "sketchbook", "3d_viewer", "video_player", "collection", "playground"]:
		var t = load(ASSETS + "active_blue_" + key + ".png")
		if t == null:
			return Errors.err(Errors.ASSET_MISSING, "active_blue_" + key)
		_tex["active_blue_" + key] = t
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
	if _windows_live_tab:
		var first := _make_tab("windows_live", _layout.tab.first_tab_x, _layout.tab.full_width)
		_add_page(first, "windows_live")
	set_bar_width(w)
	if not _tabs.is_empty():
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
	node.set_meta("sound_cue_on_gui_activate", SoundCues.BUTTON)
	node.position = Vector2(x, t.y)
	node.size = Vector2(width, t.height)
	node.clip_contents = false  # the opening sits just below the node; labels clip in LabelClip
	var left := _piece(node, _tex.tab_left, TextureRect.STRETCH_KEEP)
	var mid := _piece(node, _tex.tab_mid, TextureRect.STRETCH_SCALE)
	mid.position = Vector2(t.left_w, 0)
	var right := _piece(node, _tex.tab_right, TextureRect.STRETCH_KEEP)
	var overlay_clip := Control.new()
	overlay_clip.name = "ActiveBlueClip"
	overlay_clip.clip_contents = true
	overlay_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.add_child(overlay_clip)
	var overlay := _piece(overlay_clip, null, TextureRect.STRETCH_KEEP)
	overlay.name = "ActiveBlue"
	overlay.visible = false
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
	node.add_child(close)
	var index := _tabs.size()
	node.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			_press(_tabs.find(_tab_of(node)))
			select_tab(_tabs.find(_tab_of(node))))
	close.pressed.connect(func(): close_tab(_tabs.find(_tab_of(node))))
	add_child(node)
	if not _tabs.is_empty():
		move_child(node, _tabs[-1].node.get_index())  # behind its left neighbour: one clean join
	var tab := {"node": node, "left": left, "mid": mid, "right": right, "overlay_clip": overlay_clip,
			"overlay": overlay, "icon": icon, "clip": clip, "label": label,
			"dots": dots, "close": close, "label_key": "", "width": width, "page": null, "fixed": false,
			"tint": 0.0, "tint_to": 0.0, "fade": null}
	_tabs.append(tab)
	_set_label(tab, label_key)
	_set_tab_width(tab, width)
	return tab


## The click dip: the clicked tab drops DIP_PX with the stub's pressed tint for PRESS_SECONDS, then sits
## back. Not while a grow or fold runs (those own the tab's position and tint).
func _press(index: int) -> void:
	if _opening or index < 0 or index >= _tabs.size():
		return
	if _press_tween != null and _press_tween.is_valid():
		_press_tween.kill()
		_unpress()
	var tab: Dictionary = _tabs[index]
	_pressed = index
	tab.node.modulate = STUB_PRESSED
	tab.node.position.y = _layout.tab.y + DIP_PX
	_press_tween = create_tween()
	_press_tween.tween_interval(PRESS_SECONDS)
	_press_tween.tween_callback(_unpress)


## The active tint: the tab's face slices fade to `to` (1 = ACTIVE_TINT of the sea blue, 0 = white) at
## FADE_SECONDS for the whole way, so a reversed fade takes only the distance left. It multiplies every
## piece of the tab (slices, icon, label, dots, close): the icon and label pixels are opaque on white, so
## their white must take the tint with the face; dark glyphs and the grey outline move a few levels at most.
func _fade(tab: Dictionary, to: float) -> void:
	if tab.tint_to == to:
		return
	tab.tint_to = to
	if tab.fade != null and tab.fade.is_valid():
		tab.fade.kill()
	if tab.overlay.texture != null:
		_set_tint(tab, to)
		return
	if _reduce_motion:
		_set_tint(tab, to)
		return
	tab.fade = create_tween()
	tab.fade.tween_method(func(v: float): _set_tint(tab, v), tab.tint, to, FADE_SECONDS * absf(to - tab.tint))


func _set_tint(tab: Dictionary, v: float) -> void:
	tab.tint = v
	if tab.overlay.texture != null:
		tab.overlay.visible = v > 0.0
		tab.overlay_clip.size = Vector2(tab.width * v, _layout.tab.height)
		for piece in [tab.left, tab.mid, tab.right, tab.icon, tab.label, tab.dots, tab.close]:
			piece.self_modulate = Color.WHITE
		return
	var c := Color.WHITE.lerp(SEA_BLUE, v * ACTIVE_TINT)
	for piece in [tab.left, tab.mid, tab.right, tab.icon, tab.label, tab.dots, tab.close]:
		piece.self_modulate = c


func _unpress() -> void:
	if _pressed >= 0 and _pressed < _tabs.size():
		_tabs[_pressed].node.modulate = Color.WHITE
		_tabs[_pressed].node.position.y = _layout.tab.y
	_pressed = -1


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
	tab.overlay.texture = _tex.get("active_blue_" + key) if _compact_fixed_shell else null
	tab.overlay.visible = tab.overlay.texture != null and tab.tint > 0.0
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
		_:  # a fixed tab's title from the labels map; no label yet (phone, #34) shows the icon alone
			tab.icon.texture = _tex.icon_page
			tab.icon.position = Vector2(_layout.page_icon[0], _layout.page_icon[1])
			tab.label.texture = _tex.get("label_" + key)
			if tab.label.texture == null:
				push_warning("tab_strip: no label pixels for '%s', showing the page icon alone" % key)
	_fit_label(tab)


## The label gets the room between its left edge and the close button; when it does not fit,
## it is cut at the last whole glyph that fits and the "..." glyph follows (IE7 truncation).
func _fit_label(tab: Dictionary) -> void:
	if _compact_fixed_shell and tab.fixed:
		var height: float = tab.label.texture.get_height() if tab.label.texture else 75.0
		var full: float = tab.label.texture.get_width() if tab.label.texture else 0.0
		var room: float = max(0.0, (tab.width - 48.0 - 110.0) / FIXED_TAB_SCALE)
		tab.icon.scale = Vector2(FIXED_TAB_SCALE, FIXED_TAB_SCALE)
		tab.icon.position = Vector2(34, (123 - tab.icon.texture.get_height() * FIXED_TAB_SCALE) / 2)
		tab.clip.scale = Vector2(FIXED_TAB_SCALE, FIXED_TAB_SCALE)
		tab.clip.position = Vector2(110, (123 - height * FIXED_TAB_SCALE) / 2)
		tab.dots.visible = full > room
		tab.clip.size = Vector2(min(full, max(0.0, room - 40.0 if tab.dots.visible else room)), height)
		tab.dots.scale = Vector2(FIXED_TAB_SCALE, FIXED_TAB_SCALE)
		tab.dots.position = tab.clip.position + Vector2(tab.clip.size.x * FIXED_TAB_SCALE, 0)
		return
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
	elif room < dots_w + 20:
		tab.clip.size = Vector2(0, 66)  # narrowest IE7 tab: icon and close button only
		tab.dots.visible = false
	else:
		var cut: float = max(0.0, room - dots_w)
		tab.clip.size = Vector2(cut, 66)
		tab.dots.position = Vector2(label_x + cut, _layout.label_windows_live[1])
		tab.dots.visible = cut > 0


func _set_tab_width(tab: Dictionary, width: float) -> void:
	var t: Dictionary = _layout.tab
	width = round(width)  # whole source pixels: no hairline seams between the three slices
	tab.width = width
	tab.node.size.x = width
	tab.mid.size = Vector2(max(0.0, width - t.left_w - t.right_w), t.height)
	tab.right.position = Vector2(width - t.right_w, 0)
	if tab.overlay.texture != null:
		tab.overlay_clip.size = Vector2(width * tab.tint, t.height)
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
		_stub.position = Vector2(_layout.tab.first_tab_x + (_layout.tab.full_width - _layout.tab_pitch) + _layout.stub.gap_from_tab_right, _layout.stub.y)
		return
	var w: float = min(FIXED_TAB_WIDTH, _fitted_width(_tabs.size())) if _compact_fixed_shell else _fitted_width(_tabs.size())
	var x: float = _layout.tab.first_tab_x
	for tab in _tabs:
		if not _opening or tab != _tabs[-1]:
			_set_tab_width(tab, w)
		tab.node.position.x = x
		x += tab.width - (_layout.tab.full_width - _layout.tab_pitch)
	_layout_stub()


func _layout_stub() -> void:
	if _tabs.is_empty():
		_layout_tabs()
		return
	var last: Dictionary = _tabs[-1]
	_stub.position = Vector2(last.node.position.x + last.width + _layout.stub.gap_from_tab_right, _layout.stub.y)


func _add_page(tab: Dictionary, key: String) -> void:
	var page := ColorRect.new()
	page.color = Color.WHITE
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var title := TextureRect.new()
	title.texture = _tex.label_blank_page if key != "windows_live" else _tex.label_windows_live
	title.stretch_mode = TextureRect.STRETCH_KEEP
	title.position = Vector2(40, 40)
	page.add_child(title)
	page.name = "Page%d" % (_tabs.size() - 1)
	_own_page(tab, page)


## The tab owns `page`: hidden in the caller's PageStack until select_tab shows it.
func _own_page(tab: Dictionary, page: Control) -> void:
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


## A fixed tab appears at once, titled from the labels map, on the caller's page; no animation, no
## signals, no close button (see close_tab).
func open_fixed_tab(label_key: String, page: Control) -> Dictionary:
	if _opening:
		return Errors.err(Errors.OPEN_IN_PROGRESS)
	if _fitted_width(_tabs.size() + 1) < _layout.tab_min_width:
		return Errors.err(Errors.NO_ROOM, "%d tabs" % _tabs.size())
	var tab := _make_tab(label_key, 0.0, _fitted_width(_tabs.size() + 1))
	tab.fixed = true
	tab.close.visible = false
	_own_page(tab, page)
	_layout_tabs()
	return Errors.ok(_tabs.size() - 1)


## Replay the open gesture on an existing tab, in place (the Shell's launch tab): stub-sized with the
## pressed tint for PRESS_SECONDS, then the grow to its own width over GROW_SECONDS; its neighbours and
## the stub stay put. Emits tab_opened, then tab_settled; selects nothing.
func grow_tab(index: int) -> Dictionary:
	if index < 0 or index >= _tabs.size():
		return Errors.err(Errors.INDEX_OUT_OF_RANGE, str(index))
	if _opening:
		return Errors.err(Errors.OPEN_IN_PROGRESS)
	_opening = true
	var tab: Dictionary = _tabs[index]
	var final_w: float = tab.width
	_grow(tab, final_w, 0.0)
	tab.node.modulate = STUB_PRESSED
	emit_signal("tab_opened", index)
	_tween = create_tween()
	_tween.tween_interval(PRESS_SECONDS)
	_tween.tween_method(func(s: float): _grow(tab, final_w, s), 0.0, 1.0, GROW_SECONDS) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_callback(func():
		_opening = false
		_layout_tabs()
		emit_signal("tab_settled", index))
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
		_fade(_tabs[i], 1.0 if i == index else 0.0)
	emit_signal("tab_selected", index)
	return Errors.ok(index)


## Close tab `index`: its page goes with it, the row re-lays out, and the neighbour on the left
## (or the first tab) becomes active. Every tab can close, the last one too; a fixed tab refuses.
func close_tab(index: int) -> Dictionary:
	if index < 0 or index >= _tabs.size():
		return Errors.err(Errors.INDEX_OUT_OF_RANGE, str(index))
	if _tabs[index].fixed:
		return Errors.err(Errors.TAB_FIXED, _tabs[index].label_key)
	if _opening:
		return Errors.err(Errors.OPEN_IN_PROGRESS)
	_opening = true
	var tab: Dictionary = _tabs[index]
	var from_w: float = tab.width
	tab.close.visible = false
	_fade(tab, 0.0)  # the tint leaves with the tab; the neighbour's fades in when it is selected below
	_tween = create_tween()
	# the tab folds back into a stub where it stands: contents fade, then width/height/tint reverse the grow
	_tween.tween_method(func(s: float): _shrink(tab, from_w, s), 1.0, 0.0, CLOSE_SECONDS) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_callback(func():
		_tabs.remove_at(index)
		if tab.fade != null and tab.fade.is_valid():
			tab.fade.kill()
		tab.page.queue_free()
		tab.node.queue_free()
		for i in _tabs.size():
			_tabs[i].node.name = "Tab%d" % i
			if not _tabs[i].fixed:  # a fixed tab's page is the caller's node; its name is theirs
				_tabs[i].page.name = "Page%d" % i
		_slide_row_closed()
		emit_signal("tab_closed", index)
		if _tabs.is_empty():
			_active = -1
		else:
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
	if not _tabs.is_empty() and tab.node == _tabs[-1].node:
		_layout_stub()


## After a close, the remaining tabs and the stub slide to their new places instead of jumping.
func _slide_row_closed() -> void:
	var w := _fitted_width(_tabs.size()) if not _tabs.is_empty() else float(_layout.tab.full_width)
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
				"page_visible": tab.page.visible, "fixed": tab.fixed, "tint": tab.tint,
				"truncated": tab.clip.size.x < (tab.label.texture.get_width() if tab.label.texture else 0.0),
				"close_rect": Rect2() if tab.fixed else Rect2(tab.node.position + tab.close.position, tab.close.size)})
	return Errors.ok({"count": _tabs.size(), "active": _active, "tabs": tabs, "opening": _opening,
			"pressed": _pressed, "bar_width": size.x})


func stub_rect() -> Rect2:
	return Rect2(_stub.position, _stub.size)
