## PROTOTYPE 3 evidence: the game's main scene, Collection tab, driven with real key presses and clicks.
## Run: godot --path . --script res://modules/shell/prototype/gallery_walk3/shot.gd -- --out-dir=<path>
extends "res://testing/harness_base.gd"


func _hold(code: Key, secs: float) -> void:
	var ev := InputEventKey.new()
	ev.keycode = code
	ev.pressed = true
	Input.parse_input_event(ev)
	await create_timer(secs).timeout
	var up := InputEventKey.new()
	up.keycode = code
	up.pressed = false
	Input.parse_input_event(up)
	await process_frame


func _initialize() -> void:
	var main: Control = load("res://modules/shell/demo.tscn").instantiate()
	var out_dir := await _mount(main, Vector2i(1920, 1080), "/tmp/gallery-walk3")
	await create_timer(4.0).timeout
	var walk: Control = main.find_child("GalleryWalk", true, false)
	await _shot(out_dir, "01-start.png")
	await _hold(KEY_UP, 2.5)
	await _shot(out_dir, "02-walked-forward.png")
	await _key(KEY_UP, "step")
	await create_timer(1.2).timeout
	await _shot(out_dir, "03-one-step.png")
	await _key(KEY_LEFT, "turn left")
	await create_timer(0.8).timeout
	await _shot(out_dir, "04-turned-left.png")
	# click the first painting on the left (west) wall that is in view
	var cam: Camera3D = walk._cam
	var target := Vector2(-1, -1)
	for p in walk._paintings:
		if cam.is_position_behind(p.center):
			continue
		var s: Vector2 = cam.unproject_position(p.center) / Vector2(walk.LOW_RES) * walk.size
		if s.x > walk.size.x * 0.1 and s.x < walk.size.x * 0.9 and s.y > 0 and s.y < walk.size.y:
			target = walk.get_global_rect().position + s
			break
	if target.x >= 0:
		await _click(target, "painting")
		await create_timer(1.0).timeout
		await _shot(out_dir, "05-walking-to-painting.png")
		await create_timer(5.0).timeout
		await _shot(out_dir, "06-detail.png")
		await _key(KEY_ESCAPE, "close")
		await create_timer(0.8).timeout
		await _shot(out_dir, "07-at-the-wall.png")
	await _key(KEY_DOWN, "step back")
	await create_timer(1.2).timeout
	await _shot(out_dir, "08-stepped-back.png")
	await _key(KEY_RIGHT, "turn right")
	await _key(KEY_RIGHT, "turn right")
	await create_timer(1.2).timeout
	await _shot(out_dir, "09-turned-right.png")
	quit(0)
