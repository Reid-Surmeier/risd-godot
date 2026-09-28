extends Node
## Repeatable real-controller sequence. No donor-only playback or pose teleporting.
var gallery: Control
var elapsed := 0.0
var started := false
var done := false
var previous_stage := ""
var label: Label
var records := []
var frames := 0
var last_sample := -1.0
var previous_feet := [{}, {}]
var max_penetration := 0.0
var max_drift := 0.0
var stage_counts := {}
var detail_seen := false
var start_usec := 0

func _ready() -> void:
	process_priority = -10
	label = Label.new()
	label.position = Vector2(12, 10)
	label.add_theme_font_size_override("font_size", 19)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	gallery.add_child(label)
	await get_tree().create_timer(4).timeout
	gallery._new_action()
	gallery._target = null
	gallery._path.clear()
	gallery._entrance_active = false
	gallery._entrance_waiting = false
	gallery._pos = Vector3(-2.6, 0, -8)
	gallery._kid.position = gallery._pos
	gallery._kid.reset_contacts()
	gallery.view_yaw = PI / 2
	gallery._motion_heading = Vector3.RIGHT
	gallery._kid.pose(0, false, 0, Vector3.RIGHT, gallery.view_yaw)
	gallery._update_camera(1)
	gallery.resized.emit()
	if not OS.has_feature("web"):
		gallery.set_process(false)
		DirAccess.make_dir_recursive_absolute("/tmp/risd-159-evidence/native")
	start_usec = Time.get_ticks_usec()
	started = true
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.visitor159Start=performance.now();window.visitor159Ready=true")

func key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = pressed
	gallery._unhandled_key_input(event)

func _process(delta: float) -> void:
	if not started or done:
		return
	var dt := delta if OS.has_feature("web") else 1.0 / 30
	elapsed += dt
	var stage := "complete"
	for section in [[2, "front idle"], [4, "profile turn"], [6, "back turn"], [8, "straight walk"], [10, "diagonal walk"], [12, "stop"], [14, "reverse"], [15, "reverse stop"], [19, "look"], [32, "artwork approach / gesture"]]:
		if elapsed < section[0]:
			stage = section[1]
			break
	if stage != previous_stage:
		for code in [KEY_W, KEY_A, KEY_S, KEY_D]:
			key(code, false)
		match stage:
			"profile turn": gallery._motion_heading = Vector3.BACK
			"back turn": gallery._motion_heading = Vector3.LEFT
			"straight walk": key(KEY_D, true)
			"diagonal walk":
				key(KEY_W, true)
				key(KEY_D, true)
			"reverse": key(KEY_S, true)
			"look": gallery._orbit(0.35)
			"artwork approach / gesture":
				var nearest: Dictionary = gallery._paintings[0]
				for painting in gallery._paintings:
					if gallery._pos.distance_to(painting.center) < gallery._pos.distance_to(nearest.center):
						nearest = painting
				print("VISITOR159_TARGET ", nearest.tag)
				var point: Vector2 = gallery._cam.unproject_position(nearest.center) / Vector2(gallery._vp.size) * gallery.size
				for pressed in [true, false]:
					var event := InputEventMouseButton.new()
					event.button_index = MOUSE_BUTTON_LEFT
					event.position = point
					event.global_position = point
					event.pressed = pressed
					gallery._gui_input(event)
		previous_stage = stage
	if not OS.has_feature("web"):
		gallery._process(dt)
	# Blind visual capture: no action names to explain an otherwise unreadable pose.
	label.text = "DEMO %.2fs" % elapsed
	if not gallery._open.is_empty():
		detail_seen = true
	if stage == "complete":
		done = true
		var summary := {"demo_seconds": elapsed, "wall_seconds": (Time.get_ticks_usec() - start_usec) / 1000000.0, "paintings": gallery._paintings.size(), "bones": gallery._kid.target.get_bone_count(), "max_penetration": max_penetration, "max_planted_vertex_drift": max_drift, "detail_seen": detail_seen, "stages": stage_counts, "records": records}
		if OS.has_feature("web"):
			JavaScriptBridge.eval("window.visitor159Complete=performance.now();window.visitor159Report=" + JSON.stringify(summary))
		else:
			FileAccess.open("/tmp/risd-159-evidence/native-metrics.json", FileAccess.WRITE).store_string(JSON.stringify(summary))
			get_tree().quit()
		print("VISITOR159_COMPLETE paintings=", gallery._paintings.size(), " detail=", detail_seen, " penetration=", max_penetration, " drift=", max_drift)
		return
	if elapsed - last_sample > 0.09:
		last_sample = elapsed
		sample(stage)
		if not OS.has_feature("web") and OS.get_environment("VISITOR_FAST") != "1":
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("/tmp/risd-159-evidence/native/%04d.png" % frames)
			frames += 1
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.visitor159Demo=" + str(elapsed))

