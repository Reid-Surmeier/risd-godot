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

func _face(wanted: float) -> void:
	# Q/E now ease like pointer orbit. Wait for each real turn, rather than
	# queuing four turns against the same intermediate orientation.
	for attempt in 4:
		for frame in 180:
			if absf(walk._view_turn_remaining) < 0.001:
				break
			await process_frame
		_require(absf(walk._view_turn_remaining) < 0.001, "camera turn did not settle")
		if absf(wrapf(walk.view_yaw - wanted, -PI, PI)) < 0.01:
			return
		await _key(KEY_E, "view next wall")
	_require(false, "real turn input did not reach requested wall")


func _close_art() -> void:
	await _key(KEY_ESCAPE, "close art")
	for frame in 180:
		if walk._open.is_empty() and not walk._detail.visible:
			return
		await process_frame
	_require(false, "artwork detail did not close")


func _observe_steps(code: Key, seconds: float) -> int:
	var started := 0
	var playing := {}
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	var elapsed := 0.0
	while elapsed < seconds:
		await process_frame
		elapsed += walk.get_process_delta_time()
		for name in walk._sfx:
			if not str(name).begins_with("step"):
				continue
			var active: bool = walk._sfx[name].playing
			if active and not playing.get(name, false):
				started += 1
			playing[name] = active
	event = InputEventKey.new()
	event.keycode = code
	Input.parse_input_event(event)
	await create_timer(0.5).timeout
	return started


func _initialize() -> void:
	var main: Control = load("res://modules/shell/demo.tscn").instantiate()
	var out := await _mount(main, Vector2i(1920, 1080), "/tmp/gallery-dollhouse")
	await create_timer(4).timeout
	walk = main.find_child("GalleryWalk", true, false)
	walk._new_action()
	walk._target = null
	walk.view_yaw = PI / 2.0
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
	var bevel_faces := 0
	for mesh in walk._baked_room.get_children():
		if not mesh is MeshInstance3D or not mesh.material_override is StandardMaterial3D:
			continue
		if not mesh.material_override.albedo_color.is_equal_approx(Color("#2f3a52")):
			continue
		for surface in mesh.mesh.get_surface_count():
			var arrays: Array = mesh.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			for i in range(0, indices.size(), 3):
				var a := indices[i]
				var geometric := (vertices[indices[i + 2]] - vertices[a]).cross(vertices[indices[i + 1]] - vertices[a])
				_require(geometric.dot(normals[a]) > 0.0, "bench winding opposes its shaded face normal")
				if absf(normals[a].y) > 0.01 and absf(normals[a].y) < 0.99:
					bevel_faces += 1
	_require(bevel_faces > 0, "bench has no sloped upholstery faces")
	print("DOLLHOUSE_BENCH_BEVEL faces=", bevel_faces)
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
	_require(not walk._view_panel.visible, "comparison toolbar visible by default")
	var bay: float = walk._pos.z
	var wall_button: Button = walk.get_node("OtherWall")
	await _click(wall_button.global_position + wall_button.size / 2, "other wall shortcut")
	await create_timer(0.3).timeout
	_require(walk._pos.x > 0 and is_equal_approx(walk._pos.z, bay), "other wall did not cross to the same bay")
	_require(sin(walk.view_yaw) < -0.9, "other wall did not face east")
	await _shot(out, "04-other-wall.png")
	await _click(wall_button.global_position + wall_button.size / 2, "return to west wall")
	await create_timer(0.3).timeout
	_require(walk._pos.x < 0 and sin(walk.view_yaw) > 0.9, "other wall did not return west")
	print("DOLLHOUSE_OTHER_WALL both directions")
	var cadence := await _observe_steps(KEY_D, 2.0)
	_require(cadence >= 6 and cadence <= 9, "two-second walking cadence outside 6–9 audible contacts: " + str(cadence))
	walk._pos = Vector3(-4.45, 0, -12)
	await create_timer(0.2).timeout
	var blocked_steps := await _observe_steps(KEY_W, 1.0)
	_require(blocked_steps == 0, "walking into a wall produced footsteps")
	print("DOLLHOUSE_FOOTSTEPS contacts_2s=", cadence, " blocked=", blocked_steps)
	walk._pos = Vector3(-2.6, 0, -12)
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
	await _face(PI / 2)
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
		await _close_art()
		await _key(KEY_D, "cancel approach")
		break
	_require(hidden_checks > 0, "hidden-wall scenario projected no paintings")
	print("DOLLHOUSE_HIDDEN_WALL ", hidden_checks)
	Engine.time_scale = 5
	var opened := 0
	# Real room records, not a copied fixture inventory. Every actual painting must open.
	for painting in walk._paintings:
		walk._new_action()
		walk._target = null
		walk._velocity = Vector3.ZERO
		walk._pos = painting.center + painting.normal * 2.6
		walk._pos.y = 0
		var wanted := atan2(painting.normal.x, painting.normal.z)
		await _face(wanted)
		await create_timer(0.2).timeout
		# #189 closer framing can crop tall artwork; click its visible portion.
		var outline: PackedVector2Array = walk._visible_outline(painting.corners)
		var clipped := Geometry2D.intersect_polygons(outline, PackedVector2Array([Vector2.ZERO, Vector2(walk.size.x, 0), walk.size, Vector2(0, walk.size.y)]))
		if not clipped.is_empty():
			outline = clipped[0]
		_require(outline.size() >= 3, "painting entirely outside view: " + painting.tag)
		var point := Vector2.ZERO
		for vertex in outline:
			point += vertex / outline.size()
		await _click(walk.global_position + point, painting.tag)
		for i in 100:
			if not walk._open.is_empty():
				break
			await create_timer(0.1).timeout
		var correct: bool = walk._open.get("tag", "") == painting.tag
		_require(correct, "click failed to open " + painting.tag + "; opened " + str(walk._open.get("tag", "none")))
		if correct:
			opened += 1
		await _close_art()
	_require(not walk._view_panel.visible, "closing artwork restored the removed toolbar")
	print("DOLLHOUSE_ARTWORKS ", opened, "/", walk._paintings.size())
	Engine.time_scale = 1
	print("DOLLHOUSE_FAILURES ", failures)
	quit(1 if failures else 0)
