## Measures the Main Hall's baked light against the five targets of the finish spec
## (docs/research/2026-10-01-acnh-museum-polish-spec.md, section 4, step 3), the way that report
## sampled the game: display luma (Rec. 709 weights on the encoded values) of patches of the
## standard dollhouse view of a painting wall. It also reads the visitor's probe light at five
## places and saves the views used as before/after evidence.
##   godot --rendering-method gl_compatibility --path . --script \
##     res://modules/shell/prototype/gallery_walk4/bake/measure_light.gd -- --out-dir=/tmp/light
## Needs a display. Prints LIGHT_TARGET n ... PASS|FAIL, writes light.json, exits 1 on a FAIL.
## After a bake run `godot --headless --editor --import --path .` first: the editor leaves the
## previous lightmap texture in the import cache, and the game then shows the old light.
extends "res://testing/harness_base.gd"

const DIR := "res://modules/shell/prototype/gallery_walk4/"
# The standard view of a painting wall: the visitor 2.4 m from it, where "Other wall" stands.
const WALL_VIEWS := [
	["west-a", Vector3(-2.6, 0, -5.0), PI / 2.0],
	["west-b", Vector3(-2.6, 0, -13.0), PI / 2.0],
	["west-c", Vector3(-2.6, 0, -21.0), PI / 2.0],
	["east-a", Vector3(2.6, 0, -5.0), -PI / 2.0],
	["east-b", Vector3(2.6, 0, -13.0), -PI / 2.0],
	["east-c", Vector3(2.6, 0, -21.0), -PI / 2.0],
]
# Where the visitor's probe light is read: under the skylight, at the foot of each long wall,
# in the arch doorway and in the far corner.
const PLACES := [
	["centre", Vector3(0, 0, -13.0), PI],
	["west-wall", Vector3(-4.3, 0, -7.0), PI / 2.0],
	["east-wall", Vector3(4.3, 0, -19.0), -PI / 2.0],
	["arch-door", Vector3(0, 0, -0.9), PI],
	["far-corner", Vector3(4.2, 0, -25.6), 0.0],
]
# The floor is read in half-metre bands out from the wall, starting clear of the skirting.
const BAND := 0.5
const BAND_FROM := 0.25
const CARD_COLORS := [Color("#a3afb8"), Color("#e9e4d4")]  # the label plate before and after #238
# The Hall's walls are dark slate, so the whole-picture target is the dark-walled one. The
# pale-room range (0.35-0.40) is printed beside it: with unshaded canvases near 0.3 it can only
# be reached by a floor brighter than the art, which is target 2 failing.
const MEAN_RANGE := Vector2(0.20, 0.30)

var walk: Control
var cards: Array[AABB] = []
var card_paint := Color.WHITE


static func _luma(sum: Array) -> float:
	return (
		(0.2126 * sum[0] + 0.7152 * sum[1] + 0.0722 * sum[2]) / sum[3] if sum[3] > 0 else 0.0
	)


func _initialize() -> void:
	call_deferred("run")


func _pose(pos: Vector3, yaw: float, mode := 0) -> void:
	var facing := Vector3(-sin(yaw), 0, -cos(yaw))
	walk.view_mode = mode
	walk.view_yaw = yaw
	walk._yaw = yaw
	walk._pos = pos
	walk._motion_heading = facing
	walk._kid.position = pos
	walk._kid.reset()
	walk._kid.pose(0.0, false, 0.0, facing, yaw)
	walk._update_camera(1.0)
	await _frames(4)


# The label cards: the separate boxes of the baked meshes that carry a card colour.
func _find_cards() -> void:
	for mesh in walk._baked_room.find_children("*", "MeshInstance3D", true, false):
		var material := mesh.material_override as StandardMaterial3D
		if material == null or material.albedo_texture != null:
			continue
		if not CARD_COLORS.any(
			func(color: Color) -> bool: return material.albedo_color.is_equal_approx(color)
		):
			continue
		card_paint = material.albedo_color
		for vertex in mesh.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]:
			var point: Vector3 = mesh.global_transform * vertex
			var index := 0
			while index < cards.size() and cards[index].get_center().distance_to(point) > 0.5:
				index += 1
			if index == cards.size():
				cards.append(AABB(point, Vector3.ZERO))
			cards[index] = cards[index].expand(point)


