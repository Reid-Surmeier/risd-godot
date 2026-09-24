## The game's main scene: the Shell with the six fixed tabs, every Tab's Tenant registered:
## the Pixel Atlas desktop is the Map Tenant, sketchbook and sculpture_viewer the Sketchbook and
## 3D Viewer Tenants, video_player the Video Player Tenant, collection_page the Collection Tenant,
## playground_page the Playground desktop (the Phone Tab folded into it, ticket #62).
extends Control

const Shell := preload("res://modules/shell/interface.gd")
const Atlas := preload("res://modules/atlas/interface.gd")
const Sketchbook := preload("res://modules/sketchbook/interface.gd")
const SculptureViewer := preload("res://modules/sculpture_viewer/interface.gd")
const VideoPlayer := preload("res://modules/video_player/interface.gd")
const CollectionPage := preload("res://modules/collection_page/interface.gd")
const CollectionData := preload("res://modules/collection_data/interface.gd")
const PlaygroundPage := preload("res://modules/playground_page/interface.gd")
const SoundCues := preload("res://modules/sound_cues/interface.gd")

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
	var collection_factory := func(deps: Dictionary) -> Dictionary:
		var page_deps := deps.duplicate()
		page_deps.collection_data = data
		page_deps.image_fetch = http.fetch_image
		return CollectionPage.create(page_deps)
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
