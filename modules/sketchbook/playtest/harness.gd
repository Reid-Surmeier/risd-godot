## Playtest harness for sketchbook as the Sketchbook Tenant: builds the Shell with it in the
## Sketchbook Tab and nothing in the other Tabs, then plays it the way a person does — real
## InputEventMouseButton / InputEventMouseMotion events through Input.parse_input_event — and
## reports what it did and what the Shell's probe said. The desktop is reached through the Shell
## only (state, tenant_state). Args: --out-dir=<path>. Writes numbered screenshots and report.json.
extends "res://testing/harness_base.gd"

const Shell := preload("res://modules/shell/interface.gd")
const Book := preload("res://modules/sketchbook/interface.gd")
const Data := preload("res://modules/collection_data/interface.gd")
const BAR_RATIO := 161.0 / 4180.0  # the strip's height per pixel of width
const WELL_A := 9    # row 0: a warm well
const WELL_B := 21   # row 1: a blue well
const TRAY := 1      # the top-middle mixing tray


func _move(pos: Vector2) -> void:
	var ev := InputEventMouseMotion.new()
	ev.position = pos
	ev.global_position = pos
	Input.parse_input_event(ev)
	await process_frame


## Move there, press, move in `steps` motions of `step` each, release: one drag as a mouse makes it.
func _drag(from: Vector2, step: Vector2, steps: int, what: String) -> void:
	await _move(from)
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


func _book(shell: Control, label: String) -> Dictionary:
	var r: Dictionary = Shell.tenant_state(shell, "sketchbook")
	var entry := {"t_ms": _ms(), "event": "book", "label": label, "ok": r.ok, "code": r.error.code if not r.ok else ""}
	if r.ok:
		var v: Dictionary = r.value
		var wells := []
		for w in v.wells:
			wells.append(_rect(w))
		var trays := []
		for t in v.trays:
			trays.append(_rect(t))
		entry.merge({"ticks": v.ticks, "inputs": v.inputs, "size": [v.size.x, v.size.y], "desktop_scale": v.desktop_scale,
				"desktop_logical": [v.desktop_logical.x, v.desktop_logical.y],
				"front_window": String(v.front_window), "dragging": v.dragging, "window_rect": _rect(v.window_rect),
				"reference_rect": _rect(v.reference_rect), "saved_ids": v.saved_ids, "selected_reference": v.selected_reference,
				"title_rect": _rect(v.title_rect), "page_rect": _rect(v.page_rect), "window_visible": v.window_visible,
				"controls": {"previous": _rect(v.controls.previous), "next": _rect(v.controls.next)},
				"spread": v.spread, "strokes": v.strokes, "turning": v.turning, "turn_progress": v.turn_progress,
				"last_turn_ms": v.last_turn_ms, "previous_disabled": v.previous_disabled, "drawing": v.drawing,
				"hovering": v.hovering, "last_stroke_points": v.last_stroke_points, "ink_color": v.ink_color,
				"last_stroke_color": v.last_stroke_color, "brush_cursor_visible": v.brush_cursor_visible,
				"static_update_mode": v.static_update_mode, "face_update_mode": v.face_update_mode,
				"paintbox_rect": _rect(v.paintbox_rect), "paintbox_title_rect": _rect(v.paintbox_title_rect),
				"palette_rect": _rect(v.palette_rect), "wells": wells, "trays": trays,
				"rest_rect": _rect(v.rest_rect), "parked_brush_rect": _rect(v.parked_brush_rect),
				"brush_parked": v.brush_parked, "brush_color": v.brush_color, "brush_tip_color": v.brush_tip_color,
				"palette_hovering": v.palette_hovering, "palette_cursor_visible": v.palette_cursor_visible,
				"mix_count": v.mix_count, "paint_pixels": v.paint_pixels, "smear_variant": v.smear_variant, "mixbox": v.mixbox})
	_log.append(entry)
	return entry


