## Playtest harness for sculpture_viewer as the 3D Viewer Tenant: builds the Shell with it in the
## 3D Viewer Tab and nothing in the other Tabs, then plays it the way a person does — real
## InputEventMouseButton / InputEventMouseMotion events through Input.parse_input_event — and
## reports what it did and what the Shell's probe said. The viewer is reached through the Shell
## only (state, tenant_state). Args: --out-dir=<path>. Writes numbered screenshots and report.json.
extends "res://testing/harness_base.gd"

const Shell := preload("res://modules/shell/interface.gd")
const Viewer := preload("res://modules/sculpture_viewer/interface.gd")


func _move(pos: Vector2) -> void:
	var ev := InputEventMouseMotion.new()
	ev.position = pos
	ev.global_position = pos
	Input.parse_input_event(ev)
	await process_frame


func _wheel(pos: Vector2, up: bool, count: int, what: String) -> void:
	await _move(pos)
	for i in count:
		for pressed in [true, false]:
			await _button(pos, MOUSE_BUTTON_WHEEL_UP if up else MOUSE_BUTTON_WHEEL_DOWN, pressed)
	_log.append({"t_ms": _ms(), "event": "wheel", "what": what, "x": pos.x, "y": pos.y, "up": up, "count": count})


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


func _viewer(shell: Control, label: String) -> Dictionary:
	var r: Dictionary = Shell.tenant_state(shell, "3d_viewer")
	var entry := {"t_ms": _ms(), "event": "viewer", "label": label, "ok": r.ok, "code": r.error.code if not r.ok else ""}
	if r.ok:
		var v: Dictionary = r.value
		var controls := {}
		for n in v.controls:
			controls[n] = _rect(v.controls[n])
		entry.merge({"ticks": v.ticks, "inputs": v.inputs, "size": [v.size.x, v.size.y], "desktop_scale": v.desktop_scale,
				"pointer_scale": v.pointer_scale, "front_window": String(v.front_window), "dragging": v.dragging,
				"catalogue_rect": _rect(v.catalogue_rect), "viewer_rect": _rect(v.viewer_rect), "viewport_rect": _rect(v.viewport_rect),
				"controls": controls, "viewport_update_mode": v.viewport_update_mode, "yaw": v.yaw, "pitch": v.pitch,
				"distance": v.distance, "progress": v.progress, "playing": v.playing, "muted": v.muted, "active_view": v.active_view,
				"interaction_count": v.interaction_count, "animation_count": v.animation_count,
				"last_animated_control": v.last_animated_control, "model_loaded": v.model_loaded})
	_log.append(entry)
	return entry


func _mid(r: Dictionary) -> Vector2:
	return Vector2(r.x + r.w / 2.0, r.y + r.h / 2.0)


## The viewer window's top drag strip: Rect2(12, 4, 776, 32) in the window's own pixels.
func _top_strip(v: Dictionary) -> Vector2:
	return Vector2(v.viewer_rect.x + 400.0 * v.pointer_scale, v.viewer_rect.y + 20.0 * v.pointer_scale)


