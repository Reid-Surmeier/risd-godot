## Lion stair landing (#238): the open-well stair, its well, the stone floor, the ceiling and the
## wall colours. Sizes are estimates from IMG_6344 3.0s and IMG_6387 28.5s scaled to this room's
## plan; nothing here is surveyed. docs/evidence/museum-238/stairwell/NOTES.md has the frames.
extends RefCounted

const Marble := preload("marble_hall_additions.gd")

const LABEL := "lion stair landing"
const RISE := 0.155 # 6344 3.0s: one riser is 1/5.4 of the landing rail and 1/6.8 of the flight's width
const WIDTH := 1.06 # west and east runs, wall to stringer
const DEPTH := 1.10 # south run and both quarter landings
const SETBACK := 0.20 # the risers next to a quarter landing stand this far back from the well corner
const RISERS := [9, 11, 9] # 6387 28.5s (west run), 6.5s (south run); east run taken as the west one
const WAIST := 0.21
const RAIL := 0.84 # above a nosing; the landing rail stands at 0.90
const TOP := 8.3 # ceiling of the floor above, not seen closely: provisional
const STONE := Color("b5b2aa")
const WHITE := Color("f3f1ea")
const CREAM := Color("eeece5")
const IRON := Color("2e2b29")
const WOOD := Color("6a4a2e")
const STRIP := Color("3b3d40")

var room: Node3D
var st: SurfaceTool
var x0: float
var x1: float
var z0: float
var zs: float
var edge: float # the landing's south edge: first riser up, top riser of the flight from below
var g_side: float
var g_west: float
var west_edge: float
var g_south: float
var ironwork: Marble.Batch
var oak_rails: Marble.Batch

