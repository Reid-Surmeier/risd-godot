## PROTOTYPE 2, throwaway (2026-09-26): the RISD Grand Gallery walked in third person inside the Collection
## frame. Stills are Muse passes in the owner's NextRooms gallery style (image-work/grand-gallery-v2*), the
## kid is a Seedance walk cycle, and a step forward is shown one of two ways, to compare:
##   seedance - the Seedance clip between two stills plays (falls back to depth where no clip exists)
##   depth    - the still is projected onto a box of the room and the camera walks into it (box_room.gd)
## Keys: Up/W walk forward, Down/S turn around, 1 seedance, 2 depth, Esc back from a painting.
## Click a wall to walk up to it. URL: ?walk=seedance|depth
extends Control

const BoxRoom := preload("res://modules/shell/prototype/gallery_walk2/box_room.gd")
const DIR := "res://modules/shell/prototype/gallery_walk2/"
const FOV := 60.0

# far: the far wall's rectangle in the still (0..1). up: the stop one step forward, and how far into
# the box that step is (the fraction at which this still's far wall matches the next still's).
const STOPS := {
	"s1": {"far": Rect2(0.346, 0.353, 0.312, 0.261), "up": "s2", "step": 0.08, "down": "r2"},
	"s2": {"far": Rect2(0.33, 0.35, 0.34, 0.285), "up": "s3", "step": 0.08, "down": "r2"},
	"s3": {"far": Rect2(0.318, 0.335, 0.369, 0.298), "down": "r3"},
	"r3": {"far": Rect2(0.37, 0.40, 0.265, 0.195), "up": "r2", "step": 0.33, "down": "s3"},
	"r2": {"far": Rect2(0.30, 0.34, 0.40, 0.355), "down": "s2"},
}
const STEP_S := 2.4

var mode := "seedance"
var _stop := "s1"
var _busy := false
var _at_wall := false
var _box: SubViewportContainer
var _over: TextureRect  # crossfades and clip frames, over the box
var _kid: TextureRect
var _kid_frames: Array[Texture2D] = []
var _walking := false
var _kid_t := 0.0


func _ready() -> void:
	clip_contents = true
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	_box = BoxRoom.new()
	_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_box)
	_over = TextureRect.new()
	_over.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_over.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_over.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_over.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_over.modulate.a = 0.0
	add_child(_over)
	_kid = TextureRect.new()
	_kid.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_kid.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	_kid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_kid)
	var i := 0
	while ResourceLoader.exists(DIR + "kid/%02d.png" % i):
		_kid_frames.append(load(DIR + "kid/%02d.png" % i))
		i += 1
	if not _kid_frames.is_empty():
		_kid.texture = _kid_frames[0]
	if OS.has_feature("web"):
		var q = JavaScriptBridge.eval("new URLSearchParams(location.search).get('walk') || ''")
		if q in ["seedance", "depth"]:
			mode = q
	resized.connect(_place_kid)
	_place_kid.call_deferred()
	_show(_stop)


func _place_kid() -> void:
	var h := size.y * 0.27
	_kid.size = Vector2(h, h)
	_kid.position = Vector2((size.x - h) / 2, size.y * 0.95 - h)


func _process(delta: float) -> void:
	if _walking and _kid_frames.size() > 1:
		_kid_t += delta
		_kid.texture = _kid_frames[int(_kid_t * 12.0) % _kid_frames.size()]


func _still(id: String) -> Texture2D:
	return load(DIR + "stills/%s.png" % id)


func _show(id: String) -> void:
	_stop = id
	_box.set_still(_still(id), STOPS[id].far, FOV)


func _clip(from: String, to: String) -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	var i := 0
	while ResourceLoader.exists(DIR + "clips/%s-%s/%03d.jpg" % [from, to, i]):
		frames.append(load(DIR + "clips/%s-%s/%03d.jpg" % [from, to, i]))
		i += 1
	return frames


func _fade_over(tex: Texture2D, secs: float) -> void:
	_over.texture = tex
	var t := create_tween()
	t.tween_property(_over, "modulate:a", 1.0, secs)
	await t.finished


func _clear_over(secs: float) -> void:
	var t := create_tween()
	t.tween_property(_over, "modulate:a", 0.0, secs)
	await t.finished


func _walk_forward() -> void:
	var to: String = STOPS[_stop].get("up", "")
	if to == "":
		return
	_busy = true
	_walking = true
	var clip := _clip(_stop, to) if mode == "seedance" else ([] as Array[Texture2D])
	if not clip.is_empty():
		_over.modulate.a = 1.0
		for f in clip:  # held frames at 12 fps, the retro cadence
			_over.texture = f
			await get_tree().create_timer(1.0 / 12.0).timeout
		_show(to)
		await _clear_over(0.3)
	else:
		await _box.walk_to(STOPS[_stop].step, STEP_S).finished
		await _fade_over(_still(to), 0.35)
		_show(to)
		_over.modulate.a = 0.0
	_walking = false
	_kid.texture = _kid_frames[0] if not _kid_frames.is_empty() else null
	_busy = false


func _turn_around() -> void:
	var to: String = STOPS[_stop].get("down", "")
	if to == "":
		return
	_busy = true
	await _fade_over(_still(to), 0.5)
	_show(to)
	_over.modulate.a = 0.0
	_busy = false


# Walk up to the clicked point on a side wall: intersect the click ray with the box, then glide there.
func _approach(p: Vector2) -> void:
	var cam: Camera3D = _box.cam
	var from := cam.project_ray_origin(p)
	var dir := cam.project_ray_normal(p)
	var hit: Vector3 = _box.hit_wall(from, dir)
	if hit == Vector3.INF:
		return
	_busy = true
	_at_wall = true
	_walking = true
	var side := signf(hit.x)
	var stand := Vector3(hit.x - side * 1.4, _box.EYE, hit.z)
	var t := create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(cam, "position", stand, 2.6)
	t.tween_property(cam, "rotation:y", -side * PI / 2, 2.6)
	t.tween_property(_kid, "modulate:a", 0.0, 0.8)
	await t.finished
	_walking = false
	_busy = false


func _leave_wall() -> void:
	_busy = true
	var cam: Camera3D = _box.cam
	var t := create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(cam, "position", Vector3(0, _box.EYE, 0), 1.8)
	t.tween_property(cam, "rotation:y", 0.0, 1.8)
	t.tween_property(_kid, "modulate:a", 1.0, 1.8)
	await t.finished
	_at_wall = false
	_busy = false


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		grab_focus()
		accept_event()
		if _busy:
			return
		if _at_wall:
			_leave_wall()
		elif event.position.y > size.y * 0.7:
			_walk_forward()
		else:
			_approach(event.position)


func _unhandled_key_input(event: InputEvent) -> void:
	if not is_visible_in_tree() or not event.pressed or event.echo:
		return
	var handled := true
	match event.keycode:
		KEY_1: mode = "seedance"
		KEY_2: mode = "depth"
		KEY_UP, KEY_W:
			if not _busy and not _at_wall: _walk_forward()
		KEY_DOWN, KEY_S, KEY_ESCAPE:
			if not _busy and _at_wall:
				_leave_wall()
			elif not _busy:
				_turn_around()
		_: handled = false
	if handled:
		get_viewport().set_input_as_handled()
