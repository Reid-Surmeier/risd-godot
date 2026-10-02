## Review run on a private, unbaked copy of root's prepared room project v49v: where the new Renaissance pieces
## stand against their walls, and pictures from about the footage's poses. Reads the scene; changes nothing in it.
extends SceneTree

var scene
var vp: SubViewport
var output: String

func _initialize() -> void:
	call_deferred("run")

func box_of(node: Node) -> AABB:
	var out := AABB()
	var first := true
	var meshes: Array = [node] if node is MeshInstance3D else []
	meshes.append_array(node.find_children("*", "MeshInstance3D", true, false))
	for mesh in meshes:
		if mesh.mesh == null or mesh.mesh.get_surface_count() == 0:
			continue
		var b: AABB = mesh.global_transform * mesh.mesh.get_aabb()
		out = b if first else out.merge(b)
		first = false
	return out

func row(b: AABB) -> Dictionary:
	return {"min": [snappedf(b.position.x, 0.001), snappedf(b.position.y, 0.001), snappedf(b.position.z, 0.001)],
		"max": [snappedf(b.end.x, 0.001), snappedf(b.end.y, 0.001), snappedf(b.end.z, 0.001)]}

func owner_tag(node: Node) -> String:
	var p := node.get_parent()
	while p != null and p != scene:
		if p.has_meta("room_wall"):
			return str(p.get_meta("room_wall"))
		p = p.get_parent()
	return "none"

func shot(name: String, eye: Vector3, target: Vector3, fov: float, portrait := true) -> void:
	vp.size = Vector2i(608, 1080) if portrait else Vector2i(1100, 760)
	scene.camera.fov = fov
	scene.camera.keep_aspect = Camera3D.KEEP_HEIGHT
	scene.camera.position = eye
	scene.camera.look_at(target)
	scene.update_baked_visibility()
	for i in 12: await process_frame
	await RenderingServer.frame_post_draw
	assert(vp.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK)

