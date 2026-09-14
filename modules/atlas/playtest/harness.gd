## Playtest harness for the atlas as the Map Tenant: plays the game's main scene the way a person
## does and reports what it did and what the Shell's probe said. Real InputEventMouseButton /
## InputEventMouseMotion events through Input.parse_input_event for every gesture; the interface is
## called only for what the Shell's caller would call (state, tenant_state). The atlas is reached
## through the Shell only. Args: --out-dir=<path>. Writes numbered screenshots and report.json.
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


func _button(pos: Vector2, index: int, pressed: bool) -> void:
	var ev := InputEventMouseButton.new()
	ev.button_index = index
	ev.pressed = pressed
	ev.position = pos
	ev.global_position = pos
	Input.parse_input_event(ev)
	await process_frame


func _click(pos: Vector2, what: String) -> void:
	for pressed in [true, false]:
		await _button(pos, MOUSE_BUTTON_LEFT, pressed)
	_log.append({"t_ms": _ms(), "event": "click", "what": what, "x": pos.x, "y": pos.y})


func _wheel(pos: Vector2, up: bool, count: int, what: String) -> void:
	for i in count:
		for pressed in [true, false]:
			await _button(pos, MOUSE_BUTTON_WHEEL_UP if up else MOUSE_BUTTON_WHEEL_DOWN, pressed)
	_log.append({"t_ms": _ms(), "event": "wheel", "what": what, "x": pos.x, "y": pos.y, "up": up, "count": count})


## Press, move in `steps` motions of `step` each, release: one drag as a mouse makes it.
func _drag(from: Vector2, step: Vector2, steps: int, what: String) -> void:
	await _button(from, MOUSE_BUTTON_LEFT, true)
	var pos := from
	for i in steps:
		pos += step
		var ev := InputEventMouseMotion.new()
		ev.position = pos
		ev.global_position = pos
		ev.relative = step
		ev.button_mask = MOUSE_BUTTON_MASK_LEFT
		Input.parse_input_event(ev)
		await process_frame
	await _button(pos, MOUSE_BUTTON_LEFT, false)
	_log.append({"t_ms": _ms(), "event": "drag", "what": what, "from": [from.x, from.y], "to": [pos.x, pos.y],
			"relative_total": [step.x * steps, step.y * steps], "steps": steps})


func _rect(r: Rect2) -> Dictionary:
	return {"x": r.position.x, "y": r.position.y, "w": r.size.x, "h": r.size.y}


func _draw_calls() -> int:
	return RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)


func _state(shell: Control, label: String) -> Dictionary:
	var s: Dictionary = Shell.state(shell).value
	var tabs := []
	for t in s.tabs:
		tabs.append({"key": t.key, "page_visible": t.page_visible, "frozen": t.frozen, "tenant": t.tenant, "rect": _rect(t.rect)})
	var entry := {"t_ms": _ms(), "event": "state", "label": label, "count": s.count, "active": s.active, "tabs": tabs,
			"window": [shell.size.x, shell.size.y], "draw_calls": _draw_calls()}
	_log.append(entry)
	return entry


func _atlas(shell: Control, label: String) -> Dictionary:
	var r: Dictionary = Shell.tenant_state(shell, "map")
	var entry := {"t_ms": _ms(), "event": "atlas", "label": label, "ok": r.ok, "code": r.error.code if not r.ok else ""}
	if r.ok:
		var v: Dictionary = r.value
		entry.merge({"ticks": v.ticks, "inputs": v.inputs, "size": [v.size.x, v.size.y], "frame": _rect(v.frame), "frame_global": _rect(v.frame_global),
				"map_rect": _rect(v.map_rect), "chrome_scale": v.chrome_scale, "locked": v.locked, "collapsed": v.collapsed,
				"action": v.action, "viewport_update_mode": v.viewport_update_mode, "mode": v.mode, "region": v.region,
				"zoom": v.zoom, "zoom_ratio": v.zoom_ratio, "zoom_min": v.zoom_min, "zoom_max": v.zoom_max,
				"position": v.position, "viewport": v.viewport, "visible_cities": v.visible_cities,
				"visible_close_cities": v.visible_close_cities, "visible_labels": v.visible_labels,
				"terrain_tiles": v.terrain_tiles, "vertical_pan_locked": v.vertical_pan_locked})
	_log.append(entry)
	return entry


