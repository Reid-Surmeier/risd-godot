extends SceneTree

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var visitor = load("res://modules/shell/prototype/gallery_walk4/visitor159/visitor.gd").new()
	visitor.world_height = 1.75
	root.add_child(visitor)
	await process_frame
	assert(visitor.target.get_bone_count() == 42, "selected Hair36 skeleton missing")
	assert(visitor.player.has_animation("Idle") and visitor.player.has_animation("Walking_A"), "fallback locomotion clips missing")
	assert(not visitor.play_gesture("wave") and not visitor.play_gesture("look"), "gestures must be disabled")
	visitor.pose(0.2, true, 0.0, Vector3.FORWARD, 0.0)
	assert(visitor._clip == "Walking_A", "walking did not select the accepted clip")
	visitor.pose(0.2, false, 0.0, Vector3.FORWARD, 0.0)
	assert(visitor._clip == "Idle", "stopping did not return to idle")
	assert(visitor.model.find_children("*", "MeshInstance3D", true, false).size() > 0, "selected body has no meshes")
	visitor.queue_free()
	await process_frame
	var gallery = load("res://modules/shell/prototype/gallery_walk4/walk4.gd").new()
	root.add_child(gallery)
	await create_timer(3.0).timeout
	assert(gallery._paintings.size() == 23, "gallery paintings missing")
	assert(gallery._kid.get_script().resource_path.ends_with("visitor159/visitor.gd"), "runtime visitor is not Hair36")
	var start: Vector3 = gallery._pos
	_key(gallery, KEY_D, true)
	await create_timer(0.7).timeout
	assert(gallery._kid._clip == "Walking_A" and gallery._pos.distance_to(start) > 0.2, "runtime walk did not move")
	var socks: PackedVector3Array = gallery._kid.skin_points(gallery._kid.skin_meshes[0])
	var lowest_sole := INF
	for index in gallery._kid.sole_indices:
		lowest_sole = minf(lowest_sole, socks[index].y)
	assert(lowest_sole >= -0.03, "shoe sole penetrated the gallery floor")
	var planted_before: Array = gallery._kid.sole_positions()
	var support_before: Array = gallery._kid.sole_support()
	await create_timer(0.1).timeout
	var planted_after: Array = gallery._kid.sole_positions()
	var support_after: Array = gallery._kid.sole_support()
	assert(support_after.has(true), "walk cycle never planted a foot")
	for side in 2:
		if support_before[side] and support_after[side]:
			assert(planted_before[side].distance_to(planted_after[side]) < 0.02, "planted foot drifted")
	_key(gallery, KEY_D, false)
	await create_timer(0.5).timeout
	assert(gallery._kid._clip == "Idle", "runtime stop did not return to idle")
	var forward_heading: float = gallery._kid.rotation.y
	var reverse_start: Vector3 = gallery._pos
	_key(gallery, KEY_A, true)
	await create_timer(0.8).timeout
	_key(gallery, KEY_A, false)
	var reverse_delta: Vector3 = gallery._pos - reverse_start
	assert(reverse_delta.length() > 0.2, "runtime reversal did not move")
	assert(absf(wrapf(gallery._kid.rotation.y - forward_heading, -PI, PI)) > 2.5, "runtime reversal did not turn around")
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
	assert(not gallery._kid.play_gesture("wave") and not gallery._kid.play_gesture("look"), "runtime gesture entered")
	gallery.queue_free()
	await process_frame
	print("PASS #174: Hair36 body, 42-bone rig, 23 paintings, start/walk/stop/reversal, 90/180-degree turns, planted feet/floor, gestures disabled")
	quit()


func _key(gallery: Control, code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = pressed
	gallery._unhandled_key_input(event)
