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
	for row in [["front",Vector3(-4.5,1.5,30.0)],["right-quarter",Vector3(-3.8,1.7,29.9)],["above",Vector3(-4.5,2.7,30.2)]]:
		scene.camera.fov=43
		scene.camera.position=row[1]
		scene.camera.look_at(Vector3(-4.5,1.45,28.4))
		scene.update_baked_visibility()
		for i in 15:await process_frame
		await RenderingServer.frame_post_draw
		assert(vp.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0].path_join(row[0]+".png"))==OK)
	print("TRIPTYCH_AUTHORING_CAPTURE_OK unbaked; metrics/fidelity remain false")
	quit()
