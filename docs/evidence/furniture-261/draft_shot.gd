extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	root.size = Vector2i(1100, 700)
	var scene = load("res://remodel_room.tscn").instantiate()
	root.add_child(scene)
	for i in 10:
		await process_frame
	scene.set_physics_process(false)
	for node in scene.find_children("*", "Node3D", true, false):
		node.visible = true
	var target: Node3D
	for node in scene.find_children("*", "StaticBody3D", true, false):
		if node.get_meta("furniture", "") == OS.get_cmdline_user_args()[1]:
			target = node
	var aim := target.global_position + Vector3(0, -.05, 0)
	var shots := {"a": Vector3(1.9, 1.25, 1.9), "b": Vector3(-.6, .9, 1.5)}
	for name in shots:
		scene.camera.fov = 45
		scene.camera.global_transform = Transform3D(Basis(), aim + shots[name]).looking_at(aim, Vector3.UP)
		for i in 4:
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0] + "/furn-" + name + ".png")
	print("FURNITURE_SHOT ", target.global_position)
	quit(0)
