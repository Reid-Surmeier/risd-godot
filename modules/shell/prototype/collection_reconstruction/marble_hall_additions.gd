## Marble stair hall (#238): everything inside the room that prepare_remodel.py's row
## "marble stair hall" gives walls to. Sources: IMG_6381 (whole clip), IMG_6380 45.5..82.5s,
## and the RISD catalogue photographs of 83.152 and 2011.60, which were taken in this hall.
## Every metre is a one-camera estimate (docs/evidence/museum-238/marble-hall/NOTES.md).
## The visitor walks this floor only: flights, half-landing and service-stair void are solid.
extends RefCounted

const LABEL := "marble stair hall"
const ASSETS := "res://assets/additions/marble-hall/"
const Painting := preload("res://modules/shell/prototype/gallery_walk4/painting_asset.gd")
const RISER := .145 # 31 risers to an upper floor at 4.495m
const TREAD := .35
const FLIGHT := 1.6 # flight width; the two balustrade lines meet the plain white columns
const STRAIGHT := 13 # steps in the first run, then 6 winders to the half-landing
const SOFFIT := 3.745 # underside of the upper landing: the ceiling of the strip behind the columns
static var _scroll_panel: ArrayMesh

var room
var x0: float
var x1: float
var z0: float
var z1: float
var xf: float # east edge of the upper landing, and the corner of the chimneypiece wall
var xe: float # wall under the half-landing's edge
var zn: float # balustrade line of the first flight
var zs: float # chimneypiece wall line; the upper flight runs behind and above it
var upper: float # upper floor level
var half: float # half-landing level

## Many boxes and prisms in one mesh: one lightmap user instead of hundreds.
class Batch:
	var st := SurfaceTool.new()
	var used := false

	func _init() -> void:
		st.begin(Mesh.PRIMITIVE_TRIANGLES)

	## Primitive meshes have indices; swept faces do not. Keep the batch unindexed so
	## adding a primitive cannot silently hide the hand-built curls, leaves or rail.
	func append(mesh: Mesh, transform: Transform3D) -> void:
		if mesh is ArrayMesh and mesh.surface_get_array_index_len(0) == 0:
			st.append_from(mesh, 0, transform)
			return
		var source := SurfaceTool.new()
		source.create_from(mesh, 0)
		source.deindex()
		st.append_from(source.commit(), 0, transform)

	func box(at: Vector3, size: Vector3, basis := Basis.IDENTITY) -> void:
		var cube := BoxMesh.new()
		cube.size = size
		append(cube, Transform3D(basis, at))
		used = true

	func ball(at: Vector3, radius: float, squash := Vector3.ONE) -> void:
		var sphere := SphereMesh.new()
		sphere.radius = radius
		sphere.height = radius * 2
		sphere.radial_segments = 8
		sphere.rings = 4
		append(sphere, Transform3D(Basis.from_scale(squash), at))
		used = true

	func tube(at: Vector3, radius: float, height: float, basis := Basis.IDENTITY, sides := 10) -> void:
		var cylinder := CylinderMesh.new()
		cylinder.top_radius = radius
		cylinder.bottom_radius = radius
		cylinder.height = height
		cylinder.radial_segments = sides
		cylinder.rings = 1
		append(cylinder, Transform3D(basis, at))
		used = true

	## A bar between two points.
	func bar(a: Vector3, c: Vector3, thick: float, tall := -1.0) -> void:
		var along := c - a
		var up := Vector3.UP if absf(along.normalized().y) < .99 else Vector3.RIGHT
		box((a + c) / 2, Vector3(thick, thick if tall < 0 else tall, along.length()), Basis.looking_at(along.normalized(), up))

	## A continuous elliptical section, including the rounded oak rail and its open volute.
	func sweep(points: PackedVector3Array, wide: float, high: float, sides := 8, reference := Vector3.UP) -> void:
		var rings: Array[PackedVector3Array] = []
		var normals: Array[PackedVector3Array] = []
		var closed := points[0].distance_squared_to(points[-1]) <= .000001
		for i in points.size():
			var previous := wrapi(i - 1, 0, points.size() - 1) if closed else maxi(i - 1, 0)
			var following := wrapi(i + 1, 0, points.size() - 1) if closed else mini(i + 1, points.size() - 1)
			var tangent := (points[following] - points[previous]).normalized()
			var side := tangent.cross(reference).normalized()
			if side.length_squared() < .001:
				side = Vector3.RIGHT
			var up := side.cross(tangent).normalized()
			var ring := PackedVector3Array()
			var normal := PackedVector3Array()
			for j in sides:
				var angle := j * TAU / sides
				ring.append(points[i] + side * cos(angle) * wide / 2 + up * sin(angle) * high / 2)
				normal.append((side * cos(angle) / wide + up * sin(angle) / high).normalized())
			rings.append(ring)
			normals.append(normal)
		for i in points.size() - 1:
			for j in sides:
				var next := (j + 1) % sides
				for pair in [Vector2i(i, j), Vector2i(i + 1, next), Vector2i(i + 1, j), Vector2i(i, j), Vector2i(i, next), Vector2i(i + 1, next)]:
					st.set_normal(normals[pair.x][pair.y])
					st.set_uv(Vector2(pair.x * .1, float(pair.y) / sides))
					st.add_vertex(rings[pair.x][pair.y])
		# Oak and iron are solid sections. Closed hoops already meet their own first ring.
		if not closed:
			for end in [0, points.size() - 1]:
				var normal := (points[1] - points[0]).normalized() * -1 if end == 0 else (points[-1] - points[-2]).normalized()
				st.set_normal(normal)
				for j in range(1, sides - 1):
					for index in ([0, j + 1, j] if end == 0 else [0, j, j + 1]):
						var angle: float = index * TAU / sides
						st.set_uv(Vector2(cos(angle), sin(angle)) * .5 + Vector2.ONE * .5)
						st.add_vertex(rings[end][index])
		used = true


	func panel(at: Vector3, along: Vector3, height: float, mesh: ArrayMesh) -> void:
		var axis := Vector3(along.x, 0, along.z).normalized()
		var basis := Basis(axis, Vector3.UP * height / .87, axis.cross(Vector3.UP))
		append(mesh, Transform3D(basis, at))
		used = true

	## A vertical prism over a plan polygon (x, z), with its top and, if asked, its underside.
	func prism(plan: PackedVector2Array, y0: float, y1: float, under := false) -> void:
		var area := 0.0
		for i in plan.size():
			area += plan[i].cross(plan[(i + 1) % plan.size()])
		var turn := 1.0 if area > 0 else -1.0
		var triangles := Geometry2D.triangulate_polygon(plan)
		for level in ([y1, y0] if under else [y1]):
			st.set_normal(Vector3.UP if level == y1 else Vector3.DOWN)
			for index in triangles:
				st.set_uv(plan[index])
				st.add_vertex(Vector3(plan[index].x, level, plan[index].y))
		for i in plan.size():
			var a := plan[i]
			var c := plan[(i + 1) % plan.size()]
			var out := Vector2((c - a).y, -(c - a).x).normalized() * turn
			st.set_normal(Vector3(out.x, 0, out.y))
			var corners := [Vector3(a.x, y0, a.y), Vector3(c.x, y0, c.y), Vector3(c.x, y1, c.y), Vector3(a.x, y1, a.y)]
			var uvs := [Vector2(0, y0), Vector2(a.distance_to(c), y0), Vector2(a.distance_to(c), y1), Vector2(0, y1)]
			for index in [0, 1, 2, 0, 2, 3]:
				st.set_uv(uvs[index])
				st.add_vertex(corners[index])
		used = true

	## Batches are written in room metres; `local` keeps them in the parent's own frame instead.
	func into(parent: Node, material: Material, name := "", local := false) -> MeshInstance3D:
		var node := MeshInstance3D.new()
		node.mesh = st.commit()
		node.material_override = material
		if name != "":
			node.name = name
		parent.add_child(node)
		if not local and node.is_inside_tree():
			node.global_transform = Transform3D.IDENTITY
		return node


