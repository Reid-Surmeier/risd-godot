extends SceneTree
func _initialize() -> void:
	var before = load('/tmp/room-before-189.tscn').instantiate()
	var after = load('res://modules/shell/prototype/gallery_walk4/baked/room.tscn').instantiate()
	assert(before.get_child_count() == after.get_child_count())
	var count := 0
	for a in before.get_children():
		var b = after.get_node(NodePath(a.name))
		assert(a.transform == b.transform)
		if a is MeshInstance3D:
			assert(a.mesh.get_surface_count() == b.mesh.get_surface_count())
			for i in a.mesh.get_surface_count():
				assert(var_to_bytes(a.mesh.surface_get_arrays(i)) == var_to_bytes(b.mesh.surface_get_arrays(i)))
			count += 1
	print('UNCHANGED mesh geometry, normals, UVs and transforms: ', count)
	before.free()
	after.free()
	quit()
