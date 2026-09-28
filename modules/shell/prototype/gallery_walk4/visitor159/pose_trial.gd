extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	root.size = Vector2i(1080,1080)
	var gallery = load("res://modules/shell/prototype/gallery_walk4/visitor159/play.tscn").instantiate()
	root.add_child(gallery)
	gallery.resized.emit()
	await create_timer(2).timeout
	gallery.set_process(false)
	gallery._new_action()
	gallery._target = null
	gallery._pos = Vector3(-1.909635,0,-12.084023)
	gallery._kid.position = gallery._pos
	gallery.view_yaw = PI / 2
	DirAccess.make_dir_recursive_absolute("/tmp/risd-159-pose")
	for view in ["front","back","rear_diagonal"]:
		gallery.view_yaw = PI / 2 + (0.35 if view == "rear_diagonal" else 0.0)
		var direction := Vector3.RIGHT if view == "front" else Vector3.LEFT
		for pose in ["idle","look","wave"]:
			gallery._pos = Vector3(-2.936562,0,-10.754420) if pose == "wave" else Vector3(-1.909635,0,-12.084023)
			gallery._kid.position = gallery._pos
			gallery._kid.attention_target = gallery._nearest_work().center
			gallery.attention_normal = gallery._nearest_work().normal
			if pose != "idle":
				var toward: Vector3 = gallery._kid.attention_target - gallery._pos
				toward.y = 0
				direction = toward.normalized().rotated(Vector3.UP, -0.65 if pose == "look" else 0.0)
			gallery._kid.reset_contacts()
			gallery._kid.pose(0,false,0,direction,gallery.view_yaw)
			for i in 60:
				gallery._kid.pose(1.0/30,false,0,direction,gallery.view_yaw)
			if pose != "idle":
				gallery._kid.play_gesture(pose)
				for i in 19:
					gallery._kid.pose(1.0/30,false,0,direction,gallery.view_yaw)
			gallery._update_camera(1)
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("/tmp/risd-159-pose/"+view+"-"+pose+".png")
	quit()
