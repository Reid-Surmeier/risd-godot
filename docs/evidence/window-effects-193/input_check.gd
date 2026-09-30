extends "res://testing/harness_base.gd"
var stage: Control
var failures := 0
func check(ok: bool, label: String) -> void:
	print("PASS " if ok else "FAIL ", label)
	if not ok: failures += 1
func _initialize() -> void:
	call_deferred("run")
func screen(point: Vector2) -> Vector2:
	return stage.stage_rect.position + point / 1080.0 * stage.stage_rect.size
func drag(from: Vector2, delta: Vector2) -> void:
	await _button(screen(from), MOUSE_BUTTON_LEFT, true)
	for i in range(1, 9):
		var motion := InputEventMouseMotion.new()
		motion.position = screen(from + delta * i / 8.0)
		motion.global_position = motion.position
		motion.relative = delta / 8.0 * stage.stage_rect.size / 1080.0
		motion.button_mask = MOUSE_BUTTON_MASK_LEFT
		Input.parse_input_event(motion)
		await process_frame
	await _button(screen(from + delta), MOUSE_BUTTON_LEFT, false)
	await _frames(3)
func run() -> void:
	stage = load("res://modules/shell/demo.tscn").instantiate()
	var out := await _mount(stage, Vector2i(1080, 1080), "/tmp/window-effects-193")
	stage.enabled = false
	stage._publish_state()
	stage.squiggle.visible = false
	stage.haze.visible = false
	await create_timer(1.5).timeout
	var shell = stage.get_node("Desktop/Content/Shell")
	for index in ([1,4] if "--sketchbook-only" in OS.get_cmdline_user_args() else [0, 1, 5, 4]):
		load("res://modules/shell/interface.gd").select_tab(shell, index)
		await create_timer(0.8).timeout
		await _shot(out, "page-%d-before.png" % index)
		var grips: Array = stage.find_children("ProportionalResize", "Control", true, false)
		var count := 0
		for grip in grips:
			if not grip.is_visible_in_tree(): continue
			var window: Control = grip.get_parent()
			# Bring each actual window forward, then exercise its real grip input.
			window.get_parent().move_child(window, -1)
			await _frames(2)
			await _click(screen(window.get_global_transform() * Vector2(50, 12)), "raise window by its header")
			var before := window.scale
			var original_size := window.size
			await drag(grip.get_global_rect().get_center(), Vector2(-55, -45))
			check(window.scale.x < before.x and is_equal_approx(window.scale.x, window.scale.y), str(index) + ": " + window.name + " shrink")
			var small := window.scale.x
			await drag(grip.get_global_rect().get_center(), Vector2(25, 20))
			check(window.scale.x > small and is_equal_approx(window.scale.x, window.scale.y), str(index) + ": " + window.name + " grow")
			check(window.size == original_size, "unchanged internal layout")
			if index == 4:
				check(window.get_global_rect().get_center().is_equal_approx(window.get_parent().get_global_rect().get_center()), "resized Collection centered")
			count += 1
		check(count > 0, "page " + str(index) + " has resize grips")
		if index == 0:
			var atlas = stage.find_child("Atlas", true, false)
			var frame_rect: Rect2 = atlas.frame.get_global_rect()
			await _click(screen(atlas.minimize.get_global_rect().get_center()), "collapse resized map")
			check(atlas.collapsed and not atlas.container.visible, "resized map collapse")
			await _click(screen(atlas.minimize.get_global_rect().get_center()), "expand resized map")
			check(not atlas.collapsed and atlas.frame.get_global_rect().is_equal_approx(frame_rect), "resized map expand")
			await _click(screen(atlas.lock_button.get_global_rect().get_center()), "lock map")
			await drag(atlas.frame.get_node("ProportionalResize").get_global_rect().get_center(), Vector2(-30,-30))
			check(atlas.frame.get_global_rect().is_equal_approx(frame_rect), "locked map rejects resize")
			await _click(screen(atlas.lock_button.get_global_rect().get_center()), "unlock map")
			var zoom: float = atlas.map.camera.zoom.x
			await _button(screen(atlas.container.get_global_rect().get_center()), MOUSE_BUTTON_WHEEL_UP, true)
			await _button(screen(atlas.container.get_global_rect().get_center()), MOUSE_BUTTON_WHEEL_UP, false)
			check(atlas.map.camera.zoom.x > zoom, "map wheel zoom after resize")
		if index == 1:
			var book = stage.find_child("sketchbook-window", true, false)
			await _click(screen(book.title_bar.get_global_rect().get_center()), "raise resized book")
			var strokes: int = book.surface.stroke_count()
			await drag(book.surface.get_global_rect().get_center() + Vector2(30, 0), Vector2(35,20))
			check(book.surface.stroke_count() > strokes, "draw on resized book")
		await _shot(out, "page-%d-after.png" % index)
	var walk = stage.find_child("GalleryWalk", true, false)
	var frame = walk.get_parent()
	var frame_scale: Vector2 = frame.scale
	walk._open_detail(walk._paintings[0])
	check(frame.scale == Vector2.ONE and not frame.get_node("ProportionalResize").visible, "artwork preview fills page")
	await _shot(out, "collection-preview.png")
	await _key(KEY_ESCAPE, "return to resized Collection")
	check(frame.scale == frame_scale and frame.get_node("ProportionalResize").visible, "collection scale restored")
	check(frame.get_global_rect().get_center().is_equal_approx(frame.get_parent().get_global_rect().get_center()), "returned Collection centered")
	print("WINDOW193 real-pointer failures=", failures)
	quit(1 if failures else 0)