func run() -> void:
	output = OS.get_cmdline_user_args()[0]
	root.size = Vector2i(1100, 1080)
	var presenter = load("res://remodel_presenter.tscn").instantiate()
	root.add_child(presenter)
	scene = presenter.scene
	scene.set_physics_process(false)
	scene.visitor.hide()
	scene.contact_shadow.hide()
	for body in scene.casings:
		for child in body.get_children():
			if not child is CollisionShape3D:
				child.show()
	vp = scene.get_viewport()
	vp.get_parent().stretch = false
	for i in 20: await process_frame
	var proof := {"walls": {}, "wall_objects": {}, "east_cases": {}, "other": {}, "label_proxies": [], "inventory": {}}
	for body in scene.casings:
		var tag := str(body.get_meta("room_wall", ""))
		if tag.begins_with("light Renaissance room:"):
			var face: MeshInstance3D = body.get_child(1)
			var entry: Dictionary = row(face.global_transform * face.mesh.get_aabb())
			entry["children"] = body.get_child_count()
			if not proof.walls.has(tag):
				proof.walls[tag] = []
			proof.walls[tag].append(entry)
	for node in scene.find_children("*", "Node3D", true, false):
		if node.has_meta("renaissance_wall_object"):
			var parts := {}
			var hood := AABB()
			var hood_first := true
			for mesh in node.find_children("*", "MeshInstance3D", true, false):
				if mesh.mesh == null or mesh.mesh.get_surface_count() == 0:
					continue
				var b: AABB = mesh.global_transform * mesh.mesh.get_aabb()
				if mesh.has_meta("velvet_hood_pane"):
					hood = b if hood_first else hood.merge(b)
					hood_first = false
				elif mesh.has_meta("artwork_label_proxy"):
					parts["label proxy"] = row(b)
				else:
					var key := str(mesh.name)
					parts[key] = row(b if not parts.has(key) else b)
			var flags := {}
			for key in node.get_meta_list():
				if str(key).ends_with("accepted") or str(key).ends_with("resolved"):
					flags[key] = node.get_meta(key)
			proof.wall_objects[str(node.get_meta("renaissance_wall_object"))] = {"origin": [node.global_position.x, node.global_position.y, node.global_position.z],
				"owner": owner_tag(node), "parts": parts, "hood": row(hood) if not hood_first else null, "flags": flags,
				"wall_behind_origin": node.get_meta("wall_behind_origin", null)}
		if node.has_meta("renaissance_wall_case"):
			var objects := {}
			for item in node.find_children("*", "Node3D", true, false):
				if item.has_meta("renaissance_case_object"):
					objects[str(item.get_meta("renaissance_case_object"))] = row(box_of(item))
			proof.east_cases[str(node.get_meta("renaissance_wall_case"))] = {"all": row(box_of(node)), "owner": owner_tag(node), "objects": objects}
		for key in ["renaissance_textile_platform", "renaissance_textile_label", "triptych_wall_case", "pieta_wall_case", "saint_roch_installation"]:
			if node.has_meta(key):
				if not proof.other.has(key):
					proof.other[key] = []
				proof.other[key].append({"box": row(box_of(node)), "owner": owner_tag(node), "collides": node is StaticBody3D})
	# The west window: two plain white solids near x -5.45, z 31.95.
	for mesh in scene.find_children("*", "MeshInstance3D", true, false):
		if mesh.mesh is BoxMesh and absf(mesh.global_position.z - 31.95) < 0.01 and mesh.global_position.x < -5.3 and mesh.get_parent() == scene:
			if not proof.other.has("west_window_pieces"):
				proof.other["west_window_pieces"] = []
			proof.other["west_window_pieces"].append(row(mesh.global_transform * mesh.mesh.get_aabb()))
	for key in ["renaissance_wall_assets", "renaissance_case_objects", "renaissance_triptych", "renaissance_pieta", "saint_roch", "renaissance_verified_paintings"]:
		proof.inventory[key] = scene.inventory.get(key)
	var flags := {}
	for key in scene.inventory:
		if str(key).ends_with("accepted") or str(key).ends_with("complete"):
			flags[key] = scene.inventory[key]
	proof.inventory["top_level_flags"] = flags
	FileAccess.open(output.path_join("native-install-v49v.json"), FileAccess.WRITE).store_string(JSON.stringify(proof, "\t") + "\n")
	# Pictures at about the footage's poses, eye level, portrait like the footage.
	await shot("pose-6383-68.5s-south-wall", Vector3(-3.05, 1.5, 31.05), Vector3(-2.85, 1.25, 34.1), 71.0)
	await shot("pose-6383-60.6s-along-south-wall", Vector3(-1.2, 1.5, 33.0), Vector3(-5.4, 1.2, 33.2), 71.0)
	await shot("pose-6383-6.1s-velvet", Vector3(-0.5, 1.5, 32.0), Vector3(-1.9, 1.1, 34.1), 71.0)
	await shot("pose-6383-11.5s-woodcutters", Vector3(-2.5, 1.5, 32.6), Vector3(-3.25, 1.55, 34.1), 71.0)
	await shot("pose-6383-15.1s-madonna", Vector3(-3.3, 1.5, 33.6), Vector3(-5.48, 1.25, 33.2), 71.0)
	await shot("pose-6383-41.2s-east-case-a", Vector3(-0.75, 1.55, 29.2), Vector3(0.35, 1.4, 29.8), 71.0)
	await shot("pose-6383-55.6s-east-case-b", Vector3(-0.75, 1.6, 33.85), Vector3(0.35, 1.35, 33.2), 71.0)
	await shot("wide-south-and-west", Vector3(-0.6, 1.6, 29.3), Vector3(-4.3, 1.2, 33.6), 62.0, false)
	await shot("wide-east-wall", Vector3(-4.6, 1.55, 31.75), Vector3(0.5, 1.4, 31.75), 62.0, false)
	await shot("wide-north-wall", Vector3(-2.6, 1.55, 33.2), Vector3(-2.8, 1.45, 28.1), 62.0, false)
	await shot("check-triptych-case-from-above", Vector3(-4.5, 2.9, 28.75), Vector3(-4.5, 1.0, 28.2), 50.0, false)
	await shot("check-label-stands-on-platform", Vector3(-2.5, 0.75, 32.9), Vector3(-2.5, 0.3, 33.9), 50.0, false)
	await shot("check-velvet-hood-side", Vector3(-0.9, 1.75, 33.75), Vector3(-1.775, 1.7, 34.1), 50.0, false)
	print("REVIEW_INSTALL_OK")
	quit()
