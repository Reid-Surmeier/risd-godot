## #277 review only: existing picking/inspection/zoom adapters, at #278's 695x465 game size.
## Run in the unbaked draft after copying the unchanged character/icons and external zooms.
extends SceneTree

const SIZE := Vector2i(695, 465)


func _initialize() -> void:
	call_deferred("run")


func arg(name: String) -> String:
	for value in OS.get_cmdline_user_args():
		if value.begins_with("--" + name + "="):
			return value.get_slice("=", 1)
	return ""


func run() -> void:
	DirAccess.make_dir_recursive_absolute(arg("out"))
	root.size = SIZE
	var walk = load(arg("walk")).new()
	walk.size = Vector2(SIZE)
	root.add_child(walk)
	await process_frame
	if walk._rooms == null and walk._rooms_path != "":
		walk._attach_rooms(walk._rooms_path)
	for i in 30:
		await process_frame
	var records: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/additions/impressionist/catalogue.json"))
	var failures := []
	var measured := []
	var unwrapped_surfaces := 0
	for accession in records:
		var record: Dictionary = records[accession]
		var painting := {}
		for candidate in walk._objects:
			if str(candidate.rec.acc) == accession:
				painting = candidate
		if painting.is_empty():
			failures.append(accession + ": not clickable")
			continue
		# The unchanged bake adapter recognises the stock shader and unwraps these
		# exact surfaces. Duplicate only: this check neither bakes nor saves a scene.
		for child in painting.node.get_children():
			if not child is MeshInstance3D:
				continue
			var material: ShaderMaterial = child.material_override
			if not material.shader.resource_path.ends_with("/ps1.gdshader"):
				failures.append(accession + ": material bypasses the stock bake conversion")
			var source := SurfaceTool.new()
			source.begin(Mesh.PRIMITIVE_TRIANGLES)
			for surface in child.mesh.get_surface_count():
				source.append_from(child.mesh, surface, Transform3D.IDENTITY)
			var duplicate := source.commit()
			if duplicate.lightmap_unwrap(child.global_transform, .14) != OK:
				failures.append(accession + ": UV2 unwrap failed")
			unwrapped_surfaces += 1
		walk._new_action()
		walk._target = null
		walk._held.clear()
		walk._velocity = Vector3.ZERO
		walk._pos = painting.center + painting.normal * 2.0
		walk._pos.y = 0.0
		walk._last_pos = walk._pos
		walk._kid.position = walk._pos
		walk._space = "far"
		walk._cut_state = 0
		walk._floor_mask_stage = -2
		walk.view_mode = 0
		walk.view_yaw = atan2(painting.normal.x, painting.normal.z)
		walk._yaw = walk.view_yaw
		for i in 30:
			await process_frame
		var picked: Dictionary = walk._painting_at(walk._to_screen(painting.center))
		if str(picked.get("rec", {}).get("acc", "")) != accession:
			failures.append(accession + ": projected centre picked a different work")
		walk._open_detail(painting)
		await create_timer(.85).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(arg("out").path_join(accession + "-inspect.png"))
		if walk._catalogue_zoom._texture != null:
			failures.append(accession + ": full zoom was loaded before opening")
		# The builder's fourth surface is the canvas, with the catalogue dimensions.
		var canvas: MeshInstance3D = painting.node.get_child(3)
		var box := canvas.mesh.get_aabb()
		var corners := [box.position, box.position + Vector3(box.size.x, 0, 0), box.end, box.position + Vector3(0, box.size.y, 0)]
		var pixels := []
		for corner in corners:
			pixels.append(walk._cam.unproject_position(canvas.global_transform * corner))
		var width: float = maxf(pixels[0].distance_to(pixels[1]), pixels[2].distance_to(pixels[3]))
		var height: float = maxf(pixels[0].distance_to(pixels[3]), pixels[1].distance_to(pixels[2]))
		var wall_long: int = record.image_resolution.images.wall.required_long_side
		if maxf(width, height) > wall_long:
			failures.append(accession + ": wall photograph is smaller than its inspected canvas")
		walk._open_detail(painting)
		await create_timer(.35).timeout
		await RenderingServer.frame_post_draw
		var texture: Texture2D = walk._zoom_root.get_node("Painting").texture
		var expected: Array = record.image_resolution.images.zoom_external.pixels
		if texture.get_size() != Vector2(expected[0], expected[1]):
			failures.append(accession + ": full zoom pixels differ from record")
		root.get_texture().get_image().save_png(arg("out").path_join(accession + "-zoom.png"))
		measured.append({"accession": accession, "room": walk._plan[painting.room].label,
			"canvas_metres": [box.size.x, box.size.y], "frame_metres": [painting.node.outer.x, painting.node.outer.y],
			"inspected_canvas_px": [width, height], "wall_long_px": wall_long,
			"full_zoom_px": [texture.get_width(), texture.get_height()]})
		walk._close_detail()
		for i in 50:
			await process_frame
	var result := {"viewport": [SIZE.x, SIZE.y], "works": measured, "uv2_surfaces": unwrapped_surfaces, "failures": failures}
	var output := FileAccess.open(arg("out").path_join("catalogue-check.json"), FileAccess.WRITE)
	output.store_string(JSON.stringify(result, "\t") + "\n")
	print("IMPRESSIONIST_CATALOGUE_CHECK ", JSON.stringify(result))
	quit(0 if failures.is_empty() else 1)
