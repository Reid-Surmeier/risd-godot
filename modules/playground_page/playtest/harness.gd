## Playtest harness for the Playground desktop (ticket #62; the fill rule
## of ticket #63): builds the Shell
## with it in the Playground Tab and nothing in the other Tabs, then
## plays it the way a person does —
## real InputEventMouseButton / InputEventMouseMotion events through
## Input.parse_input_event on the tabs
## and the windows' title bars — resizes the window to the fill rule's
## page sizes, and reports what it
## did and what the interfaces said. The desktop is reached through
## ShellInterface.tenant_state only.
## Args: --out-dir=<path>. Writes numbered screenshots and report.json there.
extends "res://testing/harness_base.gd"

const Shell := preload("res://modules/shell/interface.gd")
const Page := preload("res://modules/playground_page/interface.gd")
const Data := preload("res://modules/collection_data/interface.gd")
const INDEX := 5


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


func _shell_state(shell: Control, label: String) -> Dictionary:
	var s: Dictionary = Shell.state(shell).value
	var tabs := []
	for t in s.tabs:
		tabs.append({"key": t.key, "page_visible": t.page_visible, "frozen": t.frozen, "tenant": t.tenant, "rect": _rect(t.rect)})
	var entry := {"t_ms": _ms(), "event": "shell", "label": label, "active": s.active, "count": s.count,
			"switching": s.switching, "bar_rect": _rect(s.bar_rect), "tabs": tabs, "window": [shell.size.x, shell.size.y]}
	_log.append(entry)
	return entry


func _page(shell: Control, label: String) -> Dictionary:
	var r: Dictionary = Shell.tenant_state(shell, "playground")
	var entry := {"t_ms": _ms(), "event": "page", "label": label, "ok": r.ok, "code": r.error.code if not r.ok else ""}
	if r.ok:
		var v: Dictionary = r.value
		var windows := []
		for w in v.windows:
			windows.append({"name": w.name, "rect": _rect(w.rect), "drag_height": w.drag_height, "order": w.order})
		var page: Control = shell.find_child("PlaygroundPage", true, false)
		entry.merge({"ticks": v.ticks, "inputs": v.inputs, "size": [v.size.x, v.size.y], "factor": v.factor,
				"desktop": [v.desktop.x, v.desktop.y], "margin": v.margin, "action": v.action, "windows": windows,
				"saved_ids": v.saved_ids, "storage_status": v.storage_status,
				"page_global": _rect(page.get_global_rect())})
	_log.append(entry)
	return entry


func _window(p: Dictionary, name: String) -> Dictionary:
	for w in p.windows:
		if w.name == name:
			return w
	return {}


func _resize(shell: Control, size: Vector2i, label: String, shot: String, out_dir: String) -> void:
	get_root().size = size
	await _frames(4)
	_shell_state(shell, label)
	_page(shell, label)
	await _shot(out_dir, shot)


func _initialize() -> void:
	var storage: Variant = Data.storage_adapter().value
	var data: Variant = Data.create({"search": func(_query: Dictionary, _done: Callable) -> Dictionary:
		return {"ok": false, "value": null, "error": {"code": "collection_data.unavailable", "detail": "unused"}},
		"load_saves": storage.load_saves, "save_if_absent": storage.save_if_absent, "now_ms": func() -> int: return 0}).value
	var factory := func(deps: Dictionary) -> Dictionary:
		var page_deps := deps.duplicate()
		page_deps.collection_data = data
		page_deps.image_fetch = func(_sha: String, _done: Callable) -> Dictionary:
			return {"ok": false, "value": null, "error": {"code": "collection_data.unavailable", "detail": "unused"}}
		return Page.create(page_deps)
	var shell: Control = Shell.create({"playground": factory}).value
	var out_dir := await _mount(shell, Vector2i(1920, 1080), "/tmp/playground_page-playtest")
	await create_timer(1.0).timeout  # the launch grow and fade of the Collection tab

	# 1. launch: Collection is active, this Tenant does not exist yet
	var st := _shell_state(shell, "launch")
	_page(shell, "launch")

	# 2. click the Playground tab: the desktop is created on first show,
	# every window at its reference place
	await _click(_center(shell, st.tabs[INDEX].rect), "playground tab")
	await create_timer(0.45).timeout
	_shell_state(shell, "shown")
	var a := _page(shell, "shown")
	await _frames(20)
	_page(shell, "shown-after-20-frames")
	await _shot(out_dir, "01-desktop.png")
	var page: Control = shell.find_child("PlaygroundPage", true, false)

	# 3. drag the trade window by its title bar: it moves by the drag and comes to the top
	var tr: Dictionary = _window(a, "trade")
	await _drag(page.get_global_transform() * Vector2(tr.rect.x + 120.0, tr.rect.y + 10.0), Vector2(-12, 10), 6,
			"drag trade by its title bar")
	await _frames(2)
	var moved := _page(shell, "trade-moved")
	await _shot(out_dir, "02-trade-moved.png")

	# 4. drag the options window by its body: nothing moves
	var op: Dictionary = _window(moved, "options")
	await _drag(page.get_global_transform() * Vector2(op.rect.x + 100.0, op.rect.y + op.rect.h * 0.7), Vector2(6, 4), 5,
			"drag options by its body")
	await _frames(2)
	_page(shell, "options-body-drag")

	# 5. click the Map tab: the Page is frozen; a drag and a key aimed at it change nothing
	await _click(_center(shell, st.tabs[0].rect), "map tab")
	await create_timer(0.45).timeout
	await _frames(3)
	_shell_state(shell, "hidden")
	_page(shell, "hidden")
	var ph: Dictionary = _window(moved, "phone")
	await _drag(page.get_global_transform() * Vector2(ph.rect.x + ph.rect.w / 2.0, ph.rect.y + 40.0), Vector2(-10, 6), 5,
			"drag the phone while hidden")
	await _key(KEY_SPACE, "space key while hidden")
	await _frames(20)
	_page(shell, "hidden-after-events")
	await _shot(out_dir, "03-hidden.png")

	# 6. back: it resumes with every window exactly as left
	await _click(_center(shell, st.tabs[INDEX].rect), "playground tab (again)")
	_page(shell, "resuming")  # the moment the fade starts: the counters pick up where they froze
	await create_timer(0.45).timeout
	await _frames(3)
	_shell_state(shell, "resumed")
	_page(shell, "resumed")
	await _frames(20)
	_page(shell, "resumed-after-20-frames")
	await _shot(out_dir, "04-resumed.png")

	# 7. the fill rule at two page sizes (1920x1000 and 1440x820 below the
	# bar), then the 1440x900 minimum
	await _resize(shell, Vector2i(1920, 1074), "page-1920x1000", "05-page-1920x1000.png", out_dir)
	await _resize(shell, Vector2i(1440, 876), "page-1440x820", "06-page-1440x820.png", out_dir)
	await _resize(shell, Vector2i(1440, 900), "window-1440x900", "07-window-1440x900.png", out_dir)
	await _resize(shell, Vector2i(1920, 1080), "restored", "08-restored.png", out_dir)

	_finish(out_dir)
