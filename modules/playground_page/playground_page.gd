## The Playground desktop (owner correction 2026-09-14, ticket #62): the owner's layout picture as a
## working page. Left, the Digital Playground (PostPet) window; a middle column of the options,
## Search filters and trade windows with the Global Chatroom at the bottom; right, the Nokia phone.
## Every window is a raster (assets/, PROVENANCE.md), draggable by its title bar (the phone by its
## whole surface), raised by a press, stopped at the Page's edge. Reach it through interface.gd only.
##
## Layout (ticket #63): the desktop is DESKTOP px natively (the layout picture's windows plus a
## MARGIN on every side, measured by template-matching each asset into the picture). The Page's size
## S gives s = min(S.x / D.x, S.y / D.y) for all art. The leftover on the other axis goes to the
## PostPet window: its rect runs to the middle column (right) and to the bottom margin, and it is
## drawn in bands at the uniform scale, only a flat one-pixel column per band and one flat row of its
## picture drawn wider or taller to fill (the same patch technique as the Collection
## viewer's chrome). The middle column and the phone anchor to the right edge; the chat window anchors
## to the bottom edge, the rest to the top. Re-laid out on every resize.
extends ColorRect

const Errors := preload("res://modules/playground_page/errors.gd")
const Data := preload("res://modules/collection_data/interface.gd")
const ROOT := "res://modules/playground_page/"
const WEBSURFER_ASSET := ROOT + "assets/websurfer-window.webp"
const DESKTOP := Vector2(2171, 1185)
const MARGIN := 24.0
# The PostPet picture's bands (source rows) and the column each band stretches at: a column where the
# band has no horizontal step at all (title bar, balloons, the panel right of the stickers, the info
# box right of its text), so every band grows by the same width and the edges stay aligned. Row
# STRETCH_Y (band 3, one pixel, max horizontal-neighbour step 14 across the width) takes the height.
const BANDS := [0, 45, 95, 203, 204, 660, 803]
const BAND_COLUMNS := [246, 344, 730, 730, 730, 703]
const STRETCH_Y_BAND := 3
# Blank content inside the PostPet panel; keep its header, info box, and colorful frame visible.
const POSTPET_BODY := Rect2(126, 143, 603, 547)
# name, file, native position in DESKTOP px, art scale (desktop px per source px), title height in
# desktop px (0: the whole surface drags), anchor ("left" | "right" | "right_bottom"), keyed border
# width in source px (0: no magenta key)
const WINDOWS := [
	["postpet", "postpet.png", Vector2(24, 24), 1.41560, 64.0, "left", 0.0],
	["options", "options.png", Vector2(1253, 24), 0.23921, 30.0, "right", 32.0],
	["filters", "filters.png", Vector2(1253, 238), 0.91402, 31.0, "right", 3.0],
	["trade", "trade.png", Vector2(1247, 508), 0.23730, 31.0, "right", 32.0],
	["chat", "chat.png", Vector2(1266, 898), 0.26358, 33.0, "right_bottom", 32.0],
	["phone", "phone.png", Vector2(1767, 25), 1.41264, 0.0, "right", 0.0],
]

var key := ""
var ticks := 0
var inputs := 0
var factor := 1.0
var action := ""
var windows: Array[Control] = []
var _active: Control
var _start_pointer := Vector2.ZERO
var _start_position := Vector2.ZERO
var data_handle: Variant
var image_fetch: Callable
var saved_body := ColorRect.new()
var saved_list: Control
var gallery_scroll: ScrollContainer
var gallery_overlay: ColorRect
var saved_ids: Array = []
var storage_status := "loading"
var refresh_generation := 0
var show_websurfer := false
var show_gallery := false
var websurfer: Control
var interactive_windows: Array[Control] = []


