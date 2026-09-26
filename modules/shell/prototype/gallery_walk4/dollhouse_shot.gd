## Behaviour checks for #132, driven through the viewer's existing controls and input.
## Run: godot --rendering-method gl_compatibility --path . --script res://modules/shell/prototype/gallery_walk4/dollhouse_shot.gd
extends "res://testing/harness_base.gd"

var failures := 0
var walk: Control

func _require(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)

func _held_key(code: Key, seconds: float) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await create_timer(seconds).timeout
	event = InputEventKey.new()
	event.keycode = code
	Input.parse_input_event(event)
	await create_timer(0.2).timeout


func _choose_view(title: String) -> void:
	for choice in walk.find_children("*", "OptionButton", true, false):
		for index in choice.item_count:
			if choice.get_item_text(index) == title:
				# Public control setup; Chrome separately exercises the native popup.
				choice.select(index)
				choice.item_selected.emit(index)
				return
	_require(false, "camera choice missing: " + title)

func _initialize() -> void:
	var main: Control = load("res://modules/shell/demo.tscn").instantiate()
	var out := await _mount(main, Vector2i(1920, 1080), "/tmp/gallery-dollhouse")
	await create_timer(4).timeout
	walk = main.find_child("GalleryWalk", true, false)
	walk._pos = Vector3(-2.6, 0, -12)
	await create_timer(0.5).timeout
	await _shot(out, "01-dollhouse-baked.png")
	print("DOLLHOUSE_RENDER texture_bytes=", RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TEXTURE_MEM_USED), " draw_calls=", RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME))
	var image: Image = walk._vp.get_texture().get_image()
	for point in [Vector3(-4, 0, -12), Vector3(-5, 0.8, -12)]:
		var pixel: Vector2 = walk._cam.unproject_position(point)
		var color: Color = image.get_pixelv(Vector2i(pixel))
		_require(maxf(color.r, maxf(color.g, color.b)) > 0.08, "baked surface is black with runtime lights removed")
	_require(walk._vp.find_children("*", "Light3D", true, false).is_empty(), "runtime has a live light")
	if "--lighting-only" in OS.get_cmdline_user_args():
		quit(1 if failures else 0)
		return
	walk._lighting_choice.button_pressed = false
	await create_timer(0.3).timeout
	await _shot(out, "02-dollhouse-original-light.png")
	walk._lighting_choice.button_pressed = true
	await _choose_view("Gallery")
	await create_timer(0.3).timeout
	await _shot(out, "03-gallery-baked.png")
	await _choose_view("Dollhouse")
	# A held right key must move right on screen without rotating the fixed view.
	var before: Vector3 = walk._pos
	var orientation: Basis = walk._cam.global_basis
	await _held_key(KEY_D, 0.5)
	var motion: Vector3 = walk._pos - before
	_require(motion.dot(orientation.x) > 0.5, "right key did not move right relative to camera")
	_require(walk._cam.global_basis.is_equal_approx(orientation), "walking rotated fixed camera")
	# Quarter-turn through the real key path; focus loss must stop held input.
	await _key(KEY_E, "rotate view")
	_require(not walk._cam.global_basis.is_equal_approx(orientation), "E did not change viewing side")
	var down := InputEventKey.new()
	down.keycode = KEY_D
	down.pressed = true
	Input.parse_input_event(down)
	await create_timer(0.2).timeout
	walk.notification(Control.NOTIFICATION_APPLICATION_FOCUS_OUT)
	before = walk._pos
	await create_timer(0.4).timeout
	_require(walk._pos.distance_to(before) < 0.01, "focus loss left character moving")
	await _key(KEY_D, "release held right")
	# East paintings are cut away while looking west. Their projected locations
	# must not capture clicks on the visible room behind them.
	Engine.time_scale = 5
	walk._pos = Vector3(4, 0, -12)
	for i in 4:
		if absf(wrapf(walk.view_yaw - PI / 2, -PI, PI)) < 0.01:
			break
		await _key(KEY_E, "face west")
	await create_timer(0.2).timeout
	var hidden_checks := 0
	for painting in walk._paintings:
		if painting.normal.x > -0.5:
			continue
		var point: Vector2 = walk._cam.unproject_position(painting.center) / Vector2(walk._vp.size) * walk.size
		if not Rect2(Vector2.ZERO, walk.size).has_point(point):
			continue
		await _click(walk.global_position + point, "cutaway wall")
		await create_timer(12).timeout
		_require(walk._open.get("tag", "") != painting.tag, "cutaway painting intercepted click: " + painting.tag)
		hidden_checks += 1
		await _key(KEY_ESCAPE, "close visible art if opened")
		await _key(KEY_D, "cancel approach")
		break
	_require(hidden_checks > 0, "hidden-wall scenario projected no paintings")
	print("DOLLHOUSE_HIDDEN_WALL ", hidden_checks)
	Engine.time_scale = 5
	var opened := 0
	# Real room records, not a copied fixture inventory. Every actual painting must open.
	for painting in walk._paintings:
		walk._pos = painting.center + painting.normal * 2.6
		walk._pos.y = 0
		var wanted := atan2(painting.normal.x, painting.normal.z)
		for i in 4:
			if absf(wrapf(walk.view_yaw - wanted, -PI, PI)) < 0.01:
				break
			await _key(KEY_E, "view next wall")
		await create_timer(0.2).timeout
		var point: Vector2 = walk._cam.unproject_position(painting.center) / Vector2(walk._vp.size) * walk.size
		_require(Rect2(Vector2.ZERO, walk.size).has_point(point), "painting center outside view: " + painting.tag)
		await _click(walk.global_position + point, painting.tag)
		for i in 100:
			if not walk._open.is_empty():
				break
			await create_timer(0.1).timeout
		var correct: bool = walk._open.get("tag", "") == painting.tag
		_require(correct, "click failed to open " + painting.tag + "; opened " + str(walk._open.get("tag", "none")))
		if correct:
			opened += 1
		await _key(KEY_ESCAPE, "close art")
	print("DOLLHOUSE_ARTWORKS ", opened, "/", walk._paintings.size())
	Engine.time_scale = 1
	print("DOLLHOUSE_FAILURES ", failures)
	quit(1 if failures else 0)
