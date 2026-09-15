## The Image Viewer desktop: the Collection Tab's Tenant node. The viewer window (header and
## footer patched from reference.png, seven fixed-size artworks cut from it in a vertical-only
## scroll) and the eight HUD windows of desktop.gd, all draggable, stacking by press.
## Reach it through interface.gd only.
##
## Ported from qwen-image-pipeline prototype/81-image-viewer @ 5d55209 viewer.gd. Left behind:
## the always-hidden hint label, the unused CONTENT rect, the JavaScriptBridge publishes (now
## state()). Changed: it lays out from its own size / resized (never the root viewport), pointer
## positions are made local to it, and it samples its pixels with the linear filter the prototype
## ran with (the project default is nearest).
extends Control

const Errors := preload("res://modules/collection_page/errors.gd")
const ROOT := "res://modules/collection_page/"
const FILES: Array[String] = ["reference.png", "assets/equipment.png", "assets/options.png",
	"assets/layout-reference.png", "assets/status.png", "assets/trade.png", "assets/chat.png",
	"assets/party.png", "assets/bottom.png"]
const ART_SCALE := 0.375
const MINIMUM_SIZE := Vector2(531, 250)
## The viewer in the reference's 1944x1280 review coordinates, and its right and bottom edges'
## native distances from the desktop's right and bottom: right, the desktop's own right margin;
## bottom, the gap that keeps it clear of the party window below.
const VIEWER_RECT := Rect2(529, 20, 1393, 658)
const VIEWER_FAR_GAP := Vector2(22, 602)
const WORKS := [
	Rect2(125, 200, 1215, 1240), # First print and its three original icon groups.
	Rect2(1374, 200, 763, 1118),
	Rect2(2174, 198, 833, 1126),
	Rect2(3030, 250, 1350, 1022),
	Rect2(125, 1493, 1215, 805),
	Rect2(2174, 1384, 1165, 932),
	Rect2(3475, 1276, 905, 1075),
]

var key := ""
var ticks := 0
var inputs := 0
var source: Texture2D
var desktop: Control
var frame := Control.new()
var scroll := ScrollContainer.new()
var artwork := HFlowContainer.new()
var chrome := Control.new()
var border := StyleBoxFlat.new()
var pixel_scale := 0.2
var factor := 1.0
var action := ""
var active_window: Control
var start_pointer := Vector2.ZERO
var start_rect := Rect2()


static func create(deps: Dictionary) -> Dictionary:
	for f in FILES:
		if not ResourceLoader.exists(ROOT + f):
			return Errors.err(Errors.ASSET_MISSING, ROOT + f)
	var t = load(ROOT + "viewer.gd").new()
	t.key = deps.get("key", "")
	t.name = "CollectionPage"
	t.source = load(ROOT + "reference.png")
	t.desktop = load(ROOT + "desktop.gd").new()
	t.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return Errors.ok(t)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(desktop)
	for panel in desktop.panels:
		panel.reparent(self)
	frame.name = "viewer"
	frame.mouse_filter = Control.MOUSE_FILTER_STOP
	border.bg_color = Color.WHITE
	border.border_color = Color("8799a5")
	border.set_border_width_all(1)
	border.set_corner_radius_all(6)
	frame.draw.connect(func(): frame.draw_style_box(border, Rect2(Vector2.ZERO, frame.size)))
	add_child(frame)
	scroll.follow_focus = true
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	var background := StyleBoxFlat.new()
	background.bg_color = Color.WHITE
	scroll.add_theme_stylebox_override("panel", background)
	frame.add_child(scroll)
	artwork.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	artwork.add_theme_constant_override("h_separation", 6)
	artwork.add_theme_constant_override("v_separation", 16)
	artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scroll.add_child(artwork)
	for region in WORKS:
		var atlas := AtlasTexture.new()
		atlas.atlas = source
		atlas.region = region
		var card := TextureRect.new()
		card.texture = atlas
		card.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		card.custom_minimum_size = region.size * ART_SCALE
		card.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		card.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		artwork.add_child(card)
	chrome.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chrome.draw.connect(_draw_frame)
	frame.add_child(chrome)
	resized.connect(_fit)
	_fit()


## The desktop fills the Page (#63): the HUD windows at one uniform scale of the reference, anchored
## to their nearest page edges (desktop.gd arrange), and the viewer takes the leftover — its left
## edge beside the HUD column and its bottom above the party window keep their native gaps, its top
## and right run to the page edge minus the desktop's native margin (VIEWER_FAR_GAP). Laid out
## again on every resize.
func _fit() -> void:
	action = ""
	var available := size
	desktop.arrange(available)
	factor = minf(available.x / 1944.0, available.y / 1280.0)
	frame.position = VIEWER_RECT.position * factor
	frame.size = available - VIEWER_FAR_GAP * factor - frame.position
	# The gallery still fits one fixed-size card on narrow displays.
	frame.size = frame.size.max(MINIMUM_SIZE)
	frame.position = frame.position.min((available - frame.size).max(Vector2.ZERO))
	_layout()


