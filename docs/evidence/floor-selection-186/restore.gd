## #186: copy only the selected floor; retain the current room/lightmap and conform shared edges.
extends SceneTree


func _initialize() -> void:
	var path := "res://modules/shell/prototype/gallery_walk4/baked/room.tscn"
	var room = load(path).instantiate()
	var donor = load(OS.get_cmdline_user_args()[0]).instantiate()
	var floor_mesh: MeshInstance3D = room.get_node("Surface000")
	var selected: MeshInstance3D = donor.get_node("Surface000")
	assert(selected.material_override.shader.resource_path.ends_with("/floor_oak.gdshader"))
	assert(
		selected.material_override.get_shader_parameter("oak").resource_path.ends_with(
			"/oak-board-atlas-168-v3.webp"
		)
	)
	var mesh: ArrayMesh = (
		load("res://modules/shell/prototype/gallery_walk4/walk4.gd")
		. _conform_floor_edges(selected.mesh)
	)
	var arrays := mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var uv2: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV2]
	for i in vertices.size():
		assert(
			(
				uv2[i].distance_to(
					Vector2((vertices[i].x + 5.5) / 11.0, (0.5 - vertices[i].z) / 27.3)
				)
				< 0.00002
			),
			"floor lightmap mapping changed"
		)
	mesh.lightmap_size_hint = floor_mesh.mesh.lightmap_size_hint
	floor_mesh.mesh = mesh
	floor_mesh.material_override = selected.material_override
	var packed := PackedScene.new()
	assert(packed.pack(room) == OK)
	assert(ResourceSaver.save(packed, path) == OK)
	room.free()
	donor.free()
	print(
		"FLOOR186 selected mesh/material restored, shared edges conformed, world-space lightmap UVs verified"
	)
	quit()
