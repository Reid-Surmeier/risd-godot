## Review run on private copies of root's frozen v50p and v50r: my own key walks through both wall doors.
## Real key events through Input.parse_input_event; the walk is then stepped by hand at 30 frames a second.
extends SceneTree

var walk
var output: String
var proof := {"traces": [], "taps": [], "clicks": [], "pictures": []}
const KEYS := {"up": KEY_UP, "down": KEY_DOWN, "left": KEY_LEFT, "right": KEY_RIGHT}

func _initialize() -> void:
	call_deferred("run")

func send(key: String, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = KEYS[key]
	event.physical_keycode = KEYS[key]
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
	walk._pos = at
	walk._last_pos = at
	walk._kid.position = at
	walk._portal_flash.modulate.a = 0.0
	walk._update_camera(1.0)

# done: [axis, sign, value, space] — stop once sign * position[axis] >= value in that space.
func trace(name: String, group: String, space: String, mode: int, heading: float, at: Vector3, keys: Array, done: Array, frames_max := 300) -> void:
	place(space, mode, heading, at)
	for key in keys:
		send(key, true)
	await process_frame
	var delivered: bool = walk._held.size() == keys.size()
	var spaces := [space]
	var path := []
	var worst_step := 0.0
	var worst_at := []
	var worst_flash := 0.0
	var leaf_x := 0.0  # farthest from the door's centre line while between the Hall leaves
	var before: Vector3 = walk._pos
	var frames := 0
	var reached := false
	var heading_start: float = walk.view_yaw if mode != 2 else walk._yaw
	for i in frames_max:
		walk._process(1.0 / 30.0)
		frames += 1
		var step: float = walk._pos.distance_to(before)
		if step > worst_step:
			worst_step = step
			worst_at = [[before.x, before.z], [walk._pos.x, walk._pos.z], walk._space]
		before = walk._pos
		worst_flash = maxf(worst_flash, walk._portal_flash.modulate.a)
		path.append([snappedf(walk._pos.x, 0.001), snappedf(walk._pos.z, 0.001)])
		if walk._pos.z > -27.25 and walk._pos.z < -26.3 and absf(walk._pos.x) < 2.0:
			leaf_x = maxf(leaf_x, absf(walk._pos.x))
		if walk._space != spaces[-1]:
			spaces.append(walk._space)
		if done[1] * walk._pos[done[0]] >= done[2] and walk._space == done[3]:
			reached = true
			break
	for key in keys:
		send(key, false)
	await process_frame
	var released: bool = walk._held.is_empty()
	var heading_end: float = walk.view_yaw if mode != 2 else walk._yaw
	proof.traces.append({"name": name, "group": group, "view_mode": mode, "heading": heading, "keys": keys, "start": [at.x, at.z], "start_space": space,
		"end": [walk._pos.x, walk._pos.z], "end_space": walk._space, "frames": frames, "spaces": spaces, "space_changes": spaces.size() - 1,
		"largest_step_m": worst_step, "largest_step_from_to": worst_at, "largest_flash_alpha": worst_flash, "key_delivered": delivered, "key_released": released,
		"heading_kept": absf(wrapf(heading_end - heading_start, -PI, PI)) < 0.0001, "farthest_from_centre_between_leaves_m": leaf_x, "reached": reached, "path": path})

# Short presses in the follow view: each press asks for one 1.0 m step.
func taps(name: String, space: String, heading: float, at: Vector3, key: String, count: int, done: Array) -> void:
	place(space, 2, heading, at)
	var stops := []
	var worst_step := 0.0
	var spaces := [space]
	for n in count:
		send(key, true)
		await process_frame
		var before: Vector3 = walk._pos
		for i in 2:
			walk._process(1.0 / 30.0)
			worst_step = maxf(worst_step, walk._pos.distance_to(before))
			before = walk._pos
		send(key, false)
		await process_frame
		for i in 60:
			walk._process(1.0 / 30.0)
			worst_step = maxf(worst_step, walk._pos.distance_to(before))
			before = walk._pos
			if walk._space != spaces[-1]:
				spaces.append(walk._space)
			if walk._target == null and walk._path.is_empty():
				break
		stops.append([snappedf(walk._pos.x, 0.001), snappedf(walk._pos.z, 0.001), walk._space])
	proof.taps.append({"name": name, "key": key, "start": [at.x, at.z], "start_space": space, "taps": count, "stops": stops, "spaces": spaces,
		"largest_step_m": worst_step, "reached": done[1] * walk._pos[done[0]] >= done[2] and walk._space == done[3]})

# A click on the floor: the walk's own _walk_to, which is what _click calls with the floor point.
func click(name: String, space: String, at: Vector3, points: Array, done: Array) -> void:
	place(space, 0, 0.0, at)
	var stops := []
	var worst_step := 0.0
	var spaces := [space]
	for point in points:
		walk._walk_to(point)
		var before: Vector3 = walk._pos
		for i in 300:
			walk._process(1.0 / 30.0)
			worst_step = maxf(worst_step, walk._pos.distance_to(before))
			before = walk._pos
			if walk._space != spaces[-1]:
				spaces.append(walk._space)
			if walk._target == null and walk._path.is_empty():
				break
		stops.append({"clicked": [point.x, point.z], "stopped": [snappedf(walk._pos.x, 0.001), snappedf(walk._pos.z, 0.001)], "space": walk._space})
	proof.clicks.append({"name": name, "start": [at.x, at.z], "start_space": space, "clicks": stops, "spaces": spaces, "largest_step_m": worst_step,
		"reached": done[1] * walk._pos[done[0]] >= done[2] and walk._space == done[3]})

func picture(name: String, space: String, mode: int, heading: float, at: Vector3) -> void:
	place(space, mode, heading, at)
	for i in 6: await process_frame
	await RenderingServer.frame_post_draw
	assert(walk._vp.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK)
	proof.pictures.append({"name": name, "space": space, "view_mode": mode, "heading": heading, "position": [at.x, at.z]})

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
	var L: float = walk.L
	var in_hall := [2, 1.0, -L + 1.0, "gallery"]      # a metre inside the Hall
	var in_grey := [2, -1.0, L + 1.7, "far"]           # past the passage, in the grey gallery
	var in_west := [2, 1.0, -L + 1.0, "arch"]
	var in_rock := [2, -1.0, L + 1.7, "far"]
	# Follow view. Heading 0 faces north, PI faces south.
	await trace("follow-grey-to-hall-forward", "follow", "far", 2, PI, Vector3(0, 0, -28.3), ["up"], in_hall)
	await trace("follow-grey-to-hall-backward", "follow", "far", 2, 0.0, Vector3(0, 0, -28.3), ["down"], in_hall)
	await trace("follow-hall-to-grey-forward", "follow", "gallery", 2, 0.0, Vector3(0, 0, -25.0), ["up"], in_grey)
	await trace("follow-hall-to-grey-backward", "follow", "gallery", 2, PI, Vector3(0, 0, -25.0), ["down"], in_grey)
	await trace("follow-grey-to-hall-forward-0.3-off-centre", "follow", "far", 2, PI, Vector3(0.3, 0, -28.3), ["up"], in_hall)
	await trace("follow-grey-to-hall-forward-heading-17deg-east", "follow", "far", 2, PI + 0.3, Vector3(-0.45, 0, -28.0), ["up"], in_hall)
	await trace("follow-grey-to-hall-forward-heading-17deg-west", "follow", "far", 2, PI - 0.3, Vector3(0.45, 0, -28.0), ["up"], in_hall)
	await trace("follow-hall-to-grey-forward-heading-17deg-east", "follow", "gallery", 2, -0.3, Vector3(-0.3, 0, -25.2), ["up"], in_grey)
	await trace("follow-rockefeller-to-west-forward", "follow", "far", 2, PI, Vector3(-8.05, 0, -28.3), ["up"], in_west)
	await trace("follow-rockefeller-to-west-backward", "follow", "far", 2, 0.0, Vector3(-8.05, 0, -28.3), ["down"], in_west)
	await trace("follow-west-to-rockefeller-forward", "follow", "arch", 2, 0.0, Vector3(-8.05, 0, -25.0), ["up"], in_rock)
	await trace("follow-west-to-rockefeller-backward", "follow", "arch", 2, PI, Vector3(-8.05, 0, -25.0), ["down"], in_rock)
	# Two keys, dollhouse (0) and gallery (1) views, camera facing north: up is north, right is east.
	for mode in [0, 1]:
		var tag := "dollhouse" if mode == 0 else "gallery-view"
		await trace(tag + "-grey-to-hall-from-east", "diagonal", "far", mode, 0.0, Vector3(1.6, 0, -28.6), ["down", "left"], in_hall)
		await trace(tag + "-grey-to-hall-from-west", "diagonal", "far", mode, 0.0, Vector3(-1.6, 0, -28.6), ["down", "right"], in_hall)
		await trace(tag + "-hall-to-grey-from-west", "diagonal", "gallery", mode, 0.0, Vector3(-1.2, 0, -25.0), ["up", "right"], in_grey)
		await trace(tag + "-hall-to-grey-from-east", "diagonal", "gallery", mode, 0.0, Vector3(1.2, 0, -25.0), ["up", "left"], in_grey)
		await trace(tag + "-rockefeller-to-west-from-east", "diagonal", "far", mode, 0.0, Vector3(-6.9, 0, -28.4), ["down", "left"], in_west)
		await trace(tag + "-west-to-rockefeller-from-west", "diagonal", "arch", mode, 0.0, Vector3(-9.3, 0, -25.0), ["up", "right"], in_rock)
	# Camera turned a quarter: heading PI/2 faces west, so left is south and right is north.
	await trace("dollhouse-facing-west-grey-to-hall-south-and-west", "diagonal", "far", 0, PI / 2, Vector3(1.4, 0, -28.4), ["left", "up"], in_hall)
	await trace("dollhouse-facing-west-hall-to-grey-north-and-east", "diagonal", "gallery", 0, PI / 2, Vector3(-1.2, 0, -25.0), ["right", "down"], in_grey)
	# Sideways only, standing in the Hall's own door recess: must stop at the jamb and not jump.
	await trace("recess-sideways-east", "recess", "gallery", 0, 0.0, Vector3(0, 0, -26.0), ["right"], [0, 1.0, 99.0, "gallery"], 60)
	await trace("recess-sideways-west", "recess", "gallery", 0, 0.0, Vector3(0, 0, -26.2), ["left"], [0, -1.0, 99.0, "gallery"], 60)
	await trace("recess-out-diagonal-into-hall", "recess", "gallery", 0, 0.0, Vector3(0, 0, -26.2), ["down", "right"], [2, 1.0, -L + 1.0, "gallery"])
	# Straight, as before.
	await trace("dollhouse-hall-to-grey-straight", "straight", "gallery", 0, 0.0, Vector3(0, 0, -25.0), ["up"], in_grey)
	await trace("dollhouse-grey-to-hall-straight", "straight", "far", 0, 0.0, Vector3(0, 0, -28.3), ["down"], in_hall)
	await trace("dollhouse-west-to-rockefeller-straight", "straight", "arch", 0, 0.0, Vector3(-8.05, 0, -25.0), ["up"], in_rock)
	await trace("dollhouse-rockefeller-to-west-straight", "straight", "far", 0, 0.0, Vector3(-8.05, 0, -28.3), ["down"], in_west)
	# Along the Hall's north wall past its door, holding toward the wall: the Hall's own behaviour.
	await trace("hall-along-north-wall-past-door", "hall", "gallery", 0, 0.0, Vector3(2.0, 0, -25.3), ["left"], [0, -1.0, 2.0, "gallery"], 150)
	for z in [-28.3, -28.0, -27.7]:
		await taps("taps-grey-to-hall-from-%.1f" % -z, "far", PI, Vector3(0, 0, z), "up", 6, in_hall)
	for z in [-25.0, -24.7]:
		await taps("taps-hall-to-grey-from-%.1f" % -z, "gallery", 0.0, Vector3(0, 0, z), "up", 6, in_grey)
	await taps("taps-rockefeller-to-west", "far", PI, Vector3(-8.05, 0, -28.3), "up", 6, in_west)
	await taps("taps-west-to-rockefeller", "arch", 0.0, Vector3(-8.05, 0, -25.0), "up", 6, in_rock)
	await click("click-grey-to-hall", "far", Vector3(0, 0, -28.3), [Vector3(0, 0, -24.5), Vector3(0, 0, -24.5)], in_hall)
	await click("click-hall-to-grey", "gallery", Vector3(0, 0, -24.5), [Vector3(0, 0, -28.3), Vector3(0, 0, -28.3)], in_grey)
	await click("click-rockefeller-to-west", "far", Vector3(-8.05, 0, -28.3), [Vector3(-8.05, 0, -24.5), Vector3(-8.05, 0, -24.5)], in_west)
	await click("click-west-to-rockefeller", "arch", Vector3(-8.05, 0, -24.5), [Vector3(-8.05, 0, -28.3), Vector3(-8.05, 0, -28.3)], in_rock)
	await picture("visitor-at-passage-edge-follow-north", "far", 2, 0.0, Vector3(0.6, 0, -26.68))
	await picture("visitor-at-passage-edge-dollhouse-north", "far", 0, 0.0, Vector3(0.6, 0, -26.68))
	await picture("visitor-at-grey-door-edge-follow-south", "far", 2, PI, Vector3(0.72, 0, -27.12))
	await picture("visitor-in-recess-at-jamb-dollhouse-north", "gallery", 0, 0.0, Vector3(0.399, 0, -26.0))
	FileAccess.open(output.path_join("native-passage.json"), FileAccess.WRITE).store_string(JSON.stringify(proof, "\t") + "\n")
	print("REVIEW_PASSAGE_OK")
	quit()
