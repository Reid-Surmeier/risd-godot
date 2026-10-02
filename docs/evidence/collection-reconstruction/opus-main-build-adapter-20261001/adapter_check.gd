## Headless, no GPU. Compares main_build_walk.gd with the unchanged walk4.gd in one project.
##   godot --headless --path PROJECT --script /abs/path/adapter_check.gd -- --out=/abs/result.json
## PROJECT is root's main-build-extension project or a full-app copy made by make_local_fullapp.py.
## Hard failures (exit 1): composition and Hall preservation. Root's walk trials are reported, not asserted.
extends SceneTree

const HALL := "res://modules/shell/prototype/gallery_walk4/walk4.gd"
const ADAPTER := "res://modules/shell/prototype/collection_reconstruction/main_build_walk.gd"
const STEP := 1.0 / 30.0
# Root's continuous_loop_waypoints in Hall-local metres, with two changes: the portal is
# approached through walk4's passage mouth, and the far door is a cover transition.
const LOOP := [
	["hall", Vector3(1.45, 0, -13.0), "gallery"],
	["hall arch end", Vector3(0, 0, -1.4), "gallery"],
	["stone passage", Vector3(0, 0, 1.2), "arch"],
	["medieval, portal mouth", Vector3(0, 0, 2.7), "arch"],
	["medieval west", Vector3(-2.35, 0, 2.7), "arch"],
	["medieval at tracery", Vector3(-3.4, 0, 3.665), "arch"],
	["renaissance", Vector3(-5.75, 0, 3.665), "arch"],
	["renaissance south", Vector3(-5.75, 0, 1.9), "arch"],
	["renaissance at gallery door", Vector3(-8.05, 0, 1.9), "arch"],
	["west gallery south", Vector3(-8.05, 0, -1.4), "arch"],
	["west gallery middle", Vector3(-8.05, 0, -14.0), "arch"],
	["west gallery north", Vector3(-8.05, 0, -27.5), "arch"],
	["rockefeller", Vector3(-8.05, 0, -29.3), "far"],
	["rockefeller at purple door", Vector3(-6.75, 0, -30.1), "far"],
	["purple corridor", Vector3(-3.0, 0, -30.1), "far"],
	["grey gallery", Vector3(0, 0, -30.1), "far"],
	["grey gallery at Hall door", Vector3(0, 0, -27.0), "far"],
	["through Hall door", Vector3(0, 0, -26.0), "gallery"],
	["hall far end", Vector3(0, 0, -23.0), "gallery"],
]

var failures: Array = []


func _initialize() -> void:
	call_deferred("run")


func require(ok: bool, what: String) -> void:
	if not ok:
		failures.append(what)
		print("FAIL ", what)


func still(walk) -> void:
	walk._target = null
	walk._target_yaw = null
	walk._path.clear()
	walk._velocity = Vector3.ZERO
	walk._held.clear()
	walk._entrance_active = false
	walk._entrance_waiting = false
	walk._stall_t = 0.0


func place(walk, at: Vector3, space: String) -> void:
	still(walk)
	if walk._space != space:
		walk._space = space
	walk._pos = at
	walk._last_pos = at
	walk._update_camera(1.0)


# Walk straight at a point with walk4's own _process; returns the remaining distance.
func walk_to(walk, to: Vector3, seconds: float) -> float:
	walk._target = to
	for i in int(seconds / STEP):
		walk._process(STEP)
		if walk._target == null:
			break
	var left: Vector3 = to - walk._pos
	left.y = 0
	return left.length()


