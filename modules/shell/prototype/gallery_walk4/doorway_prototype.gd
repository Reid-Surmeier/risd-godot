## Throwaway #160: the saved gallery asset, no visitor, fixed comparison views.
extends Node3D
var camera: Camera3D
var view := 0
func _ready() -> void:
	if OS.has_feature("web") and JavaScriptBridge.eval("new URLSearchParams(location.search).has('gameplay')"):
		var walk = load("res://modules/shell/prototype/gallery_walk4/walk4.gd").new()
		walk.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(walk)
		walk.size = get_viewport().get_visible_rect().size
		walk._new_action()
		walk._entrance_active = false
		walk._entrance_waiting = false
		walk._target = null
		walk._pos = Vector3(0, 0, -walk.L + 2.6)
		walk.view_yaw = 0
		walk._kid.hide()
		walk._shadow.hide()
		for shadow in walk._sole_shadows:
			shadow.hide()
		walk._update_camera(1.0)
		print("DOORWAY_GAMEPLAY_READY")
		return
	add_child(load("res://modules/shell/prototype/gallery_walk4/baked/room.tscn").instantiate())
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color("#323a41")
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_energy = 0.0
	add_child(world)
	camera = Camera3D.new()
	camera.fov = 48
	add_child(camera)
	if OS.has_feature("web"):
		view = int(JavaScriptBridge.eval("new URLSearchParams(location.search).get('view') || '0'"))
	set_view(view)
func set_view(index: int) -> void:
	view = posmod(index, 5)
	var positions := [Vector3(0, 2.1, -20), Vector3(2.9, 1.3, -23), Vector3(1.8, 0.65, -25), Vector3(-2.5, 2.6, -22), Vector3(0, 4, -13.5)]
	var targets := [Vector3(0, 1.7, -26.3), Vector3(0.9, 1.2, -26.3), Vector3(1.15, 0.3, -26.3), Vector3(0, 1.65, -26.3), Vector3(0, 2.7, -26.3)]
	camera.position = positions[view]
	camera.look_at(targets[view])
	print("DOORWAY_PROTOTYPE view=", view)
func _unhandled_key_input(event: InputEvent) -> void:
	if camera == null:
		return
	if event.is_action_pressed("ui_right"):
		set_view(view + 1)
	if event.is_action_pressed("ui_left"):
		set_view(view - 1)
