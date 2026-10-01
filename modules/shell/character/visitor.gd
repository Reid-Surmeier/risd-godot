extends Node3D
## #236 Collection visitor: the accepted #235 character behind the surface walk4.gd drives.
## The museum owns position, collision and camera; this node only faces, animates and sounds.
## Sprint, jump, tools and doors stay in the playtest: the museum has no input for them.
const HOME := "res://modules/shell/character/"
const Demo := preload("res://modules/shell/character/demo.gd")
# Skinned rest height of walk.glb in metres, horns included; visitor174_check.gd re-measures it.
const REST_HEIGHT := 1.877
# ponytail: thresholds fit this walk clip, whose planted foot rolls up to 2.6 cm mid-stance.
# Re-measure if the clip changes; visitor174_check.gd fails on a wrong step cadence.
const LIFT := 0.035
const PLANT := 0.01
# A render layer no museum camera or surface uses: only the visitor's own light reaches it.
const FILL_LAYER := 1 << 19

var world_height := 1.75
var contacts := 0
var target: Skeleton3D
var player: AnimationPlayer
var model: Node3D
var meshes := []
var layers := 1:
	set(value):
		layers = value
		for mesh in meshes:
			mesh.layers = value | FILL_LAYER
# Never enters the tree, so the playtest arena, camera and UI built in its _ready do not exist.
# Borrowed for the reviewed face/hand material, blink curve, locomotion coupling and step cues.
var _kit := Demo.new()
var _fill := DirectionalLight3D.new()
var _feet := []
var _speaker := AudioStreamPlayer.new()
var _previous := Vector3.ZERO
var _has_previous := false
var _clip := ""


func _ready() -> void:
	model = load(HOME + "walk.glb").instantiate()
	model.scale = Vector3.ONE * world_height / REST_HEIGHT
	add_child(model)
	player = model.find_children("*", "AnimationPlayer", true, false)[0]
	target = model.find_children("*", "Skeleton3D", true, false)[0]
	# The imported library is shared by every instance; edit a private copy.
	var library: AnimationLibrary = player.get_animation_library("").duplicate(true)
	player.remove_animation_library("")
	player.add_animation_library("", library)
	# Owner prefers the quieter idle accepted in #231: half the source loop's travel.
	var idle := library.get_animation("idle")
	for track in idle.get_track_count():
		var kind := idle.track_get_type(track)
		if kind not in [Animation.TYPE_POSITION_3D, Animation.TYPE_ROTATION_3D]:
			continue
		var reference: Variant = idle.track_get_key_value(track, 0)
		for key in idle.track_get_key_count(track):
			var value: Variant = idle.track_get_key_value(track, key)
			idle.track_set_key_value(
				track,
				key,
				(
					reference.slerp(value, 0.5)
					if kind == Animation.TYPE_ROTATION_3D
					else reference.lerp(value, 0.5)
				)
			)
	for clip in ["idle", "walk"]:
		library.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	_kit.model = model
	_kit.skeleton = target
	_kit.make_face()
	for mesh in model.find_children("*", "MeshInstance3D", true, false):
		meshes.append(mesh)
		mesh.gi_mode = GeometryInstance3D.GI_MODE_DYNAMIC
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mesh.layers = layers | FILL_LAYER
	for side in ["LeftFoot", "RightFoot"]:
		_feet.append({"bone": target.find_bone(side), "points": [], "low": 0.0, "planted": true})
	# Rigid sole vertices, as in the accepted playtest: the floor and contact reference.
	for mesh in meshes:
		for surface in mesh.mesh.get_surface_count():
			var arrays: Array = mesh.mesh.surface_get_arrays(surface)
			for vertex in arrays[Mesh.ARRAY_VERTEX].size():
				for influence in 4:
					if arrays[Mesh.ARRAY_WEIGHTS][vertex * 4 + influence] < 0.9999:
						continue
					var bind: int = arrays[Mesh.ARRAY_BONES][vertex * 4 + influence]
					var bone: int = mesh.skin.get_bind_bone(bind)
					if bone < 0:
						bone = target.find_bone(mesh.skin.get_bind_name(bind))
					for foot in _feet:
						if foot.bone == bone:
							foot.points.append(
								mesh.skin.get_bind_pose(bind) * arrays[Mesh.ARRAY_VERTEX][vertex]
							)
	# The museum is lit only by its baked lightmap, and probes alone leave the character far
	# darker than the accepted playtest. This is that playtest's sun, reaching only this body
	# and kept on the viewer's side as the museum camera orbits (see pose).
	_fill.top_level = true
	_fill.light_energy = 0.65
	_fill.light_cull_mask = FILL_LAYER
	add_child(_fill)
	add_child(_speaker)
	pose(0, false, 0, Vector3.FORWARD, 0)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and is_instance_valid(_kit):
		_kit.free()


func reset_contacts() -> void:
	_has_previous = false


