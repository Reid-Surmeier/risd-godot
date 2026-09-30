## Playtest harness for the atlas desktop as the Map Tenant: builds the Shell with the atlas in
## the Map Tab and nothing in the other Tabs, then plays it the way a person does (the four
## desktop panels and the map window) and reports what it did and what the Shell's probe said. Real InputEventMouseButton / InputEventMouseMotion /
## InputEventKey events through Input.parse_input_event for every gesture; the interface is called
## only for what the Shell's caller would call (state, tenant_state). The atlas is reached through
## the Shell only. Args: --out-dir=<path>. Writes numbered screenshots and report.json.
extends "res://testing/harness_base.gd"

const Shell := preload("res://modules/shell/interface.gd")
const Atlas := preload("res://modules/atlas/interface.gd")


func _wheel(pos: Vector2, up: bool, count: int, what: String) -> void:
	for i in count:
		for pressed in [true, false]:
			await _button(pos, MOUSE_BUTTON_WHEEL_UP if up else MOUSE_BUTTON_WHEEL_DOWN, pressed)
	_log.append(
		{
			"t_ms": _ms(),
			"event": "wheel",
			"what": what,
			"x": pos.x,
			"y": pos.y,
			"up": up,
			"count": count
		}
	)


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
	_log.append(
		{
			"t_ms": _ms(),
			"event": "drag",
			"what": what,
			"from": [from.x, from.y],
			"to": [pos.x, pos.y],
			"relative_total": [step.x * steps, step.y * steps],
			"steps": steps
		}
	)


func _draw_calls() -> int:
	return RenderingServer.get_rendering_info(
		RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME
	)


func _state(shell: Control, label: String) -> Dictionary:
	var s: Dictionary = Shell.state(shell).value
	var tabs := []
	for t in s.tabs:
		tabs.append(
			{
				"key": t.key,
				"page_visible": t.page_visible,
				"frozen": t.frozen,
				"tenant": t.tenant,
				"rect": _rect(t.rect)
			}
		)
	var entry := {
		"t_ms": _ms(),
		"event": "state",
		"label": label,
		"count": s.count,
		"active": s.active,
		"tabs": tabs,
		"window": [shell.size.x, shell.size.y],
		"draw_calls": _draw_calls()
	}
	_log.append(entry)
	return entry


func _atlas(shell: Control, label: String) -> Dictionary:
	var r: Dictionary = Shell.tenant_state(shell, "map")
	var entry := {
		"t_ms": _ms(),
		"event": "atlas",
		"label": label,
		"ok": r.ok,
		"code": r.error.code if not r.ok else ""
	}
	if r.ok:
		var v: Dictionary = r.value
		entry.merge(
			{
				"ticks": v.ticks,
				"inputs": v.inputs,
				"size": [v.size.x, v.size.y],
				"frame": _rect(v.frame),
				"frame_global": _rect(v.frame_global),
				"map_rect": _rect(v.map_rect),
				"chrome_scale": v.chrome_scale,
				"locked": v.locked,
				"collapsed": v.collapsed,
				"action": v.action,
				"viewport_update_mode": v.viewport_update_mode,
				"mode": v.mode,
				"region": v.region,
				"zoom": v.zoom,
				"zoom_ratio": v.zoom_ratio,
				"zoom_min": v.zoom_min,
				"zoom_max": v.zoom_max,
				"position": v.position,
				"viewport": v.viewport,
				"visible_cities": v.visible_cities,
				"visible_close_cities": v.visible_close_cities,
				"visible_labels": v.visible_labels,
				"terrain_tiles": v.terrain_tiles,
				"vertical_pan_locked": v.vertical_pan_locked,
				"stack": v.stack,
				"moving_window": v.moving_window
			}
		)
		var panels := {}
		for id in v.panels:
			panels[id] = _rect(v.panels[id])
		entry["panels"] = panels
	_log.append(entry)
	return entry


## The global centre of one of the frame's two buttons, from the probe's frame rects
## (atlas_window.gd _layout: collapse at (44, 42) x chrome_scale, lock at (w - 86, 42), 44 px square).
func _frame_button(a: Dictionary, which: String) -> Vector2:
	var cs: float = a.chrome_scale
	var x: float = 44.0 * cs if which == "collapse" else a.frame.w - 86.0 * cs
	return Vector2(a.frame_global.x + x + 22.0 * cs, a.frame_global.y + 64.0 * cs)


