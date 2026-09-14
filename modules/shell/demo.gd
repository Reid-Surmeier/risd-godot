## The game's main scene: the Shell with the six fixed tabs. Tenants are registered here as
## they are ported (the Pixel Atlas is the Map Tenant); until then the dummy tenant stands in
## (phone has none, so its page is white).
extends Control

const Shell := preload("res://modules/shell/interface.gd")
const DummyTenant := preload("res://modules/shell/playtest/dummy_tenant.gd")
const Atlas := preload("res://modules/atlas/interface.gd")


func _ready() -> void:
	get_window().min_size = Vector2i(1440, 900)
	var created := Shell.create({"map": Atlas, "sketchbook": DummyTenant, "3d_viewer": DummyTenant,
			"video_player": DummyTenant, "collection": DummyTenant})
	if not created.ok:
		push_error("shell: %s" % created.error.code)
		return
	add_child(created.value)