func build(scene: Node3D) -> void:
	room = scene
	var b: Array = room.room_bounds(LABEL)
	x0 = b[0] + .061
	x1 = b[1] - .061
	z0 = b[2] + .061
	zs = b[3] - .061
	for area in JSON.parse_string(FileAccess.get_file_as_string("res://modules/shell/collection_rooms/geometry.json")).rooms:
		if area.label == LABEL:
			edge = area.floor_void[2]
			# Leave the folded medieval fire leaf on a landing, ahead of the first riser.
			west_edge = maxf(edge, area.openings.west[1] + .05)
	g_side = (zs - DEPTH - SETBACK - edge) / (RISERS[0] - 1)
	g_west = (zs - DEPTH - SETBACK - west_edge) / (RISERS[0] - 1)
	g_south = (x1 - x0 - 2 * (WIDTH + SETBACK)) / (RISERS[1] - 1)
	var storey: float = RISE * (RISERS[0] + RISERS[1] + RISERS[2])
	var paint := StandardMaterial3D.new()
	paint.vertex_color_use_as_albedo = true
	paint.vertex_color_is_srgb = true
	paint.roughness = .95
	paint.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	lay_floor(b, paint)
	paint_walls()
	lion_wall_details()
	landing_leaves()
	ironwork = Marble.Batch.new()
	oak_rails = Marble.Batch.new()
	# Always drawn: the flight up as far as its second quarter landing, the whole flight down,
	# the landing balustrade and the lining of the well below the floor.
	begin()
	lower_runs(0.0)
	lower_runs(-storey)
	east_run(-storey)
	landing_guard(0.0, x0 + WIDTH - .05, x1 - WIDTH + .05)
	# The well below: the three outer walls, a closed wall under the landing edge (the floor
	# below was not surveyed) and a continuation into the second storey below.
	var low := -storey - WAIST
	quad(Vector3(x0, low, zs), Vector3(x0, low, edge), Vector3(x0, 0, edge), Vector3(x0, 0, zs), CREAM)
	quad(Vector3(x1, low, zs), Vector3(x0, low, zs), Vector3(x0, 0, zs), Vector3(x1, 0, zs), CREAM)
	quad(Vector3(x1, low, edge), Vector3(x1, low, zs), Vector3(x1, 0, zs), Vector3(x1, 0, edge), CREAM)
	quad(Vector3(x0, low, edge), Vector3(x1, low, edge), Vector3(x1, 0, edge), Vector3(x0, 0, edge), WHITE)
	var stair := commit(paint)
	stair.name = "LionStairPrimaryStorey"
	finish_iron(room)
	stair.set_meta("landing_stair", {"rise_m": RISE, "risers": RISERS, "going_m": [g_west, g_south, g_side], "width_m": WIDTH, "storey_m": storey, "metric_accepted": false})
	# Hidden with the ceilings when the camera is above them: the run that arrives at the floor
	# above, that floor's edge, the upper walls of the stairwell and its laylight.
	begin()
	ironwork = Marble.Batch.new()
	oak_rails = Marble.Batch.new()
	east_run(0.0)
	box(Vector3(x0, 3.80, edge - .30), Vector3(x1, storey, edge), WHITE)
	landing_guard(storey, x0 + .05, x1 - WIDTH + .05)
	var back := edge - 1.2 # the floor above is open to the well; closed here 1.2 m back from its edge
	quad(Vector3(x0, 4.1, zs), Vector3(x0, 4.1, back), Vector3(x0, TOP, back), Vector3(x0, TOP, zs), WHITE)
	quad(Vector3(x1, 4.1, zs), Vector3(x0, 4.1, zs), Vector3(x0, TOP, zs), Vector3(x1, TOP, zs), WHITE)
	quad(Vector3(x1, 4.1, back), Vector3(x1, 4.1, zs), Vector3(x1, TOP, zs), Vector3(x1, TOP, back), WHITE)
	quad(Vector3(x0, 4.1, back), Vector3(x1, 4.1, back), Vector3(x1, TOP, back), Vector3(x0, TOP, back), WHITE)
	quad(Vector3(x0, TOP, back), Vector3(x1, TOP, back), Vector3(x1, TOP, zs), Vector3(x0, TOP, zs), WHITE)
	box(Vector3(x0, TOP - .22, back), Vector3(x1, TOP, back + .12), WHITE)
	box(Vector3(x0, TOP - .22, zs - .12), Vector3(x1, TOP, zs), WHITE)
	box(Vector3(x0, TOP - .22, back), Vector3(x0 + .12, TOP, zs), WHITE)
	box(Vector3(x1 - .12, TOP - .22, back), Vector3(x1, TOP, zs), WHITE)
	# 6387 31.0s: the laylight's glazing bars, 3 panes by 4.
	var lay := Rect2((x0 + x1) / 2 - 1.2, (edge + zs - DEPTH) / 2 - .9, 2.4, 1.8)
	for i in 5:
		var x: float = lay.position.x + i * lay.size.x / 4
		box(Vector3(x - .025, TOP - .06, lay.position.y), Vector3(x + .025, TOP, lay.end.y), WHITE)
	for i in 4:
		var z: float = lay.position.y + i * lay.size.y / 3
		box(Vector3(lay.position.x, TOP - .06, z - .025), Vector3(lay.end.x, TOP, z + .025), WHITE)
	var shaft := commit(paint)
	finish_iron(shaft)
	shaft.set_meta("opaque_ceiling", LABEL)
	room.ceiling_details.append(shaft)
	var glow := StandardMaterial3D.new()
	glow.albedo_color = Color("f4f7fb")
	glow.emission_enabled = true
	glow.emission = Color("eef3ff")
	glow.emission_energy_multiplier = 4.0
	begin()
	quad(Vector3(lay.position.x, TOP - .02, lay.position.y), Vector3(lay.end.x, TOP - .02, lay.position.y), Vector3(lay.end.x, TOP - .02, lay.end.y), Vector3(lay.position.x, TOP - .02, lay.end.y), Color.WHITE)
	var glass := commit(glow)
	glass.reparent(shaft)
	# The landing's own ceiling, as the other rooms' ceilings are built.
	var ceiling: MeshInstance3D = room.solid(Vector3((x0 + x1) / 2, 4.12, (z0 + edge) / 2), Vector3(x1 - x0, .04, edge - z0), room.trim_paint())
	ceiling.set_meta("opaque_ceiling", LABEL)
	room.ceiling_details.append(ceiling)
	# IMG_6387 19.5 s: continue the visible shaft and flights for a second storey down.
	# The primary stair's checked storey/extent stays on its own mesh.
	begin()
	ironwork = Marble.Batch.new()
	oak_rails = Marble.Batch.new()
	lower_runs(-2 * storey)
	east_run(-2 * storey)
	var bottom := -2 * storey - WAIST
	quad(Vector3(x0, bottom, zs), Vector3(x0, bottom, edge), Vector3(x0, low, edge), Vector3(x0, low, zs), WHITE)
	quad(Vector3(x1, bottom, zs), Vector3(x0, bottom, zs), Vector3(x0, low, zs), Vector3(x1, low, zs), WHITE)
	quad(Vector3(x1, bottom, edge), Vector3(x1, bottom, zs), Vector3(x1, low, zs), Vector3(x1, low, edge), WHITE)
	quad(Vector3(x0, bottom, edge), Vector3(x1, bottom, edge), Vector3(x1, low, edge), Vector3(x0, low, edge), WHITE)
	quad(Vector3(x0, -2 * storey, zs), Vector3(x1, -2 * storey, zs), Vector3(x1, -2 * storey, edge), Vector3(x0, -2 * storey, edge), STONE)
	commit(paint).name = "LionStairSecondStoreyBelow"
	finish_iron(room)
	# Nobody walks onto the stair or into the well: one guard across the landing edge.
	var guard: Node3D = room.solid(Vector3((x0 + WIDTH + x1) / 2, .52, edge + .045), Vector3(x1 - x0 - WIDTH, 1.04, .09), room.look(IRON), true)
	guard.get_child(1).mesh = ArrayMesh.new()
	guard.set_meta("landing_guard", true)
	var west_guard: Node3D = room.solid(Vector3(x0 + WIDTH / 2, .52, west_edge + .045), Vector3(WIDTH, 1.04, .09), room.look(IRON), true)
	west_guard.get_child(1).mesh = ArrayMesh.new()
	if west_edge > edge + .001:
		var corner_guard: Node3D = room.solid(Vector3(x0 + WIDTH, .52, (edge + west_edge) / 2 + .045), Vector3(.09, 1.04, west_edge - edge), room.look(IRON), true)
		corner_guard.get_child(1).mesh = ArrayMesh.new()
	room.inventory["lion_landing"].merge({"stair": "one open-well stair, three flights and two curved winder turns per storey", "risers_per_storey": RISERS, "ceiling": true, "laylight": true, "stair_metric_accepted": false, "visible_storeys_below": 2, "curved_guard": true}, true)

