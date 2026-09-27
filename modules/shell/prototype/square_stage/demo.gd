## PROTOTYPE #155: three layouts of the same seven-Tenant Shell at 1080 square.
## The design question is whether full bleed, inset window, or side desk gives the
## owner the most useful first-pass fit before art-directing individual windows.
extends "res://modules/shell/demo.gd"

const KEYS := ["map", "sketchbook", "3d_viewer", "video_player", "collection", "playground", "flowers"]
const NAMES := ["Map", "Sketchbook", "3D Viewer", "Video Player", "Collection", "Playground", "Flowers"]
const VARIANTS := ["A · Full bleed", "B · Inset window", "C · Side desk"]

var variant := 0
var shell: Control
var pages: Control
var header: PanelContainer
var strip: HBoxContainer
var switcher: HBoxContainer
var start_menu: PopupMenu
var title_label: Label
var hint_label: Label
var side_panel: PanelContainer
var side_title: Label
var tab_buttons: Array[Button] = []


func _ready() -> void:
	super._ready()
	shell = get_node("Shell")
	pages = shell.get_node("PageStack")
	shell.get_node("TabStrip").hide()
	shell.get_node("TopHeader").hide()
	if OS.has_feature("web"):
		var key: String = str(JavaScriptBridge.eval("new URLSearchParams(location.search).get('variant') || 'A'"))
		variant = clampi("ABC".find(key.to_upper()), 0, 2)
	else:
		for arg in OS.get_cmdline_user_args():
			if arg.begins_with("--variant="):
				variant = clampi("ABC".find(arg.trim_prefix("--variant=").to_upper()), 0, 2)
	_build_ui()
	resized.connect(_layout)
	_layout()
	shell.switch_settled.connect(func(_index: int) -> void: _sync_tabs())
	shell.tenant_created.connect(_mask_tenant_clock)
	_sync_tabs()


func _build_ui() -> void:
	side_panel = PanelContainer.new()
	side_panel.name = "SideDesk"
	_add_panel_style(side_panel, Color("#e9eff5"))
	add_child(side_panel)
	var side_content := VBoxContainer.new()
	side_panel.add_child(side_content)
	var page_heading := Label.new()
	page_heading.text = "CURRENT PAGE"
	page_heading.add_theme_color_override("font_color", Color("#263b4c"))
	side_content.add_child(page_heading)
	side_title = Label.new()
	side_title.add_theme_font_size_override("font_size", 18)
	side_title.add_theme_color_override("font_color", Color("#263b4c"))
	side_content.add_child(side_title)
	var direction := Label.new()
	direction.text = "Choose one of the\nseven Tabs below."
	direction.add_theme_color_override("font_color", Color("#263b4c"))
	side_content.add_child(direction)
	header = PanelContainer.new()
	header.name = "SharedTopBar"
	_add_panel_style(header, Color("#e9eff5"))
	add_child(header)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 10)
	header.add_child(top)
	var brand := Label.new()
	brand.text = "RISD MUSEUM"
	brand.add_theme_font_size_override("font_size", 20)
	brand.add_theme_color_override("font_color", Color("#263b4c"))
	top.add_child(brand)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(spacer)
	var previous := Button.new()
	previous.text = "← Tab"
	previous.pressed.connect(func() -> void: _select_relative(-1))
	top.add_child(previous)
	title_label = Label.new()
	title_label.custom_minimum_size.x = 150
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.add_theme_color_override("font_color", Color("#263b4c"))
	top.add_child(title_label)
	var next := Button.new()
	next.text = "Tab →"
	next.pressed.connect(func() -> void: _select_relative(1))
	top.add_child(next)
	strip = HBoxContainer.new()
	strip.name = "BottomTabStrip"
	strip.add_theme_constant_override("separation", 2)
	add_child(strip)
	var start := Button.new()
	start.text = "Start"
	start.custom_minimum_size.x = 84
	start.pressed.connect(_open_start)
	strip.add_child(start)
	start_menu = PopupMenu.new()
	start_menu.name = "StartMenu"
	for i in KEYS.size():
		start_menu.add_item(NAMES[i], i)
	start_menu.id_pressed.connect(func(id: int) -> void: _select(id))
	add_child(start_menu)
	for i in KEYS.size():
		var button := Button.new()
		button.text = NAMES[i]
		button.toggle_mode = true
		var selected := StyleBoxFlat.new()
		selected.bg_color = Color("#244d70")
		selected.set_border_width_all(2)
		selected.border_color = Color("#9cd4f5")
		button.add_theme_stylebox_override("pressed", selected)
		button.add_theme_stylebox_override("hover_pressed", selected)
		button.add_theme_color_override("font_pressed_color", Color.WHITE)
		button.add_theme_color_override("font_hover_pressed_color", Color.WHITE)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_select.bind(i))
		strip.add_child(button)
		tab_buttons.append(button)
	var home := Button.new()
	home.text = "Home"
	home.custom_minimum_size.x = 84
	home.pressed.connect(func() -> void: _select(0))
	strip.add_child(home)
	switcher = HBoxContainer.new()
	switcher.name = "PrototypeSwitcher"
	switcher.add_theme_constant_override("separation", 4)
	top.add_child(switcher)
	var left := Button.new()
	left.text = "◀"
	left.pressed.connect(func() -> void: _set_variant(wrapi(variant - 1, 0, 3)))
	switcher.add_child(left)
	hint_label = Label.new()
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.custom_minimum_size.x = 160
	hint_label.add_theme_color_override("font_color", Color("#263b4c"))
	switcher.add_child(hint_label)
	var right := Button.new()
	right.text = "▶"
	right.pressed.connect(func() -> void: _set_variant(wrapi(variant + 1, 0, 3)))
	switcher.add_child(right)


