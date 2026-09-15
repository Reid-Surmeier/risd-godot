## Playtest harness for the video player as the Video Player Tenant: builds the Shell with the
## player in the Video Player Tab and nothing in the other Tabs, then plays it the way a person
## does and reports what it did and what the Shell's probe said. Real InputEventMouseButton /
## InputEventMouseMotion / InputEventKey events through Input.parse_input_event for every
## gesture; the interface is called only for what the Shell's caller would call (state,
## tenant_state). The player is reached through the Shell only. Args: --out-dir=<path>. Writes
## numbered screenshots and report.json.
extends "res://testing/harness_base.gd"

const Shell := preload("res://modules/shell/interface.gd")
const VideoPlayer := preload("res://modules/video_player/interface.gd")

const TAB := 3  # video_player in the Shell's fixed order


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


func _state(shell: Control, label: String) -> Dictionary:
	var s: Dictionary = Shell.state(shell).value
	var tabs := []
	for t in s.tabs:
		tabs.append({"key": t.key, "page_visible": t.page_visible, "frozen": t.frozen, "tenant": t.tenant, "rect": _rect(t.rect)})
	var entry := {"t_ms": _ms(), "event": "state", "label": label, "count": s.count, "active": s.active, "tabs": tabs,
			"window": [shell.size.x, shell.size.y]}
	_log.append(entry)
	return entry


func _vp(shell: Control, label: String) -> Dictionary:
	var r: Dictionary = Shell.tenant_state(shell, "video_player")
	var entry := {"t_ms": _ms(), "event": "player", "label": label, "ok": r.ok, "code": r.error.code if not r.ok else ""}
	if r.ok:
		var v: Dictionary = r.value
		var tiles := []
		for t in v.tiles:
			tiles.append({"index": t.index, "enabled": t.enabled, "rect": _rect(t.rect)})
		var controls := {}
		for n in v.controls:
			controls[n] = _rect(v.controls[n])
		entry.merge({"ticks": v.ticks, "size": [v.size.x, v.size.y],
				"viewer": {"position": [v.viewer.position.x, v.viewer.position.y], "scale": v.viewer.scale, "rect": _rect(v.viewer.rect)},
				"information": {"position": [v.information.position.x, v.information.position.y], "rect": _rect(v.information.rect)},
				"arrangement": v.arrangement,
				"selected_video": v.selected_video, "video_id": v.video_id, "title": v.title, "playing": v.playing,
				"paused": v.paused, "hidden_paused": v.hidden_paused, "muted": v.muted, "volume": v.volume,
				"fullscreen": v.fullscreen, "stream_position": v.stream_position, "stream_length": v.stream_length,
				"saved": v.saved, "video_rect": _rect(v.video_rect), "thumbnail_count": v.thumbnail_count,
				"linked_video_count": v.linked_video_count, "tiles": tiles, "controls": controls,
				"generated_motion_controls": v.generated_motion_controls, "motion_play_count": v.motion_play_count,
				"drag_intent_count": v.drag_intent_count, "dragging_viewer": v.dragging_viewer,
				"interaction_count": v.interaction_count, "last_action": v.last_action})
	_log.append(entry)
	return entry


func _c(r: Dictionary) -> Vector2:
	return Vector2(r.x + r.w / 2.0, r.y + r.h / 2.0)


