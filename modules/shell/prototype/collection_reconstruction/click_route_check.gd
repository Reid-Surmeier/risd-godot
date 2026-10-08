## Native planner, floor-ray handler and frame movement; real pointer events are not covered.
extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var output: String = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output)
	root.size = Vector2i(1440, 1000)
	var app = load("res://modules/shell/demo.tscn").instantiate()
	root.add_child(app)
	for i in 150:
		await process_frame
	var walk = app.find_child("GalleryWalk", true, false)
	assert(walk != null)
	if walk.state().get("pending", false):
		walk._attach_rooms(walk._rooms_path)  # built at the first doorway since #281
	assert(walk.state().attached)
	walk.set_process(false)
	var cases := [
		["grey-misses-door", "far", Vector3(2, 0, -28.5), Vector3(-2, 0, -24), "gallery"],
		["hall-misses-door", "gallery", Vector3(3, 0, -22), Vector3(1.5, 0, -29), "far"],
		["hall-two-benches", "gallery", Vector3(0, 0, -3), Vector3(0, 0, -29), "far"],
		["grey-target-beyond-bench", "far", Vector3(0, 0, -29), Vector3(0, 0, -12), "gallery"],
		["hall-lane-to-grey", "gallery", Vector3(1.6, 0, -19), Vector3(0, 0, -29), "far"],
		["hall-one-bench", "gallery", Vector3(0, 0, -12), Vector3(0, 0, -29), "far"],
		["hall-bench-same-room", "gallery", Vector3(0, 0, -3), Vector3(0, 0, -22), "gallery"],
		["aligned-hall-grey", "gallery", Vector3(0, 0, -24.5), Vector3(0, 0, -28.3), "far"],
		["aligned-grey-hall", "far", Vector3(0, 0, -28.3), Vector3(0, 0, -24.5), "gallery"],
		["start-inside-grey-passage", "far", Vector3(.3, 0, -26.7), Vector3(2, 0, -24), "gallery"],
		["start-inside-hall-passage", "gallery", Vector3(.3, 0, -26.2), Vector3(1.5, 0, -29), "far"],
		["target-inside-grey-passage", "gallery", Vector3(3, 0, -22), Vector3(.3, 0, -26.7), "far"],
		["target-inside-hall-passage", "far", Vector3(2, 0, -28.5), Vector3(.3, 0, -26.1), "gallery"],
		["replace-crossing-click", "far", Vector3(2, 0, -28.5), Vector3(-1, 0, -30), "far"],
		["floor-pick-grey-hall", "far", Vector3(1.5, 0, -28.3), Vector3(-1, 0, -24.5), "gallery"],
		# #280: seen through the Hall's far door. The floor at x 1.5 lies behind the Hall's
		# north wall, and a click on a wall is no longer a click on the floor behind it.
		["floor-pick-hall-grey", "gallery", Vector3(1.5, 0, -24.5), Vector3(0.3, 0, -28.3), "far"]
	]
	var rows := []
	var failures := []
	for test in cases:
		walk._entrance_waiting = false
		walk._entrance_active = false
		walk._held.clear()
		walk._velocity = Vector3.ZERO
		walk._target = null
		walk._target_yaw = null
		walk._path.clear()
		walk._stall_t = 0.0
		walk._space = test[1]
		walk._pos = test[2]
		walk._last_pos = walk._pos
		walk._kid.position = walk._pos
		walk.view_mode = 0
		walk._view_turn_remaining = 0.0
		walk._portal_flash.modulate.a = 0.0
		if test[0] == "replace-crossing-click":
			walk._walk_to(Vector3(-2, 0, -24))
			for i in 20:
				walk._process(1.0 / 30.0)
		var floor_pick: bool = test[0].begins_with("floor-pick-")
		var pick_valid := true
		if floor_pick:
			walk.view_yaw = PI if test[1] == "far" else 0.0
			walk._update_camera(1.0)
			var pt: Vector2 = walk._to_screen(test[3])
			pick_valid = Rect2(Vector2.ZERO, walk.size).has_point(pt) and walk._painting_at(pt).is_empty()
			walk._click(pt)
		else:
			walk._walk_to(test[3])
		var planned = {"target": walk._target, "path": walk._path.duplicate()}
		var step := 0.0
		var crossed_wall := false
		var entered_bench := false
		var path := []
		for i in 1200:
			var previous: Vector3 = walk._pos
			walk._process(1.0 / 30.0)
			step = maxf(step, previous.distance_to(walk._pos))
			var p: Vector3 = walk._pos
			if previous.z < -walk.L and p.z >= -walk.L or previous.z >= -walk.L and p.z < -walk.L:
				crossed_wall = crossed_wall or absf(lerpf(previous.x, p.x, (-walk.L - previous.z) / (p.z - previous.z))) > .401
			if p.z > -walk.L + .55 and p.z < 0 and absf(p.x) < walk.BENCH_CLEAR.x - .001:
				for z in walk.BENCHES:
					entered_bench = entered_bench or absf(p.z - z) < walk.BENCH_CLEAR.y - .001
			path.append([p.x, p.z])
			if walk._target == null and walk._path.is_empty():
				break
		var remaining: float = walk._pos.distance_to(test[3])
		var passed: bool = remaining <= .08 and walk._space == test[4] and step <= .08 and not crossed_wall and not entered_bench and pick_valid
		rows.append({"name": test[0], "passed": passed, "input": "native floor ray and click handler" if floor_pick else "native target planner", "pick_valid": pick_valid, "space": walk._space, "remaining_m": remaining, "max_step_m": step, "crossed_wall": crossed_wall, "entered_bench": entered_bench, "planned": planned, "path": path})
		if not passed:
			failures.append(test[0])
	FileAccess.open(output.path_join("click-route-check.json"), FileAccess.WRITE).store_string(JSON.stringify({"rows": rows, "failures": failures}, "\t") + "\n")
	print("CLICK_ROUTE_CHECK ", JSON.stringify({"tests": rows.size(), "failures": failures}))
	app.queue_free()
	await process_frame
	await process_frame
	quit(0 if failures.is_empty() else 1)
