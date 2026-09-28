## Private #167 form-only feedback loop; not a saved-room or visual release gate.
extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var args := OS.get_cmdline_user_args()
	assert(args.size() == 1, "Supply an output directory")
	var output: String = args[0]
	DirAccess.make_dir_recursive_absolute(output)
	var walk = load("res://modules/shell/prototype/gallery_walk4/walk4.gd").new()
	root.add_child(walk)
	walk.set_process(false)
	walk._set_lighting(false)
	var stage := Node3D.new()
	root.add_child(stage)
	for source in walk._vp.find_children("*", "MeshInstance3D", true, false):
		if not source.is_visible_in_tree() or not source.material_override is ShaderMaterial:
			continue
		var texture = source.material_override.get_shader_parameter("albedo")
		if not texture or not texture.resource_path.ends_with("/stone.png"):
			continue
		var copy := MeshInstance3D.new()
		copy.mesh = source.mesh
		copy.transform = source.global_transform
		var material := StandardMaterial3D.new()
		material.albedo_color = Color("#c7bca6")
		material.roughness = 1.0
		material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
		copy.material_override = material
		stage.add_child(copy)
	# Keep the source viewport alive but inactive until shutdown; freeing its
	# just-created lightmap before the first draw triggers a renderer warning.
	walk.hide()
	walk._vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color("#343c42")
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color = Color.WHITE
	world.environment.ambient_light_energy = 0.15
	stage.add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-35, -25, 0)
	light.light_energy = 1.0
	stage.add_child(light)
	var camera := Camera3D.new()
	stage.add_child(camera)
	for size in [720, 1600]:
		root.size = Vector2i(size, size)
		for view in [9, 10]:
			camera.position = Vector3(0, 2.1, 6.5) if view == 9 else Vector3(2.2, 1.8, 4.1)
			camera.fov = 54 if view == 9 else 48
			camera.look_at(Vector3(0, 2.1, 1.6) if view == 9 else Vector3(0.95, 1.8, 1.6))
			for frame in 4:
				await process_frame
			await RenderingServer.frame_post_draw
			var path := output.path_join("%d-view-%d.png" % [size, view])
			assert(root.get_texture().get_image().save_png(path) == OK)
			print("PORTAL_SCULPTURE_PROBE ", path)
	quit()
