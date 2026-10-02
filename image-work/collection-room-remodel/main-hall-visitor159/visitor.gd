extends Node3D
## #159 source-preserving Hair36 geometry; #174 private runtime, non-authentic KayKit motion.
## Transfer/contact corrections adapt #171, with #159-specific stationary repair.
## These are not Nintendo clips or a claim of #171's current visual acceptance.
const HOME := "res://modules/shell/prototype/gallery_walk4/visitor159/"
const MAP := {
	"Armature_Spine_1": "hips",
	"Armature_Waist": "hips",
	"Armature_Spine_2": "spine",
	"Armature_Spine_3": "chest",
	"Armature_Head_2": "head",
	"Armature_Arm_1_L": "upperarm.l",
	"Armature_Arm_2_L": "lowerarm.l",
	"Armature_Wrist_L": "hand.l",
	"Armature_Arm_1_R": "upperarm.r",
	"Armature_Arm_2_R": "lowerarm.r",
	"Armature_Wrist_R": "hand.r",
	"Armature_Leg_1_L_2": "upperleg.l",
	"Armature_Leg_2_L": "lowerleg.l",
	"Armature_Ankle_L": "foot.l",
	"Armature_Toe_L": "toes.l",
	"Armature_Leg_1_R_2": "upperleg.r",
	"Armature_Leg_2_R": "lowerleg.r",
	"Armature_Ankle_R": "foot.r",
	"Armature_Toe_R": "toes.r",
}

var target: Skeleton3D
var donor: Skeleton3D
var player: AnimationPlayer
var model: Node3D
var pairs := {}
var body_scale := 1.0
var hip_ratio := 1.0
var mapped_before := []
var skin_meshes := []
var sole_indices := []
var sole_sides := {}
var floor_offset := 0.0
var feet := []
var meshes := []
var world_height := 1.75
var contacts := 0
var phase := 0.0
var lighting := true
var fill := 0.25
var layers := 1:
	set(value):
		layers = value
		for mesh in meshes:
			mesh.layers = value
var _previous := Vector3.ZERO
var _has_previous := false
var _clock := 0.0
var _gait := 0.0
var _clip := ""
var _blend_start := 0.0
var _from := []
var _stationary_weight := 0.0


# Adapted from the already accepted KayKit gallery visitor's two-bone solver.
func solve_leg(foot: Dictionary, point: Vector3) -> void:
	var upper := target.get_bone_global_pose(foot.upper)
	var lower := target.get_bone_global_pose(foot.lower)
	var end := target.get_bone_global_pose(foot.ankle)
	var ankle: Vector3 = point - foot.flat * foot.sole
	var a := upper.origin.distance_to(lower.origin)
	var b := lower.origin.distance_to(end.origin)
	var direction := (ankle - upper.origin).normalized()
	var distance := clampf(ankle.distance_to(upper.origin), 0.001, a + b - 0.00001)
	var pole := lower.origin - upper.origin
	# A donor knee pole can turn sideways on this much shorter leg. A settled
	# neutral stance bends forward in the sourced rig's own coordinate frame.
	if _stationary_weight > 0:
		pole = pole.lerp(Vector3.BACK, _stationary_weight)
	pole = (pole - direction * pole.dot(direction)).normalized()
	if pole.length_squared() < 0.1:
		pole = Vector3.FORWARD
	var along := (a * a - b * b + distance * distance) / (2.0 * distance)
	var knee := upper.origin + direction * along + pole * sqrt(maxf(0, a * a - along * along))
	upper.basis = (
		Basis(
			Quaternion(
				(lower.origin - upper.origin).normalized(), (knee - upper.origin).normalized()
			)
		)
		* upper.basis
	)
	target.set_bone_global_pose(foot.upper, upper)
	target.force_update_all_bone_transforms()
	lower = target.get_bone_global_pose(foot.lower)
	end = target.get_bone_global_pose(foot.ankle)
	lower.basis = (
		Basis(
			Quaternion(
				(end.origin - lower.origin).normalized(), (ankle - lower.origin).normalized()
			)
		)
		* lower.basis
	)
	target.set_bone_global_pose(foot.lower, lower)
	target.force_update_all_bone_transforms()
	end = target.get_bone_global_pose(foot.ankle)
	end.basis = foot.flat
	target.set_bone_global_pose(foot.ankle, end)
	target.force_update_all_bone_transforms()