func _center(shell: Control, r: Dictionary) -> Vector2:
	return shell.get_global_transform() * Vector2(r.x + r.w / 2.0, r.y + r.h / 2.0)


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _initialize() -> void:
	var out_dir := _arg("--out-dir", "/tmp/atlas-playtest")
	DirAccess.make_dir_recursive_absolute(out_dir)
	var root := get_root()
	root.size = Vector2i(1920, 1080)
	var demo: Control = load("res://modules/shell/demo.tscn").instantiate()
	root.add_child(demo)
	await _frames(3)
	var shell: Control = demo.get_node("Shell")
	_t0 = Time.get_ticks_msec()

	# 1. launch: Collection active, the Map Tenant not created yet; draw calls of a white page
	await _frames(3)
	_state(shell, "launch")
	_atlas(shell, "launch")

	# 2. click the Map tab: the atlas is created on first show, fills the page and draws
	var st: Dictionary = _state(shell, "pre-map")
	await _click(_center(shell, st.tabs[0].rect), "map tab")
	await _frames(8)
	_state(shell, "map")
	var a := _atlas(shell, "map-shown")
	await _shot(root, out_dir, "01-map.png")

	# 3. wheel up three times at the map's centre: zoom in around it
	var map_center := Vector2(a.map_rect.x + a.map_rect.w / 2.0, a.map_rect.y + a.map_rect.h / 2.0)
	await _wheel(map_center, true, 3, "wheel up x3 at map centre")
	await _frames(3)
	var b := _atlas(shell, "zoomed")
	await _shot(root, out_dir, "02-zoomed.png")

	# 4. drag-pan inside the map: the camera moves against the drag, divided by the zoom
	await _drag(map_center, Vector2(-40, -30), 4, "drag-pan inside the map")
	await _frames(3)
	var c := _atlas(shell, "panned")
	await _shot(root, out_dir, "03-panned.png")

	# 5. drag the map window by its title bar: the frame moves by the drag
	var title := Vector2(c.frame_global.x + c.frame_global.w / 2.0, c.frame_global.y + 60.0 * c.chrome_scale)
	await _drag(title, Vector2(14, -3), 5, "drag the map window by its title bar")
	await _frames(3)
	var d := _atlas(shell, "window-moved")
	await _shot(root, out_dir, "04-window-moved.png")
	_state(shell, "window-moved")

	# 6. click the Sketchbook tab: the Map page is frozen — no frames, no input, no rendering —
	#    and events aimed at where the map was change nothing
	await _click(_center(shell, st.tabs[1].rect), "sketchbook tab")
	await _frames(3)
	_state(shell, "sketchbook")
	var e := _atlas(shell, "map-hidden")
	await _wheel(map_center, true, 3, "wheel up x3 at the map's centre while hidden")
	await _drag(map_center, Vector2(-40, -30), 4, "drag where the map was while hidden")
	await _frames(20)
	var f := _atlas(shell, "map-hidden-after-events")
	_state(shell, "sketchbook-after-20-frames")
	await _shot(root, out_dir, "05-hidden.png")

	# 7. back to Map: it resumes with zoom, camera and window exactly as left
	await _click(_center(shell, st.tabs[0].rect), "map tab (again)")
	await _frames(3)
	_state(shell, "map-again")
	var g := _atlas(shell, "map-resumed")
	await _frames(20)
	_atlas(shell, "map-resumed-after-20-frames")
	await _shot(root, out_dir, "06-resumed.png")

	# 8. resize the window to the 1440x900 minimum: the tenant fills the smaller page and re-fits its window
	root.size = Vector2i(1440, 900)
	await _frames(4)
	_state(shell, "resized")
	_atlas(shell, "resized")
	await _shot(root, out_dir, "07-resized.png")
	root.size = Vector2i(1920, 1080)
	await _frames(4)
	_state(shell, "restored")
	_atlas(shell, "restored")
	await _shot(root, out_dir, "08-restored.png")

	var fh := FileAccess.open(out_dir.path_join("report.json"), FileAccess.WRITE)
	fh.store_string(JSON.stringify({"viewport": [1920, 1080], "log": _log}, "  "))
	fh.close()
	quit(0)
