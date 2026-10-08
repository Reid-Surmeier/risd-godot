## #277: IMG_6343 84–228s. Source measurements and the fixed-door fit are in
## docs/evidence/impressionist-277/NOTES.md; missing works keep their walls bare.
extends RefCounted

const PASSAGE := "Impressionist passage"
const RETURN := "Impressionist passage return"
const A := "Impressionist gallery A"
const B := "Impressionist gallery B"
const YAW := {"north": 0.0, "south": PI, "west": PI / 2, "east": -PI / 2}

var room


func build(target) -> void:
	room = target
	for spec in [[PASSAGE, 3.2, "b4b1a9"], [RETURN, 3.2, "b4b1a9"], [A, 3.69, "a8a9a8"], [B, 3.5, "a8a9a8"]]:
		finish_shell(spec[0], spec[1], Color(spec[2]))
	# 89.5s: grey stone at the stair sill, then straight oak. Floor collision is the plan patch.
	var stone: Material = room.look(Color("bdbcb8"))
	room.solid(Vector3(18.85, .004, -1.96), Vector3(2.0, .008, 1.10), stone)
	build_windows(A, [3.0, 7.60], 3.69)
	build_windows(B, [4.98, 8.44], 3.5)
	high_vents()
	passage_details()
	ceiling_detector()
	modern_exit_plate()
	dancer_case()
	bench()
	hang_existing_works()
	room.inventory["impressionist"] = {
		"rooms": [PASSAGE, RETURN, A, B], "filmed_works": 17, "hung_works": 4,
		"windows": 4, "benches": 1, "empty_dancer_cases": 1,
		"metric_accepted": false, "lighting_complete": false,
		"physical_museum_plan_accepted": false
	}


func finish_shell(label: String, height: float, tone: Color) -> void:
	var paint: StandardMaterial3D = room.look(tone)
	paint.cull_mode = BaseMaterial3D.CULL_BACK
	for wall in room.casings:
		if str(wall.get_meta("room_wall", "")).begins_with(label + ":"):
			wall.get_child(1).material_override = paint
	var b: Array = room.room_bounds(label)
	var ceiling: MeshInstance3D = room.solid(
		Vector3((b[0] + b[1]) / 2, height + .02, (b[2] + b[3]) / 2),
		Vector3(b[1] - b[0], .04, b[3] - b[2]),
		room.look(Color("ebe9e3"))
	)
	ceiling.set_meta("opaque_ceiling", label)
	room.ceiling_details.append(ceiling)
	# Reuse the white kit without changing its profile or the other rooms' trim.
	for spec in [["north", b[1] - b[0]], ["south", b[1] - b[0]], ["west", b[3] - b[2]], ["east", b[3] - b[2]]]:
		var cornice: MeshInstance3D = room.moulding(spec[1], .20, "door-architrave", false)
		cornice.position = room.wall_point(label, spec[0], spec[1] / 2, height - .10, .065)
		cornice.rotation.y = YAW[spec[0]]
		cornice.set_meta("opaque_ceiling", label)
		room.ceiling_details.append(cornice)

func build_windows(label: String, centers: Array, height: float) -> void:
	# 6343 143/149/151 and 216/220/225: two shaded sash windows per room.
	# Replace only the room's inward visual face; keep its closed exterior collision.
	var b: Array = room.room_bounds(label)
	var wall: Node3D = room.wall_body(label, "east", Vector3(b[1], 1.5, (b[2] + b[3]) / 2))
	var visual: MeshInstance3D = wall.get_child(1)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var edges := [0.0, b[3] - b[2]]
	for center in centers:
		edges.append(center - .80)
		edges.append(center + .80)
	edges.sort()
	for j in edges.size() - 1:
		var middle: float = (edges[j] + edges[j + 1]) / 2
		var hole := false
		for center in centers:
			hole = hole or absf(middle - center) < .80
		for span in ([[0.0, .55], [3.10, height]] if hole else [[0.0, height]]):
			var piece := QuadMesh.new()
			piece.size = Vector2(edges[j + 1] - edges[j], span[1] - span[0])
			# QuadMesh supplies Godot's clockwise front and its inward +Z normal.
			st.append_from(piece, 0, Transform3D(Basis.IDENTITY, Vector3(
				middle - (b[3] - b[2]) / 2, (span[0] + span[1]) / 2 - height / 2, 0)))
	visual.mesh = st.commit()
	for center in centers:
		window(label, center, wall)