func run() -> void:
	var out := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.trim_prefix("--out=")
	var plain = load(HALL).new()
	var walk = load(ADAPTER).new()
	for node in [plain, walk]:
		node.size = Vector2(960, 640)
		root.add_child(node)
		node.set_process(false)  # stepped by hand, so both see the same deltas
	await process_frame
	await process_frame
	var report := {"adapter_state": walk.state(), "renderer": RenderingServer.get_video_adapter_name()}

	# 1. Composition: one visitor rig, one camera, one environment, no second Hall.
	require(walk._rooms != null, "room scene not attached")
	if walk._rooms == null:
		finish(report, out)
		return
	var cameras: Array = walk._vp.find_children("*", "Camera3D", true, false)
	var environments: Array = walk._vp.find_children("*", "WorldEnvironment", true, false)
	require(cameras.size() == 1 and cameras[0] == walk._cam, "extra camera in the Hall viewport")
	require(walk._vp.get_camera_3d() == walk._cam, "walk4 camera is not current")
	require(environments.size() == 1, "extra WorldEnvironment in the Hall viewport")
	require(walk._rooms.get_node_or_null("ConnectedHall") == null, "room scene kept its Hall copy")
	require(not walk._rooms.is_physics_processing(), "room scene still runs its own walker")
	require(
		walk._vp.find_children("*", "CharacterBody3D", true, false).is_empty(),
		"room scene kept its physics body"
	)
	report.composition = {
		"cameras": cameras.size(),
		"environments": environments.size(),
		"lightmaps": walk._vp.find_children("*", "LightmapGI", true, false).size()
	}

	# 2. The Hall: same paintings, same saved bake, same meshes; only the stand-in room hidden.
	require(walk._paintings.size() == 23 and plain._paintings.size() == 23, "Hall paintings != 23")
	var hidden: Array = []
	var differing: Array = []
	var theirs := {}
	for mesh in plain._baked_room.find_children("*", "MeshInstance3D", true, false):
		theirs[str(mesh.name)] = mesh
	var ours: Array = walk._baked_room.find_children("*", "MeshInstance3D", true, false)
	require(ours.size() == theirs.size(), "baked Hall mesh count differs")
	for mesh in ours:
		var other = theirs.get(str(mesh.name))
		if (
			other == null
			or other.mesh != mesh.mesh
			or other.transform != mesh.transform
			or other.layers != mesh.layers
		):
			differing.append(str(mesh.name))
		elif other.visible != mesh.visible:
			hidden.append(str(mesh.name))
	hidden.sort()
	require(differing.is_empty(), "baked Hall meshes differ: " + str(differing))
	require(
		hidden == ["Surface006", "Surface007", "Surface008", "Surface009", "Surface010"],
		"Hall meshes hidden by the adapter are not exactly the stand-in room: " + str(hidden)
	)
	# Surface011 is the photo card walk4 itself hides; Surface004/005 are the stone portal.
	require(not walk._baked_room.get_node("Surface011").visible, "walk4's door card is showing")
	require(
		walk._baked_room.get_node("Surface004").visible and walk._baked_room.get_node("Surface005").visible,
		"stone portal hidden"
	)
	require(
		walk._baked_room.get_node("Lightmap").light_data == plain._baked_room.get_node("Lightmap").light_data,
		"Hall lightmap data differs"
	)
	report.hall = {
		"paintings": walk._paintings.size(),
		"baked_meshes": ours.size(),
		"hidden_stand_in": hidden,
		"source_meshes": [plain._source_meshes.size(), walk._source_meshes.size()]
	}
	require(plain._source_meshes.size() == walk._source_meshes.size(), "Hall source mesh count differs")

	# 3. Nothing added can light or draw into the Hall's layers.
	var stray_layers := 0
	for item in walk._rooms.find_children("*", "GeometryInstance3D", true, false):
		if item.layers & 2047:
			stray_layers += 1
	var stray_lights := 0
	var lights: Array = walk._rooms.find_children("*", "Light3D", true, false)
	for light in lights:
		if light.light_cull_mask & 2047:
			stray_lights += 1
	require(stray_layers == 0, "%d added meshes are on Hall or test-room layers" % stray_layers)
	require(stray_lights == 0, "%d added lights can reach Hall layers" % stray_lights)
	var env_a: Environment = environments[0].environment
	var env_b: Environment = plain._vp.find_children("*", "WorldEnvironment", true, false)[0].environment
	require(
		env_a.ambient_light_energy == env_b.ambient_light_energy
		and env_a.background_color == env_b.background_color
		and env_a.ambient_light_color == env_b.ambient_light_color,
		"Hall environment differs"
	)
	# floor_oak.gdshader clips by world z: the Hall keeps its limits, the added floors fit theirs.
	var hall_limits := []
	for node in [plain, walk]:
		var limits := []
		for mesh in node._baked_room.find_children("*", "MeshInstance3D", true, false):
			if mesh.material_override is ShaderMaterial:
				limits.append([str(mesh.name), mesh.material_override.get_shader_parameter("floor_z_limits")])
		hall_limits.append(limits)
	require(hall_limits[0] == hall_limits[1] and not hall_limits[0].is_empty(), "Hall floor clip limits changed")
	var clipped := 0
	var added_floors := 0
	var added_limits := {}
	for mesh in walk._rooms.find_children("*", "MeshInstance3D", true, false):
		var material := mesh.material_override as ShaderMaterial
		if material == null or not material.get_shader_parameter("floor_z_limits") is Vector2:
			continue
		var clip: Vector2 = material.get_shader_parameter("floor_z_limits")
		var reach: AABB = mesh.global_transform * mesh.mesh.get_aabb()
		added_floors += 1
		added_limits[str(clip)] = true
		if reach.position.z < clip.x - 0.01 or reach.end.z > clip.y + 0.01:
			clipped += 1
	# The room scene empties its own floors under the Hall; every other room keeps its floor.
	var under_hall := 0
	var floored := {}
	for mesh in walk._rooms.find_children("*", "MeshInstance3D", true, false):
		if mesh.mesh == null or mesh.mesh.get_surface_count() == 0 or not mesh.is_visible_in_tree():
			continue
		var reach: AABB = mesh.global_transform * mesh.mesh.get_aabb()
		if reach.end.y > 0.02 or reach.position.y < -0.02:
			continue
		if absf(reach.get_center().x) < 4.99 and reach.position.z > -26.29 and reach.end.z < -0.01:
			under_hall += 1
		var index: int = walk._room_at(reach.get_center())
		if index >= 0:
			floored[walk._plan[index].label] = true
	var unfloored: Array = walk._plan.map(func(room): return room.label).filter(func(label): return not floored.has(label))
	require(under_hall == 0, "%d added floor meshes lie inside the Hall" % under_hall)
	require(unfloored.is_empty(), "added rooms without a floor: " + str(unfloored))
	require(added_floors > 0 and clipped == 0, "%d of %d added floor meshes fall outside their clip limits" % [clipped, added_floors])
	report.isolation = {"added_lights": lights.size(), "ambient": env_a.ambient_light_energy}
	report.floor_clip = {"hall": hall_limits[1], "added_floor_meshes": added_floors, "added_limits_world_z": added_limits.keys(), "outside": clipped, "added_floor_meshes_inside_hall": under_hall, "rooms_without_floor": unfloored}

	# 4. Same movement inside the Hall and its stone passage, point for point.
	var mismatches := 0
	var compared := 0
	for space in ["gallery", "arch"]:
		for from in (
			[Vector3(-2.6, 0, -8.0), Vector3(0, 0, -0.6), Vector3(0, 0, -25.9), Vector3(3.9, 0, -17.0)]
			if space == "gallery"
			else [Vector3(0, 0, 0.1), Vector3(0.3, 0, 1.0), Vector3(-0.4, 0, 2.1)]
		):
			for node in [plain, walk]:
				place(node, from, space)
			for ix in range(-12, 13):
				for iz in range(-58, 9):
					var p := Vector3(ix * 0.5, 0, iz * 0.5)
					if space == "arch" and p.z >= 2.2:
						continue  # past the passage mouth the rooms take over, by design
					compared += 1
					if plain._clamp(p) != walk._clamp(p):
						mismatches += 1
	require(mismatches == 0, "%d of %d Hall clamp results differ" % [mismatches, compared])
	for node in [plain, walk]:
		place(node, Vector3(-2.6, 0, -8.0), "gallery")
	var drift := 0.0
	for to in [Vector3(3.0, 0, -20.0), Vector3(-4.0, 0, -3.0), Vector3(0, 0, -25.5), Vector3(0, 0, -1.0)]:
		plain._walk_to(to)
		walk._walk_to(to)
		for i in 600:
			plain._process(STEP)
			walk._process(STEP)
			drift = maxf(drift, plain._pos.distance_to(walk._pos))
			drift = maxf(drift, plain._cam.global_position.distance_to(walk._cam.global_position))
			if plain._cam.cull_mask != (walk._cam.cull_mask & ~walk.NEAR_LAYER):
				drift = INF
	require(drift == 0.0, "Hall walk or camera drifts from walk4: %s" % drift)
	require(plain._space == "gallery" and walk._space == "gallery", "Hall walk left the Hall")
	report.hall_behaviour = {"clamp_points": compared, "clamp_mismatches": mismatches, "walk_drift_m": drift}

	# 5. The loop, on walk4's own _process: portal, rooms, the door between room groups, far door.
	var legs: Array = []
	place(walk, Vector3(1.45, 0, -20.0), "gallery")
	var loop_ok := true
	for leg in LOOP:
		var left := walk_to(walk, leg[1], 30.0)
		# A cover transition moves the visitor; the leg is then judged by the space it reached.
		var arrived: bool = left < 0.06 or (walk._space == leg[2] and leg[0].begins_with("through"))
		var ok: bool = arrived and walk._space == leg[2]
		loop_ok = loop_ok and ok
		legs.append({"leg": leg[0], "ok": ok, "left_m": snappedf(left, 0.001), "space": walk._space, "at": [snappedf(walk._pos.x, 0.01), snappedf(walk._pos.z, 0.01)]})
		if not ok:
			break
	report.loop = {"complete": loop_ok, "legs": legs}
	print("LOOP ", "complete" if loop_ok else "stopped at " + str(legs[-1]))

	# 6. Camera cut-away in a room: something between camera and visitor goes, and comes back.
	place(walk, Vector3(-2.35, 0, 3.4), "arch")
	walk.view_yaw = 0.0
	walk._update_camera(1.0)
	var cut_a: int = walk._walls.filter(func(w): return not w.body.get_child(1).visible).size()
	walk.view_yaw = PI
	walk._update_camera(1.0)
	var cut_b: int = walk._walls.filter(func(w): return not w.body.get_child(1).visible).size()
	report.cutaway = {"hidden_looking_north": cut_a, "hidden_looking_south": cut_b, "bodies": walk._walls.size()}

	# 7. Root's own walk trials from geometry.json, replayed on the adapter. Reported only.
	var plan: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string(walk._rooms.scene_file_path.get_base_dir().path_join("geometry.json"))
	)
	var trials: Array = []
	var agree := 0
	for row in plan.get("trials", []):
		var from: Vector3 = Vector3(row[1][0], 0, row[1][2]) + walk.ATTACH
		var to: Vector3 = Vector3(row[2][0], 0, row[2][2]) + walk.ATTACH
		from.y = 0
		to.y = 0
		var in_hall: bool = absf(from.x) < 5.0 and from.z > -26.3 and from.z < 2.2
		var index: int = walk._room_at(from)
		var space := "gallery" if in_hall and from.z < 0.0 else "arch"
		if not in_hall and index >= 0 and walk._plan[index].far:
			space = "far"
		place(walk, from, space)
		var left := walk_to(walk, to, float(plan.get("trial_seconds", 3.5)) + 0.5)
		var blocked: bool = row[3]
		var ok: bool = left > 0.2 if blocked else left < 0.06
		agree += int(ok)
		trials.append({"trial": row[0], "expects_blocked": blocked, "agrees": ok, "left_m": snappedf(left, 0.001), "start_space": space, "end_space": walk._space, "touches_hall": in_hall or (absf(to.x) < 5.0 and to.z > -26.3 and to.z < 2.2)})
	report.root_trials = {"agree": agree, "total": trials.size(), "rows": trials}
	print("ROOT_TRIALS ", agree, "/", trials.size())
	finish(report, out)


func finish(report: Dictionary, out: String) -> void:
	report.failures = failures
	if out != "":
		var file := FileAccess.open(out, FileAccess.WRITE)
		file.store_string(JSON.stringify(report, "  ") + "\n")
	print("ADAPTER_CHECK ", "FAILED " + str(failures) if not failures.is_empty() else "PASSED")
	quit(1 if not failures.is_empty() else 0)
