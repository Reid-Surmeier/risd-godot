## Review run on private copies of root's frozen v50r and v50u: more floor clicks and taps through the Hall door,
## and which door-frame pieces the camera cuts away. No baked-light node is read; v50u's added rooms are unbaked.
extends SceneTree

var walk
var output: String
var proof := {"clicks": [], "taps": [], "views": []}

func _initialize() -> void:
	call_deferred("run")

func send(code: int, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func place(space: String, mode: int, heading: float, at: Vector3) -> void:
	walk._entrance_waiting = false
	walk._entrance_active = false
	walk._space = space
	walk.view_mode = mode
	walk.view_yaw = heading if mode != 2 else 0.0
	walk._yaw = heading
	walk._view_turn_remaining = 0.0
	walk._velocity = Vector3.ZERO
	walk._held.clear()
	walk._target = null
	walk._target_yaw = null
	walk._path.clear()
	walk._stall_t = 0.0
	walk._pos = at
	walk._last_pos = at
	walk._kid.position = at
	walk._portal_flash.modulate.a = 0.0
	walk._update_camera(1.0)

# A click on the floor: the walk's own _walk_to with the floor point, as _click does. want: [space, x0, x1, z0, z1].
func click(name: String, space: String, at: Vector3, points: Array, want: Array) -> void:
	place(space, 0, 0.0, at)
	var stops := []
	var worst_step := 0.0
	var worst_at := []
	var worst_flash := 0.0
	var spaces := [space]
	var path := []
	for point in points:
		walk._walk_to(point)
		var target = walk._target
		var before: Vector3 = walk._pos
		for i in 400:
			walk._process(1.0 / 30.0)
			var step: float = walk._pos.distance_to(before)
			if step > worst_step:
				worst_step = step
				worst_at = [[before.x, before.z], [walk._pos.x, walk._pos.z]]
			before = walk._pos
			worst_flash = maxf(worst_flash, walk._portal_flash.modulate.a)
			path.append([snappedf(walk._pos.x, 0.001), snappedf(walk._pos.z, 0.001)])
			if walk._space != spaces[-1]:
				spaces.append(walk._space)
			if walk._target == null and walk._path.is_empty():
				break
		stops.append({"clicked": [point.x, point.z], "target": [target.x, target.z] if target != null else null,
			"stopped": [snappedf(walk._pos.x, 0.001), snappedf(walk._pos.z, 0.001)], "space": walk._space})
	var p: Vector3 = walk._pos
	proof.clicks.append({"name": name, "start": [at.x, at.z], "start_space": space, "clicks": stops, "spaces": spaces, "largest_step_m": worst_step,
		"largest_step_from_to": worst_at, "largest_flash_alpha": worst_flash, "path": path,
		"reached": walk._space == want[0] and p.x >= want[1] and p.x <= want[2] and p.z >= want[3] and p.z <= want[4]})

# Short presses in the follow view: each asks for one 1.0 m step.
func taps(name: String, space: String, heading: float, at: Vector3, code: int, count: int, want: Array) -> void:
	place(space, 2, heading, at)
	var stops := []
	var worst_step := 0.0
	var worst_flash := 0.0
	var spaces := [space]
	for n in count:
		send(code, true)
		await process_frame
		var before: Vector3 = walk._pos
		for i in 2:
			walk._process(1.0 / 30.0)
			worst_step = maxf(worst_step, walk._pos.distance_to(before))
			before = walk._pos
		send(code, false)
		await process_frame
		for i in 60:
			walk._process(1.0 / 30.0)
			worst_step = maxf(worst_step, walk._pos.distance_to(before))
			before = walk._pos
			worst_flash = maxf(worst_flash, walk._portal_flash.modulate.a)
			if walk._space != spaces[-1]:
				spaces.append(walk._space)
			if walk._target == null and walk._path.is_empty():
				break
		stops.append([snappedf(walk._pos.x, 0.001), snappedf(walk._pos.z, 0.001), walk._space])
	var p: Vector3 = walk._pos
	proof.taps.append({"name": name, "start": [at.x, at.z], "start_space": space, "taps": count, "stops": stops, "spaces": spaces, "largest_step_m": worst_step,
		"largest_flash_alpha": worst_flash, "heading_kept": absf(wrapf(walk._yaw - heading, -PI, PI)) < 0.0001,
		"reached": walk._space == want[0] and p.x >= want[1] and p.x <= want[2] and p.z >= want[3] and p.z <= want[4]})

# The game's camera. For every door header: is one of its drawn pieces on a line from the camera to the visitor?
func view(name: String, space: String, mode: int, heading: float, at: Vector3) -> void:
	place(space, mode, heading, at)
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	assert(walk._vp.get_texture().get_image().save_png(output.path_join("game-" + name + ".png")) == OK)
	var eye: Vector3 = walk._cam.global_position
	var across: Vector3 = walk._cam.global_transform.basis.x
	across.y = 0.0
	var hidden := []
	var in_the_way := []
	for wall in walk._walls:
		var body: Node = wall.body
		var tag := str(body.get_meta("room_wall", body.name))
		if not body.get_child(1).visible:
			hidden.append(tag)
		if not tag.ends_with(":header"):
			continue
		for part in body.get_children():
			if not part is MeshInstance3D or part.mesh == null or part.mesh.get_surface_count() == 0:
				continue
			var box: AABB = part.global_transform * part.get_aabb()
			var hit := false
			for offset in [-0.45, 0.0, 0.45]:
				for height in [0.5, 1.5]:
					if box.intersects_segment(eye, at + across * offset + Vector3(0, height, 0)) != null:
						hit = true
			if hit:
				in_the_way.append({"header": tag, "piece_size": [snappedf(box.size.x, 0.01), snappedf(box.size.y, 0.01), snappedf(box.size.z, 0.01)], "still_drawn": part.visible})
	proof.views.append({"name": name, "space": space, "view_mode": mode, "heading": heading, "position": [at.x, at.z], "camera": [eye.x, eye.y, eye.z],
		"hidden_cutaway_bodies": hidden, "header_pieces_between_camera_and_visitor": in_the_way})

func run() -> void:
	output = OS.get_cmdline_user_args()[0]
	root.size = Vector2i(1440, 1000)
	var app = load("res://modules/shell/demo.tscn").instantiate()
	root.add_child(app)
	for i in 150: await process_frame
	walk = app.find_child("GalleryWalk", true, false)
	assert(walk != null and walk.state().attached)
	walk.set_process(false)
	walk._set_lighting(true)
	proof["state"] = walk.state()
	var leaves := 0
	for wall in walk._walls:
		if wall.body.has_meta("hall_reveal_leaf"):
			leaves += 1
	proof["hall_leaves_in_cutaway_list"] = leaves
	var L: float = walk.L
	var far_z := -L - 0.76 - 6.0  # the grey gallery's north wall
	var hall := ["gallery", -5.0, 5.0, -L + 0.5, 0.0]
	var grey := ["far", -1.7, 5.5, far_z, -L - 0.76 - 0.3]
	var west := ["arch", -11.1, -5.0, -L + 0.5, 0.0]
	var rock := ["far", -10.25, -3.85, -L - 0.76 - 6.8, -L - 0.76 - 0.3]
	# Clicks. Each list is the floor points clicked in turn.
	await click("grey-to-hall-on-axis", "far", Vector3(0, 0, -28.3), [Vector3(0, 0, -24.5)], hall)
	await click("hall-to-grey-on-axis", "gallery", Vector3(0, 0, -24.5), [Vector3(0, 0, -28.3)], grey)
	await click("grey-to-hall-from-inside-passage", "far", Vector3(0, 0, -26.7), [Vector3(0, 0, -24.5)], hall)
	await click("grey-to-hall-target-off-axis-line-through-door", "far", Vector3(0.2, 0, -27.6), [Vector3(-0.6, 0, -24.0)], hall)
	await click("grey-to-hall-line-misses-door", "far", Vector3(3.0, 0, -28.5), [Vector3(-2.0, 0, -24.0)], hall)
	await click("grey-to-hall-line-misses-door-then-second-click", "far", Vector3(3.0, 0, -28.5), [Vector3(-2.0, 0, -24.0), Vector3(-2.0, 0, -24.0)], hall)
	await click("grey-to-hall-shallow-diagonal", "far", Vector3(1.5, 0, -27.4), [Vector3(-1.0, 0, -25.4)], hall)
	await click("hall-to-grey-line-misses-door", "gallery", Vector3(3.0, 0, -22.0), [Vector3(1.5, 0, -29.0)], grey)
	await click("hall-to-grey-line-misses-door-then-second-click", "gallery", Vector3(3.0, 0, -22.0), [Vector3(1.5, 0, -29.0), Vector3(1.5, 0, -29.0)], grey)
	await click("hall-to-grey-long-past-benches", "gallery", Vector3(0, 0, -12.0), [Vector3(0, 0, -29.0)], grey)
	await click("grey-to-hall-long-past-bench", "far", Vector3(0, 0, -29.0), [Vector3(0, 0, -19.5)], ["gallery", -5.0, 5.0, -20.5, -18.5])
	await click("hall-click-on-far-side-of-its-north-wall-away-from-door", "gallery", Vector3(3.0, 0, -24.0), [Vector3(3.0, 0, -28.5)], ["gallery", -5.0, 5.0, -L + 0.5, 0.0])
	await click("grey-click-into-the-wall-thickness-beside-door", "far", Vector3(2.5, 0, -28.5), [Vector3(2.5, 0, -26.7)], ["far", -1.7, 5.5, far_z, -L - 0.76 - 0.3])
	await click("rockefeller-to-west", "far", Vector3(-8.05, 0, -28.3), [Vector3(-8.05, 0, -24.5)], west)
	await click("west-to-rockefeller", "arch", Vector3(-8.05, 0, -24.5), [Vector3(-8.05, 0, -28.3)], rock)
	await click("rockefeller-to-west-diagonal", "far", Vector3(-6.5, 0, -28.5), [Vector3(-9.5, 0, -24.0)], west)
	# Taps.
	for z in [-28.3, -28.0, -27.7, -27.3, -26.9, -26.6, -26.38]:
		await taps("grey-to-hall-forward-from-%.2f" % -z, "far", PI, Vector3(0, 0, z), KEY_UP, 6, hall)
	await taps("grey-to-hall-backward-from-28.0", "far", 0.0, Vector3(0, 0, -28.0), KEY_DOWN, 6, hall)
	await taps("grey-to-hall-forward-0.3-off-centre", "far", PI, Vector3(0.3, 0, -27.7), KEY_UP, 6, hall)
	await taps("grey-to-hall-forward-heading-17deg", "far", PI + 0.3, Vector3(-0.4, 0, -27.7), KEY_UP, 6, hall)
	for z in [-25.0, -24.7, -24.2]:
		await taps("hall-to-grey-forward-from-%.2f" % -z, "gallery", 0.0, Vector3(0, 0, z), KEY_UP, 6, grey)
	await taps("hall-to-grey-backward-from-25.0", "gallery", PI, Vector3(0, 0, -25.0), KEY_DOWN, 6, grey)
	await taps("rockefeller-to-west-forward", "far", PI, Vector3(-8.05, 0, -28.3), KEY_UP, 6, west)
	await taps("west-to-rockefeller-forward", "arch", 0.0, Vector3(-8.05, 0, -25.0), KEY_UP, 6, rock)
	# Door frames and the camera. Side-on: the camera looks along the wall, across the door.
	for door in [["hall", 0.0], ["rockefeller", -8.05]]:
		for spot in [["grey-jamb", -L - 0.76], ["middle", -L - 0.38], ["hall-side-jamb", -L - 0.02]]:
			var space := "far"
			for side in [["west", PI / 2], ["east", -PI / 2]]:
				await view("%s-%s-dollhouse-%s" % [door[0], spot[0], side[0]], space, 0, side[1], Vector3(door[1], 0, spot[1]))
			await view("%s-%s-gallery-view-west" % [door[0], spot[0]], space, 1, PI / 2, Vector3(door[1], 0, spot[1]))
		# Head-on: the visitor is seen through the empty opening.
		await view("%s-front-follow-north-in-passage" % door[0], "far", 2, 0.0, Vector3(door[1], 0, -L - 0.38))
		await view("%s-front-follow-south-in-passage" % door[0], "far", 2, PI, Vector3(door[1], 0, -L - 0.38))
		await view("%s-front-follow-north-beyond-door" % door[0], "far", 2, 0.0, Vector3(door[1], 0, -L - 0.76 - 1.2))
		await view("%s-front-follow-south-before-door" % door[0], "far", 2, PI, Vector3(door[1], 0, -L - 0.76 - 2.2))
		await view("%s-front-follow-north-at-passage-edge" % door[0], "far", 2, 0.0, Vector3(door[1] + 0.6, 0, -L - 0.38))
		await view("%s-front-dollhouse-north-in-passage" % door[0], "far", 0, 0.0, Vector3(door[1], 0, -L - 0.38))
		await view("%s-front-dollhouse-south-in-passage" % door[0], "far", 0, PI, Vector3(door[1], 0, -L - 0.38))
		await view("%s-front-dollhouse-south-visitor-in-room-beyond" % door[0], "far", 0, PI, Vector3(door[1], 0, -L - 0.76 - 2.9))
	# Other doors with the same frame, for the same rule.
	await view("renaissance-north-door-dollhouse-west", "arch", 0, PI / 2, Vector3(-8.05, 0, 0.0))
	await view("renaissance-north-door-dollhouse-east", "arch", 0, -PI / 2, Vector3(-8.05, 0, 0.0))
	await view("renaissance-north-door-follow-north", "arch", 2, 0.0, Vector3(-8.05, 0, 1.2))
	await view("piano-door-dollhouse-west", "far", 0, PI / 2, Vector3(0, 0, far_z))
	await view("connector-door-dollhouse-north", "far", 0, 0.0, Vector3(-1.7, 0, -L - 0.76 - 0.18))
	await view("connector-door-dollhouse-south", "far", 0, PI, Vector3(-1.7, 0, -L - 0.76 - 0.18))
	FileAccess.open(output.path_join("native-target-jamb.json"), FileAccess.WRITE).store_string(JSON.stringify(proof, "\t") + "\n")
	print("REVIEW_TARGET_JAMB_OK")
	quit()
