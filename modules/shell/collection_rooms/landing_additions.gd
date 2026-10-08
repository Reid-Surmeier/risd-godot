## Lion stair landing (#238): the open-well stair, its well, the stone floor, the ceiling and the
## wall colours. Sizes are estimates from IMG_6344 3.0s and IMG_6387 28.5s scaled to this room's
## plan; nothing here is surveyed. docs/evidence/museum-238/stairwell/NOTES.md has the frames.
extends RefCounted

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
const WHITE := Color("eeece6")
const CREAM := Color("e6dfcf")
const IRON := Color("2a2b2d")
const WOOD := Color("4a3626")
const STRIP := Color("3b3d40")
const DARK := Color("3a3835")

var room: Node3D
var st: SurfaceTool
var x0: float
var x1: float
var z0: float
var zs: float
var edge: float # the landing's south edge: first riser up, top riser of the flight from below
var g_side: float
var g_south: float

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
	g_side = (zs - DEPTH - SETBACK - edge) / (RISERS[0] - 1)
	g_south = (x1 - x0 - 2 * (WIDTH + SETBACK)) / (RISERS[1] - 1)
	var storey: float = RISE * (RISERS[0] + RISERS[1] + RISERS[2])
	var paint := StandardMaterial3D.new()
	paint.vertex_color_use_as_albedo = true
	paint.vertex_color_is_srgb = true
	paint.roughness = .95
	paint.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	lay_floor(b, paint)
	paint_walls()
	# Always drawn: the flight up as far as its second quarter landing, the whole flight down,
	# the landing balustrade and the lining of the well below the floor.
	begin()
	lower_runs(0.0)
	lower_runs(-storey)
	east_run(-storey)
	var rail_y := 0.90
	var south := edge - .05
	for i in int((x1 - x0 - 2 * WIDTH) / .13) + 1:
		var x: float = x0 + WIDTH + i * .13
		bar(Vector3(x, 0, south), Vector3(x, rail_y - .02, south), .018, .018, IRON)
	bar(Vector3(x0 + WIDTH - .05, rail_y, south), Vector3(x1 - WIDTH + .05, rail_y, south), .06, .05, WOOD)
	bar(Vector3(x0 + WIDTH - .05, rail_y, south), Vector3(x0 + WIDTH - .05, RAIL + RISE, edge), .06, .05, WOOD)
	bar(Vector3(x1 - WIDTH + .05, rail_y, south), Vector3(x1 - WIDTH + .05, RAIL, edge), .06, .05, WOOD)
	# The well below: the three outer walls, a closed wall under the landing edge (the floor
	# below was not surveyed) and a dark floor one storey down.
	var low := -storey - WAIST
	quad(Vector3(x0, low, zs), Vector3(x0, low, edge), Vector3(x0, 0, edge), Vector3(x0, 0, zs), CREAM)
	quad(Vector3(x1, low, zs), Vector3(x0, low, zs), Vector3(x0, 0, zs), Vector3(x1, 0, zs), CREAM)
	quad(Vector3(x1, low, edge), Vector3(x1, low, zs), Vector3(x1, 0, zs), Vector3(x1, 0, edge), CREAM)
	quad(Vector3(x0, low, edge), Vector3(x1, low, edge), Vector3(x1, 0, edge), Vector3(x0, 0, edge), WHITE)
	quad(Vector3(x0, -storey, zs), Vector3(x1, -storey, zs), Vector3(x1, -storey, edge), Vector3(x0, -storey, edge), DARK)
	var stair := commit(paint)
	stair.set_meta("landing_stair", {"rise_m": RISE, "risers": RISERS, "going_m": [g_side, g_south, g_side], "width_m": WIDTH, "storey_m": storey, "metric_accepted": false})
	# Hidden with the ceilings when the camera is above them: the run that arrives at the floor
	# above, that floor's edge, the upper walls of the stairwell and its laylight.
	begin()
	east_run(0.0)
	box(Vector3(x0, 3.80, edge - .30), Vector3(x1, storey, edge), WHITE)
	var upper := storey + .90
	bar(Vector3(x0 + .05, upper, south), Vector3(x1 - WIDTH + .05, upper, south), .06, .05, WOOD)
	bar(Vector3(x1 - WIDTH + .05, upper, south), Vector3(x1 - WIDTH + .05, storey + RAIL, edge), .06, .05, WOOD)
	for i in int((x1 - WIDTH - x0) / .13):
		var x: float = x0 + .12 + i * .13
		bar(Vector3(x, storey, south), Vector3(x, upper - .02, south), .018, .018, IRON)
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
	var ceiling: MeshInstance3D = room.solid(Vector3((x0 + x1) / 2, 4.12, (z0 + edge) / 2), Vector3(x1 - x0, .04, edge - z0), room.look(Color("ebe9e3"), "res://modules/shell/collection_rooms/presentation/neutral-plaster.png"))
	ceiling.set_meta("opaque_ceiling", LABEL)
	room.ceiling_details.append(ceiling)
	# Nobody walks onto the stair or into the well: one guard across the landing edge.
	var guard: Node3D = room.solid(Vector3((x0 + x1) / 2, .52, edge + .045), Vector3(x1 - x0, 1.04, .09), room.look(IRON), true)
	guard.get_child(1).mesh = ArrayMesh.new()
	guard.set_meta("landing_guard", true)
	room.inventory["lion_landing"].merge({"stair": "one open-well stair, three runs and two quarter landings per storey", "risers_per_storey": RISERS, "ceiling": true, "laylight": true, "stair_metric_accepted": false}, true)

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
			bar(foot, foot + Vector3.UP * (RAIL + RISE * k - .02), .018, .018, IRON)
	# The soffit runs with the pitch, under every tread; a short face closes it at the landing above.
	var low := o + Vector3.UP * -WAIST
	var high := o + d * length + Vector3.UP * (RISE * (risers - 1) - WAIST)
	quad(low, low + w * width, high + w * width, high, CREAM)
	quad(high + w * width, high, high + Vector3.UP * (RISE + .01), high + w * width + Vector3.UP * (RISE + .01), CREAM)
	var face := w * (width + .004)
	quad(low + face, low + face + Vector3.UP * .17, high + face + Vector3.UP * .17, high + face, WHITE)
	var hand := w * (width - .05)
	bar(o + hand + Vector3.UP * (RAIL + RISE), o + hand + d * length + Vector3.UP * (RAIL + RISE * risers), .06, .05, WOOD)
	# The second handrail, on the wall.
	bar(o + w * .07 + d * going + Vector3.UP * (RAIL + RISE * 2), o + w * .07 + d * length + Vector3.UP * (RAIL + RISE * risers), .045, .045, WOOD)

