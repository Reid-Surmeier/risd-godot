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
	for row in [["case-a-front",Vector3(-1.35,1.53,29.65),Vector3(.18,1.50,29.65)],["case-a-quarter",Vector3(-1.25,1.8,30.3),Vector3(.18,1.50,29.65)],["case-b-front",Vector3(-1.35,1.53,33.265),Vector3(.18,1.50,33.265)],["case-b-quarter",Vector3(-1.25,1.8,33.85),Vector3(.18,1.50,33.265)],["east-wall-room",Vector3(-3.3,2.5,32.0),Vector3(.30,1.5,31.2)],["triptych-wall-fit",Vector3(-3.6,1.70,29.4),Vector3(-4.5,1.45,28.35)]]:
		scene.camera.fov=43
		scene.camera.position=row[1]
		scene.camera.look_at(row[2])
		scene.update_baked_visibility()
		for i in 15:await process_frame
		await RenderingServer.frame_post_draw
		assert(vp.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0].path_join(row[0]+".png"))==OK)
	print("RENAISSANCE_AUTHORING_CAPTURE_OK unbaked; metrics/fidelity remain false")
	quit()
