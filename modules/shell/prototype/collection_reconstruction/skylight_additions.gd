## Skylight Gallery (#275): entry landing, three descending runs and the oak floor below.
## IMG_6379, catalogue-scaled #238 fit and new frame checks; all dimensions provisional.
## docs/evidence/skylight-275/NOTES.md records the sources, errors and draft comparisons.
extends RefCounted

const ROOM := "Skylight Gallery"
const REVEAL := "Skylight Gallery reveal threshold"
const ART := "res://assets/additions/skylight/"
const RECT := [[0, 0], [1, 0], [1, 1], [0, 1]]
# Traced from the catalogue photograph of 73.018 (image coordinates, y down).
const MANGOLD := [[.2426, .0014], [.0013, .2972], [.0039, .6942], [.2407, .9935], [.6952, .9993], [.9993, .4989], [.6965, .0007]]
# accession, title, maker, date, medium, dimensions, picture, width m, height m, wall, metres along
# that wall to the centre, centre height, outline, edge colour, where the picture comes from
const WORKS := [
	["69.094", "Untitled", "David Diao", "1968", "Acrylic on canvas", "222.3 x 221 x 3.8 cm", "diao-untitled-69094.jpg", 2.21, 2.223, "west", 2.5, 1.64, RECT, "b89a6f", "catalogue"],
	["73.018", "Distorted Circle within a Polygon II", "Robert Mangold", "1972", "Acrylic and graphite on shaped canvas", "224.2 x 203.8 cm", "mangold-distorted-circle-73018.jpg", 2.242, 2.038, "north", 2.2, 1.75, MANGOLD, "e9e7e0", "catalogue"],
	["2026.3", "Foreign Sign", "Amy Feldman", "2016", "Acrylic on canvas", "152.4 x 153 cm", "feldman-foreign-sign-20263-footage.jpg", 1.53, 1.524, "north", 4.65, 2.0, RECT, "ececec", "footage IMG_6379 54.0s"],
	["2000.17", "Pile", "Dennis Congdon", "2000", "Oil and acrylic on canvas", "221 x 188 cm", "congdon-pile-200017.jpg", 1.88, 2.21, "north", 7.63, 1.75, RECT, "c9c39a", "catalogue"],
	["2025.19", "Spectrum II", "Dan Walsh", "1998", "Acrylic on canvas", "152.4 x 152.4 x 3.8 cm", "walsh-spectrum-ii-202519-footage.jpg", 1.524, 1.524, "east", 2.5, 1.9, RECT, "8fbf6a", "footage IMG_6379 52.5s"],
]
const YAW := {"north": 0.0, "south": PI, "west": PI / 2, "east": -PI / 2}
const LOWER := -2.55
const RAIL := .90


