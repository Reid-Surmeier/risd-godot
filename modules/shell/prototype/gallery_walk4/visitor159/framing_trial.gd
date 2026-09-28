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
	DirAccess.make_dir_recursive_absolute("/tmp/risd-159-framing")
	for pitch in [42.0,25.0,15.0]:
		gallery.visitor_pitch = pitch
		for view in ["front","profile","back"]:
			var direction: Vector3 = {"front":Vector3.RIGHT,"profile":Vector3.BACK,"back":Vector3.LEFT}[view]
			gallery._kid.reset_contacts()
			gallery._kid.pose(0,false,0,direction,gallery.view_yaw)
			for i in 60:
				gallery._kid.pose(1.0/30,false,0,direction,gallery.view_yaw)
			gallery._update_camera(1)
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("/tmp/risd-159-framing/%02d-%s.png" % [pitch,view])
	quit()
