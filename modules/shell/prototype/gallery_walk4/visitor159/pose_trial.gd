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
	gallery._pos = Vector3(-2.6,0,-8)
	gallery._kid.position = gallery._pos
	gallery.view_yaw = PI / 2
	DirAccess.make_dir_recursive_absolute("/tmp/risd-159-pose")
	for view in ["front","back","rear_diagonal"]:
		gallery.view_yaw = PI / 2 + (0.35 if view == "rear_diagonal" else 0.0)
		var direction := Vector3.RIGHT if view == "front" else Vector3.LEFT
		for pose in ["idle","look","wave"]:
			gallery._kid.reset_contacts()
			gallery._kid.pose(0,false,0,direction,gallery.view_yaw)
			for i in 60:
				gallery._kid.pose(1.0/30,false,0,direction,gallery.view_yaw)
			if pose != "idle":
				gallery._kid.play_gesture(pose)
				for i in 19:
					gallery._kid.pose(1.0/30,false,0,direction,gallery.view_yaw)
			gallery._update_camera(1)
			if view == "front" and pose == "idle":
				var kid = gallery._kid
				print("STANCE root=", kid.target.get_bone_pose(0).origin, " rest=", kid.target.get_bone_rest(0).origin)
				for foot in kid.feet:
					print("STANCE neutral=",foot.neutral," upper=",kid.target.get_bone_global_pose(foot.upper).origin," knee=",kid.target.get_bone_global_pose(foot.lower).origin," ankle=",kid.target.get_bone_global_pose(foot.ankle).origin)
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("/tmp/risd-159-pose/"+view+"-"+pose+".png")
	quit()
