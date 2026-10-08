## Skylight Gallery (#275): entry landing, three descending runs and the oak floor below.
## IMG_6379, catalogue-scaled #238 fit and new frame checks; all dimensions provisional.
## docs/evidence/skylight-275/NOTES.md records the sources, errors and draft comparisons.
extends RefCounted

const ROOM := "Skylight Gallery"
const REVEAL := "Skylight Gallery reveal threshold"
const ART := "res://modules/shell/collection_rooms/assets/additions/skylight/"
const RECT := [[0, 0], [1, 0], [1, 1], [0, 1]]
# Traced from the catalogue photograph of 73.018 (image coordinates, y down).
const MANGOLD := [[.2426, .0014], [.0013, .2972], [.0039, .6942], [.2407, .9935], [.6952, .9993], [.9993, .4989], [.6965, .0007]]
# accession, title, maker, date, medium, dimensions, picture, width m, height m, wall, metres along
# that wall to the centre, centre height, outline, edge colour, where the picture comes from
const WORKS := [
	["69.094", "Untitled", "David Diao", "1968", "Acrylic on canvas", "222.3 x 221 x 3.8 cm", "diao-untitled-69094.jpg", 2.21, 2.223, "west", 2.5, 1.56, RECT, "b89a6f", "catalogue"],
	["73.018", "Distorted Circle within a Polygon II", "Robert Mangold", "1972", "Acrylic and graphite on shaped canvas", "224.2 x 203.8 cm", "mangold-distorted-circle-73018.jpg", 2.242, 2.038, "north", 1.75, 1.75, MANGOLD, "e9e7e0", "catalogue"],
	["2026.3", "Foreign Sign", "Amy Feldman", "2016", "Acrylic on canvas", "152.4 x 153 cm", "feldman-foreign-sign-20263-footage.jpg", 1.53, 1.524, "north", 4.65, 1.98, RECT, "ececec", "footage IMG_6379 54.0s"],
	["2000.17", "Pile", "Dennis Congdon", "2000", "Oil and acrylic on canvas", "221 x 188 cm", "congdon-pile-200017.jpg", 1.88, 2.21, "north", 7.45, 1.75, RECT, "c9c39a", "catalogue"],
	["2025.19", "Spectrum II", "Dan Walsh", "1998", "Acrylic on canvas", "152.4 x 152.4 x 3.8 cm", "walsh-spectrum-ii-202519-footage.jpg", 1.524, 1.524, "east", 2.10, 1.9, RECT, "8fbf6a", "footage IMG_6379 52.5s"],
]
const YAW := {"north": 0.0, "south": PI, "west": PI / 2, "east": -PI / 2}
const LOWER := -2.55
const RAIL := .90
# Blank labels: local horizontal offset from the canvas centre, then height
# above the lower oak floor. Canvas-plane checks in NOTES.md / label-check.json.
const CARDS := {
	"69.094": Vector2(1.01, 1.22),       # 127s: beside the piano, well below Diao
	"73.018": Vector2(.90, 1.00),       # 127 / 154.5s: below Mangold, left of the exit
	"2026.3": Vector2(-.02, 3.25),      # 54s: centred below Feldman, above EXIT
	"2000.17": Vector2(1.31, 2.05),     # 6.5s: right of Congdon, above the wall rail
	"2025.19": Vector2(1.48, 3.25),     # 159.5s: right of Walsh, over the east quarter
}


func build(room) -> void:
	var b: Array = room.room_bounds(ROOM)
	var height := 3.9
	var white: StandardMaterial3D = room.trim_paint()
	# IMG_6379 6.0/127.0s: pale blue-grey walls, not the ivory default.
	var grey: StandardMaterial3D = room.look(Color("c5cad2"))
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
	var ceiling: Node3D = room.solid(centre + Vector3(0, .02, 0), Vector3(b[1] - b[0], .04, b[3] - b[2]), room.look(Color("ebe9e3"), "res://modules/shell/collection_rooms/presentation/neutral-plaster.png"))
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
		var hung_label: Vector2 = CARDS[row[0]]
		card.position = Vector3(hung_label.x, LOWER + hung_label.y - row[11], -.017 / art.scale.z)
		card.set_meta("artwork_label_proxy", true)
		art.reparent(room.wall_body(ROOM, row[9], art.global_position))
	room.inventory["skylight_gallery"] = {"works": WORKS.size(), "piano": true, "levels_built": 2, "levels_in_footage": 2, "lower_floor_m": LOWER, "entry_floor_m": 0.0, "ceiling_m": height, "stair_walkable": true, "metric_accepted": false, "placement_accepted": false}