## The global centre of a desktop panel, from the probe's local rect and the tenant's origin
## (frame_global - frame gives where the tenant's pixels start on the root).
func _panel_center(a: Dictionary, id: String) -> Vector2:
	var p: Dictionary = a.panels[id]
	return Vector2(
		a.frame_global.x - a.frame.x + p.x + p.w / 2.0,
		a.frame_global.y - a.frame.y + p.y + p.h / 2.0
	)


func _title_bar(a: Dictionary) -> Vector2:
	return Vector2(
		a.frame_global.x + a.frame_global.w / 2.0, a.frame_global.y + 60.0 * a.chrome_scale
	)


func _map_center(a: Dictionary) -> Vector2:
	return Vector2(a.map_rect.x + a.map_rect.w / 2.0, a.map_rect.y + a.map_rect.h / 2.0)


## The atlas keys of ticket #30 acceptance 4: +, Right, F (twice), Home. Each is probed so the
## verifier can check what changed — everything with Map active, nothing with another Tab active.
func _keys(shell: Control, suffix: String) -> void:
	await _key(KEY_PLUS, "+ key" + suffix)
	await _frames(2)
	_atlas(shell, "key-plus" + suffix)
	await _key(KEY_RIGHT, "right arrow" + suffix)
	await _frames(2)
	_atlas(shell, "key-right" + suffix)
	await _key(KEY_F, "F key" + suffix)
	await _frames(2)
	_atlas(shell, "key-f-sheet" + suffix)
	await _key(KEY_F, "F key (again)" + suffix)
	await _frames(2)
	_atlas(shell, "key-f-atlas" + suffix)
	await _key(KEY_HOME, "Home key" + suffix)
	await _frames(2)
	_atlas(shell, "key-home" + suffix)