func build(room) -> void:
	var b: Array = room.room_bounds(ROOM)
	var height := 3.9
	var white: StandardMaterial3D = room.look(Color("eeeae2"))
	# IMG_6379 6.0/127.0s: pale blue-grey walls, not the ivory default.
	var grey: StandardMaterial3D = room.look(Color("c5cad2"), "res://presentation/neutral-plaster.png")
	grey.cull_mode = BaseMaterial3D.CULL_BACK
	for wall in room.casings:
		if str(wall.get_meta("room_wall", "")).begins_with(ROOM + ":"):
			wall.get_child(1).material_override = grey
	_levels(room, b, grey, white)
	# The door wall is a deep panelled reveal with both leaves folded in it (IMG_6379 169..182s).
	# ponytail: the Hall reveal's builder, so the knobs sit at the grey gallery end; the footage hinges
	# these leaves on that side. Give the leaves their own hang when the door is fitted.
	room.build_reveal(REVEAL, true)
	_entry_floor(room)
	for wall in room.casings:
		if wall.has_meta("hall_reveal_leaf") and str(wall.get_meta("room_wall", "")).begins_with(REVEAL):
			wall.remove_meta("hall_reveal_leaf")
			wall.set_meta("skylight_reveal_leaf", true)
	# Flat plaster ceiling with the two gridded laylights the room is named for (7.0/99.0/127.0s).
	var centre := Vector3((b[0] + b[1]) / 2, height, (b[2] + b[3]) / 2)
	var ceiling: Node3D = room.solid(centre + Vector3(0, .02, 0), Vector3(b[1] - b[0], .04, b[3] - b[2]), room.look(Color("ebe9e3"), "res://presentation/neutral-plaster.png"))
	ceiling.set_meta("opaque_ceiling", ROOM)
	room.ceiling_details.append(ceiling)
	var glass: StandardMaterial3D = room.look(Color("f4f7fb"))
	glass.emission_enabled = true
	glass.emission = Color("f1f5fb")
	glass.emission_energy_multiplier = 2.5
	# ponytail: pane counts and sizes read off 7.0s by eye (west 5 x 4, east 5 x 2); refit from the ceiling frames.
	for spec in [[-1.15, 3.4, 5, 4], [1.95, 1.7, 5, 2]]:
		var size := Vector2(spec[1], 2.6)
		var pane: Node3D = room.solid(centre + Vector3(spec[0], -.012, 0), Vector3(size.x, .02, size.y), glass)
		pane.set_meta("skylight_laylight", true)
		pane.set_meta("opaque_ceiling", ROOM)  # hides with the ceiling in every view from above, baked or not
		room.ceiling_details.append(pane)
		for i in range(spec[3] + 1):
			var bar: Node3D = room.solid(centre + Vector3(spec[0] + (float(i) / spec[3] - .5) * size.x, -.035, 0), Vector3(.05, .05, size.y + .1), white)
			bar.reparent(pane)
		for i in range(spec[2] + 1):
			var bar: Node3D = room.solid(centre + Vector3(spec[0], -.035, (float(i) / spec[2] - .5) * size.y), Vector3(size.x + .1, .05, .05), white)
			bar.reparent(pane)
	for spec in [["north", b[1] - b[0], 0.0], ["south", b[1] - b[0], PI], ["west", b[3] - b[2], PI / 2], ["east", b[3] - b[2], -PI / 2]]:
		var cornice: MeshInstance3D = room.moulding(spec[1], .22, "door-architrave", false)
		cornice.position = room.wall_point(ROOM, spec[0], spec[1] / 2, height - .11, .065)
		cornice.rotation.y = spec[2]
		cornice.set_meta("opaque_ceiling", ROOM)  # two-sided trim: hide it with the ceiling, or it bars the view from above
		room.ceiling_details.append(cornice)
	_lift(room, b, white)
	_piano(room, b)
	for row in WORKS:
		var art = room.Painting.new()
		room.add_child(art)
		art.build_shaped(load(ART + row[6]), Vector2(row[7], row[8]), row[12], Color(row[13]))
		art.scale.z = .038 / .05  # catalogue depth of the stretcher
		art.position = room.wall_point(ROOM, row[9], row[10], row[11], .08)
		art.rotation.y = YAW[row[9]]
		art.set_meta("catalogue_accession", row[0])
		art.set_meta("catalogue_title", row[1])
		art.set_meta("catalogue_maker", row[2])
		art.set_meta("catalogue_date", row[3])
		art.set_meta("catalogue_medium", row[4])
		art.set_meta("catalogue_dimensions", row[5])
		art.set_meta("catalogue_image", ART + row[6])
		art.set_meta("catalogue_image_source", row[14])
		art.set_meta("placement_accepted", false)
		# Blank card: the wording is legible for one label only (Feldman, 103.9s).
		var card: Node3D = room.solid(Vector3.ZERO, Vector3(.15, .11, .003), room.look(Color("f3f2ed")))
		card.reparent(art, false)
		card.position = Vector3(row[7] / 2 + .25, 1.4 - row[11], -.017 / art.scale.z)
		card.set_meta("artwork_label_proxy", true)
		art.reparent(room.wall_body(ROOM, row[9], art.global_position))
	room.inventory["skylight_gallery"] = {"works": WORKS.size(), "piano": true, "levels_built": 2, "levels_in_footage": 2, "lower_floor_m": LOWER, "entry_floor_m": 0.0, "ceiling_m": height, "stair_walkable": true, "metric_accepted": false, "placement_accepted": false}


