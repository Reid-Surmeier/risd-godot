## Whole-museum playtest (docs/playtest/museum-playtest-rules.md is the contract).
## 1 doors:   every doorway is crossed on foot in both directions with held keys.
## 2 rooms:   from each of its doors, a click on the middle of every room walks there.
## 3 views:   every standpoint is photographed from four dollhouse directions and the follow
##            view; a view the wall fills, or one that hides the visitor, is a failure.
## 4 objects: every artwork is clicked with a real mouse event; the visitor must walk up,
##            a detail must open, and it must close again.
## source ~/promo-lab/gpu-env.sh   (the RTX through Mesa d3d12; llvmpipe is ten times slower)
## godot --fixed-fps 60 --path . --script res://modules/shell/playtest/museum_playtest.gd
##   --display-driver x11 --rendering-driver opengl3 -- --out-dir=<dir> [--only=doors,rooms,views,objects]
## --fixed-fps makes every frame one sixtieth of a second of game time, so a run is repeatable.
extends SceneTree

const SIZE := Vector2i(960, 640)
const HALL := "Grand Gallery"

var walk
var out := ""
var report := {"doors": [], "rooms": [], "views": [], "objects": [], "failures": []}


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
	var only := _arg("only", "doors,rooms,views,objects").split(",")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	root.size = SIZE
	walk = load("res://modules/shell/prototype/collection_reconstruction/main_build_walk.gd").new()
	walk.size = Vector2(SIZE)
	root.add_child(walk)
	for i in 240:
		await process_frame
	if not walk.state().attached:
		_fail("setup", "the room scene did not attach")
	walk._new_action()
	if "doors" in only:
		await _doors()
	if "rooms" in only:
		await _rooms()
	if "views" in only:
		await _views()
	if "objects" in only:
		await _objects()
	report["state"] = walk.state()
	report["summary"] = {
		"doors": report.doors.size(),
		"rooms": report.rooms.size(),
		"views": report.views.size(),
		"objects": report.objects.size(),
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


func _place(p: Vector3) -> void:
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
	walk.view_yaw = 0.0
	walk._yaw = 0.0
	walk._kid.position = p
	walk._kid.reset_contacts()
	walk._update_camera(1.0)


# Hold the keys a player would hold to reach `goal` in the north-facing dollhouse view.
func _walk_keys(goal: Vector3, limit_s: float) -> Dictionary:
	var started := walk._pos as Vector3
	var clock := 0.0
	var stuck := 0.0
	var longest_step := 0.0
	var steps := 0
	var walked_clip := false
	var before := walk._pos as Vector3
	while clock < limit_s:
		var to: Vector3 = goal - walk._pos
		to.y = 0
		if to.length() < 0.25:
			break
		var held := {}
		if absf(to.z) > 0.12:
			held["up" if to.z < 0 else "down"] = 1.0
		if absf(to.x) > 0.12:
			held["right" if to.x > 0 else "left"] = 1.0
		walk._held = held
		await process_frame
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
	for settle in 20:
		await process_frame
	var left: float = Vector3(goal.x - walk._pos.x, 0, goal.z - walk._pos.z).length()
	return {
		"arrived": left < 0.3,
		"left_m": snappedf(left, 0.01),
		"seconds": snappedf(clock, 0.1),
		"walked_m": snappedf(started.distance_to(walk._pos), 0.01),
		"longest_step_m": snappedf(longest_step, 0.001),
		"footsteps": steps,
		"walk_clip": walked_clip,
		"idle_after": walk._kid._clip == "idle",
		"ended_in": _area_at(walk._pos),
		"ended_at": [snappedf(walk._pos.x, 0.01), snappedf(walk._pos.z, 0.01)]
	}


func _doors() -> void:
	for door in _doorways():
		for way in [[door.from, door.to, door.a, door.b], [door.to, door.from, door.b, door.a]]:
			_place(way[0])
			for settle in 6:
				await process_frame
			var leg := await _walk_keys(way[1], 12.0)
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


func _rooms() -> void:
	var doors := _doorways()
	for area in _areas():
		var b: Array = area.b
		var middle := _free_near(Vector3((b[0] + b[1]) / 2.0, 0, (b[2] + b[3]) / 2.0))
		for door in doors:
			var start = door.from if door.a == area.label else (door.to if door.b == area.label else null)
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
				_fail("room", area.label + ": a click on its middle did not bring the visitor there", leg)
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


func _views() -> void:
	for area in _areas():
		var slug: String = area.label.to_lower().replace(" ", "-")
		var b: Array = area.b
		var long_z: bool = b[3] - b[2] > b[1] - b[0]
		var span: float = (b[3] - b[2]) if long_z else (b[1] - b[0])
		var count := maxi(1, roundi(span / 7.0))
		for n in count:
			var along := (n + 0.5) / count
			var here := Vector3(
				(b[0] + b[1]) / 2.0 if long_z else lerpf(b[0], b[1], along),
				0,
				lerpf(b[2], b[3], along) if long_z else (b[2] + b[3]) / 2.0
			)
			for view in ["n", "e", "s", "w", "follow"]:
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
				for y in range(0, SIZE.y, 4):
					for x in range(0, SIZE.x, 4):
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
					_fail("view", "%s %s: one flat surface fills the picture" % [area.label, view], entry)
				elif entry.visitor_pixels < 400:
					_fail("view", "%s %s: the visitor cannot be seen" % [area.label, view], entry)


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
		var at: Vector2 = walk._cam.unproject_position(points[i]) / Vector2(walk._vp.size) * walk.size
		box = Rect2(at, Vector2.ZERO) if i == 0 else box.expand(at)
	return box


func _objects() -> void:
	var things: Array = walk._paintings.duplicate()
	if walk.get("_objects") is Array:
		things += walk._objects
	for thing in things:
		var tag: String = thing.tag
		var entry := {
			"tag": tag,
			"title": str(thing.rec.get("title", "")),
			"room": walk._plan[thing.room].label if thing.has("object") else HALL
		}
		# Stand in front of it and face it, as a visitor would before clicking: nearer or
		# further until it is on screen. A free-standing work is viewed from the room's middle.
		var facing: Vector3 = thing.normal
		if facing == Vector3.ZERO:
			var room: Array = walk._plan[thing.room].b
			facing = Vector3((room[0] + room[1]) / 2.0 - thing.center.x, 0, (room[2] + room[3]) / 2.0 - thing.center.z)
			facing = facing.normalized() if facing.length() > 0.3 else Vector3.BACK
		var at := Vector2.ZERO
		var picked := ""
		# Dollhouse view first; a work hung above its frame (a chandelier) from the follow view.
		for distance in [3.0, 2.0, 4.5, 6.0, 1.4, 8.0, -4.5, -7.0]:
			var stand: Vector3 = _free_near(Vector3(thing.center.x, 0, thing.center.z) + facing * absf(distance))
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
				var edge: Vector2 = walk._cam.unproject_position(corner) / Vector2(walk._vp.size) * walk.size
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
		var problems := PackedStringArray()
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
		# The whole work is in the picture and the visitor stands beside it, not over it.
		var work := _on_screen(thing.corners)
		var body: Array = []
		for i in 8:
			body.append(walk._pos + Vector3(0.4 if i & 1 else -0.4, 1.7 if i & 2 else 0.0, 0.4 if i & 4 else -0.4))
		entry["work_on_screen"] = [roundi(work.position.x), roundi(work.position.y), roundi(work.size.x), roundi(work.size.y)]
		if not Rect2(Vector2.ZERO, walk.size).grow(2).encloses(work):
			problems.append("the work is not wholly in the inspection picture")
		entry["visitor_stepped_out"] = not walk._kid.visible
		if walk._kid.visible and work.intersects(_on_screen(body)):
			problems.append("the visitor covers the work")
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
			await _shot("zoom-%s.png" % slug)
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
		entry["result"] = "inspected, zoomed and closed" if problems.is_empty() else ", ".join(problems)
		report.objects.append(entry)
		if not problems.is_empty():
			_fail("object", tag + ": " + entry.result, entry)