func _levels(room, b: Array, grey: Material, white: Material) -> void:
	var plan: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://modules/shell/collection_rooms/geometry.json")).skylight_walk
	var landing: Array = plan.landing
	var iron: Material = room.look(Color("25272a"))
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
	var west_deck: StaticBody3D = room.solid(Vector3(landing[0],LOWER/2,(landing[2]+landing[3])/2),Vector3(.12,-LOWER,landing[3]-landing[2]),grey,true)
	west_deck.set_meta("room_wall",ROOM+":platform")
	_platform_features(room, plan, grey, white, west_deck)
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
	for f in flights.size():
		var flight: Array = flights[f]
		var going: float = flight[3] / int(flight[5])
		for i in int(flight[5]):
			var p: Vector3 = flight[0] + flight[1] * ((i + .5) * going) + flight[2] * (flight[4] / 2)
			p.y -= (i + 1) * rise + .09
			var size := Vector3(going + .015, .18, flight[4]) if flight[1].x != 0 else Vector3(flight[4], .18, going + .015)
			var st := _surface()
			var outline := _rounded_rectangle(Vector2(p.x - size.x / 2, p.z - size.z / 2), Vector2(size.x, size.z), .018)
			if f == 2 and i == int(flight[5]) - 1:
				# IMG_6379 72 / 79.5 / 132s: the first step curls around the cage newel.
				outline = _rounded_rectangle(Vector2(p.x - size.x / 2 - .10, p.z - size.z / 2), Vector2(size.x + .10, size.z + .15), .14)
			_prism(st, outline, p.y - .09, p.y + .09)
			var step: MeshInstance3D = _mesh(room, st, iron, "skylight_stair_tread")
			step.set_meta("skylight_stair_tread", true)
			var nose := _surface()
			var start: Vector3 = p - flight[1] * (going / 2) - flight[2] * (flight[4] / 2)
			start.y = p.y + .082
			_tube(nose, PackedVector3Array([start, start + flight[2] * flight[4]]), .012, 8)
			_mesh(room, nose, iron, "skylight_step_nosing")
			# Pale vertical riser / stringer outside the black walking surface.
			var edge: Vector3 = p + flight[2] * (flight[4] / 2 + .005) - Vector3.UP * .12
			room.solid(edge, Vector3(going + .018, .24, .045) if flight[1].x != 0 else Vector3(.045, .24, going + .018), white)
	# Guards collide in the draft. Their named wall tag keeps them out of the
	# adapter's furniture blocks; geometry.json supplies the same guard lines.
	_balustrade(room, plan, b, iron)
	for guard in plan.guards:
		var a := Vector3(guard.ends[0][0], guard.ends[0][1], guard.ends[0][2])
		var c := Vector3(guard.ends[1][0], guard.ends[1][1], guard.ends[1][2])
		var barrier: StaticBody3D = room.solid((a + c) / 2 + Vector3.UP * .45, Vector3(maxf(.05, absf(c.x - a.x)), absf(c.y - a.y) + .9, maxf(.05, absf(c.z - a.z))), iron, true)
		barrier.get_child(1).mesh = ArrayMesh.new()
		barrier.set_meta("room_wall", ROOM + ":rail_guard")


