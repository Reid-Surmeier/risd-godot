## #182/#183 native room, close-up and oblique visual proof.
extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.size=Vector2i(1100,760)
	var presentation=load("res://remodel_presenter.tscn").instantiate()
	root.add_child(presentation)
	var scene=presentation.scene
	await process_frame
	for view in [["room",Vector3(.45,.25,-4.6)],["gallery",Vector3(.45,.25,2.8)]]:
		scene.reset(view[1])
		for i in 30:
			await physics_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png("res://evidence/"+view[0]+".png")==OK)
	scene.set_physics_process(false)
	scene.visitor.hide()
	scene.contact_shadow.hide()
	for casing in scene.casings:
		casing.get_child(1).show()
	scene.label.text="Collection · authored low polygon geometry + Muse textures\nBookcase 2017.74.9 / gilt mirror source trial. Dimensions and hidden profiles provisional."
	for view in [["bookcase-detail",Vector3(.55,1.15,-4.8),Vector3(.45,.95,-6.84)],
		["bookcase-oblique",Vector3(2.1,1.65,-5.4),Vector3(.45,.95,-6.84)],
		["mirror-detail",Vector3(-1.05,2.15,-4.65),Vector3(-1.05,2.15,-7.00)],
		["entrance-chair-detail",Vector3(.2,1.5,-1.8),Vector3(-2.2,.7,-1.8)],
		["settee-detail",Vector3(.1,1.8,-4.4),Vector3(-2.21,.75,-4.7)],
		["tureen-detail",Vector3(3.05,1.5,-2.6),Vector3(3.05,1.3,-3.55)]]:
		scene.camera.fov=45
		scene.camera.position=view[1]
		scene.camera.look_at(view[2])
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png("res://evidence/"+view[0]+".png")==OK)
	print("REMODEL_VISUAL_PROOF: two walking views, six asset detail/oblique views")
	quit()
