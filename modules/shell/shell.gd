## Shell implementation. Reach it through interface.gd only.
##
## A white ground, the PageStack, and the TabStrip fitted to the Shell's width (the bar is the
## owner's reference, 4180 source px across the window, icon cluster at 65 percent). The six
## fixed Tabs are indexes 0..5 forever: they never close and were opened before any stub tab.
extends Control

const Errors := preload("res://modules/shell/errors.gd")
const TabStrip := preload("res://modules/tab_strip/interface.gd")

signal tenant_created(key: String)

const SOURCE_WIDTH := 4180.0
const BAR_HEIGHT := 161.0
const FIXED_TABS: Array[String] = ["map", "sketchbook", "3d_viewer", "video_player", "collection", "phone"]
const LAUNCH_TAB := "collection"

var _registry: Dictionary = {}
var _strip: Control
var _pages: Control
var _fixed: Array = []  # [{key, page, tenant: Control|null, error: String}] by tab index


static func create(registry: Dictionary) -> Dictionary:
	var shell = load("res://modules/shell/shell.gd").new()
	shell._registry = registry
	shell._pages = Control.new()
	shell._pages.name = "PageStack"
	var created: Dictionary = TabStrip.create(shell._pages, false)  # no "Windows Live" tab: the six are ours
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
	select_tab(FIXED_TABS.find(LAUNCH_TAB))


func _fit() -> void:
	var scale := size.x / SOURCE_WIDTH
	_strip.scale = Vector2(scale, scale)
	TabStrip.set_bar_width(_strip, SOURCE_WIDTH)
	_pages.position = Vector2(0, BAR_HEIGHT * scale)
	_pages.size = Vector2(size.x, size.y - BAR_HEIGHT * scale)


## The Shell's show/hide rule: the visible Page runs, every hidden Page is frozen and holds no focus.
func _on_tab_selected(index: int) -> void:
	if index < _fixed.size() and _fixed[index].tenant == null and _fixed[index].error == "":
		_create_tenant(_fixed[index])
	var focus: Control = get_viewport().gui_get_focus_owner() if is_inside_tree() else null
	for child in _pages.get_children():
		var page := child as Control
		page.process_mode = Node.PROCESS_MODE_INHERIT if page.visible else Node.PROCESS_MODE_DISABLED
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
		tabs.append({"key": f.get("key", ""), "label": t.label, "fixed": t.fixed, "page_visible": t.page_visible,
				"frozen": page != null and page.process_mode == Node.PROCESS_MODE_DISABLED,
				"tenant": null if f.is_empty() else (f.error if f.error != "" else ("ok" if f.tenant != null else null)),
				"rect": xf * t.rect, "close_rect": xf * t.close_rect if t.close_rect.size.x > 0 else Rect2()})
	return Errors.ok({"count": s.count, "active": s.active, "opening": s.opening, "fixed_count": _fixed.size(),
			"stub_rect": xf * TabStrip.stub_rect(_strip), "tabs": tabs})
