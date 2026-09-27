## #135 native navigation regression; uses delivered input events, not replacement motion logic.
## godot --rendering-method gl_compatibility --path . --script res://modules/shell/prototype/gallery_walk4/navigation_check.gd
extends "res://testing/harness_base.gd"

var failures := 0
var walk: Control

func _require(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _advance(seconds: float) -> void:
	# Deterministic stepping of the actual runtime while process is disabled.
	for frame in ceili(seconds * 60.0):
		walk._process(1.0 / 60.0)
	await process_frame

func _hold(code: Key, seconds: float) -> void:
	walk.grab_focus()
	var down := InputEventKey.new()
	down.keycode = code
	down.pressed = true
	Input.parse_input_event(down)
	await process_frame
	await _advance(seconds)
	var up := InputEventKey.new()
	up.keycode = code
	Input.parse_input_event(up)
	await process_frame

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var loader := Control.new()
	loader.name = "BootLoader"
	root.add_child(loader)
	walk = load("res://modules/shell/prototype/gallery_walk4/walk4.gd").new()
	walk.size = Vector2(1152, 720)
	walk.set_process(false)
	var out := await _mount(walk, Vector2i(1152, 720), "/tmp/gallery-navigation")
	walk.set_process(false)
	_require(walk._entrance_active and walk._pos.z > -1.2, "viewer did not begin entering through arch")
	var waiting_pos: Vector3 = walk._pos
	await _advance(0.5)
	_require(walk._pos == waiting_pos and walk._entrance_waiting, "entrance played underneath boot loader")
	root.remove_child(loader)
	loader.queue_free()
	await _shot(out, "01-entrance.png")
	var entry_from: Vector3 = walk._pos
	await _advance(0.2)
	var moving_image: Image = walk._kid.texture.get_image()
	var cell := Vector2i(moving_image.get_width() / walk._kid.hframes, moving_image.get_height() / walk._kid.vframes)
	var cell_origin: Vector2i = walk._kid.frame_coords * cell
	var first_pixels := hash(moving_image.get_region(Rect2i(cell_origin, cell)).get_data())
	await _advance(0.3)
	moving_image = walk._kid.texture.get_image()
	cell_origin = walk._kid.frame_coords * cell
	_require(hash(moving_image.get_region(Rect2i(cell_origin, cell)).get_data()) != first_pixels, "visible entrance sprite stayed on one frame")
	_require(walk._pos.z < entry_from.z - 0.4 and walk._kid_t > 0.0, "entrance did not advance walk animation")
	await _shot(out, "01b-entrance-walking.png")
	await _advance(2.5)
	_require(not walk._entrance_active and walk._pos.z < -2.5, "entry animation did not walk into gallery")
	var settled: Vector3 = walk._pos
	walk.hide()
	walk.show()
	await _advance(0.2)
	_require(walk._pos.distance_to(settled) < 0.001, "tab return restarted entrance")
	# Each real doorway roundtrip uses the same click-walk movement path as the gallery.
	for side in ["arch", "far"]:
		walk._pos = Vector3(0, 0, -1.0 if side == "arch" else -walk.L + 1.0)
		walk._walk_to(Vector3(0, 0, 0.2 if side == "arch" else -walk.L - 0.2))
		await _advance(1.3)
		_require(walk._space == side, "could not exit through " + side)
		_require(not walk.get_node("OtherWall").visible and not walk._painting_shown(walk._paintings[0]), "white room exposed gallery interactions")
		walk._walk_to(Vector3(2.0, 0, -4.0))
		await _advance(4.0)
		_require(walk._pos.distance_to(Vector3(2.0, 0, -4.0)) < 0.08, "white room was not traversable")
		await create_timer(0.3).timeout
		await _shot(out, "02-white-" + side + ".png")
		var wall: Vector3 = walk._clamp(Vector3(30, 0, 30))
		_require(wall.x <= 2.451 and wall.z <= -0.549, "white room wall limit failed")
		walk._walk_to(Vector3(0, 0, -2.5))
		await _advance(2.5)
		walk.view_yaw = PI
		walk._update_camera(1.0)
		await _shot(out, "03-return-door-" + side + ".png")
		walk._walk_to(Vector3(0, 0, 0.2))
		await _advance(4.4)
		_require(walk._space == "gallery", "could not return from " + side)
		_require(absf(walk._pos.z - (-0.7 if side == "arch" else -walk.L + 0.7)) < 0.08, "returned to wrong doorway")
		print("NAV_ROUNDTRIP ", side, " passed")
	# Input-delivery coverage complements the route checks above: the same real
	# key events used by the viewer must cross both portals and return correctly.
	for side in ["arch", "far"]:
		walk._pos = Vector3(0, 0, -1.0 if side == "arch" else -walk.L + 1.0)
		walk.view_yaw = PI if side == "arch" else 0.0
		await _hold(KEY_W, 0.9)
		_require(walk._space == side, "real W input did not enter " + side + " white room")
		walk._pos = Vector3(2.45, 0, -3)
		var blocked_at: Vector3 = walk._pos
		await _hold(KEY_D, 0.8)
		_require(walk._pos.distance_to(blocked_at) < 0.01, "real D input crossed white room wall")
		walk._pos = Vector3(0, 0, -0.7)
		await _hold(KEY_S, 0.7)
		_require(walk._space == "gallery", "real S input did not return from " + side)
		_require(absf(walk._pos.z - (-0.7 if side == "arch" else -walk.L + 0.7)) < 0.08, "key traversal returned to wrong gallery end")
		print("NAV_KEY_ROUNDTRIP ", side, " passed")
	# The door floor must also be reachable by the actual click ray, not only
	# by supplying a private route target or holding a movement key.
	for side in ["arch", "far"]:
		walk._pos = Vector3(0, 0, -1.0 if side == "arch" else -walk.L + 1.0)
		walk.view_yaw = PI if side == "arch" else 0.0
		walk._update_camera(1.0)
		await _frames(2)
		var door_floor := Vector3(0, 0, 0.15 if side == "arch" else -walk.L - 0.15)
		var point: Vector2 = walk._to_screen(door_floor)
		_require(Rect2(Vector2.ZERO, walk.size).has_point(point), "door floor cannot be clicked on screen: " + side)
		await _click(walk.global_position + point, "exit via " + side + " floor")
		await _advance(1.5)
		_require(walk._space == side, "real floor click did not enter " + side)
		walk.view_yaw = PI
		walk._update_camera(1.0)
		await _frames(2)
		point = walk._to_screen(Vector3(0, 0, 0.15))
		await _click(walk.global_position + point, "return through white doorway")
		await _advance(1.2)
		_require(walk._space == "gallery", "real floor click did not return from " + side)
		_require(absf(walk._pos.z - (-0.7 if side == "arch" else -walk.L + 0.7)) < 0.08, "clicked return chose wrong gallery end")
		print("NAV_CLICK_ROUNDTRIP ", side, " passed")
	# A diagonal cannot jump through a solid wall beside either doorway.
	for z in [0.0, -walk.L]:
		walk._pos = Vector3(1.2, 0, z + (-0.8 if z == 0 else 0.8))
		walk._move_to(Vector3(0, 0, z + (0.2 if z == 0 else -0.2)))
		_require(absf(walk._pos.z - z) >= 0.54, "diagonal cut through doorway jamb")
	walk._pos = Vector3(-2.6, 0, -12)
	walk.view_yaw = PI / 2.0
	walk._update_camera(1.0)
	await _frames(2)
	var start := Vector2(580, 400)
	await _button(start, MOUSE_BUTTON_LEFT, true)
	_require(walk._target == null, "press immediately clicked painting/floor before drag decision")
	var motion := InputEventMouseMotion.new()
	motion.position = start + Vector2(150, 0)
	motion.global_position = motion.position
	motion.relative = Vector2(150, 0)
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(motion)
	await process_frame
	var old_yaw: float = walk.view_yaw
	_require(absf(walk._view_turn_remaining) > 0.1, "mouse drag did not request turn")
	await _advance(1.0 / 60.0)
	_require(absf(walk.view_yaw - old_yaw) > 0.001 and absf(walk._view_turn_remaining) > 0.1, "turn was not eased across frames")
	await _button(motion.position, MOUSE_BUTTON_LEFT, false)
	_require(walk._target == null and walk._open.is_empty(), "drag release clicked art/floor")
	await _advance(1.0)
	_require(absf(walk._view_turn_remaining) < 0.001, "turn never settled")
	var pan := InputEventPanGesture.new()
	pan.position = start
	pan.delta = Vector2(4, 0)
	Input.parse_input_event(pan)
	await process_frame
	_require(walk._view_turn_remaining < -0.1, "trackpad pan did not turn")
	await _advance(1.0)
	await _button(start, MOUSE_BUTTON_WHEEL_LEFT, true)
	_require(walk._view_turn_remaining > 0.05, "horizontal wheel did not turn")
	await _advance(1.0)
	walk._update_camera(1.0)
	var floor_pt: Vector2 = walk._to_screen(walk._pos + Vector3(0, 0, -0.8))
	await _click(floor_pt, "floor click")
	_require(walk._target != null or not walk._path.is_empty(), "plain click did not walk")
	_require(walk._paintings.size() == 23, "gallery lost artwork")
	# User movement cancels the one-shot entrance immediately.
	walk._pos = Vector3(0, 0, 0.15)
	walk._target = Vector3(0, 0, -2.6)
	walk._entrance_active = true
	walk.grab_focus()
	await _key(KEY_A, "interrupt entrance")
	_require(not walk._entrance_active and walk._target == null, "movement did not cancel entrance")
	print("NAV_INPUT drag/easing/pan/wheel/click/cancel passed; paintings=", walk._paintings.size())
	print("NAV_FAILURES ", failures)
	quit(1 if failures else 0)