func _platform_features(room, plan: Dictionary, grey: Material, white: Material, west: Node3D) -> void:
	# 6.5 / 23 / 99s: the screen faces the lift; an open cased vestibule is
	# below the platform's front, and a white cupboard is below the first run.
	var deck: Array = plan.landing
	var mid: float = (deck[0]+deck[1])/2
	var width := 1.20
	for span in [[deck[0],mid-width/2],[mid+width/2,deck[1]]]:
		var wall: StaticBody3D = room.solid(Vector3((span[0]+span[1])/2,LOWER/2,deck[2]),Vector3(span[1]-span[0],-LOWER,.12),grey,true)
		wall.set_meta("room_wall",ROOM+":platform")
	var header: StaticBody3D = room.solid(Vector3(mid,(-LOWER+2.20)/2,deck[2]),Vector3(width,-LOWER-2.20,.12),grey,true)
	header.set_meta("room_wall",ROOM+":platform:header")
	room.door_casing(header,"north",deck[2],[mid-width/2,mid+width/2],2.20,.10)
	header.set_meta("source_casing_width",.10)
	header.position.y += LOWER
	var back: Node3D = room.solid(Vector3(mid,LOWER+1.10,deck[2]+.40),Vector3(width,2.20,.04),room.look(Color("272829")),true)
	back.set_meta("room_wall",ROOM+":platform")
	back.reparent(header)
	for side in [-1,1]:
		var cheek: Node3D = room.solid(Vector3(mid+side*(width/2-.02),LOWER+1.10,deck[2]+.20),Vector3(.04,2.20,.40),white)
		cheek.reparent(header)
	var sill: Node3D = room.solid(Vector3(mid,LOWER+.007,deck[2]+.20),Vector3(width,.014,.40),room.look(Color("45464a")))
	sill.reparent(header)
	var leaf: Node3D = room.solid(Vector3(mid+width/2-.08,LOWER+1.08,deck[2]+.18),Vector3(.045,2.16,.48),white)
	leaf.reparent(header)
	# The display is dark glass and its actual metal frame, with no invented
	# navigation labels or architecture painted into a screen texture.
	var glass: StandardMaterial3D = room.look(Color("101a20"))
	glass.roughness = .20
	glass.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	for part in [
		[Vector3(deck[0]-.095,LOWER+1.57,deck[3]-.67),Vector3(.07,.86,.64),room.look(Color("27282b"))],
		[Vector3(deck[0]-.134,LOWER+1.58,deck[3]-.67),Vector3(.009,.78,.56),glass],
		[Vector3(deck[0]-.071,LOWER+1.42,deck[3]-.67),Vector3(.08,.12,.16),room.look(Color("626465"))],
	]:
		var piece: Node3D = room.solid(part[0],part[1],part[2])
		piece.reparent(west)
	# Enclose just the first flight's underside; its white stringer still
	# reads above the cupboard. This face does not consume lower well floor.
	var closet_mid: float = (deck[1]+float(plan.turn_x))/2
	var lower_face: StaticBody3D = room.solid(Vector3(closet_mid,LOWER+.78,deck[2]),Vector3(float(plan.turn_x)-deck[1],1.56,.08),grey,true)
	lower_face.set_meta("room_wall",ROOM+":platform")
	var fill := _surface()
	_quad(fill,[Vector3(deck[1],LOWER+1.56,deck[2]),Vector3(plan.turn_x,LOWER+1.56,deck[2]),Vector3(plan.turn_x,float(plan.guards[2].ends[1][1])-.20,deck[2]),Vector3(deck[1],-.20,deck[2])],Vector3.FORWARD)
	_mesh(room,fill,grey,"skylight_stair_enclosure").reparent(lower_face)
	var cupboard: Node3D = room.solid(Vector3(closet_mid,LOWER+.78,deck[2]-.049),Vector3(1.14,1.56,.035),white)
	cupboard.reparent(lower_face)
	for x in [-.277,.277]:
		for y in [.40,1.18]:
			var panel: Node3D = room.solid(Vector3(closet_mid+x,LOWER+y,deck[2]-.073),Vector3(.42,.56,.016),room.look(Color("d9d9d1")))
			panel.reparent(lower_face)
		for z in [-.54,0,.54]:
			var stile: Node3D = room.solid(Vector3(closet_mid+z,LOWER+.78,deck[2]-.081),Vector3(.032,1.60,.025),white)
			stile.reparent(lower_face)
	for y in [.04,.79,1.55]:
		var rail: Node3D = room.solid(Vector3(closet_mid,LOWER+y,deck[2]-.081),Vector3(1.18,.045,.025),white)
		rail.reparent(lower_face)


