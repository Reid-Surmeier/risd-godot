extends "res://modules/shell/prototype/gallery_walk4/walk4.gd"
## Throwaway visitor replacement only; inherited room, art, navigation and picking.
var visitor_pitch := 25.0
var attention_camera := 0.0
var attention_normal := Vector3.ZERO

func _nearest_work() -> Dictionary:
	var nearest: Dictionary = _paintings[0]
	for painting in _paintings:
		if _pos.distance_to(painting.center) < _pos.distance_to(nearest.center):
			nearest = painting
	return nearest

func _orbit(amount: float) -> void:
	if is_zero_approx(amount):
		return
	super._orbit(amount)
	var painting := _nearest_work()
	_kid.attention_target = painting.center
	attention_normal = painting.normal
	# Present a three-quarter body, then turn the head toward the actual work.
	var toward: Vector3 = painting.center - _pos
	toward.y = 0
	_motion_heading = toward.normalized().rotated(Vector3.UP, -0.65)
	var mine := _action
	while absf(wrapf(_kid.rotation.y - atan2(_motion_heading.x, _motion_heading.z), -PI, PI)) > 0.015:
		await get_tree().process_frame
		if _action != mine:
			return
	_kid.play_gesture("look")

func _approach(p: Dictionary) -> void:
	_kid.attention_target = p.center
	attention_normal = p.normal
	super._approach(p)

func _update_camera(k: float) -> void:
	super._update_camera(k)
	if view_mode != 0:
		return
	var pitch := deg_to_rad(visitor_pitch)
	var desired := 1.0 if _kid != null and _kid.gesture in ["look", "wave"] else 0.0
	attention_camera = lerpf(attention_camera, desired, k)
	var camera_yaw := view_yaw
	if _kid != null and _kid.attention_target != null:
		var toward: Vector3 = _kid.attention_target - _pos
		camera_yaw = lerp_angle(view_yaw, atan2(toward.x, toward.z) + 1.48, attention_camera)
	var forward := Vector3(-sin(camera_yaw), 0, -cos(camera_yaw))
	var center := _pos + forward * 0.7 + Vector3.UP * 1.55
	if _kid != null and _kid.attention_target != null:
		center = center.lerp((_pos + Vector3.UP * 1.55).lerp(_kid.attention_target, 0.4), attention_camera)
	var distance := lerpf(14.2, 6.0, attention_camera)
	_cam.fov = lerpf(23.0, 51.0, attention_camera)
	_cam.position = center - forward * distance * cos(pitch) + Vector3.UP * distance * sin(pitch)
	if attention_camera > 0.001 and _kid.attention_target != null:
		var clearance: float = (_cam.position - _kid.attention_target).dot(attention_normal)
		_cam.position += attention_normal * maxf(0.0, 1.8 - clearance)
	_cam.look_at(center)
	# The inherited cutaway mask must follow the actual attention camera too.
	var hidden := (4 if forward.x < -0.2 else (2 if forward.x > 0.2 else 0)) | (8 if forward.z < -0.2 else (16 if forward.z > 0.2 else 0))
	_cam.cull_mask = (1984 & ~(hidden * 64)) if _space != "gallery" else (31 & ~hidden)
	if _space == "gallery" and absf(_cam.position.x) < W / 2.0 and _cam.position.z > -L and _cam.position.z < 0:
		_cam.cull_mask = 31

func _ready() -> void:
	super._ready()
	var capture := OS.get_environment("VISITOR_CAPTURE") == "1"
	if OS.has_feature("web"):
		capture = JavaScriptBridge.eval("new URLSearchParams(location.search).has('capture')")
	if capture:
		var evidence = load(DIR + "visitor159/evidence.gd").new()
		evidence.gallery = self
		add_child(evidence)

func _build_kid() -> void:
	super._build_kid()
	_vp.remove_child(_kid)
	_kid.free()
	_kid = load(DIR + "visitor159/visitor.gd").new()
	_kid.world_height = KID_H
	_kid.lighting = OS.get_environment("VISITOR_MATERIAL") != "source"
	if OS.has_feature("web"):
		_kid.lighting = JavaScriptBridge.eval("new URLSearchParams(location.search).get('material') !== 'source'")
	_vp.add_child(_kid)
