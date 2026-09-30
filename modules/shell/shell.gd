## Shell implementation. Reach it through interface.gd only.
##
## The PageStack over a white ground, and the TabStrip along the bottom of the window, fitted to
## the Shell's width (the bar is the owner's reference, 4180 source px across the window, icon
## cluster at 65 percent). The seven fixed Tabs are indexes 0..6 forever: they never close and
## were opened before any stub tab. At launch the Collection tab grows in like a stub-opened tab,
## then its Page fades in; on every selection the new Page cross-fades over the old one and the
## freeze rule is applied once the fade has settled.
extends Control

const Errors := preload("res://modules/shell/errors.gd")
const TabStrip := preload("res://modules/tab_strip/interface.gd")
const HoverGlow := preload("res://modules/shell/hover_glow.gd")
const DesktopIcons := preload("res://modules/shell/desktop_icons.gd")
const WindowShadows := preload("res://modules/shell/window_shadows.gd")

signal tenant_created(key: String)
signal switch_settled(index: int)

const SOURCE_WIDTH := 5703.0  # the rebuilt taskbar (tab_strip compact layout, Issue #113)
const BAR_HEIGHT := 186.0
const FADE_SECONDS := 0.2
# Placeholder top header (the owner's menu-bar screenshot, 2026-09-23) above every Tab's Page,
# fitted to the window's width.
const HEADER_TEXTURE := "res://modules/shell/assets/top-header-placeholder.png"
const FIXED_TABS: Array[String] = [
	"map", "sketchbook", "3d_viewer", "video_player", "collection", "playground", "flowers"
]
const LAUNCH_TAB := "collection"

var _registry: Dictionary = {}
var _strip: Control
var _pages: Control
var _header: TextureRect
var _fixed: Array = []  # [{key, page, tenant: Control|null, error: String}] by tab index
var _shown: Array = []  # the Pages on screen: the active one, plus any still fading out
var _fade: Tween
var _switching := false


static func create(registry: Dictionary) -> Dictionary:
	var shell = load("res://modules/shell/shell.gd").new()
	shell._registry = registry
	shell._pages = Control.new()
	shell._pages.name = "PageStack"
	var created: Dictionary = TabStrip.create(shell._pages, false)  # no "Windows Live" tab: the seven are ours
	if not created.ok:
		return created
	shell._strip = created.value
	shell._strip.name = "TabStrip"
	return Errors.ok(shell)


func _ready() -> void:
	name = "Shell"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var ground := ColorRect.new()  # the page area is white even before any Page is shown
	ground.name = "Ground"
	ground.color = Color.WHITE
	ground.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(ground)
	add_child(_pages)
	_header = TextureRect.new()
	_header.name = "TopHeader"
	_header.texture = load(HEADER_TEXTURE)
	_header.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_header.stretch_mode = TextureRect.STRETCH_SCALE
	_header.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(_header)
	add_child(_strip)
	_strip.connect("tab_selected", _on_tab_selected)
	_fit()
	resized.connect(_fit)
	for key in FIXED_TABS:
		var page := ColorRect.new()  # the plain white Page; its Tenant arrives on first show
		page.name = "Page_" + key
		page.color = Color.WHITE
		page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var opened: Dictionary = TabStrip.open_fixed_tab(_strip, key, page)
		if not opened.ok:
			push_error("shell: could not open the %s tab: %s" % [key, opened.error.code])
			continue
		_fixed.append({"key": key, "page": page, "tenant": null, "error": ""})
	_apply_freeze()  # every Page starts hidden and frozen
	# prototype: the hover glow on the strip's buttons and the seven tabs, and the two-state arrow cursor
	HoverGlow.use_cursor()
	HoverGlow.attach_all(_strip)
	for tab in _strip.get_children():
		if tab.name.begins_with("Tab"):
			HoverGlow.attach(tab)
	# launch: the Collection tab grows in like a stub-opened tab; its Page fades in once it has settled
	var launch := FIXED_TABS.find(LAUNCH_TAB)
	var grown: Dictionary = TabStrip.grow_tab(_strip, launch)
	if grown.ok:  # on settle, unless a click already chose a tab while the grow ran
		_strip.connect(
			"tab_settled",
			func(_index: int):
				if TabStrip.state(_strip).value.active == -1:
					select_tab(launch),
			CONNECT_ONE_SHOT
		)
	else:
		select_tab(launch)


func _fit() -> void:
	var scale := size.x / SOURCE_WIDTH
	var bar_h := BAR_HEIGHT * scale
	_strip.scale = Vector2(scale, scale)
	TabStrip.set_bar_width(_strip, SOURCE_WIDTH)
	_strip.position = Vector2(0, size.y - bar_h)
	var header_h := size.x * _header.texture.get_height() / _header.texture.get_width()
	_header.position = Vector2.ZERO
	_header.size = Vector2(size.x, header_h)
	_pages.position = Vector2(0, header_h)
	_pages.size = Vector2(size.x, size.y - bar_h - header_h)


