extends SceneTree

func _initialize() -> void:
	call_deferred("inspect")

func inspect() -> void:
	for file in ["character", "donor"]:
		var model: Node3D = load("res://" + file + ".glb").instantiate()
		root.add_child(model)
		var rig: Skeleton3D = model.find_children("*", "Skeleton3D", true, false)[0]
		print("MODEL ", file, " global=", rig.global_transform)
		for mesh in model.find_children("*", "MeshInstance3D", true, false):
			print("MESH ", mesh.name, " bounds=", mesh.global_transform * mesh.get_aabb())
			if file == "character" and str(mesh.name).contains("Socks"):
				print("SKIN ", mesh.skin.get_bind_count(), " first ", mesh.skin.get_bind_name(0), " ", mesh.skin.get_bind_bone(0), " ", mesh.skin.get_bind_pose(0))
				var minimum := 10000.0
				var arrays = mesh.mesh.surface_get_arrays(0)
				for v in arrays[Mesh.ARRAY_VERTEX].size():
					var p := Vector3.ZERO
					for k in 4:
						var bind: int = arrays[Mesh.ARRAY_BONES][v * 4 + k]
						var b := rig.find_bone(mesh.skin.get_bind_name(bind))
						p += (rig.get_bone_global_pose(b) * mesh.skin.get_bind_pose(bind) * arrays[Mesh.ARRAY_VERTEX][v]) * arrays[Mesh.ARRAY_WEIGHTS][v * 4 + k]
					minimum = minf(minimum, (rig.global_transform * p).y)
				print("SKINNED_MIN ", minimum)
		for i in rig.get_bone_count():
			print(i, " ", rig.get_bone_name(i), " parent=", rig.get_bone_parent(i), " rest=", rig.get_bone_global_rest(i))
		for player in model.find_children("*", "AnimationPlayer", true, false):
			print("ANIM ", player.get_animation_list())
	quit()
