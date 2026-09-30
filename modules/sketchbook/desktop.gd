## The Sketchbook Tenant: the painting-tool prototype's desktop (variant A, "Sidecar studio") — the
## Mixbox paintbox window with its cat brush rest on the left, the native sketchbook window on the
## right — laid out from the Tenant's own size by the fill rule of ticket #63. Both windows drag by
## their title bars and raise on click; the brush leaves the rest while the pointer is over the palette
## or the page and goes back to it otherwise. Reach it through interface.gd only.
##
## Ported from figma-ui-ux-qwen-pipeline prototype/painting-tool-mixbox @ d2faa30
## viewer-godot/scripts/desktop.gd (enable_paint_prototype("A"), _sync_brush_rest, the drag and raise).
## Left behind: the catalogue and viewer windows (the 3D Viewer Tenant), the A/B/C switcher and its
## Left / Right key cycling, the ?variant / ?perf / ?turn-seconds levers, the perf telemetry and the
## JavaScriptBridge publishes. Changed: the composition is cropped to the two windows with the
## prototype's own right and bottom margins (60, 52), scaled uniformly to the Page and the leftover
## axis given to the book (_fit); pointer positions are made local to the desktop.
extends Control

const Errors := preload("res://modules/sketchbook/errors.gd")
const Data := preload("res://modules/collection_data/interface.gd")
const SculptureViewer := preload("res://modules/sculpture_viewer/interface.gd")
const GlobalChatroom := preload("res://modules/sketchbook/global_chatroom.gd")

const ROOT := "res://modules/sketchbook/"
const GOLD_FRAME := preload("res://modules/sketchbook/assets/gold-frame/frame.png")
const REFERENCE_PAINTING := preload("res://modules/sketchbook/assets/monet-reference.png")
const GOLD_FRAME_SIZE := Vector2(605, 732)
## The native composition: variant A's windows (paintbox 170,345 550x575; book 750,365 630x545 on the
## prototype's 1440x972 canvas) moved in to the prototype's right/bottom margins, the book 10 px taller
## so both windows share the bottom edge and the composition's margin is NATIVE_MARGIN on every side.
const NATIVE_MARGIN := Vector2(60, 52)
const DESKTOP_SIZE := Vector2(1330, 1060)  # tall enough for the owner's arrangement of 2026-09-25
const REFERENCE_SLOT := Rect2(397, 25, 620, 446)  # owner layout 2026-09-25: the framed painting large, top middle
const PAINTBOX_SLOT := Rect2(60, 235, 360, 575)
const ANRI_PAINTBOX_SLOT := Rect2(8, 28, 360, 360.0 * 3072.0 / 1484.0)
const FRAMED_PAINTING_SLOT := Rect2(397, 520, 228.0, 276.0)
const BOOK_SLOT := Rect2(640, 494, 630, 555)  # accepted #129 proportions beside the painting
const REQUIRED := [
	"ro-top-left.png",
	"ro-top-mid.png",
	"ro-top-right.png",
	"ro-left.png",
	"ro-right.png",
	"ro-bottom-left.png",
	"ro-bottom-mid.png",
	"ro-bottom-right.png",
	"ro-btn-prev.png",
	"ro-btn-prev-disabled.png",
	"ro-btn-next.png",
	"sketchbook-page-v005-soft-384.png",
	"paintbox/palette-white.png",
	"paintbox/watercolor-brush.png",
	"paintbox/cat-brush-rest.png",
	"paintbox/brush-tip.gdshader",
	"paintbox/anri-interior-muse.webp",
	"paintbox/anri-title-reference.png",
	"tldraw-controls/button-normal-muse.png",
	"tldraw-controls/button-hover-muse.png",
	"tldraw-controls/button-selected-muse.png",
	"tldraw-controls/titlebar-muse.png",
]

