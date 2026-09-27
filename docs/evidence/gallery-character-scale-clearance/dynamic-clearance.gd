extends SceneTree
func mesh_bounds(visitor) -> AABB:
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
	return bounds

func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	for factor in [1.17, 1.42]:
		var visitor = load("res://modules/shell/prototype/gallery_walk4/rig/visitor.gd").new()
		visitor.identity = true
		visitor.world_height = 1.75 * factor
		root.add_child(visitor)
		await process_frame
		visitor.pose(0.0, false, 0.0, Vector3.BACK, 0.0)
		var widest := 0.0
		var deepest := 0.0
		var widest_frame := -1
		for frame in 240:
			visitor.position.z += 1.2 / 60.0
			visitor.pose(1.0 / 60.0, true, 0.0, Vector3.BACK, 0.0)
			if frame % 3 == 0:
				var box := mesh_bounds(visitor)
				var width := maxf(absf(box.position.x), absf(box.end.x))
				deepest = maxf(deepest, maxf(absf(box.position.z-visitor.position.z), absf(box.end.z-visitor.position.z)))
				if width > widest:
					widest = width
					widest_frame = frame
		print("DYNAMIC_CLEARANCE factor=",factor," walking_halfwidth=",widest," deepest=",deepest," widest_frame=",widest_frame," margin_at_door_edge_x_010=",0.95-0.1-widest)
		for frame in 40:
			visitor.pose(1.0 / 60.0, false, 0.0, Vector3.BACK, 0.0)
		visitor.play_gesture("wave")
		var gesture_width := 0.0
		for frame in 78:
			visitor.pose(1.0 / 60.0, false, 0.0, Vector3.BACK, 0.0)
			if frame % 3 == 0:
				var box := mesh_bounds(visitor)
				gesture_width = maxf(gesture_width, maxf(absf(box.position.x), absf(box.end.x)))
		print("GESTURE_CLEARANCE factor=",factor," wave_halfwidth=",gesture_width)
		visitor.queue_free()
		await process_frame
	quit(0)
