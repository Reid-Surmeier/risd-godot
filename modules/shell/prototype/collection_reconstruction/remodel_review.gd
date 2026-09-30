## #182/#183 native room, close-up and oblique visual proof.
extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.size=Vector2i(1100,760)
	var scene=load("res://remodel_room.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	for view in [["room",Vector3(.45,.25,-2.6)],["gallery",Vector3(.45,.25,2.8)]]:
		scene.reset(view[1])
		for i in 30:
			await physics_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png("res://evidence/"+view[0]+".png")==OK)
	scene.set_physics_process(false)
	scene.visitor.hide()
	for casing in scene.casings:
		casing.get_child(1).show()
	scene.label.text="Collection · authored low polygon geometry + Muse textures\nBookcase 2017.74.9 / gilt mirror source trial. Dimensions and hidden profiles provisional."
	for view in [["bookcase-detail",Vector3(.45,1.15,-2.8),Vector3(.45,.95,-4.87)],
		["bookcase-oblique",Vector3(2.1,1.65,-3.4),Vector3(.45,.95,-4.87)],
		["mirror-detail",Vector3(-.95,1.95,-2.65),Vector3(-.95,1.95,-5.04)]]:
		scene.camera.fov=45
		scene.camera.position=view[1]
		scene.camera.look_at(view[2])
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png("res://evidence/"+view[0]+".png")==OK)
	print("REMODEL_VISUAL_PROOF: two walking views, three asset detail/oblique views")
	quit()
