## #139: real skinned CC0 visitor. The controller supplies collision-resolved position.
extends Node3D

const HEIGHT := 2.174243
const SOURCE_STRIDE := 0.66  # stance travel fit, then checked with world-space sole anchors
var world_height := 1.75
var identity := false
var gesture := ""
var gesture_time := 0.0
var look_direction := 1.0
var layers := 1:
	set(value):
		layers = value
		if body:
			body.layers = value
var skeleton: Skeleton3D
var body: MeshInstance3D
var player: AnimationPlayer
var phase := 0.12
var contacts := 0
var _model: Node3D
var _idle: Array = []
var _feet: Array = []
var _previous := Vector3.ZERO
var _has_position := false
var _walk_weight := 0.0
var _time := 0.0


func _ready() -> void:
	_model = (
		load(
			(
				"res://modules/shell/prototype/gallery_walk4/identity/visitor_identity.glb"
				if identity
				else "res://modules/shell/prototype/gallery_walk4/rig/visitor.glb"
			)
		)
		. instantiate()
	)
	add_child(_model)
	_model.scale = Vector3.ONE * world_height / (2.065 if identity else HEIGHT)
	# Anchor at the forward edge of the idle footprint; keep the mesh on y=0.
	_model.position.z = -0.18
	skeleton = _model.find_children("*", "Skeleton3D", true, false)[0]
	body = _model.find_children("*", "MeshInstance3D", true, false)[0]
	body.gi_mode = GeometryInstance3D.GI_MODE_DYNAMIC
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	body.layers = layers
	if identity:
		for surface in body.mesh.get_surface_count():
			var source: StandardMaterial3D = body.get_active_material(surface)
			var gain: float = (
				{
					"warm skin": 1.5,
					"cream shirt": 1.55,
					"oxblood shirt stripe": 1.35,
					"eye whites": 1.15
				}
				. get(source.resource_name, 1.0)
			)
			if gain > 1.0:
				var lit := source.duplicate()
				lit.albedo_color = source.albedo_color * Color(gain, gain, gain)
				body.set_surface_override_material(surface, lit)
	else:
		var material: StandardMaterial3D = body.get_active_material(0).duplicate()
		# Bounded art-direction gain for indirect-only capture; this adds no direct light.
		material.albedo_color = Color(1.6, 1.6, 1.6)
		material.roughness = 1.0
		material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
		material.disable_ambient_light = false
		body.material_override = material
	player = _model.find_children("*", "AnimationPlayer", true, false)[0]
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	_sample("Idle", 0.0)
	for bone in skeleton.get_bone_count():
		_idle.append(skeleton.get_bone_pose(bone))
	for side in ["l", "r"]:
		var foot := skeleton.find_bone("foot." + side)
		var pose := skeleton.get_bone_global_pose(foot)
		# Flat sole centre measured from the imported idle mesh, not the camera.
		var point := Vector3(pose.origin.x, -0.015 if identity else 0.0, pose.origin.z + 0.045)
		_feet.append(
			{
				"upper": skeleton.find_bone("upperleg." + side),
				"lower": skeleton.find_bone("lowerleg." + side),
				"foot": foot,
				"toe": skeleton.find_bone("toes." + side),
				"sole": pose.affine_inverse() * point,
				"flat": pose.basis,
				"locked": false,
				"anchor": Vector3.ZERO
			}
		)


func _sample(clip: String, seconds: float) -> void:
	skeleton.reset_bone_poses()
	player.play(clip)
	player.seek(seconds, true)
	player.advance(0.0)
	skeleton.force_update_all_bone_transforms()


func play_gesture(name: String) -> bool:
	if name not in ["look", "wave"] or gesture == name:
		return false
	gesture = name
	gesture_time = 0.0
	return true


func reset_contacts() -> void:
	_has_position = false
	_walk_weight = 0.0
	for foot in _feet:
		foot.locked = false


func footprint_position() -> Vector3:
	return _model.global_position


func sole_positions() -> Array:
	var points := []
	for foot in _feet:
		points.append(
			skeleton.global_transform * (skeleton.get_bone_global_pose(foot.foot) * foot.sole)
		)
	return points


func sole_support() -> Array:
	return [_feet[0].locked, _feet[1].locked]