## A quarter landing in a corner of the stairwell: an L, because the risers stand back from the well.
func landing(corner: Vector3, along: Vector3, across: Vector3, level: float) -> void:
	var up := Vector3.UP * level
	block(corner + up - Vector3.UP * .20, corner + along * (WIDTH + SETBACK) + across * DEPTH + up, STONE, CREAM)
	block(corner + across * DEPTH + up - Vector3.UP * .20, corner + along * WIDTH + across * (DEPTH + SETBACK) + up, STONE, CREAM)

## The west run, the south-west landing, the south run and the south-east landing of one storey.
func lower_runs(base: float) -> void:
	var first := RISE * RISERS[0]
	var second := RISE * (RISERS[0] + RISERS[1])
	run(Vector3(x0, base, edge), Vector3.BACK, Vector3.RIGHT, WIDTH, RISERS[0], g_side)
	landing(Vector3(x0, base, zs), Vector3.RIGHT, Vector3.FORWARD, first)
	run(Vector3(x0 + WIDTH + SETBACK, base + first, zs), Vector3.RIGHT, Vector3.FORWARD, DEPTH, RISERS[1], g_south)
	landing(Vector3(x1, base, zs), Vector3.LEFT, Vector3.FORWARD, second)
	# The handrail carries on round both well corners.
	var a := Vector3(x0 + WIDTH - .05, base + first + RAIL, zs - DEPTH - SETBACK)
	var c := Vector3(x0 + WIDTH + SETBACK, base + first + RAIL + RISE, zs - DEPTH + .05)
	bar(a, c, .06, .05, WOOD)
	a = Vector3(x1 - WIDTH - SETBACK, base + second + RAIL, zs - DEPTH + .05)
	c = Vector3(x1 - WIDTH + .05, base + second + RAIL + RISE, zs - DEPTH - SETBACK)
	bar(a, c, .06, .05, WOOD)

## The east run, from the south-east landing north to the next floor.
func east_run(base: float) -> void:
	run(Vector3(x1, base + RISE * (RISERS[0] + RISERS[1]), zs - DEPTH - SETBACK), Vector3.FORWARD, Vector3.LEFT, WIDTH, RISERS[2], g_side)

## 6387 36.5s, 6344 3.0s: large pale and grey-beige slabs, two to a square, set on the diagonal.
func lay_floor(b: Array, paint: Material) -> void:
	# build_rooms() has laid the draft timber floor over the whole room, the well included.
	for child in room.get_children():
		if child is MeshInstance3D and child.material_override is ShaderMaterial and child.mesh != null:
			var reach: AABB = child.mesh.get_aabb()
			if reach.end.y < .02 and reach.position.x >= b[0] - .01 and reach.end.x <= b[1] + .01 and reach.position.z >= b[2] - .01 and reach.end.z <= b[3] + .01:
				child.free()
	var bounds := PackedVector2Array([Vector2(b[0], b[2]), Vector2(b[1], b[2]), Vector2(b[1], edge), Vector2(b[0], edge)])
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
				var tone: Color = (Color("d9d5cb") if (i + j + k) % 2 == 0 else Color("bdb7ab")).darkened(shade)
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
	var white: StandardMaterial3D = room.look(Color.WHITE, "res://modules/shell/collection_rooms/presentation/neutral-plaster.png")
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
		if south_end <= edge + .01:
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
		var trim: MeshInstance3D = room.moulding(edge - start, .20, "baseboard", false)
		trim.position = Vector3(wall.position.x + inward * .065, .10, (start + edge) / 2)
		trim.rotation.y = inward * PI / 2
		trim.reparent(wall)
		# The stairwell's part of this wall is white from the landing edge south.
		begin()
		var x: float = wall.position.x + inward * .064
		if side == "west":
			quad(Vector3(x, 0, zs), Vector3(x, 0, edge - .30), Vector3(x, 4.1, edge - .30), Vector3(x, 4.1, zs), Color.WHITE)
		else:
			# Only above the run that climbs this wall; under it the wall stays grey (6387 5.5s).
			var landing_z := zs - DEPTH - SETBACK
			var level: float = RISE * (RISERS[0] + RISERS[1])
			var reach_z: float = landing_z - (4.1 - level - RISE) / RISE * g_side
			quad(Vector3(x, level, landing_z), Vector3(x, level, zs), Vector3(x, 4.1, zs), Vector3(x, 4.1, landing_z), Color.WHITE)
			quad(Vector3(x, level + RISE, landing_z), Vector3(x, 4.1, landing_z), Vector3(x, 4.1, reach_z), Vector3(x, 4.1, reach_z), Color.WHITE)
		var over := commit(white)
		over.reparent(wall)
