extends "res://modules/shell/prototype/gallery_walk4/walk4.gd"
## Throwaway visitor replacement only; inherited room, art, navigation and picking.
var visitor_pitch := 25.0

func _update_camera(k: float) -> void:
	super._update_camera(k)
	if view_mode != 0:
		return
	var pitch := deg_to_rad(visitor_pitch)
	var forward := Vector3(-sin(view_yaw), 0, -cos(view_yaw))
	var center := _pos + forward * 0.7 + Vector3.UP * 1.55
	_cam.position = center - forward * 14.2 * cos(pitch) + Vector3.UP * 14.2 * sin(pitch)
	_cam.look_at(center)

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
