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
		var arch: bool = JavaScriptBridge.eval("new URLSearchParams(location.search).get('portal') === 'arch'")
		walk._pos = Vector3(0, 0, -2.6 if arch else -walk.L + 2.6)
		walk.view_yaw = PI if arch else 0
		if not JavaScriptBridge.eval("new URLSearchParams(location.search).has('show-visitor')"):
			walk._kid.hide()
			walk._shadow.hide()
			for shadow in walk._sole_shadows:
				shadow.hide()
		else:
			walk._pos.z = -5.0 if arch else walk._pos.z
		walk._update_camera(1.0)
		if JavaScriptBridge.eval("new URLSearchParams(location.search).has('qa-floor')"):
			# Read-only exported-runtime observation; browser still drives real keys.
			var frames := [0]
			get_tree().process_frame.connect(func() -> void:
				frames[0] += 1
				if frames[0] % 10 == 0:
					JavaScriptBridge.eval("window.__portalQA=" + JSON.stringify({"space": walk._space, "position": [walk._pos.x, walk._pos.z], "mask": walk._cam.cull_mask, "view": walk.view_mode, "fov": walk._cam.fov, "camera": [walk._cam.position.x, walk._cam.position.y, walk._cam.position.z], "visitor_visible": walk._kid.is_visible_in_tree()}))
			)
			for frame in 6:
				await get_tree().process_frame
			if arch:
				var probe: Dictionary = await load("res://modules/shell/prototype/gallery_walk4/portal_floor_probe.gd").sample(walk)
				print("PORTAL_FLOOR_DEPTH clear_samples=", probe.clear, "/9 meshes=", probe.meshes)
			else:
				var image: Image = walk._vp.get_texture().get_image()
				var clear := 0
				for x in [-0.5, 0.0, 0.5]:
					for depth in [0.15, 0.22, 0.32]:
						var pixel := Vector2i(walk._cam.unproject_position(Vector3(x, 0, -walk.L - depth)))
						if image.get_pixelv(pixel).get_luminance() > 0.04:
							clear += 1
				print("DOORWAY_FLOOR clear_samples=", clear, "/9")
		var floor_view = JavaScriptBridge.eval("new URLSearchParams(location.search).get('floor_view')")
		if floor_view != null:
			set_floor_pose(walk, int(floor_view))
		print("DOORWAY_GAMEPLAY_READY")
		return
	var room: Node = load("res://modules/shell/prototype/gallery_walk4/baked/room.tscn").instantiate()
	add_child(room)
	# Match actual gameplay: this inherited photographic reference is not the
	# modeled room. Keeping it in the static fixture created a false black end.
	for mesh in room.find_children("*", "MeshInstance3D", true, false):
		var material: Material = mesh.material_override
		if material is StandardMaterial3D and material.albedo_texture and material.albedo_texture.resource_path.ends_with("/door-arch.jpg"):
			mesh.hide()
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
	view = posmod(index, 17)
	var positions := [Vector3(0, 2.1, -20), Vector3(2.9, 1.3, -23), Vector3(1.8, 0.65, -25), Vector3(-2.5, 2.6, -22), Vector3(0, 3, -9), Vector3(0, 3.2, -13), Vector3(0, 3.2, -23), Vector3(0, 3.2, -4), Vector3(0, 2.0, -5), Vector3(0, 2.1, 6.5), Vector3(2.2, 1.8, 4.1), Vector3(2.5, 2.2, -6.3), Vector3(0.75, 0.8, -7.3), Vector3(0, 1.7, -4), Vector3(3.7, 2.1, -1.8), Vector3(1.8, 2.4, -3), Vector3(1.4, 1.7, -12)]
	var targets := [Vector3(0, 1.7, -26.3), Vector3(0.9, 1.2, -26.3), Vector3(1.15, 0.3, -26.3), Vector3(0, 1.65, -26.3), Vector3(0, 2.4, -26.3), Vector3(-5, 5.75, -13), Vector3(-5, 5.75, -26.3), Vector3(-5, 5.75, 0), Vector3(0, 1.9, 0), Vector3(0, 2.1, 1.6), Vector3(0.95, 1.8, 1.6), Vector3(0, 0.24, -9), Vector3(0, 0.24, -8.3), Vector3(0, 4.2, -20), Vector3(3.7, 0, -0.5), Vector3(0.9, 2.0, 0), Vector3(-5, 2.4, -14)]
	camera.position = positions[view]
	camera.fov = 62 if view == 16 else (66 if view == 13 else (54 if view == 9 else 48))
	camera.look_at(targets[view])
	print("DOORWAY_PROTOTYPE view=", view)
func _unhandled_key_input(event: InputEvent) -> void:
	if camera == null:
		return
	if event.is_action_pressed("ui_right"):
		set_view(view + 1)
	if event.is_action_pressed("ui_left"):
		set_view(view - 1)

static func set_floor_pose(walk: Control, index: int) -> void:
	walk._new_action()
	walk._entrance_active = false
	walk._entrance_waiting = false
	walk._target = null
	walk._pos = Vector3(0, 0, -17.0)
	walk.view_mode = 1
	walk.view_yaw = 0.0
	walk._kid.hide()
	walk._shadow.hide()
	for shadow in walk._sole_shadows:
		shadow.hide()
	walk._update_camera(1.0)
	if index == 1:
		walk.set_process(false)
		walk._cam.position = Vector3(0.8, 1.75, -14.0)
		walk._cam.look_at(Vector3(0.2, 0.0, -18.5))
		walk._cam.fov = 55.0
	elif index == 2:
		walk.set_process(false)
		walk._cam.position = Vector3(1.4, 1.7, -12.0)
		walk._cam.look_at(Vector3(-5.0, 2.4, -14.0))
		walk._cam.fov = 62.0
	elif index == 3:
		walk.set_process(false)
		walk._cam.cull_mask = 63  # the normal floor view hides the skylight layer
		walk._cam.position = Vector3(0.0, 1.8, -12.0)
		walk._cam.look_at(Vector3(0.0, 5.8, -19.0))
		walk._cam.fov = 66.0
