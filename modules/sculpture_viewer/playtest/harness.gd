## #170 acceptance: real native input on the complete square application.
extends "res://testing/harness_base.gd"

const Scene := preload("res://modules/shell/demo.tscn")
const Shell := preload("res://modules/shell/interface.gd")
var stage: Control
var chrome: Control


func _initialize() -> void:
	call_deferred("_run")


func _pointer(target: Vector2, click: bool = false) -> void:
	var screen := target
	for _i in 6:
		screen += target - stage._screen_to_desktop(screen)
	var motion := InputEventMouseMotion.new()
	motion.position = screen
	motion.global_position = screen
	Input.parse_input_event(motion)
	await process_frame
	if click:
		await _click(screen, "native catalogue/tab click")
	await _frames(4)


func _probe(label: String) -> Dictionary:
	var data: Dictionary = Shell.tenant_state(chrome.shell, "3d_viewer").value.duplicate()
	var cards := []
	for rect in data.cards:
		cards.append(_rect(rect))
	data.cards = cards
	data.size = [data.size.x, data.size.y]
	data.event = "viewer"
	data.label = label
	_log.append(data)
	return data


func _run() -> void:
	stage = Scene.instantiate()
	var out := await _mount(stage, Vector2i(1080, 1080), "/tmp/viewer-170")
	await _frames(90)
	chrome = stage.get_node("Desktop/Content/SquareChrome")
	for i in 7:
		await _pointer(chrome.tab_buttons[i].get_global_rect().get_center(), true)
		await _frames(30)
		assert(chrome._active() == i)
		_log.append({"event": "tab", "key": chrome.KEYS[i], "active": chrome._active()})
		await _shot(out, "tab-" + chrome.KEYS[i] + ".png")
	await _pointer(chrome.tab_buttons[2].get_global_rect().get_center(), true)
	await _frames(30)
	_probe("initial")
	for i in 20:
		var state: Dictionary = Shell.tenant_state(chrome.shell, "3d_viewer").value
		await _pointer(state.cards[i].get_center(), true)
		var selected := _probe("selected-%02d" % i)
		assert(selected.selected == i and selected.hovered == i)
		assert(not selected["3d_preview_available"])
		if i in [2, 5, 19]:
			await _shot(out, "selected-%02d.png" % i)
	var state: Dictionary = Shell.tenant_state(chrome.shell, "3d_viewer").value
	await _pointer(state.cards[5].get_center())
	_probe("hover")
	await _frames(20)
	_probe("hover-later")
	await _shot(out, "hover.png")
	await _pointer(chrome.tab_buttons[4].get_global_rect().get_center(), true)
	await _frames(30)
	_probe("hidden")
	await _pointer(state.cards[0].get_center(), true)
	await _frames(20)
	_probe("hidden-after-input")
	await _pointer(chrome.tab_buttons[2].get_global_rect().get_center(), true)
	await _frames(30)
	_probe("returned")
	await _shot(out, "returned.png")
	print("PASS: seven Tabs; all 20 real clicks; hover; hidden input; return")
	_finish(out)
