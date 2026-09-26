## Evidence for map #116 (prototype 4): all four walls, a walk, a painting approach, the zoomable detail view,
## the camera against a wall, in the real game's Collection tab.
## Run: godot --path . --script res://modules/shell/prototype/gallery_walk4/shot.gd -- --out-dir=<path>
extends "res://testing/harness_base.gd"

var walk: Control
var failed := 0


func _require(ok: bool, message: String) -> void:
	if not ok:
		failed += 1
		push_error(message)


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
	# The original view remains a user-selectable comparison.
	for choice in walk.find_children("*", "OptionButton", true, false):
		for index in choice.item_count:
			if choice.get_item_text(index) == "Original":
				choice.select(index)
				choice.item_selected.emit(index)
	walk._pos = Vector3(0, 0, -4.2)
	walk._update_camera(1.0)
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
	var w6 := {}
	for p in walk._paintings:
		if p.tag == "W6":
			w6 = p
	await _pose(-2.6, w6.center.z - 2.2, 130, "17-tiepolo-oblique.png", out_dir)
	await _pose(0.6, -21.5, 0, "18-far-door.png", out_dir)
	await _pose(-0.6, -4.5, 180, "19-arch-door.png", out_dir)
	await _pose(2.0, -12.0, 200, "20-floor.png", out_dir)
	# click a painting across the room, past a bench: must route round it and open
	await _pose(-3.5, -12.0, -100, "21-before-cross-click.png", out_dir)
	var e5 := {}
	for p in walk._paintings:
		if p.tag == "E4":
			e5 = p
	await _click(walk.get_global_rect().position + walk._to_screen(e5.center), "E4 across the room")
	await create_timer(12.0).timeout
	await _shot(out_dir, "22-cross-click-detail.png")
	await _key(KEY_ESCAPE, "close")
	await create_timer(0.6).timeout
	# Astra round 2 case: from W7, click E4 across a bench at an angle
	var w7 := {}
	for p in walk._paintings:
		if p.tag == "W7":
			w7 = p
	await _pose(-3.2, w7.center.z, -60, "23-from-w7.png", out_dir)
	await _click(walk.get_global_rect().position + walk._to_screen(e5.center), "E4 from W7")
	await create_timer(14.0).timeout
	await _shot(out_dir, "24-w7-to-e4-detail.png")
	await _key(KEY_ESCAPE, "close")
	await create_timer(0.6).timeout
	# click far-end N1 from the start, then tap S: must step back locally
	await _pose(0, -4.2, 0, "25-start-again.png", out_dir)
	var n1 := {}
	for p in walk._paintings:
		if p.tag == "N1":
			n1 = p
	await _click(walk.get_global_rect().position + walk._to_screen(n1.center), "N1")
	await create_timer(1.0).timeout
	var z_before: float = walk._pos.z
	await _key(KEY_S, "step back")
	await create_timer(2.0).timeout
	_require(walk._pos.z > z_before + 0.5, "back input did not cancel approach and step back")
	print("STEP-BACK z before %.2f after %.2f target %s" % [z_before, walk._pos.z, str(walk._target)])
	await _shot(out_dir, "26-after-step-back.png")
	# Astra round 3: past both benches, from the far end to the arch end
	await _pose(0, -24.0, 180, "27-far-end-facing-arch.png", out_dir)
	walk._walk_to(Vector3(0, 0, -5.0))
	await create_timer(20.0).timeout
	_require(walk._pos.distance_to(Vector3(0, 0, -5.0)) < 0.1 and walk._target == null, "both benches route did not finish")
	print("BOTH-BENCHES end pos %s target %s" % [str(walk._pos), str(walk._target)])
	await _shot(out_dir, "28-after-both-benches.png")
	# Astra round 4: starting against the first bench, to beyond the second
	walk._pos = walk._clamp(Vector3(0, 0, -7.2))
	walk._update_camera(1.0)
	walk._walk_to(Vector3(0, 0, -18.9))
	print("AGAINST-BENCH path %s" % str(walk._path))
	await create_timer(20.0).timeout
	_require(walk._pos.distance_to(Vector3(0, 0, -18.9)) < 0.1 and walk._target == null, "against bench route did not finish")
	print("AGAINST-BENCH end pos %s target %s" % [str(walk._pos), str(walk._target)])
	# 300 random walks through the real movement code (stepped, not timed): each must arrive
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var fails := 0
	for n in 300:
		var a := Vector3(rng.randf_range(-4.5, 4.5), 0, rng.randf_range(-25.8, -0.5))
		var b := Vector3(rng.randf_range(-4.5, 4.5), 0, rng.randf_range(-25.8, -0.5))
		walk._pos = walk._clamp(a)
		walk._walk_to(b)
		var steps := 0
		while (walk._target != null or not walk._path.is_empty()) and steps < 2000:
			walk._process(0.05)
			steps += 1
		if walk._pos.distance_to(walk._clamp(b)) > 0.1:
			fails += 1
			if fails <= 5:
				print("FUZZ fail from %s to %s ended %s" % [str(walk._pos), str(walk._clamp(b)), str(walk._pos)])
	_require(fails == 0, "random routes failed")
	print("FUZZ %d of 300 walks failed" % fails)
	# a painting half out of view: close to the east wall, looking along it; click its visible part
	var e6 := {}
	for p in walk._paintings:
		if p.tag == "E6":
			e6 = p
	await _pose(3.2, e6.center.z + 1.6, -35, "29-half-visible.png", out_dir)
	var poly: PackedVector2Array = walk._visible_outline(e6.corners)
	var inside := Rect2(Vector2.ZERO, walk.size)
	var pick := Vector2(-1, -1)
	for q in poly:
		if inside.grow(-20).has_point(q):
			pick = q
			break
	var cen := Vector2.ZERO
	for q in poly:
		cen += q / poly.size()
	pick = pick.lerp(cen, 0.3) if pick.x >= 0 else cen
	print("HALF-VISIBLE picks %s at %s" % [walk._painting_at(pick).get("tag", "none"), str(pick)])
	await _click(walk.get_global_rect().position + pick, "E6 half visible")
	await create_timer(6.0).timeout
	_require(walk._open.get("tag", "none") == "E6", "visible part of E6 must open E6")
	print("HALF-VISIBLE open %s" % walk._open.get("tag", "none"))
	await _shot(out_dir, "30-half-visible-detail.png")
	quit(1 if failed else 0)
