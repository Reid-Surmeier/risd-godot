extends "res://testing/harness_base.gd"


func _initialize() -> void:
	var main: Control = load("res://modules/shell/demo.tscn").instantiate()
	var out := await _mount(main, Vector2i(720, 486), "/tmp/gallery-pitch-corner")
	await create_timer(4.0).timeout
	var walk: Control = main.find_child("GalleryWalk", true, false)
	if walk == null:
		push_error("GalleryWalk absent")
		quit(1)
		return
	walk._new_action()
	walk._entrance_waiting = false
	walk._entrance_active = false
	walk._target = null
	walk._path.clear()
	walk._held.clear()
	walk._velocity = Vector3.ZERO
	walk._pos = Vector3(-4.45, 0.0, -2.56)
	walk._last_pos = walk._pos
	walk.view_yaw = 2.65
	walk._yaw = 2.65
	walk._view_turn_remaining = 0.0
	walk.set_process(false)
	walk._process(0.0)
	walk._update_camera(1.0)
	await _frames(8)
	await _shot(out, "corner.png")
	print(
		"CORNER_CAM ",
		walk._cam.global_transform.origin,
		" yaw=",
		walk.view_yaw,
		" fov=",
		walk._cam.fov,
		" size=",
		get_root().size
	)
	quit(0)
