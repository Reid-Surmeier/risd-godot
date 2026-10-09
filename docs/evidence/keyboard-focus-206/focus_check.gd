extends "res://testing/harness_base.gd"
const Shell := preload("res://modules/shell/interface.gd")
var stage: Control
var shell: Control
var failures := 0
var observations: Array = []


func _initialize() -> void:
	call_deferred("run")


func check(ok: bool, label: String) -> void:
	var focus = stage.get_node("Desktop").gui_get_focus_owner()
	observations.append(
		{
			"check": label,
			"pass": ok,
			"shell": Shell.state(shell).value,
			"video": Shell.tenant_state(shell, "video_player"),
			"focus": str(focus.get_path()) if focus else "none"
		}
	)
	print("PASS " if ok else "FAIL ", label)
	if not ok:
		failures += 1


func video() -> Dictionary:
	return Shell.tenant_state(shell, "video_player").value


func screen(point: Vector2) -> Vector2:
	return stage.stage_rect.position + point / 1080.0 * stage.stage_rect.size


func run() -> void:
	stage = load("res://modules/shell/demo.tscn").instantiate()
	var out := await _mount(stage, Vector2i(1080, 1080), "/tmp/risd-focus-206")
	stage.enabled = false
	stage.squiggle.visible = false
	stage.haze.visible = false
	await create_timer(1.5).timeout
	shell = stage.get_node("Desktop/Content/Shell")
	var chrome = stage.find_child("SquareChrome", true, false)
	await _click(screen(chrome.tab_buttons[3].get_global_rect().get_center()), "mouse select Video")
	await create_timer(1.0).timeout
	check(Shell.state(shell).value.active == 3, "mouse opens Video")
	check(
		stage.get_node("Desktop").gui_get_focus_owner() == null,
		"mouse Shell control releases focus"
	)
	var before := float(video().stream_position)
	await _key(KEY_RIGHT, "seek right five seconds")
	await create_timer(0.25).timeout
	check(float(video().stream_position) > before + 4.5, "Right seeks after mouse selection")
	await _key(KEY_LEFT, "seek left five seconds")
	await create_timer(0.25).timeout
	check(float(video().stream_position) < before + 2.0, "Left seeks after mouse selection")
	await _key(KEY_SPACE, "pause Video")
	await create_timer(0.25).timeout
	check(
		Shell.state(shell).value.active == 3 and not video().playing,
		"Space pauses Video without selecting another Tab"
	)
	if Shell.state(shell).value.active == 3:
		var paused := float(video().stream_position)
		await create_timer(0.5).timeout
		check(abs(float(video().stream_position) - paused) < 0.03, "paused position remains fixed")
		await _key(KEY_SPACE, "resume Video")
		await create_timer(0.5).timeout
		check(
			video().playing and float(video().stream_position) > paused + 0.25,
			"Space resumes Video"
		)
		await _key(KEY_F, "Video fullscreen")
		check(video().fullscreen, "F enters Video fullscreen")
		await _shot(out, "video-fullscreen.png")
		await _key(KEY_F, "return from Video fullscreen")
		check(not video().fullscreen, "F returns from Video fullscreen")
		before = float(video().stream_position)
		await _key(KEY_RIGHT, "seek right after fullscreen return")
		await create_timer(0.25).timeout
		check(float(video().stream_position) > before + 4.5, "Right seeks after fullscreen return")
		await _key(KEY_LEFT, "seek left after fullscreen return")
		await create_timer(0.25).timeout
		check(float(video().stream_position) < before + 2.0, "Left seeks after fullscreen return")
		await _key(KEY_SPACE, "pause after fullscreen return")
		check(
			Shell.state(shell).value.active == 3 and not video().playing,
			"Space pauses after fullscreen return"
		)
		await _click(
			screen(chrome.tab_buttons[4].get_global_rect().get_center()), "hide paused Video"
		)
		await create_timer(0.6).timeout
		paused = float(video().stream_position)
		await _click(
			screen(chrome.tab_buttons[3].get_global_rect().get_center()), "return to paused Video"
		)
		await create_timer(0.6).timeout
		check(
			not video().playing and abs(float(video().stream_position) - paused) < 0.03,
			"paused Video survives hide and return"
		)
	await _shot(out, "video-return.png")
	# Actual Tab events must still reach a Shell Button; no programmatic grab_focus.
	var keyboard_button: Button
	for i in 30:
		await _key(KEY_TAB, "navigate with Tab")
		var focus = stage.get_node("Desktop").gui_get_focus_owner()
		if (
			focus is Button
			and chrome.is_ancestor_of(focus)
			and focus.get_parent() == chrome.header
			and focus.text == "Previous"
		):
			keyboard_button = focus
			break
	check(keyboard_button != null, "Tab reaches a Shell header Button")
	if keyboard_button != null:
		check(
			(
				keyboard_button.has_focus()
				and keyboard_button.get_theme_stylebox("focus") is StyleBoxFlat
			),
			"keyboard focus remains indicated"
		)
		await _shot(out, "keyboard-focus.png")
		var active: int = Shell.state(shell).value.active
		await _key(KEY_SPACE, "activate focused Shell control with Space")
		await create_timer(0.4).timeout
		check(
			Shell.state(shell).value.active == wrapi(active - 1, 0, 7),
			"Space activates keyboard-focused Shell control"
		)
		# A newly created Tenant may intentionally grab its initial focus. Navigate again.
		for i in 30:
			await _key(KEY_TAB, "navigate back to Previous")
			if keyboard_button.has_focus():
				break
		check(keyboard_button.has_focus(), "Tab returns to Shell after Tenant creation")
		active = Shell.state(shell).value.active
		await _key(KEY_ENTER, "activate focused Shell control with Enter")
		await create_timer(0.4).timeout
		check(
			Shell.state(shell).value.active == wrapi(active - 1, 0, 7),
			"Enter activates keyboard-focused Shell control"
		)
	FileAccess.open(out.path_join("observations.json"), FileAccess.WRITE).store_string(
		JSON.stringify(observations, "  ")
	)
	print("FOCUS206 failures=", failures)
	quit(1 if failures else 0)
