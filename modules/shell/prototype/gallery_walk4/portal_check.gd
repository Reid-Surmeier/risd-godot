## Private #167 saved-scene diagnostic, not a visual acceptance substitute.
extends SceneTree


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var source_mode := "--source" in OS.get_cmdline_user_args()
	var scene: Node
	var walk: Control
	if source_mode:
		walk = load("res://modules/shell/prototype/gallery_walk4/walk4.gd").new()
		walk.set_process(false)
		root.add_child(walk)
		walk._set_lighting(false)
		scene = walk._vp
	else:
		scene = load("res://modules/shell/prototype/gallery_walk4/baked/room.tscn").instantiate()
	var reversed := 0
	var relief_winding := 0
	var stones := 0
	var passage := 0
	for instance in scene.find_children("*", "MeshInstance3D", true, false):
		if source_mode and not instance.is_visible_in_tree():
			continue
		var material: Material = instance.material_override
		relief_winding += int(instance.get_meta("portal_relief_winding_failures", 0))
		if (
			instance.get_meta("portal_floor", false)
			or (
				material is ShaderMaterial
				and material.get_shader_parameter("floor_z_limits") == Vector2(0, 6.65)
			)
		):
			passage += 1
		var texture = (
			material.albedo_texture
			if material is StandardMaterial3D
			else (material.get_shader_parameter("albedo") if material is ShaderMaterial else null)
		)
		if not texture or not texture.resource_path.ends_with("/stone.png"):
			continue
		stones += 1
		for surface in instance.mesh.get_surface_count():
			var arrays: Array = instance.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			var indices: PackedInt32Array = (
				arrays[Mesh.ARRAY_INDEX]
				if arrays[Mesh.ARRAY_INDEX] != null
				else PackedInt32Array(range(vertices.size()))
			)
			for index in range(0, indices.size(), 3):
				var a := indices[index]
				var b := indices[index + 1]
				var c := indices[index + 2]
				var geometric := (vertices[c] - vertices[a]).cross(vertices[b] - vertices[a])
				if geometric.dot(normals[a] + normals[b] + normals[c]) < -0.000001:
					reversed += 1
	if source_mode:
		walk.free()
	else:
		scene.free()
	print(
		"PORTAL_SOURCE" if source_mode else "PORTAL_BAKE",
		" stone_meshes=",
		stones,
		" reversed_triangles=",
		reversed,
		" relief_winding=",
		relief_winding,
		" passage_floor=",
		passage
	)
	quit(0 if stones == 2 and reversed == 0 and relief_winding == 0 and passage == 1 else 1)
