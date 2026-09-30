extends SceneTree


func _initialize() -> void:
	call_deferred("capture")


func capture() -> void:
	var scene = (
		load("res://modules/shell/prototype/gallery_walk4/doorway_prototype.tscn").instantiate()
	)
	root.add_child(scene)
	var output := OS.get_cmdline_user_args()[0]
	var failures := 0
	for mesh in scene.find_children("*", "MeshInstance3D", true, false):
		var material = mesh.material_override
		if (
			material is StandardMaterial3D
			and material.albedo_texture
			and material.albedo_texture.resource_path.ends_with("door-far.jpg")
		):
			push_error("Far vestibule still contains its photographic backplate")
			failures += 1
		if (
			material is StandardMaterial3D
			and material.albedo_texture
			and material.albedo_texture.resource_path.ends_with("ivory-trim.svg")
		):
			for surface in mesh.mesh.get_surface_count():
				var arrays: Array = mesh.mesh.surface_get_arrays(surface)
				var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
				var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
				var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
				for index in range(0, indices.size(), 3):
					var a := indices[index]
					var geometric := (vertices[indices[index + 2]] - vertices[a]).cross(
						vertices[indices[index + 1]] - vertices[a]
					)
					if geometric.dot(normals[a]) < -0.000001:
						push_error("Baked ivory winding opposes its face normal")
						failures += 1
	DirAccess.make_dir_recursive_absolute(output)
	for width in [1600, 720]:
		root.size = Vector2i(width, roundi(width * 0.75))
		for index in 4:
			scene.set_view(index)
			for frame in 8:
				await process_frame
			var frame := root.get_texture().get_image()
			frame.save_png(output.path_join("%s-view-%s.png" % [width, index]))
			if index == 0:
				for side in [-1, 1]:
					var pixel := Vector2i(
						scene.camera.unproject_position(Vector3(side * 1.12, 1.4, -26.22))
					)
					var lit := frame.get_pixelv(pixel).get_luminance()
					if lit < 0.08:
						push_error("Mirrored trim is dark: " + str(side) + " luminance=" + str(lit))
						failures += 1
				var floor_pixel := Vector2i(scene.camera.unproject_position(Vector3(0, 0, -27.0)))
				if frame.get_pixelv(floor_pixel).get_luminance() < 0.08:
					push_error("Vestibule floor has lost its baked light")
					failures += 1
	print("DOORWAY_PROFILE failures=", failures)
	quit(1 if failures else 0)