func begin() -> void:
	st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

func commit(m: Material) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	mesh.mesh = st.commit()
	mesh.material_override = m
	room.add_child(mesh)
	return mesh

## Corners counter-clockwise as seen from the side that is looked at.
func quad(a: Vector3, b: Vector3, c: Vector3, d: Vector3, tone: Color) -> void:
	st.set_color(tone)
	st.set_normal((b - a).cross(d - a).normalized())
	for p in [a, c, b, a, d, c]:
		st.add_vertex(p)

func box(lo: Vector3, hi: Vector3, tone: Color, under := Color(0, 0, 0, 0)) -> void:
	quad(Vector3(lo.x, hi.y, hi.z), Vector3(hi.x, hi.y, hi.z), Vector3(hi.x, hi.y, lo.z), Vector3(lo.x, hi.y, lo.z), tone)
	quad(Vector3(lo.x, lo.y, lo.z), Vector3(hi.x, lo.y, lo.z), Vector3(hi.x, lo.y, hi.z), Vector3(lo.x, lo.y, hi.z), tone if under.a == 0 else under)
	quad(Vector3(hi.x, lo.y, hi.z), Vector3(hi.x, lo.y, lo.z), Vector3(hi.x, hi.y, lo.z), Vector3(hi.x, hi.y, hi.z), tone)
	quad(Vector3(lo.x, lo.y, lo.z), Vector3(lo.x, lo.y, hi.z), Vector3(lo.x, hi.y, hi.z), Vector3(lo.x, hi.y, lo.z), tone)
	quad(Vector3(lo.x, lo.y, hi.z), Vector3(hi.x, lo.y, hi.z), Vector3(hi.x, hi.y, hi.z), Vector3(lo.x, hi.y, hi.z), tone)
	quad(Vector3(hi.x, lo.y, lo.z), Vector3(lo.x, lo.y, lo.z), Vector3(lo.x, hi.y, lo.z), Vector3(hi.x, hi.y, lo.z), tone)

func block(p: Vector3, q: Vector3, tone: Color, under := Color(0, 0, 0, 0)) -> void:
	box(Vector3(minf(p.x, q.x), minf(p.y, q.y), minf(p.z, q.z)), Vector3(maxf(p.x, q.x), maxf(p.y, q.y), maxf(p.z, q.z)), tone, under)