func _levels(room, b: Array, grey: Material, white: Material) -> void:
	var plan: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://geometry.json")).skylight_walk
	var landing: Array = plan.landing
	var iron: Material = room.look(Color("25272a"))
	var wood: Material = room.look(Color("8c6141"))
	# Replace only this room's flat visual boards. Collision already comes from
	# its lower floor / landing / ramp patches; the neighbouring reveal stays level.
	var oak: ShaderMaterial
	for child in room.get_children():
		if child is MeshInstance3D and child.mesh != null and child.material_override is ShaderMaterial:
			var reach: AABB = child.mesh.get_aabb()
			if reach.position.y > -.01 and reach.end.y < .02 and reach.position.x >= b[0] - .01 and reach.end.x <= b[1] + .01 and reach.position.z >= b[2] - .01 and reach.end.z <= b[3] + .01:
				if oak == null:
					oak = child.material_override.duplicate()
					oak.set_shader_parameter("ground_tone", Color("dfc89f"))
				child.free()
	assert(oak != null, "Skylight must replace its own authored floor")
	for i in int(ceil((b[1] - b[0]) / .14)):
		var xa: float = b[0] + i * .14
		var xb: float = minf(b[1], xa + .14)
		for j in int(ceil((b[3] - b[2]) / 1.8)) + 1:
			var za: float = maxf(b[2], b[2] + j * 1.8 - (i % 3) * .6)
			var zb: float = minf(b[3], b[2] + (j + 1) * 1.8 - (i % 3) * .6)
			if zb <= za:
				continue
			room.panel(room, [Vector3(xa, LOWER + .003, za), Vector3(xb, LOWER + .003, za), Vector3(xb, LOWER + .003, zb), Vector3(xa, LOWER + .003, zb)], [Vector2.ZERO, Vector2.DOWN, Vector2.ONE, Vector2.RIGHT], oak, Color(1, 1, 1, fmod((i * 7 + j * 3) * .131, 1.0)))
	# Extend the walls downward. The upper opening / casing / deep reveal and
	# leaves remain the kit's construction at y=0. Existing kit skirting is
	# positioned on the oak floor, not left floating at the entry's height.
	var upper_walls: Array = room.casings.duplicate()
	var exit_width := 1.80
	var exit_mid: float = b[0] + 4.65
	for side in ["west", "east", "north", "south"]:
		var vertical: bool = side in ["west", "east"]
		var fixed: float = b[0] if side == "west" else b[1] if side == "east" else b[2] if side == "north" else b[3]
		var lo: float = b[2] if vertical else b[0]
		var hi: float = b[3] if vertical else b[1]
		var spans: Array = [[lo, exit_mid - exit_width / 2], [exit_mid + exit_width / 2, hi]] if side == "north" else [[lo, hi]]
		for span in spans:
			var center := Vector3(fixed, LOWER / 2, (span[0] + span[1]) / 2) if vertical else Vector3((span[0] + span[1]) / 2, LOWER / 2, fixed)
			var size := Vector3(.12, -LOWER, span[1] - span[0]) if vertical else Vector3(span[1] - span[0], -LOWER, .12)
			var wall: StaticBody3D = room.solid(center, size, grey, true)
			wall.set_meta("room_wall", ROOM + ":" + side)
			room.wall_face(wall, span[1] - span[0], -LOWER, vertical, 1.0 if side in ["west", "north"] else -1.0)
			for upper in upper_walls:
				if upper.get_meta("room_wall", "") != ROOM + ":" + side:
					continue
				for child in upper.get_children():
					if child is MeshInstance3D and child != upper.get_child(1) and not child.has_meta("door_casing"):
						if side == "north":
							child.free()  # replace the single kit length with the two door-side lengths
							continue
						child.global_position.y += LOWER
						child.reparent(wall)
			if side == "north":
				var trim: MeshInstance3D = room.moulding(span[1] - span[0], .20, "baseboard", false)
				trim.material_override = room.trim_paint()
				trim.position = Vector3((span[0] + span[1]) / 2, LOWER + .10, fixed + .065)
				trim.reparent(wall)
	_lower_exit(room, b, exit_mid, exit_width, grey, white)
	# A solid plaster enclosure below the entry deck, as filmed beside the
	# lift / vestibule. Its two exposed faces keep the lower visitor out of
	# the deck's footprint; nothing supports a walk on an invisible flat plane.
	for spec in [
		[Vector3(landing[0], LOWER / 2, (landing[2] + landing[3]) / 2), Vector3(.12, -LOWER, landing[3] - landing[2])],
		[Vector3((landing[0] + landing[1]) / 2, LOWER / 2, landing[2]), Vector3(landing[1] - landing[0], -LOWER, .12)],
	]:
		var wall: StaticBody3D = room.solid(spec[0], spec[1], grey, true)
		wall.set_meta("room_wall", ROOM + ":platform")
	# Visible stair treads / risers above smooth collision ramps. The first
	# run descends east, the second north, the third west onto the oak floor.
	var count: int = 0
	for n in plan.risers:
		count += int(n)
	var rise: float = -LOWER / count
	var flights: Array = [
		[Vector3(landing[1], 0, landing[3]), Vector3.RIGHT, Vector3.FORWARD, plan.turn_x - landing[1], landing[3] - landing[2], int(plan.risers[0]), 0.0],
		[Vector3(b[1], -rise * int(plan.risers[0]), landing[2]), Vector3.FORWARD, Vector3.LEFT, landing[2] - plan.turn_z, b[1] - plan.turn_x, int(plan.risers[1]), -rise * int(plan.risers[0])],
		[Vector3(plan.turn_x, -rise * (int(plan.risers[0]) + int(plan.risers[1])), b[2]), Vector3.LEFT, Vector3.BACK, plan.turn_x - landing[1], plan.turn_z - b[2], int(plan.risers[2]), -rise * (int(plan.risers[0]) + int(plan.risers[1]))],
	]
	for patch in plan.surfaces:
		if not (patch.label.contains("landing") or patch.label.contains("quarter")):
			continue
		var a: Array = patch.vertices[0]
		var c: Array = patch.vertices[2]
		var slab: MeshInstance3D = room.solid(Vector3((a[0] + c[0]) / 2, a[1] - .09, (a[2] + c[2]) / 2), Vector3(absf(c[0] - a[0]), .18, absf(c[2] - a[2])), iron)
		slab.set_meta("skylight_landing", patch.label)
	for flight in flights:
		var going: float = flight[3] / int(flight[5])
		for i in int(flight[5]):
			var p: Vector3 = flight[0] + flight[1] * ((i + .5) * going) + flight[2] * (flight[4] / 2)
			p.y -= (i + 1) * rise + .09
			var size := Vector3(going + .015, .18, flight[4]) if flight[1].x != 0 else Vector3(flight[4], .18, going + .015)
			var step: MeshInstance3D = room.solid(p, size, iron)
			step.set_meta("skylight_stair_tread", true)
			# Pale vertical riser / stringer outside the black walking surface.
			var edge: Vector3 = p + flight[2] * (flight[4] / 2 + .005) - Vector3.UP * .12
			room.solid(edge, Vector3(going + .018, .24, .045) if flight[1].x != 0 else Vector3(.045, .24, going + .018), white)
	# Guards collide in the draft. Their named wall tag keeps them out of the
	# adapter's furniture blocks; geometry.json supplies the same guard lines.
	for guard in plan.guards:
		var a := Vector3(guard.ends[0][0], guard.ends[0][1], guard.ends[0][2])
		var c := Vector3(guard.ends[1][0], guard.ends[1][1], guard.ends[1][2])
		var length := Vector2(c.x - a.x, c.z - a.z).length()
		var rail: MeshInstance3D = room.solid((a + c) / 2 + Vector3.UP * RAIL, Vector3(length, .06, .07), wood)
		rail.rotation.z = atan2(c.y - a.y, length) if absf(c.x - a.x) > .01 else 0.0
		if absf(c.z - a.z) > .01:
			rail.rotation = Vector3(atan2(a.y - c.y, length), PI / 2, 0)
		rail.set_meta("skylight_balustrade", true)
		for i in int(ceil(length / .14)) + 1:
			var p: Vector3 = a.lerp(c, float(i) / ceil(length / .14))
			room.solid(p + Vector3.UP * (RAIL / 2), Vector3(.018, RAIL, .018), iron).set_meta("skylight_baluster", true)
		var barrier: StaticBody3D = room.solid((a + c) / 2 + Vector3.UP * .45, Vector3(maxf(.05, absf(c.x - a.x)), absf(c.y - a.y) + .9, maxf(.05, absf(c.z - a.z))), iron, true)
		barrier.get_child(1).mesh = ArrayMesh.new()
		barrier.set_meta("room_wall", ROOM + ":rail_guard")