## IMG_6381 5.5 s: a narrow vertical spindle, paired end curls, a short oval and curled leaf tips.
## One template is reused in both stair spaces; ornament never becomes a flat X/decal.
static func scroll_panel_mesh() -> ArrayMesh:
	if _scroll_panel != null:
		return _scroll_panel
	var panel := Batch.new()
	panel.box(Vector3(0, .435, 0), Vector3(.014, .87, .014))
	for level in [.055, .22, .435, .65, .815]:
		panel.tube(Vector3(0, level, 0), .016, .016, Basis.IDENTITY, 8)
	for level in [.10, .77]:
		for hand in [-1.0, 1.0]:
			var points := PackedVector3Array()
			for i in 11:
				var t := float(i) / 10
				var angle := -PI / 2 + t * TAU * 1.12
				var radius := lerpf(.035, .008, t)
				points.append(Vector3(hand * (.021 + cos(angle) * radius), level + sin(angle) * radius, 0))
			panel.sweep(points, .009, .012, 4, Vector3.BACK)
	for hand in [-1.0, 1.0]:
		var points := PackedVector3Array()
		for i in 15:
			var t := float(i) / 14
			points.append(Vector3(hand * (.009 + sin(t * PI) * .037), .355 + t * .17, 0))
		panel.sweep(points, .009, .012, 4, Vector3.BACK)
		for level in [.235, .655]:
			# A folded pointed leaf: front and back facets, not a card facing the camera.
			var leaf := PackedVector3Array([Vector3(.008 * hand, level - .015, 0), Vector3(.030 * hand, level + .020, 0), Vector3(.053 * hand, level + .010, 0), Vector3(.041 * hand, level - .010, .012), Vector3(.025 * hand, level - .019, 0)])
			for side in [-1.0, 1.0]:
				for triangle in [[0, 1, 3], [1, 2, 3], [0, 3, 4]]:
					var a: Vector3 = leaf[triangle[0]] * Vector3(1, 1, side)
					var b: Vector3 = leaf[triangle[1]] * Vector3(1, 1, side)
					var c: Vector3 = leaf[triangle[2]] * Vector3(1, 1, side)
					panel.st.set_normal((c - a).cross(b - a).normalized())
					for vertex in [a, b, c]:
						panel.st.add_vertex(vertex)
	_scroll_panel = panel.st.commit()
	return _scroll_panel


func guard(bars: Batch, rail: Batch, a: Vector3, b: Vector3, height := .92) -> void:
	var along := b - a
	var count := maxi(2, roundi(Vector2(along.x, along.z).length() / .175))
	for i in count + 1:
		var foot := a.lerp(b, float(i) / count)
		if i % 2 == 0:
			bars.panel(foot, along, height - .025, scroll_panel_mesh())
		else:
			bars.box(foot + Vector3.UP * (height - .025) / 2, Vector3(.014, height - .025, .014))
	rail.sweep(PackedVector3Array([a + Vector3.UP * height, b + Vector3.UP * height]), .065, .050)


func ceiling_height() -> float:
	for area in room._plan_rooms:
		if area.label == LABEL:
			return float(area.get("height", 3.5))
	return 3.5


func rect(xa: float, xb: float, za: float, zb: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(xa, za), Vector2(xb, za), Vector2(xb, zb), Vector2(xa, zb)])


func build(scene) -> void:
	room = scene
	var b: Array = room.room_bounds(LABEL)
	x0 = b[0]
	x1 = b[1]
	z0 = b[2]
	z1 = b[3]
	xf = x0 + 2.8
	xe = x1 - FLIGHT
	zn = z0 + FLIGHT
	zs = z1 - FLIGHT
	half = RISER * (STRAIGHT + 7)
	upper = half + RISER * 11
	marble_floor()
	columned_opening()
	inner_walls()
	stair()
	upper_landing()
	rounded_corners()
	shell()
	fireplace()
	chandelier()
	room.inventory["marble_hall"] = {"risers": 31, "upper_floor_m": upper, "accessions": ["83.152", "2011.60"], "metric_accepted": false, "service_stair_built": true, "upper_rooms_built": false}


## A wall or slab the game's camera may cut away: collision box, visible box, room_wall tag.
func wall(tag: String, at: Vector3, size: Vector3, material: Material) -> StaticBody3D:
	var body: StaticBody3D = room.solid(at, size, material, true)
	body.set_meta("room_wall", LABEL + ":" + tag)
	return body


## What the visitor cannot walk into, with nothing to draw.
func block(at: Vector3, size: Vector3) -> void:
	var body: StaticBody3D = room.solid(at, size, room.look(Color.WHITE), true)
	body.get_child(1).mesh = ArrayMesh.new()
	body.set_meta("collision_only", true)


## Deterministic stone, not a photograph. Same finish for tiles, stair and grey base.
static func marble_material(tone: Color, seed := 0.0) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode cull_disabled;
uniform vec4 stone_tone : source_color;
uniform float seed = 0.0;
varying vec3 stone_position;
varying vec3 stone_normal;
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
	vec2 i = floor(p), f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}
