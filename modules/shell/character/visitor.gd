extends Node3D
## #236 Collection visitor: the accepted #235 character behind the surface walk4.gd drives.
## The museum owns position, collision and camera; this node only faces, animates and sounds.
## Walk, run, dash, skid and jump come from the package; tools and doors stay in the playtest.
const HOME := "res://modules/shell/character/"
const Demo := preload("res://modules/shell/character/demo.gd")
# Skinned rest height of walk.glb in metres, horns included; visitor174_check.gd re-measures it.
const REST_HEIGHT := 1.877
# Where in each gait clip a foot lands after its high lift, as a share of the clip
# (Left, Right), measured at 480 samples. Steps sound when playback crosses these, so they
# stay in time with the visible landing at any frame rate. visitor174_check.gd re-measures.
# In the run both feet leave the floor; its right foot dips at 0.43 before landing at 0.57.
const LANDINGS := {"walk": [0.823, 0.304], "run": [0.079, 0.567], "dash": [0.842, 0.323]}
# The museum's sprint is faster than this many metres a second; its walk is slower.
const SPRINT_FROM := 2.5
# The accepted playtest's hop: 0.05 s crouch, 3.6 m/s launch, 0.23 s landing.
const JUMP_CROUCH := 0.05
const JUMP_LAUNCH := 3.6
const JUMP_LANDING := 0.23
# Sole heights that count as lifted and as planted, for the museum's contact shadows only.
# The planted foot rolls up to 2.6 cm mid-stance, hence the gap.
const LIFT := 0.035
const PLANT := 0.01
# The captured steps peak at -29 to -38 dBFS; the museum's other sounds peak near -3 dBFS and
# its previous steps played at -8 dB. With the package's own +6 dB captured-mix gain (#235)
# this puts the captured steps at that same loudness.
const MUSEUM_GAIN_DB := 14.0
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
var _effects := AudioStreamPlayer.new()
var _air := -1.0  # seconds since the jump began; negative on the ground
var _launched := false
var _landed := -1.0  # seconds since touching down
var _rise := 0.0
var _height := 0.0
var _ground := 0.0  # the model offset that put the soles on the floor before take-off
var _skid := 0.0  # seconds of skid left after a dash is thrown into reverse
var _timing := false  # ?qa-sound in the page address: each step's time is published for latency checks
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
	for gait in ["run", "dash", "skid"]:
		var source: Node3D = load(HOME + gait + ".glb").instantiate()
		var clips: AnimationPlayer = source.find_children("*", "AnimationPlayer", true, false)[0]
		library.add_animation(gait, clips.get_animation("walk").duplicate())
		source.free()
	for clip in ["idle", "walk", "run", "dash"]:
		library.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
	player.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	player.play("idle")
	player.advance(0)
	_kit.model = model
	_kit.skeleton = target
	_kit.player = player
	_kit.make_jump_animation()  # adds jump, flight and landing, built from the idle pose
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
	add_child(_effects)
	_timing = OS.has_feature("web") and bool(
		JavaScriptBridge.eval("new URLSearchParams(location.search).has('qa-sound')")
	)
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
	_air = -1.0
	_skid = 0.0
	rotation.y = 0.0
	model.rotation.x = 0.0
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


