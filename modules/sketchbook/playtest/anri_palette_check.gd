extends SceneTree

var failures := 0


func _init() -> void:
	call_deferred("_run")


func _check(condition: bool, label: String) -> void:
	print(("PASS " if condition else "FAIL ") + label)
	if not condition:
		failures += 1


func _mouse_button(box: Control, point: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = point
	box._gui_input(event)


func _click(box: Control, point: Vector2) -> void:
	_mouse_button(box, point, true)
	_mouse_button(box, point, false)


func _drag(box: Control, from: Vector2, to: Vector2) -> void:
	_mouse_button(box, from, true)
	for step in range(1, 9):
		var event := InputEventMouseMotion.new()
		event.position = from.lerp(to, float(step) / 8.0)
		event.button_mask = MOUSE_BUTTON_MASK_LEFT
		box._deposit(box._uv(event.position))
	_mouse_button(box, to, false)


func _run() -> void:
	var box: Control = load("res://modules/sketchbook/paintbox.gd").new()
	box.set_anri_mode(true)
	root.add_child(box)
	box.size = Vector2(360, 775)
	await process_frame
	var cues := []
	box.sound_cue_requested.connect(func(cue: String): cues.append(cue))
	var visible_red_well: Vector2 = (
		box.image_rect.position + box._well_center(0, 10) * box.image_rect.size
	)
	var top_tray: Rect2 = box._active_trays()[0]
	var visible_top_tray := Rect2(
		box.image_rect.position + top_tray.position * box.image_rect.size,
		top_tray.size * box.image_rect.size
	)
	var before: Color = box.brush_color
	for row in range(2):
		for column in range(16):
			var visible_center: Vector2 = (
				box.image_rect.position + box._well_center(row, column) * box.image_rect.size
			)
			_check(
				box._well_at(box._uv(visible_center)) == row * 16 + column,
				"visible_well_%d_%d_is_clickable" % [row, column]
			)
	var motion := InputEventMouseMotion.new()
	motion.position = visible_red_well
	box._input(motion)
	box._process(0.0)
	_check(box.brush_cursor.visible, "brush_follows_visible_palette")
	_click(box, visible_red_well)
	_check(not box.brush_color.is_equal_approx(before), "visible_muse_well_loads_pigment")
	_drag(
		box,
		visible_top_tray.position + Vector2(8, visible_top_tray.size.y * 0.5),
		visible_top_tray.end - Vector2(8, visible_top_tray.size.y * 0.5)
	)
	_check(box.qa_state().paint_pixels > 0, "visible_muse_tray_accepts_paint")
	var visible_blue_well: Vector2 = (
		box.image_rect.position + box._well_center(1, 5) * box.image_rect.size
	)
	_click(box, visible_blue_well)
	_drag(
		box,
		visible_top_tray.position + Vector2(visible_top_tray.size.x * 0.5, 8),
		visible_top_tray.end - Vector2(visible_top_tray.size.x * 0.5, 8)
	)
	_check(box.qa_state().mix_count > 0, "visible_muse_tray_mixes_two_pigments")
	var cue_count := cues.count("mixing")
	_mouse_button(box, visible_top_tray.get_center(), true)
	box._process(box.MIX_CUE_INTERVAL)
	_mouse_button(box, visible_top_tray.get_center(), false)
	_check(
		cues.count("mixing") == cue_count + 2, "mixing_cue_starts_and_repeats_while_brush_is_down"
	)
	_check(
		is_equal_approx(box.image_rect.size.aspect(), box.ANRI_PALETTE_SOURCE.size.aspect()),
		"palette_keeps_original_aspect"
	)
	_check(
		is_equal_approx(box.brush_stage.position.y, box.image_rect.end.y), "palette_bottom_is_clean"
	)
	_check(box.parked_brush.position.y - box.image_rect.end.y >= 12.0, "brush_clears_palette_base")
	_check(box.parked_brush.visible, "brush_starts_on_cat")
	box.set_brush_active(true)
	_check(not box.parked_brush.visible, "brush_lifts_from_cat")
	box.set_brush_active(false)
	_check(box.parked_brush.visible, "brush_returns_to_cat")
	box.queue_free()
	print("anri palette: " + ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)