float stone_noise(vec2 p) {
	float n = 0.0, weight = 0.5;
	for (int i = 0; i < 4; i++) { n += noise(p) * weight; p = p * 2.07 + vec2(7.1, 2.4); weight *= 0.5; }
	return n;
}
void vertex() { stone_position = VERTEX; stone_normal = NORMAL; }
void fragment() {
	vec3 normal = abs(stone_normal);
	vec2 p = normal.y > 0.6 ? stone_position.xz : (normal.x > normal.z ? stone_position.zy : stone_position.xy);
	p += vec2(seed * 5.4, seed * 8.2);
	float cloud = stone_noise(p * 3.2);
	float field = p.x * 2.1 - p.y * 1.2 + 3.1 * stone_noise(p * 1.6) + 0.55 * stone_noise(p * 5.0);
	float aa = max(fwidth(field), 0.008);
	float vein = 1.0 - smoothstep(0.012, 0.035 + aa, abs(sin(field * 4.0)));
	float feather = 1.0 - smoothstep(0.035, 0.18 + aa, abs(sin(field * 4.0)));
	float mineral = stone_noise(p * vec2(15.0, 24.0));
	ALBEDO = stone_tone.rgb * (0.978 + cloud * 0.035 - vein * 0.060 - feather * 0.025 - mineral * 0.006);
	ROUGHNESS = 0.13 + cloud * 0.040;
	SPECULAR = 0.55;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("stone_tone", tone)
	material.set_shader_parameter("seed", seed)
	return material


func marble_floor() -> void:
	# build_rooms lays oak boards in any room it has no floor for: take this room's away.
	for child in room.get_children():
		if child is MeshInstance3D and child.material_override is ShaderMaterial and child.mesh != null:
			if not str(child.material_override.shader.resource_path).ends_with("floor_oak.gdshader"):
				continue
			var centre: Vector3 = (child.global_transform * child.mesh.get_aabb()).get_center()
			if centre.x > x0 and centre.x < x1 and centre.z > z0 and centre.z < z1:
				child.free()
	# IMG_6381 90.5s, 71.0s; IMG_6380 49.0s: large squares on the diagonal in two pale marbles,
	# a grey band under the columns. The .76m square is read against the fireplace and the columns.
	marble_tiles(room, rect(x0, x1, z0, z1), .004)
	var band := Batch.new()
	band.prism(rect(x0 - .23, x0 + .23, z0, z1), .004, .008)
	band.into(room, marble_material(Color("b6b6b1"), 3.2), "MarbleThresholdBand")
	# Reuse the kit's existing baseboard geometry with this room's marble finish.
	for body in room.casings:
		if not str(body.get_meta("room_wall", "")).begins_with(LABEL + ":"):
			continue
		for trim in body.get_children():
			if trim is MeshInstance3D and trim.get_meta("trim", "") == "baseboard":
				trim.material_override = marble_material(Color("b6b6b1"), 3.2)
	var reflection := ReflectionProbe.new()
	reflection.name = "MarbleHallReflection"
	reflection.position = Vector3((x0 + x1) / 2, ceiling_height() / 2, (z0 + z1) / 2)
	reflection.size = Vector3(x1 - x0, ceiling_height(), z1 - z0)
	reflection.origin_offset = Vector3(0, 2.6 - ceiling_height() / 2, 0)
	reflection.intensity = 2.0
	reflection.box_projection = true
	reflection.interior = true
	reflection.ambient_mode = ReflectionProbe.AMBIENT_DISABLED
	reflection.max_distance = 14.0
	room.add_child(reflection)


func marble_tiles(parent: Node3D, edge: PackedVector2Array, level: float) -> void:
	var size := .76
	var turn := Transform2D(PI / 4, Vector2((x0 + x1) / 2, (z0 + z1) / 2))
	var tones := [Batch.new(), Batch.new()]
	var reach := int(ceil((x1 - x0 + z1 - z0) / size / 1.4)) + 1
	for i in range(-reach, reach + 1):
		for j in range(-reach, reach + 1):
			var tile := PackedVector2Array()
			for corner in [Vector2(i, j), Vector2(i + 1, j), Vector2(i + 1, j + 1), Vector2(i, j + 1)]:
				tile.append(turn * (corner * size))
			for piece in Geometry2D.intersect_polygons(tile, edge):
				var pieces: Array = Geometry2D.clip_polygons(piece, rect(xf + .065, xf + 2.25, (zs + z1) / 2 + .05 - .50, (zs + z1) / 2 + .05 + .50)) if level < .02 else [piece]
				for visible in pieces:
					var batch: Batch = tones[posmod(i + j, 2)]
					batch.st.set_normal(Vector3.UP)
					for index in Geometry2D.triangulate_polygon(visible):
						batch.st.set_uv(visible[index])
						batch.st.add_vertex(Vector3(visible[index].x, level, visible[index].y))
					batch.used = true
	tones[0].into(parent, marble_material(Color("e9e7e1")), "MarbleFloorLight")
	tones[1].into(parent, marble_material(Color("d9d9d4"), 1.7), "MarbleFloorGrey")


## IMG_6380 35.5/44.5 s, IMG_6343 84 s: plain slender shafts, round bases, small
## capitals, a continuous white beam and dentils. Replaces build_grey_gallery's Ionic row.
func columned_opening() -> void:
	var white: Material = room.trim_paint()
	var middle := (z0 + z1) / 2
	for z in [middle - 1.4, middle + 1.4]:
		var body := StaticBody3D.new()
		body.name = "PlainStairHallColumn"
		body.position = Vector3(x0, 1.55, z)
		var shape := CollisionShape3D.new()
		var cylinder := CylinderShape3D.new()
		cylinder.radius = .19
		cylinder.height = 3.10
		shape.shape = cylinder
		body.add_child(shape)
		room.add_child(body)
		room.casings.append(body)
		var column := Batch.new()
		column.tube(Vector3(x0, .08, z), .19, .144, Basis.IDENTITY, 20)
		column.tube(Vector3(x0, .155, z), .155, .05, Basis.IDENTITY, 20)
		column.tube(Vector3(x0, .19, z), .13, .035, Basis.IDENTITY, 20)
		column.tube(Vector3(x0, 1.555, z), .11, 2.71, Basis.IDENTITY, 20)
		column.tube(Vector3(x0, 2.91, z), .12, .035, Basis.IDENTITY, 20)
		column.tube(Vector3(x0, 2.95, z), .15, .05, Basis.IDENTITY, 20)
		column.tube(Vector3(x0, 3.02, z), .17, .09, Basis.IDENTITY, 20)
		column.box(Vector3(x0, 3.075, z), Vector3(.36, .05, .36))
		column.into(body, white, "PlainWhiteShaftBaseAndCapital")
		body.set_meta("stair_hall_column", true)
	var beam := Batch.new()
	beam.box(Vector3(x0, 3.30, middle), Vector3(.34, .40, z1 - z0))
	for y in [3.14, 3.30, 3.43, 3.48]:
		beam.box(Vector3(x0, y, middle), Vector3(.40 if y < 3.40 else .46, .025, z1 - z0))
	for hand in [-1, 1]:
		for i in int((z1 - z0) / .10):
			beam.box(Vector3(x0 + hand * .205, 3.38, z0 + .05 + i * .10), Vector3(.05, .055, .045))
		var z: float = z0 + .10 if hand == -1 else z1 - .10
		beam.box(Vector3(x0, 1.55, z), Vector3(.13, 3.10, .20))
		beam.box(Vector3(x0, .10, z), Vector3(.20, .16, .28))
		beam.box(Vector3(x0, 3.03, z), Vector3(.23, .14, .30))
	beam.into(room, white, "WhiteColumnBeamDentilsAndPilasters").set_meta("column_beam", true)
	room.inventory["stair_hall_columns"] = {"count": 2, "shaft_diameter_m": .22, "round_base_diameter_m": .38, "small_capital_width_m": .36, "dentils": true, "metric_accepted": false}


func inner_walls() -> void:
	var plaster: Material = room.trim_paint()
	var grey: Material = room.look(Color("a9a8a3"), "res://presentation/neutral-plaster.png")
	var skirting: Material = marble_material(Color("b6b6b1"), 3.2)
	# IMG_6380 47.0/65.0s and the 83.152 photographs: the fireplace wall carries the upper flight's string.
	var chimney := wall("south:chimney", Vector3((xf + xe) / 2, SOFFIT / 2, zs), Vector3(xe - xf, SOFFIT, .12), plaster)
	chimney.set_meta("marble_hall_part", "chimneypiece wall")
	var base: MeshInstance3D = room.solid(Vector3((xf + xe) / 2, .09, zs - .07), Vector3(xe - xf, .18, .02), skirting)
	base.reparent(chimney)
	service_niche(plaster)
	# IMG_6381 1.25..3.0s, 71.0s: the wall under the half-landing's edge, exit doorway in its middle.
	var exit := wall("east:landing", Vector3(xe, (half - .25) / 2, (zn + zs) / 2), Vector3(.12, half - .25, zs - zn), plaster)
	var white: Material = room.look(Color("eeeae2"))
	var middle := (zn + zs) / 2
	var door := Batch.new()
	for side in [-1, 1]:
		door.box(Vector3(xe - .075, 1.08, middle + side * .26), Vector3(.03, 2.16, .5))
		door.box(Vector3(xe - .085, 1.14, middle + side * .60), Vector3(.05, 2.28, .14))
	door.box(Vector3(xe - .085, 2.28, middle), Vector3(.05, .14, 1.34))
	door.into(exit, white, "ExitDoorClosed").set_meta("marble_hall_provisional", "closed leaves: the filmed doorway stood open onto a corridor")
	var sign: MeshInstance3D = room.solid(Vector3(xe - .09, 2.55, middle), Vector3(.05, .19, .36), room.look(Color("273a2d")))
	sign.reparent(exit)
	var lettering := Label3D.new()
	lettering.text = "EXIT"
	lettering.font_size = 48
	lettering.pixel_size = .0024
	lettering.modulate = Color("70f89e")
	lettering.position = Vector3(xe - .12, 2.55, middle)
	lettering.rotation.y = -PI / 2
	room.add_child(lettering)
	lettering.reparent(sign)
	var foot: MeshInstance3D = room.solid(Vector3(xe - .07, .09, middle), Vector3(.02, .18, zs - zn), skirting)
	foot.reparent(exit)
	# IMG_6380 49.0/70.0/71.0s: grey wall behind the columns, a cased doorway to a further gallery
	# (leaves folded in its reveal) and a fire alarm pull left of it. Closed leaves here.
	var south: Node3D = room.wall_body(LABEL, "south", Vector3(x0 + 1.4, 1.3, z1))
	var panel: MeshInstance3D = room.solid(Vector3((x0 + xf) / 2, SOFFIT / 2, z1 - .066), Vector3(xf - x0 - .06, SOFFIT, .006), grey)
	panel.reparent(south)
	var passage := Batch.new()
	var centre := x0 + .45 + .93
	for side in [-1, 1]:
		passage.box(Vector3(centre + side * .44, 1.3, z1 - .085), Vector3(.86, 2.6, .03))
		passage.box(Vector3(centre + side * .955, 1.36, z1 - .095), Vector3(.15, 2.72, .05))
	passage.box(Vector3(centre, 2.68, z1 - .095), Vector3(2.06, .15, .05))
	passage.into(south, white, "PassageDoorClosed").set_meta("marble_hall_provisional", "closed leaves: the gallery beyond was only glimpsed")
	var vent: MeshInstance3D = room.solid(Vector3(centre, 3.15, z1 - .075), Vector3(1.3, .24, .02), room.look(Color("5c5b58")))
	vent.reparent(south)
	var pull: MeshInstance3D = room.solid(Vector3(xf - .32, 1.2, z1 - .08), Vector3(.11, .14, .04), room.look(Color("a8322c")))
	pull.reparent(south)
	# The flights and the room behind the exit wall are not floor.
	block(Vector3((xe - STRAIGHT * TREAD - .3 + xe) / 2, 1.0, (z0 + zn) / 2), Vector3(STRAIGHT * TREAD + .3, 2.0, FLIGHT))
	block(Vector3((xe + x1) / 2, 1.0, (z0 + z1) / 2), Vector3(FLIGHT, 2.0, z1 - z0))


## IMG_6343 87 s / IMG_6380 35.5, 70.5 s: an actual hollow arch, olive walls and stairs down.
func service_niche(plaster: Material) -> void:
	var middle := (zs + z1) / 2 + .05
	var radius := .50
	var spring := 2.10
	var crown := spring + radius + .02
	for span in [[zs, middle - radius], [middle + radius, z1]]:
		wall("west:niche", Vector3(xf, SOFFIT / 2, (span[0] + span[1]) / 2), Vector3(.12, SOFFIT, span[1] - span[0]), plaster)
	var header := wall("west:niche:header", Vector3(xf, (crown + SOFFIT) / 2, (zs + z1) / 2), Vector3(.12, SOFFIT - crown, z1 - zs), plaster)
	var profile := PackedVector2Array([Vector2(middle - radius, crown), Vector2(middle + radius, crown)])
	for i in 25:
		var angle := float(i) * PI / 24
		profile.append(Vector2(middle + cos(angle) * radius, spring + sin(angle) * radius))
	# Rotate an extruded profile from the Batch's x/z plane into the return wall's z/y plane.
	var shaped := Batch.new()
	shaped.prism(profile, xf - .06, xf + .06, true)
	var face := Batch.new()
	face.st.append_from(shaped.st.commit(), 0, Transform3D(Basis(Vector3.BACK, Vector3.RIGHT, Vector3.UP), Vector3.ZERO))
	face.used = true
	face.into(header, plaster, "NicheArchSpandrel")
	var olive: Material = room.look(Color("5e6347"))
	var lining := Batch.new()
	var depth := 2.16
	lining.box(Vector3(xf + depth / 2, .35, middle - radius - .03), Vector3(depth, 3.50, .06))
	lining.box(Vector3(xf + depth / 2, .35, middle + radius + .03), Vector3(depth, 3.50, .06))
	lining.box(Vector3(xf + depth, .60, middle), Vector3(.06, 4.10, 1.06))
	for i in 24:
		var a := float(i) * PI / 24
		var b := float(i + 1) * PI / 24
		var corners := [Vector3(xf + .06, spring + sin(a) * radius, middle + cos(a) * radius), Vector3(xf + depth, spring + sin(a) * radius, middle + cos(a) * radius), Vector3(xf + depth, spring + sin(b) * radius, middle + cos(b) * radius), Vector3(xf + .06, spring + sin(b) * radius, middle + cos(b) * radius)]
		lining.st.set_normal(Vector3(0, -sin((a + b) / 2), -cos((a + b) / 2)))
		for index in [0, 2, 1, 0, 3, 2]:
			lining.st.add_vertex(corners[index])
	lining.used = true
	lining.into(header, olive, "ServiceStairOliveVault")
	var steps := Batch.new()
	var edges := Batch.new()
	for i in 8:
		steps.box(Vector3(xf + .12 + (i + .5) * .25, -(i + 1) * RISER - .10, middle), Vector3(.25, .20, .94))
		var nose := xf + .12 + (i + 1) * .25 - .008
		edges.sweep(PackedVector3Array([Vector3(nose, -(i + 1) * RISER, middle - .47), Vector3(nose, -(i + 1) * RISER, middle + .47)]), .015, .010, 6)
	steps.into(header, room.look(Color("505149")), "ServiceStairDescendingTreads")
	edges.into(header, room.look(Color("62645a")), "ServiceStairRoundedNosings")
	var hand := Batch.new()
	hand.sweep(PackedVector3Array([Vector3(xf + .15, .91, middle + .44), Vector3(xf + 2.1, -.20, middle + .44)]), .035, .032)
	for i in 3:
		hand.bar(Vector3(xf + .3 + i * .75, .82 - i * .43, middle + .44), Vector3(xf + .3 + i * .75, .82 - i * .43, middle + .50), .014)
	hand.into(header, room.look(Color("37372e")), "ServiceStairHandrail")
	header.set_meta("service_stair_niche", {"treads": 8, "width_m": 1.0, "descending": true, "walkable": false})


func stair() -> void:
	var marble: Material = marble_material(Color("ddd9d0"), 2.4)
	var strip: Material = room.look(Color("4f4f52"))
	var iron: StandardMaterial3D = room.look(Color("2e2b29"))
	iron.metallic = .55
	iron.roughness = .38
	iron.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	var wood: StandardMaterial3D = room.look(Color("6a4a2e"))
	wood.roughness = .30
	wood.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	var solid := Batch.new()
	var strips := Batch.new()
	var bars := Batch.new()
	var rail := Batch.new()
	var first := xe - STRAIGHT * TREAD
	var rail_start := Vector3(first + .15, RISER + .92, zn - .06)
	var rail_end := Vector3(xe - .25, STRAIGHT * RISER + .92, zn - .06)
	# IMG_6381 3.5/5.5 s: continuous bullnose around the open cage, no separate disc.
	for k in range(1, STRAIGHT + 1):
		var nose := first + (k - 1) * TREAD
		if k == 1:
			var bottom := PackedVector2Array([Vector2(first - .35, z0), Vector2(xe, z0), Vector2(xe, zn - .05), Vector2(first + .45, zn - .05)])
			for i in range(1, 25):
				bottom.append(Vector2(first + .05, zn - .05) + Vector2.from_angle(i * PI / 24) * .40)
			solid.prism(bottom, 0, RISER)
		else:
			solid.prism(rect(nose, xe, z0, zn), (k - 1) * RISER, k * RISER)
		strips.box(Vector3(nose + .07, k * RISER + .003, (z0 + zn) / 2), Vector3(.05, .006, FLIGHT - .3))
		for part in [.25, .75]:
			if k == STRAIGHT and part == .75:
				continue # this station lies past the straight rail, in the curved turn
			var at := Vector3(nose + part * TREAD, k * RISER, zn - .06)
			var rail_y := rail_start.lerp(rail_end, (at.x - rail_start.x) / (rail_end.x - rail_start.x)).y
			var height := rail_y - at.y - .025
			if part == .25:
				bars.panel(at, Vector3.RIGHT, height, scroll_panel_mesh())
			else:
				bars.box(at + Vector3.UP * height / 2, Vector3(.014, height, .014))
	# The oak scroll grows out to the sloping rail. The hole remains visibly open.
	var centre := Vector2(first + .05, zn + .1225)
	block(Vector3(centre.x, 1.0, centre.y), Vector3(.44, 2.0, .44))
	var volute := PackedVector3Array()
	for i in 49:
		var t := float(i) / 48
		var angle := -PI / 2 - TAU * 1.15 * (1 - t)
		var radius := lerpf(.070, .1825, t)
		var point := centre + Vector2.from_angle(angle) * radius
		volute.append(Vector3(point.x, rail_start.y, point.y))
	volute.append(rail_start)
	volute.append(rail_end)
	rail.sweep(volute, .065, .050)
	# Eight open spindles, four ornamented, with thin iron hoops rather than a solid newel.
	for i in 8:
		var angle := i * TAU / 8
		var point := centre + Vector2.from_angle(angle) * .155
		var foot := Vector3(point.x, RISER + .025, point.y)
		if i % 2 == 0:
			bars.panel(foot, Vector3(cos(angle + PI / 2), 0, sin(angle + PI / 2)), .855, scroll_panel_mesh())
		else:
			bars.box(foot + Vector3.UP * .4275, Vector3(.014, .855, .014))
	for level in [RISER + .06, rail_start.y - .05]:
		var hoop := PackedVector3Array()
		for i in 25:
			var point := centre + Vector2.from_angle(i * TAU / 24) * .155
			hoop.append(Vector3(point.x, level, point.y))
		bars.sweep(hoop, .014, .014, 4)
	# Six quarter-turn winders, retaining their count and the half-landing footprint.
	var pivot := Vector2(xe, zn)
	var outer := []
	for i in 7:
		var a := deg_to_rad(i * 15.0)
		outer.append(pivot + Vector2.from_angle(-PI / 2 + a) * FLIGHT)
	for j in range(1, 7):
		solid.prism(PackedVector2Array([pivot, outer[j - 1], outer[j]]), 0, (STRAIGHT + j) * RISER)
		winder_strip(strips, pivot, outer[j - 1], outer[j], (STRAIGHT + j) * RISER)
	solid.prism(rect(xe, x1, zn, zs), half - .25, half, true)
	var turn := PackedVector3Array()
	for i in 13:
		var t := float(i) / 12
		var point := Vector2(xe - .25, zn + .23) + Vector2.from_angle(-PI / 2 + t * PI / 2) * .29
		var level := lerpf(STRAIGHT * RISER, half, t)
		turn.append(Vector3(point.x, level + .92, point.y))
		if i > 0 and i < 12 and i % 3 == 0:
			bars.panel(Vector3(point.x, level, point.y), Vector3(cos(t * PI / 2), 0, sin(t * PI / 2)), .895, scroll_panel_mesh())
	rail.sweep(turn, .065, .050)
	guard(bars, rail, Vector3(xe + .04, half, zn + .23), Vector3(xe + .04, half, zs - .23))
	var treads := solid.into(room, marble, "MarbleStairLower")
	treads.set_meta("marble_hall_part", "first flight, winders and half-landing")
	strips.into(room, strip, "MarbleStairStrips")
	var ironwork := bars.into(room, iron, "MarbleStairBalusters")
	ironwork.set_meta("stair_ironwork", "repeated scroll and leaf mesh, open cage newel")
	rail.into(room, wood, "MarbleStairHandrail")
	var north: Node3D = room.wall_body(LABEL, "north", Vector3((first + xe) / 2, 1.5, z0))
	var hand := Batch.new()
	hand.sweep(PackedVector3Array([Vector3(first + .3, RISER + .9, z0 + .11), Vector3(xe - .25, STRAIGHT * RISER + .9, z0 + .11)]), .050, .042)
	hand.into(north, wood, "MarbleStairWallRail")


## The dark strip along a winder's nosing: the edge from the pivot to `from`, on the tread toward `to`.
func winder_strip(strips: Batch, pivot: Vector2, from: Vector2, to: Vector2, level: float) -> void:
	var along := (from - pivot).normalized()
	var inward := ((to - pivot) - along * (to - pivot).dot(along)).normalized()
	var a := pivot + along * .35 + inward * .08
	var c := pivot + along * ((from - pivot).length() - .15) + inward * .08
	strips.bar(Vector3(a.x, level + .003, a.y), Vector3(c.x, level + .003, c.y), .05, .006)


func upper_landing() -> void:
	var marble: Material = marble_material(Color("ddd9d0"), 2.4)
	var white: Material = room.trim_paint()
	var iron: StandardMaterial3D = room.look(Color("2e2b29"))
	iron.metallic = .55
	iron.roughness = .38
	iron.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	var wood: StandardMaterial3D = room.look(Color("6a4a2e"))
	wood.roughness = .30
	wood.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	var strip: Material = room.look(Color("4f4f52"))
	var top := xe - 4 * TREAD
	# IMG_6381 20.5/31.5s: the upper landing lies over the strip behind the columns, its white fascia
	# across the well; 72.0s and the 83.152 photographs: an arm of it runs east over the fireplace to the
	# head of the upper flight. Both are cut away with their walls, or when they hide the visitor.
	var deck := wall("west:landing", Vector3((x0 + xf) / 2, (SOFFIT + upper) / 2, (z0 + z1) / 2), Vector3(xf - x0, upper - SOFFIT, z1 - z0), white)
	deck.set_meta("marble_hall_part", "upper landing")
	var arm := wall("south:arm", Vector3((xf + top) / 2, (SOFFIT + upper) / 2, (zs + z1) / 2), Vector3(top - xf, upper - SOFFIT, z1 - zs), white)
	arm.set_meta("marble_hall_part", "upper landing arm and upper flight")
	# IMG_6381 68.5/73.0..76.5s: four steps down from the arm, then six winders to the half-landing.
	var flight := Batch.new()
	var strips := Batch.new()
	var bars := Batch.new()
	var rail := Batch.new()
	var pivot := Vector2(xe, zs)
	var outer := []
	for i in 7:
		var a := deg_to_rad(i * 15.0)
		outer.append(pivot + Vector2.from_angle(a) * FLIGHT)
	for j in range(1, 7):
		flight.prism(PackedVector2Array([pivot, outer[j - 1], outer[j]]), half - .25, half + j * RISER, true)
		winder_strip(strips, pivot, outer[j - 1], outer[j], half + j * RISER)
	var upper_rail_start := Vector3(xe - .25, half + 7 * RISER + .92, zs + .06)
	var upper_rail_end := Vector3(top, upper + .95, zs + .06)
	for k in range(1, 5):
		var level := half + (6 + k) * RISER
		flight.prism(rect(xe - k * TREAD, xe - (k - 1) * TREAD, zs, z1), SOFFIT - .15, level, true)
		strips.box(Vector3(xe - (k - 1) * TREAD - .07, level + .003, (zs + z1) / 2), Vector3(.05, .006, FLIGHT - .3))
		for part in [.25, .75]:
			if k == 1:
				continue # the curved turn already carries this first tread
			var at := Vector3(xe - (k - 1 + part) * TREAD, level, zs + .06)
			var rail_y := upper_rail_start.lerp(upper_rail_end, (at.x - upper_rail_start.x) / (upper_rail_end.x - upper_rail_start.x)).y
			var height := rail_y - at.y - .025
			if part == .25:
				bars.panel(at, Vector3.LEFT, height, scroll_panel_mesh())
			else:
				bars.box(at + Vector3.UP * height / 2, Vector3(.014, height, .014))
	var curve := PackedVector3Array()
	for i in 13:
		var t := float(i) / 12
		var point := Vector2(xe - .25, zs - .23) + Vector2.from_angle(t * PI / 2) * .29
		var level := half + t * 7 * RISER
		curve.append(Vector3(point.x, level + .92, point.y))
		if i > 0 and i % 3 == 0:
			bars.panel(Vector3(point.x, level, point.y), Vector3(-sin(t * PI / 2), 0, cos(t * PI / 2)), .895, scroll_panel_mesh())
	rail.sweep(curve, .065, .050)
	rail.sweep(PackedVector3Array([upper_rail_start, upper_rail_end]), .065, .050)
	guard(bars, rail, Vector3(xf, upper, zs + .06), Vector3(top, upper, zs + .06), .95)
	flight.into(arm, marble, "MarbleStairUpper")
	strips.into(arm, strip, "MarbleStairUpperStrips")
	bars.into(arm, iron, "MarbleStairUpperBalusters")
	rail.into(arm, wood, "MarbleStairUpperHandrail")
	var edge_bars := Batch.new()
	var edge_rail := Batch.new()
	guard(edge_bars, edge_rail, Vector3(xf - .06, upper, z0 + .05), Vector3(xf - .06, upper, zs + .06), .95)
	edge_bars.into(deck, iron, "UpperLandingBalusters")
	edge_rail.into(deck, wood, "UpperLandingHandrail")
	marble_tiles(deck, rect(x0 + .12, xf - .12, z0 + .12, z1 - .12), upper + .004)
	marble_tiles(arm, rect(xf, top, zs + .10, z1 - .10), upper + .004)
	var arm_border := Batch.new()
	for span in [rect(xf, top, zs, zs + .10), rect(xf, top, z1 - .10, z1)]:
		arm_border.prism(span, upper, upper + .005)
	arm_border.into(arm, marble_material(Color("b6b6b1"), 3.2), "UpperLandingArmBorder")
	var border := Batch.new()
	for span in [rect(x0, x0 + .12, z0, z1), rect(xf - .12, xf, z0, z1), rect(x0, xf, z0, z0 + .12), rect(x0, xf, z1 - .12, z1)]:
		border.prism(span, upper, upper + .005)
	border.into(deck, marble_material(Color("b6b6b1"), 3.2), "UpperLandingMarbleBorder")
	# Three closed doors of the floor above (IMG_6381 31.5/42.25/61.25s), seen from below across the well.
	var doors := Batch.new()
	for spec in [[Vector3(x0 + .20, upper, (z0 + z1) / 2), false], [Vector3(x0 + 1.5, upper, z0 + .08), true], [Vector3(xf + 1.0, upper, z1 - .08), true]]:
		var at: Vector3 = spec[0]
		var size := Vector3(1.5, 2.5, .05) if spec[1] else Vector3(.05, 2.5, 1.5)
		doors.box(at + Vector3(0, 1.25, 0), size)
		doors.box(at + Vector3(0, 2.58, 0), Vector3(1.8, .16, .08) if spec[1] else Vector3(.08, .16, 1.8))
	doors.into(deck, room.look(Color("f1efe9")), "UpperDoorsClosed").set_meta("marble_hall_provisional", "three closed doors: the rooms behind were only glimpsed")
	var header: Node3D
	for body in room.casings:
		if body.get_meta("room_wall", "") == LABEL + ":west:header":
			header = body
	assert(header != null, "The hall's wall above the columns must exist")
	# Seen from the grey gallery the wall above its beam is plain plaster, not the back of this hall.
	var behind: MeshInstance3D = room.solid(Vector3(x0 - .05, (3.5 + ceiling_height()) / 2, (z0 + z1) / 2), Vector3(.02, ceiling_height() - 3.5, z1 - z0), room.look(Color("b6b4ad"), "res://presentation/neutral-plaster.png"))
	behind.reparent(header)


func shell() -> void:
	var height: float = ceiling_height()
	var white: Material = room.look(Color("ebe9e3"), "res://presentation/neutral-plaster.png")
	# IMG_6381 29.5/58.5s: flat white ceiling with a cornice over the whole well. Hidden from above.
	var ceiling: MeshInstance3D = room.solid(Vector3((x0 + x1) / 2, height + .02, (z0 + z1) / 2), Vector3(x1 - x0, .04, z1 - z0), white)
	ceiling.set_meta("opaque_ceiling", LABEL)
	room.ceiling_details.append(ceiling)
	var cornice := Batch.new()
	for spec in [[Vector3((x0 + x1) / 2, height - .12, z0 + .1), Vector3(x1 - x0, .24, .16)], [Vector3((x0 + x1) / 2, height - .12, z1 - .1), Vector3(x1 - x0, .24, .16)], [Vector3(x1 - .1, height - .12, (z0 + z1) / 2), Vector3(.16, .24, z1 - z0)], [Vector3(x0 + .16, height - .12, (z0 + z1) / 2), Vector3(.16, .24, z1 - z0)]]:
		cornice.box(spec[0], spec[1])
	room.ceiling_details.append(cornice.into(room, room.look(Color("f1efe9")), "MarbleHallCornice"))
	window()


## The filmed stair turns follow quarter-round wall faces within the existing footprint.
func rounded_corners() -> void:
	var white: Material = room.trim_paint()
	for spec in [[Vector2(xe, zn), -PI / 2, Vector2(x1, z0), "north"], [Vector2(xe, zs), 0.0, Vector2(x1, z1), "south"]]:
		var outline := PackedVector2Array()
		for i in 25:
			outline.append(spec[0] + Vector2.from_angle(spec[1] + i * PI / 48) * FLIGHT)
		outline.append(spec[2])
		var curve := Batch.new()
		curve.prism(outline, 0, ceiling_height(), true)
		var owner: Node3D = room.wall_body(LABEL, spec[3], Vector3(xe, 3.5, z0 if spec[3] == "north" else z1))
		curve.into(owner, white, "RoundedStairCorner")
	# White stringers follow the curve of the guard, then meet the straight flights.
	var stringer := Batch.new()
	for lower in [true, false]:
		var path := PackedVector3Array()
		for i in 13:
			var t := float(i) / 12
			var centre := Vector2(xe - .25, zn + .23 if lower else zs - .23)
			var angle := -PI / 2 + t * PI / 2 if lower else t * PI / 2
			var point := centre + Vector2.from_angle(angle) * .29
			var level := lerpf(STRAIGHT * RISER, half, t) if lower else half + t * 7 * RISER
			path.append(Vector3(point.x, level - .11, point.y))
		stringer.sweep(path, .09, .22)
	stringer.into(room, white, "CurvedMarbleStairStringers")


## IMG_6381 28.5 s: tall centre arch, two tall side lights, four engaged columns,
## deep profiled sill, stepped bases/capitals, glazing bars and louvred sill grilles.
func window() -> void:
	var white: Material = room.trim_paint()
	for body in room.casings:
		var tag: String = body.get_meta("room_wall", "")
		if tag in [LABEL + ":north", LABEL + ":east", LABEL + ":south"]:
			body.get_child(1).material_override = white
	var middle := (z0 + z1) / 2
	var sill := half + .95
	var spring := sill + 2.90
	var east: Node3D = room.wall_body(LABEL, "east", Vector3(x1, 4.0, middle))
	var glow: StandardMaterial3D = room.look(Color("eef2f4"), "", true)
	glow.emission_enabled = true
	glow.emission = Color("eef2f4")
	glow.emission_energy_multiplier = 4.0
	var glass := Batch.new()
	glass.box(Vector3(x1 - .071, sill + 1.45, middle), Vector3(.015, 2.90, 1.34))
	glass.tube(Vector3(x1 - .071, spring, middle), .67, .015, Basis(Vector3.BACK, PI / 2), 32)
	for hand in [-1, 1]:
		glass.box(Vector3(x1 - .071, sill + 1.40, middle + hand * 1.13), Vector3(.015, 2.80, .60))
	glass.into(east, glow, "MarbleHallWindowLight").set_meta("marble_hall_window", true)
	var frame := Batch.new()
	for hand in [-1, 1]:
		for column in [.77, 1.52]:
			var z: float = middle + hand * column
			var radius := .095 if column == .77 else .060
			frame.box(Vector3(x1 - .18, sill + .065, z), Vector3(.26, .13, radius * 3))
			for band in [[.14, radius * 1.45, .045], [.19, radius * 1.18, .045], [2.70, radius * 1.16, .05], [2.76, radius * 1.4, .06]]:
				frame.tube(Vector3(x1 - .18, sill + band[0], z), band[1], band[2], Basis.IDENTITY, 16)
			frame.tube(Vector3(x1 - .18, sill + 1.45, z), radius, 2.48, Basis.IDENTITY, 16)
			frame.box(Vector3(x1 - .18, sill + 2.84, z), Vector3(.25, .10, radius * 3))
		frame.box(Vector3(x1 - .16, spring + .03, middle + hand * 1.13), Vector3(.26, .12, .84))
		for row in 5:
			frame.box(Vector3(x1 - .102, sill + .45 + row * .48, middle + hand * 1.13), Vector3(.025, .023, .60))
	for column in [-.225, .225]:
		frame.box(Vector3(x1 - .102, sill + 1.45, middle + column), Vector3(.028, 2.90, .03))
	for row in 6:
		frame.box(Vector3(x1 - .102, sill + .44 + row * .48, middle), Vector3(.028, .025, 1.34))
	# IMG_6381 28.5 s: a small semicircle and three short spokes in the fanlight.
	var fan := PackedVector3Array()
	for i in 17:
		var angle := i * PI / 16
		fan.append(Vector3(x1 - .102, spring + sin(angle) * .25, middle + cos(angle) * .25))
	frame.sweep(fan, .025, .024, 6, Vector3.RIGHT)
	frame.box(Vector3(x1 - .102, spring, middle), Vector3(.028, .028, 1.34))
	for angle in [PI / 4, PI / 2, 3 * PI / 4]:
		frame.bar(Vector3(x1 - .102, spring + sin(angle) * .25, middle + cos(angle) * .25), Vector3(x1 - .102, spring + sin(angle) * .65, middle + cos(angle) * .65), .024)
	for radius in [.705, .755]:
		var arch := PackedVector3Array()
		for i in 33:
			var angle := i * PI / 32
			arch.append(Vector3(x1 - .18, spring + sin(angle) * radius, middle + cos(angle) * radius))
		frame.sweep(arch, .085, .042, 8, Vector3.RIGHT)
	frame.box(Vector3(x1 - .19, sill - .04, middle), Vector3(.36, .08, 3.18))
	frame.box(Vector3(x1 - .12, sill - .13, middle), Vector3(.18, .10, 3.05))
	for hand in [-1, 1]:
		frame.box(Vector3(x1 - .10, sill - .53, middle + hand * 1.09), Vector3(.08, .70, .70))
		frame.box(Vector3(x1 - .14, sill - .53, middle + hand * 1.09), Vector3(.025, .59, .59))
	frame.box(Vector3(x1 - .10, sill - .53, middle), Vector3(.08, .70, 1.25))
	frame.box(Vector3(x1 - .14, sill - .53, middle), Vector3(.025, .59, 1.13))
	frame.into(east, white, "MarbleHallWindowFrame")
	var grille := Batch.new()
	for hand in [-1, 1]:
		grille.box(Vector3(x1 - .22, sill + .004, middle + hand * 1.12), Vector3(.15, .009, .62))
	var slots := Batch.new()
	for hand in [-1, 1]:
		for i in 15:
			slots.box(Vector3(x1 - .22, sill + .010, middle + hand * 1.12 - .28 + i * .04), Vector3(.14, .008, .008))
	grille.into(east, room.look(Color("7f817c")), "WindowSillGrilles")
	slots.into(east, room.look(Color("343936")), "WindowSillGrilleSlots")


func fireplace() -> void:
	# Hugnet Freres, Fireplace Surround, 1900, RISD 83.152: 349.8 x 210.8 x 50.8 cm (catalogue, unframed
	# object size). IMG_6380 47.0..67.0s: on the wall under the upper flight, about a metre from the
	# wall's west corner, its label to its right. The front is the museum's own photograph on the
	# object's outline; the depth is one extrusion, shallower than the catalogue's deepest point.
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ASSETS + "fireplace-83.152.json"))
	var chimney: Node3D
	for body in room.casings:
		if body.get_meta("room_wall", "") == LABEL + ":south:chimney":
			chimney = body
	assert(chimney != null, "The fireplace needs its wall")
	var centre := xf + 1.0 + float(data.size_m[0]) / 2
	var art := Painting.new()
	art.name = "FireplaceSurround83152"
	room.add_child(art)
	art.build_shaped(load(ASSETS + "fireplace-83.152.jpg"), Vector2(data.size_m[0], data.size_m[1]), data.outline, Color("7a4f26"))
	art.scale.z = .40 / .05
	art.position = Vector3(centre, float(data.size_m[1]) / 2, zs - .061)
	art.rotation.y = PI
	art.set_meta("catalogue_accession", "83.152")
	art.set_meta("catalogue_title", "Fireplace Surround")
	art.set_meta("catalogue_maker", "Hugnet Frères (French, active in Paris ca. 1900), designer")
	art.set_meta("catalogue_date", "1900")
	art.set_meta("catalogue_medium", "Walnut, ceramic tiles, and copper")
	art.set_meta("catalogue_dimensions", "349.8 x 210.8 x 50.8 cm")
	art.set_meta("catalogue_image", ASSETS + "fireplace-83.152.jpg")
	art.set_meta("catalogue_identified", true)
	art.set_meta("placement_accepted", false)
	art.reparent(chimney)
	var label: MeshInstance3D = room.solid(Vector3(centre - float(data.size_m[0]) / 2 - .45, 1.45, zs - .064), Vector3(.15, .22, .004), room.look(Color("f3f2ed")))
	label.set_meta("artwork_label_proxy", true)
	label.reparent(chimney)
	block(Vector3(centre, 1.0, zs - .06 - .22), Vector3(float(data.size_m[0]) - .1, 2.0, .44))