## The same first frame every time: render_diagnostics.gd replays depend on it.
func reset() -> void:
	_has_previous = false
	_clip = ""
	rotation.y = 0.0
	player.stop()
	_kit.movement.reset()
	_kit.random.seed = 231
	_kit.blink_clock = 1.4
	_kit.blink_index = -1
	for foot in _feet:
		foot.planted = true
	pose(0, false, 0, Vector3.ZERO, 0)


func sole_positions() -> Array:
	return _feet.map(
		func(foot):
			var origin: Vector3 = (
				target.global_transform * target.get_bone_global_pose(foot.bone).origin
			)
			return Vector3(origin.x, global_position.y + foot.low, origin.z)
	)


func sole_support() -> Array:
	return _feet.map(func(foot): return foot.planted)


func play_gesture(_name: String) -> bool:
	return false


func pose(
	delta: float, moving: bool, _legacy_phase: float, heading: Vector3, camera_yaw: float
) -> void:
	if not player:
		return
	_fill.rotation = Vector3(deg_to_rad(-55), camera_yaw - deg_to_rad(20), 0)
	contacts = 0
	var distance := global_position.distance_to(_previous) if _has_previous else 0.0
	if distance > 0.5:
		distance = 0.0
	_previous = global_position
	_has_previous = true
	# Same turning rule as the visitor this replaces; _approach() waits on its 0.015 rad snap.
	var old_yaw := rotation.y
	if heading.length_squared() > 0.1:
		var wanted := atan2(heading.x, heading.z)
		rotation.y = (
			wanted
			if delta == 0
			else rotate_toward(rotation.y, wanted, (5.5 if moving else 3.0) * delta)
		)
		if absf(wrapf(rotation.y - wanted, -PI, PI)) < 0.015:
			rotation.y = wanted
	# A turn on the spot steps around a 0.3 m circle instead of pivoting like a statue.
	var travel := distance if moving else absf(wrapf(rotation.y - old_yaw, -PI, PI)) * 0.3
	var speed := travel / delta if delta > 0 else 0.0
	# The accepted coupling of gait, cadence and speed, fed the museum's own travel.
	var movement = _kit.movement
	var units: float = speed / (movement.travel_gain * model.scale.y) / 4.875
	movement.heading = 0.0
	movement.step(Vector2(0, minf(units, 1.0)), false, delta)
	var clip := "idle" if movement.gait == "Idle" else "walk"
	if clip != _clip:
		_clip = clip
		player.play(clip, 0.167 if delta > 0 else 0.0)
	player.speed_scale = (
		1.0
		if clip == "idle"
		else player.get_animation(clip).length * movement.phase_step * 60.0 / 16.0
	)
	player.advance(delta)
	# Keep the lowest sole on the museum floor, then read which foot carries the weight.
	model.position.y = 0.0
	target.force_update_all_bone_transforms()
	var floor_y := INF
	for foot in _feet:
		var bone: Transform3D = target.global_transform * target.get_bone_global_pose(foot.bone)
		var low := INF
		for point in foot.points:
			low = minf(low, (bone * point).y)
		foot.low = low - global_position.y
		floor_y = minf(floor_y, foot.low)
	model.position.y = -floor_y
	for index in 2:
		var foot: Dictionary = _feet[index]
		foot.low -= floor_y
		if clip == "idle":
			foot.planted = true
		elif foot.planted and foot.low > LIFT * model.scale.y:
			foot.planted = false
		elif not foot.planted and foot.low < PLANT * model.scale.y:
			foot.planted = true
			if speed > 0.08:
				contacts += 1
				_step(["Left", "Right"][index], movement.gait)
	_blink(delta)


func _step(side: String, gait: String) -> void:
	# Same cue selection and levels as the accepted playtest's captured-house profile (#235).
	# ponytail: one voice. Walk steps last 185 ms and land about 430 ms apart; running or
	# dashing here would need the playtest's polyphonic player so tails are not cut.
	var cue: Dictionary = _kit.sounds.step("Indoor", gait, side, true)
	_speaker.stream = cue.stream
	_speaker.volume_db = -14 + linear_to_db(cue.gain) + cue.get("gain_offset_db", 0)
	_speaker.pitch_scale = cue.pitch
	_speaker.play(cue.get("start_offset", 0))


func _blink(delta: float) -> void:
	_kit.blink_clock -= delta
	if _kit.blink_index < 0 and _kit.blink_clock <= 0:
		_kit.blink_index = 15
		_kit.blink_updates = 0
		_kit.blink_repeat = _kit.random.randi_range(0, 3)
	if _kit.blink_index >= 0:
		_kit.blink_updates += delta * 60
		while _kit.blink_updates >= 1 and _kit.blink_index >= 0:
			_kit.blink_updates -= 1
			_kit.blink_index -= 1
		if _kit.blink_index < 0:
			if _kit.blink_repeat > 0:
				_kit.blink_repeat -= 1
				_kit.blink_index = 15
			else:
				_kit.blink_clock = _kit.random.randf_range(1, 2)
	_kit.face_material.set_shader_parameter("blink", _kit.blink_amount())
