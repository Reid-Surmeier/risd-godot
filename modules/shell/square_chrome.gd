## Selected Browser treatment from #156. The Shell retains all Page lifecycle behavior.
extends Control

const Shell := preload("res://modules/shell/interface.gd")
const ASSETS := "res://modules/shell/assets/square_chrome/"
const KEYS := ["map", "sketchbook", "3d_viewer", "video_player", "collection", "playground", "flowers"]
const NAMES := ["Map", "Sketchbook", "3D Viewer", "Video Player", "Collection", "Playground", "Flowers"]
var shell: Control
var pages: Control
var header: Control
var strip: Control
var start_menu: PopupMenu
var title_label: Label
var tab_buttons: Array[Button] = []
var search_requested: Callable


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	pages = shell.get_node("PageStack")
	shell.get_node("TabStrip").hide()
	shell.get_node("TopHeader").hide()
	header = Control.new()
	header.name = "SharedTopBar"
	add_child(header)
	strip = Control.new()
	strip.name = "BottomTabStrip"
	strip.position.y = 1026
	add_child(strip)
	for bar in [header, strip]:
		bar.size = Vector2(1080, 54)
		_raster(bar, "res://modules/tab_strip/assets/compact/bar_stripes.png", Rect2(0, 0, 1080, 54))
	var brand := Label.new()
	brand.text = "RISD MUSEUM"
	brand.position = Vector2(18, 14)
	brand.add_theme_font_size_override("font_size", 20)
	brand.add_theme_color_override("font_color", Color("#18232b"))
	header.add_child(brand)
	_raster(header, ASSETS + "selected-face.png", Rect2(210, 8, 103, 38))
	_button(header, "Previous", Rect2(218, 7, 92, 40), "", _relative.bind(-1))
	title_label = Label.new()
	title_label.position = Vector2(342, 18)
	title_label.add_theme_font_size_override("font_size", 15)
	title_label.add_theme_color_override("font_color", Color("#18232b"))
	header.add_child(title_label)
	_raster(header, ASSETS + "selected-face.png", Rect2(502, 8, 84, 38))
	_button(header, "Next", Rect2(510, 7, 75, 40), "", _relative.bind(1))
	var search := _button(header, "Search Playground", Rect2(620, 8, 220, 38), "search", _search)
	var inset := StyleBoxFlat.new()
	inset.bg_color = Color.WHITE
	inset.border_color = Color("#8a9198")
	inset.set_border_width_all(2)
	inset.set_corner_radius_all(12)
	inset.set_content_margin_all(6)
	for state_name in ["normal", "hover", "pressed", "focus"]:
		search.add_theme_stylebox_override(state_name, inset)
	_button(strip, "Start", Rect2(0, 3, 98, 51), "start", _open_start)
	for i in KEYS.size():
		var x := 100.0 + i * 127.0
		var face := _raster(strip, ASSETS + "selected-face.png", Rect2(x + 1, 3, 125, 48))
		face.name = "Selected%d" % i
		var button := _button(strip, NAMES[i], Rect2(x, 0, 127, 54), KEYS[i], _select.bind(i))
		button.toggle_mode = true
		tab_buttons.append(button)
	_button(strip, "Home", Rect2(992, 3, 88, 51), "home", _select.bind(0))
	start_menu = PopupMenu.new()
	start_menu.name = "StartMenu"
	var menu_style := StyleBoxTexture.new()
	menu_style.texture = load(ASSETS + "stripe-face.png")
	menu_style.set_content_margin_all(12)
	start_menu.add_theme_stylebox_override("panel", menu_style)
	start_menu.add_theme_color_override("font_color", Color("#18232b"))
	start_menu.add_theme_font_size_override("font_size", 18)
	for i in KEYS.size():
		start_menu.add_item(NAMES[i], i)
	start_menu.id_pressed.connect(_select)
	add_child(start_menu)
	shell.switch_settled.connect(func(_index: int) -> void: _sync_tabs())
	shell.tenant_created.connect(_prepare_tenant)
	shell.resized.connect(_layout)
	_layout()
	_sync_tabs()


func _button(parent: Control, text: String, rect: Rect2, icon: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.add_theme_font_size_override("font_size", 15)
	for state_name in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	for state_name in ["font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color"]:
		button.add_theme_color_override(state_name, Color("#18232b"))
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color.TRANSPARENT
	focus.border_color = Color("#385e78")
	focus.set_border_width_all(2)
	button.add_theme_stylebox_override("focus", focus)
	if not icon.is_empty():
		button.icon = load(ASSETS + icon + ".png")
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width", 25)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button


func _raster(parent: Control, path: String, rect: Rect2) -> TextureRect:
	var picture := TextureRect.new()
	picture.texture = load(path)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_SCALE
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	picture.position = rect.position
	picture.size = rect.size
	parent.add_child(picture)
	return picture


func _layout() -> void:
	pages.position = Vector2(0, 54)
	pages.size = Vector2(1080, 972)


func _active() -> int:
	return Shell.state(shell).value.active


func _sync_tabs() -> void:
	var active := _active()
	for i in tab_buttons.size():
		tab_buttons[i].button_pressed = i == active
		strip.get_node("Selected%d" % i).visible = i == active
	title_label.text = NAMES[active] if active >= 0 else "Loading"


func _select(index: int) -> void:
	Shell.select_tab(shell, index)
	_sync_tabs()


func _relative(step: int) -> void:
	_select(wrapi(_active() + step, 0, KEYS.size()))


func _search() -> void:
	_select(5)
	search_requested.call()


func _open_start() -> void:
	start_menu.position = Vector2i(0, int(1026 - start_menu.get_contents_minimum_size().y))
	start_menu.popup()


func _prepare_tenant(key: String) -> void:
	if key == "playground":
		# The selected Playground grid occupies its whole Page, without desktop decoration.
		var tenant := pages.get_node("Page_playground").get_child(0) as Control
		tenant.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var icons := tenant.find_child("DesktopIcons", true, false) as Control
		if icons != null:
			icons.hide()
		tenant.get_node("WindowShadows").process_mode = Node.PROCESS_MODE_DISABLED
	elif key == "map":
		var minimap := pages.get_node_or_null("Page_map/Atlas/minimap") as Control
		if minimap != null:
			var mask := ColorRect.new()
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
		var collection := pages.get_node("Page_collection/CollectionFrame") as TextureRect
		var mask := ColorRect.new()
		mask.color = Color.WHITE
		mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
		collection.add_child(mask)
		var fit := func() -> void:
			var factor := minf(collection.size.x / collection.texture.get_width(), collection.size.y / collection.texture.get_height())
			var origin := (collection.size - collection.texture.get_size() * factor) / 2.0
			mask.position = origin + Vector2(1100, 2250) * factor
			mask.size = Vector2(950, 702) * factor
		collection.resized.connect(fit)
		fit.call()