## A straight bar of rectangular section between two points.
func bar(p: Vector3, q: Vector3, wide: float, high: float, tone: Color) -> void:
	var axis := q - p
	var side := axis.cross(Vector3.UP)
	if side.length() < .0001:
		side = Vector3.RIGHT
	side = side.normalized() * wide / 2
	var up := side.cross(axis).normalized() * high / 2
	quad(p + side - up, q + side - up, q + side + up, p + side + up, tone)
	quad(p - side + up, q - side + up, q - side - up, p - side - up, tone)
	quad(p + side + up, q + side + up, q - side + up, p - side + up, tone)
	quad(p - side - up, q - side - up, q + side - up, p + side - up, tone)

## One straight run: `o` is the foot of its first riser at the wall, `d` the way up, `w` from the
## wall to the well. Treads with their anti-slip strips, a plaster soffit and stringer, two bars
## to a tread and the handrail.
func run(o: Vector3, d: Vector3, w: Vector3, width: float, risers: int, going: float) -> void:
	var length := going * (risers - 1)
	for i in risers - 1:
		var top := RISE * (i + 1)
		block(o + d * (going * i) + Vector3.UP * (top - .20), o + d * (going * (i + 1)) + w * width + Vector3.UP * top, STONE)
		block(o + d * (going * i + .035) + w * .08 + Vector3.UP * top, o + d * (going * i + .085) + w * (width - .08) + Vector3.UP * (top + .004), STRIP)
		for k in [.25, .75]:
			var foot: Vector3 = o + d * (going * (i + k)) + w * (width - .05) + Vector3.UP * top
			var height: float = RAIL + RISE * k - .025
			if k == .25:
				ironwork.panel(foot, d, height, Marble.scroll_panel_mesh())
			else:
				ironwork.box(foot + Vector3.UP * height / 2, Vector3(.014, height, .014))
	# The soffit runs with the pitch, under every tread; a short face closes it at the landing above.
	var low := o + Vector3.UP * -WAIST
	var high := o + d * length + Vector3.UP * (RISE * (risers - 1) - WAIST)
	quad(low, low + w * width, high + w * width, high, CREAM)
	quad(high + w * width, high, high + Vector3.UP * (RISE + .01), high + w * width + Vector3.UP * (RISE + .01), CREAM)
	var face := w * (width + .004)
	quad(low + face, low + face + Vector3.UP * .17, high + face + Vector3.UP * .17, high + face, WHITE)
	var hand := w * (width - .05)
	oak_rails.sweep(PackedVector3Array([o + hand + Vector3.UP * (RAIL + RISE), o + hand + d * length + Vector3.UP * (RAIL + RISE * risers)]), .060, .048)
	# The second handrail, on the wall.
	oak_rails.sweep(PackedVector3Array([o + w * .07 + d * going + Vector3.UP * (RAIL + RISE * 2), o + w * .07 + d * length + Vector3.UP * (RAIL + RISE * risers)]), .045, .038)