var key := ""
var ticks := 0
var inputs := 0
var desktop := Control.new()
var windows: Array[Control] = []
var sketchbook: Control
var paintbox: Control
var dragged_window: Control
var drag_offset := Vector2.ZERO
var _slots := {}  # window -> the Rect2 the last _fit gave it
var data_handle: Variant
var image_fetch: Callable
var reference_panel := PanelContainer.new()
var reference_list := HBoxContainer.new()
var reference_art: Control
var viewer_host := Control.new()
var global_chatroom: Control
var tldraw_controls: Control
var painting_flow: Control
var saved_ids: Array = []
var selected_reference := ""
var storage_status := "loading"
var refresh_generation := 0
var anri_prototype := true


static func create(deps: Dictionary) -> Dictionary:
	for name in REQUIRED:
		if not ResourceLoader.exists(ROOT + "assets/" + name):
			return Errors.err(Errors.ASSET_MISSING, ROOT + "assets/" + name)
	if not ResourceLoader.exists(ROOT + "mixbox/mixbox.gd"):
		return Errors.err(Errors.ASSET_MISSING, ROOT + "mixbox/mixbox.gd")
	var flow: Dictionary = load(ROOT + "painting_flow.gd").create()
	if not flow.ok:
		return flow
	var t = load(ROOT + "desktop.gd").new()
	t.painting_flow = flow.value
	t.key = deps.get("key", "")
	t.data_handle = deps.collection_data
	t.image_fetch = deps.image_fetch
	t.name = "Sketchbook"
	t.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return Errors.ok(t)


func _ready() -> void:
	# The prototype's project filtered linearly; this project's default is nearest. Children inherit.
	texture_filter = TEXTURE_FILTER_LINEAR
	desktop.name = "desktop"
	desktop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(desktop)
	var paper := ColorRect.new()
	paper.color = Color.WHITE
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	paper.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	desktop.add_child(paper)
	sketchbook = load(ROOT + "sketchbook_window.gd").new()
	sketchbook.name = "sketchbook-window"
	desktop.add_child(sketchbook)
	windows.append(sketchbook)
	sketchbook.title_bar.gui_input.connect(_drag_handle_input.bind(sketchbook))
	paintbox = load(ROOT + "paintbox.gd").new()
	paintbox.name = "paintbox-window"
	paintbox.set_anri_mode(anri_prototype)
	desktop.add_child(paintbox)
	windows.append(paintbox)
	paintbox.title_bar.gui_input.connect(_drag_handle_input.bind(paintbox))
	paintbox.color_changed.connect(sketchbook.surface.set_ink_color)
	paintbox.pointer_changed.connect(_sync_brush_rest)
	sketchbook.surface.pointer_changed.connect(_sync_brush_rest)
	sketchbook.surface.set_ink_color(paintbox.brush_color)
	paintbox.set_smear_variant("A")
	tldraw_controls = load(ROOT + "tldraw_controls_prototype.gd").new()
	tldraw_controls.configure(sketchbook.surface)
	paintbox.tool_selected.connect(tldraw_controls._select_tool)
	desktop.add_child(tldraw_controls)
	windows.append(tldraw_controls)
	tldraw_controls.title_bar.gui_input.connect(_drag_handle_input.bind(tldraw_controls))
	var embedded := SculptureViewer.embedded_viewer()
	if embedded.ok:
		viewer_host.name = "embedded-3d-viewer-window"
		viewer_host.mouse_filter = Control.MOUSE_FILTER_STOP
		viewer_host.clip_contents = true
		viewer_host.add_child(embedded.value)
		var viewer_drag_strip := Control.new()
		viewer_drag_strip.position = Vector2(12, 4)
		viewer_drag_strip.size = Vector2(386, 28)
		viewer_drag_strip.mouse_default_cursor_shape = Control.CURSOR_DRAG
		viewer_drag_strip.gui_input.connect(func(event): _drag_handle_input(event, viewer_host))
		viewer_host.add_child(viewer_drag_strip)
		desktop.add_child(viewer_host)
		windows.append(viewer_host)
	if ResourceLoader.exists(GlobalChatroom.CHAT_ASSET):
		global_chatroom = GlobalChatroom.new()
		global_chatroom.name = "global-chatroom"
		global_chatroom.mouse_filter = Control.MOUSE_FILTER_STOP
		global_chatroom.gui_input.connect(func(event): _drag_handle_input(event, global_chatroom))
		desktop.add_child(global_chatroom)
		windows.append(global_chatroom)
	# The original framed painting and the Finder-like viewer are separate movable windows.
	reference_panel.name = "framed-painting-window"
	reference_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	reference_panel.clip_contents = false
	reference_panel.gui_input.connect(_drag_handle_input.bind(reference_panel))
	reference_panel.add_theme_stylebox_override("panel", _reference_style(Color(1, 1, 1, 0)))
	desktop.add_child(reference_panel)
	reference_art = _framed_painting()
	reference_panel.add_child(reference_art)
	reference_list.add_theme_constant_override("separation", 10)
	reference_list.visible = false
	reference_panel.add_child(reference_list)
	windows.append(reference_panel)
	painting_flow.name = "painting-flow-window"
	desktop.add_child(painting_flow)
	windows.append(painting_flow)
	painting_flow.title_bar.gui_input.connect(_drag_handle_input.bind(painting_flow))
	_sync_brush_rest()
	visibility_changed.connect(_on_visibility_changed)
	visibility_changed.connect(_refresh_references)
	resized.connect(_fit)
	_fit()
	_refresh_references()
	for window in windows:
		_add_scale_grip(window)