func solve_contacts(phase: float, moving: bool, settling: bool = false) -> void:
	var goals := []
	for i in feet.size():
		var foot: Dictionary = feet[i]
		if settling:
			foot.locked = false
		target.set_bone_pose(foot.toe, target.get_bone_rest(foot.toe))
		target.force_update_all_bone_transforms()
		var planted := (
			(phase >= 0.11 and phase < 0.46) if i == 0 else (phase >= 0.61 and phase < 0.96)
		)
		planted = planted if moving else true
		var point: Vector3 = (
			target.global_transform * (target.get_bone_global_pose(foot.ankle) * foot.sole)
		)
		if not moving:
			# The donor's idle/interact stance is not a target-body stance. Settle
			# toward the sourced rig's neutral sole locations, not its retargeted
			# ankle sample, so a turn/interaction cannot leave crossed resting feet.
			point = target.global_transform * foot.neutral
			if settling:
				point = foot.settle_from.lerp(
					point, smoothstep(0, 1, clampf((_clock - _blend_start) / 0.2, 0, 1))
				)
		if planted and not foot.locked:
			if moving:
				contacts += 1
			foot.anchor = Vector3(point.x, 0, point.z)
			foot.anchor_basis = target.global_basis * foot.rest_flat
		foot.locked = planted
		foot.flat = target.global_basis.inverse() * foot.anchor_basis if planted else foot.rest_flat
		var goal: Vector3 = (
			foot.anchor if planted else Vector3(point.x, maxf(point.y, 0.015), point.z)
		)
		goals.append(target.global_transform.affine_inverse() * goal)
	# Acceleration / reversal can leave a planted ankle beyond the new idle hip's
	# reach. Lower the pose root only as far as necessary before the two leg solves.
	# This is a runtime pose adjustment, never a source geometry / bind change.
	var drop := 0.0
	for i in feet.size():
		var foot: Dictionary = feet[i]
		var upper := target.get_bone_global_pose(foot.upper).origin
		var lower := target.get_bone_global_pose(foot.lower).origin
		var end := target.get_bone_global_pose(foot.ankle).origin
		var ankle: Vector3 = goals[i] - foot.flat * foot.sole
		var reach := upper.distance_to(lower) + lower.distance_to(end) - 0.0001
		var horizontal := Vector2(upper.x - ankle.x, upper.z - ankle.z).length_squared()
		var ceiling := ankle.y + sqrt(maxf(0, reach * reach - horizontal))
		drop = maxf(drop, upper.y - ceiling)
	if drop > 0:
		var root_pose := target.get_bone_pose(0)
		root_pose.origin.y -= drop
		target.set_bone_pose(0, root_pose)
		target.force_update_all_bone_transforms()
	for i in feet.size():
		solve_leg(feet[i], goals[i])
		if settling:
			feet[i].locked = false


func skin_points(mesh: MeshInstance3D) -> PackedVector3Array:
	var arrays := mesh.mesh.surface_get_arrays(0)
	var transforms := []
	for bind in mesh.skin.get_bind_count():
		var bone := target.find_bone(mesh.skin.get_bind_name(bind))
		assert(bone >= 0)
		transforms.append(
			(
				target.global_transform
				* target.get_bone_global_pose(bone)
				* mesh.skin.get_bind_pose(bind)
			)
		)
	var points := PackedVector3Array()
	for vertex in arrays[Mesh.ARRAY_VERTEX].size():
		var point := Vector3.ZERO
		for k in 4:
			point += (
				(
					transforms[arrays[Mesh.ARRAY_BONES][vertex * 4 + k]]
					* arrays[Mesh.ARRAY_VERTEX][vertex]
				)
				* arrays[Mesh.ARRAY_WEIGHTS][vertex * 4 + k]
			)
		points.append(point)
	return points


