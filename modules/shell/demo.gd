## The game's main scene: the Shell with the seven fixed tabs. Tenants are registered here as
## they are ported (the Pixel Atlas is the Map Tenant, video_player the Video Player Tenant,
## collection_page the Collection Tenant, playground_page and phone_page the two draft mockups);
## until the rest land, the dummy tenant stands in.
extends Control

const Shell := preload("res://modules/shell/interface.gd")
const DummyTenant := preload("res://modules/shell/playtest/dummy_tenant.gd")
const Atlas := preload("res://modules/atlas/interface.gd")
const CollectionPage := preload("res://modules/collection_page/interface.gd")
const VideoPlayer := preload("res://modules/video_player/interface.gd")
const PlaygroundPage := preload("res://modules/playground_page/interface.gd")
const PhonePage := preload("res://modules/phone_page/interface.gd")


func _ready() -> void:
	get_window().min_size = Vector2i(1440, 900)
	var created := Shell.create({"map": Atlas, "sketchbook": DummyTenant, "3d_viewer": DummyTenant,
			"video_player": VideoPlayer, "collection": CollectionPage, "playground": PlaygroundPage,
			"phone": PhonePage})
	if not created.ok:
		push_error("shell: %s" % created.error.code)
		return
	add_child(created.value)