func sample(stage: String) -> void:
	var kid = gallery._kid
	var points: PackedVector3Array = kid.skin_points(kid.skin_meshes[0])
	var minimum := INF
	var drift := 0.0
	for index in kid.sole_indices:
		minimum = minf(minimum, points[index].y)
	max_penetration = maxf(max_penetration, -minimum)
	for side in 2:
		var foot: Dictionary = kid.feet[side]
		var current := {}
		for index in kid.sole_indices:
			# Membership is frozen in rest coordinates, not inferred from rotated world x.
			if kid.sole_sides[index] != side:
				continue
			current[index] = points[index]
		if foot.locked and previous_feet[side].get("locked", false) and previous_feet[side].get("anchor", Vector3.INF).distance_to(foot.anchor) < 0.00001:
			for index in current:
				drift = maxf(drift, current[index].distance_to(previous_feet[side].points[index]))
		else:
			previous_feet[side] = {"locked": foot.locked, "anchor": foot.anchor, "points": current}
	stage_counts[stage] = stage_counts.get(stage, 0) + 1
	max_drift = maxf(max_drift, drift)
	var soles: Array = kid.sole_positions()
	var left: Vector3 = kid.global_transform.affine_inverse() * soles[0]
	var right: Vector3 = kid.global_transform.affine_inverse() * soles[1]
	var stationary: bool = kid._clip != "Walking_A" and kid._clock - kid._blend_start >= 0.21
	var pointing_dot := -1.0
	var target_in_frame = null
	var camera_clearance := -1.0
	if kid.gesture != "" and kid.gesture_time > 0.8 and kid.gesture_time < (1.4 if kid.gesture == "look" else 1.8):
		camera_clearance = (gallery._cam.position - kid.attention_target).dot(gallery.attention_normal)
		target_in_frame = true
		for painting in gallery._paintings:
			if painting.center.distance_to(kid.attention_target) > 0.001:
				continue
			for corner in painting.corners:
				var pixel: Vector2 = gallery._cam.unproject_position(corner)
				target_in_frame = target_in_frame and Rect2(Vector2.ZERO, Vector2(gallery._vp.size)).has_point(pixel) and not gallery._cam.is_position_behind(corner)
	if kid.gesture == "wave" and kid.gesture_time > 0.4 and kid.gesture_time < 1.8:
		var lower: Vector3 = kid.target.get_bone_global_pose(kid.target.find_bone("Armature_Arm_2_L")).origin
		var wrist: Vector3 = kid.target.get_bone_global_pose(kid.target.find_bone("Armature_Wrist_L")).origin
		var aim: Vector3 = kid.target.global_transform.affine_inverse() * kid.attention_target
		pointing_dot = (wrist - lower).normalized().dot((aim - lower).normalized())
	records.append({"time": elapsed, "stage": stage, "position": [gallery._pos.x, gallery._pos.z], "yaw": kid.rotation.y, "gesture": kid.gesture, "min_sole_y": minimum, "drift": drift, "stationary": stationary, "left_x": left.x, "right_x": right.x, "pointing_dot": pointing_dot, "target_in_frame": target_in_frame, "camera_clearance": camera_clearance})
