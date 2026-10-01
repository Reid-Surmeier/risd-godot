## Second review run on the private v50m copy: plinth collision from three sides, and what the dark floor bars in Rockefeller are.
extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var output: String = OS.get_cmdline_user_args()[0]
	root.size = Vector2i(1440, 1000)
	var app = load("res://modules/shell/demo.tscn").instantiate()
	root.add_child(app)
	for i in 150: await process_frame
	var walk = app.find_child("GalleryWalk", true, false)
	assert(walk != null and walk.state().attached)
	walk.set_process(false)
	walk._entrance_waiting = false
	walk._entrance_active = false
	walk._target_yaw = null
	walk._set_lighting(true)
	var proof := {"plinth_walks": [], "blocks_in_renaissance": [], "rockefeller_low_dark_meshes": []}
	# Plinth footprint in Hall metres: x -10.76..-10.06, z 3.50..4.20. Clearance in the walk is 0.30 m.
	for row in [["from-east", Vector3(-9.72, 0, 3.85), "left"], ["from-north", Vector3(-10.41, 0, 2.6), "down"], ["from-south", Vector3(-10.41, 0, 5.1), "up"]]:
		walk._space = "arch"
		walk.view_mode = 0
		walk.view_yaw = 0.0
		walk._velocity = Vector3.ZERO
		walk._held.clear()
		walk._target = null
		walk._path.clear()
		walk._pos = row[1]
		walk._last_pos = row[1]
		walk._kid.position = row[1]
		walk._update_camera(1.0)
		var ok_start: bool = walk._walkable(row[1])
		walk._held[row[2]] = 0.0
		for i in 150: walk._process(1.0 / 30.0)
		walk._held.clear()
		proof.plinth_walks.append({"name": row[0], "start": [row[1].x, row[1].z], "start_walkable": ok_start, "held": row[2], "end": [walk._pos.x, walk._pos.z],
			"gap_to_plinth_face_m": (walk._pos.x + 10.06) if row[0] == "from-east" else (3.50 - walk._pos.z) if row[0] == "from-north" else (walk._pos.z - 4.20)})
	for block in walk._blocks:
		if block.position.x > -11.2 and block.end.x < -4.9 and block.position.y > -0.1 and block.end.y < 6.2:
			proof.blocks_in_renaissance.append([block.position.x, block.position.y, block.size.x, block.size.y])
	# Rockefeller in Hall metres: x -10.25..-3.85, z -33.1..-26.3.
	for mesh in walk._rooms.find_children("*", "MeshInstance3D", true, false):
		if mesh.mesh == null or mesh.mesh.get_surface_count() == 0:
			continue
		var box: AABB = mesh.global_transform * mesh.mesh.get_aabb()
		if box.position.x < -10.3 or box.end.x > -3.8 or box.position.z < -33.2 or box.end.z > -26.2 or box.end.y > 0.25 or box.size.x > 3 or box.size.z > 3:
			continue
		var m = mesh.material_override
		var colour = m.albedo_color if m is StandardMaterial3D else null
		if colour != null and colour.v > 0.35:
			continue
		proof.rockefeller_low_dark_meshes.append({"name": str(mesh.name), "parent": str(mesh.get_parent().name), "layers": mesh.layers, "visible": mesh.is_visible_in_tree(),
			"box": [box.position.x, box.position.y, box.position.z, box.size.x, box.size.y, box.size.z], "colour": str(colour), "source_path": str(mesh.get_meta("source_path", "")),
			"transparent": m is StandardMaterial3D and m.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED})
	FileAccess.open(output.path_join("native-plinth-v50m.json"), FileAccess.WRITE).store_string(JSON.stringify(proof, "\t") + "\n")
	print("REVIEW_PLINTH_OK")
	quit()