# One view of a wall whose normal (into the room) is n: the summed colour and pixel count of
# every zone. Zones, in wall metres (u along the wall, v up):
#   picture  every pixel
#   canvas   inside a canvas, 6% in from its edge (the shaped W6 is left out)
#   pool     the wall just above a frame: from 5 cm above its top edge, a fifth of the frame's
#            height tall (15-40 cm), the middle 80% of its width. That is where a pool shows:
#            the canvas and frame under its centre are unshaded.
#   away     the wall between two works (the middle third of the gap, over the heights both
#            frames share) and any wall at least 0.75 m from every frame
#   floorN   the floor BAND_FROM + N * BAND metres from the wall
#   card     the middle 60% of a label card
func _read(n: Vector3) -> Dictionary:
	var image: Image = walk._vp.get_texture().get_image()
	var cam: Camera3D = walk._cam
	var along := Vector3.UP.cross(n)
	var frames := []
	var wall := 0.0
	for p in walk._paintings:
		if p.normal.dot(n) > 0.9:
			wall = p.center.dot(n)
			frames.append(
				{
					"u": p.center.dot(along),
					"v": p.center.y,
					"w": p.outer.x / 2.0,
					"h": p.outer.y / 2.0,
					"cw": 0.0 if p.rec.has("outline") else p.rec.canvas_w * 0.47,
					"ch": p.rec.canvas_h * 0.47
				}
			)
	frames.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.u < b.u)
	var here := cards.filter(
		func(card: AABB) -> bool: return absf(card.get_center().dot(n) - wall) < 0.1
	)
	var body := Rect2(cam.unproject_position(walk._pos), Vector2.ZERO)
	for x in [-0.6, 0.6]:
		for y in [0.0, 1.95]:
			for z in [-0.6, 0.6]:
				body = body.expand(cam.unproject_position(walk._pos + Vector3(x, y, z)))
	body = body.grow(4)
	var sums := {}
	var add := func(zone: String, c: Color) -> void:
		var sum: Array = sums.get_or_add(zone, [0.0, 0.0, 0.0, 0])
		sum[0] += c.r
		sum[1] += c.g
		sum[2] += c.b
		sum[3] += 1
	var eye := cam.global_position
	for y in image.get_height():
		for x in image.get_width():
			var c := image.get_pixel(x, y)
			add.call("picture", c)
			if body.has_point(Vector2(x, y)):
				continue
			var ray := cam.project_ray_normal(Vector2(x + 0.5, y + 0.5))
			var hit := eye + ray * ((wall - eye.dot(n)) / ray.dot(n))
			if hit.z > -0.4 or hit.z < -walk.L + 0.4:
				continue
			if hit.y <= 0.0:
				var from_wall := (eye - ray * (eye.y / ray.y)).dot(n) - wall
				if from_wall >= BAND_FROM:
					add.call("floor%d" % int((from_wall - BAND_FROM) / BAND), c)
				continue
			var u := hit.dot(along)
			var v := hit.y
			# Canvases sit 5.5 cm proud of the wall; read them on their own plane.
			var face := eye + ray * ((wall + 0.055 - eye.dot(n)) / ray.dot(n))
			var zone := ""
			var nearest := INF
			for card: AABB in here:
				var across := absf(u - card.get_center().dot(along)) / absf(card.size.dot(along))
				var up := absf(v - card.get_center().y) / card.size.y
				if across < 0.3 and up < 0.3:
					zone = "card"
				elif across < 0.65 and up < 0.75:
					zone = "skip"
			for index in frames.size():
				var frame: Dictionary = frames[index]
				var du: float = absf(u - frame.u) - frame.w
				var dv: float = absf(v - frame.v) - frame.h
				var above: float = v - frame.v - frame.h
				nearest = minf(nearest, Vector2(maxf(du, 0.0), maxf(dv, 0.0)).length())
				if (
					absf(face.dot(along) - frame.u) < frame.cw
					and absf(face.y - frame.v) < frame.ch
				):
					zone = "canvas"
				elif zone != "":
					pass
				elif du < 0.07 and dv < 0.07:
					zone = "skip"
				elif (
					du < -0.2 * frame.w
					and above > 0.05
					and above < 0.05 + clampf(0.4 * frame.h, 0.15, 0.4)
				):
					zone = "pool"
				elif index > 0:
					var left: Dictionary = frames[index - 1]
					var gap: float = frame.u - frame.w - left.u - left.w
					if (
						gap >= 0.45
						and absf(u - (frame.u - frame.w - gap / 2.0)) < gap / 6.0
						and v > maxf(frame.v - frame.h, left.v - left.h)
						and v < minf(frame.v + frame.h, left.v + left.h)
					):
						zone = "away"
			if zone == "" and nearest >= 0.75:
				zone = "away"
			# Below 0.36 m the skirting stands in front of the wall.
			if zone in ["canvas", "card"] or (zone in ["pool", "away"] and v > 0.36):
				add.call(zone, c)
	return sums