func _sync_brush_rest() -> void:
	paintbox.set_brush_active(paintbox.hovering or sketchbook.surface.hovering)


## Hidden with the pointer over the palette or the page: give the arrow back (both hide it) and park
## the brush, since the frozen Page gets no mouse-exit.
func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		return
	Input.set_custom_mouse_cursor(
		Engine.get_meta("arrow_cursor") if Engine.has_meta("arrow_cursor") else null,
		Input.CURSOR_ARROW,
		(
			Engine.get_meta("arrow_cursor").get_meta("tip")
			if Engine.has_meta("arrow_cursor")
			else Vector2.ZERO
		)
	)  # hover-glow prototype
	if paintbox.hovering:
		paintbox.hovering = false
		paintbox.brush_cursor.visible = false
	_sync_brush_rest()


## The fill rule (ticket #63). S is this Tenant's size, D the native composition. All art scales by
## s = min(S.x / D.x, S.y / D.y); the desktop's logical size becomes S / s, so the leftover axis E
## goes to the book window (wider or taller pages) while the paintbox keeps its native size, anchored
## to the top-left corner beside it. A window the user dragged or resized keeps that change
## relative to its slot, clamped inside the desktop.
func _fit() -> void:
	if size.x < 2 or size.y < 2:
		return
	var s := minf(size.x / DESKTOP_SIZE.x, size.y / DESKTOP_SIZE.y)
	var logical := size / s
	var extra := logical - DESKTOP_SIZE
	desktop.scale = Vector2(s, s)
	desktop.position = Vector2.ZERO
	desktop.size = logical
	if get_meta("windows_adjusted", false):
		set_meta("scaling", false)
		for window in windows:
			window.scale = (
				Vector2.ONE
				* minf(
					window.scale.x,
					minf(desktop.size.x / window.size.x, desktop.size.y / window.size.y)
				)
			)
			window.position = window.position.clamp(
				Vector2.ZERO, (desktop.size - window.size * window.scale).max(Vector2.ZERO)
			)
		return
	_place(paintbox, ANRI_PAINTBOX_SLOT if anri_prototype else PAINTBOX_SLOT)
	_place(sketchbook, Rect2(BOOK_SLOT.position, BOOK_SLOT.size + Vector2(extra.x * 0.25, 0)))
	# Reuse the tested viewer at a fixed upper-right scale; its own 800x680 scene stays intact.
	viewer_host.position = Vector2(desktop.size.x - 430, 20)
	viewer_host.size = Vector2(410, 350)
	if viewer_host.get_child_count() > 0:
		var embedded: Control = viewer_host.get_child(0)
		embedded.scale = Vector2(0.5125, 0.5125)
	if global_chatroom != null:
		global_chatroom.position = Vector2(desktop.size.x - 337, 370)  # just under the viewer
		global_chatroom.size = Vector2(320, 150)
	_place(reference_panel, FRAMED_PAINTING_SLOT)
	reference_list.position = Vector2(12, 12)
	reference_list.size = reference_panel.size - Vector2(24, 24)
	_place(painting_flow, REFERENCE_SLOT)
	_place(tldraw_controls, Rect2(14, 865, 310, 178) if anri_prototype else Rect2(90, 70, 250, 184))  # bottom left


