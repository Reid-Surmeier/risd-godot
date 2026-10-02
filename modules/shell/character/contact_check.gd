extends SceneTree
## Measure actual soles through every gait-change phase, independently of the scheduler.
var demo: Node3D
var cases := 0
var cues := 0
var peak := {"Left": 0.0, "Right": 0.0}
var substantial := {"Left": false, "Right": false}
var cycle := {"Left": 0, "Right": 0}
var wraps := 0


func _initialize() -> void:
	call_deferred("run")


func release_all() -> void:
	for action in ["down", "up", "left", "right", "sprint", "slow"]:
		Input.action_release(action)


func tick(_frame: int, steady: bool) -> void:
	if demo.audio_history.size() > 40:
		demo.audio_history.clear()
	var prior: int = demo.audio_history.size()
	var phase: float = demo.movement.phase
	demo._physics_process(1.0 / 60)
	demo.skeleton.force_update_all_bone_transforms()
	var fresh: Array = demo.audio_history.slice(prior)
	var active: bool = demo.state in ["Walk", "Run", "Dash"] and demo.body.is_on_floor()
	for side in ["Left", "Right"]:
		var height := INF
		for sole in demo.soles:
			if demo.skeleton.get_bone_name(sole.bone) == side + "Foot":
				height = minf(
					height,
					(
						(
							(
								demo.skeleton.global_transform
								* (demo.skeleton.get_bone_global_pose(sole.bone) * sole.point)
							)
							. y
						)
						- demo.body.position.y
					)
				)
		var heard: bool = fresh.any(func(cue): return cue.get("foot", "") == side)
		if active:
			peak[side] = maxf(peak[side], height)
			if height >= .06:
				substantial[side] = true
			if height <= .01 and substantial[side]:
				assert(heard, "A substantial swing landed without its cue")
				substantial[side] = false
			if heard:
				assert(height <= .0101, "Footstep played before planting")
				assert(peak[side] >= .05, "Toe roll played as a stride across a gait change")
				peak[side] = 0.0
				cycle[side] += 1
				cues += 1
		else:
			peak[side] = 0.0
			substantial[side] = false
	if steady and demo.movement.phase < phase:
		if wraps >= 2:
			assert(
				cycle.Left == 1 and cycle.Right == 1, "Steady gait has extra or missing contacts"
			)
		wraps += 1
		cycle = {"Left": 0, "Right": 0}
	# Keep the probe on open floor; never alter movement or bone poses.
	if demo.body.position.z > 6:
		demo.body.position.z -= 12
	elif demo.body.position.z < -6:
		demo.body.position.z += 12
	if absf(demo.body.position.x) > 3:
		demo.body.position.x -= signf(demo.body.position.x) * 6


func one(kind: String, offset: int) -> void:
	release_all()
	demo.reset()
	peak = {"Left": 0.0, "Right": 0.0}
	substantial = {"Left": false, "Right": false}
	cycle = {"Left": 0, "Right": 0}
	wraps = 0
	for frame in 30:
		demo._physics_process(1.0 / 60)
	if not kind.begins_with("start"):
		Input.action_press("down")
	if kind.begins_with("dash"):
		Input.action_press("sprint")
	if kind.begins_with("walk"):
		Input.action_press("slow")
	var lead := offset if kind.begins_with("start") else 90 + offset
	for frame in 420 if kind.ends_with("steady") else lead + 70:
		if frame == lead:
			match kind:
				"run_stop", "dash_stop", "walk_stop":
					release_all()
				"run_slow":
					Input.action_press("slow")
				"run_dash":
					Input.action_press("sprint")
				"dash_run":
					Input.action_release("sprint")
				"walk_run":
					Input.action_release("slow")
				"run_turn":
					Input.action_release("down")
					Input.action_press("right")
				"start_run", "start_walk":
					Input.action_press("down")
					if kind == "start_walk":
						Input.action_press("slow")
		tick(frame, kind.ends_with("steady"))
	cases += 1


func run() -> void:
	demo = load("res://modules/shell/character/demo.gd").new()
	root.add_child(demo)
	demo.set_physics_process(false)
	# This fast pose sweep checks dispatch, not mixer wall time (audio_check checks that).
	demo.foot_audio.volume_db = -80
	for kind in ["run_stop", "run_slow", "run_dash", "run_turn"]:
		for offset in 34:
			one(kind, offset)
	for kind in ["dash_stop", "dash_run"]:
		for offset in 27:
			one(kind, offset)
	for kind in ["walk_stop", "walk_run"]:
		for offset in 50:
			one(kind, offset)
	for kind in ["start_run", "start_walk"]:
		for offset in range(0, 64, 4):
			one(kind, offset)
	for kind in ["walk_steady", "run_steady", "dash_steady"]:
		one(kind, 0)
	release_all()
	FileAccess.open("res://contact-check.json", FileAccess.WRITE).store_string(
		JSON.stringify(
			{
				"cases": cases,
				"cues": cues,
				"no_toe_roll_cues": true,
				"no_missed_substantial_swings": true
			}
		)
	)
	print("PASS independent sole contacts across ", cases, " phase cases and steady gaits")
	demo.free()
	OS.delay_msec(100)
	quit()
