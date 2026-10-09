## Each registered room work's node, parts and room bounds as JSON, for placement_rectify.py (#266).
## godot --headless --path . --script res://modules/shell/prototype/collection_reconstruction/placement_dump.gd -- parts.json
extends SceneTree


func _initialize() -> void:
	call_deferred("run")


func texture_file(part: Node) -> String:
	var material = part.get("material_override")
	if material == null:
		return ""
	var texture = material.albedo_texture if material is BaseMaterial3D else material.get_shader_parameter("albedo")
	return texture.resource_path.get_file() if texture is Texture2D else ""


func run() -> void:
	var walk = load("res://modules/shell/prototype/collection_reconstruction/main_build_walk.gd").new()
	walk.size = Vector2(960, 640)
	root.add_child(walk)
	for i in 240:
		await process_frame
	if walk._rooms == null and walk._rooms_path != "":
		walk._attach_rooms(walk._rooms_path)
		for settle in 6:
			await process_frame
	var out := []
	for thing in walk._objects:
		var node: Node3D = thing.node
		var across: Vector3 = node.global_transform.basis.x
		var yaw := atan2(-across.z, across.x)
		var frame := Transform3D(Basis(Vector3.UP, yaw), node.global_position).affine_inverse()
		var parts: Array = node.find_children("*", "GeometryInstance3D", true, false)
		if node is GeometryInstance3D:
			parts.append(node)
		var rows := []
		for p in parts:
			# name, class, then the part's box in the node's wall frame: x, y, z, width, height, depth, texture
			var r: AABB = (frame * p.global_transform) * p.get_aabb()
			rows.append([str(node.get_path_to(p)), p.get_class(), r.position.x, r.position.y, r.position.z, r.size.x, r.size.y, r.size.z, texture_file(p)])
		var at := node.global_position
		out.append({"key": str(thing.tag).get_slice("#", 0), "room": walk._plan[thing.room].label, "name": str(node.name), "pos": [at.x, at.y, at.z], "yaw": yaw, "parts": rows, "b": walk._plan[thing.room].b})
	FileAccess.open(OS.get_cmdline_user_args()[0], FileAccess.WRITE).store_string(JSON.stringify({"objects": out}))
	print("PLACEMENT_DUMP ", out.size())
	quit(0)
