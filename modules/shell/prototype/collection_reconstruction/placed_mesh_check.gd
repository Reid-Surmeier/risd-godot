## place_mesh() end to end in the built museum, on a fixture no shipped room has: the mesh is
## there at its catalogue height, drawn the way the rooms' other works are, solid to walk into,
## cut away with the camera, registered as a work, still drawn when a visitor opens it, and gone
## when the visitor stands on another room's stage.
## godot --headless --fixed-fps 60 --path . --script res://modules/shell/prototype/collection_reconstruction/placed_mesh_check.gd -- --placed-mesh-fixture
extends SceneTree

const Fixture := preload("placed_mesh_fixture.gd")


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	assert("--placed-mesh-fixture" in OS.get_cmdline_user_args(), "run with -- --placed-mesh-fixture")
	var walk = load("res://modules/shell/prototype/collection_reconstruction/main_build_walk.gd").new()
	walk.size = Vector2(960, 640)
	root.add_child(walk)
	for i in 240:
		await process_frame
	# The room scene is built at the first doorway since #281; a check needs the rooms now.
	if walk._rooms == null and walk._rooms_path != "":
		walk._attach_rooms(walk._rooms_path)
		for settle in 6:
			await process_frame
	var failures: Array = []
	var thing := {}
	for entry in walk._objects:
		if str(entry.tag).get_slice("#", 0) == Fixture.KEY:
			thing = entry
	if thing.is_empty():
		print("PLACED_MESH_CHECK ", JSON.stringify({"failures": ["the placed mesh is not registered as a work"]}))
		quit(1)
		return
	var node: Node3D = thing.node
	var part: MeshInstance3D = node.get_child(1)
	var box: AABB = part.global_transform * part.mesh.get_aabb()
	var triangles: int = part.mesh.get_faces().size() / 3
	if triangles == 0 or absf(box.size.y - Fixture.HEIGHT) > 0.002 or absf(box.position.y) > 0.002:
		failures.append("the mesh is empty, not at its catalogue height, or not standing on the floor")
	# Lit like the other works: its own texture, unshaded. The lightmap lights architecture only.
	var material := part.material_override as StandardMaterial3D
	if material == null or material.albedo_texture == null or material.shading_mode != BaseMaterial3D.SHADING_MODE_UNSHADED or material.metallic != 0.0:
		failures.append("the mesh is not drawn with its own texture, unshaded and matt")
	var collider := node.get_child(0) as CollisionShape3D
	if not node is StaticBody3D or collider == null or not collider.shape is BoxShape3D or absf(collider.shape.size.y - Fixture.HEIGHT) > 0.002:
		failures.append("the mesh has no box collider of its own height")
	var centre := Vector3(thing.center.x, 0, thing.center.z)
	if walk._walkable(centre) or not walk._walkable(centre + Vector3(1.2, 0, 0)):
		failures.append("a visitor can walk through the mesh, or cannot walk beside it")
	var cut := false
	for wall in walk._walls:
		cut = cut or wall.body == node
	if not cut:
		failures.append("the mesh is not one of the camera's cut-away bodies")
	# A visitor stands south of it and looks north, so it is beyond the visitor and not in the
	# camera's way; then opens it: walk up, turn, read. It must still be drawn while it is read.
	walk._new_action()
	walk.view_mode = 0
	walk.view_yaw = 0.0
	walk._yaw = 0.0
	walk._pos = centre + Vector3(0, 0, 2.2)
	walk._last_pos = walk._pos
	walk._space = "far" if walk._plan[thing.room].far else "arch"
	walk._kid.position = walk._pos
	for settle in 30:
		await process_frame
	if not walk._drawn(node):
		failures.append("the mesh is not drawn with the visitor in its room")
	walk._approach(thing)
	var frames := 0
	while (walk._inspect.is_empty() or walk._inspect_t < 0.99) and frames < 1200:
		await process_frame
		frames += 1
	if walk._inspect.get("tag", "") != thing.tag:
		failures.append("opening the mesh did not start its inspection")
	else:
		for settle in 30:
			await process_frame
		if not walk._drawn(node):
			failures.append("the mesh is not drawn in its own inspection")
		walk._end_inspect(false)
	# Only the visitor's own stage is drawn: from another room's stage the mesh is gone.
	for other in walk._plan.size():
		if walk._stage_ids[other] == walk._stage_ids[thing.room]:
			continue
		var b: Array = walk._plan[other].b
		walk._new_action()
		walk._pos = Vector3((b[0] + b[1]) / 2.0, 0, (b[2] + b[3]) / 2.0)
		walk._last_pos = walk._pos
		walk._space = "far" if walk._plan[other].far else "arch"
		walk._kid.position = walk._pos
		for settle in 90:
			await process_frame
		if walk._stage == walk._stage_ids[thing.room] or walk._drawn(node):
			failures.append("the mesh is still drawn from %s, another stage" % walk._plan[other].label)
		break
	print("PLACED_MESH_CHECK ", JSON.stringify({"triangles": triangles, "height_m": snappedf(box.size.y, 0.001), "room": walk._plan[thing.room].label, "frames_to_open": frames, "failures": failures}))
	quit(0 if failures.is_empty() else 1)