## Four fan treads form each curved stair turn.
func landing(corner: Vector3, along: Vector3, across: Vector3, level: float) -> void:
	# Four fan-shaped treads replace four adjoining straight risers.
	# The neighbouring straight runs shorten accordingly. Each storey still rises through 29 intervals of 155 mm.
	var a := WIDTH + SETBACK + g_south
	var b := DEPTH + SETBACK + 2 * (g_west if along.x > 0 else g_side)
	var rx := a - WIDTH + .05
	var rz := b - DEPTH + .05
	var start := level - RISE * (2 if along.x > 0 else 1)
	var from_angle := -PI if along.x > 0 else -PI / 2
	var to_angle := -PI / 2 if along.x > 0 else -PI
	var corner_angle := -PI + atan(b * rx / (a * rz))
	for step in 4:
		var lo := lerpf(from_angle, to_angle, float(step) / 4)
		var hi := lerpf(from_angle, to_angle, float(step + 1) / 4)
		var outline: Array[Vector3] = []
		for angle in [lo, hi]:
			var direction := Vector2(rx * cos(angle), rz * sin(angle))
			var reach := minf(a / maxf(.00001, -direction.x), b / maxf(.00001, -direction.y))
			var inner := corner + along * (a + direction.x) + across * (b + direction.y)
			var outer := corner + along * (a + direction.x * reach) + across * (b + direction.y * reach)
			if outline.is_empty():
				outline.append(inner)
				outline.append(outer)
				if corner_angle > minf(lo, hi) and corner_angle < maxf(lo, hi):
					outline.append(corner)
			else:
				outline.append(outer)
				outline.append(inner)
		for i in range(1, 4):
			var angle := lerpf(hi, lo, float(i) / 4)
			outline.append(corner + along * (a + rx * cos(angle)) + across * (b + rz * sin(angle)))
		var plan := PackedVector2Array()
		var area := 0.0
		for point in outline:
			plan.append(Vector2(point.x, point.z))
		for i in plan.size():
			area += plan[i].cross(plan[(i + 1) % plan.size()])
		var triangles := Geometry2D.triangulate_polygon(plan)
		var top := corner.y + start + step * RISE
		st.set_color(STONE)
		st.set_normal(Vector3.UP)
		for i in range(0, triangles.size(), 3):
			var triangle := [triangles[i], triangles[i + 1], triangles[i + 2]]
			if (plan[triangle[1]] - plan[triangle[0]]).cross(plan[triangle[2]] - plan[triangle[0]]) < 0:
				triangle.reverse()
			for index in triangle:
				st.add_vertex(Vector3(plan[index].x, top, plan[index].y))
		for i in plan.size():
			var p := Vector3(plan[i].x, top - .20, plan[i].y)
			var q := Vector3(plan[(i + 1) % plan.size()].x, top - .20, plan[(i + 1) % plan.size()].y)
			if area > 0:
				quad(q, p, p + Vector3.UP * .20, q + Vector3.UP * .20, WHITE)
			else:
				quad(p, q, q + Vector3.UP * .20, p + Vector3.UP * .20, WHITE)
		var inner: Vector3 = outline[0] + Vector3.UP * (start + step * RISE + .004)
		var outer: Vector3 = outline[1] + Vector3.UP * (start + step * RISE + .004)
		var radial := (outer - inner).normalized()
		bar(inner + radial * .08, outer - radial * .08, .05, .006, STRIP)
	var rail := PackedVector3Array()
	var stringer := PackedVector3Array()
	for i in 17:
		var t := float(i) / 16
		var angle := lerpf(from_angle, to_angle, t)
		var point := corner + along * (a + rx * cos(angle)) + across * (b + rz * sin(angle))
		var hand_height := start + 4 * RISE * t + RAIL
		rail.append(point + Vector3.UP * hand_height)
		stringer.append(point + Vector3.UP * (start + 3 * RISE * t - .11))
		if i % 2 == 0:
			var foot_level := start + RISE * mini(3, floori(t * 4))
			var foot := point + Vector3.UP * foot_level
			var tangent := along * (-rx * sin(angle)) + across * (rz * cos(angle))
			if i % 4 == 0:
				ironwork.panel(foot, tangent, hand_height - foot_level - .025, Marble.scroll_panel_mesh())
			else:
				ironwork.box(foot + Vector3.UP * (hand_height - foot_level - .025) / 2, Vector3(.014, hand_height - foot_level - .025, .014))
	oak_rails.sweep(rail, .060, .048)
	var finish := Marble.Batch.new()
	finish.sweep(stringer, .055, .20)
	finish.into(room, room.trim_paint(), "LionStairCurvedWinderStringer")


## The west run, the south-west landing, the south run and the south-east landing of one storey.
func lower_runs(base: float) -> void:
	var first := RISE * RISERS[0]
	var second := RISE * (RISERS[0] + RISERS[1])
	run(Vector3(x0, base, west_edge), Vector3.BACK, Vector3.RIGHT, WIDTH, RISERS[0] - 2, g_west)
	landing(Vector3(x0, base, zs), Vector3.RIGHT, Vector3.FORWARD, first)
	run(Vector3(x0 + WIDTH + SETBACK + g_south, base + first + RISE, zs), Vector3.RIGHT, Vector3.FORWARD, DEPTH, RISERS[1] - 2, g_south)
	landing(Vector3(x1, base, zs), Vector3.LEFT, Vector3.FORWARD, second)

## The east run, from the south-east landing north to the next floor.
func east_run(base: float) -> void:
	run(Vector3(x1, base + RISE * (RISERS[0] + RISERS[1] + 2), zs - DEPTH - SETBACK - 2 * g_side), Vector3.FORWARD, Vector3.LEFT, WIDTH, RISERS[2] - 2, g_side)

