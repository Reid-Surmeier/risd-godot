## The game's main scene: the Shell with the six fixed tabs, every Tab's Tenant registered:
## the Pixel Atlas desktop is the Map Tenant, sketchbook and sculpture_viewer the Sketchbook and
## 3D Viewer Tenants, video_player the Video Player Tenant, the owner's framed page (2026-09-25) the Collection Tenant,
## playground_page the Playground desktop (the Phone Tab folded into it, ticket #62), flowers_page the
## Flowers Tab (Orisinal Flowers on the site's own Ruffle build, 2026-09-25).
extends Control

const Shell := preload("res://modules/shell/interface.gd")
const Atlas := preload("res://modules/atlas/interface.gd")
const Sketchbook := preload("res://modules/sketchbook/interface.gd")
const SculptureViewer := preload("res://modules/sculpture_viewer/interface.gd")
const VideoPlayer := preload("res://modules/video_player/interface.gd")
const CollectionData := preload("res://modules/collection_data/interface.gd")
const PlaygroundPage := preload("res://modules/playground_page/interface.gd")
const FlowersPage := preload("res://modules/flowers_page/interface.gd")
const SoundCues := preload("res://modules/sound_cues/interface.gd")
const COLLECTION_PICTURE := "res://modules/shell/assets/collection_frame/page.png"  # image-work/collection-frame

var _storage: Variant
var _playground: Control


func _ready() -> void:
	var http_result := CollectionData.http_adapter()
	if not http_result.ok:
		push_error("collection data: could not create HTTP adapter")
		return
	var http: Node = http_result.value
	add_child(http)
	var storage_result := CollectionData.storage_adapter()
	if not storage_result.ok:
		push_error("collection data: could not create storage adapter")
		return
	_storage = storage_result.value
	var data_result := CollectionData.create({"search": http.dispatch, "load_saves": _storage.load_saves,
			"save_if_absent": _storage.save_if_absent, "now_ms": func() -> int: return int(Time.get_unix_time_from_system() * 1000.0)})
	if not data_result.ok:
		push_error("collection data: could not create shared handle")
		return
	var data: Variant = data_result.value
	var collection_factory := func(_deps: Dictionary) -> Dictionary:  # the frame and clock, filling the Page's height
		var host := Control.new()
		host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var page := TextureRect.new()
		host.add_child(page)
		page.name = "CollectionFrame"
		page.texture = load(COLLECTION_PICTURE)
		page.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		page.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		page.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		page.mouse_filter = Control.MOUSE_FILTER_IGNORE
		page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		# PROTOTYPE (2026-09-26): the Grand Gallery 3D walk fills the frame's white opening (458,521 2110x1412 in page.png)
		var walk: Control = load("res://modules/shell/prototype/gallery_walk4/walk4.gd").new()
		walk.name = "GalleryWalk"
		page.add_child(walk)
		var fit := func() -> void:
			if not walk._open.is_empty():
				walk.position = Vector2(24, 12)
				walk.size = page.size - Vector2(48, 24)
				return
			var tex_size: Vector2 = page.texture.get_size()
			var s := minf(page.size.x / tex_size.x, page.size.y / tex_size.y)
			var origin := (page.size - tex_size * s) / 2
			walk.position = (origin + Vector2(458, 521) * s).round()
			walk.size = (Vector2(2110, 1412) * s).round()
		page.resized.connect(fit)
		host.ready.connect(func(): _add_scale_grip(page))
		var frame_scale := [Vector2.ONE]
		walk.detail_changed.connect(func(open: bool) -> void:
			if open:
				frame_scale[0] = page.scale
			page.scale = Vector2.ONE if open else frame_scale[0]
			page.get_node("ProportionalResize").visible = not open
			page.self_modulate.a = 0.0 if open else 1.0
			fit.call())
		return {"ok": true, "value": host, "error": null}
	var sketchbook_factory := func(deps: Dictionary) -> Dictionary:
		var page_deps := deps.duplicate()
		page_deps.collection_data = data
		page_deps.image_fetch = http.fetch_image
		return Sketchbook.create(page_deps)
	var playground_factory := func(deps: Dictionary) -> Dictionary:
		var page_deps := deps.duplicate()
		page_deps.collection_data = data
		page_deps.image_fetch = http.fetch_image
		page_deps.show_websurfer = true
		page_deps.show_fengshui = true
		page_deps.show_sketchbook = true
		var result := PlaygroundPage.create(page_deps)
		if result.ok:
			_playground = result.value
		return result
	var created := Shell.create({"map": Atlas, "sketchbook": sketchbook_factory, "3d_viewer": SculptureViewer,
			"video_player": VideoPlayer, "collection": collection_factory, "playground": playground_factory, "flowers": FlowersPage})
	if not created.ok:
		push_error("shell: %s" % created.error.code)
		return
	var sounds := SoundCues.create()
	if not sounds.ok:
		push_error("sound cues: %s" % sounds.error.code)
		return
	add_child(sounds.value)
	add_child(created.value)
	SoundCues.attach(sounds.value, created.value)
	var chrome := preload("res://modules/shell/square_chrome.gd").new()
	chrome.name = "SquareChrome"
	chrome.shell = created.value
	chrome.search_requested = func() -> void:
		var result := PlaygroundPage.show_page(_playground, "search")
		if not result.ok:
			push_error("Playground Search: %s" % result.error)
	add_child(chrome)


# Resize the complete window with one scale, preserving content and input coordinates.
func _add_scale_grip(window: Control) -> void:
	var grip := Control.new()
	grip.name = "ProportionalResize"
	grip.size = Vector2(32, 32)
	grip.mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
	grip.tooltip_text = "Drag to resize proportionally"
	grip.draw.connect(func():
		grip.draw_rect(Rect2(Vector2.ZERO, grip.size), Color(0.3, 0.3, 0.3, 0.8))
		for inset in [10, 17, 24]:
			grip.draw_line(Vector2(inset, 28), Vector2(28, inset), Color.WHITE, 2.0))
	window.add_child(grip)
	var fit := func(): grip.position = window.size - grip.size
	window.resized.connect(fit)
	fit.call()
	var gesture := {"active": false, "start": Vector2.ZERO, "scale": 1.0}
	get_window().focus_exited.connect(func():
		gesture.active = false
		set_meta("scaling", false))
	window.visibility_changed.connect(func():
		gesture.active = false
		set_meta("scaling", false))
	grip.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			gesture.active = event.pressed
			set_meta("scaling", event.pressed)
			if event.pressed:
				gesture.start = window.get_parent().make_canvas_position_local(event.global_position)
				gesture.scale = window.scale.x
				set_meta("windows_adjusted", true)
				window.get_parent().move_child(window, -1)
			grip.accept_event()
		elif event is InputEventMouseMotion and gesture.active and get_meta("scaling", false):
			var delta: Vector2 = window.get_parent().make_canvas_position_local(event.global_position) - gesture.start
			var available: Vector2 = window.get_parent().size - window.position
			var maximum := minf(available.x / window.size.x, available.y / window.size.y)
			var factor: float = gesture.scale + delta.dot(window.size) / window.size.length_squared()
			window.scale = Vector2.ONE * clampf(factor, minf(0.35, maximum), maximum)
			grip.accept_event())
