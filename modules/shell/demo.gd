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


func _ready() -> void:
	var http_result := CollectionData.http_adapter()
	if not http_result.ok:
		push_error("collection data: could not create HTTP adapter")
		return
	var http: Node = http_result.value
	add_child(http)
	var data: Variant = CollectionData.create({"search": http.dispatch}).value
	var collection_factory := func(deps: Dictionary) -> Dictionary:
		var page_deps := deps.duplicate()
		page_deps.collection_data = data
		page_deps.image_base_url = http.base_url
		return CollectionPage.create(page_deps)
	var created := Shell.create({"map": Atlas, "sketchbook": Sketchbook, "3d_viewer": SculptureViewer,
			"video_player": VideoPlayer, "collection": collection_factory, "playground": PlaygroundPage})
	if not created.ok:
		push_error("shell: %s" % created.error.code)
		return
	add_child(created.value)
