## The game's main scene: the Shell with the six fixed tabs, every Tab's Tenant registered:
## the Pixel Atlas desktop is the Map Tenant, sketchbook and sculpture_viewer the Sketchbook and
## 3D Viewer Tenants, video_player the Video Player Tenant, the owner's framed page (2026-09-25) the Collection Tenant,
## playground_page the Playground desktop (the Phone Tab folded into it, ticket #62).
extends Control

const Shell := preload("res://modules/shell/interface.gd")
const Atlas := preload("res://modules/atlas/interface.gd")
const Sketchbook := preload("res://modules/sketchbook/interface.gd")
const SculptureViewer := preload("res://modules/sculpture_viewer/interface.gd")
const VideoPlayer := preload("res://modules/video_player/interface.gd")
const CollectionData := preload("res://modules/collection_data/interface.gd")
const PlaygroundPage := preload("res://modules/playground_page/interface.gd")
const SoundCues := preload("res://modules/sound_cues/interface.gd")
const COLLECTION_PICTURE := "res://modules/shell/assets/collection_frame/page.png"  # image-work/collection-frame

var _storage: Variant


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
		var page := TextureRect.new()
		page.name = "CollectionFrame"
		page.texture = load(COLLECTION_PICTURE)
		page.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		page.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		page.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		page.mouse_filter = Control.MOUSE_FILTER_IGNORE
		page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		return {"ok": true, "value": page, "error": null}
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
		return PlaygroundPage.create(page_deps)
	var created := Shell.create({"map": Atlas, "sketchbook": sketchbook_factory, "3d_viewer": SculptureViewer,
			"video_player": VideoPlayer, "collection": collection_factory, "playground": playground_factory})
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