func _initialize() -> void:
	var root := get_root()
	var shell: Control = Shell.create({"video_player": VideoPlayer}).value
	var out_dir := await _mount(shell, Vector2i(1920, 1080), "/tmp/video_player-playtest")
	await create_timer(1.0).timeout  # the launch grow and fade of the Collection tab

	# 1. launch: Collection active, the Video Player Tenant not created yet
	await _frames(3)
	_state(shell, "launch")
	_vp(shell, "launch")

	# 2. click the Video Player tab: the player is created on first show, fills the page, the
	#    viewer fits it and the first video is playing; thirty frames later its position has moved
	var st: Dictionary = _state(shell, "pre-video")
	await _click(_center(shell, st.tabs[TAB].rect), "video player tab")
	await create_timer(0.45).timeout  # the page cross-fade
	await _frames(8)
	_state(shell, "video")
	var a := _vp(shell, "shown")
	await _shot(out_dir, "01-shown.png")
	await _frames(30)
	_vp(shell, "playing-30")
	await _shot(out_dir, "02-playing.png")

	# 3. click the third tile: its video loads at 0:00 and autoplays
	await _click(_c(a.tiles[2].rect), "tile 3")
	await _frames(3)
	_vp(shell, "tile-3")
	await _frames(30)
	var b := _vp(shell, "tile-3-30")
	await _shot(out_dir, "03-tile-3.png")

	# 4. the play/pause control pauses: the position stands still for twenty frames; again resumes
	await _click(_c(b.controls.play), "play/pause")
	await _frames(2)
	_vp(shell, "paused")
	await _shot(out_dir, "04-paused.png")
	await _frames(20)
	_vp(shell, "paused-20")
	await _shot(out_dir, "05-paused-20.png")
	await _click(_c(b.controls.play), "play/pause (again)")
	await _frames(2)
	var c := _vp(shell, "resumed")

	# 5. seek by a real drag on the knob: 60 px to the right along the track
	await _drag(_c(c.controls.seek_knob), Vector2(12, 0), 5, "drag the seek knob right")
	await _frames(3)
	var d := _vp(shell, "seeked")
	await _shot(out_dir, "06-seeked.png")

	# 6. mute by its control; then a drag on the volume knob sets the gain and unmutes
	await _click(_c(d.controls.mute), "mute")
	await _frames(2)
	var e := _vp(shell, "muted")
	await _drag(_c(e.controls.volume_knob), Vector2(-6, 0), 5, "drag the volume knob left")
	await _frames(2)
	var f := _vp(shell, "volume")

	# 7. fullscreen fills the Page and keeps playing; F restores the viewer
	await _click(_c(f.controls.fullscreen), "fullscreen")
	await _frames(3)
	_vp(shell, "fullscreen")
	await _shot(out_dir, "07-fullscreen.png")
	await _frames(20)
	_vp(shell, "fullscreen-20")
	await _key(KEY_F, "F key")
	await _frames(3)
	var g := _vp(shell, "windowed")
	await _shot(out_dir, "08-windowed.png")

	# 8. the keys with the page shown: Space pauses and resumes, Right seeks 5 s, 2 picks the
	#    second tile; Save toggles for the session
	await _key(KEY_SPACE, "Space key")
	await _frames(2)
	_vp(shell, "key-space")
	await _key(KEY_SPACE, "Space key (again)")
	await _frames(2)
	_vp(shell, "key-space-again")
	await _key(KEY_RIGHT, "Right key")
	await _frames(2)
	_vp(shell, "key-right")
	await _key(KEY_2, "2 key")
	await _frames(3)
	_vp(shell, "key-2")
	await _click(_c(g.controls.save), "save")
	await _frames(2)
	var h := _vp(shell, "saved")

	# 9. drag the viewer by its title bar: it moves by the drag; far past the corner it stops with
	#    part of the title bar still inside the page
	await _drag(_c(h.controls.title_bar), Vector2(14, -3), 5, "drag the viewer by its title bar")
	await _frames(3)
	var m := _vp(shell, "viewer-moved")
	await _shot(out_dir, "09-viewer-moved.png")
	await _drag(_c(m.controls.title_bar), Vector2(300, 200), 6, "drag the title bar past the page's bottom-right corner")
	await _frames(3)
	_vp(shell, "viewer-clamped")

	# 9b. #63: the Information window drags by its own title bar; the Fly Through window stays
	var cl := _vp(shell, "viewer-clamped-probe")
	await _drag(_c(cl.controls.info_title_bar), Vector2(-12, 6), 5, "drag the information window by its title bar")
	await _frames(3)
	_vp(shell, "information-moved")

	# 10. hide: the Map tab (no Tenant) shows a white page; the player is frozen and paused, its
	#     position stands still, and keys and a click aimed at it change nothing
	_vp(shell, "before-hidden")
	await _shot(out_dir, "10-before-hidden.png")
	await _click(_center(shell, st.tabs[0].rect), "map tab")
	await create_timer(0.45).timeout  # the page cross-fade
	await _frames(3)
	_state(shell, "map")
	_vp(shell, "hidden")
	await _key(KEY_SPACE, "Space key while hidden")
	await _key(KEY_RIGHT, "Right key while hidden")
	await _key(KEY_3, "3 key while hidden")
	await _click(_c(a.tiles[3].rect), "where tile 4 was, while hidden")
	await _frames(30)
	_vp(shell, "hidden-after-events")
	_state(shell, "map-after-30-frames")
	await _shot(out_dir, "11-hidden.png")

	# 11. back to the Video Player: it resumes playing from where it paused
	await _click(_center(shell, st.tabs[TAB].rect), "video player tab (again)")
	await create_timer(0.45).timeout  # the page cross-fade
	await _frames(3)
	_state(shell, "video-again")
	_vp(shell, "resumed-on-show")
	await _frames(30)
	_vp(shell, "resumed-30")
	await _shot(out_dir, "12-resumed.png")

	# 12. the 1440x900 minimum: the tenant fills the smaller page and the viewer re-fits, then back
	root.size = Vector2i(1440, 900)
	await _frames(4)
	_state(shell, "resized")
	_vp(shell, "resized")
	await _shot(out_dir, "13-resized.png")
	root.size = Vector2i(1920, 1080)
	await _frames(4)
	_vp(shell, "restored")

	# 13. #63: pages of 1920x1000 and 1440x820 (the window is the page plus the bar, 161/4180 of its
	#     width): the viewer plate is as large as the page allows and centred
	for page in [Vector2i(1920, 1000), Vector2i(1440, 820)]:
		root.size = Vector2i(page.x, roundi(page.y + 161.0 * page.x / 4180.0))
		await _frames(4)
		_state(shell, "fill-%dx%d" % [page.x, page.y])
		_vp(shell, "fill-%dx%d" % [page.x, page.y])
		await _shot(out_dir, "14-fill-%dx%d.png" % [page.x, page.y])

	_finish(out_dir)
