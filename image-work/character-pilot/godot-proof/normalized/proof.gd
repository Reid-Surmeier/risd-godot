extends SceneTree
## THROWAWAY generated character230: raw provider clip import and visible deformation.
var evidence := {"cost_usd": 0, "browser_tested": false, "visual_acceptance": "pending", "clips": {}}

func _initialize() -> void:
	call_deferred("run")

func skin_bounds(model: Node3D, skeleton: Skeleton3D) -> AABB:
	var low := Vector3.INF
	var high := -Vector3.INF
	for mesh in model.find_children("*", "MeshInstance3D", true, false):
		if not mesh.visible:
			continue
		for surface in mesh.mesh.get_surface_count():
			var arrays: Array = mesh.mesh.surface_get_arrays(surface)
			for vertex in arrays[Mesh.ARRAY_VERTEX].size():
				var point := Vector3.ZERO
				for influence in 4:
					var weight: float = arrays[Mesh.ARRAY_WEIGHTS][vertex * 4 + influence]
					if weight == 0:
						continue
					var bind: int = arrays[Mesh.ARRAY_BONES][vertex * 4 + influence]
					var bone: int = mesh.skin.get_bind_bone(bind)
					if bone < 0:
						bone = skeleton.find_bone(mesh.skin.get_bind_name(bind))
					point += (skeleton.get_bone_global_pose(bone) * mesh.skin.get_bind_pose(bind) * arrays[Mesh.ARRAY_VERTEX][vertex]) * weight
				point = skeleton.global_transform * point
				low = low.min(point)
				high = high.max(point)
	return AABB(low, high-low)

func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://" + name + ".png")

func run() -> void:
	root.size = Vector2i(640,640)
	var stage := Node3D.new()
	root.add_child(stage)
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.background_mode = Environment.BG_COLOR
	world.environment.background_color = Color(0.17,0.2,0.24)
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color = Color(0.7,0.7,0.7)
	world.environment.ambient_light_energy = 0.6
	stage.add_child(world)
	var sun := DirectionalLight3D.new()
	sun.light_energy = 1.3
	sun.rotation_degrees = Vector3(-45,-25,0)
	stage.add_child(sun)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	stage.add_child(camera)
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(20,20)
	floor.mesh = plane
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.43,0.4,0.34)
	floor.material_override = material
	stage.add_child(floor)
	var common_center := Vector3.ZERO
	var common_height := 0.0
	for kind in ["idle", "walk"]:
		var model = load("res://" + kind + ".glb").instantiate()
		stage.add_child(model)
		await process_frame
		var skeleton: Skeleton3D = model.find_children("*", "Skeleton3D", true, false)[0]
		var player: AnimationPlayer = model.find_children("*", "AnimationPlayer", true, false)[0]
		player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
		var names := player.get_animation_list()
		assert(names.size() >= 2)
		var clip := ""
		for name in names:
			if name.to_lower() == kind:
				clip = name
		assert(not clip.is_empty(), "missing derived clip " + kind)
		var duration := player.get_animation(clip).length
		var left := skeleton.find_bone("LeftFoot")
		var right := skeleton.find_bone("RightFoot")
		assert(skeleton.get_bone_count() == 24 and left >= 0 and right >= 0)
		var bone_names := []
		var rest := []
		for bone in skeleton.get_bone_count():
			bone_names.append(skeleton.get_bone_name(bone))
			rest.append({"name": skeleton.get_bone_name(bone), "parent": skeleton.get_bone_parent(bone), "rest": str(skeleton.get_bone_rest(bone))})
		var mesh_info := []
		for mesh in model.find_children("*","MeshInstance3D",true,false):
			mesh_info.append({"name":mesh.name,"visible":mesh.visible,"transform":str(mesh.global_transform)})
		var bounds := skin_bounds(model,skeleton)
		if common_height == 0:
			common_height = bounds.size.y
			common_center = bounds.get_center()
			floor.position.y = bounds.position.y-0.015
			camera.size = common_height*1.45
			camera.position = common_center + Vector3(-0.55,0.25,2.5)*common_height
			camera.look_at(common_center)
		player.play(clip)
		var feet := []
		var bounds_samples := []
		var matrices := []
		for index in 8:
			var time := duration*index/8.0
			player.seek(time,true)
			skeleton.force_update_all_bone_transforms()
			var foot_pose := skeleton.get_bone_global_pose(left)
			matrices.append(str(foot_pose))
			feet.append({"time":time,"left":str(skeleton.global_transform*foot_pose.origin),"right":str(skeleton.global_transform*skeleton.get_bone_global_pose(right).origin),"head_global_pose_scale":str(skeleton.get_bone_global_pose(skeleton.find_bone("Head")).basis.get_scale()),"hips_local_pose_scale":str(skeleton.get_bone_pose_scale(skeleton.find_bone("Hips")))})
			var pose_bounds := skin_bounds(model,skeleton)
			bounds_samples.append({"time":time,"min":str(pose_bounds.position),"max":str(pose_bounds.end),"height":pose_bounds.size.y,"min_relative_to_review_floor":pose_bounds.position.y-floor.position.y})
			if kind == "walk":
				await capture("walk-%02d" % index)
				if index == 2:
					var before := camera.transform
					camera.position = common_center + Vector3(2.5,0.15,0)*common_height
					camera.look_at(common_center)
					await capture("walk-side")
					camera.transform = before
			elif index == 0:
				await capture("idle")
			elif index == 4:
				await capture("idle-mid")
		assert(matrices[0] != matrices[4], "foot did not animate")
		evidence.clips[kind] = {"bones":skeleton.get_bone_count(),"bone_names":bone_names,"bone_rest":rest,"skeleton_global_transform":str(skeleton.global_transform),"imported_clip_names":names,"seconds":duration,"foot_transform_changed":true,"feet_samples":feet,"skin_bounds_samples":bounds_samples,"rest_skin_bounds":{"min":str(bounds.position),"max":str(bounds.end),"height":bounds.size.y},"mesh_nodes":mesh_info}
		model.queue_free()
		await process_frame
	evidence["godot"] = Engine.get_version_info().string
	evidence["renderer"] = "Native Compatibility, no runtime integration"
	evidence["framing"] = "Shared camera/floor from idle skinned rest bounds; no model scale correction"
	FileAccess.open("res://evidence.json",FileAccess.WRITE).store_string(JSON.stringify(evidence,"  ")+"\n")
	print("TARGET_GODOT_PROOF idle/walk imported; 24 bones each; foot transforms changed; 8 walk frames captured")
	quit(0)