func _lower_exit(room, b: Array, middle: float, width: float, grey: Material, white: Material) -> void:
	var header: StaticBody3D = room.solid(Vector3(middle, (-LOWER + 2.20) / 2, b[2]), Vector3(width, -LOWER - 2.20, .12), grey, true)
	header.set_meta("room_wall", ROOM + ":north:header")
	# Reuse the kit, then place this door on the lower floor. No kit code changes.
	room.door_casing(header, "north", b[2], [middle - width / 2, middle + width / 2], 2.20, .10)
	header.set_meta("source_casing_width", .10)
	header.position.y += LOWER
	# Short, closed study of the doorway beyond the surveyed room. It is not
	# registered as a new walkable room or a route out of this gallery.
	var back: Node3D = room.solid(Vector3(middle, LOWER + 1.10, b[2] - .60), Vector3(width, 2.20, .04), room.look(Color("262325")))
	back.reparent(header)
	for side in [-1, 1]:
		var leaf: Node3D = room.solid(Vector3(middle + side * (width / 2 - .08), LOWER + 1.08, b[2] - .29), Vector3(.06, 2.16, .56), white)
		leaf.reparent(header)
		for level in [.42, 1.30, 1.91]:
			var panel: Node3D = room.solid(Vector3(middle + side * (width / 2 - .04), LOWER + level, b[2] - .29), Vector3(.024, .30 if level != 1.30 else .63, .39), room.look(Color("d6d6d0")))
			panel.reparent(header)
		var push: Node3D = room.solid(Vector3(middle + side * (width / 2 - .02), LOWER + 1.02, b[2] - .29), Vector3(.025, .035, .43), room.look(Color("303032")))
		push.reparent(header)
	var sign: Node3D = room.solid(Vector3(middle, LOWER + 2.50, b[2] + .075), Vector3(.42, .20, .018), room.look(Color.WHITE, "res://modules/shell/prototype/gallery_walk4/textures/exit-sign.svg"))
	sign.reparent(header)
	header.set_meta("skylight_lower_exit", true)


