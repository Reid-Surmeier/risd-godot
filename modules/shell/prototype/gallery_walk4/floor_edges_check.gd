## #177: a shared floor edge must have two triangles, never a rasterization gap.
extends SceneTree

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var path := args[0] if not args.is_empty() else "res://modules/shell/prototype/gallery_walk4/baked/room.tscn"
	var room = load(path).instantiate()
	var floor_mesh: MeshInstance3D = room.get_node("Surface000")
	var vertices: PackedVector3Array = floor_mesh.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var edges := {}
	for triangle in range(0, vertices.size(), 3):
		for side in 3:
			var a := Vector3i((vertices[triangle + side] * 100000.0).round())
			var b := Vector3i((vertices[triangle + (side + 1) % 3] * 100000.0).round())
			var key := str(a) + str(b) if a < b else str(b) + str(a)
			var midpoint := Vector3(a + b) / 200000.0
			if absf(midpoint.y) < 0.0001 and absf(midpoint.x) < 4.25 and midpoint.z < -0.5 and midpoint.z > -25.8:
				edges[key] = edges.get(key, 0) + 1
	var unmatched := 0
	for count in edges.values():
		if count != 2:
			unmatched += 1
	room.free()
	print("FLOOR_EDGES unmatched interior edges=", unmatched)
	quit(0 if unmatched == 0 else 1)
