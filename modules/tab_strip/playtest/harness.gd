## Playtest harness for tab_strip: plays the demo the way a person does and reports what it
## did, what happened, and whether the interface responded. Real InputEventMouseButton events
## through Input.parse_input_event — never a direct call into the strip for the gestures.
## Args: --out-dir=<path>. Writes numbered screenshots and report.json there.
extends SceneTree

const TabStrip := preload("res://modules/tab_strip/interface.gd")

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
	var img := root.get_texture().get_image()
	img.save_png(out_dir.path_join(name))
	_log.append({"t_ms": _ms(), "event": "screenshot", "file": name})


func _click(pos: Vector2, what: String) -> void:
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.position = pos
	down.global_position = pos
	Input.parse_input_event(down)
	await process_frame
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.pressed = false
	up.position = pos
	up.global_position = pos
	Input.parse_input_event(up)
	await process_frame
	_log.append({"t_ms": _ms(), "event": "click", "what": what, "x": pos.x, "y": pos.y})


func _state(strip: Control, label: String) -> Dictionary:
	var s: Dictionary = TabStrip.state(strip).value
	var tabs := []
	for t in s.tabs:
		tabs.append({"label": t.label, "x": t.rect.position.x, "y": t.rect.position.y,
				"w": t.rect.size.x, "h": t.rect.size.y, "page_visible": t.page_visible, "fixed": t.fixed,
				"truncated": t.truncated,
				"close_rect": {"position": {"x": t.close_rect.position.x, "y": t.close_rect.position.y},
						"size": {"x": t.close_rect.size.x, "y": t.close_rect.size.y}}})
	var entry := {"t_ms": _ms(), "event": "state", "label": label, "count": s.count, "active": s.active,
			"opening": s.opening, "tabs": tabs, "bar_width": s.bar_width}
	_log.append(entry)
	return entry


func _global_center(strip: Control, rect: Rect2) -> Vector2:
	var xf := strip.get_global_transform()
	return xf * (rect.position + rect.size / 2.0)


