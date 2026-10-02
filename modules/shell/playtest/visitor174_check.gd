extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	# #236: the accepted #235 character replaced the Hair36 visitor behind the same surface.
	var visitor = load("res://modules/shell/character/visitor.gd").new()
	visitor.world_height = 1.75
	root.add_child(visitor)
	await process_frame
	assert(visitor.target.get_bone_count() == 24, "accepted 24-bone rig missing")
	assert(
		visitor.player.has_animation("idle") and visitor.player.has_animation("walk"),
		"accepted locomotion clips missing"
	)
	assert(
		not visitor.play_gesture("wave") and not visitor.play_gesture("look"),
		"gestures must be disabled"
	)
	var lowest := INF
	var highest := -INF
	for mesh in visitor.meshes:
		var arrays: Array = mesh.mesh.surface_get_arrays(0)
		for vertex in arrays[Mesh.ARRAY_VERTEX].size():
			var point := Vector3.ZERO
			for k in 4:
				var bind: int = arrays[Mesh.ARRAY_BONES][vertex * 4 + k]
				var bone: int = mesh.skin.get_bind_bone(bind)
				if bone < 0:
					bone = visitor.target.find_bone(mesh.skin.get_bind_name(bind))
				point += (
					(
						visitor.target.get_bone_global_rest(bone)
						* (mesh.skin.get_bind_pose(bind) * arrays[Mesh.ARRAY_VERTEX][vertex])
					)
					* arrays[Mesh.ARRAY_WEIGHTS][vertex * 4 + k]
				)
			lowest = minf(lowest, point.y)
			highest = maxf(highest, point.y)
	var rest_height: float = (highest - lowest) * visitor.target.global_basis.get_scale().y
	assert(
		absf(rest_height / visitor.model.scale.y - visitor.REST_HEIGHT) < 0.01,
		"REST_HEIGHT no longer matches walk.glb: %s" % (rest_height / visitor.model.scale.y)
	)
	# LANDINGS must be where the walk clip really puts each foot down after its high lift.
	for gait in ["walk", "run", "dash"]:
		visitor.player.play(gait)
		var clip_length: float = visitor.player.get_animation(gait).length
		var lifted := [false, false]
		var landed := [-1.0, -1.0]
		for sample in 960:
			visitor.player.seek(clip_length * (sample % 480) / 480.0, true)
			visitor.target.force_update_all_bone_transforms()
			var lows := []
			for foot in visitor._feet:
				var bone: Transform3D = (
					visitor.target.global_transform
					* visitor.target.get_bone_global_pose(foot.bone)
				)
				var low := INF
				for point in foot.points:
					low = minf(low, (bone * point).y)
				lows.append(low)
			for side in 2:
				var height: float = (lows[side] - minf(lows[0], lows[1])) / visitor.model.scale.y
				if height > visitor.LIFT:
					lifted[side] = true
				elif lifted[side] and height < visitor.PLANT:
					lifted[side] = false
					landed[side] = (sample % 480) / 480.0
		for side in 2:
			assert(
				absf(landed[side] - visitor.LANDINGS[gait][side]) < 0.02,
				"LANDINGS no longer match the %s clip: %s" % [gait, landed]
			)
	visitor.reset()
	visitor.pose(0.0, false, 0.0, Vector3.FORWARD, 0.0)
	var idle_steps := 0
	for _tick in 120:
		visitor.pose(1.0 / 60.0, false, 0.0, Vector3.FORWARD, 0.0)
		idle_steps += visitor.contacts
	assert(visitor._clip == "idle" and idle_steps == 0, "idle visitor stepped")
	# Four seconds at the museum's 1.2 m/s: the accepted coupling gives ~1.16 cycles a second.
	var steps := 0
	for _tick in 240:
		visitor.position.z -= 1.2 / 60.0
		visitor.pose(1.0 / 60.0, true, 0.0, Vector3.FORWARD, 0.0)
		steps += visitor.contacts
		for sole in visitor.sole_positions():
			assert(sole.y > -0.001, "sole went through the floor")
		assert(visitor.sole_support().has(true), "both feet left the floor while walking")
	assert(visitor._clip == "walk", "walking did not select the accepted clip")
	assert(steps >= 8 and steps <= 10, "step cadence is not two contacts a cycle: %s" % steps)
	for _tick in 30:
		visitor.pose(1.0 / 60.0, false, 0.0, Vector3.FORWARD, 0.0)
	assert(visitor._clip == "idle", "stopping did not return to idle")
	# The museum's sprint: three metres a second selects the dash clip and still lands steps.
	var dash_steps := 0
	for _tick in 120:
		visitor.position.z -= 3.0 / 60.0
		visitor.pose(1.0 / 60.0, true, 0.0, Vector3.FORWARD, 0.0)
		dash_steps += visitor.contacts
	assert(visitor._clip == "dash", "sprinting did not select the dash clip: %s" % visitor._clip)
	assert(dash_steps >= 5 and dash_steps <= 9, "dash step cadence is wrong: %s" % dash_steps)
	# A hop: leaves the floor, comes back, makes no footsteps in the air, ends in a gait.
	visitor.jump()
	var top := 0.0
	var air_steps := 0
	for _tick in 90:
		visitor.pose(1.0 / 60.0, false, 0.0, Vector3.FORWARD, 0.0)
		var soles: Array = visitor.sole_positions()
		top = maxf(top, minf(soles[0].y, soles[1].y))
		air_steps += visitor.contacts
	assert(top > 0.4 and top < 0.9, "jump height is not the accepted hop: %s" % top)
	assert(air_steps == 0, "footsteps sounded during a jump")
	assert(visitor._air < 0.0 and visitor._clip == "idle", "the jump did not land and settle")
	for sole in visitor.sole_positions():
		assert(absf(sole.y) < 0.02, "the visitor did not return to the floor after a jump")
	visitor.queue_free()
	await process_frame
	var gallery = load("res://modules/shell/prototype/gallery_walk4/walk4.gd").new()
	root.add_child(gallery)
	await create_timer(3.0).timeout
	assert(gallery._paintings.size() == 23, "gallery paintings missing")
	assert(
		gallery._kid.get_script().resource_path.ends_with("character/visitor.gd"),
		"runtime visitor is not the accepted character"
	)
	var start: Vector3 = gallery._pos
	_key(gallery, KEY_D, true)
	await create_timer(0.7).timeout
	assert(
		gallery._kid._clip == "walk" and gallery._pos.distance_to(start) > 0.2,
		"runtime walk did not move"
	)
	for sole in gallery._kid.sole_positions():
		assert(sole.y >= -0.001, "shoe sole penetrated the gallery floor")
	assert(gallery._kid.sole_support().has(true), "walk cycle never planted a foot")
	_key(gallery, KEY_D, false)
	await create_timer(0.5).timeout
	assert(gallery._kid._clip == "idle", "runtime stop did not return to idle")
	var forward_heading: float = gallery._kid.rotation.y
	var reverse_start: Vector3 = gallery._pos
	_key(gallery, KEY_A, true)
	await create_timer(0.8).timeout
	_key(gallery, KEY_A, false)
	var reverse_delta: Vector3 = gallery._pos - reverse_start
	assert(reverse_delta.length() > 0.2, "runtime reversal did not move")
	assert(
		absf(wrapf(gallery._kid.rotation.y - forward_heading, -PI, PI)) > 2.5,
		"runtime reversal did not turn around"
	)
	gallery._set_view(2)
	await process_frame
	var turn_start: float = gallery._kid.rotation.y
	for _step in 2:
		_key(gallery, KEY_LEFT, true)
		_key(gallery, KEY_LEFT, false)
		await create_timer(0.7).timeout
	var quarter_turn := absf(wrapf(gallery._kid.rotation.y - turn_start, -PI, PI))
	if absf(quarter_turn - PI / 2.0) >= 0.1:
		push_error("runtime 90-degree turn failed: %s" % quarter_turn)
		gallery.queue_free()
		await process_frame
		quit(1)
		return
	for _step in 2:
		_key(gallery, KEY_LEFT, true)
		_key(gallery, KEY_LEFT, false)
		await create_timer(0.7).timeout
	var half_turn := absf(wrapf(gallery._kid.rotation.y - turn_start, -PI, PI))
	if absf(half_turn - PI) >= 0.1:
		push_error("runtime 180-degree turn failed: %s" % half_turn)
		gallery.queue_free()
		await process_frame
		quit(1)
		return
	assert(
		not gallery._kid.play_gesture("wave") and not gallery._kid.play_gesture("look"),
		"runtime gesture entered"
	)
	gallery.queue_free()
	await process_frame
	print(
		(
			"PASS #236: accepted character, 24-bone rig, 23 paintings, start/walk/stop/reversal, "
			+ "90/180-degree turns, floor contact and step cadence, gestures disabled"
		)
	)
	quit()


func _key(gallery: Control, code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = pressed
	gallery._unhandled_key_input(event)
