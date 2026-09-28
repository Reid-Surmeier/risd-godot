## Private #167 saved-scene diagnostic, not a visual acceptance substitute.
extends SceneTree

func _initialize() -> void:
	var scene: Node = load("res://modules/shell/prototype/gallery_walk4/baked/room.tscn").instantiate()
	var reversed := 0
	var stones := 0
	var passage := 0
	for instance in scene.find_children("*", "MeshInstance3D", true, false):
		var material: Material = instance.material_override
		if material is ShaderMaterial and material.get_shader_parameter("floor_z_limits") == Vector2(0, 6.65):
			passage += 1
		if not material is StandardMaterial3D or not material.albedo_texture or not material.albedo_texture.resource_path.ends_with("/stone.png"):
			continue
		stones += 1
		for surface in instance.mesh.get_surface_count():
			var arrays: Array = instance.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			for index in range(0, indices.size(), 3):
				var a := indices[index]
				var b := indices[index + 1]
				var c := indices[index + 2]
				var geometric := (vertices[c] - vertices[a]).cross(vertices[b] - vertices[a])
				if geometric.dot(normals[a] + normals[b] + normals[c]) < -0.000001:
					reversed += 1
	scene.free()
	print("PORTAL_BAKE stone_meshes=", stones, " reversed_triangles=", reversed, " passage_floor=", passage)
	quit(0 if stones == 2 and reversed == 0 and passage == 1 else 1)