func window(label: String, along: float, wall: Node3D) -> void:
	var white: Material = room.trim_paint()
	var lining: Material = room.look(Color("e1dfd8"))
	var glass: Material = room.look(Color("b3c5c7"))
	var shade: Material = room.look(Color("d1cbbde6"))
	var node := Node3D.new()
	node.set_meta("impressionist_window", label)
	room.add_child(node)
	node.position = room.wall_point(label, "east", along, 0, .061)
	node.rotation.y = -PI / 2
	# The back plane is recessed .18m; no photographic view of outdoors is invented.
	local_box(node, Vector3(0, 1.825, -.185), Vector3(1.60, 2.55, .012), glass)
	for side in [-1, 1]:
		local_box(node, Vector3(side * .765, 1.825, -.095), Vector3(.07, 2.55, .19), lining)
	local_box(node, Vector3(0, 3.065, -.095), Vector3(1.60, .07, .19), lining)
	local_box(node, Vector3(0, .555, .025), Vector3(1.80, .07, .29), white)
	# 149/151/218: the solar shade's hem is at the sill. The broad lower field
	# is daylight through the fabric, not four exposed, divided glass panes.
	for x in [-.71, .71]:
		local_box(node, Vector3(x, 1.28, -.125), Vector3(.04, 1.36, .05), white)
	for y in [.61, 1.95]:
		local_box(node, Vector3(0, y, -.125), Vector3(1.46, .055, .05), white)
	var fabric := MeshInstance3D.new()
	var sheet := QuadMesh.new()
	sheet.size = Vector2(1.46, 2.43)
	fabric.mesh = sheet
	fabric.material_override = shade
	fabric.position = Vector3(0, 1.825, -.075)
	node.add_child(fabric)
	local_box(node, Vector3(0, .61, -.065), Vector3(1.49, .025, .024), lining)
	var roller := MeshInstance3D.new()
	var tube := CylinderMesh.new()
	tube.top_radius = .026
	tube.bottom_radius = .026
	tube.height = 1.48
	tube.radial_segments = 12
	roller.mesh = tube
	roller.material_override = white
	roller.position = Vector3(0, 3.045, -.05)
	roller.rotation.z = PI / 2
	node.add_child(roller)
	# Apron: a sunken painted panel, with the kit profile around it and a low louvred grille.
	local_box(node, Vector3(0, .355, .009), Vector3(1.58, .30, .020), white)
	for spec in [[Vector3(0, .50, .026), 1.64, .045, false], [Vector3(0, .205, .026), 1.64, .045, false], [Vector3(-.79, .353, .026), .04, .295, true], [Vector3(.79, .353, .026), .04, .295, true]]:
		var trim: MeshInstance3D = room.moulding(spec[1], spec[2], "window-apron", spec[3])
		trim.reparent(node, false)
		trim.position = spec[0]
	for spec in [[Vector3(0, 3.18, .012), 1.84, .16, false], [Vector3(-.88, 1.825, .012), .16, 2.71, true], [Vector3(.88, 1.825, .012), .16, 2.71, true]]:
		var trim: MeshInstance3D = room.moulding(spec[1], spec[2], "window-casing", spec[3])
		trim.reparent(node, false)
		trim.position = spec[0]
	grille(node, Vector3(0, .135, .035), Vector2(1.25, .16), true)
	node.reparent(wall)


func high_vents() -> void:
	# 147: high grille over A's last landscape; 214: slot over B's end-wall Monet.
	for spec in [[A, "west", 8.70, 3.28, Vector2(1.40, .20)], [B, "south", 3.15, 3.12, Vector2(1.25, .18)]]:
		var node := Node3D.new()
		room.add_child(node)
		node.position = room.wall_point(spec[0], spec[1], spec[2], spec[3], .078)
		node.rotation.y = YAW[spec[1]]
		grille(node, Vector3.ZERO, spec[4], false)
		node.reparent(room.wall_body(spec[0], spec[1], node.position))


