## The base every playtest harness extends: the helpers that drive the game the way a person
## does (real InputEventMouseButton / InputEventKey events through Input.parse_input_event),
## screenshot the root, and keep the timed log that report.json is written from. A harness adds
## its own probes (the states its module's interface reports) and its _initialize.
## Args every harness takes: --out-dir=<path>.
extends SceneTree

var _log: Array = []
var _t0 := 0
var _viewport := Vector2i.ZERO


func _arg(name: String, default_value: String) -> String:
	for a in OS.get_cmdline_user_args():
		if a.begins_with(name + "="):
			return a.substr(name.length() + 1)
	return default_value


func _ms() -> int:
	return Time.get_ticks_msec() - _t0


## Size the root, mount the node under test, let it settle, start the clock. Returns the out dir.
func _mount(node: Node, size: Vector2i, default_out_dir: String) -> String:
	var out_dir := _arg("--out-dir", default_out_dir)
	DirAccess.make_dir_recursive_absolute(out_dir)
	_viewport = size
	get_root().size = size
	get_root().add_child(node)
	await _frames(3)
	_t0 = Time.get_ticks_msec()
	return out_dir


func _frames(n: int) -> void:
	for i in n:
		await process_frame


func _shot(out_dir: String, name: String) -> void:
	await process_frame
	get_root().get_texture().get_image().save_png(out_dir.path_join(name))
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


func _key(keycode: Key, what: String) -> void:
	for pressed in [true, false]:
		var ev := InputEventKey.new()
		ev.keycode = keycode
		ev.pressed = pressed
		Input.parse_input_event(ev)
		await process_frame
	_log.append(
		{"t_ms": _ms(), "event": "key", "what": what, "keycode": OS.get_keycode_string(keycode)}
	)


func _rect(r: Rect2) -> Dictionary:
	return {"x": r.position.x, "y": r.position.y, "w": r.size.x, "h": r.size.y}


## The global centre of a rect given in `node`'s pixels, as a Rect2 or as _rect's {x, y, w, h}.
func _center(node: Control, r) -> Vector2:
	var rect: Rect2 = r if r is Rect2 else Rect2(r.x, r.y, r.w, r.h)
	return node.get_global_transform() * (rect.position + rect.size / 2.0)


func _finish(out_dir: String) -> void:
	var fh := FileAccess.open(out_dir.path_join("report.json"), FileAccess.WRITE)
	fh.store_string(JSON.stringify({"viewport": [_viewport.x, _viewport.y], "log": _log}, "  "))
	fh.close()
	quit(0)
