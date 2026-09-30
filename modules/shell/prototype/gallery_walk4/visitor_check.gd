## Source-content and actual playback regression, including empty/static negative controls.
## godot --headless --rendering-method gl_compatibility --path . --script
## res://modules/shell/prototype/gallery_walk4/visitor_check.gd
extends SceneTree

var failures := 0


func _require(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)


func _has_motion(textures: Array) -> bool:
	var hashes := {}
	for tex in textures:
		hashes[hash(tex.get_image().get_data())] = true
	return hashes.size() > 1


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var visitor = load("res://modules/shell/prototype/gallery_walk4/visitor.gd").new()
	root.add_child(visitor)
	await process_frame
	_require(visitor.clips.walk.size() == 21, "reviewed walk frames missing")
	_require(
		visitor.clips.look.size() == 18 and visitor.clips.wave.size() == 24,
		"reviewed gesture frames missing"
	)
	_require(_has_motion(visitor.clips.walk), "walking images contain no actual pixel motion")
	_require(
		_has_motion(visitor.clips.look) and _has_motion(visitor.clips.wave),
		"gesture images contain no actual motion"
	)
	_require(not _has_motion([]), "empty negative control accepted")
	_require(not _has_motion([visitor._idle, visitor._idle]), "static negative control accepted")
	var headings := [Vector3.BACK, Vector3.FORWARD, Vector3.LEFT, Vector3.RIGHT]
	for direction in 4:
		visitor.pose(0.0, true, 0.0, headings[direction], 0.0)
		var first: Texture2D = visitor.texture
		_require(visitor.frame == direction and visitor.hframes == 2, "walk selected wrong view")
		visitor.pose(0.0, true, 0.5, headings[direction], 0.0)
		_require(visitor.texture != first, "walk phase failed to advance actual texture")
		visitor.pose(0.0, false, 0.0, headings[direction], 0.0)
		_require(visitor.texture == visitor._idle, "stopping failed to select idle")
		_require(
			visitor.play_gesture("look") == (direction == 0),
			"head look admitted unsupported direction"
		)
		visitor.gesture = ""
		_require(
			visitor.play_gesture("wave") == (direction == 1),
			"greeting admitted unsupported direction"
		)
		visitor.gesture = ""
	visitor.pose(0.0, false, 0.0, Vector3.BACK, 0.0)
	visitor.play_gesture("look")
	visitor.pose(0.1, false, 0.0, Vector3.BACK, 0.0)
	_require(
		visitor.hframes == 1 and visitor.texture == visitor.clips.look[1],
		"single-cell gesture not played"
	)
	visitor.pose(0.0, false, 0.0, Vector3.LEFT, 0.0)
	_require(
		visitor.gesture == "" and visitor.texture == visitor._idle, "turn failed to cancel gesture"
	)
	visitor.pose(0.0, false, 0.0, Vector3.FORWARD, 0.0)
	visitor.play_gesture("wave")
	visitor.pose(0.1, true, 0.1, Vector3.FORWARD, 0.0)
	_require(visitor.gesture == "", "walking failed to cancel gesture")
	visitor.pose(0.0, false, 0.0, Vector3.FORWARD, 0.0)
	visitor.play_gesture("wave")
	visitor.pose(2.1, false, 0.0, Vector3.FORWARD, 0.0)
	_require(
		visitor.gesture == "" and visitor.texture == visitor._idle,
		"greeting did not finish on idle"
	)
	print(
		"VISITOR_MOTION walk=21 look=18 greeting=24 empty_rejected=true static_rejected=true failures=",
		failures
	)
	visitor.queue_free()
	await process_frame
	quit(1 if failures else 0)
