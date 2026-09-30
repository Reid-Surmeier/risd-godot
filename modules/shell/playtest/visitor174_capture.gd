## #174 gameplay-size visitor views and accepted locomotion in the real Collection frame.
extends "res://testing/harness_base.gd"

const Scene := preload("res://modules/shell/demo.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var stage := Scene.instantiate()
	var out := await _mount(stage, Vector2i(1080, 1080), "res://docs/evidence/character-174")
	var chrome: Control = stage.get_node("Desktop/Content/SquareChrome")
	chrome._select(4)
	await _frames(2)
	var gallery := stage.find_child("GalleryWalk", true, false) as Control
	assert(gallery != null)
	await _frames(120)
	assert(gallery._paintings.size() == 23)
	assert(gallery._kid.get_script().resource_path.ends_with("visitor159/visitor.gd"))
	await _shot(out, "visitor-front-idle.png")
	gallery._orbit(PI / 2.0)
	await _frames(60)
	await _shot(out, "visitor-profile.png")
	gallery._orbit(PI / 2.0)
	await _frames(60)
	await _shot(out, "visitor-back.png")
	var start: Vector3 = gallery._pos
	_visitor_key(gallery, KEY_W, true)
	await _frames(30)
	assert(gallery._kid._clip == "Walking_A" and gallery._pos.distance_to(start) > 0.2)
	await _shot(out, "visitor-walk.png")
	_visitor_key(gallery, KEY_W, false)
	await _frames(18)
	assert(gallery._kid._clip == "Idle")
	await _shot(out, "visitor-stop.png")
	var diagonal_start: Vector3 = gallery._pos
	_visitor_key(gallery, KEY_W, true)
	_visitor_key(gallery, KEY_D, true)
	await _frames(30)
	assert(gallery._kid._clip == "Walking_A" and gallery._pos.distance_to(diagonal_start) > 0.2)
	_visitor_key(gallery, KEY_W, false)
	_visitor_key(gallery, KEY_D, false)
	await _frames(18)
	assert(gallery._kid._clip == "Idle")
	assert(not gallery._kid.play_gesture("wave") and not gallery._kid.play_gesture("look"))
	print(
		(
			"PASS #174 captures: Collection front/profile/back, straight/diagonal walk, " +
			"stop, 23 paintings, gestures disabled"
		)
	)
	_finish(out)


func _visitor_key(gallery: Control, code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = pressed
	event.echo = false
	gallery._unhandled_key_input(event)