func _layout() -> void:
	pixel_scale = minf(0.25, (frame.size.x - 10) / 2150.0)
	scroll.position = Vector2(12, 12 + 102 * pixel_scale)
	scroll.size = frame.size - Vector2(24, 24 + 292 * pixel_scale)
	chrome.size = frame.size
	chrome.queue_redraw()
	frame.queue_redraw()


func _patch(source_rect: Rect2, target: Rect2) -> void:
	if target.size.x > 0 and target.size.y > 0:
		chrome.draw_texture_rect_region(source, target, source_rect)


func _draw_frame() -> void:
	var w := frame.size.x
	var h := frame.size.y
	var s := pixel_scale
	# Sample only the clean interior; the source's noisy outer frame is never drawn.
	_patch(Rect2(44, 34, 1800, 102), Rect2(5, 5, 1800 * s, 102 * s))
	_patch(Rect2(2000, 34, 1000, 102), Rect2(5 + 1800 * s, 5, w - 10 - 2150 * s, 102 * s))
	_patch(Rect2(4220, 34, 350, 102), Rect2(w - 5 - 350 * s, 5, 350 * s, 102 * s))
	var footer_y := h - 5 - 190 * s
	_patch(Rect2(44, 2580, 900, 190), Rect2(5, footer_y, 900 * s, 190 * s))
	_patch(Rect2(1000, 2580, 2000, 190), Rect2(5 + 900 * s, footer_y, w - 10 - 1650 * s, 190 * s))
	_patch(Rect2(3770, 2580, 750, 190), Rect2(w - 5 - 750 * s, footer_y, 750 * s, 190 * s))
	chrome.draw_line(Vector2(5, 6 + 102 * s), Vector2(w - 5, 6 + 102 * s), Color("8799a5"))
	for offset in [7, 12, 17]:
		chrome.draw_line(Vector2(w - offset - 3, h - 6), Vector2(w - 6, h - offset - 3), Color("536b82"), 2)


## Title-bar drag of any window and corner resize of the viewer, by the mouse. A press picks the
## topmost window under the pointer and raises it; the wheel is left to the scroll.
func _input(event: InputEvent) -> void:
	inputs += 1
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var pointer := make_canvas_position_local(event.position)
		if not event.pressed:
			if action.is_empty():
				return
			action = ""
			active_window = null
		else:
			active_window = null
			for window in desktop.panels + [frame]:
				if window.get_rect().has_point(pointer) and (active_window == null or window.get_index() > active_window.get_index()):
					active_window = window
			if active_window == null:
				return
			move_child(active_window, get_child_count() - 1)
			var local: Vector2 = pointer - active_window.position
			var title_height: float = 8 + 102 * pixel_scale if active_window == frame else active_window.get_meta("drag_height")
			if active_window == frame and local.x > frame.size.x - 26 and local.y > frame.size.y - 26:
				action = "resize"
			elif local.y < title_height:
				action = "drag"
			else:
				return
			start_pointer = pointer
			start_rect = active_window.get_rect()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and not action.is_empty():
		var delta: Vector2 = make_canvas_position_local(event.position) - start_pointer
		var available := size
		if action == "drag":
			active_window.position = (start_rect.position + delta).clamp(Vector2.ZERO, (available - active_window.size).max(Vector2.ZERO))
		else:
			frame.size = (start_rect.size + delta).clamp(MINIMUM_SIZE, available - frame.position)
		_layout()
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	ticks += 1


func _local_rect(node: Control) -> Rect2:
	return Rect2(get_global_transform().affine_inverse() * node.global_position, node.size)


## The harness probe (the Tenant contract): every window's rect and stacking order, the viewer's
## scroll and its seven artwork rects, all in the Page's own pixels.
func state() -> Dictionary:
	var windows: Array = desktop.snapshot()
	windows.append({"name": frame.name, "rect": frame.get_rect(), "drag_height": 8 + 102 * pixel_scale, "order": frame.get_index()})
	windows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.order < b.order)
	var cards := []
	for card in artwork.get_children():
		cards.append(_local_rect(card))
	var bar := scroll.get_v_scroll_bar()
	return Errors.ok({"key": key, "ticks": ticks, "inputs": inputs, "size": size, "factor": factor, "action": action,
			"windows": windows, "viewer": {"rect": frame.get_rect(), "scale": pixel_scale, "scroll": scroll.scroll_vertical,
			"scroll_max": bar.max_value - bar.page, "body": _local_rect(scroll), "cards": cards}})
