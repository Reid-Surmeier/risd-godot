extends "res://testing/harness_base.gd"

func drag(from: Vector2, to: Vector2) -> void:
	await _button(from, MOUSE_BUTTON_LEFT, true)
	for i in range(1, 9):
		var motion := InputEventMouseMotion.new()
		motion.position = from.lerp(to, i / 8.0)
		motion.global_position = motion.position
		motion.relative = (to - from) / 8.0
		motion.button_mask = MOUSE_BUTTON_MASK_LEFT
		Input.parse_input_event(motion)
		await process_frame
	await _button(to, MOUSE_BUTTON_LEFT, false)

func point(control: Control, local: Vector2) -> Vector2:
	return control.get_global_transform() * local

func _initialize() -> void:
	var page: Control = load("res://modules/sculpture_viewer/interface.gd").create({}).value
	var out := await _mount(page, Vector2i(1080, 972), "/tmp/scan-windows")
	await create_timer(2).timeout
	await _shot(out, "before.png")
	for window in page.windows.duplicate():
		var grip: Control = window.get_node("ResizeGrip")
		var original: Vector2 = window.scale
		var start := point(grip, grip.size / 2)
		await drag(start, start - Vector2(110, 100))
		assert(window.scale.x < original.x, "resize grip must shrink window")
		assert(is_equal_approx(window.scale.x, window.scale.y), "window must scale uniformly")
		var old_position: Vector2 = window.position
		start = point(window, Vector2(100, 20))
		await drag(start, start + Vector2(30, 50))
		assert(window.position.distance_to(old_position) > 10, "header must move window")
		assert(page.windows.back() == window, "active window must raise")
		var smaller: float = window.scale.x
		start = point(grip, grip.size / 2)
		await drag(start, start + Vector2(40, 30))
		assert(window.scale.x > smaller, "grip must enlarge window")
		assert(is_equal_approx(window.scale.x, window.scale.y))
	await _shot(out, "resized.png")
	# Card selection and model orbit still receive pointer input after uniform scaling.
	await _click(point(page.cards_view, page.cards_view._card_rect(1).get_center()), "select second scan")
	assert(page.viewer.scan_id == page.cards_view.IDS[1])
	assert(page.dragged_window == null)
	var yaw: float = page.viewer.qa_state().yaw
	var vp: Control = page.viewer.viewport_container
	var center := point(vp, vp.size / 2)
	await drag(center, center + Vector2(45, 10))
	assert(absf(page.viewer.qa_state().yaw - yaw) > 1.0, "scaled viewer must orbit")
	var position: Vector2 = page.viewer_window.position
	var scale: Vector2 = page.viewer_window.scale
	page.hide()
	await process_frame
	page.show()
	root.size = Vector2i(1200, 1000)
	await _frames(4)
	assert(page.viewer_window.position == position and page.viewer_window.scale == scale, "resize/hide must preserve adjustments")
	await _shot(out, "after-page-resize.png")
	var grip: Control = page.viewer_window.get_node("ResizeGrip")
	await _button(point(grip, grip.size / 2), MOUSE_BUTTON_LEFT, true)
	assert(page.resized_window != null)
	page.notification(Control.NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert(page.resized_window == null and page.dragged_window == null)
	await _button(point(grip, grip.size / 2), MOUSE_BUTTON_LEFT, false)
	print("WINDOW192 four windows drag/raise, shrink/grow, uniform aspect, selection, orbit and retained placement PASS")
	quit()