## 6387 36.5s, 6344 3.0s: large pale and grey-beige slabs, two to a square, set on the diagonal.
func lay_floor(b: Array, paint: Material) -> void:
	# build_rooms() has laid the draft timber floor over the whole room, the well included.
	for child in room.get_children():
		if child is MeshInstance3D and child.material_override is ShaderMaterial and child.mesh != null:
			var reach: AABB = child.mesh.get_aabb()
			if reach.end.y < .02 and reach.position.x >= b[0] - .01 and reach.end.x <= b[1] + .01 and reach.position.z >= b[2] - .01 and reach.end.z <= b[3] + .01:
				child.free()
	var bounds := PackedVector2Array([Vector2(b[0], b[2]), Vector2(b[1], b[2]), Vector2(b[1], edge), Vector2(b[0], edge)])
	if west_edge > edge + .001:
		bounds = PackedVector2Array([Vector2(b[0], b[2]), Vector2(b[1], b[2]), Vector2(b[1], edge), Vector2(x0 + WIDTH, edge), Vector2(x0 + WIDTH, west_edge), Vector2(b[0], west_edge)])
	var turn := Transform2D(PI / 4, Vector2((b[0] + b[1]) / 2, (b[2] + edge) / 2))
	begin()
	st.set_normal(Vector3.UP)
	for i in range(-5, 5):
		for j in range(-5, 5):
			for k in 2:
				var flat: bool = (i + j) % 2 == 0
				var at := Vector2(i, j) + (Vector2(0, k * .5) if flat else Vector2(k * .5, 0))
				var size := Vector2(1, .5) if flat else Vector2(.5, 1)
				var slab := PackedVector2Array([turn * at, turn * (at + Vector2(size.x, 0)), turn * (at + size), turn * (at + Vector2(0, size.y))])
				var shade: float = fposmod((i * 7 + j * 3 + k * 5) * .37, 1.0) * .04
				var tone: Color = (Color("ded8cb") if (i + j + k) % 2 == 0 else Color("c9c1b1")).darkened(shade)
				for piece in Geometry2D.intersect_polygons(slab, bounds):
					var corners: PackedInt32Array = Geometry2D.triangulate_polygon(piece)
					for n in range(0, corners.size(), 3):
						var tri := [piece[corners[n]], piece[corners[n + 1]], piece[corners[n + 2]]]
						if (tri[1] - tri[0]).cross(tri[2] - tri[0]) < 0:
							tri.reverse()
						st.set_color(tone)
						for q in tri:
							st.add_vertex(Vector3(q.x, .003, q.y))
	commit(paint).set_meta("landing_floor", "stone slabs")

## 6387 5.5s, 13.5s, 42.5s: grey on the west and east walls of the landing, white on the lion wall
## and in the stairwell.
func paint_walls() -> void:
	var white: StandardMaterial3D = room.trim_paint().duplicate()
	white.cull_mode = BaseMaterial3D.CULL_BACK
	for wall in room.casings:
		var tag: String = wall.get_meta("room_wall", "")
		if not tag.begins_with(LABEL + ":"):
			continue
		var side := tag.get_slice(":", 1)
		if side in ["north", "south"]:
			wall.get_child(1).material_override = white
		# No baseboard hangs in the well.
		var reach: Vector3 = wall.get_child(0).shape.size
		var south_end: float = wall.position.z + reach.z / 2
		var finish_edge := west_edge if side == "west" else edge
		if south_end <= finish_edge + .01:
			continue
		for old in wall.get_children().slice(2):
			if not old is MeshInstance3D:
				continue
			if old.get_meta("trim", "") == "baseboard":
				old.free()
		if side == "south":
			continue
		var start: float = wall.position.z - reach.z / 2
		var inward := 1.0 if side == "west" else -1.0
		if finish_edge > start + .01:
			var trim: MeshInstance3D = room.moulding(finish_edge - start, .20, "baseboard", false)
			trim.position = Vector3(wall.position.x + inward * .065, .10, (start + finish_edge) / 2)
			trim.rotation.y = inward * PI / 2
			trim.reparent(wall)
		# The stairwell's part of this wall is white from the landing edge south.
		begin()
		var x: float = wall.position.x + inward * .064
		if side == "west":
			quad(Vector3(x, 0, zs), Vector3(x, 0, finish_edge), Vector3(x, 4.1, finish_edge), Vector3(x, 4.1, zs), Color.WHITE)
		else:
			quad(Vector3(x, 0, finish_edge), Vector3(x, 0, zs), Vector3(x, 4.1, zs), Vector3(x, 4.1, finish_edge), Color.WHITE)
		var over := commit(white)
		over.reparent(wall)