func sample(clip: String, time: float) -> Array:
	player.play(clip)
	var duration := player.get_animation(clip).length
	player.seek(minf(time, duration - 0.001) if clip == "Interact" else fmod(time, duration), true)
	player.advance(0)
	donor.force_update_all_bone_transforms()
	var globals := []
	for i in donor.get_bone_count():
		globals.append(donor.get_bone_global_pose(i))
	return globals


func transfer(poses: Array) -> void:
	var current := []
	for i in target.get_bone_count():
		var local := target.get_bone_rest(i)
		var parent := target.get_bone_parent(i)
		var parent_pose: Transform3D = current[parent] if parent >= 0 else Transform3D.IDENTITY
		if pairs.has(i):
			var source: int = pairs[i]
			var delta: Basis = (
				poses[source].basis * donor.get_bone_global_rest(source).basis.inverse()
			)
			var wanted := delta * target.get_bone_global_rest(i).basis
			local.basis = parent_pose.basis.inverse() * wanted
		if parent < 0:
			var hips := donor.find_bone("hips")
			local.origin += (
				(poses[hips].origin - donor.get_bone_global_rest(hips).origin)
				* hip_ratio
				* (1.0 - _stationary_weight)
			)
			local.origin.y -= lerpf(0.30, 0.03, _stationary_weight)
		target.set_bone_pose(i, local)
		current.append(parent_pose * local)
	target.force_update_all_bone_transforms()


func _ready() -> void:
	model = load(HOME + "inputs/character.glb").instantiate()
	add_child(model)
	target = model.find_children("*", "Skeleton3D", true, false)[0]
	var min_y := INF
	var max_y := -INF
	for mesh in model.find_children("*", "MeshInstance3D", true, false):
		for point in skin_points(mesh):
			min_y = minf(min_y, point.y)
			max_y = maxf(max_y, point.y)
		if str(mesh.name).contains("Socks"):
			skin_meshes.append(mesh)
	var rest_feet := skin_points(skin_meshes[0])
	for i in rest_feet.size():
		if rest_feet[i].y < min_y + 0.12:
			sole_indices.append(i)
			sole_sides[i] = 0 if rest_feet[i].x > 0 else 1
	body_scale = world_height / (max_y - min_y)
	floor_offset = -min_y * body_scale
	hip_ratio = (4.84 - min_y) / 0.405663
	model.scale = Vector3.ONE * body_scale
	model.position.y = floor_offset
	for side in ["L", "R"]:
		var ankle := target.find_bone("Armature_Ankle_" + side)
		var ankle_rest := target.get_bone_global_rest(ankle)
		var sole := Vector3.ZERO
		var count := 0
		for i in sole_indices:
			if (rest_feet[i].x > 0) == (side == "L"):
				sole += rest_feet[i]
				count += 1
		sole /= count
		sole.y = min_y
		sole.y -= 4.84
		feet.append(
			{
				"upper": target.find_bone("Armature_Leg_1_" + side + "_2"),
				"lower": target.find_bone("Armature_Leg_2_" + side),
				"ankle": ankle,
				"toe": target.find_bone("Armature_Toe_" + side),
				"flat": ankle_rest.basis,
				"rest_flat": ankle_rest.basis,
				"anchor_basis": Basis.IDENTITY,
				"sole": ankle_rest.affine_inverse() * sole,
				"neutral": sole,
				"settle_from": Vector3.ZERO,
				"locked": false,
				"anchor": Vector3.ZERO
			}
		)
	print("REST bounds=", min_y, "..", max_y, " soles=", sole_indices.size())
	var source: Node3D = load(HOME + "inputs/donor.glb").instantiate()
	add_child(source)
	source.visible = false
	donor = source.find_children("*", "Skeleton3D", true, false)[0]
	player = source.find_children("*", "AnimationPlayer", true, false)[0]
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	for name in MAP:
		var a := target.find_bone(name)
		var b := donor.find_bone(MAP[name])
		assert(a >= 0 and b >= 0, "missing mapped bone " + name)
		pairs[a] = b
	for clip in ["Idle", "Walking_A", "Interact"]:
		assert(player.has_animation(clip))
		print("CLIP ", clip, " length=", player.get_animation(clip).length)

	for mesh in model.find_children("*", "MeshInstance3D", true, false):
		meshes.append(mesh)
		mesh.gi_mode = GeometryInstance3D.GI_MODE_DYNAMIC
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh.layers = layers
		for surface in mesh.mesh.get_surface_count():
			var original: StandardMaterial3D = mesh.get_active_material(surface)
			if lighting and original.emission_enabled:
				var lit: StandardMaterial3D = original.duplicate()
				# Imported emission is already sRGB. The source's emissive-only export
				# has metallic=1; diffuse gallery probes need a nonmetallic copy.
				lit.albedo_color = original.emission * Color(1.6, 1.6, 1.6)
				lit.albedo_texture = original.emission_texture
				lit.emission_enabled = fill > 0
				lit.emission_energy_multiplier = 0.6 if str(mesh.name).contains("Hair") else fill
				lit.roughness = 1.0
				lit.metallic = 0.0
				lit.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
				mesh.set_surface_override_material(surface, lit)
	pose(0, false, 0, Vector3.FORWARD, 0)