func _balustrade(room, plan: Dictionary, b: Array, iron: Material) -> void:
	# 154.5 / 99s: a slender shaft, two rolled leaves under the rail, two
	# scrolls at the foot and collars; corner posts are open scroll panels.
	var rods := _surface()
	var scrolls := _surface()
	var timber := _surface()
	var rail_path := PackedVector3Array()
	for index in plan.guards.size():
		var guard: Dictionary = plan.guards[index]
		var a := Vector3(guard.ends[0][0], guard.ends[0][1], guard.ends[0][2])
		var c := Vector3(guard.ends[1][0], guard.ends[1][1], guard.ends[1][2])
		var along := Vector3(c.x - a.x, 0, c.z - a.z).normalized()
		var length := Vector2(c.x - a.x, c.z - a.z).length()
		var intervals := int(round(length / .14))
		if index == 0:
			rail_path.append(a + Vector3.UP * RAIL)
		rail_path.append(c + Vector3.UP * RAIL)
		for i in range(1, intervals):
			var p := a.lerp(c, float(i) / intervals)
			# The sockets stand on each built tread, rather than hovering on the ramp.
			if index >= 2:
				var count: int = int(plan.risers[index - 2])
				p.y = a.y + (c.y - a.y) * ceil(float(i) / intervals * count) / count
			var top := a.lerp(c, float(i) / intervals).y + RAIL - .025
			_tube(rods, PackedVector3Array([p, Vector3(p.x, top, p.z)]), .008, 6)
			for y in [.04, .17, top - p.y - .20, top - p.y - .055]:
				_tube(rods, PackedVector3Array([p + Vector3.UP * (y - .012), p + Vector3.UP * (y + .012)]), .015, 8)
			for sign in [-1, 1]:
				var upper := PackedVector3Array()
				var lower := PackedVector3Array()
				# The measured outlines are mirrored about the shaft. These are
				# rolled iron rods, not alpha cards or a repeated video texture.
				for uv in [[0,.0],[.018,.032],[.052,.105],[.052,.145],[.035,.167],[.018,.160],[.014,.142],[.024,.133],[.034,.144]]:
					upper.append(Vector3(p.x, top - .18, p.z) + along * (float(uv[0]) * sign) + Vector3.UP * float(uv[1]))
				for uv in [[0,0],[.022,.025],[.057,.100],[.056,.132],[.037,.145],[.019,.138],[.014,.120],[.024,.112],[.035,.123]]:
					lower.append(p + along * (float(uv[0]) * sign) + Vector3.UP * (.025 + float(uv[1])))
				_tube(scrolls, _smooth(upper), .0055, 6)
				_tube(scrolls, _smooth(lower), .0055, 6)
		# Rectangular corner posts with five paired C scrolls. The front / west
		# landing post and both quarter-turn posts are visible in 99 / 154.5s.
		if index < 4:
			var p: Vector3 = c
			for offset in [-.095, 0.0, .095]:
				_tube(rods, PackedVector3Array([p + along * offset, p + along * offset + Vector3.UP * (RAIL - .035)]), .009 if offset == 0 else .006, 6)
			for y in [.08, .26, .44, .62, .80]:
				for sign in [-1, 1]:
					var path := PackedVector3Array()
					for i in 15:
						var t: float = float(i) / 14 * TAU * .92
						var radius: float = lerpf(.069, .018, float(i) / 14)
						path.append(p + along * (sign * (.026 + sin(t) * radius)) + Vector3.UP * (y + cos(t) * radius))
					_tube(scrolls, path, .0055, 6)
			for y in [.02, .875]:
				_tube(rods, PackedVector3Array([p - along * .12 + Vector3.UP * y, p + along * .12 + Vector3.UP * y]), .013, 8)
	# Warm oval wood, continuous through the bends rather than independent bars
	# with the wrong slope. Below it is the slim flat iron mounting strip.
	var rounded := _smooth(rail_path, .12)
	_tube(timber, rounded, .037, 12, .68)
	var under := PackedVector3Array()
	for p in rounded:
		under.append(p - Vector3.UP * .03)
	_tube(rods, under, .015, 6, .35)
	# Cylindrical open cage at the stair foot and the spiral wood volute.
	var foot := Vector3(plan.landing[1] + .06, LOWER, plan.turn_z + .075)
	for i in 10:
		var angle: float = TAU * i / 10
		var p := foot + Vector3(cos(angle), 0, sin(angle)) * .105
		_tube(rods, PackedVector3Array([p + Vector3.UP * .035, p + Vector3.UP * .865]), .008, 6)
	for y in [.06, .18, .70, .85]:
		var hoop := PackedVector3Array()
		for i in 25:
			var angle: float = TAU * i / 24
			hoop.append(foot + Vector3(cos(angle) * .11, y, sin(angle) * .11))
		_tube(rods, hoop, .009, 6)
	var volute := PackedVector3Array([rounded[-1]])
	for i in 31:
		var t: float = float(i) / 30
		var angle: float = -PI / 2 - t * TAU * 1.10
		var radius: float = lerpf(.15, .025, t)
		volute.append(foot + Vector3(cos(angle) * radius, RAIL, sin(angle) * radius))
	_tube(timber, _smooth(volute, .035), .037, 12, .68)
	# Wall rails / black brackets at the same stair levels (27.5 / 79.5s).
	var wall_path := PackedVector3Array([
		Vector3(plan.landing[1] + .05, .90, b[3] - .09),
		Vector3(plan.turn_x, float(plan.guards[2].ends[1][1]) + .90, b[3] - .09),
		Vector3(b[1] - .09, float(plan.guards[2].ends[1][1]) + .90, b[3] - .09),
		Vector3(b[1] - .09, float(plan.guards[2].ends[1][1]) + .90, plan.landing[2]),
		Vector3(b[1] - .09, float(plan.guards[3].ends[1][1]) + .90, plan.turn_z),
		Vector3(b[1] - .09, float(plan.guards[3].ends[1][1]) + .90, b[2] + .09),
		Vector3(plan.turn_x, float(plan.guards[3].ends[1][1]) + .90, b[2] + .09),
		Vector3(plan.landing[1] - .10, LOWER + .90, b[2] + .09),
	])
	_tube(timber, _smooth(wall_path, .16), .025, 10, .80)
	for i in range(wall_path.size() - 1):
		var delta := wall_path[i+1]-wall_path[i]
		var horizontal: bool = absf(delta.x)>absf(delta.z)
		var brackets := int(ceil(Vector2(delta.x,delta.z).length()/.8))
		for j in brackets:
			var t: float = (float(j)+.5)/brackets
			var p: Vector3 = wall_path[i].lerp(wall_path[i + 1], t)
			var toward := Vector3(0,0,.065 if p.z>b[3]-.20 else -.065) if horizontal else Vector3(.065,0,0)
			_tube(rods, PackedVector3Array([p - Vector3.UP * .055, p - Vector3.UP * .12, p - Vector3.UP * .12 + toward]), .008, 6)
	_mesh(room, rods, iron, "skylight_balusters")
	_mesh(room, scrolls, iron, "skylight_iron_scrolls")
	var wood: StandardMaterial3D = room.look(Color("926744"))
	wood.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	wood.roughness = .48
	_mesh(room, timber, wood, "skylight_wood_handrails")