func local_box(parent: Node3D, at: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var mesh: MeshInstance3D = room.solid(Vector3.ZERO, size, material)
	mesh.reparent(parent, false)
	mesh.position = at
	return mesh


func grille(parent: Node3D, at: Vector3, size: Vector2, crossbars: bool) -> void:
	# Built slots/louvres, not a printed rectangle or typed label.
	local_box(parent, at, Vector3(size.x, size.y, .014), room.look(Color("4d504e")))
	var metal: Material = room.look(Color("999b94"))
	var slats = load("res://marble_hall_additions.gd").Batch.new()
	for y in int(size.y / .025):
		slats.box(at + Vector3(0, -size.y / 2 + .0125 + y * .025, .012), Vector3(size.x, .007, .017))
	if crossbars:
		for x in int(size.x / .035):
			slats.box(at + Vector3(-size.x / 2 + .0175 + x * .035, 0, .015), Vector3(.006, size.y, .012))
	slats.into(parent, metal, "VentLouvers", true)


func passage_details() -> void:
	# 89.5s: six-panel service leaf and two ventilation grilles beside A's entry.
	# The return leg is a fixed-door fit; the service door stays on its entrance-side wall.
	var service := leaf(.85, 2.50)
	var service_at: Vector3 = room.wall_point(RETURN, "south", 2.40, 1.25, .075)
	service.position = service_at
	service.rotation.y = PI
	service.reparent(room.wall_body(RETURN, "south", service.position))
	service.set_meta("room_wall", RETURN + ":south:service-leaf")
	service.set_meta("source_casing_width", .16)
	var b: Array = room.room_bounds(RETURN)
	room.door_casing(service, "south", b[3], [service_at.x - .425, service_at.x + .425], 2.50, .16)
	var vent := Node3D.new()
	room.add_child(vent)
	vent.position = room.wall_point(RETURN, "south", 2.40, 2.85, .075)
	vent.rotation.y = PI
	grille(vent, Vector3.ZERO, Vector2(.82, .18), false)
	vent.reparent(room.wall_body(RETURN, "south", vent.position))
	vent = Node3D.new()
	room.add_child(vent)
	vent.position = room.wall_point(RETURN, "west", 1.0, .53, .08)
	vent.rotation.y = PI / 2
	grille(vent, Vector3.ZERO, Vector2(.56, .45), true)
	vent.reparent(room.wall_body(RETURN, "west", vent.position))
	# White leaves folded along the opening cheeks: kept outside the clear route.
	for side in [-1, 1]:
		var folded := leaf(.53, 2.47)
		folded.position = Vector3(18.18, 1.235, -1.96 + side * .57)
		folded.rotation.y = 0 if side == -1 else PI
		var head: Node3D
		for body in room.casings:
			if body.get_meta("room_wall", "") == "marble stair hall:east:landing:header":
				head = body
		assert(head != null)
		folded.reparent(head)
	for side in [-1, 1]:
		var folded := leaf(.62, 2.74)
		folded.position = Vector3(11.55 + side * .67, 1.37, 2.70)
		folded.rotation.y = -side * PI / 2
		folded.reparent(room.wall_body(RETURN, "south", folded.position))


func leaf(width: float, height: float) -> Node3D:
	var node := Node3D.new()
	node.set_meta("impressionist_panelled_leaf", true)
	room.add_child(node)
	var white: Material = room.trim_paint()
	local_box(node, Vector3.ZERO, Vector3(width, height, .045), white)
	for x in [-1, 1]:
		for span in [[.09, .34], [.40, .59], [.66, .91]]:
			var h: float = (span[1] - span[0]) * height
			var w: float = (width - .18) / 2
			var center := Vector3(x * (w / 2 + .022), ((span[0] + span[1]) / 2 - .5) * height, .025)
			local_box(node, center, Vector3(w, h, .004), room.look(Color("e0ded5")))
			for spec in [[Vector3(0, h / 2, 0), w, .022, false], [Vector3(0, -h / 2, 0), w, .022, false], [Vector3(-w / 2, 0, 0), .022, h, true], [Vector3(w / 2, 0, 0), .022, h, true]]:
				var bead: MeshInstance3D = room.moulding(spec[1], spec[2], "leaf-panel", spec[3])
				bead.reparent(node, false)
				bead.position = center + spec[0]
	var knob := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = .026
	sphere.height = .052
	sphere.radial_segments = 12
	sphere.rings = 6
	knob.mesh = sphere
	knob.material_override = room.look(Color("8c7b49"))
	knob.position = Vector3(width / 2 - .08, 1.0 - height / 2, .055)
	node.add_child(knob)
	return node


func hexagon(at: Vector3, height: float, bottom: float, top: float, material: Material, parent: Node3D) -> void:
	var mesh := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.bottom_radius = bottom
	cylinder.top_radius = top
	cylinder.height = height
	cylinder.radial_segments = 6
	mesh.mesh = cylinder
	mesh.material_override = material
	mesh.rotation.y = PI / 6
	mesh.scale.z = .90
	room.add_child(mesh)
	mesh.position = at
	mesh.reparent(parent)


func ceiling_detector() -> void:
	# 147s: a small round detector, separate from the tracks owned by #274.
	var detector := MeshInstance3D.new()
	detector.mesh = ArrayMesh.new()
	room.add_child(detector)
	detector.position = Vector3(13.10, 3.65, 6.35)
	for spec in [[.10, .035, .0175, "343531"], [.084, .04, -.014, "eeeae2"]]:
		var mesh := MeshInstance3D.new()
		var disc := CylinderMesh.new()
		disc.top_radius = spec[0]
		disc.bottom_radius = spec[0] * .93
		disc.height = spec[1]
		disc.radial_segments = 16
		mesh.mesh = disc
		mesh.position.y = spec[2]
		mesh.material_override = room.look(Color(spec[3]))
		detector.add_child(mesh)
	detector.set_meta("opaque_ceiling", A)
	room.ceiling_details.append(detector)


func modern_exit_plate() -> void:
	# 225s: plain name-plate shape over the door and switch to its left. No typed text.
	var at: Vector3 = room.wall_point(B, "south", 5.20, 3.02, .055)
	var plate: Node3D = room.solid(at, Vector3(1.42, .16, .025), room.trim_paint())
	plate.reparent(room.wall_body(B, "south", at))
	at = room.wall_point(B, "south", 4.30, 1.26, .06)
	plate = room.solid(at, Vector3(.08, .105, .012), room.trim_paint())
	plate.reparent(room.wall_body(B, "south", at))


func dancer_case() -> void:
	# 145/147/152: six-sided grey plinth, stepped foot, bevelled white deck and clear hood.
	var c := Vector3(14.10, 0, 10.55)
	var grey: Material = room.look(Color("babbb5"))
	var white: Material = room.trim_paint()
	var body: Node3D = room.solid(c + Vector3(0, .475, 0), Vector3(1.10, .95, .98), grey, true)
	body.get_child(1).mesh = ArrayMesh.new()
	body.set_meta("impressionist_hexagonal_case", true)
	hexagon(c + Vector3(0, .065, 0), .13, .635, .635, grey, body)
	hexagon(c + Vector3(0, .495, 0), .72, .595, .595, grey, body)
	hexagon(c + Vector3(0, .862, 0), .024, .605, .605, white, body)
	hexagon(c + Vector3(0, .90, 0), .05, .595, .635, white, body)
	hexagon(c + Vector3(0, .9375, 0), .025, .635, .635, white, body)
	var glass: Material = room.look(Color(.81, .91, .94, .065))
	glass.cull_mode = BaseMaterial3D.CULL_DISABLED
	glass.roughness = .08
	var edge: Material = room.look(Color(.80, .91, .94, .35))
	for side in [-1, 1]:
		var pane: Node3D = room.solid(c + Vector3(side * .425, 1.40, 0), Vector3(.006, .90, .65), glass)
		pane.reparent(body)
		pane = room.solid(c + Vector3(0, 1.40, side * .325), Vector3(.85, .90, .006), glass)
		pane.reparent(body)
		for other in [-1, 1]:
			var seam: Node3D = room.solid(c + Vector3(side * .425, 1.40, other * .325), Vector3(.004, .90, .004), edge)
			seam.reparent(body)
	var lid: Node3D = room.solid(c + Vector3(0, 1.85, 0), Vector3(.85, .006, .65), glass)
	lid.reparent(body)
	# The bronze is intentionally absent; no silhouette is substituted for the missing asset.
	body.set_meta("missing_sculpture", "23.315")


func bench_surface(x: float, z: float) -> Vector3:
	# Rounded upholstered rim and real button depressions, scaled to the filmed 1.8 x .75m bench.
	var corner := Vector2(maxf(absf(x) - .315, 0), maxf(absf(z) - .84, 0))
	if corner.length() > .06:
		corner = corner.normalized() * .06
		x = signf(x) * (.315 + corner.x)
		z = signf(z) * (.84 + corner.y)
	var q := Vector2(absf(x) - .315, absf(z) - .84)
	var edge := .06 - q.max(Vector2.ZERO).length() - minf(maxf(q.x, q.y), 0)
	var y := .41 + .04 * sin(clampf(edge / .10, 0, 1) * PI / 2)
	for bx in [-.17, .17]:
		for bz in [-.63, -.21, .21, .63]:
			y -= .022 * exp(-Vector2(x - bx, z - bz).length_squared() / .0035)
	return Vector3(x, y, z)


func bench() -> void:
	# 214/216: one charcoal bench on four slender dark legs, not a solid black block.
	var c := Vector3(12.0, 0, 17.70)
	var dark: Material = room.look(Color("343531"))
	var body: Node3D = room.solid(c + Vector3(0, .225, 0), Vector3(.75, .45, 1.8), dark, true)
	body.get_child(1).mesh = ArrayMesh.new()
	body.set_meta("impressionist_tufted_bench", true)
	for x in [-.29, .29]:
		for z in [-.72, .72]:
			var leg: Node3D = room.solid(c + Vector3(x, .155, z), Vector3(.045, .29, .045), dark)
			leg.reparent(body)
	for spec in [[Vector3(0, .305, 0), Vector3(.63, .055, 1.62)], [Vector3(0, .29, -.72), Vector3(.65, .065, .045)], [Vector3(0, .29, .72), Vector3(.65, .065, .045)]]:
		var rail: Node3D = room.solid(c + spec[0], spec[1], dark)
		rail.reparent(body)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in 40:
		for column in 18:
			var corners := []
			for offset in [Vector2.ZERO, Vector2.RIGHT, Vector2.ONE, Vector2.DOWN]:
				corners.append(bench_surface(-.375 + (column + offset.x) * .75 / 18, -.90 + (row + offset.y) * 1.8 / 40))
			for i in [0, 1, 2, 0, 2, 3]:
				var point: Vector3 = corners[i]
				var dx := bench_surface(point.x + .001, point.z) - bench_surface(point.x - .001, point.z)
				var dz := bench_surface(point.x, point.z + .001) - bench_surface(point.x, point.z - .001)
				var normal := dz.cross(dx).normalized()
				st.set_normal(normal if normal.length_squared() > .1 else Vector3.UP)
				st.set_uv(Vector2(point.x, point.z) * 2)
				st.add_vertex(point)
	var perimeter := []
	for edge in 4:
		for i in 20:
			var t := float(i) / 20
			var p: Vector2 = Vector2(-.375 + t * .75, -.90) if edge == 0 else Vector2(.375, -.90 + t * 1.8) if edge == 1 else Vector2(.375 - t * .75, .90) if edge == 2 else Vector2(-.375, .90 - t * 1.8)
			perimeter.append(bench_surface(p.x, p.y))
	for i in perimeter.size():
		var a: Vector3 = perimeter[i]
		var b: Vector3 = perimeter[(i + 1) % perimeter.size()]
		var corners := [a, b, Vector3(b.x * .96, .335, b.z * .985), Vector3(a.x * .96, .335, a.z * .985)]
		var out := Vector2(a.x - clampf(a.x, -.315, .315), a.z - clampf(a.z, -.84, .84)).normalized()
		st.set_normal(Vector3(out.x, 0, out.y))
		for index in [0, 2, 1, 0, 3, 2]:
			st.set_uv(Vector2(corners[index].x, corners[index].z) * 2)
			st.add_vertex(corners[index])
	var cushion := MeshInstance3D.new()
	cushion.mesh = st.commit()
	cushion.material_override = room.look(Color("989a91"), "res://modules/shell/prototype/gallery_walk4/textures/bench-cloth-muse.webp")
	room.add_child(cushion)
	cushion.position = c
	cushion.reparent(body)
	for x in [-.17, .17]:
		for z in [-.63, -.21, .21, .63]:
			var button := MeshInstance3D.new()
			var dome := SphereMesh.new()
			dome.radius = .006
			dome.height = .004
			dome.radial_segments = 8
			dome.rings = 4
			button.mesh = dome
			button.material_override = dark
			room.add_child(button)
			button.position = c + bench_surface(x, z) + Vector3(0, .002, 0)
			button.reparent(body)


# #277: four filmed paintings with tracked repo photographs.
func hang_existing_works() -> void:
	var works: Array = JSON.parse_string(FileAccess.get_file_as_string("res://modules/shell/prototype/gallery_walk4/works.json"))
	for spec in [
		["42.219", "The Basin at Argenteuil (Le Bassin d'Argenteuil)", "Claude Monet", "1874", "55.2 x 74.3 cm", "west", 2.45, 1.65, Vector2(.743, .552), "E7", 1.20, A],
		["1998.107", "A Walk in the Meadows at Argenteuil", "Claude Monet", "1873", "53.3 x 64.8 cm", "west", 8.05, 1.65, Vector2(.648, .533), "E7", 1.20, A],
		["41.012", "Still Life with Apples", "Paul Cézanne", "ca. 1878", "23.2 x 39.7 cm", "east", 1.35, 1.62, Vector2(.397, .232), "W10", 2.35, A],
		["44.541", "The Seine at Giverny", "Claude Monet", "1885", "64.8 x 92.7 cm", "south", 3.15, 1.65, Vector2(.927, .648), "E7", .78, B]
	]:
		var margins: Array = []
		for work in works:
			if work.tag == spec[9]:
				margins = work.margins_px
		assert(not margins.is_empty())
		var painting = room.Painting.new()
		room.add_child(painting)
		var image: String = "res://assets/additions/impressionist/painting-" + spec[0] + ".jpg"
		painting.build_framed(load("res://modules/shell/prototype/gallery_walk4/frames/" + spec[9] + ".png"), load(image), spec[8], margins)
		# Match filmed broad bands while keeping the canvas at catalogue scale and the
		# kit's existing UVs. This changes our new frame geometry, not the frame source.
		var canvas: Vector2 = spec[8]
		var band_scale: float = spec[10]
		for mesh in painting.get_children():
			if not mesh is MeshInstance3D:
				continue
			var widened := ArrayMesh.new()
			for surface in mesh.mesh.get_surface_count():
				var arrays: Array = mesh.mesh.surface_get_arrays(surface)
				var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
				for i in vertices.size():
					var point := vertices[i]
					if absf(point.x) > canvas.x / 2 + .0001:
						point.x = signf(point.x) * (canvas.x / 2 + (absf(point.x) - canvas.x / 2) * band_scale)
					if absf(point.y) > canvas.y / 2 + .0001:
						point.y = signf(point.y) * (canvas.y / 2 + (absf(point.y) - canvas.y / 2) * band_scale)
					vertices[i] = point
				arrays[Mesh.ARRAY_VERTEX] = vertices
				widened.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
			mesh.mesh = widened
		painting.outer = canvas + (painting.outer - canvas) * band_scale
		painting.position = room.wall_point(spec[11], spec[5], spec[6], spec[7], .067)
		painting.rotation.y = YAW[spec[5]]
		painting.set_meta("catalogue_accession", spec[0])
		painting.set_meta("catalogue_asset", "impressionist-" + spec[0])
		painting.set_meta("catalogue_title", spec[1])
		painting.set_meta("catalogue_maker", spec[2])
		painting.set_meta("catalogue_date", spec[3])
		painting.set_meta("catalogue_medium", "Oil on canvas")
		painting.set_meta("catalogue_dimensions", spec[4])
		painting.set_meta("catalogue_image", image)
		painting.set_meta("catalogue_identified", true)
		painting.set_meta("placement_accepted", false)
		painting.set_meta("frame_ornament_accepted", false)
		painting.reparent(room.wall_body(spec[11], spec[5], painting.position))
		var right: float = -1 if spec[5] in ["west", "south"] else 1
		var card: Node3D = room.solid(room.wall_point(spec[11], spec[5], spec[6] + right * (painting.outer.x / 2 + .15), 1.40, .068), Vector3(.12, .14, .004) if spec[5] == "south" else Vector3(.004, .14, .12), room.look(Color("e9e7df")))
		card.set_meta("artwork_label_proxy", true)
		card.reparent(room.wall_body(spec[11], spec[5], card.position))