func _entry_floor(room) -> void:
	# 170s / IMG_6380 0..14s: black landing meets the grey room's oak at the
	# outer sill, including the floor inside the preserved deep reveal.
	var b: Array = room.room_bounds(REVEAL)
	for child in room.get_children():
		if child is MeshInstance3D and child.mesh != null and child.material_override is ShaderMaterial:
			var reach: AABB = child.mesh.get_aabb()
			if reach.position.y > -.01 and reach.end.y < .02 and reach.position.x >= b[0] - .01 and reach.end.x <= b[1] + .01 and reach.position.z >= b[2] - .01 and reach.end.z <= b[3] + .01:
				child.free()
	var floor: MeshInstance3D = room.solid(Vector3((b[0] + b[1]) / 2, -.017, (b[2] + b[3]) / 2), Vector3(b[1] - b[0], .04, b[3] - b[2]), room.look(Color("25272a")))
	floor.set_meta("skylight_landing", REVEAL)


# Lift 4: cream doors in a purple reveal under the strip that names the room (IMG_6379 8.0..9.4s).
# A closed wall feature, as lift 5 is in the connector. ponytail: it stands on the lower floor in
# the footage, in the south wall west of the landing; here it is at the door's level.
func _lift(room, b: Array, white: Material) -> void:
	var at: Vector3 = room.wall_point(ROOM, "south", 1.55, LOWER, 0)
	var wall: Node3D = room.wall_body(ROOM, "south", at)
	var purple: Material = room.look(Color.WHITE, "res://presentation/purple-plaster.png")
	for part in [[Vector3(0, 1.15, -.07), Vector3(1.5, 2.3, .02), purple], [Vector3(-.26, 1.07, -.085), Vector3(.5, 2.1, .02), white], [Vector3(.26, 1.07, -.085), Vector3(.5, 2.1, .02), white],
			[Vector3(-.8, 1.2, -.09), Vector3(.1, 2.4, .05), white], [Vector3(.8, 1.2, -.09), Vector3(.1, 2.4, .05), white], [Vector3(0, 2.4, -.09), Vector3(1.7, .1, .05), white],
			[Vector3(0, 2.75, -.075), Vector3(1.5, .16, .02), room.look(Color("d9dadc"))]]:
		var piece: Node3D = room.solid(at + part[0], part[1], part[2])
		piece.set_meta("skylight_lift", true)
		piece.reparent(wall)
	for text in [["4", 100, Color("27252a"), Vector3(-.26, 1.55, -.1)], ["SKYLIGHT GALLERY", 22, Color("4a4a4d"), Vector3(0, 2.77, -.09)], ["Gift of Suzanne and Terrence Murray", 11, Color("4a4a4d"), Vector3(0, 2.715, -.09)]]:
		var label := Label3D.new()
		label.text = text[0]
		label.font_size = text[1]
		label.pixel_size = .005
		label.modulate = text[2]
		label.position = at + text[3]
		label.rotation.y = PI
		room.add_child(label)
		label.reparent(wall)


