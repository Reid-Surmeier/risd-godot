## The game's main scene: the Shell with the seven fixed tabs, every Tab's Tenant registered:
## the Pixel Atlas desktop is the Map Tenant, sketchbook and sculpture_viewer the Sketchbook and
## 3D Viewer Tenants, video_player the Video Player Tenant, collection_page the Collection Tenant,
## playground_page and phone_page the two draft mockups.
extends Control

const Shell := preload("res://modules/shell/interface.gd")
const Atlas := preload("res://modules/atlas/interface.gd")
const Sketchbook := preload("res://modules/sketchbook/interface.gd")
const SculptureViewer := preload("res://modules/sculpture_viewer/interface.gd")
const VideoPlayer := preload("res://modules/video_player/interface.gd")
const CollectionPage := preload("res://modules/collection_page/interface.gd")
const PlaygroundPage := preload("res://modules/playground_page/interface.gd")
const PhonePage := preload("res://modules/phone_page/interface.gd")


func _ready() -> void:
	get_window().min_size = Vector2i(1440, 900)
	var created := Shell.create({"map": Atlas, "sketchbook": Sketchbook, "3d_viewer": SculptureViewer,
			"video_player": VideoPlayer, "collection": CollectionPage, "playground": PlaygroundPage,
			"phone": PhonePage})
	if not created.ok:
		push_error("shell: %s" % created.error.code)
		return
	add_child(created.value)
