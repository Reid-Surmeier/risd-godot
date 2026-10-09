## Review capture on CPU (Mesa llvmpipe), unbaked, in a scratch project prepared with the retained Hall:
##   env LIBGL_ALWAYS_SOFTWARE=1 GALLIUM_DRIVER=llvmpipe DISPLAY=:99 godot --path <project> --rendering-method gl_compatibility -s capture_hall_passage.gd -- --out=<folder>
## Three views of the Hall door from inside the grey gallery, each as built and with the retained Hall's
## six north-passage meshes (Surface118 to Surface123) hidden. Prints those meshes' world boxes.
extends SceneTree

func _initialize() -> void:
	create_timer(300).timeout.connect(func(): quit(2))
	call_deferred("run")

func run() -> void:
	var out := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.trim_prefix("--out=")
	root.size = Vector2i(1100, 760)
	var scene: Node3D = load("res://remodel_room.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_physics_process(false)
	scene.visitor.hide()
	scene.contact_shadow.hide()
	scene.label.hide()
	for casing in scene.casings:
		casing.get_child(1).show()
	scene.update_baked_visibility()
	var passage := []
	for node in scene.find_children("*", "MeshInstance3D", true, false):
		if node.has_meta("retained_main_hall") and node.is_visible_in_tree():
			var b: AABB = node.global_transform * node.mesh.get_aabb()
			if b.position.z < 1.6:
				passage.append(node)
				print("PASSAGE ", node.name, " ", b.position.snapped(Vector3.ONE * .01), " .. ", b.end.snapped(Vector3.ONE * .01))
	for hidden in [false, true]:
		for node in passage:
			node.visible = not hidden or str(node.name) == "Surface000"
		for view in [["hall-door-from-grey-north-east", Vector3(9.2, 1.6, -2.4), Vector3(5.55, 1.3, 1.8)], ["grey-from-connector-door", Vector3(3.2, 1.6, .58), Vector3(11.05, 1.4, .3)],
				["grey-south-west-from-above", Vector3(7.5, 5.5, -3.4), Vector3(5.2, 0, .6)]]:
			scene.camera.fov = 70
			scene.camera.position = view[1]
			scene.camera.look_at(view[2])
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(out.path_join(view[0] + ("-passage-hidden" if hidden else "-as-built") + ".png"))
	print("CAPTURE ", JSON.stringify({"passage_meshes": passage.size(), "views": 6}))
	quit(0)
