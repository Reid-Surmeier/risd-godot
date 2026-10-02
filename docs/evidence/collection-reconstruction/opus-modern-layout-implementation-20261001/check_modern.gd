## Headless, no GPU: godot --headless --path <prepared project> -s check_modern.gd
## Reads the emitted geometry.json and the built remodel_room scene and holds both to layout-patch.json,
## then walks the modern-room portal trials. Writes checks.json beside this file.
extends SceneTree

const MODERN := "modern painting gallery"
const ADJOINING := "modern adjoining gallery threshold study limit"
var failures := []
var here: String

func expect(ok: bool, what: String) -> void:
	if not ok:
		failures.append(what)

func near(a: Vector3, b: Array) -> bool:
	return a.distance_to(Vector3(b[0], b[1], b[2])) < .0005

func yaw(text: String) -> float:
	return {"0": 0.0, "PI": PI, "PI/2": PI / 2, "-PI/2": -PI / 2}[text]

func _initialize() -> void:
	here = get_script().resource_path.get_base_dir()
	# A script error stops run() without stopping the tree; never let that look like a pass or hang a caller.
	create_timer(90).timeout.connect(func():
		print("MODERN_LAYOUT_CHECK aborted: run() did not finish")
		quit(2))
	call_deferred("run")

func run() -> void:
	var patch: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(here.path_join("../opus-modern-layout-review-20261001/layout-patch.json").simplify_path()))
	var geometry: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://geometry.json"))
	var rooms := {}
	for room in geometry.rooms:
		rooms[room.label] = room
	# 1. Emitted geometry: the two changed rooms, the opening pairs, the replaced trials, nothing accepted.
	for label in patch.rooms:
		expect(rooms[label].bounds == patch.rooms[label].proposed.bounds and rooms[label].openings == patch.rooms[label].proposed.openings, label + " differs from the accepted patch")
	var b: Array = rooms[MODERN].bounds
	expect(rooms[MODERN].openings.west == rooms["lion stair landing"].openings.east and b[0] == rooms["lion stair landing"].bounds[1], "entry pair with the landing changed")
	expect(rooms[MODERN].openings.east == rooms[ADJOINING].openings.west and b[1] == rooms[ADJOINING].bounds[0], "second doorway pair does not match")
	expect(rooms["lion stair landing"].bounds == [10.55, 16.15, 28.1, 35.9] and rooms["lion stair landing"].openings.east == [29.2, 30.9], "landing or retained entry moved")
	for i in geometry.rooms.size():
		for j in range(i + 1, geometry.rooms.size()):
			var p: Array = geometry.rooms[i].bounds
			var q: Array = geometry.rooms[j].bounds
			expect(min(p[1], q[1]) - max(p[0], q[0]) < 1e-8 or min(p[3], q[3]) - max(p[2], q[2]) < 1e-8, "rooms overlap: %s / %s" % [geometry.rooms[i].label, geometry.rooms[j].label])
	var trials := {}
	for row in geometry.trials:
		trials[row[0]] = row
	for name in patch.trials.replace:
		var want: Array = patch.trials.replace[name]
		expect(trials.has(name) and trials[name][1] == want[0] and trials[name][2] == want[1] and trials[name][3] == want[2], "trial %s differs from the patch" % name)
	var layout: Dictionary = geometry.lion_modern_layout
	expect(layout.get("metric_accepted") == false and layout.get("adjoining_room_interior_complete") == false and layout.get("entry_reveal_depth_modelled") == false, "nothing metric may be accepted here")
	expect(max(b[1] - b[0], b[3] - b[2]) / min(b[1] - b[0], b[3] - b[2]) <= 1.25, "modern room is stretched")

	# 2. Built scene.
	var scene: Node3D = load("res://remodel_room.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	var built := {"paintings": {}, "windows": []}
	var line := {"west": b[0] + .08, "east": b[1] - .08, "north": b[2] + .08, "south": b[3] - .08}
	var into := {"west": Vector3.RIGHT, "east": Vector3.LEFT, "north": Vector3.BACK, "south": Vector3.FORWARD}
	var spans := {"west": [[rooms[MODERN].openings.west[0] - .16, rooms[MODERN].openings.west[1] + .16, "entry_door"]],
		"east": [[rooms[MODERN].openings.east[0] - .16, rooms[MODERN].openings.east[1] + .16, "adjoining_doorway"]], "north": [], "south": []}
	for item in patch.items:
		var along_z: bool = item.wall in ["west", "east"]
		if item.kind == "painting":
			var accession: String = item.id.split("_")[1]
			var found: Array = scene.get_children().filter(func(node): return node is Node3D and node.get_meta("catalogue_accession", "") == accession)
			expect(found.size() == 1, "%s: expected one painting, found %d" % [item.id, found.size()])
			if found.size() != 1:
				continue
			var work: Node3D = found[0]
			expect(near(work.position, item.proposed.position) and abs(work.rotation.y - yaw(item.proposed.rotation_y)) < 1e-5, item.id + " is not at its patch transform")
			expect(abs((work.position.x if along_z else work.position.z) - line[item.wall]) < 1e-4, item.id + " is not on the %s wall line" % item.wall)
			expect(work.global_transform.basis.z.distance_to(into[item.wall]) < 1e-4, item.id + " does not face into the room")
			expect(abs(work.outer.x - item.framed_width_m) < .003, "%s framed width %.3f differs from the patch %.3f" % [item.id, work.outer.x, item.framed_width_m])
			var at: float = work.position.z if along_z else work.position.x
			spans[item.wall].append([at - work.outer.x / 2, at + work.outer.x / 2, item.id])
			built.paintings[accession] = {"position": [work.position.x, work.position.y, work.position.z], "yaw": work.rotation.y, "outer_m": [work.outer.x, work.outer.y], "wall": item.wall}
	# Windows: exactly two, on the south wall, owned by that wall's visual so the cutaway hides them with it.
	var south: StaticBody3D
	for wall in scene.casings:
		if wall.get_meta("room_wall", "") == MODERN + ":south":
			south = wall
	var windows: Array = scene.find_children("*", "MeshInstance3D", true, false).filter(func(node): return node.has_meta("modern_window"))
	windows.sort_custom(func(l, r): return l.global_position.x < r.global_position.x)
	expect(south != null and windows.size() == 2, "expected two windows on one south wall, found %d" % windows.size())
	var centres := [patch.items.filter(func(i): return i.id == "window_1")[0].proposed.centre_x, patch.items.filter(func(i): return i.id == "window_2")[0].proposed.centre_x]
	for i in min(windows.size(), 2):
		var window: MeshInstance3D = windows[i]
		expect(abs(window.global_position.x - centres[i]) < 1e-4 and abs(window.global_position.z - (b[3] - .076)) < 1e-4, "window %d is off its patch centre or wall" % (i + 1))
		expect(south != null and window.get_parent() == south.get_child(1), "window %d is not parented to the south wall visual" % (i + 1))
		expect(window.mesh.size.x > window.mesh.size.z, "window %d is not turned to the south wall" % (i + 1))
		var radiators: Array = window.get_children().filter(func(node): return node is StaticBody3D)
		expect(radiators.size() == 1 and abs(radiators[0].global_position.x - centres[i]) < 1e-4 and radiators[0] in scene.casings, "window %d radiator cover missing or moved" % (i + 1))
		spans.south.append([window.global_position.x - .67, window.global_position.x + .67, "window_%d" % (i + 1)])
		built.windows.append([window.global_position.x, window.global_position.y, window.global_position.z])
	if south != null and windows.size() == 2:
		south.get_child(1).visible = false
		expect(not windows[0].is_visible_in_tree() and not windows[1].is_visible_in_tree(), "cutaway of the south wall must hide its windows")
		south.get_child(1).visible = true
	# Case and figure.
	var seated: StaticBody3D = scene.get_node_or_null("SeatedWomanCase")
	var case_item: Dictionary = patch.items.filter(func(i): return i.id == "seated_woman_case")[0]
	expect(seated != null and seated in scene.casings, "Seated Woman case missing or outside the cutaway list")
	if seated != null:
		expect(near(seated.position, case_item.proposed.position) and abs(seated.rotation.y - yaw(case_item.proposed.rotation_y)) < 1e-5, "case is not at its patch transform")
		var figure: MeshInstance3D = seated.get_child(3)
		expect(figure.get_meta("catalogue_accession", "") == "67.089" and figure.mesh.get_aabb().size.distance_to(Vector3(.203, .711, .241)) < .0005, "figure is not the catalogue-bounded 67.089")
		expect(figure.global_transform.basis.z.distance_to(Vector3.FORWARD) < 1e-4 and figure.global_transform.basis.x.distance_to(Vector3.LEFT) < 1e-4, "figure must face north into the room with its left to the west")
		var surface = figure.material_override.get("albedo_texture")
		expect(surface != null and surface.resource_path == "res://assets/seated-woman-bronze.webp", "Muse bronze surface was not kept")
		spans.south.append([seated.position.x - .34, seated.position.x + .34, "seated_woman_case"])
		built["case"] = {"position": [seated.position.x, seated.position.y, seated.position.z], "yaw": seated.rotation.y}
	# Wall order equals the pan order and nothing overlaps a neighbour, an opening or a corner.
	var order := {"west": "west_north_to_south", "south": "south_west_to_east", "east": "east_north_to_south", "north": "north_west_to_east"}
	for wall in spans:
		var row: Array = spans[wall]
		row.sort_custom(func(l, r): return l[0] < r[0])
		expect(row.map(func(s): return s[2]) == patch.wall_order_from_pan[order[wall]], "%s wall order %s differs from the pan" % [wall, row.map(func(s): return s[2])])
		var lo: float = b[2] if wall in ["west", "east"] else b[0]
		var hi: float = b[3] if wall in ["west", "east"] else b[1]
		var edge := lo
		for s in row:
			expect(s[0] - edge >= (0.0 if edge == lo else .15) - 1e-6, "%s wall: %s overlaps what is before it" % [wall, s[2]])
			edge = s[1]
		expect(hi - edge >= -1e-6, "%s wall: last item runs past the corner" % wall)
	# Walls, ceiling, bench, tracks: all inside the new room, nothing left where the old room was.
	var walls := {}
	built["walls"] = []
	for wall in scene.casings:
		var tag: String = wall.get_meta("room_wall", "")
		if tag.begins_with(MODERN + ":") and not tag.ends_with(":header"):
			walls[tag] = walls.get(tag, 0) + 1
			var box: Vector3 = wall.get_child(0).shape.size
			built.walls.append([tag.trim_prefix(MODERN + ":"), wall.position.x, wall.position.z, box.x, box.z])
	expect(walls.get(MODERN + ":west", 0) == 2 and walls.get(MODERN + ":east", 0) == 2 and walls.get(MODERN + ":north", 0) == 1 and walls.get(MODERN + ":south", 0) == 1, "modern wall spans are not door-split west, doorway-split east, whole north and south: %s" % walls)
	var ceiling: Array = scene.ceiling_details.filter(func(mesh): return mesh.get_meta("opaque_ceiling", "") == MODERN)
	expect(ceiling.size() == 1 and abs(ceiling[0].position.x - (b[0] + b[1]) / 2) < 1e-4 and abs(ceiling[0].position.z - (b[2] + b[3]) / 2) < 1e-4 and abs(ceiling[0].mesh.size.x - (b[1] - b[0])) < 1e-4 and abs(ceiling[0].mesh.size.z - (b[3] - b[2])) < 1e-4, "modern ceiling does not cover the new room")
	var tracks: Array = scene.ceiling_details.filter(func(mesh): return mesh.mesh is BoxMesh and not mesh.has_meta("opaque_ceiling") and mesh.position.x > b[0] and mesh.position.z > b[2] - .1)
	expect(tracks.size() == 3 and tracks.all(func(t): return t.mesh.size.x > t.mesh.size.z and t.get_child_count() == 4 and t.position.x - t.mesh.size.x / 2 > b[0] and t.position.x + t.mesh.size.x / 2 < b[1] and t.position.z > b[2] and t.position.z < b[3]), "three ceiling tracks with four fixtures each must run along the large-painting wall inside the room")
	var benches: Array = scene.casings.filter(func(c): return c.get_child(0) is CollisionShape3D and c.get_child(0).shape is BoxShape3D and c.get_child(0).shape.size.distance_to(Vector3(2.20, .13, .80)) < 1e-4)
	expect(benches.size() == 1 and benches[0].position.x > b[0] + 1 and benches[0].position.x < b[1] - 1 and benches[0].position.z > b[2] + 1 and benches[0].position.z < b[3] - 1, "one bench, long side along X, inside the room")
	built["tracks"] = tracks.map(func(t): return [t.position.x, t.position.z, t.mesh.size.x, t.mesh.size.z])
	built["bench"] = benches.map(func(c): return [c.position.x, c.position.z, 2.20, .80])
	# The old footprint north of the new room and east of the landing must be empty of authored nodes.
	var stale := []
	for node in scene.find_children("*", "Node3D", true, false):
		if scene.visitor.is_ancestor_of(node) or node == scene.visitor or node == scene.body or node == scene.camera or node is CollisionShape3D:
			continue
		var p: Vector3 = node.global_position
		if p.x > 16.4 and p.z > 22.5 and p.z < 28.7 and (node is MeshInstance3D or node is StaticBody3D):
			stale.append("%s %s" % [node.name, p])
	expect(stale.is_empty(), "authored nodes remain in the old modern-room footprint: %s" % [stale.slice(0, 6)])
	var listed: Dictionary = scene.inventory.get("modern_gallery", {})
	expect(listed.get("windows") == 2 and listed.get("placement_accepted") == false, "inventory must say two windows and unaccepted placement")

	# 3. Every landing and modern trial in geometry.json, walked by the scene's own runner: both modern
	# openings each way, the bench, and the untouched landing trials beside them.
	scene.trials = scene.trials.filter(func(t): return t[0].contains("modern") or t[0].contains("landing"))
	var names: Array = scene.trials.map(func(t): return t[0])
	for name in ["landing_to_modern", "modern_to_landing", "modern_far_opening_out", "modern_far_opening_back", "modern_bench_blocked"]:
		expect(name in names, "portal trial missing from geometry.json: " + name)
	# A last row the runner never finishes, so it cannot quit the tree before this report is written.
	scene.trials.append(["hold", scene.trials[0][1], scene.trials[0][1], false])
	scene.phase = 0
	scene.elapsed = 0
	scene.results = {}
	scene.samples = []
	scene.reset(scene.trials[0][1])
	scene.qa = true
	while scene.phase < names.size():
		await physics_frame
	scene.qa = false
	for name in names:
		expect(scene.results.get(name, false), "portal trial failed: " + name)
	var report := {
		"project": ProjectSettings.globalize_path("res://"), "godot": Engine.get_version_info().string, "gpu_used": false,
		"renderer": "headless dummy; camera-clear flags from the walk are recorded, not judged",
		"geometry": {"modern": rooms[MODERN], "adjoining": rooms[ADJOINING], "metric_accepted": layout.get("metric_accepted")},
		"built": built, "wall_spans": walls, "portal_trials": scene.results, "trial_samples": scene.samples,
		"native_review_and_bake": "not run here: remodel_review.gd and remodel_bake.gd need a renderer; root owns them",
		"failures": failures, "passed": failures.is_empty(),
	}
	FileAccess.open(here.path_join("checks.json"), FileAccess.WRITE).store_string(JSON.stringify(report, "  ") + "\n")
	print("MODERN_LAYOUT_CHECK " + JSON.stringify({"passed": failures.is_empty(), "failures": failures, "portal_trials": scene.results}))
	quit(0 if failures.is_empty() else 1)
