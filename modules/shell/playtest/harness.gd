## Playtest harness for the shell: plays the game's main scene the way a person does and reports
## what it did, what happened, and whether the interface responded. Real InputEventMouseButton
## and InputEventKey events through Input.parse_input_event — never a direct call into the strip
## for the gestures; the interface is called only for what the Shell's caller would call.
## Args: --out-dir=<path>. Writes numbered screenshots and report.json there.
extends SceneTree

const Shell := preload("res://modules/shell/interface.gd")

var _log: Array = []
var _t0 := 0


func _arg(name: String, default_value: String) -> String:
	for a in OS.get_cmdline_user_args():
		if a.begins_with(name + "="):
			return a.substr(name.length() + 1)
	return default_value


func _ms() -> int:
	return Time.get_ticks_msec() - _t0


func _shot(root: Window, out_dir: String, name: String) -> void:
	await process_frame
	root.get_texture().get_image().save_png(out_dir.path_join(name))
	_log.append({"t_ms": _ms(), "event": "screenshot", "file": name})


func _click(pos: Vector2, what: String) -> void:
	for pressed in [true, false]:
		var ev := InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = pressed
		ev.position = pos
		ev.global_position = pos
		Input.parse_input_event(ev)
		await process_frame
	_log.append({"t_ms": _ms(), "event": "click", "what": what, "x": pos.x, "y": pos.y})


func _key(what: String) -> void:
	for pressed in [true, false]:
		var ev := InputEventKey.new()
		ev.keycode = KEY_SPACE
		ev.pressed = pressed
		Input.parse_input_event(ev)
		await process_frame
	_log.append({"t_ms": _ms(), "event": "key", "what": what})


func _rect(r: Rect2) -> Dictionary:
	return {"x": r.position.x, "y": r.position.y, "w": r.size.x, "h": r.size.y}


func _state(shell: Control, label: String) -> Dictionary:
	var s: Dictionary = Shell.state(shell).value
	var tabs := []
	for t in s.tabs:
		tabs.append({"key": t.key, "label": t.label, "fixed": t.fixed, "page_visible": t.page_visible,
				"frozen": t.frozen, "tenant": t.tenant, "rect": _rect(t.rect), "close_rect": _rect(t.close_rect)})
	var entry := {"t_ms": _ms(), "event": "state", "label": label, "count": s.count, "active": s.active,
			"opening": s.opening, "fixed_count": s.fixed_count, "stub_rect": _rect(s.stub_rect), "tabs": tabs,
			"window": [shell.size.x, shell.size.y]}
	_log.append(entry)
	return entry


func _tenant(shell: Control, key: String, label: String) -> Dictionary:
	var r: Dictionary = Shell.tenant_state(shell, key)
	var entry := {"t_ms": _ms(), "event": "tenant", "label": label, "key": key, "ok": r.ok,
			"code": r.error.code if not r.ok else "",
			"ticks": r.value.ticks if r.ok else -1, "inputs": r.value.inputs if r.ok else -1,
			"size": [r.value.size.x, r.value.size.y] if r.ok else [0, 0]}
	_log.append(entry)
	return entry


func _center(shell: Control, r: Dictionary) -> Vector2:
	return shell.get_global_transform() * Vector2(r.x + r.w / 2.0, r.y + r.h / 2.0)


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _initialize() -> void:
	var out_dir := _arg("--out-dir", "/tmp/shell-playtest")
	DirAccess.make_dir_recursive_absolute(out_dir)
	var root := get_root()
	root.size = Vector2i(1920, 1080)
	var demo: Control = load("res://modules/shell/demo.tscn").instantiate()
	root.add_child(demo)
	await _frames(3)
	var shell: Control = demo.get_node("Shell")
	_t0 = Time.get_ticks_msec()

	# 1. launch: six fixed tabs in order, Collection active and its tenant created, the rest waiting
	_state(shell, "launch")
	for key in Shell.FIXED_TABS:
		_tenant(shell, key, "launch")
	await _shot(root, out_dir, "01-launch.png")

	# 2. click the Map tab: its tenant is created on first show and runs
	var st: Dictionary = _state(shell, "pre-map")
	await _click(_center(shell, st.tabs[0].rect), "map tab")
	_state(shell, "map")
	var a := _tenant(shell, "map", "map-shown")
	await _frames(20)
	var b := _tenant(shell, "map", "map-after-20-frames")
	await _shot(root, out_dir, "02-map.png")

	# 3. click the Sketchbook tab: the Map page is frozen (its _process and input stop), Sketchbook runs
	await _click(_center(shell, st.tabs[1].rect), "sketchbook tab")
	_state(shell, "sketchbook")
	var c := _tenant(shell, "map", "map-hidden")
	var sk0 := _tenant(shell, "sketchbook", "sketchbook-shown")
	await _key("space key while map is hidden")
	await _frames(20)
	var d := _tenant(shell, "map", "map-hidden-after-20-frames")
	var sk1 := _tenant(shell, "sketchbook", "sketchbook-after-20-frames")
	await _shot(root, out_dir, "03-sketchbook.png")

	# 4. back to Map: it resumes with its count intact
	await _click(_center(shell, st.tabs[0].rect), "map tab (again)")
	_state(shell, "map-again")
	var e := _tenant(shell, "map", "map-resumed")
	await _frames(20)
	var f := _tenant(shell, "map", "map-resumed-after-20-frames")

	# 5. a fixed tab does not close: click where its close button would be, then ask the interface
	var r: Dictionary = st.tabs[0].rect
	var scale: float = r.h / 123.0
	await _click(_center(shell, {"x": r.x + r.w - (80 + 22) * scale, "y": r.y + (24 + 22) * scale,
			"w": 22 * scale, "h": 22 * scale}), "where the close button of the map tab would be")
	await create_timer(0.9).timeout
	var refused: Dictionary = Shell.close_tab(shell, 0)
	_log.append({"t_ms": _ms(), "event": "close_fixed", "ok": refused.ok,
			"code": refused.error.code if not refused.ok else ""})
	_state(shell, "fixed-kept")
	await _shot(root, out_dir, "04-fixed-kept.png")

	# 6. the stub still opens a Blank Page with a close button; closing it lands on the Phone tab,
	#    which has no tenant yet and shows a plain white page
	await _click(_center(shell, st.stub_rect), "new-tab stub")
	await create_timer(1.8).timeout
	_state(shell, "stub-blank")
	await _shot(root, out_dir, "05-stub-blank.png")
	var sb: Dictionary = _state(shell, "stub-blank")
	await _click(_center(shell, sb.tabs[sb.count - 1].close_rect), "close button of the blank tab")
	await create_timer(0.9).timeout
	_state(shell, "phone")
	_tenant(shell, "phone", "phone-shown")
	await _shot(root, out_dir, "06-phone.png")

	# 7. resize the window to the 1440x900 minimum: the bar re-fits, the visible tenant fills its page
	await _click(_center(shell, st.tabs[4].rect), "collection tab")
	root.size = Vector2i(1440, 900)
	await _frames(3)
	_state(shell, "resized")
	_tenant(shell, "collection", "resized")
	await _shot(root, out_dir, "07-resized.png")
	root.size = Vector2i(1920, 1080)
	await _frames(3)
	_state(shell, "restored")
	_tenant(shell, "collection", "restored")
	await _shot(root, out_dir, "08-restored.png")

	var fh := FileAccess.open(out_dir.path_join("report.json"), FileAccess.WRITE)
	fh.store_string(JSON.stringify({"viewport": [1920, 1080], "log": _log}, "  "))
	fh.close()
	quit(0)
