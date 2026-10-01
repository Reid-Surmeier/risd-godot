## Review captures on CPU (Mesa llvmpipe), unbaked, in a scratch copy of the plain prototype project:
##   env LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe DISPLAY=:99 godot --path <plain project> --rendering-method gl_compatibility -s capture.gd -- --out=<folder> [--without-piano-west-leaf]
## Four views of the grey gallery's west wall and corner door. With --without-piano-west-leaf the piano door's
## west leaf (0.66 m in front of the west wall, beside the Courbet) and its panel faces are hidden, to show what
## the one recommended correction changes. The Hall door's two leaves stay as built.
## Camera positions are approximations of the source viewpoints, not measured.
extends SceneTree

func _initialize() -> void:
	create_timer(120).timeout.connect(func(): quit(2))
	call_deferred("run")

func run() -> void:
	var out := ""
	var hide := false
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.trim_prefix("--out=")
		hide = hide or arg == "--without-piano-west-leaf"
	root.size = Vector2i(1100, 760)
	var scene: Node3D = load("res://remodel_room.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_physics_process(false)
	scene.visitor.hide()
	scene.contact_shadow.hide()
	scene.label.hide()
	var hidden := 0
	for casing in scene.casings:
		casing.get_child(1).show()
	if hide:
		# The leaf body and the six panel faces built beside it, all within its footprint.
		for node in scene.get_children():
			if node is Node3D and not node is Camera3D:
				var at: Vector3 = node.global_position
				if node is MeshInstance3D and node.mesh != null:
					at = node.global_transform * node.mesh.get_aabb().get_center()
				if abs(at.x - 4.51) < .06 and at.z > -4.25 and at.z < -3.2 and at.y < 2.8 and at.y > .1:
					node.hide()
					hidden += 1
	scene.update_baked_visibility()
	for view in [["west-wall-from-north-east", Vector3(9.0, 1.6, -2.0), Vector3(3.85, 1.7, -.9)], ["north-west-corner-from-east", Vector3(9.0, 1.6, -2.0), Vector3(3.85, 1.7, -3.3)],
			["west-wall-from-stair", Vector3(12.3, 2.6, -1.2), Vector3(3.85, 1.2, -1.2)], ["from-connector-door-looking-east", Vector3(3.7, 1.6, .58), Vector3(11.05, 1.5, -1.0)]]:
		scene.camera.fov = 70
		scene.camera.position = view[1]
		scene.camera.look_at(view[2])
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(out.path_join(view[0] + ("-without-piano-west-leaf" if hide else "") + ".png"))
	print("CAPTURE ", JSON.stringify({"hidden_nodes": hidden, "views": 4}))
	quit(0)
