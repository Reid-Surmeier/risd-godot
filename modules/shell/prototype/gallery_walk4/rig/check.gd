## #139 real Skeleton3D motion/contact tests. No sprite-frame proxy.
extends SceneTree
var failures := 0


func require(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)


func mesh_sole_height(visitor) -> float:
	var skin: Skin = visitor.body.skin
	var minimum := INF
	for surface in visitor.body.mesh.get_surface_count():
		var arrays: Array = visitor.body.mesh.surface_get_arrays(surface)
		var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
		var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		for index in vertices.size():
			if vertices[index].y > 0.18:
				continue
			var point := Vector3.ZERO
			for influence in 4:
				var bind := bones[index * 4 + influence]
				var bone: int = skin.get_bind_bone(bind)
				if bone < 0:
					bone = visitor.skeleton.find_bone(skin.get_bind_name(bind))
				point += (
					(
						visitor.skeleton.get_bone_global_pose(bone)
						* skin.get_bind_pose(bind)
						* vertices[index]
					)
					* weights[index * 4 + influence]
				)
			minimum = minf(minimum, (visitor.skeleton.global_transform * point).y)
	return minimum


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var visitor = load("res://modules/shell/prototype/gallery_walk4/rig/visitor.gd").new()
	visitor.identity = OS.get_environment("GALLERY_CHARACTER") != "rogue"
	visitor.world_height = 1.75 * 1.17
	root.add_child(visitor)
	await process_frame
	var sprite = load("res://modules/shell/prototype/gallery_walk4/visitor.gd").new()
	require(
		sprite is Sprite3D and sprite.find_children("*", "Skeleton3D", true, false).is_empty(),
		"sprite negative control unexpectedly supplies skeleton"
	)
	sprite.free()
	require(visitor.skeleton.get_bone_count() >= 20, "real articulated skeleton missing")
	require(
		visitor.body.gi_mode == GeometryInstance3D.GI_MODE_DYNAMIC, "visitor cannot receive probes"
	)
	require(
		(
			visitor.player.has_animation("Idle")
			and visitor.player.has_animation("Walking_A")
			and visitor.player.has_animation("Interact")
		),
		"motion clips missing"
	)
	visitor.pose(0.0, false, 0.0, Vector3.FORWARD, 0.0)
	var total_contacts := 0
	var drift := 0.0
	var penetration := 0.0
	var previous_contact := [false, false]
	var hip_start: Transform3D = visitor.skeleton.get_bone_global_pose(2)
	var animated := false
	var turn_jump := 0.0
	for frame in 480:
		var heading := (
			Vector3.FORWARD
			if frame < 120
			else (Vector3(1, 0, -1).normalized() if frame < 240 else Vector3.BACK)
		)
		var moving := frame < 360
		visitor.position += heading * (1.2 / 60.0 if moving else 0.0)
		var before_yaw: float = visitor.rotation.y
		visitor.pose(1.0 / 60.0, moving, 0.0, heading, PI / 2)
		turn_jump = maxf(turn_jump, absf(wrapf(visitor.rotation.y - before_yaw, -PI, PI)))
		total_contacts += visitor.contacts
		var points: Array = visitor.sole_positions()
		for index in 2:
			if visitor._feet[index].locked and previous_contact[index]:
				var error: float = points[index].distance_to(visitor._feet[index].anchor)
				drift = maxf(drift, error)
			penetration = maxf(penetration, -points[index].y)
			previous_contact[index] = visitor._feet[index].locked
		if frame % 3 == 0:
			penetration = maxf(penetration, -mesh_sole_height(visitor))
		animated = (
			animated or not hip_start.is_equal_approx(visitor.skeleton.get_bone_global_pose(2))
		)
		if not moving:
			require(visitor.contacts == 0, "idle or blocked visitor emitted step")
	require(animated, "skeleton stayed static")
	require(turn_jump <= 5.5 / 60.0 + 0.0001, "body flipped instead of smoothly turning")
	require(total_contacts >= 10, "walk emitted no alternating contacts")
	require(drift <= 0.02, "planted sole moved more than 2cm: " + str(drift))
	require(penetration <= 0.01, "sole penetrated floor: " + str(penetration))
	print(
		"RIG_CONTACT contacts=",
		total_contacts,
		" max_stance_drift=",
		drift,
		" penetration=",
		penetration
	)
	visitor.play_gesture("look")
	var head: int = visitor.skeleton.find_bone("head")
	var before: Quaternion = visitor.skeleton.get_bone_pose_rotation(head)
	visitor.pose(0.65, false, 0.0, Vector3.BACK, 0.0)
	require(
		before.angle_to(visitor.skeleton.get_bone_pose_rotation(head)) > 0.2,
		"head look did not move bone"
	)
	var right_look: Quaternion = visitor.skeleton.get_bone_pose_rotation(head)
	visitor.gesture = ""
	visitor.look_direction = -1.0
	visitor.play_gesture("look")
	visitor.pose(0.65, false, 0.0, Vector3.BACK, 0.0)
	require(
		right_look.angle_to(visitor.skeleton.get_bone_pose_rotation(head)) > 0.4,
		"opposite orbit direction left head turn unchanged"
	)
	visitor.play_gesture("wave")
	var hand: int = visitor.skeleton.find_bone("hand.r")
	var hand_before: Transform3D = visitor.skeleton.get_bone_global_pose(hand)
	visitor.pose(0.6, false, 0.0, Vector3.BACK, 0.0)
	require(
		hand_before.origin.distance_to(visitor.skeleton.get_bone_global_pose(hand).origin) > 0.02,
		"interaction hand did not move"
	)
	visitor.pose(0.01, true, 0.0, Vector3.BACK, 0.0)
	require(visitor.gesture.is_empty(), "movement did not cancel gesture")

	# A stop can occur anywhere in the cycle. An airborne foot must settle before
	# it becomes a planted contact; otherwise idle blending stretches that leg.
	var stop_drift := 0.0
	for stop in 24:
		visitor.reset_contacts()
		visitor.position = Vector3.ZERO
		visitor.phase = 0.12
		visitor.pose(0.0, false, 0.0, Vector3.FORWARD, 0.0)
		for frame in 120 + stop:
			visitor.position.z -= 1.2 / 60.0
			visitor.pose(1.0 / 60.0, true, 0.0, Vector3.FORWARD, 0.0)
		for frame in 30:
			visitor.pose(1.0 / 60.0, false, 0.0, Vector3.FORWARD, 0.0)
			var points: Array = visitor.sole_positions()
			for index in 2:
				if visitor._feet[index].locked:
					stop_drift = maxf(
						stop_drift, points[index].distance_to(visitor._feet[index].anchor)
					)
	require(stop_drift <= 0.02, "stop phase left a sliding planted sole: " + str(stop_drift))
	print("RIG_STOP_PHASES count=24 max_drift=", stop_drift)

	visitor.reset_contacts()
	visitor.pose(0.0, false, 0.0, Vector3.FORWARD, 0.0)
	var pivot_drift := 0.0
	for frame in 90:
		visitor.pose(1.0 / 60.0, false, 0.0, Vector3.BACK, 0.0)
		var points: Array = visitor.sole_positions()
		for index in 2:
			if visitor._feet[index].locked:
				pivot_drift = maxf(
					pivot_drift, points[index].distance_to(visitor._feet[index].anchor)
				)
		penetration = maxf(penetration, -mesh_sole_height(visitor))
	require(
		pivot_drift <= 0.02 and penetration <= 0.01, "stationary turn lost physical foot contact"
	)
	print("RIG_PIVOT max_stance_drift=", pivot_drift, " boot_penetration=", penetration)

	print("RIG_FAILURES ", failures)
	quit(1 if failures else 0)
