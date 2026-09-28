extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var gallery = load("res://modules/shell/prototype/gallery_walk4/visitor159/play.tscn").instantiate()
	root.add_child(gallery)
	await process_frame
	await process_frame
	gallery._entrance_waiting = false
	gallery._entrance_active = false
	gallery._target = null
	gallery._path.clear()
	gallery._pos = Vector3(-2.6, 0, -8)
	gallery._kid.position = gallery._pos
	gallery._kid.reset_contacts()
	gallery._motion_heading = Vector3.RIGHT
	gallery._kid.rotation.y = PI / 2.0
	gallery._kid.attention_target = gallery._paintings[0].center
	assert(gallery._kid.play_gesture("wave"))
	gallery._kid.pose(0.3, false, 0, Vector3.RIGHT, 0)
	assert(gallery._kid.gesture == "wave", "Interact did not start")
	var event := InputEventKey.new()
	event.keycode = KEY_D
	event.pressed = true
	gallery._unhandled_key_input(event)
	gallery._process(1.0 / 30.0)
	assert(gallery._kid.gesture == "", "Movement did not cancel Interact")
	assert(gallery._kid._clip == "Walking_A", "Movement did not enter walk clip")
	print("CANCEL_PASS: real D key event interrupted active Interact; next clip Walking_A")
	quit()
