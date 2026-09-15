## Playtest harness for the Image Viewer desktop as the Collection Tenant: builds the Shell with
## it in the Collection Tab and nothing in the other Tabs, then plays it the way a person does —
## real InputEventMouseButton / InputEventMouseMotion events through Input.parse_input_event on
## the windows' title bars, a window body, the viewer's corner, the wheel over the artworks and the
## tabs — and reports what it did and what the interfaces said. The desktop is reached through the
## Shell only. Args: --out-dir=<path>. Writes numbered screenshots and report.json there.
extends "res://testing/harness_base.gd"

const Shell := preload("res://modules/shell/interface.gd")
const Page := preload("res://modules/collection_page/interface.gd")


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


func _shell_state(shell: Control, label: String) -> Dictionary:
	var s: Dictionary = Shell.state(shell).value
	var tabs := []
	for t in s.tabs:
		tabs.append({"key": t.key, "page_visible": t.page_visible, "frozen": t.frozen, "tenant": t.tenant, "rect": _rect(t.rect)})
	var entry := {"t_ms": _ms(), "event": "shell", "label": label, "active": s.active, "count": s.count, "tabs": tabs,
			"window": [shell.size.x, shell.size.y]}
	_log.append(entry)
	return entry


func _page(shell: Control, label: String) -> Dictionary:
	var r: Dictionary = Shell.tenant_state(shell, "collection")
	var entry := {"t_ms": _ms(), "event": "page", "label": label, "ok": r.ok, "code": r.error.code if not r.ok else ""}
	if r.ok:
		var v: Dictionary = r.value
		var page: Control = shell.find_child("CollectionPage", true, false)
		var windows := []
		for w in v.windows:
			windows.append({"name": w.name, "rect": _rect(w.rect), "drag_height": w.drag_height, "order": w.order})
		var cards := []
		for c in v.viewer.cards:
			cards.append(_rect(c))
		entry.merge({"ticks": v.ticks, "inputs": v.inputs, "size": [v.size.x, v.size.y], "factor": v.factor,
				"action": v.action, "windows": windows, "page_global": _rect(page.get_global_rect()),
				"viewer": {"rect": _rect(v.viewer.rect), "scale": v.viewer.scale, "scroll": v.viewer.scroll,
				"scroll_max": v.viewer.scroll_max, "body": _rect(v.viewer.body), "cards": cards}})
	_log.append(entry)
	return entry


func _window(p: Dictionary, name: String) -> Dictionary:
	for w in p.windows:
		if w.name == name:
			return w
	return {}


## A point on a window's title bar (12 px into its drag height, 100 px in from its left edge,
## as the prototype's playtest pressed), in global pixels.
func _title(page: Control, w: Dictionary) -> Vector2:
	return page.get_global_transform() * Vector2(w.rect.x + minf(100.0, w.rect.w / 2.0), w.rect.y + 12.0)