# Local closed-mesh helpers: batch the repeated iron and piano parts by material.
func _surface() -> SurfaceTool:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	return st


func _mesh(room, st: SurfaceTool, paint: Material, tag: String) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = st.commit()
	node.material_override = paint
	node.set_meta(tag, true)
	node.set_meta("fine_fidelity_accepted", false)
	room.add_child(node)
	return node


func _quad(st: SurfaceTool, corners: Array, normal: Vector3) -> void:
	var flip: bool = (corners[1] - corners[0]).cross(corners[2] - corners[0]).dot(normal) > 0
	var indices := [0,2,1] if flip else [0,1,2]
	if corners.size() == 4:
		indices.append_array([0,3,2] if flip else [0,2,3])
	for i in indices:
		st.set_normal(normal)
		st.add_vertex(corners[i])


func _prism(st: SurfaceTool, outline: PackedVector2Array, low: float, high: float, at := Vector3.ZERO) -> void:
	if Geometry2D.is_polygon_clockwise(outline):
		outline.reverse()
	var indices := Geometry2D.triangulate_polygon(outline)
	for y in [low, high]:
		var normal := Vector3.DOWN if y == low else Vector3.UP
		for i in range(0, indices.size(), 3):
			var corners := []
			for j in 3:
				var p := outline[indices[i + j]]
				corners.append(at + Vector3(p.x, y, p.y))
			_quad(st, corners, normal)
	for i in outline.size():
		var a := outline[i]
		var b := outline[(i + 1) % outline.size()]
		var normal := Vector3(b.y - a.y, 0, a.x - b.x).normalized()
		_quad(st, [at + Vector3(a.x,low,a.y),at + Vector3(b.x,low,b.y),at + Vector3(b.x,high,b.y),at + Vector3(a.x,high,a.y)], normal)