static func create(deps: Dictionary) -> Dictionary:
	for entry in WINDOWS:
		if not ResourceLoader.exists(ROOT + "assets/" + entry[1]):
			return Errors.err(Errors.ASSET_MISSING, ROOT + "assets/" + entry[1])
	if deps.get("show_websurfer", false) and not ResourceLoader.exists(WEBSURFER_ASSET):
		return Errors.err(Errors.ASSET_MISSING, WEBSURFER_ASSET)
	var page = load(ROOT + "playground_page.gd").new()
	page.key = deps.get("key", "")
	page.data_handle = deps.collection_data
	page.image_fetch = deps.image_fetch
	page.show_websurfer = deps.get("show_websurfer", false)
	page.show_gallery = deps.get("show_gallery", false)
	page.name = "PlaygroundPage"
	page.color = Color.WHITE
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return Errors.ok(page)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR  # the art is scaled; nearest would alias it
	for entry in WINDOWS:
		var texture: Texture2D = load(ROOT + "assets/" + entry[1])
		var window: Control
		if entry[0] == "postpet":
			window = Control.new()
			window.draw.connect(_draw_postpet.bind(window, texture))
		else:
			var rect := TextureRect.new()
			rect.texture = texture
			rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			if entry[6] > 0.0:
				var material := ShaderMaterial.new()
				material.shader = preload("res://modules/playground_page/remove-pink.gdshader")
				material.set_shader_parameter("border_width", entry[6])
				rect.material = material
			window = rect
		window.name = entry[0]
		window.mouse_filter = Control.MOUSE_FILTER_STOP
		window.set_meta("native", texture.get_size())
		add_child(window)
		windows.append(window)
		if entry[0] not in ["phone", "postpet"]:
			var blank := ColorRect.new()
			blank.name = "ClearedInterior"
			blank.color = Color.WHITE
			blank.mouse_filter = Control.MOUSE_FILTER_IGNORE
			window.add_child(blank)
	interactive_windows.assign(windows)
	if show_websurfer:
		websurfer = load(ROOT + "websurfer_window.gd").new()
		websurfer.name = "WebSurfer"
		websurfer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(websurfer)
		interactive_windows.append(websurfer)
	saved_body.name = "SavedWorks"
	saved_body.color = Color.WHITE
	saved_body.mouse_filter = Control.MOUSE_FILTER_STOP
	saved_body.clip_contents = true
	windows[0].add_child(saved_body)
	saved_list = Control.new() if show_gallery else VBoxContainer.new()
	if show_gallery:
		gallery_scroll = ScrollContainer.new()
		gallery_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		gallery_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		gallery_scroll.add_child(saved_list)
		saved_body.add_child(gallery_scroll)
		_build_gallery_overlay()
	else:
		saved_list.add_theme_constant_override("separation", 8)
		saved_body.add_child(saved_list)
	visibility_changed.connect(_refresh_saved)
	resized.connect(_fit)
	_fit()
	_refresh_saved()


func _fit() -> void:
	action = ""
	factor = minf(size.x / DESKTOP.x, size.y / DESKTOP.y)
	var s := factor
	var right_of_postpet := 0.0
	for index in WINDOWS.size():
		var entry: Array = WINDOWS[index]
		var window := windows[index]
		var native: Vector2 = window.get_meta("native") * float(entry[3])  # desktop px
		var at: Vector2 = entry[2]
		window.set_meta("drag_height", entry[4] * s if entry[4] > 0.0 else INF)
		match entry[5]:
			"left":
				window.position = at * s
				right_of_postpet = at.x + native.x
			"right":
				window.position = Vector2(size.x - (DESKTOP.x - at.x) * s, at.y * s)
			"right_bottom":
				window.position = Vector2(size.x - (DESKTOP.x - at.x) * s, size.y - (DESKTOP.y - at.y) * s)
		window.size = native * s
		var blank := window.get_node_or_null("ClearedInterior") as ColorRect
		if blank != null:
			var inset := maxf(2.0, float(entry[6]) * float(entry[3]) * s)
			var top := float(window.get_meta("drag_height"))
			blank.position = Vector2(inset, top)
			blank.size = (window.size - Vector2(inset * 2.0, top + inset)).max(Vector2.ZERO)
	# the main window takes the leftover: to the middle column on the right, to the margin at the bottom
	var postpet := windows[0]
	var right := size.x - (DESKTOP.x - right_of_postpet) * s
	var bottom := size.y - MARGIN * s
	postpet.size = Vector2(right, bottom) - postpet.position
	postpet.queue_redraw()
	var postpet_scale: float = WINDOWS[0][3] * s
	var postpet_source: Vector2 = postpet.get_meta("native")
	saved_body.position = POSTPET_BODY.position * postpet_scale
	var lower_right_inset := postpet_source - POSTPET_BODY.end
	saved_body.size = (postpet.size - saved_body.position - lower_right_inset * postpet_scale).max(Vector2.ZERO)
	if show_gallery:
		gallery_scroll.position = Vector2(10 * s, 8 * s)
		gallery_scroll.size = saved_body.size - Vector2(20 * s, 16 * s)
		saved_list.custom_minimum_size.x = gallery_scroll.size.x
		_fit_gallery_tiles()
		if gallery_overlay != null:
			gallery_overlay.position = Vector2(12 * s, 10 * s)
			gallery_overlay.size = saved_body.size - Vector2(24 * s, 20 * s)
			_layout_gallery_overlay()
	else:
		saved_list.position = Vector2(10 * s, 8 * s)
		saved_list.size = saved_body.size - Vector2(20 * s, 16 * s)
		for child in saved_list.get_children():
			child.custom_minimum_size.x = saved_list.size.x
	if websurfer != null:
		var websurfer_height := minf(780.0, size.y * 0.78)
		websurfer.size = Vector2(websurfer_height * 1616.0 / 1407.0, websurfer_height)
		websurfer.position = Vector2(size.x - websurfer.size.x - MARGIN * s, (size.y - websurfer.size.y) * 0.5)


