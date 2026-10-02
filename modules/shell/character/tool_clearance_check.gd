extends SceneTree
## Regression from Opus review: actual prop surfaces against the exported, skinned head.
var out_dir := "res://tool-clearance/"
var demo: Node3D
var mesh: MeshInstance3D
var arrays: Array
var skin: Skin
var bone_map := []
var bin: FileAccess
var index := []
var before_hand := Vector3.ZERO


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(out_dir)
	create_timer(900).timeout.connect(func(): quit(2))
	call_deferred("run")


func run() -> void:
	demo = load("res://modules/shell/character/demo.gd").new()
	root.add_child(demo)
	demo.set_physics_process(false)
	await process_frame
	for m in demo.model.find_children("*", "MeshInstance3D", true, false):
		if m.skin != null:
			mesh = m
	skin = mesh.skin
	arrays = mesh.mesh.surface_get_arrays(0)
	for bind in skin.get_bind_count():
		var bone: int = skin.get_bind_bone(bind)
		if bone < 0:
			bone = demo.skeleton.find_bone(skin.get_bind_name(bind))
		bone_map.append(bone)
	static_dump()
	bin = FileAccess.open(out_dir + "poses.bin", FileAccess.WRITE)
	demo.reset()
	demo.tool = "Net"
	for tick in 30:
		demo._physics_process(1.0 / 60)
	for tick in 66:
		demo._physics_process(1.0 / 60)
		capture("idle_net", tick)
	demo.interaction = "Receive"
	demo.interaction_timer = 0
	for tick in 42:
		demo._physics_process(1.0 / 60)
		capture("receive_net", tick)
	for spec in [
		["stand_net", "Net", ""],
		["run_net", "Net", "run"],
		["stand_axe", "Axe", ""],
		["run_axe", "Axe", "run"]
	]:
		demo.reset()
		demo.tool = spec[1]
		for t in 30:
			demo._physics_process(1.0 / 60)
		if spec[2] == "run":
			Input.action_press("down")
		for t in 40 if spec[2] == "run" else 1:
			demo._physics_process(1.0 / 60)
		capture(spec[0], -1)
		demo.jump()
		for t in 130:
			demo._physics_process(1.0 / 60)
			capture(spec[0], t)
		Input.action_release("down")
	for mode in ["stand", "run", "steer"]:
		for offset in range(0, 64, 4):
			demo.reset()
			demo.tool = "Axe"
			for t in 30 + offset:
				demo._physics_process(1.0 / 60)
			if mode == "run":
				Input.action_press("down")
			for t in 40 + offset if mode == "run" else 0:
				demo._physics_process(1.0 / 60)
			demo.jump()
			var samples := 0
			for t in 120:
				before_hand = (
					(
						(
							demo.skeleton.global_transform
							* demo.skeleton.get_bone_global_pose(
								demo.skeleton.find_bone("LeftHand")
							)
						)
						. origin
					)
					- demo.body.global_position
				)
				if mode == "steer" and demo.jump_launched and demo.body.velocity.y <= 0:
					Input.action_press("down")
				demo._physics_process(1.0 / 60)
				if demo.jump_landed and demo.state != "Jump" and samples < 40:
					capture("regrip_" + mode + "_" + str(offset), samples)
					samples += 1
			assert(samples == 40, "Missing axe recovery")
			Input.action_release("down")
	bin.close()
	FileAccess.open(out_dir + "index.json", FileAccess.WRITE).store_string(JSON.stringify(index))
	print("TOOLSURF DONE ", index.size())
	quit()


func capture(label: String, tick: int) -> void:
	demo.skeleton.force_update_all_bone_transforms()
	var inv: Transform3D = demo.model.global_transform.affine_inverse()
	var mats := []
	for bind in skin.get_bind_count():
		mats.append(
			(
				inv
				* demo.skeleton.global_transform
				* demo.skeleton.get_bone_global_pose(bone_map[bind])
				* skin.get_bind_pose(bind)
			)
		)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
	var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
	var out := PackedVector3Array()
	out.resize(verts.size())
	for v in verts.size():
		var p := Vector3.ZERO
		for i in 4:
			var wt: float = weights[v * 4 + i]
			if wt > 0.0:
				p += (mats[bones[v * 4 + i]] * verts[v]) * wt
		out[v] = p
	var offset: int = bin.get_position()
	bin.store_buffer(out.to_byte_array())
	var pts := {}
	var prop: Node3D = demo.tool_meshes[demo.tool]
	for child in prop.get_children():
		if not child is MeshInstance3D:
			continue
		var m: Mesh = child.mesh
		var list := []
		if m is TorusMesh:
			for k in 32:
				var a: float = TAU * k / 32.0
				for j in 4:
					var t: float = TAU * j / 4.0
					list.append(
						Vector3(
							cos(a) * (.17 + .01 * cos(t)),
							.01 * sin(t),
							sin(a) * (.17 + .01 * cos(t))
						)
					)
		elif m is CylinderMesh:
			for k in 11:
				for j in 8:
					list.append(
						Vector3(
							.022 * cos(TAU * j / 8),
							-m.height / 2 + m.height * k / 10.0,
							.022 * sin(TAU * j / 8)
						)
					)
		elif m is BoxMesh:
			var s: Vector3 = m.size
			for ix in 3:
				for iy in 3:
					for iz in 3:
						list.append(
							Vector3((ix - 1) * s.x / 2, (iy - 1) * s.y / 2, (iz - 1) * s.z / 2)
						)
		var kind: String = m.get_class()
		if not pts.has(kind):
			pts[kind] = []
		for p in list:
			var q: Vector3 = inv * (child.global_transform * p)
			pts[kind].append([q.x, q.y, q.z])
	var left: Vector3 = (
		(
			(
				demo.skeleton.global_transform
				* demo.skeleton.get_bone_global_pose(demo.skeleton.find_bone("LeftHand"))
			)
			. origin
		)
		- demo.body.global_position
	)
	index.append(
		{
			"left_before": [before_hand.x, before_hand.y, before_hand.z],
			"left_hand": [left.x, left.y, left.z],
			"label": label,
			"tick": tick,
			"offset": offset,
			"pts": pts,
			"stage": demo.jump_stage,
			"state": demo.state,
			"visible": prop.visible
		}
	)


func static_dump() -> void:
	var vcount: int = arrays[Mesh.ARRAY_VERTEX].size()
	var groups := []
	for v in vcount:
		var w := {}
		for i in 4:
			var wt: float = arrays[Mesh.ARRAY_WEIGHTS][v * 4 + i]
			if wt <= 0:
				continue
			var name: String = demo.skeleton.get_bone_name(
				bone_map[arrays[Mesh.ARRAY_BONES][v * 4 + i]]
			)
			w[name] = w.get(name, 0.0) + wt
		groups.append(w)
	FileAccess.open(out_dir + "static.json", FileAccess.WRITE).store_string(
		JSON.stringify(
			{"vertex_count": vcount, "indices": Array(arrays[Mesh.ARRAY_INDEX]), "groups": groups}
		)
	)
