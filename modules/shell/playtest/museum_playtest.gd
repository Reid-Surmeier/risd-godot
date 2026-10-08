## Whole-museum playtest (docs/playtest/museum-playtest-rules.md is the contract).
## 1 doors:   every doorway is crossed on foot in both directions with held keys.
## 2 rooms:   from each of its doors, a click on the middle of every room walks there.
## 3 views:   every standpoint is photographed from four dollhouse directions and the follow
##            view; a view the wall fills, or one that hides the visitor, is a failure.
## 4 objects: every artwork is clicked with a real mouse event; the visitor must walk up,
##            a detail must open, and it must close again.
## 5 interaction: the faults a player found by playing (#280), each replayed with real
##            pointer events: "Other wall" pressed while a work is being read; a click on
##            every room's walls (no walk) and in every doorway (a walk through); a click on
##            a work whose box another work's box overlaps on screen; "Other wall" pressed
##            while a room change is under way.
## 6 light:   every room has a lamp, every work a lamp aimed at it, and a pool round its works.
## source ~/promo-lab/gpu-env.sh   (the RTX through Mesa d3d12; llvmpipe is ten times slower)
## godot --fixed-fps 60 --path . --script res://modules/shell/playtest/museum_playtest.gd
##   --display-driver x11 --rendering-driver opengl3 -- --out-dir=<dir>
## Options: --only=doors,rooms,views,objects,interaction,light; --room=<label>; --shell=true; --width/height=<px>.
## --fixed-fps makes every frame one sixtieth of a second of game time, so a run is repeatable.
extends SceneTree

const SIZE := Vector2i(960, 640)
# A work being read: the least share of the picture's height it stands, and the most of its
# screen rectangle the caption panel may cover (#272).
const READ_HEIGHT := 0.25
const READ_COVERED := 0.02
const READ_FACE := 0.6  # the least of a flat work's face that shows
const READ_SQUARE := 0.6  # the least the lens leans to a work's face: 1 square on, 0 edge on
const READ_VISITOR := 0.1  # the most of the picture the visitor's box may take
const READ_CLEAR := 0.8  # metres before a work within which a drawn thing is its own mount
const READ_GLASS := 1.5  # and within which a thin pane is the glass of its own case
const READ_IN := 1.4  # a clicked doorway carries the visitor at least this far past its sill
const READ_THROUGH := 3.8  # and no further than this
const HALL := "Grand Gallery"

var walk
var out := ""
var report := {
	"doors": [], "rooms": [], "views": [], "objects": [], "interaction": [], "light": [], "failures": []
}


func _initialize() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--" + name + "="):
			return arg.get_slice("=", 1)
	return fallback


func _fail(kind: String, what: String, detail := {}) -> void:
	report.failures.append({"kind": kind, "what": what, "detail": detail})
	print("PLAYTEST_FAIL ", kind, ": ", what)