func _initialize() -> void:
	var root := get_root()
	var shell: Control = Shell.create({"3d_viewer": Viewer}).value
	var out_dir := await _mount(shell, Vector2i(1920, 1080), "/tmp/sculpture_viewer-playtest")

	# 1. launch: Collection active, the 3D Viewer Tenant not created yet; draw calls of a white page
	await _frames(3)
	_state(shell, "launch")
	_viewer(shell, "launch")

	# 2. click the 3D Viewer tab: the desktop is created on first show, its two windows on the page,
	#    the autoplay orbit running
	var st: Dictionary = _state(shell, "pre-viewer")
	await _click(_center(shell, st.tabs[2].rect), "3d viewer tab")
	await _frames(8)
	_state(shell, "viewer")
	var v := _viewer(shell, "viewer-shown")
	await _shot(out_dir, "01-viewer.png")

	# 3. the play/pause button pauses the orbit: the render then stands still (SubViewport UPDATE_ONCE spent)
	await _move(_mid(v.controls["play-pause"]))
	await _click(_mid(v.controls["play-pause"]), "play-pause button")
	await _frames(3)
	var p := _viewer(shell, "paused")
	await _shot(out_dir, "02-paused.png")
	await _frames(10)
	_viewer(shell, "paused-later")
	await _shot(out_dir, "03-paused-later.png")

	# 4. drag inside the viewport: the camera orbits (yaw by -dx * 0.35, pitch by -dy * 0.25 in viewer pixels)
	await _drag(_mid(p.viewport_rect), Vector2(-20, 10), 5, "drag-orbit inside the viewport")
	await _frames(3)
	var o := _viewer(shell, "orbited")
	await _shot(out_dir, "04-orbited.png")

	# 5. two wheel notches up inside the viewport: the camera comes 0.45 closer per notch
	await _wheel(_mid(o.viewport_rect), true, 2, "wheel up x2 inside the viewport")
	await _frames(3)
	var z := _viewer(shell, "zoomed")
	await _shot(out_dir, "05-zoomed.png")

	# 6. the next button steps 30 degrees and plays its motion
	await _move(_mid(z.controls["next"]))
	await _click(_mid(z.controls["next"]), "next button")
	await _frames(3)
	var n := _viewer(shell, "next")

	# 7. drag the viewer window by its top strip: the window moves by the drag, the view does not
	await _drag(_top_strip(n), Vector2(-15, 8), 5, "drag the viewer window by its top strip")
	await _frames(3)
	var m := _viewer(shell, "window-moved")
	await _shot(out_dir, "06-window-moved.png")

	# 8. drag the catalogue by its picture: it raises to the front and moves by the drag
	await _drag(_mid(m.catalogue_rect), Vector2(30, -5), 4, "drag the catalogue by its picture")
	await _frames(3)
	var c := _viewer(shell, "catalogue-moved")
	await _shot(out_dir, "07-catalogue-moved.png")

	# 9. a click on the viewer's top strip raises the viewer again without moving it
	await _move(_top_strip(c))
	await _click(_top_strip(c), "viewer top strip")
	await _frames(3)
	var e := _viewer(shell, "before-hidden")
	_state(shell, "before-hidden")
	await _shot(out_dir, "08-before-hidden.png")

	# 10. click the Sketchbook tab: the 3D Viewer page is frozen — no frames, no input, no rendering —
	#     and wheel, drag and a button click aimed at the hidden viewer change nothing
	await _click(_center(shell, st.tabs[1].rect), "sketchbook tab")
	await _frames(3)
	_state(shell, "sketchbook")
	_viewer(shell, "viewer-hidden")
	await _wheel(_mid(e.viewport_rect), true, 2, "wheel up x2 inside the viewport while hidden")
	await _drag(_mid(e.viewport_rect), Vector2(-20, 10), 5, "drag-orbit inside the viewport while hidden")
	await _move(_mid(e.controls["next"]))
	await _click(_mid(e.controls["next"]), "next button while hidden")
	await _frames(20)
	_viewer(shell, "viewer-hidden-after-events")
	_state(shell, "sketchbook-after-20-frames")
	await _shot(out_dir, "09-hidden.png")

	# 11. back to the 3D Viewer: it resumes with the view and the windows exactly as left
	await _click(_center(shell, st.tabs[2].rect), "3d viewer tab (again)")
	await _frames(3)
	_state(shell, "viewer-again")
	_viewer(shell, "viewer-resumed")
	await _frames(20)
	_viewer(shell, "viewer-resumed-after-20-frames")
	await _shot(out_dir, "10-resumed.png")

	# 12. resize the window to the 1440x900 minimum: the desktop shrinks to fit the smaller page
	root.size = Vector2i(1440, 900)
	await _frames(4)
	_state(shell, "resized")
	_viewer(shell, "resized")
	await _shot(out_dir, "11-resized.png")
	root.size = Vector2i(1920, 1080)
	await _frames(4)
	_state(shell, "restored")
	_viewer(shell, "restored")
	await _shot(out_dir, "12-restored.png")

	_finish(out_dir)
