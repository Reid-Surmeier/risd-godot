## #167 saved-bake diagnostic: pale plaster and outward-facing triangle winding.
extends SceneTree


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var room = (
		load(
			(
				args[0]
				if not args.is_empty()
				else "res://modules/shell/prototype/gallery_walk4/baked/room.tscn"
			)
		)
		. instantiate()
	)
	var found := 0
	var reversed := 0
	var failures := 0
	for instance in room.find_children("*", "MeshInstance3D", true, false):
		var material = instance.material_override
		if (
			not material is StandardMaterial3D
			or material.albedo_texture == null
			or not material.albedo_texture.resource_path.ends_with("/cornice-ivory.svg")
		):
			continue
		found += 1
		if material.albedo_color != Color.WHITE:
			failures += 1
		for surface in instance.mesh.get_surface_count():
			var arrays = instance.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			if indices.is_empty():
				indices = PackedInt32Array(range(vertices.size()))
			for triangle in range(0, indices.size(), 3):
				var a := indices[triangle]
				var geometric := (vertices[indices[triangle + 2]] - vertices[a]).cross(
					vertices[indices[triangle + 1]] - vertices[a]
				)
				if geometric.dot(normals[a]) < -0.000001:
					reversed += 1
	room.free()
	print(
		"CORNICE_BAKE meshes=",
		found,
		" reversed_triangles=",
		reversed,
		" tinted_materials=",
		failures
	)
	quit(0 if found > 0 and reversed == 0 and failures == 0 else 1)