func reset_contacts() -> void:
	_has_previous = false
	for foot in feet:
		foot.locked = false


func footprint_position() -> Vector3:
	return model.global_position


func sole_positions() -> Array:
	var points := []
	for foot in feet:
		points.append(
			target.global_transform * (target.get_bone_global_pose(foot.ankle) * foot.sole)
		)
	return points


func sole_support() -> Array:
	return feet.map(func(foot): return foot.locked)


func play_gesture(_name: String) -> bool:
	return false


func pose(
	delta: float, moving: bool, _legacy_phase: float, heading: Vector3, _camera_yaw: float
) -> void:
	if not player:
		return
	contacts = 0
	_clock += delta
	var distance := global_position.distance_to(_previous) if _has_previous else 0.0
	if distance > 0.5:
		reset_contacts()
		distance = 0.0
	_previous = global_position
	_has_previous = true
	var old_yaw := rotation.y
	if heading.length_squared() > 0.1:
		var wanted := atan2(heading.x, heading.z)
		rotation.y = (
			wanted
			if delta == 0
			else rotate_toward(rotation.y, wanted, (5.5 if moving else 3.0) * delta)
		)
		# The inherited approach controller considers <0.015 rad aligned and
		# starts Interact. Finish that residual rotation before it starts, so the
		# next pose does not classify the final fraction of a degree as walking.
		if absf(wrapf(rotation.y - wanted, -PI, PI)) < 0.015:
			rotation.y = wanted
	var turn_distance := absf(wrapf(rotation.y - old_yaw, -PI, PI)) * 0.3 if delta > 0 else 0.0
	var stepping := moving or turn_distance > 0.0001
	var clip := "Walking_A" if stepping else "Idle"
	if clip != _clip:
		var current_soles := sole_positions()
		for i in feet.size():
			feet[i].settle_from = current_soles[i]
		_from = mapped_before.duplicate()
		_clip = clip
		_blend_start = _clock
		_gait = 0
	_gait += (distance if moving else turn_distance) / (0.4 * world_height / 1.75)
	var poses := sample(clip, _gait if stepping else _clock)
	if not _from.is_empty():
		var blend := clampf((_clock - _blend_start) / 0.2, 0, 1)
		for i in poses.size():
			poses[i] = _from[i].interpolate_with(poses[i], blend)
	mapped_before = poses
	_stationary_weight = (
		move_toward(_stationary_weight, 0.0 if stepping else 1.0, delta / 0.2)
		if delta > 0
		else (0.0 if stepping else 1.0)
	)
	transfer(poses)
	phase = fmod(_gait / player.get_animation("Walking_A").length, 1.0)
	# As in #171: feet finish their short walk-to-idle settling before planting.
	solve_contacts(phase, stepping, not stepping and _clock - _blend_start < 0.2)
