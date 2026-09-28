## #172 real native rail clicks and overlap regression on all seven square Pages.
extends "res://testing/harness_base.gd"

const Scene := preload("res://modules/shell/demo.tscn")
var stage: Control
var chrome: Control
var failures := 0
var opened: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _press(target: Vector2, double: bool = false) -> void:
	var screen := target
	for _i in 6:
		screen += target - stage._screen_to_desktop(screen)
	var motion := InputEventMouseMotion.new()
	motion.position = screen
	Input.parse_input_event(motion)
	await process_frame
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = screen
		event.global_position = screen
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.double_click = double
		Input.parse_input_event(event)
		await process_frame
	await _frames(20)


func _run() -> void:
	stage = Scene.instantiate()
	var out := await _mount(stage, Vector2i(1080, 1080), "/tmp/icon-172")
	await _frames(60)
	chrome = stage.get_node("Desktop/Content/SquareChrome")
	for index in 7:
		await _press(chrome.tab_buttons[index].get_global_rect().get_center())
		assert(chrome._active() == index)
		var page: Control = chrome.pages.get_node("Page_" + chrome.KEYS[index])
		var rail: Control = page.find_child("DesktopIcons", true, false)
		if index == 5:
			assert(rail == null, "Playground owns its full Page")
			await _shot(out, chrome.KEYS[index] + ".png")
			continue
		assert(rail != null)
		rail.opened.connect(func(key: String): opened.append(key))
		# The Tenant's full-rect content starts after the reserved Shell rail.
		var tenant: Control = page.get_child(0)
		for icon in rail.get_children():
			var rect: Rect2 = icon.get_global_rect()
			var fits: bool = rect.position.x >= page.global_position.x and rect.end.x <= tenant.global_position.x
			_log.append({"event": "rail", "tab": chrome.KEYS[index], "icon": icon.name,
				"rect": _rect(rect), "tenant_left": tenant.global_position.x, "fits": fits})
			if not fits:
				failures += 1
		await _shot(out, chrome.KEYS[index] + ".png")
		# Collection's frame clips its outside children already at the 72px baseline.
		# Its hidden rail is not an available click target; this Issue changes no Tenant.
		if index == 4:
			continue
		var icon: TextureRect = rail.get_child(0)
		await _press(icon.get_global_rect().get_center())
		assert(rail._selected == icon, "Icon click must still select")
		await _press(icon.get_global_rect().get_center(), true)
		assert(opened.back() == "downloads", "Double click must still open")
		_log.append({"event": "input", "tab": chrome.KEYS[index], "selected": icon.name, "opened": opened.back()})
	print("RAIL_OVERLAP_FAILURES=", failures)
	_finish(out)
	if failures:
		quit(1)
