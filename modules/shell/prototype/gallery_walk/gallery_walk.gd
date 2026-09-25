## PROTOTYPE, throwaway (2026-09-25): a frame-by-frame walk through one RISD Museum gallery, inside the
## Collection frame. Each stop is one Muse still rebuilt from the owner's walkthrough video (IMG_6343.MOV,
## 1:31-2:25); a key or click advances to the next still. Clicking a painting glides the view into it,
## then fades to that painting's close-up still. Stills: image-work/gallery-walk-v1 and -closeups.
## Keys: Up/W forward, Down/S back, Left/A and Right/D turn, Esc steps back from a painting.
## Mouse: click a painting to approach it, the left or right edge to turn, the floor to walk forward.
extends Control

const DIR := "res://modules/shell/prototype/gallery_walk/stills/"
const IMAGE := Vector2(1920, 1280)

# Each stop: its still, where each key leads, and its paintings (rects in still pixels).
const STOPS := {
	"n0": {"still": "n0-doorway", "up": "n1",
		"paintings": [["le_repos", Rect2(756, 456, 155, 165)]]},
	"n1": {"still": "n1-room", "up": "n4", "down": "n0", "left": "n5", "right": "n2",
		"paintings": [["le_repos", Rect2(592, 482, 213, 272)], ["road", Rect2(1220, 531, 148, 158)],
			["sailboats", Rect2(1510, 478, 248, 245)]]},
	"n2": {"still": "n2-right-wall", "down": "n1", "left": "n1", "right": "n3",
		"paintings": [["poppies", Rect2(773, 511, 199, 195)], ["road", Rect2(1142, 481, 306, 231)]]},
	"n3": {"still": "n3-poppy-wall", "down": "n1", "left": "n2", "right": "n4",
		"paintings": [["poppies", Rect2(761, 410, 413, 353)]]},
	"n4": {"still": "n4-le-repos-wall", "down": "n1", "left": "n3", "right": "n5",
		"paintings": [["le_repos", Rect2(744, 368, 423, 515)]]},
	"n5": {"still": "n5-reverse", "up": "n4", "down": "n1", "left": "n4", "right": "n1",
		"paintings": [["le_repos", Rect2(1026, 432, 280, 331)]]},
}
# Close-up stills; "photo" is the museum's own photograph, shown on a second click.
const PAINTINGS := {
	"le_repos": {"still": "p-le-repos"},
	"road": {"still": "p-road"},
	"sailboats": {"still": "p-sailboats"},
	"bonnet": {"still": "p-bonnet"},
	"poppies": {"still": "p-poppies", "photo": "monet-walk-meadows-argenteuil-1998.107"},
}
const APPROACH_S := 1.8
const STEP_S := 0.45

var _stop := "n0"
var _painting := ""  # "" while walking; the painting id while standing at it
var _photo := false
var _busy := false
# Two layers, each {tex, cam (a Rect2 in that still's pixels), alpha}; the top one fades in over the base.
var _base := {}
var _top := {}
var _over := {}  # the museum photograph, over a close-up
var _textures := {}


func _ready() -> void:
	clip_contents = true
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	_base = {"tex": _tex(STOPS[_stop].still), "cam": Rect2(Vector2.ZERO, IMAGE), "alpha": 1.0}
	_top = {}
	queue_redraw()


func _tex(still: String, ext := ".png") -> Texture2D:
	if not _textures.has(still):
		_textures[still] = load(DIR + still + ext)
	return _textures[still]


func _draw() -> void:
	for layer in [_base, _top, _over]:
		if layer.is_empty() or layer.tex == null:
			continue
		if layer.get("fit", false):  # the museum photograph: letterboxed on black, never stretched
			draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, layer.alpha))
			var ts: Vector2 = layer.tex.get_size()
			var fs := ts * minf(size.x / ts.x, size.y / ts.y)
			draw_texture_rect(layer.tex, Rect2((size - fs) / 2, fs), false, Color(1, 1, 1, layer.alpha))
			continue
		draw_texture_rect_region(layer.tex, Rect2(Vector2.ZERO, size), layer.cam, Color(1, 1, 1, layer.alpha))


func _full(tex: Texture2D) -> Rect2:
	return Rect2(Vector2.ZERO, tex.get_size())


# The view that frames a painting the way its close-up still does: the frame at ~3/4 of the height.
func _frame_on(rect: Rect2) -> Rect2:
	var h := minf(rect.size.y / 0.75, IMAGE.y)
	var cam := Rect2(Vector2.ZERO, Vector2(h * IMAGE.x / IMAGE.y, h))
	cam.position = (rect.get_center() - cam.size / 2).clamp(Vector2.ZERO, IMAGE - cam.size)
	return cam


func _set_cam(cam: Rect2, layer: Dictionary) -> void:
	layer.cam = cam
	queue_redraw()


func _set_alpha(a: float) -> void:
	_top.alpha = a
	queue_redraw()