func _refresh_saved() -> void:
	if not is_visible_in_tree() or data_handle == null:
		return
	if show_gallery:
		_refresh_gallery()
		return
	refresh_generation += 1
	var current := refresh_generation
	storage_status = "loading"
	var started := Data.saved(data_handle, func(result: Dictionary) -> void:
		if current != refresh_generation or not is_visible_in_tree() or not is_instance_valid(saved_list):
			return
		for child in saved_list.get_children():
			child.queue_free()
		saved_ids.clear()
		if not result.ok:
			storage_status = "error"
			saved_list.add_child(_saved_label("Saved works unavailable"))
			return
		storage_status = "ready"
		if result.value.items.is_empty():
			saved_list.add_child(_saved_label("No saved RISD works yet"))
			return
		for item in result.value.items:
			saved_ids.append(item.artwork.id)
			saved_list.add_child(_saved_card(item.artwork)))
	if not started.ok and current == refresh_generation and is_visible_in_tree():
		storage_status = "error"


func _refresh_gallery() -> void:
	refresh_generation += 1
	var current := refresh_generation
	storage_status = "loading"
	var query := {"q": "", "category": "Painting", "sort": "title_asc", "has_image": true, "page": 1}
	var started := Data.search(data_handle, query, func(result: Dictionary) -> void:
		if not _gallery_current(current):
			return
		if not result.ok:
			_show_gallery_error()
			return
		var items: Array = result.value.items.duplicate(true)
		if result.value.total <= items.size():
			_show_gallery(current, items)
			return
		var next_query := query.duplicate()
		next_query.page = 2
		next_query.snapshot = result.value.corpus.snapshot
		var next_started := Data.search(data_handle, next_query, func(next_result: Dictionary) -> void:
			if not _gallery_current(current):
				return
			if next_result.ok:
				items.append_array(next_result.value.items)
			_show_gallery(current, items))
		if not next_started.ok:
			_show_gallery(current, items))
	if not started.ok and _gallery_current(current):
		_show_gallery_error()


func _gallery_current(generation: int) -> bool:
	return generation == refresh_generation and is_visible_in_tree() and is_instance_valid(saved_list)


func _show_gallery(generation: int, items: Array) -> void:
	if not _gallery_current(generation):
		return
	for child in saved_list.get_children():
		saved_list.remove_child(child)
		child.queue_free()
	saved_ids.clear()
	storage_status = "ready"
	for artwork in items.slice(0, 25):
		saved_ids.append(artwork.id)
		saved_list.add_child(_gallery_image(artwork))
	_fit_gallery_tiles()


func _show_gallery_error() -> void:
	storage_status = "error"
	for child in saved_list.get_children():
		saved_list.remove_child(child)
		child.queue_free()
	saved_list.add_child(_saved_label("Paintings unavailable"))


func _gallery_image(artwork: Dictionary) -> Control:
	var cell := PanelContainer.new()
	cell.clip_contents = true
	cell.mouse_filter = Control.MOUSE_FILTER_STOP
	cell.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var surface := StyleBoxFlat.new()
	surface.bg_color = Color.WHITE
	cell.add_theme_stylebox_override("panel", surface)
	cell.set_meta("artwork", artwork)
	cell.set_meta("aspect", maxf(0.2, float(artwork.image.get("width", 1)) / maxf(1.0, float(artwork.image.get("height", 1)))))
	var image := TextureRect.new()
	image.name = "SavedImage"
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image.tooltip_text = "%s — %s" % [artwork.title, ", ".join(artwork.makers)]
	cell.add_child(image)
	var hover := ColorRect.new()
	hover.name = "HoverMetadata"
	hover.color = Color(0.04, 0.05, 0.06, 0.82)
	hover.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hover.visible = false
	cell.add_child(hover)
	var maker := "Unknown maker" if artwork.makers.is_empty() else ", ".join(artwork.makers)
	var caption := _saved_label("%s\n%s%s" % [artwork.title if artwork.title != "" else "Untitled", maker,
		" · " + artwork.dating if artwork.dating != "" else ""])
	caption.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 8)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.add_theme_color_override("font_color", Color.WHITE)
	caption.add_theme_font_size_override("font_size", 12)
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hover.add_child(caption)
	cell.mouse_entered.connect(func() -> void: hover.visible = true)
	cell.mouse_exited.connect(func() -> void: hover.visible = false)
	cell.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_expand_gallery_artwork(artwork)
			get_viewport().set_input_as_handled())
	_load_saved_image(artwork.image, image, null)
	return cell


