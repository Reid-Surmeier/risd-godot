## Private #167 continuous-world regression; screenshots are the visual gate.
extends "res://testing/harness_base.gd"
var failures := 0


func require(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var walk = load("res://modules/shell/prototype/gallery_walk4/walk4.gd").new()
	walk.size = Vector2(720, 540)
	walk.set_process(false)
	var out := await _mount(walk, Vector2i(720, 540), "/tmp/risd-167-continuity-red")
	walk.set_process(false)
	walk._new_action()
	walk._entrance_active = false
	walk._entrance_waiting = false
	walk._target = null
	walk._kid.hide()
	walk._shadow.hide()
	for shadow in walk._sole_shadows:
		shadow.hide()
	for width in [720, 1600]:
		var dimensions := Vector2i(width, width * 3 / 4)
		root.size = dimensions
		walk.size = dimensions
		walk._space = "gallery"
		walk._held.clear()
		walk._velocity = Vector3.ZERO
		walk.view_yaw = PI
		walk._pos = Vector3(0, 0, -2.6)
		walk._update_camera(1.0)
		await _frames(4)
		await _shot(out, "%s-approach.png" % width)
		walk._held["up"] = 0.0
		for frame in 300:
			walk._process(1.0 / 60.0)
		require(walk._space == "arch", "arch was not entered")
		require(walk._pos.z > 2.0, "arch entry teleported to QA room or stopped at threshold")
		require(walk._cam.cull_mask < 64, "arch camera still shows QA room layers")
		require(
			walk._baked_room.get_node("Lightmap").visible,
			"modeled portal lighting hidden after entry"
		)
		await _frames(4)
		await _shot(out, "%s-inside.png" % width)
		walk._held.clear()
		walk._orbit(PI)
		for frame in 90:
			walk._process(1.0 / 60.0)
		await _frames(4)
		await _shot(out, "%s-inside-looking-back.png" % width)
		walk._orbit(PI)
		for frame in 90:
			walk._process(1.0 / 60.0)
		walk._held["down"] = 0.0
		for frame in 300:
			walk._process(1.0 / 60.0)
		require(walk._space == "gallery" and walk._pos.z < -1.0, "continuous arch return failed")
		await _frames(4)
		await _shot(out, "%s-return.png" % width)
		print(
			"PORTAL_CONTINUITY width=",
			width,
			" position=",
			walk._pos,
			" mask=",
			walk._cam.cull_mask,
			" failures=",
			failures
		)
	var mouth: float = walk.PORTAL_MOUTH
	walk._space = "arch"
	walk._pos = Vector3(0.4, 0, mouth - 0.2)
	walk._move_to(Vector3(2.0, 0, mouth + 0.1))
	require(walk._pos.x <= 0.401, "outward diagonal crossed stone jamb")
	walk._pos = Vector3(2.0, 0, mouth + 0.1)
	walk._move_to(Vector3(0, 0, mouth - 0.2))
	require(walk._pos.z >= mouth - 0.001, "inward diagonal crossed stone jamb")
	walk.queue_free()
	await _frames(2)
	quit(1 if failures else 0)
