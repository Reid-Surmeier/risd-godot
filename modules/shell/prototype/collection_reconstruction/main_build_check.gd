## Run against make_local_fullapp.py's copy, using a real Compatibility renderer.
extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://modules/shell/demo.tscn").instantiate()
	root.add_child(app)
	for i in 150:
		await process_frame
	var walk = app.find_child("GalleryWalk", true, false)
	assert(walk != null and walk.state().attached)
	walk.set_process(false)
	var failures: Array = []
	var leaves := 0
	for body in walk._rooms.get("casings"):
		if not str(body.get_meta("room_wall", "")).begins_with("Grand Gallery reveal threshold:"):
			continue
		leaves += 1
		var registered := false
		for wall in walk._walls:
			if wall.body == body:
				registered = true
		if not registered:
			failures.append("Hall reveal leaf missing from camera cutaway")
	if leaves != 2:
		failures.append("Expected both Hall reveal leaves")
	var removed := 0
	for mesh in walk._baked_room.find_children("*", "MeshInstance3D", true, false):
		if not mesh.has_meta("far_fixture_clipped"):
			continue
		removed += int(mesh.get_meta("far_fixture_clipped"))
		for surface in mesh.mesh.get_surface_count():
			var arrays = mesh.mesh.surface_get_arrays(surface)
			for index in arrays[Mesh.ARRAY_INDEX]:
				if (mesh.global_transform * arrays[Mesh.ARRAY_VERTEX][index]).z < -walk.L - .19:
					failures.append("Closed demo fixture remains outside Hall")
	if removed == 0:
		failures.append("No demo fixture removed")
	var probes: Dictionary = walk._rooms.get_node("BakedRoom/Lightmap").light_data.get("probe_data")
	# The integrated bake has 430 probes; relocation independently checks the complete probe dictionary.
	if probes.points.size() != 430:
		failures.append("Addition probes lost in full-app conversion")
	var wall_art:=0
	var case_art:=0
	for node in walk._rooms.find_children("*","Node3D",true,false):
		wall_art+=int(node.has_meta("renaissance_wall_object"))
		case_art+=int(node.has_meta("renaissance_case_object"))
	if wall_art!=3 or case_art!=11:failures.append("Renaissance art lost in full-app conversion")
	# The revised south platform is furniture: its new depth must block walking.
	if walk._walkable(Vector3(-8.65,0,5.565)):failures.append("Visitor can walk through textile platform")
	for fixture in [[Vector3(1.45, 0, -13), "gallery", false], [Vector3(0, 0, -30.1), "far", true]]:
		walk._pos = fixture[0]
		walk._space = fixture[1]
		walk._update_camera(1.0)
		if walk._baked_room.get_node("Lightmap").visible == fixture[2] or walk._rooms.get_node("BakedRoom/Lightmap").visible != fixture[2] or walk._white_capture.visible:
			failures.append("Visitor must use only its room's probe field")
	if (walk._cam.cull_mask & 1) == 0:
		failures.append("Grey camera cannot see the Hall")
	walk._pos = Vector3(0, 0, -24.5)
	walk._space = "gallery"
	walk._update_camera(1.0)
	if (walk._cam.cull_mask & walk.FAR_LAYER) == 0:
		failures.append("Hall camera cannot see the grey gallery")
	for room in walk._plan:
		if not room.far:
			continue
		walk._space = "far"
		walk.view_mode = 2
		walk._pos = Vector3((room.b[0] + room.b[1]) / 2, 0, (room.b[2] + room.b[3]) / 2)
		walk._cutaway_alpha[8] = 0.0 # Reproduce an earlier north-facing Hall cutaway.
		walk._update_camera(1.0)
		if (walk._cam.cull_mask & 1) == 0 or walk._cutaway_alpha[8] != 1.0:
			failures.append("Far room loses the Hall or leaves its end wall faded: " + room.label)
		for entry in walk._cutaway_materials.get(8, []):
			if entry.mesh.material_override != entry.original:
				failures.append("Hall end wall still uses its faded material")
	for pair in [["far", "arch"], ["arch", "far"]]:
		var position := Vector3(-8.05, 0, -25.9)
		walk._pos = position
		walk._space = pair[0]
		walk._held = {KEY_UP: true}
		walk.view_yaw = .42
		walk._portal_flash.modulate.a = 0.0
		walk._enter_space(pair[1])
		if walk._pos != position or walk._held != {KEY_UP: true} or walk.view_yaw != .42 or walk._portal_flash.modulate.a != 0.0:
			failures.append("Added-room group crossing resets input/position/heading or flashes")
		if (walk._cam.cull_mask & (walk.NEAR_LAYER | walk.FAR_LAYER)) != (walk.NEAR_LAYER | walk.FAR_LAYER):
			failures.append("Adjoining room group is invisible through its doorway")
	print("MAIN_BUILD_CHECK ", JSON.stringify({"removed_demo_triangles": removed, "probes": probes.points.size(), "failures": failures}))
	quit(0 if failures.is_empty() else 1)