func _initialize() -> void:
	var root := get_root()
	var shell: Control = Shell.create({"collection": Page}).value
	var out_dir := await _mount(shell, Vector2i(1920, 1080), "/tmp/collection_page-playtest")
	await create_timer(1.0).timeout  # the launch grow and fade of the Collection tab; its Tenant exists after
	var page: Control = shell.find_child("CollectionPage", true, false)

	# 1. launch: Collection active, the desktop is the Tenant, every window at its reference place
	var st := _shell_state(shell, "launch")
	var la := _page(shell, "launch")
	await _shot(out_dir, "01-launch.png")

	# 2. drag the equipment window by its title bar: it moves by the drag and comes to the top
	await _drag(_title(page, _window(la, "equipment")), Vector2(8, -3), 5, "drag equipment by its title bar")
	await _frames(2)
	var eq := _page(shell, "equipment-moved")
	await _shot(out_dir, "02-equipment-moved.png")

	# 3. drag the options window by its body (below its title bar): nothing moves
	var op: Dictionary = _window(eq, "options")
	await _drag(page.get_global_transform() * Vector2(op.rect.x + 100.0, op.rect.y + op.rect.h / 2.0), Vector2(6, 4), 5,
			"drag options by its body")
	await _frames(2)
	_page(shell, "options-body-drag")

	# 4. drag the party window by its title bar up over the viewer: it lies on top of the viewer
	var pa: Dictionary = _window(eq, "party")
	var vw: Dictionary = _window(eq, "viewer")
	var up := Vector2(0, -(pa.rect.y - (vw.rect.y + vw.rect.h) + 60.0) / 6.0)
	await _drag(_title(page, pa), up, 6, "drag party by its title bar over the viewer")
	await _frames(2)
	var ov := _page(shell, "party-over-viewer")
	await _shot(out_dir, "03-party-over-viewer.png")

	# 5. press the viewer's title bar where party does not cover it and drag: the viewer comes to the
	#    top of the stack and moves; party stays where it was
	var vt := page.get_global_transform() * Vector2(vw.rect.x + vw.rect.w - 200.0, vw.rect.y + 12.0)
	await _drag(vt, Vector2(-5, 4), 6, "drag the viewer by its title bar")
	await _frames(2)
	var vm := _page(shell, "viewer-moved")
	await _shot(out_dir, "04-viewer-moved.png")

	# 6. wheel down three notches over the artworks: the gallery scrolls
	var body: Dictionary = vm.viewer.body
	var centre := page.get_global_transform() * Vector2(body.x + body.w / 2.0, body.y + body.h / 2.0)
	await _wheel(centre, false, 3, "wheel down x3 over the artworks")
	await _frames(2)
	var sc := _page(shell, "scrolled")
	await _shot(out_dir, "05-scrolled.png")

	# 7. drag the viewer's bottom-right corner inward: it shrinks in place
	var vr: Dictionary = _window(sc, "viewer").rect
	var corner := page.get_global_transform() * Vector2(vr.x + vr.w - 8.0, vr.y + vr.h - 8.0)
	await _drag(corner, Vector2(-20, -12), 5, "drag the viewer's corner inward")
	await _frames(2)
	var rz := _page(shell, "viewer-resized")
	await _shot(out_dir, "06-viewer-resized.png")

	# 8. drag the chat window far past the page's bottom-left corner: it stops at the edge
	await _drag(_title(page, _window(rz, "chat")), Vector2(-60, 60), 6, "drag chat past the page's bottom-left corner")
	await _frames(2)
	var cl := _page(shell, "chat-clamped")
	await _shot(out_dir, "07-chat-clamped.png")

	# 9. click the Map tab: the page is frozen — no frames, no input — and a drag and a wheel aimed
	#    at the hidden windows change nothing
	await _click(_center(shell, st.tabs[0].rect), "map tab")
	await create_timer(0.45).timeout  # the page cross-fade, then the freeze rule
	await _frames(3)
	_shell_state(shell, "map")
	_page(shell, "hidden")
	await _drag(_title(page, _window(cl, "trade")), Vector2(8, -3), 5, "drag trade by its title bar while hidden")
	await _wheel(centre, false, 3, "wheel down x3 over the artworks while hidden")
	await _frames(20)
	_page(shell, "hidden-after-events")
	_shell_state(shell, "map-after-20-frames")
	await _shot(out_dir, "08-map.png")

	# 10. back to Collection: it resumes with every window exactly as left
	await _click(_center(shell, st.tabs[4].rect), "collection tab")
	await create_timer(0.45).timeout
	await _frames(3)
	_shell_state(shell, "collection-again")
	_page(shell, "resumed")
	await _frames(20)
	_page(shell, "resumed-after-20-frames")
	await _shot(out_dir, "09-resumed.png")

	# 11. the 1440x900 minimum: the desktop re-fits every window to the smaller page
	root.size = Vector2i(1440, 900)
	await _frames(4)
	_shell_state(shell, "resized")
	_page(shell, "resized")
	await _shot(out_dir, "10-resized.png")

	# 12. #63: pages of 1920x1000 and 1440x820 (the window is the page plus the bar, 161/4180 of its
	#     width): the desktop spans the page on both axes and the viewer takes the leftover
	for size in [Vector2i(1920, 1000), Vector2i(1440, 820)]:
		root.size = Vector2i(size.x, roundi(size.y + 161.0 * size.x / 4180.0))
		await _frames(4)
		_shell_state(shell, "fill-%dx%d" % [size.x, size.y])
		_page(shell, "fill-%dx%d" % [size.x, size.y])
		await _shot(out_dir, "11-fill-%dx%d.png" % [size.x, size.y])

	_finish(out_dir)
