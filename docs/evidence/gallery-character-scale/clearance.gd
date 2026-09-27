extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	for factor in [1.17, 1.42]:
		var visitor = load("res://modules/shell/prototype/gallery_walk4/rig/visitor.gd").new()
		visitor.identity = true
		visitor.world_height = 1.75 * factor
		root.add_child(visitor)
		await process_frame
		for heading in [Vector3.BACK, Vector3.RIGHT]:
			visitor.pose(0.0, false, 0.0, heading, 0.0)
			var skin: Skin = visitor.body.skin
			var bounds := AABB()
			var first := true
			var low_x := 0.0
			for surface in visitor.body.mesh.get_surface_count():
				var arrays: Array = visitor.body.mesh.surface_get_arrays(surface)
				var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
				var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
				var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
				for index in vertices.size():
					var point := Vector3.ZERO
					for influence in 4:
						var bind := bones[index * 4 + influence]
						var bone: int = skin.get_bind_bone(bind)
						if bone < 0:
							bone = visitor.skeleton.find_bone(skin.get_bind_name(bind))
						point += (visitor.skeleton.get_bone_global_pose(bone) * skin.get_bind_pose(bind) * vertices[index]) * weights[index * 4 + influence]
					point = visitor.skeleton.global_transform * point
					bounds = AABB(point, Vector3.ZERO) if first else bounds.expand(point)
					first = false
					if point.y < 0.6:
						low_x = maxf(low_x, absf(point.x))
			print("CLEARANCE factor=",factor," heading=",heading," min=",bounds.position," max=",bounds.end," bench_low_halfwidth=",low_x," wall_x_overrun=",maxf(0,bounds.end.x-0.55)," door_edge_overrun=",maxf(0,0.4+bounds.end.x-0.95))
		visitor.queue_free()
		await process_frame
	quit(0)