## Six raised panels on the three existing pairs of fire leaves. Their poses/heads
## are inherited; casing/reveal geometry is supplied by #273.
func landing_leaves() -> void:
	var positions := [Vector3(11.0, 1.35, 30.915), Vector3(11.0, 1.35, 32.615), Vector3(11.0, 1.35, 27.65), Vector3(12.7, 1.35, 27.65), Vector3(16.6, 1.35, 29.5), Vector3(16.6, 1.35, 31.5)]
	for body in room.casings:
		if not positions.any(func(point): return Vector2(body.global_position.x, body.global_position.z).distance_to(Vector2(point.x, point.z)) < .02):
			continue
		var visual: MeshInstance3D = body.get_child(1)
		visual.material_override = room.trim_paint()
		var has_closer := false
		var has_hinges := false
		for old in body.get_children().slice(2):
			if not old is MeshInstance3D or not old.material_override is StandardMaterial3D:
				continue
			var paint: StandardMaterial3D = old.material_override
			if paint.albedo_color.r > .65:
				old.free()
			else:
				has_closer = has_closer or old.position.y > 1.0
				has_hinges = has_hinges or absf(old.position.x) > .40
		var scale_y: float = body.get_child(0).shape.size.y / 2.70
		var borders := Marble.Batch.new()
		var panels := Marble.Batch.new()
		var hardware := Marble.Batch.new()
		for side in [-1, 1]:
			for column in [-1, 1]:
				for row in [[-.93, .55], [-.12, .82], [.87, .67]]:
					var x: float = column * .205
					var y: float = row[0] * scale_y
					var h: float = row[1] * scale_y
					panels.box(Vector3(x, y, side * .036), Vector3(.31, h, .008))
					for hand in [-1, 1]:
						borders.box(Vector3(x + hand * .157, y, side * .046), Vector3(.018, h + .025, .014))
						borders.box(Vector3(x, y + hand * h / 2, side * .046), Vector3(.33, .018, .014))
			if not has_closer:
				hardware.box(Vector3(-.15, 1.16 * scale_y, side * .075), Vector3(.20, .075, .050))
				hardware.bar(Vector3(-.15, 1.21 * scale_y, side * .08), Vector3(.20, 1.24 * scale_y, side * .11), .018)
		if not has_hinges:
			for y in [-1.17, -.03, 1.15]:
				hardware.box(Vector3(-.46, y * scale_y, 0), Vector3(.060, .10, .09))
		borders.into(body, room.trim_paint(), "WhiteFireLeafPanelBorders", true)
		panels.into(body, room.look(Color("e5e3dd")), "FireLeafSixPanels", true)
		if hardware.used:
			hardware.into(body, room.look(Color("292b2c")), "FireLeafCloserAndHinges", true)


func finish_iron(parent: Node3D) -> void:
	var iron: StandardMaterial3D = room.look(IRON)
	iron.metallic = .55
	iron.roughness = .38
	iron.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	ironwork.into(parent, iron, "LionStairScrollIronwork")
	var wood: StandardMaterial3D = room.look(WOOD)
	wood.roughness = .30
	wood.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	oak_rails.into(parent, wood, "LionStairOakHandrail")