func _initialize() -> void:
	var root := get_root()
	var shell: Control = Shell.create({"map": Atlas}).value
	var out_dir := await _mount(shell, Vector2i(1920, 1080), "/tmp/atlas-playtest")
	await create_timer(1.0).timeout  # the launch grow and fade of the Collection tab

	# 1. launch: Collection active, the Map Tenant not created yet; draw calls of a white page
	await _frames(3)
	_state(shell, "launch")
	_atlas(shell, "launch")

	# 2. click the Map tab: the atlas is created on first show, fills the page and draws
	var st: Dictionary = _state(shell, "pre-map")
	await _click(_center(shell, st.tabs[0].rect), "map tab")
	await create_timer(0.45).timeout  # the page cross-fade
	await _frames(8)
	_state(shell, "map")
	var a := _atlas(shell, "map-shown")
	await _shot(out_dir, "01-map.png")

	# 3. the desktop panels: drag the notification from the bottom-right corner onto the map body —
	#    the panel moves by the drag and comes to the top of the stack, the frame and the view stay;
	#    then a wheel over the panel does not zoom the map beneath it
	await _drag(
		_panel_center(a, "notification"),
		Vector2(-140, -140),
		5,
		"drag the notification panel onto the map"
	)
	await _frames(3)
	var pn := _atlas(shell, "panel-moved")
	await _shot(out_dir, "02-panel-moved.png")
	await _wheel(
		_panel_center(pn, "notification"), true, 3, "wheel up x3 over the notification panel"
	)
	await _frames(3)
	_atlas(shell, "wheel-over-panel")

	# 4. wheel up three times at the map's centre: zoom in around it
	await _wheel(_map_center(a), true, 3, "wheel up x3 at map centre")
	await _frames(3)
	_atlas(shell, "zoomed")
	await _shot(out_dir, "03-zoomed.png")

	# 5. drag-pan inside the map: the camera moves against the drag, divided by the zoom
	await _drag(_map_center(a), Vector2(-40, -30), 4, "drag-pan inside the map")
	await _frames(3)
	var c := _atlas(shell, "panned")
	await _shot(out_dir, "04-panned.png")

	# 6. drag the map window by its title bar: the frame moves by the drag
	#    (left and down: since #63 the window starts flush with the page's top and right margins)
	await _drag(_title_bar(c), Vector2(-14, 3), 5, "drag the map window by its title bar")
	await _frames(3)
	var d := _atlas(shell, "window-moved")
	await _shot(out_dir, "05-window-moved.png")
	_state(shell, "window-moved")

	# 7. drag the title bar far past the page's bottom-right corner: the frame stops at the page's edge
	await _drag(
		_title_bar(d),
		Vector2(300, 200),
		6,
		"drag the title bar past the page's bottom-right corner"
	)
	await _frames(3)
	var cl := _atlas(shell, "window-clamped")
	await _shot(out_dir, "06-window-clamped.png")

	# 8. drag the frame's bottom-right corner inward: the frame shrinks in place and the map body follows
	var corner := Vector2(
		cl.frame_global.x + cl.frame_global.w - 4.0, cl.frame_global.y + cl.frame_global.h - 4.0
	)
	await _drag(corner, Vector2(-30, -20), 5, "drag the frame's bottom-right corner inward")
	await _frames(3)
	var rz := _atlas(shell, "window-resized")
	await _shot(out_dir, "07-window-resized.png")

	# 9. the left button collapses the window to its title bar; again expands it to the size it had
	await _click(_frame_button(rz, "collapse"), "collapse button")
	await _frames(3)
	var co := _atlas(shell, "collapsed")
	await _shot(out_dir, "08-collapsed.png")
	await _click(_frame_button(co, "collapse"), "collapse button (again)")
	await _frames(3)
	var ex := _atlas(shell, "expanded")

	# 10. the right button locks the window: a title-bar drag moves nothing; again unlocks it
	await _click(_frame_button(ex, "lock"), "lock button")
	await _frames(2)
	var lk := _atlas(shell, "locked")
	await _drag(_title_bar(lk), Vector2(-14, 3), 5, "drag the title bar while locked")
	await _frames(3)
	_atlas(shell, "locked-drag")
	await _click(_frame_button(lk, "lock"), "lock button (again)")
	await _frames(2)
	_atlas(shell, "unlocked")

	# 11. the keys with Map active: + zooms, Right pans, F shows the region's sheet and comes back,
	#     Home resets to the world view; then two wheel notches so the view left behind is not the default
	_atlas(shell, "pre-keys")
	await _keys(shell, "")
	await _shot(out_dir, "09-key-home.png")
	await _wheel(_map_center(lk), true, 2, "wheel up x2 at map centre before hiding")
	await _frames(3)
	var e := _atlas(shell, "before-hidden")
	await _shot(out_dir, "10-before-hidden.png")
	_state(shell, "before-hidden")

	# 12. click the Sketchbook tab: the Map page is frozen — no frames, no input, no rendering —
	#     and wheel, drag and every key aimed at the hidden map change nothing
	await _click(_center(shell, st.tabs[1].rect), "sketchbook tab")
	await create_timer(0.45).timeout  # the freeze rule applies once the cross-fade has settled
	await _frames(3)
	_state(shell, "sketchbook")
	_atlas(shell, "map-hidden")
	await _wheel(_map_center(e), true, 3, "wheel up x3 at the map's centre while hidden")
	await _drag(_map_center(e), Vector2(-40, -30), 4, "drag where the map was while hidden")
	await _keys(shell, " while hidden")
	await _frames(20)
	_atlas(shell, "map-hidden-after-events")
	_state(shell, "sketchbook-after-20-frames")
	await _shot(out_dir, "11-hidden.png")

	# 13. back to Map: it resumes with zoom, camera and window exactly as left
	await _click(_center(shell, st.tabs[0].rect), "map tab (again)")
	await _frames(3)
	_atlas(shell, "map-resumed")  # it runs again from the moment its fade-in starts
	await create_timer(0.45).timeout
	_state(shell, "map-again")
	await _frames(20)
	_atlas(shell, "map-resumed-after-20-frames")
	await _shot(out_dir, "12-resumed.png")

	# 14. resize the window to the 1440x900 minimum: the tenant fills the smaller page and re-fits its window
	root.size = Vector2i(1440, 900)
	await _frames(4)
	_state(shell, "resized")
	_atlas(shell, "resized")
	await _shot(out_dir, "13-resized.png")
	root.size = Vector2i(1920, 1080)
	await _frames(4)
	_state(shell, "restored")
	_atlas(shell, "restored")
	await _shot(out_dir, "14-restored.png")

	# 15. #63: pages of 1920x1000 and 1440x820 (the window is the page plus the bar, 161/4180 of its
	#     width): the desktop spans the page on both axes and the map window takes the leftover
	for page in [Vector2i(1920, 1000), Vector2i(1440, 820)]:
		root.size = Vector2i(page.x, roundi(page.y + 161.0 * page.x / 4180.0))
		await _frames(4)
		_state(shell, "fill-%dx%d" % [page.x, page.y])
		_atlas(shell, "fill-%dx%d" % [page.x, page.y])
		await _shot(out_dir, "15-fill-%dx%d.png" % [page.x, page.y])

	_finish(out_dir)