## A selection: the Tenant is created on the first show, then the new Page cross-fades in over
## FADE_SECONDS while the Page(s) on screen fade out; the freeze rule is applied when the fade settles.
func _on_tab_selected(index: int) -> void:
	if index < _fixed.size() and _fixed[index].tenant == null and _fixed[index].error == "":
		_create_tenant(_fixed[index])
	var target: Control = null
	for child in _pages.get_children():  # the strip shows exactly one live Page before it emits
		if child.visible and not child.is_queued_for_deletion():
			target = child
	if target == null:
		return
	if _fade != null and _fade.is_valid():
		_fade.kill()
	var outgoing: Array = []
	for p in _shown:
		if p != target and is_instance_valid(p) and not p.is_queued_for_deletion():
			p.visible = true  # the strip hid it; it keeps running until its fade is done
			outgoing.append(p)
	if not _shown.has(target):
		target.modulate.a = 0.0
	target.process_mode = Node.PROCESS_MODE_INHERIT
	_pages.move_child(target, -1)  # on top of whatever fades out beneath it
	_shown = [target] + outgoing
	_switching = true
	_fade = create_tween().set_parallel(true)
	_fade.tween_property(target, "modulate:a", 1.0, FADE_SECONDS)
	for p in outgoing:
		_fade.tween_property(p, "modulate:a", 0.0, FADE_SECONDS)
	_fade.chain().tween_callback(
		func():
			for p in outgoing:
				if is_instance_valid(p):
					p.visible = false
					p.modulate.a = 1.0
			_shown = [target]
			_switching = false
			_apply_freeze()
			emit_signal("switch_settled", index)
	)


## The Shell's show/hide rule: the visible Page runs, every hidden Page is frozen and holds no focus.
func _apply_freeze() -> void:
	var focus: Control = get_viewport().gui_get_focus_owner() if is_inside_tree() else null
	for child in _pages.get_children():
		var page := child as Control
		page.process_mode = (
			Node.PROCESS_MODE_INHERIT if page.visible else Node.PROCESS_MODE_DISABLED
		)
		if not page.visible and focus != null and page.is_ancestor_of(focus):
			focus.release_focus()


func _create_tenant(f: Dictionary) -> void:
	var maker = _registry.get(f.key)
	if maker == null:
		return  # no Tenant yet: the Page stays plain white (tenant_state says TENANT_MISSING)
	var result = maker.call({"key": f.key}) if maker is Callable else maker.create({"key": f.key})
	if not (result is Dictionary and result.get("ok") and result.get("value") is Control):
		f.error = Errors.TENANT_FAILED
		push_error("shell: tenant '%s' failed to create: %s" % [f.key, str(result)])
		return
	f.tenant = result.value
	f.page.add_child(f.tenant)
	if f.key not in ["playground", "collection"]:
		DesktopIcons.insert(f.tenant)
		WindowShadows.attach(f.tenant)
	if f.key == "sketchbook":  # prototype: the hover glow on every button of the Sketchbook Page first
		HoverGlow.attach_all(f.tenant)
	emit_signal("tenant_created", f.key)


# --- interface -------------------------------------------------------------------


func select_tab(index: int) -> Dictionary:
	return TabStrip.select_tab(_strip, index)


func close_tab(index: int) -> Dictionary:
	if index >= 0 and index < _fixed.size():
		return Errors.err(Errors.TAB_FIXED, _fixed[index].key)
	return TabStrip.close_tab(_strip, index)


func tenant_state(key: String) -> Dictionary:
	for f in _fixed:
		if f.key == key:
			if f.error != "":
				return Errors.err(f.error, key)
			if f.tenant == null:
				return Errors.err(Errors.TENANT_MISSING, key)
			return f.tenant.state() if f.tenant.has_method("state") else Errors.ok({})
	return Errors.err(Errors.TENANT_MISSING, key)


func state() -> Dictionary:
	var s: Dictionary = TabStrip.state(_strip).value
	var xf := _strip.get_transform()
	var tabs := []
	for i in s.tabs.size():
		var t: Dictionary = s.tabs[i]
		var f: Dictionary = _fixed[i] if i < _fixed.size() else {}
		var page: Control = f.page if not f.is_empty() else null
		tabs.append(
			{
				"key": f.get("key", ""),
				"label": t.label,
				"fixed": t.fixed,
				"page_visible": t.page_visible,
				"frozen": page != null and page.process_mode == Node.PROCESS_MODE_DISABLED,
				"tenant":
				(
					null
					if f.is_empty()
					else (f.error if f.error != "" else ("ok" if f.tenant != null else null))
				),
				"rect": xf * t.rect,
				"close_rect": xf * t.close_rect if t.close_rect.size.x > 0 else Rect2()
			}
		)
	return Errors.ok(
		{
			"count": s.count,
			"active": s.active,
			"opening": s.opening,
			"pressed": s.pressed,
			"switching": _switching,
			"fixed_count": _fixed.size(),
			"bar_rect": Rect2(_strip.position, _strip.size * _strip.scale),
			"stub_rect": xf * TabStrip.stub_rect(_strip),
			"tabs": tabs
		}
	)