func landing_guard(base: float, xa: float, xb: float) -> void:
	var z := edge - .05
	var count := roundi((xb - xa - .44) / .175)
	for i in count + 1:
		var foot := Vector3(lerpf(xa + .22, xb - .22, float(i) / count), base, z)
		if i % 2 == 0:
			ironwork.panel(foot, Vector3.RIGHT, .87, Marble.scroll_panel_mesh())
		else:
			ironwork.box(foot + Vector3.UP * .435, Vector3(.014, .87, .014))
	var join := west_edge if is_zero_approx(base) else edge
	var path := PackedVector3Array([Vector3(xa, base + RAIL + RISE, join)])
	var links := maxi(1, floori((join - edge + .27) / .175))
	for i in links:
		var t := (float(i) + .5) / links
		var foot := Vector3(xa, base, lerpf(join, edge - .27, t))
		var height := lerpf(RAIL + RISE, .90, t) - .025
		if i % 2 == 0:
			ironwork.panel(foot, Vector3.BACK, height, Marble.scroll_panel_mesh())
		else:
			ironwork.box(foot + Vector3.UP * height / 2, Vector3(.014, height, .014))
	for hand in [-1, 1]:
		var centre := Vector2(xa + .22 if hand == -1 else xb - .22, edge - .27)
		for i in 13:
			var angle := PI - i * PI / 24 if hand == -1 else PI / 2 - i * PI / 24
			var point := centre + Vector2.from_angle(angle) * .22
			path.append(Vector3(point.x, base + .90, point.y))
			if i % 4 == 0:
				ironwork.panel(Vector3(point.x, base, point.y), Vector3(-sin(angle), 0, cos(angle)), .87, Marble.scroll_panel_mesh())
		if hand == -1:
			path.append(Vector3(xb - .22, base + .90, z))
	path.append(Vector3(xb, base + RAIL, edge))
	oak_rails.sweep(path, .060, .048)


## IMG_6387 10.5 / 42 s. Physical panels, surround and fittings; no invented lettering.
func lion_wall_details() -> void:
	var wall: Node3D = room.wall_body(LABEL, "north", Vector3(14.6, 1.7, z0))
	var face: Node3D = wall.get_child(1)
	for old in face.get_children():
		if old is MeshInstance3D and old.mesh != null and old.global_position.distance_to(Vector3(14.6, 3.32, 28.19)) < .04:
			old.free()
			continue
		if old is MeshInstance3D and absf(old.global_position.z - 28.295) < .002:
			var at: Vector3 = old.global_position
			if absf(at.x - 14.6) < .002 and absf(absf(at.y - 1.7005) - .5605) < .002 or absf(absf(at.x - 14.6) - 1.183) < .002 and absf(at.y - 1.7005) < .002:
				old.free()
	var white: Material = room.trim_paint()
	var surround := Marble.Batch.new()
	for hand in [-1, 1]:
		surround.box(Vector3(14.6, 1.7005 + hand * .5605, 28.298), Vector3(2.50, .14, .014))
		surround.box(Vector3(14.6 + hand * 1.183, 1.7005, 28.298), Vector3(.14, 1.26, .014))
	surround.into(face, white, "LionFlushWhiteSurround")
	var label: MeshInstance3D = room.solid(Vector3(13.05, 1.65, 28.19), Vector3(.35, .65, .008), room.look(Color("b8b8b2")))
	label.set_meta("artwork_label_proxy", true)
	label.reparent(face)
	var vent := Marble.Batch.new()
	vent.box(Vector3(13.85, 3.10, 28.182), Vector3(.90, .22, .018))
	for i in 10:
		vent.box(Vector3(13.85, 3.00 + i * .022, 28.199), Vector3(.87, .008, .018))
	vent.into(face, room.look(Color("73766f")), "LionLouvredVent")
	var label_card: MeshInstance3D = room.solid(Vector3(15.82, .96, 28.185), Vector3(.12, .075, .006), white)
	label_card.set_meta("artwork_label_proxy", true)
	label_card.reparent(face)
	# Source fire devices at the sculpture door; tiny hardware, rather than wall slabs.
	var east: Node3D = room.wall_body(LABEL, "east", Vector3(x1, 1.5, 31.94))
	var pull: MeshInstance3D = room.solid(Vector3(x1 - .07, 1.15, 31.86), Vector3(.035, .125, .085), room.look(Color("a9342c")))
	pull.reparent(east)
	var strobe: MeshInstance3D = room.solid(Vector3(x1 - .074, 2.10, 31.86), Vector3(.03, .14, .09), white)
	strobe.reparent(east)
	# Directory/level carrier beside the medieval doorway. Lettering is not invented.
	var west: Node3D = room.wall_body(LABEL, "west", Vector3(x0, 1.8, 33.04))
	var directory: MeshInstance3D = room.solid(Vector3(x0 + .011, 1.70, 33.04), Vector3(.007, .39, .28), white)
	directory.set_meta("artwork_label_proxy", true)
	directory.reparent(west)
	var access := Marble.Batch.new()
	access.box(Vector3(x1 - .067, 1.26, 32.02), Vector3(.008, .28, .22))
	access.into(east, room.look(Color("c5c7c3")), "LandingAccessPanel")
