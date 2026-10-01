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
	for view in [["room",Vector3(.45,.25,-4.6)],["gallery",Vector3(-.55,.25,3)]]:
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
	scene.label.text="Collection · authored low polygon geometry + Muse textures\nMuseum-catalogued objects / Muse asset trials. Dimensions and hidden profiles provisional."
	for view in [["bookcase-detail",Vector3(.55,1.5,-3.5),Vector3(.55,1.1,-6.84)],
		["bookcase-oblique",Vector3(2.1,1.65,-5.4),Vector3(.45,.95,-6.84)],
		["mirror-detail",Vector3(-1.05,2.15,-4.65),Vector3(-1.05,2.15,-7.00)],
		["entrance-chair-detail",Vector3(.2,1.5,-1.95),Vector3(-2.2,.7,-1.95)],
		["settee-detail",Vector3(.1,1.8,-5.2),Vector3(-2.21,.75,-5.2)],
		["bust-detail",Vector3(-.3,1.65,-6.15),Vector3(-2.2,1.60,-5.87)],
		["gold-service-detail",Vector3(.8,1.7,-3.8),Vector3(3.05,1.27,-3.8)],
		["pink-service-detail",Vector3(1.85,1.7,-3.2),Vector3(1.85,1.24,-.95)],
		["door-sconce-detail",Vector3(-.55,2.1,-3.2),Vector3(-.55,1.9,-.4)]]:
		scene.camera.fov=45
		scene.camera.position=view[1]
		scene.camera.look_at(view[2])
		scene.update_baked_visibility()
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png("res://evidence/"+view[0]+".png")==OK)
	# Inspect geometry at native resolution as well as the shipping 376x252 presentation.
	var native_view:SubViewport=scene.get_viewport()
	native_view.get_parent().stretch=false
	native_view.size=Vector2i(1100,760)
	for view in [["bookcase-asset",Vector3(.55,1.35,-4.3),Vector3(.55,1.1,-6.84)],
		["gold-service-asset",Vector3(1.7,1.8,-3.8),Vector3(3.05,1.27,-3.8)],
		["pink-service-asset",Vector3(1.85,1.8,-2.7),Vector3(1.85,1.24,-.95)],
		["wide-purple-entry",Vector3(3.2,1.65,-2),Vector3(-2.6,1.35,-4.8)],
		["wide-gallery-entry",Vector3(-.8,1.65,1.1),Vector3(.15,1.3,-6.2)],
		["architecture-asset",Vector3(-.55,2.1,-3.5),Vector3(-.55,1.9,-.4)],
		["wallpaper-asset",Vector3(1.6,2.1,-5.4),Vector3(3.59,2.1,-5.4)],
		["bust-asset",Vector3(-.9,1.65,-5.87),Vector3(-2.2,1.60,-5.87)]]:
		scene.camera.position=view[1]
		scene.camera.look_at(view[2])
		scene.update_baked_visibility()
		await process_frame
		await RenderingServer.frame_post_draw
		assert(native_view.get_texture().get_image().save_png("res://evidence/"+view[0]+".png")==OK)
	var fit:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/wide-camera-fit.json"))
	native_view.size=Vector2i(540,960)
	scene.camera.fov=fit.vertical_fov_degrees
	scene.camera.position=scene.vec(fit.position)
	scene.camera.look_at(scene.vec(fit.target),scene.vec(fit.up))
	scene.update_baked_visibility()
	await process_frame
	await RenderingServer.frame_post_draw
	assert(native_view.get_texture().get_image().save_png("res://evidence/wide-source-camera.png")==OK)
	native_view.size=Vector2i(700,760)
	scene.camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	scene.camera.size=.85
	for view in [["bust-front-uv",Vector3(-.9,1.62,-5.87)],
		["bust-rear-uv",Vector3(-2.63,1.62,-5.87)],
		["bust-side-uv",Vector3(-2.2,1.62,-4.8)]]:
		scene.camera.position=view[1]
		scene.camera.look_at(Vector3(-2.2,1.62,-5.87))
		scene.update_baked_visibility()
		await process_frame
		await RenderingServer.frame_post_draw
		assert(native_view.get_texture().get_image().save_png("res://evidence/"+view[0]+".png")==OK)
	print("REMODEL_VISUAL_PROOF: two walking, nine detail/oblique, eight native-resolution asset views, one source-camera fit and three bust UV views")
	quit()
