## Playtest harness for sketchbook as the Sketchbook Tenant: builds the Shell with it in the
## Sketchbook Tab and nothing in the other Tabs, then plays it the way a person does — real
## InputEventMouseButton / InputEventMouseMotion events through Input.parse_input_event — and
## reports what it did and what the Shell's probe said. The book is reached through the Shell
## only (state, tenant_state). Args: --out-dir=<path>. Writes numbered screenshots and report.json.
extends "res://testing/harness_base.gd"

const Shell := preload("res://modules/shell/interface.gd")
const Book := preload("res://modules/sketchbook/interface.gd")


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
		entry.merge({"ticks": v.ticks, "inputs": v.inputs, "size": [v.size.x, v.size.y], "desktop_scale": v.desktop_scale,
				"front_window": String(v.front_window), "dragging": v.dragging, "window_rect": _rect(v.window_rect),
				"title_rect": _rect(v.title_rect), "page_rect": _rect(v.page_rect), "window_visible": v.window_visible,
				"controls": {"previous": _rect(v.controls.previous), "next": _rect(v.controls.next)},
				"spread": v.spread, "strokes": v.strokes, "turning": v.turning, "turn_progress": v.turn_progress,
				"last_turn_ms": v.last_turn_ms, "previous_disabled": v.previous_disabled, "drawing": v.drawing,
				"hovering": v.hovering, "last_stroke_points": v.last_stroke_points, "ink_color": v.ink_color,
				"static_update_mode": v.static_update_mode, "face_update_mode": v.face_update_mode})
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


func _initialize() -> void:
	var root := get_root()
	var shell: Control = Shell.create({"sketchbook": Book}).value
	var out_dir := await _mount(shell, Vector2i(1920, 1080), "/tmp/sketchbook-playtest")

	# 1. launch: Collection active, the Sketchbook Tenant not created yet; draw calls of a white page
	await _frames(3)
	_state(shell, "launch")
	_book(shell, "launch")

	# 2. click the Sketchbook tab: the desktop is created on first show with the book on it, spread 1, no ink
	var st: Dictionary = _state(shell, "pre-book")
	await _click(_center(shell, st.tabs[1].rect), "sketchbook tab")
	await _frames(8)
	_state(shell, "book")
	var b := _book(shell, "book-shown")
	await _shot(out_dir, "01-book.png")

	# 3. a real drag across the left page draws one stroke: every sample reaches it, the ink is on screen
	await _drag(_page_point(b), Vector2(8, 3), 8, "drag inside the page")
	await _frames(3)
	var d := _book(shell, "drawn")
	await _shot(out_dir, "02-drawn.png")

	# 4. the next arrow turns the page: the 520 ms perspective turn, then spread 2 with no ink on it
	await _move(_mid(d.controls.next))
	await _click(_mid(d.controls.next), "next-page button")
	await _frames(2)
	_book(shell, "turning")
	await _shot(out_dir, "03-turning.png")
	var t := await _settle_turn(shell, "turned")
	await _shot(out_dir, "04-turned.png")

	# 5. the previous arrow turns back: spread 1 with its stroke still there
	await _move(_mid(t.controls.previous))
	await _click(_mid(t.controls.previous), "previous-page button")
	var tb := await _settle_turn(shell, "turned-back")
	await _shot(out_dir, "05-turned-back.png")

	# 6. drag the window by its title bar: the window and its page move by the drag, the ink with them
	await _drag(_mid(tb.title_rect), Vector2(-20, -6), 5, "drag the window by its title bar")
	await _frames(3)
	var e := _book(shell, "before-hidden")
	_state(shell, "before-hidden")
	await _shot(out_dir, "06-before-hidden.png")

	# 7. click the Map tab: the Sketchbook page is frozen — no frames, no input, SubViewports quiet —
	#    and a drag across the hidden page draws nothing, the hidden arrow turns nothing
	await _click(_center(shell, st.tabs[0].rect), "map tab")
	await _frames(3)
	_state(shell, "map")
	_book(shell, "book-hidden")
	await _drag(_page_point(e), Vector2(8, 3), 8, "drag inside the page while hidden")
	await _move(_mid(e.controls.next))
	await _click(_mid(e.controls.next), "next-page button while hidden")
	await _frames(20)
	_book(shell, "book-hidden-after-events")
	_state(shell, "map-after-20-frames")
	await _shot(out_dir, "07-hidden.png")

	# 8. back to the Sketchbook: it resumes with the ink, the spread and the window exactly as left
	await _click(_center(shell, st.tabs[1].rect), "sketchbook tab (again)")
	await _frames(3)
	_state(shell, "book-again")
	_book(shell, "book-resumed")
	await _frames(20)
	_book(shell, "book-resumed-after-20-frames")
	await _shot(out_dir, "08-resumed.png")

	# 9. resize the window to the 1440x900 minimum: the desktop shrinks to fit the smaller page
	root.size = Vector2i(1440, 900)
	await _frames(4)
	_state(shell, "resized")
	_book(shell, "resized")
	await _shot(out_dir, "09-resized.png")
	root.size = Vector2i(1920, 1080)
	await _frames(4)
	_state(shell, "restored")
	_book(shell, "restored")
	await _shot(out_dir, "10-restored.png")

	_finish(out_dir)