func _fit_gallery_tiles() -> void:
	if gallery_scroll == null:
		return
	var columns := 2 if gallery_scroll.size.x < 520 else 3
	var gap := maxf(6.0, 8.0 * factor)
	var width := floorf((gallery_scroll.size.x - gap * (columns - 1)) / columns)
	var heights: Array[float] = []
	heights.resize(columns)
	heights.fill(0.0)
	for child in saved_list.get_children():
		if not child.has_meta("aspect"):
			continue
		var column := heights.find(heights.min())
		var height := floorf(width / float(child.get_meta("aspect")))
		child.position = Vector2(column * (width + gap), heights[column])
		child.size = Vector2(width, height)
		child.custom_minimum_size = child.size
		heights[column] += height + gap
	saved_list.custom_minimum_size = Vector2(gallery_scroll.size.x, heights.max() if not heights.is_empty() else 0.0)


func _build_gallery_overlay() -> void:
	gallery_overlay = ColorRect.new()
	gallery_overlay.name = "ExpandedArtwork"
	gallery_overlay.color = Color.WHITE
	gallery_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	gallery_overlay.visible = false
	saved_body.add_child(gallery_overlay)
	gallery_overlay.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			gallery_overlay.visible = false
			get_viewport().set_input_as_handled())


func _expand_gallery_artwork(artwork: Dictionary) -> void:
	for child in gallery_overlay.get_children():
		child.queue_free()
	var image := TextureRect.new()
	image.name = "ExpandedImage"
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gallery_overlay.add_child(image)
	var maker := "Unknown maker" if artwork.makers.is_empty() else ", ".join(artwork.makers)
	var caption := _saved_label("%s — %s%s\nClick to close" % [artwork.title if artwork.title != "" else "Untitled", maker,
		" · " + artwork.dating if artwork.dating != "" else ""])
	caption.name = "ExpandedCaption"
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gallery_overlay.add_child(caption)
	_layout_gallery_overlay()
	gallery_overlay.visible = true
	gallery_overlay.move_to_front()
	_load_saved_image(artwork.image, image, null)


func _layout_gallery_overlay() -> void:
	if gallery_overlay == null:
		return
	var image := gallery_overlay.get_node_or_null("ExpandedImage") as TextureRect
	if image != null:
		image.position = Vector2(10, 10)
		image.size = gallery_overlay.size - Vector2(20, 64)
	var caption := gallery_overlay.get_node_or_null("ExpandedCaption") as Label
	if caption != null:
		caption.position = Vector2(10, gallery_overlay.size.y - 50)
		caption.size = Vector2(gallery_overlay.size.x - 20, 42)


func _saved_label(value: String) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_color_override("font_color", Color("243e58"))
	label.add_theme_font_size_override("font_size", 16)
	return label


