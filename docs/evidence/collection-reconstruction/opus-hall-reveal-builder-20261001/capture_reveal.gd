## Private CPU capture of the room project before its bake (draft light), at the source cameras.
## LIBGL_ALWAYS_SOFTWARE=1 xvfb-run -a godot --display-driver x11 --rendering-method gl_compatibility --path PREPARED_COPY -s capture_reveal.gd -- OUT_DIR
extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var output: String = OS.get_cmdline_user_args()[0]
	root.size = Vector2i(720, 1280)
	var scene = load("res://remodel_room.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_physics_process(false)
	scene.set_process(false)
	scene.visitor.hide()
	scene.contact_shadow.hide()
	scene.label.get_parent().hide()
	var wall: float = JSON.parse_string(FileAccess.get_file_as_string("res://geometry.json")).get("hall_reveal", {"wall_m": 0.0}).wall_m
	# The full app's walk removes the old demo tunnel behind the Hall's end wall
	# (main_build_walk.gd _set_lighting); the same rule here, on this copy's live meshes only.
	var hall: Node3D = scene.get_node("ConnectedHall")
	var removed := 0
	for mesh in hall.find_children("*", "MeshInstance3D", true, false):
		if mesh.mesh == null or not mesh.visible:
			continue
		var floor := mesh.material_override as ShaderMaterial
		if floor != null and floor.get_shader_parameter("floor_z_limits") is Vector2:
			continue
		if (mesh.global_transform * mesh.mesh.get_aabb()).position.z >= 1.8 - .19:
			continue
		var clipped := ArrayMesh.new()
		for surface in mesh.mesh.get_surface_count():
			var arrays: Array = mesh.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array(range(vertices.size()))
			if indices.is_empty():
				indices = PackedInt32Array(range(vertices.size()))
			var kept := PackedInt32Array()
			for i in range(0, indices.size(), 3):
				var outside := false
				for vertex in indices.slice(i, i + 3):
					outside = outside or (mesh.global_transform * vertices[vertex]).z < 1.8 - .19
				if outside:
					removed += 1
				else:
					kept.append_array(indices.slice(i, i + 3))
			if kept.is_empty():
				continue
			arrays[Mesh.ARRAY_INDEX] = kept
			clipped.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
			clipped.surface_set_material(clipped.get_surface_count() - 1, mesh.mesh.surface_get_material(surface))
		mesh.mesh = clipped
	var lightmap = hall.get_node_or_null("Lightmap")
	if lightmap:
		var saved = lightmap.light_data
		lightmap.light_data = null
		lightmap.light_data = saved
	var camera := Camera3D.new()
	scene.add_child(camera)
	camera.fov = 67.0 # 26-30 mm phone lens held upright
	camera.cull_mask = 0xFFFFF
	camera.make_current()
	var grey := 1.8 - wall # the grey gallery's south wall plane
	var proof: Array = []
	for view in [
		["grey-front-as-6343-0.5s", Vector3(5.5, 1.45, grey - 4.6), Vector3(5.55, 1.25, 1.8)],
		["grey-oblique-as-6343-35s", Vector3(8.6, 1.5, grey - 4.2), Vector3(5.55, 1.3, grey + .4)],
		["grey-close-as-6380-106s", Vector3(4.5, 1.15, grey - 1.9), Vector3(6.2, 1.45, grey + .5)],
		["hall-side-as-6344-25s", Vector3(5.55, 1.5, 8.8), Vector3(5.55, 1.4, 1.8)],
		["rockefeller-door-as-6385-1s", Vector3(-1.6, 1.45, 4.6), Vector3(-2.9, 1.4, 1.4)],
	]:
		camera.look_at_from_position(view[1], view[2], Vector3.UP)
		for i in 4:
			await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(output.path_join(view[0] + ".png")) == OK)
		proof.append({"view": view[0], "eye": [view[1].x, view[1].y, view[1].z], "target": [view[2].x, view[2].y, view[2].z]})
	# Plan from above: ceilings off, so the wall's thickness shows.
	for item in scene.ceiling_details:
		item.hide()
	for mesh in hall.find_children("*", "MeshInstance3D", true, false):
		if mesh.mesh != null and (mesh.global_transform * mesh.mesh.get_aabb()).position.y > 2.9:
			mesh.hide()
	root.size = Vector2i(1280, 800)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 9.0
	camera.look_at_from_position(Vector3(3.2, 20, .2), Vector3(3.2, 0, .2), Vector3.FORWARD)
	for i in 4:
		await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join("plan-wall-line.png")) == OK)
	FileAccess.open(output.path_join("capture.json"), FileAccess.WRITE).store_string(JSON.stringify({"wall_m": wall, "hall_tunnel_triangles_removed": removed, "renderer": RenderingServer.get_video_adapter_name(), "baked": scene.inventory.has("native_lightmap_users"), "views": proof}, "\t") + "\n")
	print("REVEAL_CAPTURE_OK ", RenderingServer.get_video_adapter_name())
	quit()
