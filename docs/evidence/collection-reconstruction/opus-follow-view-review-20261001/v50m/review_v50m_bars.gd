## Third review run on the private v50m copy: are the dark floor bars the visitor's own foot shadows left behind by a teleport?
extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var output: String = OS.get_cmdline_user_args()[0]
	root.size = Vector2i(1440, 1000)
	var app = load("res://modules/shell/demo.tscn").instantiate()
	root.add_child(app)
	for i in 150: await process_frame
	var walk = app.find_child("GalleryWalk", true, false)
	walk.set_process(false)
	walk._entrance_waiting = false
	walk._entrance_active = false
	walk._target_yaw = null
	walk._set_lighting(true)
	var proof := []
	# Same two placements as the first run, then the same view again after one real pose update.
	for row in [["teleported", Vector3(-7.0, 0, -29.3), "far", 1, -PI / 2, false], ["teleported", Vector3(-8.05, 0, -24.3), "arch", 0, 0.0, false], ["after-one-pose-update", Vector3(-8.05, 0, -24.3), "arch", 0, 0.0, true]]:
		walk._space = row[2]
		walk.view_mode = row[3]
		walk.view_yaw = row[4]
		walk._velocity = Vector3.ZERO
		walk._held.clear()
		walk._target = null
		walk._path.clear()
		walk._pos = row[1]
		walk._last_pos = row[1]
		walk._kid.position = row[1]
		if row[5]:
			walk._kid.reset_contacts()
			for i in 20: walk._process(1.0 / 30.0)
		walk._update_camera(1.0)
		for i in 6: await process_frame
		await RenderingServer.frame_post_draw
		var name: String = "native-bars-%s-%d.png" % [row[0], proof.size()]
		walk._vp.get_texture().get_image().save_png(output.path_join(name))
		var soles := []
		for s in walk._sole_shadows:
			soles.append([s.global_position.x, s.global_position.z, s.material_override.albedo_color.a, s.layers])
		proof.append({"image": name, "visitor": [walk._pos.x, walk._pos.z], "space": walk._space, "sole_shadows_x_z_alpha_layers": soles, "soft_shadow": [walk._shadow.global_position.x, walk._shadow.global_position.z]})
	FileAccess.open(output.path_join("native-bars-v50m.json"), FileAccess.WRITE).store_string(JSON.stringify(proof, "\t") + "\n")
	print("REVIEW_BARS_OK")
	quit()