# Black grand piano with its bench in the north-west corner, keyboard to the west wall, lid shut
# (IMG_6379 3.0/13.5/132.0s). ponytail: maker unread; 1.75 x 1.48 m is a parlour grand by eye.
func _piano(room, b: Array) -> void:
	var black: StandardMaterial3D = room.look(Color("121214"))
	black.roughness = .35
	var at := Vector3(b[0] + .85, LOWER, b[2] + .35)  # keyboard end, spine side
	var body: Node3D = room.solid(at + Vector3(.45, .79, .74), Vector3(.9, .38, 1.48), black, true)
	body.set_meta("skylight_piano", true)
	var tail: Node3D = room.solid(at + Vector3(1.325, .79, .5), Vector3(.85, .38, 1.0), black, true)
	tail.set_meta("skylight_piano", true)
	for part in [[Vector3(-.07, .70, .74), Vector3(.14, .03, 1.22), room.look(Color("f1efe8"))], [Vector3(-.08, .665, .74), Vector3(.18, .04, 1.4), black],
			[Vector3(.1, .30, .1), Vector3(.09, .60, .09), black], [Vector3(.1, .30, 1.38), Vector3(.09, .60, .09), black], [Vector3(1.6, .30, .5), Vector3(.09, .60, .09), black],
			[Vector3(.12, .28, .74), Vector3(.06, .44, .26), black], [Vector3(.9, 1.06, .6), Vector3(.02, .16, .1), black]]:
		var piece: Node3D = room.solid(at + part[0], part[1], part[2])
		piece.reparent(body)
	var bench: Node3D = room.solid(at + Vector3(-.42, .47, .74), Vector3(.38, .08, .8), black, true)
	bench.set_meta("skylight_piano_bench", true)
	for x in [-.14, .14]:
		for z in [-.34, .34]:
			var leg: Node3D = room.solid(at + Vector3(-.42 + x, .215, .74 + z), Vector3(.05, .43, .05), black)
			leg.reparent(bench)