func _solve_leg(foot: Dictionary, target: Vector3) -> void:
	var upper: Transform3D = skeleton.get_bone_global_pose(foot.upper)
	var lower: Transform3D = skeleton.get_bone_global_pose(foot.lower)
	var end: Transform3D = skeleton.get_bone_global_pose(foot.foot)
	var basis: Basis = foot.flat
	var ankle: Vector3 = target - basis * foot.sole
	var a := upper.origin.distance_to(lower.origin)
	var b := lower.origin.distance_to(end.origin)
	var direction: Vector3 = (ankle - upper.origin).normalized()
	var distance := clampf(ankle.distance_to(upper.origin), 0.001, a + b - 0.00001)
	var pole := lower.origin - upper.origin
	pole = (pole - direction * pole.dot(direction)).normalized()
	if pole.length_squared() < 0.1:
		pole = Vector3.FORWARD
	var along := (a * a - b * b + distance * distance) / (2.0 * distance)
	var knee: Vector3 = (
		upper.origin + direction * along + pole * sqrt(maxf(0, a * a - along * along))
	)
	upper.basis = (
		Basis(
			Quaternion(
				(lower.origin - upper.origin).normalized(), (knee - upper.origin).normalized()
			)
		)
		* upper.basis
	)
	skeleton.set_bone_global_pose(foot.upper, upper)
	skeleton.force_update_all_bone_transforms()
	lower = skeleton.get_bone_global_pose(foot.lower)
	end = skeleton.get_bone_global_pose(foot.foot)
	lower.basis = (
		Basis(
			Quaternion(
				(end.origin - lower.origin).normalized(), (ankle - lower.origin).normalized()
			)
		)
		* lower.basis
	)
	skeleton.set_bone_global_pose(foot.lower, lower)
	skeleton.force_update_all_bone_transforms()
	end = skeleton.get_bone_global_pose(foot.foot)
	end.basis = basis
	# Do not stretch the lower leg to reach an impossible planted target.
	skeleton.set_bone_global_pose(foot.foot, end)
	skeleton.force_update_all_bone_transforms()


func pose(
	delta: float, moving: bool, _legacy_phase: float, heading: Vector3, _camera_yaw: float
) -> void:
	if not player:
		return
	contacts = 0
	var distance := global_position.distance_to(_previous) if _has_position else 0.0
	if distance > 0.5:
		reset_contacts()
		distance = 0.0
	_previous = global_position
	_has_position = true
	_time += delta
	var turn_distance := 0.0
	if heading.length_squared() > 0.1:
		var wanted := atan2(heading.x, heading.z)
		var previous_yaw := rotation.y
		rotation.y = (
			wanted
			if delta == 0.0
			else rotate_toward(rotation.y, wanted, (5.5 if moving else 3.0) * delta)
		)
		if delta > 0.0:
			turn_distance = absf(wrapf(rotation.y - previous_yaw, -PI, PI)) * 0.3
	var stepping := moving or turn_distance > 0.0001
	if stepping:
		gesture = ""
		phase = fposmod(
			(
				phase
				+ (
					(distance if moving else turn_distance)
					/ (SOURCE_STRIDE * world_height / (2.065 if identity else HEIGHT))
				)
			),
			1.0
		)
	_walk_weight = move_toward(
		_walk_weight, (1.0 if moving else 0.7) if stepping else 0.0, delta * 8.0
	)
	_sample("Idle", fposmod(_time, player.get_animation("Idle").length))
	var idle_pose := []
	for bone in skeleton.get_bone_count():
		idle_pose.append(skeleton.get_bone_pose(bone))
	_sample("Walking_A", phase * player.get_animation("Walking_A").length)
	for bone in skeleton.get_bone_count():
		skeleton.set_bone_pose(
			bone,
			(idle_pose[bone] as Transform3D).interpolate_with(
				skeleton.get_bone_pose(bone), _walk_weight
			)
		)
	if gesture != "":
		gesture_time += delta
		if gesture == "wave":
			var lower_pose := []
			for bone in skeleton.get_bone_count():
				lower_pose.append(skeleton.get_bone_pose(bone))
			_sample("Interact", minf(gesture_time, 1.299))
			for bone in skeleton.get_bone_count():
				if bone < 2 or bone >= 15:
					skeleton.set_bone_pose(bone, lower_pose[bone])
		var head := skeleton.find_bone("head")
		var q := skeleton.get_bone_pose_rotation(head)
		skeleton.set_bone_pose_rotation(
			head,
			(
				q
				* Quaternion(
					Vector3.UP, sin(minf(gesture_time / 1.3, 1.0) * PI) * 0.48 * look_direction
				)
			)
		)
		if gesture_time >= 1.3:
			gesture = ""
	# Slight knee reserve prevents idle/walk crossfade from fully extending a
	# planted leg. The sole solver keeps floor height independent of this crouch.
	var root_pose: Vector3 = _idle[0].origin
	root_pose.y -= 0.075
	skeleton.set_bone_pose_position(0, root_pose)
	skeleton.force_update_all_bone_transforms()
	for index in _feet.size():
		var foot: Dictionary = _feet[index]
		skeleton.set_bone_pose(foot.toe, _idle[foot.toe])
		skeleton.force_update_all_bone_transforms()
		var contact := (
			(phase >= 0.11 and phase < 0.46) if index == 0 else (phase >= 0.61 and phase < 0.96)
		)
		contact = contact if stepping else (bool(foot.locked) or _walk_weight < 0.05)
		var point: Vector3 = (
			skeleton.global_transform * (skeleton.get_bone_global_pose(foot.foot) * foot.sole)
		)
		if contact and not foot.locked:
			foot.anchor = Vector3(point.x, global_position.y, point.z)
			if stepping and maxf(distance, turn_distance) > 0.00001:
				contacts += 1
		foot.locked = contact
		var target: Vector3 = (
			foot.anchor
			if contact
			else Vector3(point.x, maxf(point.y, global_position.y + 0.015), point.z)
		)
		_solve_leg(foot, skeleton.global_transform.affine_inverse() * target)
