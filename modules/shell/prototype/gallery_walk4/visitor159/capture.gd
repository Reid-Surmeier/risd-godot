extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.size = Vector2i(1080, 1080)
	var gallery: Control = load("res://modules/shell/prototype/gallery_walk4/visitor159/play.tscn").instantiate()
	root.add_child(gallery)
	gallery.resized.emit()
	await create_timer(3.0).timeout
	gallery._new_action()
	gallery._target = null
	gallery._pos = Vector3(-2.6, 0, -8)
	gallery._kid.position = gallery._pos
	gallery._kid.reset_contacts()
	gallery.view_yaw = PI / 2
	gallery.set_process(false)
	for view in ["front", "profile", "back"]:
		var direction: Vector3 = {"front": Vector3.RIGHT, "profile": Vector3.BACK, "back": Vector3.LEFT}[view]
		gallery._kid.pose(0, false, 0, direction, gallery.view_yaw)
		for i in 90:
			gallery._kid.pose(1.0 / 30, false, 0, direction, gallery.view_yaw)
		gallery._update_camera(1)
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("/tmp/risd-159-" + view + ".png")
	print("VISITOR159 paintings=", gallery._paintings.size(), " bones=", gallery._kid.target.get_bone_count(), " viewport=", gallery._vp.size)
	quit()
