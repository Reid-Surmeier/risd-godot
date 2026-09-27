## #164 integration input check, separate from the frozen Shell acceptance fixture.
extends "res://testing/harness_base.gd"

const Scene := preload("res://modules/shell/demo.tscn")
const Playground := preload("res://modules/playground_page/interface.gd")
var stage: Control
var chrome: Control


func _initialize() -> void:
	call_deferred("_run")


func _press(control: Control, what: String) -> void:
	# Map the logical control point back through the display's CRT warp.
	var target := control.get_global_rect().get_center()
	var screen := target
	for _i in 6:
		screen += target - stage._screen_to_desktop(screen)
	var motion := InputEventMouseMotion.new()
	motion.position = screen
	Input.parse_input_event(motion)
	await process_frame
	await _click(screen, what)
	await _frames(30)


func _run() -> void:
	stage = Scene.instantiate()
	var out := await _mount(stage, Vector2i(1080, 1080), "res://docs/evidence/integration-164")
	await _frames(90)
	chrome = stage.get_node("Desktop/Content/SquareChrome")
	for i in 7:
		await _press(chrome.tab_buttons[i], "Tab " + chrome.KEYS[i])
		assert(chrome._active() == i, "Tab click failed")
		assert(chrome.tab_buttons[i].button_pressed)
		assert(chrome.pages.size == Vector2(1080, 972))
		await _shot(out, "tab-" + chrome.KEYS[i] + ".png")
	await _press(chrome.strip.get_child(1), "Start")
	assert(chrome.start_menu.visible and chrome.start_menu.item_count == 7)
	await _shot(out, "start.png")
	# Activate Map from the actual popup with keyboard input.
	chrome.start_menu.set_focused_item(0)
	await _key(KEY_ENTER, "Start menu Map")
	await _frames(30)
	assert(chrome._active() == 0)
	await _press(chrome.tab_buttons[4], "Collection before Home")
	await _press(chrome.strip.get_child(chrome.strip.get_child_count() - 1), "Home")
	assert(chrome._active() == 0, "Home must select Map")
	for button in chrome.header.get_children():
		if button is Button and button.text == "Search Playground":
			await _press(button, "Top Search")
	assert(chrome._active() == 5)
	var tenant: Control = stage.get_node("Desktop/Content")._playground
	assert(Playground.state(tenant).value.page == "search")
	assert(stage.get_node("Desktop").gui_get_focus_owner() is LineEdit)
	await _shot(out, "top-search.png")
	for page in ["explore", "all", "channels", "search"]:
		var button := tenant.find_child("Page_" + page, true, false) as Button
		assert(button != null, "Missing Playground navigation button")
		await _press(button, "Playground " + page)
		assert(Playground.state(tenant).value.page == page, "Page click failed: " + page)
		await _shot(out, "playground-" + page + ".png")
		if page == "explore":
			var wheel := InputEventMouseButton.new()
			wheel.position = Vector2(950, 900)
			wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
			wheel.pressed = true
			Input.parse_input_event(wheel)
			wheel = wheel.duplicate()
			wheel.pressed = false
			Input.parse_input_event(wheel)
			await _frames(5)
			var scroll := tenant.find_children("*", "ScrollContainer", true, false)[0] as ScrollContainer
			assert(scroll.scroll_vertical > 0, "Playground must scroll to lower Save controls")
			await _shot(out, "playground-explore-scrolled.png")
	print("PASS: seven Tabs, Start selection, Home, top Search focus, four Playground pages")
	_finish(out)