# Fade a new still in over the current view while both drift by `drift` (a fraction of the view).
func _cut_to(still: String, from_cam_scale: float, drift: Vector2, secs: float) -> void:
	_busy = true
	var tex := _tex(still)
	var full := _full(tex)
	var start := Rect2(full.get_center() - full.size * from_cam_scale / 2 + drift * full.size, full.size * from_cam_scale)
	_top = {"tex": tex, "cam": start, "alpha": 0.0}
	var base_end := Rect2(_base.cam.get_center() - _base.cam.size / (2.0 * from_cam_scale) - drift * _base.cam.size,
			_base.cam.size / from_cam_scale)
	var t := create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_method(_set_cam.bind(_base), _base.cam, base_end, secs)
	t.tween_method(_set_cam.bind(_top), start, full, secs)
	t.tween_method(_set_alpha, 0.0, 1.0, secs)
	await t.finished
	_base = {"tex": tex, "cam": full, "alpha": 1.0}
	_top = {}
	_busy = false
	queue_redraw()


func _move(dir: String) -> void:
	if _busy:
		return
	if _painting != "":
		if dir == "down":
			_leave_painting()
		return
	var to: String = STOPS[_stop].get(dir, "")
	if to == "":
		return
	_stop = to
	match dir:
		"up": _cut_to(STOPS[to].still, 1.0 / 1.18, Vector2.ZERO, STEP_S)  # walk in: the old view grows past us
		"down": _cut_to(STOPS[to].still, 1.18, Vector2.ZERO, STEP_S)
		"left": _cut_to(STOPS[to].still, 1.0, Vector2(-0.12, 0), STEP_S)
		"right": _cut_to(STOPS[to].still, 1.0, Vector2(0.12, 0), STEP_S)


func _approach(id: String, rect: Rect2) -> void:
	_busy = true
	_painting = id
	var t := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	t.tween_method(_set_cam.bind(_base), _base.cam, _frame_on(rect), APPROACH_S)
	await t.finished
	var tex := _tex(PAINTINGS[id].still)
	_top = {"tex": tex, "cam": _full(tex), "alpha": 0.0}
	var f := create_tween()
	f.tween_method(_set_alpha, 0.0, 1.0, 0.5)
	await f.finished
	_busy = false


func _leave_painting() -> void:
	_busy = true
	_over = {}
	_photo = false
	var f := create_tween()
	f.tween_method(_set_alpha, 1.0, 0.0, 0.4)
	await f.finished
	_top = {}
	var t := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	t.tween_method(_set_cam.bind(_base), _base.cam, _full(_base.tex), APPROACH_S * 0.7)
	await t.finished
	_painting = ""
	_busy = false


# At a painting: a click fades the museum's own photograph in over the Muse close-up, or back out.
func _toggle_photo() -> void:
	var p: Dictionary = PAINTINGS[_painting]
	if not p.has("photo") or _busy:
		return
	_busy = true
	_photo = not _photo
	if _photo:
		var tex := _tex(p.photo, ".jpg")
		_over = {"tex": tex, "cam": _full(tex), "alpha": 0.0, "fit": true}
	var f := create_tween()
	f.tween_method(_set_over_alpha, _over.alpha, 1.0 if _photo else 0.0, 0.6)
	await f.finished
	if not _photo:
		_over = {}
	_busy = false


func _set_over_alpha(a: float) -> void:
	_over.alpha = a
	queue_redraw()


func _to_image(p: Vector2) -> Vector2:
	return _base.cam.position + p / size * _base.cam.size


func _hit(p: Vector2) -> Array:
	var ip := _to_image(p)
	for entry in STOPS[_stop].paintings:
		if entry[1].grow(12).has_point(ip):
			return entry
	return []


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not _busy:
		var over := _painting == "" and not _hit(event.position).is_empty()
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if over else Control.CURSOR_ARROW
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	grab_focus()
	accept_event()
	if _busy:
		return
	if _painting != "":
		if PAINTINGS[_painting].has("photo"):
			_toggle_photo()
		else:
			_leave_painting()
		return
	var hit := _hit(event.position)
	if not hit.is_empty():
		_approach(hit[0], hit[1])
	elif event.position.x < size.x * 0.18:
		_move("left")
	elif event.position.x > size.x * 0.82:
		_move("right")
	elif event.position.y > size.y * 0.62:
		_move("up")


func _unhandled_key_input(event: InputEvent) -> void:
	if not is_visible_in_tree() or not event.pressed or event.echo:
		return
	var dir := ""
	match event.keycode:
		KEY_UP, KEY_W: dir = "up"
		KEY_DOWN, KEY_S, KEY_ESCAPE: dir = "down"
		KEY_LEFT, KEY_A: dir = "left"
		KEY_RIGHT, KEY_D: dir = "right"
	if dir != "":
		get_viewport().set_input_as_handled()
		_move(dir)
