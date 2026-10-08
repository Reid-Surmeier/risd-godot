## Review harness for #275. Run in its draft after copying main_build_walk.gd
## to res://skylight_main_walk.gd and the unchanged character / close-icon assets.
## This does not replace or edit the repository's frozen acceptance tests.
extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var walk = load("res://skylight_main_walk.gd").new()
	root.add_child(walk)
	walk.set_process(false)
	if walk._rooms == null:
		walk._attach_rooms("res://remodel_room.tscn")
	walk._rooms_path = ""
	walk._space = "far"
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://geometry.json"))
	var failures := []
	var rows := []
	for trial in data.trials:
		if not str(trial[0]).begins_with("skylight_") and not str(trial[0]).begins_with("grey_skylight_"):
			continue
		walk._pos = Vector3(trial[1][0],trial[1][1]-.25,trial[1][2])+walk.ATTACH
		var goal: Vector3 = Vector3(trial[2][0],trial[2][1],trial[2][2])+walk.ATTACH
		var largest := 0.0
		for i in 800:
			var flat := Vector3(goal.x-walk._pos.x,0,goal.z-walk._pos.z)
			if flat.length() < .025:
				break
			var previous: Vector3 = walk._pos
			walk._pos = walk._clamp(walk._pos+flat.limit_length(.02))
			largest = maxf(largest,walk._pos.distance_to(previous))
		var reached: bool = Vector2(goal.x-walk._pos.x,goal.z-walk._pos.z).length() < .04
		var passed: bool = (not reached if trial[3] else reached and absf(walk._pos.y-goal.y)<.04) and largest<.05
		if not passed:
			failures.append(trial[0])
		var p: Vector3 = walk._pos-walk.ATTACH
		rows.append({"trial":trial[0],"passed":passed,"floor_m":p.y,"largest_step_m":largest})
	var entry: Vector3 = Vector3(5.55,0,-6.58)+walk.ATTACH
	var lower: Vector3 = Vector3(3.50,-2.55,-8.30)+walk.ATTACH
	for route in [[entry,lower],[lower,entry]]:
		walk._pos = route[0]
		walk._route_to(route[1])
		for i in 2500:
			var goal = walk._path[0] if not walk._path.is_empty() else walk._target
			if goal == null:
				break
			var flat: Vector3 = goal-walk._pos
			flat.y = 0
			if flat.length() < .025:
				if not walk._path.is_empty():
					walk._path.pop_front()
				else:
					walk._target = null
			else:
				walk._move_to(walk._pos+flat.limit_length(.02))
		var passed: bool = walk._pos.distance_to(route[1])<.06
		if not passed:
			failures.append("pulled click route "+str(route))
		rows.append({"click_route":str(route),"passed":passed,"arrived":str(walk._pos-walk.ATTACH)})
	var output := {"trials":rows,"failures":failures,"actual_attached_room":walk.state(),"navigation_accepted":false}
	print("SKYLIGHT_GAME_ROUTES ",JSON.stringify(output))
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			FileAccess.open(arg.trim_prefix("--out="),FileAccess.WRITE).store_string(JSON.stringify(output,"  "))
	walk.free()
	quit(0 if failures.is_empty() else 1)
