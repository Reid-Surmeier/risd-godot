## Private headless dump: godot --headless --path PREPARED_COPY -s dump_scene.gd -- OUT.json
## Lists every authored visual and collider in world metres, so two builds can be compared.
extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var scene = load("res://remodel_room.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var meshes: Array = []
	for mesh in scene.find_children("*", "MeshInstance3D", true, false):
		if mesh.has_meta("retained_main_hall") or mesh.mesh == null or mesh.mesh.get_surface_count() == 0 or scene.visitor.is_ancestor_of(mesh):
			continue
		var box: AABB = mesh.global_transform * mesh.mesh.get_aabb()
		var c := box.get_center()
		meshes.append([snappedf(c.x, .001), snappedf(c.y, .001), snappedf(c.z, .001), snappedf(box.size.x, .001), snappedf(box.size.y, .001), snappedf(box.size.z, .001)])
	var bodies: Array = []
	for body in scene.casings:
		var shape = body.get_child(0).shape
		var size := Vector3.ZERO # other shapes are compared by position only
		if shape is BoxShape3D:
			size = shape.size
		elif shape is CylinderShape3D:
			size = Vector3(shape.radius * 2, shape.height, shape.radius * 2)
		var p: Vector3 = body.global_position
		bodies.append({"at": [snappedf(p.x, .001), snappedf(p.y, .001), snappedf(p.z, .001)], "size": [snappedf(size.x, .001), snappedf(size.y, .001), snappedf(size.z, .001)], "wall": body.get_meta("room_wall", ""), "children": body.get_child_count(), "leaf": body.get_meta("hall_reveal_leaf", "")})
	var ceilings: Array = []
	for item in scene.ceiling_details:
		if item.has_meta("opaque_ceiling"):
			var q: Vector3 = item.global_position
			ceilings.append({"label": item.get_meta("opaque_ceiling"), "at": [snappedf(q.x, .001), snappedf(q.y, .001), snappedf(q.z, .001)]})
	var file := FileAccess.open(OS.get_cmdline_user_args()[0], FileAccess.WRITE)
	file.store_string(JSON.stringify({"meshes": meshes, "bodies": bodies, "opaque_ceilings": ceilings, "inventory_hall_reveal": scene.inventory.get("hall_reveal", null), "start": [scene.body.position.x, scene.body.position.y, scene.body.position.z]}))
	file.close()
	print("DUMP_OK ", meshes.size(), " meshes ", bodies.size(), " bodies")
	quit(0)