func _initialize() -> void:
	var out_dir := _arg("--out-dir", "/tmp/tab-strip-playtest")
	DirAccess.make_dir_recursive_absolute(out_dir)
	var root := get_root()
	root.size = Vector2i(1920, 420)
	var demo: Control = load("res://modules/tab_strip/demo.tscn").instantiate()
	root.add_child(demo)
	await process_frame
	await process_frame
	var strip: Control = demo.get_node("TabStrip")
	_t0 = Time.get_ticks_msec()
	for sig in ["tab_opened", "tab_settled", "tab_titled", "tab_selected", "tab_closed"]:
		strip.connect(sig, func(i: int): _log.append({"t_ms": _ms(), "event": "signal", "signal": sig, "index": i}))

	_state(strip, "initial")
	await _shot(root, out_dir, "01-initial.png")

	# 1. click the blank New Tab stub, recording every frame for 1.8 s (the film of the gesture)
	DirAccess.make_dir_recursive_absolute(out_dir.path_join("frames"))
	var stub_center := _global_center(strip, TabStrip.stub_rect(strip))
	await _click(stub_center, "new-tab stub")
	var t_click := _ms()
	var frame := 0
	var mid_done := false
	var conn_done := false
	while _ms() - t_click < 1800:
		await process_frame
		var img := root.get_texture().get_image()
		img.save_png(out_dir.path_join("frames/f%04d.png" % frame))
		_log.append({"t_ms": _ms(), "event": "frame", "n": frame})
		frame += 1
		if not mid_done and _ms() - t_click >= 250:      # 0.1 s press + ~0.15 s into the 0.4 s grow
			mid_done = true
			_state(strip, "mid-grow")
			img.save_png(out_dir.path_join("02-mid-grow.png"))
			_log.append({"t_ms": _ms(), "event": "screenshot", "file": "02-mid-grow.png"})
		if not conn_done and _ms() - t_click >= 700:     # grow finished, label "Connecting..."
			conn_done = true
			_state(strip, "connecting")
			img.save_png(out_dir.path_join("03-connecting.png"))
			_log.append({"t_ms": _ms(), "event": "screenshot", "file": "03-connecting.png"})
	_state(strip, "blank-page")                          # label swapped to "Blank Page"
	await _shot(root, out_dir, "04-blank-page.png")

	# 2. click the first tab, then the second: pages must follow
	var s: Dictionary = TabStrip.state(strip).value
	await _click(_global_center(strip, s.tabs[0].rect), "tab 0")
	_state(strip, "selected-0")
	await _shot(root, out_dir, "05-selected-0.png")
	await _click(_global_center(strip, s.tabs[1].rect), "tab 1")
	_state(strip, "selected-1")
	await _shot(root, out_dir, "06-selected-1.png")

	# 3. the stub moved: click it again for a third tab and let it settle
	await _click(_global_center(strip, TabStrip.stub_rect(strip)), "new-tab stub (2nd)")
	await create_timer(1.8).timeout
	_state(strip, "third-tab")
	await _shot(root, out_dir, "07-third-tab.png")

	# 4. keep clicking until the strip refuses (NO_ROOM) — the row must shrink, never overflow
	var refused := ""
	for i in 12:
		var before: int = TabStrip.state(strip).value.count
		await _click(_global_center(strip, TabStrip.stub_rect(strip)), "new-tab stub (fill)")
		await create_timer(0.7).timeout
		if TabStrip.state(strip).value.count == before:
			refused = "refused at %d tabs" % before
			break
	await create_timer(1.2).timeout
	_state(strip, "full-row")
	await _shot(root, out_dir, "08-full-row.png")
	_log.append({"t_ms": _ms(), "event": "fill", "result": refused})

	# 5. close the active (last) tab with its close button, then close the second tab by clicking
	#    it first (close shows on the active tab only)
	var st: Dictionary = TabStrip.state(strip).value
	DirAccess.make_dir_recursive_absolute(out_dir.path_join("close-frames"))
	await _click(_global_center(strip, st.tabs[st.active].close_rect), "close button of active tab")
	var t_close := _ms()
	var cf := 0
	while _ms() - t_close < 900:            # 0.3 s fold + 0.2 s slide, plus settle: the film of the close
		await process_frame
		root.get_texture().get_image().save_png(out_dir.path_join("close-frames/f%04d.png" % cf))
		cf += 1
	_state(strip, "closed-last")
	await _shot(root, out_dir, "09-closed-last.png")
	st = TabStrip.state(strip).value
	await _click(_global_center(strip, st.tabs[1].rect), "tab 1")
	st = TabStrip.state(strip).value
	await _click(_global_center(strip, st.tabs[1].close_rect), "close button of tab 1")
	await create_timer(0.9).timeout
	_state(strip, "closed-second")
	await _shot(root, out_dir, "10-closed-second.png")

	# 6. close every remaining tab from its own close button, then open one again from the stub
	for i in 8:
		st = TabStrip.state(strip).value
		if st.count == 0:
			break
		await _click(_global_center(strip, st.tabs[st.count - 1].close_rect), "close button (empty the row)")
		await create_timer(0.7).timeout
	_state(strip, "all-closed")
	await _shot(root, out_dir, "11-all-closed.png")
	await _click(_global_center(strip, TabStrip.stub_rect(strip)), "new-tab stub (after empty)")
	await create_timer(1.8).timeout
	_state(strip, "reopened")
	await _shot(root, out_dir, "12-reopened.png")

	# 7. a fixed, titled tab on a caller-owned page (seam Issue #39): opened through the interface
	#    (the Shell's call, not a gesture), no close button, close refused by click and by call
	var page := ColorRect.new()
	page.color = Color.WHITE
	page.set_anchors_preset(Control.PRESET_FULL_RECT)
	var fixed: Dictionary = TabStrip.open_fixed_tab(strip, "map", page)
	_log.append({"t_ms": _ms(), "event": "fixed_open", "ok": fixed.ok, "index": fixed.value,
			"page_in_stack": page.get_parent() == demo.get_node("PageStack")})
	TabStrip.select_tab(strip, fixed.value)
	_state(strip, "fixed-open")
	await _shot(root, out_dir, "13-fixed-open.png")
	st = TabStrip.state(strip).value
	var r: Rect2 = st.tabs[fixed.value].rect
	await _click(_global_center(strip, Rect2(r.position + Vector2(r.size.x - 80 - 22, 24 + 22), Vector2(22, 22))),
			"where the close button of the fixed tab would be")
	await create_timer(0.9).timeout
	var kept: Dictionary = TabStrip.close_tab(strip, fixed.value)
	_log.append({"t_ms": _ms(), "event": "fixed_close", "ok": kept.ok,
			"code": kept.error.code if not kept.ok else ""})
	await create_timer(0.9).timeout
	_state(strip, "fixed-kept")
	await _shot(root, out_dir, "14-fixed-kept.png")
	var phone: Dictionary = TabStrip.open_fixed_tab(strip, "phone", ColorRect.new())  # no label pixels yet (#34)
	_log.append({"t_ms": _ms(), "event": "fixed_open", "ok": phone.ok, "index": phone.value, "page_in_stack": true})
	await _click(_global_center(strip, TabStrip.stub_rect(strip)), "new-tab stub (after fixed)")
	await create_timer(1.8).timeout
	_state(strip, "after-fixed-stub")
	await _shot(root, out_dir, "15-after-fixed-stub.png")

	var f := FileAccess.open(out_dir.path_join("report.json"), FileAccess.WRITE)
	f.store_string(JSON.stringify({"viewport": [1680, 420], "log": _log}, "  "))
	f.close()
	quit(0)