func _mid(r: Dictionary) -> Vector2:
	return Vector2(r.x + r.w / 2.0, r.y + r.h / 2.0)


## A point on the left page, a quarter in and halfway down.
func _page_point(b: Dictionary) -> Vector2:
	return Vector2(b.page_rect.x + b.page_rect.w * 0.25, b.page_rect.y + b.page_rect.h * 0.5)


## Wait for a paper turn to land (bounded), logging its end.
func _settle_turn(shell: Control, label: String) -> Dictionary:
	for i in 240:
		await process_frame
		if Shell.tenant_state(shell, "sketchbook").value.turning == "":
			break
	await _frames(2)
	return _book(shell, label)


## Size the window so the page above the strip is `page` (the strip's height follows the width).
func _page_size(shell: Control, page: Vector2i, label: String, shot: String, out_dir: String) -> void:
	get_root().size = Vector2i(page.x, roundi(page.y + page.x * BAR_RATIO))
	await _frames(6)
	_state(shell, label)
	_book(shell, label)
	await _shot(out_dir, shot)


func _initialize() -> void:
	var root := get_root()
	var storage: Variant = Data.storage_adapter().value
	var data: Variant = Data.create({"search": func(_query: Dictionary, _done: Callable) -> Dictionary:
		return {"ok": false, "value": null, "error": {"code": "collection_data.unavailable", "detail": "unused"}},
		"load_saves": storage.load_saves, "save_if_absent": storage.save_if_absent, "now_ms": func() -> int: return 0}).value
	var factory := func(deps: Dictionary) -> Dictionary:
		var page_deps := deps.duplicate()
		page_deps.collection_data = data
		page_deps.image_fetch = func(_sha: String, _done: Callable) -> Dictionary:
			return {"ok": false, "value": null, "error": {"code": "collection_data.unavailable", "detail": "unused"}}
		return Book.create(page_deps)
	var shell: Control = Shell.create({"sketchbook": factory}).value
	var out_dir := await _mount(shell, Vector2i(1920, 1080), "/tmp/sketchbook-playtest")
	await _key(KEY_F9, "disable squiggle for deterministic pixel checks")
	await create_timer(1.0).timeout  # the launch grow and fade of the Collection tab

	# 1. launch: Collection active, the Sketchbook Tenant not created yet; draw calls of a white page
	await _frames(3)
	_state(shell, "launch")
	_book(shell, "launch")

	# 2. click the Sketchbook tab: the desktop is created on first show — paintbox, rest, book, spread 1
	var st: Dictionary = _state(shell, "pre-book")
	await _click(_center(shell, st.tabs[1].rect), "sketchbook tab")
	await create_timer(0.45).timeout  # the page cross-fade
	await _move(Vector2(8, 8))  # the pointer on the white desktop: the brush rests
	await _frames(8)
	_state(shell, "book")
	_book(shell, "book-shown")
	await _shot(out_dir, "01-desktop.png")

	# 3. the fill rule at two page sizes, then back
	await _page_size(shell, Vector2i(1920, 1000), "fill-1920x1000", "02-fill-1920x1000.png", out_dir)
	await _page_size(shell, Vector2i(1440, 820), "fill-1440x820", "03-fill-1440x820.png", out_dir)
	root.size = Vector2i(1920, 1080)
	await _frames(6)
	var b := _book(shell, "fill-restored")

	# 4. load well A, smear it into the tray
	await _move(_mid(b.wells[WELL_A]))
	await _click(_mid(b.wells[WELL_A]), "well A")
	await _frames(2)
	_book(shell, "well-a")
	var tray: Dictionary = b.trays[TRAY]
	await _drag(Vector2(tray.x + tray.w * 0.15, tray.y + tray.h * 0.5), Vector2(tray.w * 0.7 / 14.0, 0), 14, "smear A across the tray")
	await _frames(2)
	_book(shell, "tray-a")
	await _shot(out_dir, "04-tray-a.png")

	# 5. load well B and drag it down through A: Mixbox mixes what the brush carries
	await _move(_mid(b.wells[WELL_B]))
	await _click(_mid(b.wells[WELL_B]), "well B")
	await _frames(2)
	_book(shell, "well-b")
	await _drag(Vector2(tray.x + tray.w * 0.5, tray.y + tray.h * 0.1), Vector2(0, tray.h * 0.8 / 12.0), 12, "drag B through A")
	await _frames(2)
	_book(shell, "mixed")
	await _shot(out_dir, "05-mixed.png")

	# 6. paint on the left page with the carried pigment
	await _drag(_page_point(b), Vector2(10, 4), 10, "paint on the page")
	await _frames(3)
	var dr := _book(shell, "painted")
	await _shot(out_dir, "06-painted.png")

	# 7. idle: the pointer on the white desktop, the brush goes back to the rest with its tip coloured
	await _move(Vector2(dr.size[0] - 12, 12))
	await _frames(6)
	_book(shell, "rested")
	await _shot(out_dir, "07-rested.png")

	# 8. the next arrow turns the page: the 520 ms perspective turn, then spread 2 with no paint on it
	await _move(_mid(dr.controls.next))
	await _click(_mid(dr.controls.next), "next-page button")
	await _frames(2)
	_book(shell, "turning")
	await _shot(out_dir, "08-turning.png")
	var t := await _settle_turn(shell, "turned")
	await _shot(out_dir, "09-turned.png")

	# 9. the previous arrow turns back: spread 1 with its stroke still there
	await _move(_mid(t.controls.previous))
	await _click(_mid(t.controls.previous), "previous-page button")
	var tb := await _settle_turn(shell, "turned-back")
	await _shot(out_dir, "10-turned-back.png")

	# 10. drag the book by its title bar: the window and its page move by the drag, the paint with them
	await _drag(_mid(tb.title_rect), Vector2(-20, -6), 5, "drag the window by its title bar")
	await _move(Vector2(tb.size[0] - 12, 12))
	await _frames(3)
	var e := _book(shell, "before-hidden")
	_state(shell, "before-hidden")
	await _shot(out_dir, "11-before-hidden.png")

	# 11. click the Map tab: the Sketchbook page is frozen — no frames, no input, SubViewports quiet —
	#     and a drag across the hidden page draws nothing, the hidden arrow turns nothing
	await _click(_center(shell, st.tabs[0].rect), "map tab")
	await create_timer(0.45).timeout  # the page cross-fade
	await _frames(3)
	_state(shell, "map")
	_book(shell, "book-hidden")
	await _drag(_page_point(e), Vector2(8, 3), 8, "drag inside the page while hidden")
	await _move(_mid(e.controls.next))
	await _click(_mid(e.controls.next), "next-page button while hidden")
	await _frames(20)
	_book(shell, "book-hidden-after-events")
	_state(shell, "map-after-20-frames")
	await _shot(out_dir, "12-hidden.png")

	# 12. back to the Sketchbook: it resumes with the paint, the spread and the window exactly as left
	await _click(_center(shell, st.tabs[1].rect), "sketchbook tab (again)")
	await _frames(3)
	_book(shell, "book-resumed")  # it runs again from the moment its fade-in starts
	await create_timer(0.45).timeout
	await _move(Vector2(tb.size[0] - 12, 12))
	_state(shell, "book-again")
	await _frames(20)
	_book(shell, "book-resumed-after-20-frames")
	await _shot(out_dir, "13-resumed.png")

	# 13. resize the window to the 1440x900 minimum: the desktop re-fits, the moved book keeps its move
	root.size = Vector2i(1440, 900)
	await _frames(6)
	_state(shell, "resized")
	_book(shell, "resized")
	await _shot(out_dir, "14-resized.png")
	root.size = Vector2i(1920, 1080)
	await _frames(6)
	_state(shell, "restored")
	_book(shell, "restored")
	await _shot(out_dir, "15-restored.png")

	_finish(out_dir)
