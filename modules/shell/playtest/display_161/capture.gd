## Throwaway #161: matched square-stage display captures, never a runtime dependency.
extends "res://testing/harness_base.gd"

const Scene := preload("res://modules/shell/demo.tscn")
var stage: Control
var walk: Control


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	stage = Scene.instantiate()
	var out := await _mount(stage, Vector2i(1080, 1080), "/tmp/risd-display-161")
	await _frames(90)
	var chrome: Control = stage.get_node("Desktop/Content/SquareChrome")
	chrome.tab_buttons[4].pressed.emit()
	await _frames(90)
	walk = stage.find_child("GalleryWalk", true, false)
	assert(walk != null, "Gallery Walk not mounted in square stage")
	assert(chrome.pages.size == Vector2(1080, 972), "Square Tenant area changed")
	var finish: ShaderMaterial = walk._vp.get_parent().material
	assert(finish.shader.resource_path.ends_with("gamecube.gdshader"), "wrong display material")
	walk._entrance_active = false
	walk._entrance_waiting = false
	walk._target = null
	walk._target_yaw = null
	walk._view_turn_remaining = 0.0
	walk._pos = Vector3(0, 0, -8.0)
	walk._yaw = PI
	walk._update_camera(1.0)
	await _frames(15)
	for mode in ["bypass", "current", "copy-full"]:
		finish.set_shader_parameter("quantization_mode", 0 if mode == "bypass" else 2)
		finish.set_shader_parameter("copy_filter", 0.0 if mode == "bypass" else (1.0 if mode == "copy-full" else 0.5))
		await _frames(15)
		await _shot(out, mode + "-warm.png")
	print("PASS: matched square display modes; 23 paintings=" + str(walk._paintings.size()))
	assert(walk._paintings.size() == 23)
	_finish(out)
