## Evidence for the hover-glow prototype: the Shell with the Sketchbook Tenant, a real pointer moved over
## a page button, a tldraw control and a tab, a screenshot before and during each hover.
## Args: --out-dir=<path>.
extends "res://testing/harness_base.gd"

const Shell := preload("res://modules/shell/interface.gd")
const Book := preload("res://modules/sketchbook/interface.gd")
const Data := preload("res://modules/collection_data/interface.gd")


func _move(pos: Vector2) -> void:
	var ev := InputEventMouseMotion.new()
	ev.position = pos
	ev.global_position = pos
	Input.parse_input_event(ev)
	await process_frame


func _centre_of(c: Control) -> Vector2:
	return c.get_global_rect().get_center()


func _hover(out_dir: String, target: Control, name: String) -> void:
	await _move(Vector2(6, 6))
	await create_timer(0.6).timeout
	await _shot(out_dir, name + "-before.png")
	await _move(_centre_of(target))
	await create_timer(0.35).timeout
	await _shot(out_dir, name + "-hover.png")
	_log.append({"event": "hover", "what": name, "rect": str(target.get_global_rect()),
			"glow_visible": (target.get_meta("hover_glow") as Control).visible})


func _initialize() -> void:
	var storage: Variant = Data.storage_adapter().value
	var data: Variant = Data.create({"search": func(_q: Dictionary, _d: Callable) -> Dictionary:
		return {"ok": false, "value": null, "error": {"code": "collection_data.unavailable", "detail": "unused"}},
		"load_saves": storage.load_saves, "save_if_absent": storage.save_if_absent, "now_ms": func() -> int: return 0}).value
	var factory := func(deps: Dictionary) -> Dictionary:
		var page_deps := deps.duplicate()
		page_deps.collection_data = data
		page_deps.image_fetch = func(_sha: String, _done: Callable) -> Dictionary:
			return {"ok": false, "value": null, "error": {"code": "collection_data.unavailable", "detail": "unused"}}
		return Book.create(page_deps)
	var shell: Control = Shell.create({"sketchbook": factory}).value
	var out_dir := await _mount(shell, Vector2i(1920, 1080), "/tmp/hover-glow")
	await create_timer(1.0).timeout
	var st: Dictionary = Shell.state(shell).value
	await _click(st.tabs[1].rect.get_center(), "sketchbook tab")
	await create_timer(0.6).timeout
	var next: Control = shell.find_child("next-page", true, false)
	await _hover(out_dir, next, "01-page-arrow")
	var buttons := shell.find_children("*", "Button", true, false).filter(func(b): return b.is_visible_in_tree() and b.text != "")
	if not buttons.is_empty():
		await _hover(out_dir, buttons[0], "02-control-button")
	var tab: Control = shell.find_child("TabStrip", true, false).get_child(0).get_parent().find_children("Tab*", "", false, false)[3]
	await _hover(out_dir, tab, "03-tab")
	var f := FileAccess.open(out_dir.path_join("report.json"), FileAccess.WRITE)
	f.store_string(JSON.stringify(_log, "  "))
	quit()