func chandelier() -> void:
	# Dale Chihuly, Gilded Frost and Jet Chandelier, 2008, RISD 2011.60: 121.9 x 274.3 x 228.6 cm.
	# IMG_6381 31.5/45.25..47.25/58.75s and the museum's photographs: hung over the east end of the well
	# before the window. Authored tendrils and spheres inside the catalogue's size, not a likeness.
	var height: float = ceiling_height()
	var at := Vector3(xe - .85, height - 1.35, (z0 + z1) / 2)
	var node := Node3D.new()
	node.name = "GildedFrostAndJetChandelier201160"
	node.position = at
	room.add_child(node)
	var frost := Batch.new()
	var jet := Batch.new()
	var reach := Vector3(2.286 / 2, 1.219 / 2, 2.743 / 2)
	for i in 14:
		var around := Vector3(cos(i * 2.4), sin(i * 1.7) * .6, sin(i * 2.4)) * .3
		(jet if i % 3 else frost).ball(around * Vector3(1, .7, 1.2), .15 + .04 * (i % 3))
	for i in 64:
		# Fibonacci directions; each tendril curls as it leaves the core.
		var y := 1.0 - 2.0 * (i + .5) / 64
		var ring := sqrt(1.0 - y * y)
		var out := Vector3(cos(i * 2.39996) * ring, y, sin(i * 2.39996) * ring)
		var side := out.cross(Vector3.UP if absf(out.y) < .9 else Vector3.RIGHT).normalized()
		var batch: Batch = jet if i % 5 == 0 else frost
		var previous := out * .3 * reach
		for step in range(1, 5):
			var along := .3 + step * .175
			var next := (out * along + side * sin(step * 1.3 + i) * .12 + Vector3.UP * sin(step * .9 + i * .7) * .08) * reach
			batch.bar(previous, next, .05 - step * .007)
			previous = next
	frost.into(node, room.look(Color("eceae4")), "ChandelierFrost", true)
	# The app lists a work only if one of its parts carries a picture: the museum's view tints the jet glass.
	jet.into(node, room.look(Color("4a4744"), ASSETS + "chandelier-2011.60.jpg"), "ChandelierJet", true)
	var cables := Batch.new()
	for offset in [Vector3(.15, 0, 0), Vector3(-.1, 0, .12), Vector3(-.1, 0, -.12)]:
		cables.box(offset + Vector3(0, (height - at.y) / 2, 0), Vector3(.01, height - at.y, .01))
	cables.into(node, room.look(Color("8a8986")), "ChandelierCables", true)
	node.set_meta("catalogue_accession", "2011.60")
	node.set_meta("catalogue_title", "Gilded Frost and Jet Chandelier")
	node.set_meta("catalogue_maker", "Dale Chihuly (American, b. 1941)")
	node.set_meta("catalogue_date", "2008")
	node.set_meta("catalogue_medium", "Glass with metal armature")
	node.set_meta("catalogue_dimensions", "121.9 x 274.3 x 228.6 cm")
	node.set_meta("catalogue_image", ASSETS + "chandelier-2011.60.jpg")
	node.set_meta("catalogue_identified", true)
	node.set_meta("placement_accepted", false)
	# IMG_6381 20.5s: a small dark placard on the upper landing's balustrade, opposite the chandelier.
	var deck: Node3D
	for body in room.casings:
		if body.get_meta("room_wall", "") == LABEL + ":west:landing":
			deck = body
	var label: MeshInstance3D = room.solid(Vector3(xf - .1, upper + .7, (z0 + z1) / 2 + .4), Vector3(.012, .2, .16), room.look(Color("1e1e20")))
	label.set_meta("artwork_label_proxy", true)
	label.reparent(deck)
