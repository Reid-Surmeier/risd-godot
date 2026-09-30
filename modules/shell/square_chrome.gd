## Selected Browser treatment from #156. The Shell retains all Page lifecycle behavior.
extends Control

const Shell := preload("res://modules/shell/interface.gd")
const COMPACT := "res://modules/tab_strip/assets/compact/"
const BAND_WIDTH := 4348.0
const ASSETS := "res://modules/shell/assets/square_chrome/"
const KEYS := [
	"map", "sketchbook", "3d_viewer", "video_player", "collection", "playground", "flowers"
]
const NAMES := [
	"Map", "Sketchbook", "3D Viewer", "Video Player", "Collection", "Playground", "Flowers"
]
var shell: Control
var pages: Control
var header: Control
var strip: Control
var start_menu: PopupMenu
var title_label: Label
var tab_buttons: Array[Button] = []
var search_requested: Callable
var fullscreen_button: Button
var _fullscreen_callback: JavaScriptObject


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
	strip.position.y = 1080 - 186 * 1080 / BAND_WIDTH
	strip.scale = Vector2.ONE * 1080 / BAND_WIDTH
	add_child(strip)
	header.size = Vector2(1080, 54)
	_raster(header, ASSETS + "bar_stripes.png", Rect2(0, 0, 1080, 54))
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
	fullscreen_button = _button(
		header, "Full screen", Rect2(872, 8, 190, 38), "", _toggle_fullscreen
	)
	fullscreen_button.name = "Fullscreen"
	fullscreen_button.tooltip_text = "Expand to full screen; proportions stay unchanged"
	get_window().size_changed.connect(_sync_fullscreen)
	if OS.has_feature("web"):
		fullscreen_button.disabled = not JavaScriptBridge.eval("!!document.fullscreenEnabled")
		if fullscreen_button.disabled:
			fullscreen_button.tooltip_text = "Open this page in a browser window to use full screen."
		_fullscreen_callback = JavaScriptBridge.create_callback(
			func(_args: Array) -> void: _sync_fullscreen()
		)
		JavaScriptBridge.get_interface("document").addEventListener(
			"fullscreenchange", _fullscreen_callback
		)
	_sync_fullscreen()
	strip.size = Vector2(BAND_WIDTH, 186)
	var layout: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(COMPACT + "layout.json")
	)
	_raster(strip, COMPACT + "bar_stripes.png", Rect2(0, 0, BAND_WIDTH, 186))
	_raster(strip, COMPACT + "stars.png", Rect2(0, 0, 307, 186))
	_band_button("Start", Rect2(0, 0, 307, 186), _open_start)
	# Draw right-to-left, retaining the source's 67 px overlap and native label positions.
	for i in range(KEYS.size() - 1, -1, -1):
		var x := 307.0 + i * 550.0
		var face := Control.new()
		face.name = "Selected%d" % i
		face.mouse_filter = Control.MOUSE_FILTER_IGNORE
		strip.add_child(face)
		_raster(face, COMPACT + "tab_left.png", Rect2(x, 34, 67, 146))
		var middle := _raster(face, COMPACT + "tab_mid.png", Rect2(x + 67, 34, 483, 146))
		middle.stretch_mode = TextureRect.STRETCH_TILE
		_raster(face, COMPACT + "tab_right.png", Rect2(x + 550, 34, 67, 146))
		for kind in ["icon", "label"]:
			var at: Array = layout.place[KEYS[i]][kind]
			var path: String = COMPACT + kind + "_" + KEYS[i] + ".png"
			var texture: Texture2D = load(path)
			_raster(strip, path, Rect2(Vector2(x + at[0], 34 + at[1]), texture.get_size()))
	for i in KEYS.size():
		var button := _band_button(NAMES[i], Rect2(307 + i * 550, 34, 550, 146), _select.bind(i))
		button.toggle_mode = true
		tab_buttons.append(button)
	var home := _raster(strip, COMPACT + "right_cluster.png", Rect2(4224, 0, 124, 186))
	var crop := AtlasTexture.new()
	crop.atlas = home.texture
	crop.region = Rect2(0, 0, 124, 186)
	home.texture = crop
	_band_button("Home", Rect2(4224, 0, 124, 186), _select.bind(0))
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
	shell.resized.connect(_layout)
	_layout()
	_sync_tabs()


func _band_button(label: String, rect: Rect2, callback: Callable) -> Button:
	var button := _button(strip, "", rect, "", callback)
	button.name = label.replace(" ", "")
	button.tooltip_text = label
	return button


func _button(
	parent: Control, text: String, rect: Rect2, icon: String, callback: Callable
) -> Button:
	var button := Button.new()
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.add_theme_font_size_override("font_size", 15)
	for state_name in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(state_name, StyleBoxEmpty.new())
	for state_name in [
		"font_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color"
	]:
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
	button.gui_input.connect(
		func(event: InputEvent) -> void:
			if (
				event is InputEventMouseButton
				and event.button_index == MOUSE_BUTTON_LEFT
				and event.pressed
			):
				button.release_focus()
	)
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
		strip.get_node("Selected%d" % i).modulate = (
			Color(0.911, 0.911, 0.911) if i == active else Color.WHITE
		)
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


func _is_fullscreen() -> bool:
	if OS.has_feature("web"):
		return JavaScriptBridge.eval("!!document.fullscreenElement")
	return get_window().mode in [Window.MODE_FULLSCREEN, Window.MODE_EXCLUSIVE_FULLSCREEN]


func _sync_fullscreen() -> void:
	fullscreen_button.text = "Exit full screen" if _is_fullscreen() else "Full screen"
	if OS.has_feature("web") and JavaScriptBridge.eval("!!window.risdFullscreenError"):
		fullscreen_button.tooltip_text = "Your browser blocked full screen in this window."


func _toggle_fullscreen() -> void:
	if OS.has_feature("web"):
		(
			JavaScriptBridge
			. eval(
				"window.risdFullscreenError = false; (document.fullscreenElement ? document.exitFullscreen() : document.documentElement.requestFullscreen()).catch(() => { window.risdFullscreenError = true; document.dispatchEvent(new Event('fullscreenchange')); })"
			)
		)
	else:
		get_window().mode = Window.MODE_WINDOWED if _is_fullscreen() else Window.MODE_FULLSCREEN
	_sync_fullscreen()


func _exit_tree() -> void:
	if _fullscreen_callback != null:
		JavaScriptBridge.get_interface("document").removeEventListener(
			"fullscreenchange", _fullscreen_callback
		)
