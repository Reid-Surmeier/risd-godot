extends "res://testing/harness_base.gd"
const Shell = preload("res://modules/shell/interface.gd")
const Viewer = preload("res://modules/sculpture_viewer/interface.gd")
func _initialize() -> void:
	var shell: Control = Shell.create({"3d_viewer": Viewer}).value
	var out := await _mount(shell, Vector2i(1440, 972), "/tmp/risd-zoom82-close-native")
	await create_timer(1.0).timeout
	await _click(Shell.state(shell).value.tabs[2].rect.get_center(), "3D Viewer tab")
	await create_timer(0.5).timeout
	var s: Dictionary = Shell.tenant_state(shell, "3d_viewer").value
	await _click(s.controls["play-pause"].get_center(), "pause orbit")
	var center: Vector2 = s.viewport_rect.get_center()
	for i in 24:
		await _button(center, MOUSE_BUTTON_WHEEL_UP, true)
		await _button(center, MOUSE_BUTTON_WHEEL_UP, false)
	s = Shell.tenant_state(shell, "3d_viewer").value
	assert(is_equal_approx(s.distance, 2.8))
	await _shot(out, "closest.png")
	_log.append({"event": "close-zoom", "distance": s.distance, "model_loaded": s.model_loaded})
	_finish(out)