func _saved_card(artwork: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var image_column := VBoxContainer.new()
	row.add_child(image_column)
	var image := TextureRect.new()
	image.name = "SavedImage"
	image.custom_minimum_size = Vector2(110, 82)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image_column.add_child(image)
	var unavailable := _saved_label("IMAGE UNAVAILABLE")
	unavailable.name = "SavedImageUnavailable"
	unavailable.visible = false
	unavailable.add_theme_font_size_override("font_size", 11)
	image_column.add_child(unavailable)
	var maker := "Unknown maker" if artwork.makers.is_empty() else ", ".join(artwork.makers)
	var label := _saved_label("%s\n%s\n%s\n%s" % [artwork.title if artwork.title != "" else "Untitled", maker,
			artwork.id, artwork.credit if artwork.credit != "" else "Credit unavailable"])
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	if artwork.image == null:
		unavailable.visible = true
	else:
		_load_saved_image(artwork.image, image, unavailable)
	return row


func _load_saved_image(manifest: Dictionary, target: TextureRect, unavailable: Label) -> void:
	var page_id := get_instance_id()
	var target_id := target.get_instance_id()
	var unavailable_id := unavailable.get_instance_id() if unavailable != null else 0
	image_fetch.call(manifest.sha256, func(result: Dictionary) -> void:
		var live_page := instance_from_id(page_id) as Control
		var live_target := instance_from_id(target_id) as TextureRect
		var live_unavailable := instance_from_id(unavailable_id) as Label
		if live_page == null or not live_page.is_visible_in_tree() or live_target == null or (unavailable_id != 0 and live_unavailable == null):
			return
		if not result.ok:
			if live_unavailable != null:
				live_unavailable.visible = true
			return
		var context := HashingContext.new()
		context.start(HashingContext.HASH_SHA256)
		context.update(result.value)
		if context.finish().hex_encode() != manifest.sha256:
			if live_unavailable != null:
				live_unavailable.visible = true
			return
		var decoded := Image.new()
		var status := decoded.load_jpg_from_buffer(result.value) if manifest.mime == "image/jpeg" else (decoded.load_png_from_buffer(result.value) if manifest.mime == "image/png" else decoded.load_webp_from_buffer(result.value))
		if status == OK:
			live_target.texture = ImageTexture.create_from_image(decoded)
		elif live_unavailable != null:
			live_unavailable.visible = true)


## The PostPet picture band by band at the uniform scale; in each band only its one-pixel column takes
## the extra width, and only the one-pixel band STRETCH_Y_BAND takes the extra height.
func _draw_postpet(window: Control, texture: Texture2D) -> void:
	var src: Vector2 = texture.get_size()
	var k: float = WINDOWS[0][3] * factor
	var extra: Vector2 = (window.size - src * k).max(Vector2.ZERO)
	var dy := 0.0
	for band in BAND_COLUMNS.size():
		var top: float = BANDS[band]
		var rows: float = BANDS[band + 1] - top
		var h: float = rows * k + (extra.y if band == STRETCH_Y_BAND else 0.0)
		var xs := [0.0, float(BAND_COLUMNS[band]), BAND_COLUMNS[band] + 1.0, src.x]
		var dx := 0.0
		for i in 3:
			var w: float = (xs[i + 1] - xs[i]) * k + (extra.x if i == 1 else 0.0)
			window.draw_texture_rect_region(texture, Rect2(dx, dy, w, h), Rect2(xs[i], top, xs[i + 1] - xs[i], rows))
			dx += w
		dy += h


## A press raises the topmost window under the pointer; on its title bar it starts a drag.
func _input(event: InputEvent) -> void:
	inputs += 1
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var pointer := make_canvas_position_local(event.position)
		if not event.pressed:
			if action.is_empty():
				return
			action = ""
			_active = null
		else:
			_active = null
			for window in interactive_windows:
				if window.get_rect().has_point(pointer) and (_active == null or window.get_index() > _active.get_index()):
					_active = window
			if _active == null:
				return
			move_child(_active, -1)
			if pointer.y - _active.position.y >= float(_active.get_meta("drag_height")):
				return
			action = "drag"
			_start_pointer = pointer
			_start_position = _active.position
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and not action.is_empty():
		var delta: Vector2 = make_canvas_position_local(event.position) - _start_pointer
		_active.position = (_start_position + delta).clamp(Vector2.ZERO, (size - _active.size).max(Vector2.ZERO))
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	ticks += 1


func state() -> Dictionary:
	var list := []
	for window in windows:
		var drag: float = window.get_meta("drag_height")
		list.append({"name": String(window.name), "rect": window.get_rect(), "order": window.get_index(),
				"drag_height": -1.0 if is_inf(drag) else drag})
	list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.order < b.order)
	var saved_images_loaded := 0
	var saved_images_unavailable := 0
	for image in saved_list.find_children("SavedImage", "TextureRect", true, false):
		if image.texture != null:
			saved_images_loaded += 1
	for unavailable in saved_list.find_children("SavedImageUnavailable", "Label", true, false):
		if unavailable.visible:
			saved_images_unavailable += 1
	return Errors.ok({"key": key, "ticks": ticks, "inputs": inputs, "size": size, "factor": factor,
			"desktop": DESKTOP, "margin": MARGIN, "action": action, "windows": list,
			"saved_ids": saved_ids.duplicate(), "saved_images_loaded": saved_images_loaded,
			"saved_images_unavailable": saved_images_unavailable,
			"storage_status": storage_status})