## A hop on the spot or in stride; ignored while one is already under way.
func jump() -> void:
	if _air >= 0.0:
		return
	_air = 0.0
	_launched = false
	_landed = -1.0
	_rise = 0.0
	_height = 0.0
	player.play("jump", 0.1)


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
	var sprint := speed > SPRINT_FROM
	var movement = _kit.movement
	var units: float = (
		speed / (movement.travel_gain * model.scale.y) / (7.5 if sprint else 4.875)
	)
	movement.heading = 0.0
	movement.step(Vector2(0, minf(units, 1.0)), sprint, delta)
	# A dash thrown more than 100 degrees round skids, as in the playtest.
	if (
		_clip == "dash"
		and sprint
		and heading.length_squared() > 0.1
		and absf(wrapf(atan2(heading.x, heading.z) - old_yaw, -PI, PI)) > deg_to_rad(100)
	):
		_skid = 0.35
		_clip = "skid"
		player.play("skid", 0.08)
		player.speed_scale = 1.0
		_cue("Skid", 0.8)
	var clip := "jump"
	if _air >= 0.0:
		_hop(delta)
	elif _skid > 0.0:
		_skid -= delta
		clip = "skid"
		player.advance(delta)
		if _skid <= 0.0:
			_clip = ""
	else:
		clip = {"Idle": "idle", "Walk": "walk", "Run": "run", "Dash": "dash"}.get(
			movement.gait, "idle"
		)
		if clip != _clip:
			_clip = clip
			player.play(clip, 0.167 if delta > 0 else 0.0)
		player.speed_scale = (
			1.0
			if clip == "idle"
			else player.get_animation(clip).length * movement.phase_step * 60.0 / 16.0
		)
		var before := player.current_animation_position
		player.advance(delta)
		if clip != "idle" and speed > 0.08:
			var length := player.current_animation_length
			var after := player.current_animation_position
			if after < before:
				after += length
			for index in 2:
				var at: float = LANDINGS[clip][index] * length
				if (before < at and after >= at) or (before < at + length and after >= at + length):
					contacts += 1
					_step(["Left", "Right"][index], movement.gait)
	var airborne := _air >= 0.0 and _launched and _landed < 0.0
	model.rotation.x = move_toward(
		model.rotation.x, 0.0 if _air >= 0.0 else movement.lean, deg_to_rad(120) * delta
	)
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
	if airborne:
		model.position.y = _ground + _height  # the tucked pose rises; nothing pulls it down
	else:
		_ground = -floor_y
		model.position.y = _ground
	for index in 2:
		var foot: Dictionary = _feet[index]
		foot.low += model.position.y
		if airborne:
			foot.planted = false
		elif clip in ["idle", "jump", "skid"]:
			foot.planted = true
		elif foot.planted and foot.low > LIFT * model.scale.y:
			foot.planted = false
		elif not foot.planted and foot.low < PLANT * model.scale.y:
			foot.planted = true
	_blink(delta)


# The playtest's hop without its physics body: crouch, rise and fall under gravity, land.
func _hop(delta: float) -> void:
	_air += delta
	player.speed_scale = 1.0
	var at := minf(_air / JUMP_CROUCH * 0.11, 0.11)
	if _landed >= 0.0:
		_landed += delta
		at = _landed
		if _landed >= JUMP_LANDING:
			_air = -1.0
			_clip = ""  # the next pose blends back into the gait
			return
	elif _air >= JUMP_CROUCH:
		if not _launched:
			_launched = true
			_rise = JUMP_LAUNCH
			player.play("flight", 0.1)
			_cue("Jump", 0.7)
		_rise -= 9.8 * delta
		_height += _rise * delta
		at = 0.6 * clampf(1.0 - _rise / JUMP_LAUNCH, 0.0, 2.0) / 2.0
		if _height <= 0.0 and _rise < 0.0:
			_height = 0.0
			_landed = 0.0
			at = 0.0
			player.play("landing", 0.08)
			_cue("Landing", 0.8)
	player.seek(maxf(0.0, at - delta), false)
	player.advance(delta)


func _cue(bank: String, gain: float) -> void:
	# The playtest's authored hop sounds (the original game has no jump), at the museum's level.
	_effects.stream = _kit.sounds.streams[_kit.sounds.key(bank, false, 0)]
	_effects.volume_db = -14 + linear_to_db(gain) + 6.0
	_effects.play()


func _step(side: String, gait: String) -> void:
	# Same cue selection and relative gait levels as the accepted playtest's captured-house
	# profile (#235), raised as a whole to the museum's loudness.
	# ponytail: one voice. The recordings last 185 ms; the fastest gait here lands a step
	# every 270 ms. A faster gait would need the playtest's polyphonic player.
	var cue: Dictionary = _kit.sounds.step("Indoor", gait, side, true)
	_speaker.stream = cue.stream
	_speaker.volume_db = (
		-14 + linear_to_db(cue.gain) + cue.get("gain_offset_db", 0) + MUSEUM_GAIN_DB
	)
	_speaker.pitch_scale = cue.pitch
	_speaker.play(cue.get("start_offset", 0))
	if _timing:
		JavaScriptBridge.eval("(window.visitorSteps=window.visitorSteps||[]).push(performance.now())")


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