# The visitor alone (its own render layer, with its own lamp): mean luma, and the shares of
# its pixels that are blown out (luma over 0.97) or lost in the dark (under 0.04).
func _visitor() -> Dictionary:
	var mask: int = walk._cam.cull_mask
	walk._kid._fill.layers |= walk._kid.FILL_LAYER  # a camera only applies lamps it can see
	walk._cam.cull_mask = walk._kid.FILL_LAYER
	await _frames(3)
	var image: Image = walk._vp.get_texture().get_image()
	walk._cam.cull_mask = mask
	var void_color := image.get_pixel(0, 0)
	var total := 0.0
	var count := 0
	var blown := 0
	var dark := 0
	for y in image.get_height():
		for x in image.get_width():
			var c := image.get_pixel(x, y)
			if c.is_equal_approx(void_color):
				continue
			var luma := 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
			total += luma
			count += 1
			blown += int(luma > 0.97)
			dark += int(luma < 0.04)
	return {
		"pixels": count,
		"mean": snappedf(total / maxi(count, 1), 0.001),
		"blown": snappedf(float(blown) / maxi(count, 1), 0.001),
		"dark": snappedf(float(dark) / maxi(count, 1), 0.001)
	}


func run() -> void:
	walk = load(DIR + "walk4.gd").new()
	walk.set_process(false)
	var out := await _mount(walk, Vector2i(960, 640), "/tmp/hall-light")
	walk.size = Vector2(960, 640)  # sized in the tree, so the view renders at its own 480 x 320
	walk.set_process(false)
	walk._new_action()
	walk._entrance_active = false
	walk._entrance_waiting = false
	walk._target = null
	walk.get_node("OtherWall").hide()
	_find_cards()
	var report := {"views": {}, "visitor": {}, "targets": []}
	var total := {}
	for zone in ["picture", "canvas", "pool", "away", "card", "floor0"]:
		total[zone] = [0.0, 0.0, 0.0, 0]
	for view in WALL_VIEWS:
		await _pose(view[1], view[2])
		await _shot(out, "wall-%s.png" % view[0])
		var sums := _read(Vector3(sin(view[2]), 0, cos(view[2])))
		var line := {}
		for zone in sums:
			line[zone] = snappedf(_luma(sums[zone]), 0.001)
			var sum: Array = total.get_or_add(zone, [0.0, 0.0, 0.0, 0])
			for index in 4:
				sum[index] += sums[zone][index]
		if sums.has("card"):
			line["card_red_over_blue"] = snappedf(sums.card[0] / sums.card[2], 0.001)
		report.views[view[0]] = line
		print("LIGHT_VIEW ", view[0], " ", JSON.stringify(line))
	# Evidence views that are not measured: the bench area, the follow view down the Hall, one
	# painting and its label close up.
	await _pose(Vector3(1.4, 0, -6.2), 0.0)
	await _shot(out, "bench.png")
	await _pose(Vector3(0, 0, -3.0), 0.0, 2)
	await _shot(out, "follow.png")
	await _pose(Vector3(-2.6, 0, -4.0), PI / 2.0)
	walk._cam.cull_mask = walk._cutaway_mask(63, 1.0)
	walk._cam.fov = 40.0
	walk._cam.position = Vector3(-1.9, 1.4, -8.8)
	walk._cam.look_at(Vector3(-5.0, 1.4, -8.8))
	await _shot(out, "painting-close.png")
	for place in PLACES:
		await _pose(place[1], place[2])
		await _shot(out, "visitor-%s.png" % place[0])
		var visitor: Dictionary = await _visitor()
		report.visitor[place[0]] = visitor
		print("LIGHT_VISITOR ", place[0], " ", JSON.stringify(visitor))
	# The lit floor is the brightest band in view; the room's edge is the band at the wall's foot.
	var lit := 0.0
	var profile := []
	for band in 16:
		var sum: Array = total.get("floor%d" % band, [0.0, 0.0, 0.0, 0])
		if sum[3] >= 400:
			profile.append(snappedf(_luma(sum), 0.001))
			lit = maxf(lit, _luma(sum))
	var edge := _luma(total.floor0)
	var pool := _luma(total.pool)
	var away := _luma(total.away)
	var canvas := _luma(total.canvas)
	var card: Array = total.card
	var mean := _luma(total.picture)
	print("LIGHT_FLOOR luma by half-metre band out from the wall ", profile)
	print(
		(
			"LIGHT_ZONES canvas=%.3f wall_in_pool=%.3f wall_away=%.3f floor_lit=%.3f floor_edge=%.3f"
			% [canvas, pool, away, lit, edge]
		),
		" card_paint_red_over_blue=%.3f" % (card_paint.r / card_paint.b),
		" pixels canvas=%d pool=%d away=%d card=%d"
		% [total.canvas[3], total.pool[3], total.away[3], card[3]]
	)
	var failures := 0
	for target in [
		["wall away from pools / wall in a pool", away / maxf(pool, 0.001), 0.0, 1.0 / 3.0],
		["canvases / lit floor", canvas / maxf(lit, 0.001), 1.2, INF],
		["lit floor / floor at the room's edge", lit / maxf(edge, 0.001), 2.0, INF],
		["label card red / blue", card[0] / maxf(card[2], 0.001), 0.0, 1.25],
		["whole-picture mean", mean, MEAN_RANGE.x, MEAN_RANGE.y],
	]:
		var passed: bool = target[1] >= target[2] and target[1] <= target[3]
		failures += int(not passed)
		var wanted := "%.2f to %.2f" % [target[2], target[3]]
		if target[3] == INF:
			wanted = "at least %.2f" % target[2]
		elif target[2] == 0.0:
			wanted = "at most %.2f" % target[3]
		report.targets.append(
			{"name": target[0], "value": snappedf(target[1], 0.001), "pass": passed}
		)
		print(
			"LIGHT_TARGET %d %s = %.3f (%s) %s"
			% [report.targets.size(), target[0], target[1], wanted, "PASS" if passed else "FAIL"]
		)
	print("LIGHT_NOTE a pale room would need a whole-picture mean of 0.35 to 0.40")
	report["floor_profile"] = profile
	var file := FileAccess.open(out.path_join("light.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	file.close()
	print("LIGHT_FAILURES ", failures)
	quit(1 if failures else 0)
