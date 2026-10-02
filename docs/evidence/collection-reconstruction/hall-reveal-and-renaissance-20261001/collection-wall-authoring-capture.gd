extends SceneTree
func _initialize():call_deferred("capture")
func capture():
	DirAccess.make_dir_recursive_absolute(OS.get_cmdline_user_args()[0])
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
	for row in [["textiles-south-wide",Vector3(-2.5,1.35,31.2),Vector3(-2.5,1.35,34.13)],["velvet-front",Vector3(-1.775,1.31,31.85),Vector3(-1.775,1.31,34.117)],["textiles-platform",Vector3(-2.5,1.1,31.9),Vector3(-3.1,.22,33.7)],["madonna-west-front",Vector3(-3.6,1.22,33.35),Vector3(-5.478,1.22,33.35)],["madonna-west-quarter",Vector3(-3.6,1.40,32.6),Vector3(-5.478,1.22,33.35)],["renaissance-south-west-wide",Vector3(-.85,2.35,30.1),Vector3(-3.25,1.55,33.7)]]:
		scene.camera.fov=62 if "wide" in row[0] else 43
		scene.camera.position=row[1]
		scene.camera.look_at(row[2])
		scene.update_baked_visibility()
		for i in 15:await process_frame
		await RenderingServer.frame_post_draw
		assert(vp.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0].path_join(row[0]+".png"))==OK)
	print("RENAISSANCE_WALL_AUTHORING_CAPTURE_OK users=",scene.inventory.get("native_lightmap_users",0),"; metrics/fidelity remain false")
	quit()