func _run() -> void:
	out = _arg("out-dir", "res://build/museum-playtest")
	var only := _arg("only", "doors,rooms,views,objects,interaction,light").split(",")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	root.size = Vector2i(int(_arg("width", str(SIZE.x))), int(_arg("height", str(SIZE.y))))
	if _arg("shell", "false") == "true":
		var demo = load("res://modules/shell/demo.tscn").instantiate()
		root.add_child(demo)
		for i in 240:
			await process_frame
		walk = demo.find_child("GalleryWalk", true, false)
	else:
		walk = (
			load("res://modules/shell/prototype/collection_reconstruction/main_build_walk.gd").new()
		)
		walk.size = Vector2(root.size)
		root.add_child(walk)
		# The rooms would begin building themselves two seconds after the Hall shows (#281).
		# The cases marked "at launch" want them not yet begun, so here they wait until the
		# visitor is first put in one; stepped_build_check.gd covers the build in steps.
		walk.set("_build_clock", -1.0e9)
		for i in 240:
			await process_frame
	# The room scene is built the first time the visitor leaves the Hall (#281).
	if not walk.state().attached and not walk.state().get("pending", false):
		_fail("setup", "the room scene is neither attached nor waiting to be")
	walk._new_action()
	if "doors" in only:
		await _doors()
	if "rooms" in only:
		await _rooms()
	if "views" in only:
		await _views()
	if "objects" in only:
		await _objects()
	if "interaction" in only:
		await _interaction()
	if "light" in only:
		await _light()
	report["state"] = walk.state()
	report["summary"] = {
		"doors": report.doors.size(),
		"off_centre": (report.get("off_centre", []) as Array).size(),
		"rooms": report.rooms.size(),
		"views": report.views.size(),
		"objects": report.objects.size(),
		"interaction": report.interaction.size(),
		"light": report.light.size(),
		"failures": report.failures.size()
	}
	var file := FileAccess.open(out.path_join("report.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, " "))
	file.close()
	print("MUSEUM_PLAYTEST ", JSON.stringify(report.summary))
	quit(0 if report.failures.is_empty() else 1)


# ---------------------------------------------------------------- the plan of the museum


func _areas() -> Array:
	var areas := [{"label": HALL, "space": "gallery", "b": [-5.0, 5.0, -walk.L, 0.0]}]
	for room in walk._plan:
		areas.append({"label": room.label, "space": "far" if room.far else "arch", "b": room.b})
	return areas


func _area_at(p: Vector3) -> String:
	var index: int = walk._room_at(p)
	if index >= 0:
		return walk._plan[index].label
	if absf(p.x) <= 5.0 and p.z <= 0.0 and p.z >= -walk.L:
		return HALL
	return ""


# Every doorway once: {a, b: area labels, from, to: points 0.9 m inside each side}.
func _doorways() -> Array:
	# Where a visitor can stand beside a door depends on the furniture, which exists only once
	# the rooms are built: step into the medieval room first.
	if not walk.state().attached:
		_place(Vector3(0, 0, walk.PORTAL_MOUTH + 0.9))
	var doors := [
		{"a": HALL, "from": Vector3(0, 0, -walk.L + 0.9), "to": Vector3(0, 0, -walk.L - 1.3)},
		{"a": HALL, "from": Vector3(0, 0, -0.9), "to": Vector3(0, 0, walk.PORTAL_MOUTH + 0.9)},
	]
	for room in walk._plan:
		var b: Array = room.b
		for side in room.openings:
			var door: Array = room.openings[side]
			var mid: float = (door[0] + door[1]) / 2.0
			var on_wall := Vector3(
				b[0] if side == "west" else b[1] if side == "east" else mid,
				0,
				b[2] if side == "north" else b[3] if side == "south" else mid
			)
			var outward: Vector3 = walk.SIDES[side]
			# Straight through on the door's own axis; nearer the door if furniture stands close.
			var ends := []
			for way in [-1.0, 1.0]:
				var end: Vector3 = on_wall + outward * way * 0.9
				for depth in [0.9, 0.7, 0.55]:
					if walk._free(on_wall + outward * way * depth):
						end = on_wall + outward * way * depth
						break
				ends.append(end)
			doors.append({"a": room.label, "from": ends[0], "to": ends[1]})
	var unique := []
	for door in doors:
		door.from = _free_near(door.from)
		door.to = _free_near(door.to)
		door["b"] = _area_at(door.to)
		var seen := false
		for other in unique:
			if other.a == door.b and other.b == door.a and other.from.distance_to(door.to) < 1.2:
				seen = true
		if not seen:
			unique.append(door)
	return unique


# p, or the nearest place beside it where a visitor can stand.
func _free_near(p: Vector3) -> Vector3:
	if walk._free(p):
		return p
	for radius in [0.25, 0.5, 0.75, 1.0, 1.5, 2.0]:
		for step in 16:
			var q: Vector3 = p + Vector3(cos(step * TAU / 16), 0, sin(step * TAU / 16)) * radius
			if walk._free(q):
				return q
	return p


func _place(p: Vector3, yaw := 0.0) -> void:
	var label := _area_at(p)
	walk._new_action()
	walk._target = null
	walk._held.clear()
	walk._velocity = Vector3.ZERO
	walk._pos = p
	walk._last_pos = p
	walk._space = "gallery"
	for area in _areas():
		if area.label == label:
			walk._space = area.space
	walk.view_mode = 0
	walk.view_yaw = yaw
	walk._yaw = yaw
	walk._kid.position = p
	walk._kid.reset_contacts()
	# A room change still under way from the last leg ends here, and the stage is the one stood in.
	if walk.has_method("_wipe_end"):
		walk._wipe_end()
		walk.set("_stage", walk.get("NO_STAGE"))
	walk._update_camera(1.0)


# The share of the picture that is the dark outside the rooms (or the wipe's black).
func _void_share(image: Image) -> float:
	var small: Image = image.duplicate()
	small.resize(96, 64, Image.INTERPOLATE_BILINEAR)
	var dark := 0
	for y in 64:
		for x in 96:
			var c := small.get_pixel(x, y)
			dark += int(maxf(c.r, maxf(c.g, c.b)) < 0.07)
	return dark / 6144.0


# One reading of the picture for the dark-share rule; stops for good once the wipe has shut,
# because what is put up in the black is not on screen.
func _watch_void(dark: Dictionary, clock: float) -> void:
	if not dark.on:
		return
	if float(walk.get("_wipe_t")) >= float(walk.get("WIPE_CLOSE")):
		dark.on = false
		return
	var share := _void_share(root.get_texture().get_image())
	if dark.before >= 0.0 and share - dark.before > dark.jump:
		dark.jump = share - dark.before
		dark.at = clock
		dark.from = dark.before
	dark.before = share


# Hold the keys a player would hold to reach `goal` in the dollhouse view as it is turned.
# With `watch_void` the picture is read every other frame until the room-change wipe has shut:
# the dark outside must grow smoothly, never in one step (a room dropped before the wipe hid it).
func _walk_keys(goal: Vector3, limit_s: float, watch_void := false) -> Dictionary:
	var started := walk._pos as Vector3
	var clock := 0.0
	var stuck := 0.0
	var longest_step := 0.0
	var steps := 0
	var walked_clip := false
	var before := walk._pos as Vector3
	var dark := {"on": watch_void, "before": -1.0, "jump": 0.0, "at": 0.0, "from": 0.0}
	var frame := 0
	while clock < limit_s:
		var to: Vector3 = goal - walk._pos
		to.y = 0
		if to.length() < 0.25:
			break
		var yaw: float = walk.view_yaw  # read each frame: an arrival may turn the view
		var ahead := to.dot(Vector3(-sin(yaw), 0, -cos(yaw)))
		var aside := to.dot(Vector3(cos(yaw), 0, -sin(yaw)))
		var held := {}
		if absf(ahead) > 0.12:
			held["up" if ahead > 0 else "down"] = 1.0
		if absf(aside) > 0.12:
			held["right" if aside > 0 else "left"] = 1.0
		walk._held = held
		await process_frame
		frame += 1
		if frame % 2 == 0:
			_watch_void(dark, clock)
		var delta: float = root.get_process_delta_time()
		clock += delta
		var moved: float = (walk._pos as Vector3).distance_to(before)
		longest_step = maxf(longest_step, moved)
		stuck = stuck + delta if moved < 0.0005 else 0.0
		steps += walk._kid.contacts
		walked_clip = walked_clip or walk._kid._clip == "walk"
		before = walk._pos
		if stuck > 2.5:
			break
	walk._held = {}
	# Arrived, perhaps while the wipe is still closing: it is watched until it has shut.
	for settle in 110:
		if settle >= 20 and (not dark.on or float(walk.get("_wipe_t")) < 0.0):
			break
		await process_frame
		if settle % 2 == 1:
			_watch_void(dark, clock + (settle + 1) / 60.0)
	var left: float = Vector3(goal.x - walk._pos.x, 0, goal.z - walk._pos.z).length()
	return {
		"arrived": left < 0.3,
		"left_m": snappedf(left, 0.01),
		"seconds": snappedf(clock, 0.1),
		"walked_m": snappedf(started.distance_to(walk._pos), 0.01),
		"longest_step_m": snappedf(longest_step, 0.001),
		"footsteps": steps,
		"walk_clip": walked_clip,
		"void_jump": snappedf(dark.jump, 0.01),
		"void_jump_at_s": snappedf(dark.at, 0.01),
		"void_before_jump": snappedf(dark.from, 0.01),
		"idle_after": walk._kid._clip == "idle",
		"ended_in": _area_at(walk._pos),
		"ended_at": [snappedf(walk._pos.x, 0.01), snappedf(walk._pos.z, 0.01)]
	}


# The most the dark share of the picture may rise between two readings (every other frame).
# The wipe itself and the camera's travel reach 0.09; a dropped room or wall is 0.2 and more.
const DARK_STEP := 0.15


func _doors() -> void:
	for door in _doorways():
		for way in [[door.from, door.to, door.a, door.b], [door.to, door.from, door.b, door.a]]:
			# Looking the way the visitor walks, so the camera stands over the room being left:
			# the view in which a room dropped too early shows.
			var along: Vector3 = way[1] - way[0]
			var yaw := (0.0 if along.z < 0 else PI) if absf(along.z) > absf(along.x) else (
				-PI / 2.0 if along.x > 0 else PI / 2.0
			)
			_place(way[0], yaw)
			for settle in 6:
				await process_frame
			var leg := await _walk_keys(way[1], 12.0, true)
			leg["from"] = way[2]
			leg["to"] = way[3]
			report.doors.append(leg)
			var name := "%s -> %s" % [way[2], way[3]]
			if way[3] == "":
				_fail("door", name + ": the doorway leads nowhere", leg)
			elif not leg.arrived:
				_fail("door", name + ": the visitor could not walk through", leg)
			elif leg.longest_step_m > 0.25:
				_fail("door", name + ": the visitor jumped", leg)
			elif not leg.walk_clip or leg.footsteps == 0:
				_fail("door", name + ": walked without its walk animation or footsteps", leg)
			elif leg.void_jump > DARK_STEP:
				_fail("door", name + ": the room went dark in one step before the wipe had shut", leg)
	await _doors_off_centre()


# The deep doorways again, off their centre line (round 5): half a metre to each side, on a
# diagonal from one side to the other, and standing in the doorway's depth stepping sideways.
# The centre line misses a room dropped because the sight line clips the wall beside the opening.
func _doors_off_centre() -> void:
	report["off_centre"] = []
	for door in _doorways():
		if not ("reveal threshold" in str(door.a) or "reveal threshold" in str(door.b)):
			continue
		var axis: Vector3 = (door.to - door.from).normalized()
		var side := Vector3(-axis.z, 0, axis.x)
		var middle: Vector3 = (door.from + door.to) / 2.0
		var cases := []
		for way in [[door.from, door.to, door.a, door.b], [door.to, door.from, door.b, door.a]]:
			# Out to the door's cheek and against it: that is where the room was dropped.
			for shift in [-0.7, 0.7]:
				cases.append(["%.1f m off centre" % shift, way[0] + side * shift, way[1] + side * shift, way])
			cases.append(["on a diagonal into the cheek", way[0] - side * 0.6, way[1] + side * 1.0, way])
			cases.append(["sidestep in the doorway", middle, middle + side * 1.0, way])
			cases.append(["sidestep in the doorway, other way", middle, middle - side * 1.0, way])
		for case in cases:
			var way: Array = case[3]
			var along: Vector3 = way[1] - way[0]
			var yaw := (0.0 if along.z < 0 else PI) if absf(along.z) > absf(along.x) else (
				-PI / 2.0 if along.x > 0 else PI / 2.0
			)
			_place(case[1], yaw)
			for settle in 12:
				await process_frame
			var leg := await _walk_keys(case[2], 3.0, true)
			leg["from"] = way[2]
			leg["to"] = way[3]
			leg["case"] = case[0]
			report.off_centre.append(leg)
			if leg.void_jump > DARK_STEP:
				_fail(
					"door",
					"%s -> %s, %s: the room went dark in one step before the wipe had shut"
					% [way[2], way[3], case[0]],
					leg
				)


func _rooms() -> void:
	var doors := _doorways()
	for area in _areas():
		var b: Array = area.b
		var middle := _free_near(Vector3((b[0] + b[1]) / 2.0, 0, (b[2] + b[3]) / 2.0))
		for door in doors:
			var start = (
				door.from if door.a == area.label else (door.to if door.b == area.label else null)
			)
			if start == null:
				continue
			_place(start)
			for settle in 6:
				await process_frame
			walk._walk_to(middle)
			var clock := 0.0
			var longest := 0.0
			var steps := 0
			var before: Vector3 = walk._pos
			while (walk._target != null or not walk._path.is_empty()) and clock < 90.0:
				await process_frame
				clock += root.get_process_delta_time()
				longest = maxf(longest, before.distance_to(walk._pos))
				before = walk._pos
				steps += walk._kid.contacts
			var left: float = Vector3(middle.x - walk._pos.x, 0, middle.z - walk._pos.z).length()
			var leg := {
				"room": area.label,
				"arrived": left < 0.35,
				"left_m": snappedf(left, 0.01),
				"seconds": snappedf(clock, 0.1),
				"longest_step_m": snappedf(longest, 0.001),
				"footsteps": steps,
				"ended_at": [snappedf(walk._pos.x, 0.01), snappedf(walk._pos.z, 0.01)]
			}
			report.rooms.append(leg)
			if not leg.arrived:
				_fail(
					"room",
					area.label + ": a click on its middle did not bring the visitor there",
					leg
				)
			elif leg.longest_step_m > 0.25:
				_fail("room", area.label + ": the visitor jumped on the way to its middle", leg)


# ---------------------------------------------------------------- looking


func _shot(file: String) -> Image:
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	if file != "":
		image.save_png(out.path_join(file))
	return image


# The share of the picture taken by its single most common colour: a wall in the lens.
func _flat_share(image: Image) -> float:
	var small: Image = image.duplicate()
	small.resize(96, 64, Image.INTERPOLATE_BILINEAR)
	var buckets := {}
	for y in 64:
		for x in 96:
			var c := small.get_pixel(x, y)
			var key := int(c.r * 15.0) << 8 | int(c.g * 15.0) << 4 | int(c.b * 15.0)
			buckets[key] = buckets.get(key, 0) + 1
	var most := 0
	for key in buckets:
		most = maxi(most, buckets[key])
	return most / 6144.0


# Where an area is photographed from: one standpoint per seven metres of its long axis.
func _stands(area: Dictionary) -> Array:
	var b: Array = area.b
	var long_z: bool = b[3] - b[2] > b[1] - b[0]
	var span: float = (b[3] - b[2]) if long_z else (b[1] - b[0])
	var count := maxi(1, roundi(span / 7.0))
	var stands := []
	for n in count:
		var along := (n + 0.5) / count
		stands.append(
			Vector3(
				(b[0] + b[1]) / 2.0 if long_z else lerpf(b[0], b[1], along),
				0,
				lerpf(b[2], b[3], along) if long_z else (b[2] + b[3]) / 2.0
			)
		)
	return stands


# Stand the visitor at `here` in one of the five standard views, with the game loop held still.
func _face(here: Vector3, view: String) -> void:
	_place(_free_near(here))  # never photographed from inside a case
	var yaw: float = {"n": 0.0, "e": -PI / 2, "s": PI, "w": PI / 2, "follow": 0.0}[view]
	walk.view_mode = 2 if view == "follow" else 0
	walk.view_yaw = yaw
	walk._yaw = yaw
	walk.set_process(false)
	walk._kid.pose(0.0, false, 0.0, Vector3(-sin(yaw), 0, -cos(yaw)), yaw)
	for settle in 4:
		walk._update_camera(1.0)
		await process_frame


func _views() -> void:
	for area in _areas():
		if _arg("room", "") != "" and area.label != _arg("room", ""):
			continue
		var slug: String = area.label.to_lower().replace(" ", "-")
		var b: Array = area.b
		var stands := _stands(area)
		for n in stands.size():
			var here: Vector3 = stands[n]
			for view in ["n", "e", "s", "w", "follow"]:
				await _face(here, view)
				var file := "%s-%d-%s.png" % [slug, n, view]
				var with_visitor := await _shot(file)
				walk._kid.hide()
				walk._shadow.hide()
				await process_frame
				var without := await _shot("")
				walk._kid.show()
				walk._shadow.show()
				walk.set_process(true)
				# How much of the picture the visitor changes: none means it is hidden.
				var changed := 0
				for y in range(0, root.size.y, 4):
					for x in range(0, root.size.x, 4):
						var a := with_visitor.get_pixel(x, y)
						var c := without.get_pixel(x, y)
						if absf(a.r - c.r) + absf(a.g - c.g) + absf(a.b - c.b) > 0.08:
							changed += 1
				var entry := {
					"room": area.label,
					"stand": [snappedf(here.x, 0.01), snappedf(here.z, 0.01)],
					"view": view,
					"file": file,
					"flat_share": snappedf(_flat_share(with_visitor), 0.001),
					"visitor_pixels": changed * 16
				}
				report.views.append(entry)
				# A doorway-sized stub cannot be photographed without a wall in the lens.
				if entry.flat_share > 0.45 and minf(b[1] - b[0], b[3] - b[2]) >= 2.2:
					_fail(
						"view",
						"%s %s: one flat surface fills the picture" % [area.label, view],
						entry
					)
				elif entry.visitor_pixels < 400:
					_fail("view", "%s %s: the visitor cannot be seen" % [area.label, view], entry)


# ---------------------------------------------------------------- light


# The picture's colour round a point of the museum, 0 to 255 a channel; alpha 0 off the picture.
func _colour_at(image: Image, point: Vector3, radius: int) -> Color:
	if walk._cam.is_position_behind(point):
		return Color(0, 0, 0, 0)
	var at: Vector2 = walk._cam.unproject_position(point) / Vector2(walk._vp.size) * walk.size
	var x := int(at.x)
	var y := int(at.y)
	if x < radius or y < radius or x >= image.get_width() - radius or y >= image.get_height() - radius:
		return Color(0, 0, 0, 0)
	var sum := Color(0, 0, 0, 0)
	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			sum += image.get_pixel(x + dx, y + dy)
	sum = sum * (255.0 / ((2 * radius + 1) * (2 * radius + 1)))
	return Color(sum.r, sum.g, sum.b, 1.0)


# Display brightness, 0 to 255, of the picture round a point; -1 off the picture.
func _luma_at(image: Image, point: Vector3, radius: int) -> float:
	var colour := _colour_at(image, point, radius)
	return colour.get_luminance() if colour.a > 0.0 else -1.0


func _mean(values: Array) -> float:
	var sum := 0.0
	for value in values:
		sum += value
	return snappedf(sum / values.size(), 0.1) if not values.is_empty() else -1.0


# Mean colour as [red, green, blue, brightness], 0 to 255; [] when nothing was sampled.
func _mean_colour(colours: Array) -> Array:
	if colours.is_empty():
		return []
	var sum := Color(0, 0, 0, 0)
	for colour in colours:
		sum += colour
	sum = sum / float(colours.size())
	return [roundi(sum.r), roundi(sum.g), roundi(sum.b), snappedf(sum.get_luminance(), 0.1)]


# The lamps a room's bake was given. The baked scenes keep no lamp nodes, so the bakes' own
# lists are the record: the Hall's lamps.json and the added rooms' room-lamps.json.
func _lamps() -> Array:
	var lamps := []
	var rooms_dir: String = walk.ROOM_SCENES[0].get_base_dir()
	for source in [
		[walk.DIR + "baked/lamps.json", HALL],
		[rooms_dir.path_join("addition_baked/room-lamps.json"), ""]
	]:
		var rows = JSON.parse_string(FileAccess.get_file_as_string(source[0]))
		if rows is Array:
			for row in rows:
				lamps.append({"room": row.get("room", source[1]), "works": row.get("works", [])})
	return lamps


# Each room from its four dollhouse views, the visitor hidden: the floor on a half-metre grid
# clear of furniture, each work the camera faces over the middle of its front, the wall 20 cm
# beyond each side of it, and the same walls a metre or more from any work. The numbers are
# the picture's colour, 0 to 255 ([red, green, blue, brightness]), not light: a dark painting
# under a strong lamp still reads dark, which is why the works are compared with nothing
# here (the Hall's own floor is twice as bright as its paintings). A room fails without a lamp in its bake, with a work no lamp
# is aimed at, and when the wall beside its works is no brighter than its wall away from them.
func _light() -> void:
	var lamps := _lamps()
	for area in _areas():
		if _arg("room", "") != "" and area.label != _arg("room", ""):
			continue
		var b: Array = area.b
		# The room scene is built the first time the visitor is put in a room (#281): its works
		# are only known after that.
		await _face(_stands(area)[0], "n")
		walk.set_process(true)
		var things: Array = walk._paintings.duplicate()
		if walk.get("_objects") is Array:
			things += walk._objects
		var mine := things.filter(
			func(thing: Dictionary) -> bool:
				return (walk._plan[thing.room].label if thing.has("object") else HALL) == area.label
		)
		var boxes := []
		for thing in mine:
			var box := AABB(thing.corners[0], Vector3.ZERO)
			for corner in thing.corners:
				box = box.expand(corner)
			boxes.append(box)
		# Bare wall: chest height, a metre clear of every work and door, clear of furniture.
		var doors: Dictionary = {"north": [-1.5, 1.5], "south": [-1.5, 1.5]}
		for room in walk._plan:
			if room.label == area.label:
				doors = room.openings
		var bare := []  # [point on the wall, the way the wall faces]
		var skirting := []  # the same for the skirting board: the room's white
		for side in walk.SIDES:
			var inward: Vector3 = -walk.SIDES[side]
			var along_x: bool = side in ["north", "south"]
			var lo: float = b[0] if along_x else b[2]
			var hi: float = b[1] if along_x else b[3]
			for step in range(int((hi - lo - 1.0) / 0.5) + 1):
				var along: float = lo + 0.5 + step * 0.5
				var door: Array = doors.get(side, [])
				if not door.is_empty() and along > door[0] - 0.4 and along < door[1] + 0.4:
					continue
				var fixed: float = (
					b[2] if side == "north" else b[3] if side == "south" else b[0] if side == "west" else b[1]
				)
				var on_wall := (
					Vector3(along, 1.5, fixed) if along_x else Vector3(fixed, 1.5, along)
				) + inward * 0.01
				var clear := true
				var low := true  # nothing stands on the floor in front of the skirting here
				for box in boxes:
					var near: AABB = box.grow(1.0)
					var foot := Rect2(near.position.x, near.position.z, near.size.x, near.size.z)
					var covered: bool = foot.has_point(Vector2(on_wall.x, on_wall.z))
					clear = clear and not covered
					low = low and not (covered and box.position.y < 0.5)
				for block in walk._blocks:
					var blocked: bool = block.grow(0.6).has_point(Vector2(on_wall.x, on_wall.z))
					clear = clear and not blocked
					low = low and not blocked
				if clear:
					bare.append([on_wall, inward])
				if low:
					skirting.append([Vector3(on_wall.x, 0.09, on_wall.z) + inward * 0.07, inward])
		var floor := []
		var beside_works := []
		var away := []
		var trim := []
		var picture := []
		var seen := {}  # work tag -> brightness of each sample of it
		for here in _stands(area):
			for view in ["n", "e", "s", "w"]:
				await _face(here, view)
				walk._kid.hide()
				walk._shadow.hide()
				await process_frame
				var image := await _shot("")
				walk._kid.show()
				walk._shadow.show()
				walk.set_process(true)
				var small: Image = image.duplicate()
				small.resize(48, 32, Image.INTERPOLATE_BILINEAR)
				for y in 32:
					for x in 48:
						picture.append(small.get_pixel(x, y).get_luminance() * 255.0)
				var eye: Vector3 = walk._cam.global_position
				for x in range(int((b[1] - b[0] - 0.6) / 0.5) + 1):
					for z in range(int((b[3] - b[2] - 0.6) / 0.5) + 1):
						var on_floor := Vector3(b[0] + 0.3 + x * 0.5, 0.004, b[2] + 0.3 + z * 0.5)
						var blocked := false
						for block in walk._blocks:
							blocked = blocked or block.grow(0.15).has_point(Vector2(on_floor.x, on_floor.z))
						var value := Color(0, 0, 0, 0) if blocked else _colour_at(image, on_floor, 3)
						if value.a > 0.0:
							floor.append(value)
				for spot in bare:
					if spot[1].dot((eye - spot[0]).normalized()) >= 0.5:
						var value := _colour_at(image, spot[0], 4)
						if value.a > 0.0:
							away.append(value)
				for spot in skirting:
					if spot[1].dot((eye - spot[0]).normalized()) >= 0.5:
						var value := _colour_at(image, spot[0], 1)
						if value.a > 0.0:
							trim.append(value)
				for i in mine.size():
					var thing: Dictionary = mine[i]
					if thing.has("object") and not walk._drawn(thing.node):
						continue
					var normal: Vector3 = thing.normal
					var centre: Vector3 = thing.center
					if normal != Vector3.ZERO and normal.dot((eye - centre).normalized()) < 0.5:
						continue  # on a wall the camera has cut away, or seen edge-on
					var across: Vector3 = (
						walk._cam.global_transform.basis.x if normal == Vector3.ZERO else Vector3.UP.cross(normal)
					)
					var front: Vector3 = centre + normal * (absf(boxes[i].size.dot(normal)) / 2.0 + 0.005)
					for u in [-0.3, 0.0, 0.3]:
						for v in [-0.3, 0.0, 0.3]:
							var value := _luma_at(
								image, front + across * u * thing.outer.x + Vector3.UP * v * thing.outer.y, 2
							)
							if value >= 0.0:
								seen[thing.tag] = seen.get(thing.tag, []) + [value]
					if normal == Vector3.ZERO:
						continue
					for side in [-1.0, 1.0]:
						var beside: Vector3 = centre + across * side * (thing.outer.x / 2.0 + 0.2)
						if absf(normal.x) > 0.5:
							beside.x = (b[0] if normal.x > 0.0 else b[1]) + normal.x * 0.01
						else:
							beside.z = (b[2] if normal.z > 0.0 else b[3]) + normal.z * 0.01
						var clear: bool = (
							beside.x > b[0] and beside.x < b[1] and beside.z > b[2] and beside.z < b[3]
						)
						for box in boxes:
							clear = clear and not box.grow(0.12).has_point(beside)
						var value := _colour_at(image, beside, 4) if clear else Color(0, 0, 0, 0)
						if value.a > 0.0:
							beside_works.append(value)
		var works := []
		for tag in seen:
			works.append(_mean(seen[tag]))
		var hung := 0
		var aimed := {}
		for lamp in lamps:
			if lamp.room == area.label:
				hung += 1
				for key in lamp.works:
					aimed[key] = true
		var dark := []
		for thing in mine:
			if thing.has("object") and not aimed.has(thing.tag.get_slice("#", 0)):
				dark.append(thing.tag)
		var row := {
			"room": area.label,
			"floor": _mean_colour(floor),
			"wall_beside_works": _mean_colour(beside_works),
			"wall_away_from_works": _mean_colour(away),
			"skirting": _mean_colour(trim),
			"works": _mean(works),
			"picture": _mean(picture),
			"lamps": hung,
			"works_without_a_lamp": dark,
			"samples": [floor.size(), beside_works.size(), away.size(), trim.size(), works.size()]
		}
		report.light.append(row)
		print("PLAYTEST_LIGHT ", JSON.stringify(row))
		if hung == 0:
			_fail("light", area.label + ": no lamp hangs in this room", row)
		elif not dark.is_empty():
			_fail("light", area.label + ": works with no lamp aimed at them", row)
		elif (
			not beside_works.is_empty()
			and not away.is_empty()
			and row.wall_beside_works[3] <= row.wall_away_from_works[3]
		):
			_fail("light", area.label + ": no pool on the wall beside its works", row)


# ---------------------------------------------------------------- reading


# What is wrong with a caption label as it came out in `image`, or "" when it reads: a
# character its font has no glyph for (the Web build has no system font to fall back on),
# text that drew as nothing, or a line that drew as solid blocks. Letters fill about a
# quarter of the box round them; a glyph sheet that did not reach the GPU fills it (#271).
func _unreadable(image: Image, label: Label) -> String:
	var text := label.text.strip_edges()
	if text == "":
		return ""
	var font := label.get_theme_font("font")
	var missing := ""
	for i in text.length():
		if text.unicode_at(i) > 32 and not font.has_char(text.unicode_at(i)) and not text[i] in missing:
			missing += text[i]
	if missing != "":
		return "the font has no glyph for " + missing
	var colour := label.get_theme_color("font_color")
	var box := Rect2i(label.get_global_rect()).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
	var ink := 0
	var line := Rect2i()  # the run of pixel rows being read, and the ink in it
	var line_ink := 0
	for y in range(box.position.y, box.end.y + 1):
		var row := 0
		if y < box.end.y:
			for x in range(box.position.x, box.end.x):
				var c := image.get_pixel(x, y)
				if absf(c.r - colour.r) + absf(c.g - colour.g) + absf(c.b - colour.b) < 0.3:
					line = Rect2i(x, y, 1, 1) if line_ink + row == 0 else line.expand(Vector2i(x + 1, y + 1))
					row += 1
		if row > 0:
			line_ink += row
			continue
		if line_ink > 0 and line.size.y >= 6 and line_ink > 0.5 * line.get_area():
			return "a line drew as solid blocks, not letters"
		ink += line_ink
		line_ink = 0
	return "the text did not draw" if ink < 4 * text.length() else ""


# The share of a picture its one commonest colour takes: 1 is a blank rectangle.
func _blank_share(image: Image) -> float:
	var buckets := {}
	var seen := 0
	for y in range(0, image.get_height(), 3):
		for x in range(0, image.get_width(), 3):
			var c := image.get_pixel(x, y)
			var key := int(c.r * 31.0) << 10 | int(c.g * 31.0) << 5 | int(c.b * 31.0)
			buckets[key] = buckets.get(key, 0) + 1
			seen += 1
	var most := 0
	for key in buckets:
		most = maxi(most, buckets[key])
	return most / maxf(seen, 1.0)


# ---------------------------------------------------------------- touching


func _mouse(at: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = at
	event.global_position = at
	walk._gui_input(event)


# The screen rectangle a set of world points covers; empty when any is behind the lens.
func _on_screen(points: Array) -> Rect2:
	var box := Rect2()
	for i in points.size():
		if walk._cam.is_position_behind(points[i]):
			return Rect2()
		var at: Vector2 = (
			walk._cam.unproject_position(points[i]) / Vector2(walk._vp.size) * walk.size
		)
		box = Rect2(at, Vector2.ZERO) if i == 0 else box.expand(at)
	return box


func _objects() -> void:
	# A work in a room not yet entered exists only once the visitor has gone there.
	if not walk.state().attached:
		_place(Vector3(0, 0, walk.PORTAL_MOUTH + 0.9))
		for settle in 6:
			await process_frame
		if not walk.state().attached:
			_fail("setup", "walking into an added room did not build the rooms")
	var captions: Dictionary = JSON.parse_string(
		FileAccess.get_file_as_string("res://modules/shell/collection_rooms/objects.json")
	)
	var things: Array = walk._paintings.duplicate()
	if walk.get("_objects") is Array:
		things += walk._objects
	# --objects=E1,21.482 drives only those works (by tag, or by the accession before its #).
	var wanted := _arg("objects", "").split(",", false)
	for thing in things:
		var tag: String = thing.tag
		if not wanted.is_empty() and not (tag in wanted or tag.get_slice("#", 0) in wanted):
			continue
		var entry := {
			"tag": tag,
			"title": str(thing.rec.get("title", "")),
			"maker": str(thing.rec.get("artist", "")),
			"number": str(thing.rec.get("acc", "")),
			"room": walk._plan[thing.room].label if thing.has("object") else HALL
		}
		if _arg("room", "") != "" and entry.room != _arg("room", ""):
			continue
		if _arg("tags", "") != "" and tag.get_slice("#", 0) not in _arg("tags", "").split(","):
			continue
		# The caption says what the catalogue says: a title, a maker and a museum number.
		var problems := PackedStringArray()
		for field in ["title", "maker", "number"]:
			if entry[field].strip_edges() == "":
				problems.append("the caption has no " + field)
		if not thing.rec.get("identified", true) or entry.title == tag.get_slice("#", 0):
			problems.append("the caption carries a working name, not a catalogue title")
		# Stand in front of it and face it, as a visitor would before clicking: nearer or
		# further until it is on screen. A free-standing work is viewed from the room's middle.
		var facing: Vector3 = thing.normal
		if facing == Vector3.ZERO:
			var room: Array = walk._plan[thing.room].b
			facing = Vector3(
				(room[0] + room[1]) / 2.0 - thing.center.x,
				0,
				(room[2] + room[3]) / 2.0 - thing.center.z
			)
			facing = facing.normalized() if facing.length() > 0.3 else Vector3.BACK
		var at := Vector2.ZERO
		var picked := ""
		# Dollhouse view first; a work hung above its frame (a chandelier) from the follow view.
		for distance in [3.0, 2.0, 4.5, 6.0, 1.4, 8.0, -4.5, -7.0]:
			var stand: Vector3 = _free_near(
				Vector3(thing.center.x, 0, thing.center.z) + facing * absf(distance)
			)
			if not walk._free(stand):
				continue
			_place(stand)
			walk.view_mode = 2 if distance < 0.0 else 0
			entry["view"] = "follow" if distance < 0.0 else "dollhouse"
			walk.view_yaw = atan2(facing.x, facing.z)
			walk._yaw = walk.view_yaw
			for settle in 8:
				await process_frame
			at = Vector2.ZERO
			for corner in thing.corners:
				at += walk._cam.unproject_position(corner) / thing.corners.size()
			at = at / Vector2(walk._vp.size) * walk.size
			# Its middle first; if a smaller work sits on it (a cup on its saucer), its edges.
			var centre := at
			var tries := [centre]
			for corner in thing.corners:
				var edge: Vector2 = (
					walk._cam.unproject_position(corner) / Vector2(walk._vp.size) * walk.size
				)
				tries.append(centre.lerp(edge, 0.75))
			picked = ""
			for point in tries:
				if Rect2(Vector2.ZERO, walk.size).grow(-8).has_point(point):
					picked = walk._painting_at(point).get("tag", "")
					if picked == tag:
						at = point
						break
			if picked == tag:
				break
		entry["screen"] = [roundi(at.x), roundi(at.y)]
		entry["picked"] = picked
		if picked != tag:
			entry["result"] = "not clickable from in front of it"
			report.objects.append(entry)
			_fail("object", tag + ": a click on it does not select it", entry)
			continue
		_mouse(at, true)
		_mouse(at, false)
		# The visitor walks up and turns, the camera glides in and the text panel fills.
		var clock := 0.0
		while walk._inspect.is_empty() and clock < 20.0:
			await process_frame
			clock += root.get_process_delta_time()
		entry["seconds_to_open"] = snappedf(clock, 0.1)
		if walk._inspect.is_empty():
			entry["result"] = "nothing opened"
			report.objects.append(entry)
			_fail("object", tag + ": clicking it opened nothing", entry)
			continue
		for settle in 60:
			await process_frame
		var slug: String = tag.to_lower().replace("/", "-").replace(" ", "-").replace("#", "-")
		var looked := await _shot("object-%s.png" % slug)
		var panel: Control = walk._inspect_panel
		var title: String = panel.get_child(0).get_node("Title").text
		entry["title_shown"] = title
		entry["camera_glided"] = walk._inspect_t > 0.99
		entry["flat_share"] = snappedf(_flat_share(looked), 0.001)
		for part in ["Title", "Body"]:
			var fault := _unreadable(looked, panel.get_child(0).get_node(part))
			if fault != "":
				problems.append("caption %s: %s" % [part.to_lower(), fault])
		if not panel.visible or title.strip_edges() == "":
			problems.append("no title in the panel")
		if title.begins_with("Authored Surface") or title.begins_with("@"):
			problems.append("the title is a scene node name")
		if not entry.camera_glided:
			problems.append("the camera did not reach its shot")
		if entry.flat_share > 0.6:
			problems.append("the inspection shot is filled by one flat surface")
		if walk._kid._clip != "idle":
			problems.append("the visitor is not standing still")
		if walk._inspect.get("tag", "") != tag:
			problems.append("a different work opened: " + str(walk._inspect.get("tag", "")))
		# Its box can be in the picture while the camera's cut-away has hidden the work itself.
		if thing.has("node") and not walk._drawn(thing.node):
			problems.append("the work is not drawn in its own inspection")
		# The whole work is in the picture and the visitor stands beside it, not over it.
		var work := _on_screen(thing.corners)
		var body: Array = []
		for i in 8:
			body.append(
				(
					walk._pos
					+ Vector3(0.4 if i & 1 else -0.4, 1.7 if i & 2 else 0.0, 0.4 if i & 4 else -0.4)
				)
			)
		entry["work_on_screen"] = [
			roundi(work.position.x),
			roundi(work.position.y),
			roundi(work.size.x),
			roundi(work.size.y)
		]
		if not Rect2(Vector2.ZERO, walk.size).grow(2).encloses(work):
			problems.append("the work is not wholly in the inspection picture")
		# A flat work (a photo card, a cut-out, a slab lying down) shows its face (#272): the
		# share of that face's area its box takes on screen, against the face seen square on
		# at the same distance. Along its edge the share is a few hundredths.
		var reach := AABB(thing.corners[0], Vector3.ZERO)
		for corner in thing.corners:
			reach = reach.expand(corner)
		var measures: Vector3 = reach.size
		var least: float = measures[measures.min_axis_index()]
		var mid: float = measures.x + measures.y + measures.z - least - measures[measures.max_axis_index()]
		if least <= 0.035 and least < 0.2 * mid:
			var outline := PackedVector2Array()
			for corner in thing.corners:
				outline.append(walk._to_screen(corner))
			outline = Geometry2D.convex_hull(outline)
			var seen := 0.0
			for i in outline.size() - 1:
				seen += outline[i].x * outline[i + 1].y - outline[i + 1].x * outline[i].y
			var per_metre: float = walk.size.y / (
				2.0 * walk._cam.global_position.distance_to(reach.get_center())
				* tan(deg_to_rad(walk._cam.fov) / 2.0)
			)
			seen = absf(seen) / 2.0 / (mid * measures[measures.max_axis_index()] * per_metre * per_metre)
			entry["face_seen"] = snappedf(seen, 0.01)
			if seen < READ_FACE:
				problems.append("the work is flat and shows only %.2f of its face" % seen)
		# The lens is before the work's face, where the museum says it has one (#272): a flat
		# work's (a card at any angle, a slab lying down) or the front of one in the round.
		var eye_way: Vector3 = (walk._cam.global_position - thing.center).normalized()
		var faces: Vector3 = thing.get("front", Vector3.ZERO)
		var fronted: bool = faces != Vector3.ZERO and thing.normal == Vector3.ZERO
		if not fronted:
			faces = thing.get("flat", Vector3.ZERO)
		if faces != Vector3.ZERO:
			var level := Vector3(eye_way.x, 0, eye_way.z).normalized()
			var square: float = eye_way.y if faces.y != 0.0 else level.dot(faces)
			if not fronted and faces.y == 0.0:
				square = absf(square)  # a card shows the same on both sides
			entry["face_on"] = snappedf(square, 0.01)
			if square < READ_SQUARE:
				problems.append("the lens is not before the work's face (%.2f)" % square)
		# No other work stands in front of it (#272). At five points of its rectangle the
		# lens's ray is tried against this work's own meshes and its room's other works';
		# a point is hidden when another is met first.
		if thing.has("object"):
			var on_it := 0
			var hidden := 0
			var before := {}
			for spot in [Vector2(0.5, 0.5), Vector2(0.3, 0.3), Vector2(0.7, 0.3), Vector2(0.3, 0.7), Vector2(0.7, 0.7)]:
				var pixel: Vector2 = (work.position + work.size * spot) / walk.size * Vector2(walk._vp.size)
				var from: Vector3 = walk._cam.project_ray_origin(pixel)
				var toward: Vector3 = walk._cam.project_ray_normal(pixel)
				var own: float = walk._ray_reach(thing.node, from, toward)
				if own == INF:
					continue
				on_it += 1
				for other in walk._objects:
					if other.tag != tag and other.room == thing.room:
						if walk._ray_reach(other.node, from, toward) < own - 0.01:
							before[other.tag.get_slice("#", 0)] = true
				hidden += int(not before.is_empty())
			entry["points_hidden"] = [hidden, on_it]
			if on_it > 0 and hidden * 2 >= on_it:
				problems.append(
					"%d of %d points of the work are behind %s" % [hidden, on_it, ", ".join(before.keys())]
				)
			# Nor does anything else that is drawn (#272, round 5: a glass case standing before
			# Christ in Majesty, the stair before the fireplace). The glass of a work's own case
			# is not in its way: only what is met more than READ_CLEAR metres before the work.
			var screened := 0
			var by := {}
			for spot in [Vector2(0.5, 0.5), Vector2(0.3, 0.3), Vector2(0.7, 0.3), Vector2(0.3, 0.7), Vector2(0.7, 0.7)]:
				var pixel: Vector2 = (work.position + work.size * spot) / walk.size * Vector2(walk._vp.size)
				var from: Vector3 = walk._cam.project_ray_origin(pixel)
				var toward: Vector3 = walk._cam.project_ray_normal(pixel)
				var own: float = walk._ray_reach(thing.node, from, toward)
				if own == INF:
					continue
				var met := false
				var until: Vector3 = from + toward * (own - READ_CLEAR)
				for row in _room_meshes():
					# Only what the stretch from the lens to READ_CLEAR before the work crosses.
					if (row.box as AABB).intersects_segment(from, until) == null:
						continue
					var mesh: MeshInstance3D = row.mesh
					if not mesh.is_visible_in_tree() or (walk._cam.cull_mask & mesh.layers) == 0:
						continue
					if thing.node == mesh or thing.node.is_ancestor_of(mesh):
						continue
					if not row.has("shape"):
						row["shape"] = mesh.mesh.generate_triangle_mesh()
						row["inward"] = mesh.global_transform.affine_inverse()
					if row.shape == null:
						continue
					var hit: Dictionary = row.shape.intersect_ray(
						row.inward * from, (row.inward.basis * toward).normalized()
					)
					if hit.is_empty():
						continue
					var struck: Vector3 = mesh.global_transform * hit.position
					# A thin pane is glass: the front or side of the work's own case when it is
					# within READ_GLASS of the work, or when no floor lies between the two
					# however deep the case (the plates at the back of Rockefeller's).
					var thin: bool = (row.box as AABB).size[(row.box as AABB).size.min_axis_index()] < 0.05
					if from.distance_to(struck) >= own - (READ_GLASS if thin else READ_CLEAR):
						continue
					var between: Vector3 = struck.lerp(from + toward * own, 0.5)
					if thin and not walk._free(Vector3(between.x, 0, between.z)):
						continue
					met = true
					by[str(mesh.get_parent().name) + "/" + str(mesh.name)] = true
				screened += int(met)
			entry["points_screened"] = [screened, on_it]
			if on_it > 0 and screened * 2 >= on_it:
				problems.append(
					"%d of %d points of the work are behind %s" % [screened, on_it, ", ".join(by.keys().slice(0, 3))]
				)
		# The caption panel stands under the work, not over it (#272).
		var under := 0.0
		if panel.is_visible_in_tree() and work.has_area():
			under = work.intersection(panel.get_global_rect()).get_area() / work.get_area()
		entry["under_caption"] = snappedf(under, 0.01)
		if under > READ_COVERED:
			problems.append("the caption panel covers %.2f of the work" % under)
		entry["render_size"] = [walk._vp.size.x, walk._vp.size.y]
		if thing.rec.has("canvas_w"):
			var canvas_points: Array = []
			var right: Vector3 = Vector3.UP.cross(thing.normal)
			for corner in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
				canvas_points.append(
					(
						thing.center
						+ right * corner.x * thing.rec.canvas_w / 2.0
						+ Vector3.UP * corner.y * thing.rec.canvas_h / 2.0
						+ thing.normal * 0.055
					)
				)
			var canvas_box := _on_screen(canvas_points)
			var rendered: Vector2 = canvas_box.size / walk.size * Vector2(walk._vp.size)
			entry["canvas_screen_px"] = [ceilf(canvas_box.size.x), ceilf(canvas_box.size.y)]
			entry["canvas_render_px"] = [ceilf(rendered.x), ceilf(rendered.y)]
		entry["visitor_stepped_out"] = not walk._kid.visible
		if thing.has("object"):
			var record: Dictionary = captions.get(tag.get_slice("#", 0), {})
			var policy: Dictionary = record.get("image_resolution", {})
			var wall_path: String = policy.get("images", {}).get("wall", {}).get("path", "")
			for part in thing.node.find_children("*", "MeshInstance3D", true, false):
				var material: Material = part.material_override
				if material == null:
					continue
				var texture: Texture2D = (
					material.albedo_texture
					if material is BaseMaterial3D
					else material.get_shader_parameter("albedo")
				)
				if texture == null or texture.resource_path != "res://" + wall_path:
					continue
				var face_points := []
				for i in 8:
					face_points.append(part.to_global(part.get_aabb().get_endpoint(i)))
				var face_box := _on_screen(face_points)
				var pixels: Vector2 = face_box.size / walk.size * Vector2(walk._vp.size)
				entry["canvas_render_px"] = [ceilf(pixels.x), ceilf(pixels.y)]
				break
		if walk._kid.visible and work.intersects(_on_screen(body)):
			problems.append("the visitor covers the work")
		# Nor does the visitor crowd the lens (#272, round 5): its box takes no more than
		# READ_VISITOR of the picture.
		var crowd := 0.0
		if walk._kid.visible:
			crowd = (
				_on_screen(body).intersection(Rect2(Vector2.ZERO, walk.size)).get_area()
				/ (walk.size.x * walk.size.y)
			)
		entry["visitor_fills"] = snappedf(crowd, 0.01)
		if crowd > READ_VISITOR:
			problems.append("the visitor fills %.2f of the picture" % crowd)
		# A second click on the work: the zoom page, which must close again.
		var again := Vector2.ZERO
		for corner in thing.corners:
			again += walk._cam.unproject_position(corner) / thing.corners.size()
		again = again / Vector2(walk._vp.size) * walk.size
		_mouse(again, true)
		_mouse(again, false)
		clock = 0.0
		while walk._open.is_empty() and clock < 4.0:
			await process_frame
			clock += root.get_process_delta_time()
		if walk._open.is_empty():
			problems.append("a second click did not open the zoom page")
		else:
			for settle in 20:
				await process_frame
			var zoomed := await _shot("zoom-%s.png" % slug)
			var pic: TextureRect = walk._zoom_root.get_node("Painting")
			entry["zoom_image_px"] = [pic.texture.get_width(), pic.texture.get_height()]
			var resolution: Dictionary = thing.rec.get("image_resolution", {})
			if resolution.is_empty() and thing.has("object"):
				resolution = captions.get(tag.get_slice("#", 0), {}).get("image_resolution", {})
			if not resolution.is_empty():
				var images: Dictionary = resolution.images
				var need: Dictionary = images.get(
					"zoom_external", images.get("zoom", images.get("detail", {}))
				)
				if (
					maxf(pic.texture.get_width(), pic.texture.get_height())
					< need.get("required_long_side", 0)
				):
					problems.append("the zoom picture is smaller than its recorded requirement")
			# The page shows the work, and its caption reads clear of the picture.
			var picture: Control = walk._zoom_root.get_node("Painting")
			var shown := Rect2i(picture.get_global_rect()).intersection(Rect2i(Vector2i.ZERO, zoomed.get_size()))
			entry["zoom_blank_share"] = snappedf(_blank_share(zoomed.get_region(shown)), 0.001) if shown.has_area() else 1.0
			if entry.zoom_blank_share > 0.97:
				problems.append("the zoom page's picture is blank")
			if walk.get("_caption") is Label:
				var fault := _unreadable(zoomed, walk._caption)
				var page: Rect2 = picture.get_global_rect()
				var frame: Control = walk._zoom_root.get_node("Frame")
				if frame.visible:
					page = page.merge(frame.get_global_rect())
				if page.intersects(walk._caption.get_global_rect()):
					fault = "it lies across the picture"
				if fault != "":
					problems.append("zoom page caption: " + fault)
			entry["zoom_fit_px"] = [ceilf(pic.size.x), ceilf(pic.size.y)]
			# Magnified, the caption lies clear of the work or is put away (#280, round 4): one
			# notch of the wheel over the picture, then as far as the page goes.
			var wheel := InputEventMouseButton.new()
			wheel.button_index = MOUSE_BUTTON_WHEEL_UP
			wheel.pressed = true
			wheel.position = walk.size / 2.0
			wheel.global_position = wheel.position
			walk._gui_input(wheel)
			for step in 2:
				if step == 1:
					walk._zoom_at(walk.size / 2.0, 6.0)
				await process_frame
				var grown: Rect2 = picture.get_global_rect()
				var border: Control = walk._zoom_root.get_node("Frame")
				if border.visible:
					grown = grown.merge(border.get_global_rect())
				if (
					walk.get("_caption") is Label
					and walk._caption.is_visible_in_tree()
					and grown.intersects(walk._caption.get_global_rect())
				):
					problems.append(
						"zoom page caption lies across the picture magnified %.2f times" % walk._zoom
					)
			entry["zoom_full_px"] = [ceilf(pic.size.x * walk._zoom), ceilf(pic.size.y * walk._zoom)]
			for settle in 4:
				await process_frame
			await _shot("zoom-full-%s.png" % slug)
			walk._zoom_at(walk.size / 2.0, 1.0 / 6.0)
			await process_frame
			if walk.get("_caption") is Label and not walk._caption.is_visible_in_tree():
				problems.append("the zoom page caption did not come back at the fitted size")
			walk._close_detail()
			for settle in 10:
				await process_frame
			if not walk._open.is_empty():
				problems.append("the zoom page would not close")
		walk._end_inspect(false)
		for settle in 50:
			await process_frame
		if walk._inspect_t > 0.01:
			problems.append("the camera did not return")
		entry["result"] = (
			"inspected, zoomed and closed" if problems.is_empty() else ", ".join(problems)
		)
		report.objects.append(entry)
		if not problems.is_empty():
			_fail("object", tag + ": " + entry.result, entry)


# ---------------------------------------------------------------- interaction (#280)


# A press and release through the window itself, for a control that is not the walk.
func _press(at: Vector2) -> void:
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = at
		event.global_position = at
		Input.parse_input_event(event)
		await process_frame


# Whether a wall of the Hall stands in the lens: the camera is outside the Hall on a side
# whose wall it is drawing. The dollhouse view cuts that wall away; an inspection may bring
# it back only once the lens is inside.
func _hall_wall_in_lens() -> bool:
	if walk._space != "gallery":
		return false
	var eye: Vector3 = walk._cam.global_position
	var mask: int = walk._cam.cull_mask
	return (
		(eye.x > 5.0 and (mask & walk.LAYER_EAST) != 0)
		or (eye.x < -5.0 and (mask & walk.LAYER_WEST) != 0)
		or (eye.z > 0.0 and (mask & 8) != 0)
		or (eye.z < -walk.L and (mask & 16) != 0)
	)


# Click a work from three metres in front of it and wait until it is being read. Returns the
# frames of the camera's glide in during which a Hall wall stood in the lens.
func _read(thing: Dictionary) -> int:
	_place(Vector3(thing.center.x, 0, thing.center.z) + thing.normal * 3.0)
	walk.view_yaw = atan2(thing.normal.x, thing.normal.z)
	for settle in 8:
		await process_frame
	var at := _on_screen(thing.corners).get_center()
	_mouse(at, true)
	_mouse(at, false)
	var clock := 0.0
	while walk._inspect.is_empty() and clock < 20.0:
		await process_frame
		clock += root.get_process_delta_time()
	var blocked := 0
	for settle in 60:
		await process_frame
		blocked += int(_hall_wall_in_lens())
	return blocked


# Every case is run as a player meets it at launch, when only the Hall exists (#281 builds the
# rooms at the first doorway), and again once the rooms are built.
func _interaction() -> void:
	var launch: bool = walk.state().get("pending", false)
	await _hall_readings(", at launch" if launch else "")
	await _other_wall_while_reading(", at launch" if launch else "")
	if launch:
		await _wall_clicks([_areas()[0]], ", at launch")
	await _other_wall_in_wipe()  # out through the first doorway, which builds the rooms, and back
	await _wall_clicks(_areas(), "")
	if launch:
		await _hall_readings(", rooms built")
		await _other_wall_while_reading(", rooms built")
	await _overlapped_works()


# "Other wall" while a Hall painting is being read. The visitor may not walk off under an open
# caption: either the button does nothing, or the reading ends before the crossing.
func _other_wall_while_reading(when: String) -> void:
	var w2 := {}
	for painting in walk._paintings:
		if painting.tag == "W2":
			w2 = painting
	var lens_blocked: int = await _read(w2)
	var entry := {"name": "other wall while reading" + when, "read": walk._inspect.get("tag", "")}
	# The reading is a camera shot of the work, not a caption over the walking view.
	var off_shot := INF
	if not walk._inspect.is_empty():
		off_shot = walk._cam.global_position.distance_to(walk._inspect_shot(walk._inspect).origin)
	entry["camera_off_shot_m"] = snappedf(off_shot, 0.01)
	var started: Vector3 = walk._pos
	var button: Button = walk.get_node("OtherWall")
	entry["button_shown"] = button.is_visible_in_tree()
	if entry.button_shown:
		await _press(button.get_global_rect().get_center())
	var walked_reading := 0.0  # metres walked while the caption was still up
	var before: Vector3 = walk._pos
	for tick in 480:
		await process_frame
		if not walk._inspect.is_empty():
			walked_reading += before.distance_to(walk._pos)
		before = walk._pos
	var chest: Vector3 = walk._pos + Vector3(0, 0.9, 0)
	entry["walked_m"] = snappedf(started.distance_to(walk._pos), 0.01)
	entry["walked_while_reading_m"] = snappedf(walked_reading, 0.01)
	entry["still_reading"] = walk._inspect.get("tag", "")
	entry["camera_on_work"] = snappedf(walk._inspect_t, 0.01)
	entry["visitor_in_picture"] = (
		not walk._cam.is_position_behind(chest)
		and Rect2(Vector2.ZERO, walk.size).has_point(walk._to_screen(chest))
	)
	var problems := PackedStringArray()
	if entry.read != "W2":
		problems.append("W2 did not open to begin with")
	elif off_shot > 0.05:
		problems.append("the camera is %.2f m from the inspection shot" % off_shot)
	if walked_reading > 0.05:
		problems.append("the visitor walked %.2f m while the caption stayed open" % walked_reading)
	if entry.walked_m > 0.05 and entry.camera_on_work > 0.01:
		problems.append("the visitor crossed but the camera stayed on the old painting")
	if entry.walked_m > 0.05 and not entry.visitor_in_picture:
		problems.append("the visitor walked out of the picture")
	# A button hidden for the reading is back once the reading and its camera glide are over.
	walk._end_inspect(false)
	for settle in 60:
		await process_frame
		lens_blocked += int(_hall_wall_in_lens())
	# The lens stays clear while the camera glides in and back (rounds 2 to 4).
	entry["wall_in_lens_frames"] = lens_blocked
	if lens_blocked > 0:
		problems.append("a Hall wall stood in the lens for %d frames of the camera's glide" % lens_blocked)
	entry["button_back"] = button.is_visible_in_tree()
	if not entry.button_back:
		problems.append("the button did not come back after the reading closed")
	entry["result"] = "ok" if problems.is_empty() else ", ".join(problems)
	report.interaction.append(entry)
	if not problems.is_empty():
		_fail("interaction", entry.name + ": " + entry.result, entry)



# Every mesh of the room scene with its box in the room, listed once: {mesh, box}.
var _meshes: Array = []


func _room_meshes() -> Array:
	if _meshes.is_empty() and walk._rooms != null:
		for mesh in walk._rooms.find_children("*", "MeshInstance3D", true, false):
			if mesh.mesh != null:
				_meshes.append({"mesh": mesh, "box": mesh.global_transform * mesh.get_aabb()})
	return _meshes


# The pixel showing a point of a wall, or null when it is out of the picture or under a work.
func _wall_pixel(point: Vector3):
	if walk._cam.is_position_behind(point):
		return null
	var at: Vector2 = walk._to_screen(point)
	if not Rect2(Vector2.ZERO, walk.size).grow(-8).has_point(at):
		return null
	return at if walk._painting_at(at).is_empty() else null


# Click, say where the walk it started would end (null when it started none), and drop it.
func _click_goal(at: Vector2):
	_mouse(at, true)
	_mouse(at, false)
	var goal = walk._target
	walk._new_action()
	walk._target = null
	return goal


# A wall is not floor (#280). In every room, facing each of its walls in turn from the middle,
# a click on the drawn wall starts no walk, and a click in a doorway of that wall still does.
func _wall_clicks(areas: Array, when: String) -> void:
	var entry := {
		"name": "wall and doorway clicks" + when,
		"walls": 0,
		"doorways": 0,
		"not_tried": [],
		"walked": [],
		"dead_doorways": []
	}
	for area in areas:
		var b: Array = area.b
		if b[1] - b[0] < 2.5 or b[3] - b[2] < 2.5:
			continue  # a doorway's own thickness
		var openings := {"north": [-0.95, 0.95], "south": [-0.95, 0.95]}  # the Hall's two doors
		for room in walk._plan:
			if room.label == area.label:
				openings = room.openings
		var middle_of := Vector3((b[0] + b[1]) / 2.0, 0, (b[2] + b[3]) / 2.0)
		for side in walk.SIDES:
			var out: Vector3 = walk.SIDES[side]
			var along_z: bool = side in ["west", "east"]
			var plane: float = b[["west", "east", "north", "south"].find(side)]
			# From the middle, or four metres short of the wall in a long room.
			var reach: float = absf(plane - (middle_of.x if along_z else middle_of.z))
			var stand := _free_near(middle_of + out * maxf(0.0, reach - 4.0))
			if not walk._free(stand):
				# No floor there to stand on (the Skylight Gallery's middle is open to its
				# lower storey): this wall is not tried from here.
				entry.not_tried.append("%s, %s (no floor at the standpoint)" % [area.label, side])
				continue
			var door: Array = openings.get(side, [])
			var spans := [[b[2], b[3]] if along_z else [b[0], b[1]]]
			if not door.is_empty():
				spans = [[spans[0][0], door[0]], [door[1], spans[0][1]]]
			_place(stand)
			walk.view_yaw = atan2(-out.x, -out.z)
			for settle in 8:
				await process_frame
			var name := "%s, %s" % [area.label, side]
			# The wall: the middle of each solid stretch, at three heights, until one shows.
			var at = null
			for span in spans:
				for height in [1.5, 0.5, 2.5]:
					var middle: float = (span[0] + span[1]) / 2.0
					if at == null and span[1] - span[0] > 0.6:
						at = _wall_pixel(
							Vector3(plane, height, middle) if along_z else Vector3(middle, height, plane)
						)
			if at == null:
				entry.not_tried.append(name + " wall")
			else:
				entry.walls += 1
				if _click_goal(at) != null:
					entry.walked.append(name)
			if door.is_empty():
				continue
			var centre: float = (door[0] + door[1]) / 2.0
			var sill := Vector3(plane, 0, centre) if along_z else Vector3(centre, 0, plane)
			# A metre up, a doorway shows the dark beyond the stage. Where the area behind it is
			# part of this stage (a wall's thickness, a stub) it shows that area's back wall,
			# so there the floor in the doorway is clicked.
			var beyond: int = walk._room_at(sill + out * 0.3)
			var joined: bool = beyond >= 0 and walk._stage_of(beyond) == walk._stage
			# High in the opening too where it is dark: the ray's own ground point is then far
			# off, which is what used to send the visitor rooms away.
			at = _wall_pixel(sill + Vector3(0, 0.3 if joined else 1.0, 0))
			var high = null if joined else _wall_pixel(sill + Vector3(0, 2.2, 0))
			if high != null:
				entry.doorways += 1
				var far_goal = _click_goal(high)
				if far_goal == null or (far_goal as Vector3 - sill).dot(out) <= 0.0:
					entry.dead_doorways.append(name + ", high in the opening")
				elif (far_goal as Vector3).distance_to(sill) > READ_THROUGH:
					entry.dead_doorways.append(
						"%s, high in the opening (sent %.1f m past the door)"
						% [name, (far_goal as Vector3).distance_to(sill)]
					)
			if at == null:
				entry.not_tried.append(name + " doorway")
				continue
			entry.doorways += 1
			# Through the door and no further: beyond its plane, at least READ_IN and at most
			# READ_THROUGH from its sill.
			var goal = _click_goal(at)
			if goal == null or (goal as Vector3 - sill).dot(out) <= 0.0:
				entry.dead_doorways.append(name)
			elif (
				not joined
				and (goal as Vector3 - sill).dot(out) < READ_IN
				and walk._free(sill + out * (READ_IN + 0.4))  # where the floor goes that far
			):
				entry.dead_doorways.append(
					"%s (left %.1f m in, on the threshold)" % [name, (goal as Vector3 - sill).dot(out)]
				)
			elif (goal as Vector3).distance_to(sill) > READ_THROUGH:
				entry.dead_doorways.append(
					"%s (sent %.1f m past the door)" % [name, (goal as Vector3).distance_to(sill)]
				)
	var problems := PackedStringArray()
	if not entry.walked.is_empty():
		problems.append("a click on a wall started a walk: " + "; ".join(entry.walked))
	if not entry.dead_doorways.is_empty():
		problems.append(
			"a click in a doorway did not walk through: " + "; ".join(entry.dead_doorways)
		)
	entry["result"] = "ok" if problems.is_empty() else ", ".join(problems)
	report.interaction.append(entry)
	if not problems.is_empty():
		_fail("interaction", entry.name + ": " + entry.result, entry)


# The work under the pointer is the one that answers (#280). In the Renaissance room's east
# case the carved diptych 22.201 lies in front of the book cover 34.016 and their boxes overlap
# on screen. Seen from either end of the case a click on the diptych selects the diptych, and
# the book cover still answers a click on itself.
func _overlapped_works() -> void:
	var by := {}
	for thing in walk._objects:
		by[thing.tag.get_slice("#", 0)] = thing
	var entry := {"name": "works whose boxes overlap", "picks": []}
	var problems := PackedStringArray()
	# [view yaw, where the visitor stands along the case, the works clicked]
	for pose in [[0.0, 1.0, ["22.201", "34.016"]], [PI, 2.5, ["22.201"]]]:
		_place(Vector3(-8.05, 0, pose[1]))
		walk.view_yaw = pose[0]
		for settle in 8:
			await process_frame
		for number in pose[2]:
			if not by.has(number):
				problems.append(number + " is not in the museum")
				continue
			var at := Vector2.ZERO
			for corner in by[number].corners:
				at += walk._to_screen(corner) / by[number].corners.size()
			var picked: String = walk._painting_at(at).get("tag", "")
			entry.picks.append(
				{"clicked": number, "facing": "north" if pose[0] == 0.0 else "south", "picked": picked}
			)
			if picked.get_slice("#", 0) != number:
				problems.append(
					"a click on the middle of %s selects %s" % [number, picked if picked != "" else "nothing"]
				)
	# And with the mouse, from the first pose: the diptych's own caption opens.
	if by.has("22.201"):
		_place(Vector3(-8.05, 0, 1.0))
		for settle in 8:
			await process_frame
		var at := Vector2.ZERO
		for corner in by["22.201"].corners:
			at += walk._to_screen(corner) / by["22.201"].corners.size()
		_mouse(at, true)
		_mouse(at, false)
		var clock := 0.0
		while walk._inspect.is_empty() and clock < 20.0:
			await process_frame
			clock += root.get_process_delta_time()
		entry["opened"] = walk._inspect.get("tag", "")
		if str(entry.opened).get_slice("#", 0) != "22.201":
			problems.append(
				"clicking 22.201 opened %s" % (entry.opened if entry.opened != "" else "nothing")
			)
		walk._end_inspect(false)
		for settle in 50:
			await process_frame
	entry["result"] = "ok" if problems.is_empty() else ", ".join(problems)
	report.interaction.append(entry)
	if not problems.is_empty():
		_fail("interaction", entry.name + ": " + entry.result, entry)


# "Other wall" during a room change (#280, round 4). Walking out of the Hall into the medieval
# room and back, the button may not show from the moment a wipe starts until it has finished,
# and a press where it stands may not turn the view.
func _other_wall_in_wipe() -> void:
	var button: Button = walk.get_node("OtherWall")
	# [from, the key that leads through the portal in the north-facing view]
	for leg in [[Vector3(0, 0, -0.9), "down"], [Vector3(0, 0, walk.PORTAL_MOUTH + 0.9), "up"]]:
		_place(leg[0])
		for settle in 30:
			await process_frame
		var entry := {
			"name": "other wall during a room change, from " + _area_at(leg[0]),
			"shown_frames": 0,
			"wipe_frames": 0,
			"rooms_built_in_it": walk.state().get("pending", false)
		}
		var yaw: float = walk.view_yaw
		var turned := false
		for tick in 1800:
			# The key is let go once the wipe starts: the change walks the visitor in itself,
			# and a held key would refuse the button anyway.
			walk._held = {leg[1]: 1.0} if entry.wipe_frames == 0 else {}
			await process_frame
			if walk._wipe_t < 0.0:
				if entry.wipe_frames > 0:
					break  # the change has finished
				continue
			entry.wipe_frames += 1
			# In the black the arrival may turn the view to show the room (round 4); only a
			# turn besides that one is the button's.
			if walk._wipe_t >= walk.WIPE_CLOSE and not entry.has("arrival_yaw"):
				entry["arrival_yaw"] = snappedf(walk.view_yaw, 0.01)
				yaw = walk.view_yaw
			entry.shown_frames += int(button.is_visible_in_tree())
			if entry.wipe_frames == 12:
				await _press(button.get_global_rect().get_center())
			turned = turned or absf(walk._view_turn_remaining) > 0.001
		walk._held = {}
		for settle in 60:
			await process_frame
			turned = turned or absf(walk._view_turn_remaining) > 0.001
		entry["turned_rad"] = snappedf(absf(wrapf(walk.view_yaw - yaw, -PI, PI)), 0.01)
		entry["ended_in"] = _area_at(walk._pos)
		var problems := PackedStringArray()
		if entry.wipe_frames == 0:
			problems.append("no room change happened")
		if entry.shown_frames > 0:
			problems.append("the button showed for %d frames of the wipe" % entry.shown_frames)
		if turned or entry.turned_rad > 0.01:
			problems.append("a press during the wipe turned the view")
		entry["result"] = "ok" if problems.is_empty() else ", ".join(problems)
		report.interaction.append(entry)
		if not problems.is_empty():
			_fail("interaction", entry.name + ": " + entry.result, entry)


# Reading a Hall work frames the work (round 4, #272's rule begun). One painting on each wall
# and the three the playtest named are clicked from in front; a second later the camera is on
# its inspection shot, the work's rectangle on screen lies inside the picture and stands at
# least READ_HEIGHT of its height, the caption panel covers no more than READ_COVERED of the
# work, and the caption has its title.
func _hall_readings(when: String) -> void:
	var entry := {"name": "reading a Hall work frames it" + when, "works": []}
	var problems := PackedStringArray()
	for tag in ["S2", "E8", "E5", "W2", "N1"]:
		var thing := {}
		for painting in walk._paintings:
			if painting.tag == tag:
				thing = painting
		if thing.is_empty():
			problems.append(tag + " is not in the Hall")
			continue
		await _read(thing)
		var row := {"work": tag, "read": walk._inspect.get("tag", "")}
		var faults := PackedStringArray()
		if row.read != tag:
			faults.append("opened %s" % (row.read if row.read != "" else "nothing"))
		else:
			var shot: Transform3D = walk._inspect_shot(walk._inspect)
			row["camera_off_shot_m"] = snappedf(walk._cam.global_position.distance_to(shot.origin), 0.01)
			var work := _on_screen(thing.corners)
			var panel: Control = walk._inspect_panel
			var covered := 0.0
			if panel != null and panel.is_visible_in_tree() and work.has_area():
				covered = work.intersection(panel.get_global_rect()).get_area() / work.get_area()
			row["inside_picture"] = work.has_area() and Rect2(Vector2.ZERO, walk.size).grow(2).encloses(work)
			row["height_share"] = snappedf(work.size.y / walk.size.y, 0.01)
			row["under_caption"] = snappedf(covered, 0.01)
			row["title"] = str(panel.get_child(0).get_node("Title").text) if panel != null else ""
			if row.camera_off_shot_m > 0.05:
				faults.append("the camera is %.2f m from its inspection shot" % row.camera_off_shot_m)
			if not row.inside_picture:
				faults.append("the work is not wholly inside the picture")
			if row.height_share < READ_HEIGHT:
				faults.append("the work stands only %.2f of the picture's height" % row.height_share)
			if covered > READ_COVERED:
				faults.append("the caption panel covers %.2f of the work" % covered)
			if row.title.strip_edges() == "":
				faults.append("the caption has no title a second after it opened")
		entry.works.append(row)
		if not faults.is_empty():
			problems.append("%s: %s" % [tag, ", ".join(faults)])
		walk._end_inspect(false)
		for settle in 60:
			await process_frame
	entry["result"] = "ok" if problems.is_empty() else "; ".join(problems)
	report.interaction.append(entry)
	if not problems.is_empty():
		_fail("interaction", entry.name + ": " + entry.result, entry)