func _reference_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("87a8c5")
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	return style


func _framed_painting() -> Control:
	var atlas := AtlasTexture.new()
	atlas.atlas = REFERENCE_PAINTING
	atlas.region = Rect2(Vector2(24, 24), REFERENCE_PAINTING.get_size() - Vector2(48, 48))
	var painting := TextureRect.new()
	painting.texture = atlas
	painting.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	painting.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	painting.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var frame := TextureRect.new()
	frame.name = "gold-frame"
	frame.texture = GOLD_FRAME
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var holder := Control.new()
	holder.name = "framed-reference"
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	holder.add_child(painting)
	holder.add_child(frame)
	holder.resized.connect(
		func() -> void:
			var k := holder.size.y / GOLD_FRAME_SIZE.y
			var near := Vector2(143, 130) * k
			painting.position = near
			painting.size = Vector2(323, 472) * k
			frame.position = Vector2.ZERO
			frame.size = GOLD_FRAME_SIZE * k
	)
	return holder


func _refresh_references() -> void:
	if not is_visible_in_tree() or data_handle == null:
		return
	refresh_generation += 1
	var current := refresh_generation
	storage_status = "loading"
	var started := Data.saved(
		data_handle,
		func(result: Dictionary) -> void:
			if (
				current != refresh_generation
				or not is_visible_in_tree()
				or not is_instance_valid(reference_list)
			):
				return
			for child in reference_list.get_children():
				child.queue_free()
			saved_ids.clear()
			if not result.ok:
				storage_status = "error"
				reference_list.add_child(_reference_label("Saved references unavailable"))
				return
			storage_status = "ready"
			reference_panel.visible = true
			if result.value.items.is_empty():
				reference_list.add_child(
					_reference_label("Save a RISD artwork in Collection to use it as a reference")
				)
				return
			for item in result.value.items:
				saved_ids.append(item.artwork.id)
				reference_list.add_child(_reference_card(item.artwork))
	)
	if not started.ok and current == refresh_generation and is_visible_in_tree():
		storage_status = "error"


func _reference_label(value: String) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_color_override("font_color", Color("243e58"))
	label.add_theme_font_size_override("font_size", 16)
	return label


