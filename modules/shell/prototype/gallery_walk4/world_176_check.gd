## #176 private source geometry regression, before static merging hides metadata.
extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var args := OS.get_cmdline_user_args()
	var walk = load(args[0] if not args.is_empty() else "res://modules/shell/prototype/gallery_walk4/walk4.gd").new()
	walk._vp = SubViewport.new()
	root.add_child(walk._vp)
	assert(absf(walk._bench_surface(0.475, 0.0).y - walk._bench_surface(0.385 + 0.09 / sqrt(2.0), 1.41 + 0.09 / sqrt(2.0)).y) < 0.0001, "rounded corner rim rises above straight rim")
	# #177: pin the owner's selected appearance against later asset substitutions.
	assert(walk.PLANK == Vector2(1.9, 0.36), "owner-selected parquet scale changed")
	assert(walk._wall_ps().get_shader_parameter("albedo").resource_path.ends_with("/wall-muse.webp"), "owner-selected wall texture changed")
	walk._build_room()
	walk._build_paintings()
	var legs := 0
	var vents := 0
	var captions := 0
	var cushions := 0
	var selected_floor := false
	for mesh in walk._vp.find_children("*", "MeshInstance3D", true, false):
		if mesh.material_override is ShaderMaterial and mesh.material_override.get_shader_parameter("plank_seams") == true:
			selected_floor = mesh.material_override.get_shader_parameter("albedo").resource_path.ends_with("/oak-board-atlas-168-v3.webp")
		legs += int(mesh.get_meta("bench_leg", false))
		vents += int(mesh.get_meta("wall_vent", false))
		captions += int(mesh.get_meta("caption_plate", false))
		if mesh.get_meta("bench_cushion", false):
			cushions += 1
			var arrays: Array = mesh.mesh.surface_get_arrays(0)
			var uv: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
			var side_start := 96 * 32 * 6
			assert(absf(uv[side_start].x - uv[side_start + 1].x) > 0.001, "side quad stretches a single texture column")
			var bounds: AABB = mesh.mesh.get_aabb()
			assert(bounds.size.y > 0.11 and bounds.end.y <= 0.421, "owner-selected cushion envelope changed")
	assert(legs == 16 and vents == 6 and captions == 23 and cushions == 2)
	assert(walk._paintings.size() == 23)
	assert(selected_floor, "owner-selected lighter parquet texture changed")
	walk._vp.free()
	walk.free()
	print("WORLD176 source: 16 turned supports, 2 owner-selected cushions, 6 vents, 23 caption plates PASS")
	quit()
