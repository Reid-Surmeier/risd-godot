## Evidence for map #116 (prototype 4): all four walls, a walk, a painting approach, the zoomable detail view,
## the camera against a wall, in the real game's Collection tab.
## Run: godot --path . --script res://modules/shell/prototype/gallery_walk4/shot.gd -- --out-dir=<path>
extends "res://testing/harness_base.gd"

var walk: Control


func _pose(x: float, z: float, yaw_deg: float, name: String, out_dir: String) -> void:
	walk._pos = Vector3(x, 0, z)
	walk._yaw = deg_to_rad(yaw_deg)
	walk._target = null
	walk._target_yaw = null
	walk._update_camera(1.0)
	await create_timer(0.3).timeout
	await _shot(out_dir, name)


func _hold(code: Key, secs: float) -> void:
	var ev := InputEventKey.new()
	ev.keycode = code
	ev.pressed = true
	Input.parse_input_event(ev)
	await create_timer(secs).timeout
	var up := InputEventKey.new()
	up.keycode = code
	Input.parse_input_event(up)
	await process_frame


func _initialize() -> void:
	var main: Control = load("res://modules/shell/demo.tscn").instantiate()
	var out_dir := await _mount(main, Vector2i(1920, 1080), "/tmp/gallery-walk4")
	await create_timer(4.0).timeout
	walk = main.find_child("GalleryWalk", true, false)
	await _shot(out_dir, "01-start.png")
	await _pose(0, -3.0, 90, "02-west-wall-near.png", out_dir)
	await _pose(0, -14.0, 90, "03-west-wall-mid.png", out_dir)
	await _pose(0, -22.0, 90, "04-west-wall-far.png", out_dir)
	await _pose(0, -22.0, -90, "05-east-wall-far.png", out_dir)
	await _pose(0, -12.0, -90, "06-east-wall-mid.png", out_dir)
	await _pose(0, -3.0, -90, "07-east-wall-near.png", out_dir)
	await _pose(0, -18.0, 0, "08-far-end.png", out_dir)
	await _pose(0, -8.0, 180, "09-arch-end.png", out_dir)
	await _pose(-4.9, -12.0, -30, "10-camera-at-wall.png", out_dir)
	await _pose(0, -4.2, 0, "11-reset.png", out_dir)
	await _hold(KEY_UP, 3.0)
	await _shot(out_dir, "12-walked-3s.png")
	# click the Tiepolo from the middle of the room
	await _pose(0, -11.0, 70, "13-before-click.png", out_dir)
	var target := {}
	for p in walk._paintings:
		if p.tag == "W6":
			target = p
	var sp: Vector2 = walk.get_global_rect().position + walk._to_screen(target.center)
	await _click(sp, "Tiepolo")
	await create_timer(7.0).timeout
	await _shot(out_dir, "14-detail.png")
	for i in 6:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_WHEEL_UP
		ev.pressed = true
		ev.position = walk.get_global_rect().get_center() + Vector2(0, -120)
		ev.global_position = ev.position
		Input.parse_input_event(ev)
		await process_frame
	await create_timer(0.3).timeout
	await _shot(out_dir, "15-detail-zoomed.png")
	await _key(KEY_ESCAPE, "close")
	await create_timer(0.6).timeout
	await _shot(out_dir, "16-closed.png")
	quit(0)