func _rounded_rectangle(at: Vector2, size: Vector2, radius: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for spec in [[at + Vector2(radius,radius),PI],[at + Vector2(size.x-radius,radius),-PI/2],[at + size - Vector2(radius,radius),0.0],[at + Vector2(radius,size.y-radius),PI/2]]:
		for i in 5:
			var angle: float = spec[1] + PI / 2 * i / 4
			out.append(spec[0] + Vector2(cos(angle),sin(angle)) * radius)
	return out


func _smooth(points: PackedVector3Array, radius := .025) -> PackedVector3Array:
	var out := PackedVector3Array([points[0]])
	for i in range(1, points.size() - 1):
		var p := points[i]
		var a := p.move_toward(points[i - 1], minf(radius,p.distance_to(points[i - 1]) * .35))
		var b := p.move_toward(points[i + 1], minf(radius,p.distance_to(points[i + 1]) * .35))
		out.append(a)
		for j in range(1, 5):
			var t: float = float(j) / 4
			out.append(a * pow(1-t,2) + p * 2*t*(1-t) + b * t*t)
	out.append(points[-1])
	return out


func _tube(st: SurfaceTool, path: PackedVector3Array, radius: float, sides: int, flatten := 1.0) -> void:
	var rings := []
	for i in path.size():
		var tangent := (path[min(i+1,path.size()-1)] - path[maxi(i-1,0)]).normalized()
		var u := tangent.cross(Vector3.UP).normalized()
		if u.length_squared() < .5:
			u = tangent.cross(Vector3.FORWARD).normalized()
		var v := u.cross(tangent).normalized()
		var ring := PackedVector3Array()
		for j in sides:
			var angle: float = TAU * j / sides
			ring.append(path[i] + (u * cos(angle) + v * sin(angle) * flatten) * radius)
		rings.append(ring)
	for i in range(path.size() - 1):
		for j in sides:
			var k: int = (j + 1) % sides
			var n: Vector3 = ((rings[i][j] + rings[i][k]) / 2 - path[i]).normalized()
			_quad(st, [rings[i][j],rings[i][k],rings[i+1][k],rings[i+1][j]], n)
	for index in [0,path.size()-1]:
		var n := (path[0]-path[1]).normalized() if index == 0 else (path[-1]-path[-2]).normalized()
		for j in sides:
			_quad(st, [path[index],rings[index][j],rings[index][(j+1)%sides]],n)


func _lower_exit(room, b: Array, middle: float, width: float, grey: Material, white: Material) -> void:
	# Feldman wall-plane fit (54s): casing top 2.535m above oak, ±.25m.
	var head := 2.40
	var header: StaticBody3D = room.solid(Vector3(middle,(-LOWER+head)/2,b[2]),Vector3(width,-LOWER-head,.12),grey,true)
	header.set_meta("room_wall",ROOM+":north:header")
	room.door_casing(header,"north",b[2],[middle-width/2,middle+width/2],head,.10)
	header.set_meta("source_casing_width",.10)
	header.position.y += LOWER
	# Closed 0.95m doorway study; the footage does not establish a destination
	# or a route beyond it. Folded fire-door leaves have their own hinges.
	var back: Node3D = room.solid(Vector3(middle,LOWER+head/2,b[2]-.95),Vector3(width,head,.04),room.look(Color("262325")))
	back.reparent(header)
	var sill: Node3D = room.solid(Vector3(middle,LOWER+.004,b[2]-.475),Vector3(width,.008,.95),room.look(Color("605f55")))
	sill.reparent(header)
	var metal: Material = room.look(Color("303032"))
	for side in [-1,1]:
		var leaf := Node3D.new()
		room.add_child(leaf)
		leaf.position = Vector3(middle+side*(width/2-.03),LOWER,b[2]-.06)
		leaf.rotation.y = -side*deg_to_rad(65)
		leaf.reparent(header)
		var x: float = -side*(width/2-.04)/2
		var door: Node3D = room.solid(Vector3.ZERO,Vector3(width/2-.04,head-.04,.055),white)
		door.reparent(leaf,false)
		door.position = Vector3(x,(head-.04)/2,0)
		for face in [-1,1]:
			for panel in [[.36,.48],[1.56,1.43]]:
				var inset: Node3D = room.solid(Vector3.ZERO,Vector3(width/2-.22,panel[1],.012),room.look(Color("dadad3")))
				inset.reparent(leaf,false)
				inset.position = Vector3(x,panel[0],face*.034)
				for edge in [-1,1]:
					var stile: Node3D = room.solid(Vector3.ZERO,Vector3(.018,panel[1]+.025,.012),white)
					stile.reparent(leaf,false)
					stile.position = Vector3(x+edge*(width/2-.22)/2,panel[0],face*.044)
					var rail: Node3D = room.solid(Vector3.ZERO,Vector3(width/2-.20,.018,.012),white)
					rail.reparent(leaf,false)
					rail.position = Vector3(x,panel[0]+edge*panel[1]/2,face*.044)
			var push: Node3D = room.solid(Vector3.ZERO,Vector3(width/2-.16,.038,.038),metal)
			push.reparent(leaf,false)
			push.position = Vector3(x,1.00,face*.077)
		for y in [.27,1.17,2.08]:
			var hinge: Node3D = room.solid(Vector3.ZERO,Vector3(.05,.10,.07),metal)
			hinge.reparent(leaf,false)
			hinge.position = Vector3(0,y,0)
	var sign: Node3D = room.solid(Vector3(middle,LOWER+2.68,b[2]+.075),Vector3(.42,.20,.018),room.look(Color.WHITE,"res://modules/shell/prototype/gallery_walk4/textures/exit-sign.svg"))
	sign.reparent(header)
	header.set_meta("skylight_lower_exit",true)


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
# A closed wall feature, as lift 5 is in the connector, on the lower floor west of the landing.
func _lift(room, b: Array, white: Material) -> void:
	var at: Vector3 = room.wall_point(ROOM, "south", 1.55, LOWER, 0)
	var wall: Node3D = room.wall_body(ROOM, "south", at)
	var purple: Material = room.look(Color.WHITE, "res://modules/shell/collection_rooms/presentation/purple-plaster.png")
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
# (IMG_6379 3.0/13.5/132.0s). Maker unread; 1.75 x 1.48 m is provisional.
func _piano(room, b: Array) -> void:
	var black: StandardMaterial3D = room.look(Color("121214"))
	black.roughness = .27
	black.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	var at := Vector3(b[0] + .85, LOWER, b[2] + .35)  # keyboard end, spine side
	var outline := PackedVector2Array([Vector2(.20,0),Vector2(1.35,0)])
	for curve in [
		[Vector2(1.35,0),Vector2(1.79,0),Vector2(1.91,.53),Vector2(1.58,.78)],
		[Vector2(1.58,.78),Vector2(1.36,.94),Vector2(1.04,.78),Vector2(.83,1.02)],
		[Vector2(.83,1.02),Vector2(.65,1.20),Vector2(.69,1.48),Vector2(.38,1.48)],
	]:
		for i in range(1,13):
			var t: float = float(i)/12
			outline.append(curve[0]*pow(1-t,3)+curve[1]*3*t*pow(1-t,2)+curve[2]*3*t*t*(1-t)+curve[3]*t*t*t)
	outline.append(Vector2(.20,1.48))
	# One conservative invisible collider; the visible rim is the closed curved
	# outline, with a separate overhanging lid, cheek blocks and open key bed.
	var center := Vector3(.875,.77,.74)
	var body: StaticBody3D = room.solid(at + center, Vector3(1.75,.42,1.48), black, true)
	body.set_meta("skylight_piano", true)
	var rim := _surface()
	_prism(rim,outline,.58,.94)
	var visible := body.get_child(1) as MeshInstance3D
	visible.mesh = rim.commit()
	visible.position = -center
	var piano := _surface()
	_prism(piano,outline,.953,.976,at)
	_prism(piano,_rounded_rectangle(Vector2(-.17,.02),Vector2(.41,1.44),.018),.648,.685,at)
	for z in [.0,1.36]:
		_prism(piano,_rounded_rectangle(Vector2(-.08,z),Vector2(.32,.12),.022),.68,.94,at)
	_prism(piano,_rounded_rectangle(Vector2(.133,.12),Vector2(.045,1.24),.008),.705,.947,at)
	# Distinct long-lid seam, hinge knuckles and a low music rack. No maker
	# name / invented lettering is added; the object is identified by its form.
	var metal := _surface()
	for x in [.38,.86,1.30]:
		_tube(metal,PackedVector3Array([at+Vector3(x-.025,.96,.004),at+Vector3(x+.025,.96,.004)]),.007,8)
	var seam := PackedVector3Array([at+Vector3(.37,.98,.02),at+Vector3(.37,.98,1.43)])
	_tube(piano,seam,.0035,6)
	_prism(piano,_rounded_rectangle(Vector2(.38,.32),Vector2(.22,.84),.012),.978,.992,at)
	for z in [.36,1.12]:
		_tube(piano,PackedVector3Array([at+Vector3(.40,.996,z),at+Vector3(.59,.996,z)]),.008,6)
	_tube(piano,PackedVector3Array([at+Vector3(.59,.996,.36),at+Vector3(.59,.996,1.12)]),.008,6)
	for z in [.48,.64,.80,.96]:
		_tube(piano,PackedVector3Array([at+Vector3(.40,.996,z),at+Vector3(.59,.996,z)]),.005,6)
	var card: Node3D = room.solid(at+Vector3(.90,1.045,.60),Vector3(.012,.14,.095),black)
	card.reparent(body)  # The small lid card at 13.5s; its illegible wording is omitted.
	# 52 ivory and 36 black keys; A to C, with the real two / three grouping.
	var ivory := _surface()
	var key_pitch := 1.20/52
	for i in 52:
		var z: float = .14+i*key_pitch
		_prism(ivory,_rounded_rectangle(Vector2(-.13,z),Vector2(.25,key_pitch-.0012),.001),.686,.710,at)
		if i < 51 and i%7 in [0,2,3,5,6]:
			_prism(piano,_rounded_rectangle(Vector2(-.015,z+key_pitch-.0065),Vector2(.12,.013),.0015),.711,.738,at)
	# Three tapered turned legs, caster forks / wheels and the pedal lyre.
	for p in [Vector2(.26,.13),Vector2(.26,1.34),Vector2(1.50,.27)]:
		_turned(piano,at+Vector3(p.x,0,p.y),[[.08,.030],[.16,.040],[.22,.038],[.27,.060],[.30,.060],[.33,.044],[.55,.065],[.58,.090],[.62,.090]],10)
		_tube(metal,PackedVector3Array([at+Vector3(p.x,.045,p.y),at+Vector3(p.x,.105,p.y)]),.015,8)
		_tube(piano,PackedVector3Array([at+Vector3(p.x,.041,p.y-.022),at+Vector3(p.x,.041,p.y+.022)]),.034,10)
	for z in [.59,.89]:
		_tube(piano,PackedVector3Array([at+Vector3(.30,.13,z),at+Vector3(.24,.61,z)]),.018,8)
	_prism(piano,_rounded_rectangle(Vector2(.16,.55),Vector2(.23,.38),.035),.12,.18,at)
	for z in [.62,.74,.86]:
		_prism(metal,_rounded_rectangle(Vector2(-.045,z-.016),Vector2(.25,.032),.015),.082,.097,at)
	_mesh(room,piano,black,"skylight_piano_details").reparent(body)
	_mesh(room,ivory,room.look(Color("f2eee0")),"skylight_piano_keys").reparent(body)
	var brass: StandardMaterial3D = room.look(Color("796746"))
	brass.metallic = .70
	brass.roughness = .35
	brass.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	_mesh(room,metal,brass,"skylight_piano_hardware").reparent(body)
	var bench: StaticBody3D = room.solid(at + Vector3(-.48,.47,.74),Vector3(.38,.08,.80),black,true)
	bench.set_meta("skylight_piano_bench", true)
	var leather: StandardMaterial3D = black.duplicate()
	leather.roughness = .70
	var cushion := _surface()
	_prism(cushion,_rounded_rectangle(Vector2(-.67,.34),Vector2(.38,.80),.035),.45,.51,at)
	var top := bench.get_child(1) as MeshInstance3D
	top.mesh = cushion.commit()
	top.position = -Vector3(-.48,.47,.74)
	top.material_override = leather
	var stool := _surface()
	_prism(stool,_rounded_rectangle(Vector2(-.66,.35),Vector2(.36,.78),.025),.410,.45,at)
	for x in [-.14, .14]:
		for z in [-.34, .34]:
			_turned(stool,at+Vector3(-.48+x,0,.74+z),[[.025,.021],[.08,.027],[.14,.026],[.20,.034],[.25,.029],[.40,.040],[.43,.045]],8)
	for x in [-.56,-.40]:
		for z in [.49,.66,.83,1.0]:
			_tube(stool,PackedVector3Array([at+Vector3(x,.509,z),at+Vector3(x,.511,z)]),.006,6)
	var piping := PackedVector3Array()
	for p in _rounded_rectangle(Vector2(-.671,.339),Vector2(.382,.802),.036):
		piping.append(at+Vector3(p.x,.484,p.y))
	piping.append(piping[0])
	_tube(stool,piping,.004,6)
	_mesh(room,stool,black,"skylight_piano_bench_details").reparent(bench)


func _turned(st: SurfaceTool, at: Vector3, profile: Array, sides: int) -> void:
	for i in range(profile.size()-1):
		var a: Array = profile[i]
		var b: Array = profile[i+1]
		for j in sides:
			var aa: float = TAU*j/sides
			var bb: float = TAU*(j+1)/sides
			var normal := Vector3(cos((aa+bb)/2),(float(a[1])-float(b[1]))/(float(b[0])-float(a[0])),sin((aa+bb)/2)).normalized()
			_quad(st,[at+Vector3(cos(aa)*a[1],a[0],sin(aa)*a[1]),at+Vector3(cos(bb)*a[1],a[0],sin(bb)*a[1]),at+Vector3(cos(bb)*b[1],b[0],sin(bb)*b[1]),at+Vector3(cos(aa)*b[1],b[0],sin(aa)*b[1])],normal)
	for row in [profile[0],profile[-1]]:
		for j in sides:
			var aa: float = TAU*j/sides
			var bb: float = TAU*(j+1)/sides
			_quad(st,[at+Vector3(0,row[0],0),at+Vector3(cos(aa)*row[1],row[0],sin(aa)*row[1]),at+Vector3(cos(bb)*row[1],row[0],sin(bb)*row[1])],Vector3.DOWN if row==profile[0] else Vector3.UP)
