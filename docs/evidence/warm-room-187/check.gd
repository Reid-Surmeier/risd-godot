extends SceneTree


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	root.size = Vector2i(720, 720)
	var scene = (
		load("res://modules/shell/prototype/gallery_walk4/doorway_prototype.tscn").instantiate()
	)
	root.add_child(scene)
	var tag := "after" if "--after" in OS.get_cmdline_user_args() else "before"
	var minimum := 1.0
	var normal_failures := 0
	var reveal_vertices := 0
	for mesh in scene.get_child(0).find_children("*", "MeshInstance3D", true, false):
		var bounds: AABB = mesh.mesh.get_aabb()
		if absf(bounds.size.z - 0.45) > 0.001 or bounds.size.y < 3.0:
			continue
		var arrays: Array = mesh.mesh.surface_get_arrays(0)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
		for i in vertices.size():
			var v := vertices[i]
			if absf(absf(v.x) - 0.95) < 0.001 and v.y > 0.5 and v.y < 2.0:
				reveal_vertices += 1
				if normals[i].dot(Vector3(-signf(v.x), 0, 0)) < 0.99:
					normal_failures += 1
	print("REVEAL_NORMALS vertices=", reveal_vertices, " outward=", normal_failures)
	for side in [-1, 1]:
		scene.camera.position = Vector3(-side * 2.0, 1.8, -3.0)
		scene.camera.look_at(Vector3(0, 1.5, 0.2))
		scene.camera.fov = 48
		for frame in 8:
			await process_frame
		var shot := root.get_texture().get_image()
		shot.save_png("res://docs/evidence/warm-room-187/%s-reveal-%s.png" % [tag, side])
		var p: Vector2 = scene.camera.unproject_position(Vector3(side * 0.95, 1.3, 0.2))
		var luminance := 0.0
		for y in range(-2, 3):
			for x in range(-2, 3):
				luminance += shot.get_pixelv(Vector2i(p) + Vector2i(x, y)).get_luminance() / 25.0
		print("REVEAL side=", side, " luminance=", luminance)
		minimum = minf(minimum, luminance)
	for view in [12, 13, 17]:
		scene.set_view(view)
		for frame in 8:
			await process_frame
		root.get_texture().get_image().save_png(
			"res://docs/evidence/warm-room-187/%s-view-%s.png" % [tag, view]
		)
	print("REVEAL_CHECK ", "PASS" if minimum > 0.20 else "FAIL", " min=", minimum)
	quit(0 if minimum > 0.20 and reveal_vertices > 0 and normal_failures == 0 else 1)
