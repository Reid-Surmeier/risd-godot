extends SceneTree

const Surface := preload("res://modules/sketchbook/drawing_surface.gd")
const Controls := preload("res://modules/sketchbook/tldraw_controls_prototype.gd")

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var host := Control.new()
	root.add_child(host)
	var surface := Surface.new()
	surface.size = Vector2(600, 400)
	host.add_child(surface)
	var controls := Controls.new()
	controls.configure(surface)
	host.add_child(controls)
	await process_frame

	for tool in ["select", "hand", "draw", "eraser"]:
		_press(controls, "tool", tool)
		_check(surface.tool == tool, "tool_%s" % tool)

	_press(controls, "size", "XL")
	_press(controls, "opacity", 1)
	_check(surface.tool == "draw" and is_equal_approx(surface.stroke_width, 13.0), "xl_changes_actual_width")
	_check(is_equal_approx(surface.stroke_opacity, 0.25), "opacity_changes_actual_ink")

	surface._begin_stroke(Vector2(20, 20))
	surface._extend_stroke(Vector2(80, 50))
	surface._end_stroke()
	_check(surface.stroke_count() == 1 and is_equal_approx(surface.spreads[1][0].color.a, 0.25), "styled_stroke_recorded")
	controls.undo_button.emit_signal("pressed")
	_check(surface.stroke_count() == 0 and surface.can_redo(), "undo")
	controls.redo_button.emit_signal("pressed")
	_check(surface.stroke_count() == 1 and surface.can_undo(), "redo")

	host.free()
	await process_frame
	print("tldraw controls: %s" % ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)

func _press(controls: Control, kind: String, value: Variant) -> void:
	for button in controls.choice_buttons:
		if button.get_meta("kind") == kind and button.get_meta("value") == value:
			button.emit_signal("pressed")
			return
	_check(false, "missing_%s_%s" % [kind, value])

func _check(condition: bool, label: String) -> void:
	print("%s %s" % ["PASS" if condition else "FAIL", label])
	if not condition:
		failures += 1
