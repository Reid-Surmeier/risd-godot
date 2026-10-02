extends SceneTree
func _initialize():call_deferred("capture")
func capture():
	root.size=Vector2i(1100,760)
	var presenter=load("res://remodel_presenter.tscn").instantiate()
	root.add_child(presenter)
	var scene=presenter.scene
	scene.set_physics_process(false)
	scene.visitor.hide()
	scene.contact_shadow.hide()
	for body in scene.casings:
		for child in body.get_children():
			if not child is CollisionShape3D:child.show()
	var vp:SubViewport=scene.get_viewport()
	vp.get_parent().stretch=false
	vp.size=Vector2i(1100,760)
	for row in [["pieta-front",Vector3(-3.65,1.48,29.8),Vector3(-5.25,1.4,29.8)],["pieta-quarter",Vector3(-3.9,1.9,30.55),Vector3(-5.25,1.38,29.8)],["saint-roch-front",Vector3(-2.4,1.7,31.95),Vector3(-4.86,1.4,31.95)],["saint-roch-quarter",Vector3(-2.5,2.1,33.0),Vector3(-4.86,1.4,31.95)],["room-corner",Vector3(-1.0,2.65,33.3),Vector3(-4.2,1.5,29.9)]]:
		scene.camera.fov=43
		scene.camera.position=row[1]
		scene.camera.look_at(row[2])
		scene.update_baked_visibility()
		for i in 15:await process_frame
		await RenderingServer.frame_post_draw
		assert(vp.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0].path_join(row[0]+".png"))==OK)
	print("RENAISSANCE_AUTHORING_CAPTURE_OK unbaked; metrics/fidelity remain false")
	quit()