func _add_panel_style(panel: PanelContainer, color: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_border_width_all(1)
	style.border_color = Color("#77899b")
	style.set_content_margin_all(9)
	panel.add_theme_stylebox_override("panel", style)


func _layout() -> void:
	if shell == null:
		return
	var side := 0.0
	var margin := 0.0
	match variant:
		1: margin = 28.0
		2: side = 188.0
	shell.get_node("Ground").color = Color.WHITE if variant == 0 else (Color("#d9e2e8") if variant == 1 else Color("#c3d4df"))
	side_panel.visible = variant == 2
	side_panel.position = Vector2(8, 70)
	side_panel.size = Vector2(170, 125)
	header.position = Vector2.ZERO
	header.size = Vector2(size.x, 54)
	strip.position = Vector2(0, size.y - 54)
	strip.size = Vector2(size.x, 54)
	var available := Vector2(size.x - 2 * margin - side, size.y - 108 - 2 * margin)
	var page_size := Vector2(size.x, size.y - 108)
	var page_scale := minf(available.x / page_size.x, available.y / page_size.y)
	pages.position = Vector2(margin + side, 54 + margin)
	pages.scale = Vector2.ONE * page_scale
	pages.size = page_size
	hint_label.text = VARIANTS[variant]
	# The source Tenants keep their accepted pixels; these masks belong to this prototype.
	var collection := pages.get_node_or_null("Page_collection/CollectionFrame") as Control
	if collection != null:
		_fit_collection_mask(collection)


func _active() -> int:
	var result: Dictionary = Shell.state(shell)
	return result.value.active if result.ok else 4


func _sync_tabs() -> void:
	var active := _active()
	for i in tab_buttons.size():
		tab_buttons[i].button_pressed = i == active
	title_label.text = NAMES[active] if active >= 0 and active < NAMES.size() else "Loading"
	side_title.text = title_label.text


func _select(index: int) -> void:
	Shell.select_tab(shell, index)
	_sync_tabs()


func _select_relative(step: int) -> void:
	_select(wrapi(_active() + step, 0, KEYS.size()))


func _open_start() -> void:
	start_menu.position = Vector2i(0, int(size.y - 54 - start_menu.get_contents_minimum_size().y))
	start_menu.popup()


func _set_variant(index: int) -> void:
	variant = index
	if OS.has_feature("web"):
		JavaScriptBridge.eval("history.replaceState(null, '', new URL(location.href).pathname + '?variant=%s')" % "ABC"[variant])
	_layout()


func _mask_tenant_clock(key: String) -> void:
	if key == "map":
		var minimap := pages.get_node_or_null("Page_map/Atlas/minimap") as Control
		if minimap != null:
			var mask := ColorRect.new()
			mask.name = "PrototypeClockMask"
			mask.color = Color("#e8f4f7")
			mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
			minimap.add_child(mask)
			var label := Label.new()
			label.text = "MINI MAP"
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.add_theme_font_size_override("font_size", 14)
			label.add_theme_color_override("font_color", Color("#385e78"))
			label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			mask.add_child(label)
			minimap.resized.connect(func() -> void:
				mask.position = Vector2(minimap.size.x * 0.07, 0)
				mask.size = Vector2(minimap.size.x * 0.74, minimap.size.y * 0.35))
			minimap.resized.emit()
	elif key == "collection":
		var collection := pages.get_node_or_null("Page_collection/CollectionFrame") as Control
		if collection != null:
			var mask := ColorRect.new()
			mask.name = "PrototypeClockMask"
			mask.color = Color.WHITE
			mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
			collection.add_child(mask)
			collection.resized.connect(_fit_collection_mask.bind(collection))
			_fit_collection_mask(collection)


func _fit_collection_mask(collection: Control) -> void:
	var mask := collection.get_node_or_null("PrototypeClockMask") as ColorRect
	if mask == null:
		return
	var texture := (collection as TextureRect).texture
	var scale_factor: float = minf(collection.size.x / texture.get_width(), collection.size.y / texture.get_height())
	var origin: Vector2 = (collection.size - texture.get_size() * scale_factor) / 2.0
	mask.position = origin + Vector2(1100, 2250) * scale_factor
	mask.size = Vector2(950, 702) * scale_factor


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and get_viewport().gui_get_focus_owner() == null:
		if event.keycode == KEY_LEFT:
			_set_variant(wrapi(variant - 1, 0, 3))
		elif event.keycode == KEY_RIGHT:
			_set_variant(wrapi(variant + 1, 0, 3))