func _reference_card(artwork: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.set_meta("artwork_id", artwork.id)
	card.custom_minimum_size = Vector2(270, 145)
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.add_theme_stylebox_override(
		"panel",
		_reference_style(Color("dcecff") if artwork.id == selected_reference else Color.WHITE)
	)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	card.add_child(row)
	var image_column := VBoxContainer.new()
	row.add_child(image_column)
	var image := TextureRect.new()
	image.name = "ReferenceImage"
	image.custom_minimum_size = Vector2(110, 120)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image_column.add_child(image)
	var unavailable := _reference_label("IMAGE UNAVAILABLE")
	unavailable.name = "ReferenceImageUnavailable"
	unavailable.visible = false
	unavailable.add_theme_font_size_override("font_size", 11)
	image_column.add_child(unavailable)
	var maker := "Unknown maker" if artwork.makers.is_empty() else ", ".join(artwork.makers)
	var label := _reference_label(
		"%s\n%s\n%s" % [artwork.title if artwork.title != "" else "Untitled", maker, artwork.id]
	)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	card.gui_input.connect(
		func(event: InputEvent) -> void:
			if (
				event is InputEventMouseButton
				and event.pressed
				and event.button_index == MOUSE_BUTTON_LEFT
			):
				selected_reference = artwork.id
				_refresh_references()
	)
	if artwork.image != null:
		_load_reference_image(artwork.image, image, unavailable)
	else:
		unavailable.visible = true
	return card


func _load_reference_image(manifest: Dictionary, target: TextureRect, unavailable: Label) -> void:
	var page_id := get_instance_id()
	var target_id := target.get_instance_id()
	var unavailable_id := unavailable.get_instance_id()
	image_fetch.call(
		manifest.sha256,
		func(result: Dictionary) -> void:
			var live_page := instance_from_id(page_id) as Control
			var live_target := instance_from_id(target_id) as TextureRect
			var live_unavailable := instance_from_id(unavailable_id) as Label
			if (
				live_page == null
				or not live_page.is_visible_in_tree()
				or live_target == null
				or live_unavailable == null
			):
				return
			if not result.ok:
				live_unavailable.visible = true
				return
			var context := HashingContext.new()
			context.start(HashingContext.HASH_SHA256)
			context.update(result.value)
			if context.finish().hex_encode() != manifest.sha256:
				live_unavailable.visible = true
				return
			var decoded := Image.new()
			var status := (
				decoded.load_jpg_from_buffer(result.value)
				if manifest.mime == "image/jpeg"
				else (
					decoded.load_png_from_buffer(result.value)
					if manifest.mime == "image/png"
					else decoded.load_webp_from_buffer(result.value)
				)
			)
			if status == OK:
				live_target.texture = ImageTexture.create_from_image(decoded)
			else:
				live_unavailable.visible = true
	)


func _place(window: Control, slot: Rect2) -> void:
	var moved := Vector2.ZERO
	var grown := Vector2.ZERO
	if _slots.has(window):
		moved = window.position - _slots[window].position
		grown = window.size - _slots[window].size
	_slots[window] = slot
	window.size = (slot.size + grown).max(window.custom_minimum_size)
	window.position = (slot.position + moved).clamp(
		_margin_low(), (desktop.size - window.size).max(Vector2.ZERO)
	)


func _drag_handle_input(event: InputEvent, window: Control) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		dragged_window = window
		drag_offset = desktop.make_canvas_position_local(event.global_position) - window.position
		desktop.move_child(window, -1)
		window.accept_event()


func _process(_delta: float) -> void:
	ticks += 1


## Window drag and raise, by the mouse, in the desktop's own pixels (the prototype's desktop.gd _input,
## less the variant key cycling).
func _input(event: InputEvent) -> void:
	inputs += 1
	if dragged_window != null:
		if event is InputEventMouseMotion:
			var limit := (desktop.size - dragged_window.size * dragged_window.scale).max(
				Vector2.ZERO
			)
			dragged_window.position = (
				(desktop.make_canvas_position_local(event.position) - drag_offset)
				. clamp(_margin_low(), limit)
			)
			get_viewport().set_input_as_handled()
		elif (
			event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and not event.pressed
		):
			dragged_window = null
			get_viewport().set_input_as_handled()
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var pointer := desktop.make_canvas_position_local(event.position)
		for index in range(windows.size() - 1, -1, -1):
			var window := windows[index]
			if (
				window.visible
				and Rect2(window.position, window.size * window.scale).has_point(pointer)
			):
				desktop.move_child(window, -1)
				windows.erase(window)
				windows.append(window)
				break


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		dragged_window = null


## A Control's rect in global pixels, its own and its ancestors' scale applied.
static func _global_rect(c: Control) -> Rect2:
	return c.get_global_transform() * Rect2(Vector2.ZERO, c.size)


## The paintbox's palette-space rects in global pixels: the image, the 32 wells' hit boxes, the 4 trays.
func _paintbox_rects() -> Dictionary:
	var xf: Transform2D = paintbox.get_global_transform()
	var img: Rect2 = paintbox.image_rect
	var wells := []
	var hit: Vector2 = paintbox._active_well_hit()
	for row in range(2):
		for column in range(paintbox._well_column_count()):
			var c: Vector2 = paintbox._well_center(row, column)
			wells.append(xf * Rect2(img.position + (c - hit) * img.size, hit * 2.0 * img.size))
	var trays := []
	for tray in paintbox._active_trays():
		trays.append(xf * Rect2(img.position + tray.position * img.size, tray.size * img.size))
	return {"palette_rect": xf * img, "wells": wells, "trays": trays}


## The harness probe (the Tenant contract): the desktop, the book's state and the paintbox's.
func state() -> Dictionary:
	var s: Dictionary = sketchbook.qa_state()
	var pointer: Dictionary = s.pointer
	var page: Rect2 = sketchbook.page_rect()
	var p: Dictionary = paintbox.qa_state()
	var chat: Dictionary = (
		global_chatroom.qa_state()
		if global_chatroom != null and global_chatroom.has_method("qa_state")
		else {}
	)
	var reference_cards := []
	for child in reference_list.get_children():
		if child is PanelContainer and child.has_meta("artwork_id"):
			var reference_image := child.find_child("ReferenceImage", true, false) as TextureRect
			var unavailable := child.find_child("ReferenceImageUnavailable", true, false) as Label
			reference_cards.append(
				{
					"id": child.get_meta("artwork_id"),
					"rect": _global_rect(child),
					"has_texture": reference_image != null and reference_image.texture != null,
					"image_unavailable": unavailable != null and unavailable.visible
				}
			)
	s.erase("pointer")
	s.erase("page_rect")
	s.merge(
		{
			"key": key,
			"ticks": ticks,
			"inputs": inputs,
			"size": size,
			"desktop_scale": desktop.scale.x,
			"desktop_logical": desktop.size,
			"front_window": windows.back().name,
			"dragging": dragged_window != null,
			"window_rect": _global_rect(sketchbook),
			"title_rect": _global_rect(sketchbook.title_bar),
			"page_rect": sketchbook.get_global_transform() * page,
			"window_visible": sketchbook.visible,
			"controls":
			{
				"previous": _global_rect(sketchbook.previous_button),
				"next": _global_rect(sketchbook.next_button)
			},
			"drawing": pointer.drawing,
			"hovering": pointer.hovering,
			"last_stroke_points": pointer.last_stroke_points,
			"ink_color": pointer.ink_color,
			"last_stroke_color": pointer.last_stroke_color,
			"brush_cursor_visible": sketchbook.surface.pencil.visible,
			"static_update_mode": sketchbook.surface._static_viewport.render_target_update_mode,
			"face_update_mode": sketchbook.face_viewport.render_target_update_mode,
			"paintbox_rect": _global_rect(paintbox),
			"paintbox_title_rect": _global_rect(paintbox.title_bar),
			"rest_rect": _global_rect(paintbox.brush_rest),
			"parked_brush_rect": _global_rect(paintbox.parked_brush),
			"brush_parked": p.brush_parked,
			"brush_color": p.brush_color,
			"brush_tip_color": p.brush_tip_color,
			"palette_hovering": p.hovering,
			"palette_cursor_visible": paintbox.brush_cursor.visible,
			"mix_count": p.mix_count,
			"paint_pixels": p.paint_pixels,
			"smear_variant": p.smear_variant,
			"mixbox": p.mixbox,
			"saved_ids": saved_ids.duplicate(),
			"selected_reference": selected_reference,
			"storage_status": storage_status,
			"reference_rect": _global_rect(reference_panel),
			"reference_cards": reference_cards,
			"reference_visible": reference_panel.visible,
			"saved_cards_visible": reference_list.visible,
			"framed_painting_rect": _global_rect(reference_panel),
			"framed_painting_asset": REFERENCE_PAINTING.resource_path,
			"gold_frame_asset": GOLD_FRAME.resource_path,
			"palette_asset": paintbox.ANRI_INTERIOR.resource_path,
			"drawing_tool": sketchbook.surface.tool,
			"painting_viewer": painting_flow.qa_state(),
			"painting_viewer_rect": _global_rect(painting_flow),
			"painting_title_rect": _global_rect(painting_flow.title_bar),
			"chat_text_posts": chat.get("text_posts", 0),
			"chat_image_posts": chat.get("image_posts", 0),
			"chat_picker_requests": chat.get("picker_requests", 0),
			"chat_message_count": chat.get("message_count", 0),
			"chat_input_rect": chat.get("input_rect", Rect2()),
			"chat_attach_rect": chat.get("attach_rect", Rect2()),
			"chat_send_rect": chat.get("send_rect", Rect2())
		}
	)
	s.merge(_paintbox_rects())
	return Errors.ok(s)


## The top-left a window may be dragged to, in desktop px: the page's own left margin too, when this
## Tenant was placed with one (offset_left, e.g. the Shell's desktop-icon strip).
func _margin_low() -> Vector2:
	return Vector2(-offset_left / desktop.scale.x, 0)


# Resize the complete window with one scale, preserving content and input coordinates.
func _add_scale_grip(window: Control) -> void:
	var grip := Control.new()
	grip.name = "ProportionalResize"
	grip.size = Vector2(32, 32)
	grip.mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
	grip.tooltip_text = "Drag to resize proportionally"
	grip.draw.connect(
		func():
			grip.draw_rect(Rect2(Vector2.ZERO, grip.size), Color(0.3, 0.3, 0.3, 0.8))
			for inset in [10, 17, 24]:
				grip.draw_line(Vector2(inset, 28), Vector2(28, inset), Color.WHITE, 2.0)
	)
	# Containers otherwise stretch the grip across the painting/tool panel.
	grip.top_level = window is Container
	window.add_child(grip)
	var fit := func():
		if grip.top_level:
			grip.size = Vector2(32, 32)
			grip.global_position = window.get_global_transform() * (window.size - grip.size)
			grip.scale = window.get_global_transform().get_scale()
		else:
			grip.position = window.size - grip.size
	window.item_rect_changed.connect(fit)
	window.get_parent().item_rect_changed.connect(fit)
	fit.call()
	var gesture := {"active": false, "start": Vector2.ZERO, "scale": 1.0}
	get_window().focus_exited.connect(
		func():
			gesture.active = false
			set_meta("scaling", false)
	)
	window.visibility_changed.connect(
		func():
			gesture.active = false
			set_meta("scaling", false)
	)
	grip.gui_input.connect(
		func(event):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
				gesture.active = event.pressed
				set_meta("scaling", event.pressed)
				if event.pressed:
					gesture.start = window.get_parent().make_canvas_position_local(
						event.global_position
					)
					gesture.scale = window.scale.x
					set_meta("windows_adjusted", true)
					window.get_parent().move_child(window, -1)
				grip.accept_event()
			elif event is InputEventMouseMotion and gesture.active and get_meta("scaling", false):
				var delta: Vector2 = (
					window.get_parent().make_canvas_position_local(event.global_position)
					- gesture.start
				)
				var available: Vector2 = window.get_parent().size - window.position
				var maximum := minf(available.x / window.size.x, available.y / window.size.y)
				var factor: float = (
					gesture.scale + delta.dot(window.size) / window.size.length_squared()
				)
				window.scale = Vector2.ONE * clampf(factor, minf(0.35, maximum), maximum)
				fit.call()
				grip.accept_event()
	)
