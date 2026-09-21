extends SceneTree

var failures := 0

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, label: String) -> void:
	print(("PASS " if condition else "FAIL ") + label)
	if not condition:
		failures += 1

func _click(box: Control, point: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = point
	box._gui_input(event)

func _run() -> void:
	var box: Control = load("res://modules/sketchbook/paintbox.gd").new()
	box.set_anri_mode(true)
	root.add_child(box)
	box.size = Vector2(360, 775)
	await process_frame
	# Visible centers measured in the 1120x2240 Muse reconstruction.
	var visible_red_well: Vector2 = box.tool_reference.position + Vector2(728.0 / 1120.0, 1095.0 / 2240.0) * box.tool_reference.size
	var visible_top_tray: Vector2 = box.tool_reference.position + Vector2(250.0 / 1120.0, 1200.0 / 2240.0) * box.tool_reference.size
	var before: Color = box.brush_color
	for row in range(2):
		for column in range(15):
			var source_center := Vector2(168.0 + 56.0 * column, 1095.0 if row == 0 else 1355.0)
			var visible_center: Vector2 = box.tool_reference.position + source_center / Vector2(1120, 2240) * box.tool_reference.size
			_check(box._well_at(box._uv(visible_center)) == row * 16 + column, "visible_well_%d_%d_is_clickable" % [row, column])
	var motion := InputEventMouseMotion.new()
	motion.position = visible_red_well
	box._input(motion)
	box._process(0.0)
	_check(box.brush_cursor.visible, "brush_follows_visible_palette")
	_click(box, visible_red_well)
	_check(not box.brush_color.is_equal_approx(before), "visible_muse_well_loads_pigment")
	_click(box, visible_top_tray)
	_check(box.qa_state().paint_pixels > 0, "visible_muse_tray_accepts_paint")
	var visible_blue_well: Vector2 = box.tool_reference.position + Vector2(448.0 / 1120.0, 1355.0 / 2240.0) * box.tool_reference.size
	_click(box, visible_blue_well)
	_click(box, visible_top_tray)
	_check(box.qa_state().mix_count > 0, "visible_muse_tray_mixes_two_pigments")
	_check(box.parked_brush.visible, "brush_starts_on_cat")
	box.set_brush_active(true)
	_check(not box.parked_brush.visible, "brush_lifts_from_cat")
	box.set_brush_active(false)
	_check(box.parked_brush.visible, "brush_returns_to_cat")
	box.queue_free()
	print("anri palette: " + ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)
