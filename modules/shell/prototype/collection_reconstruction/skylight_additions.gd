## Skylight Gallery (#238), first version: the room behind the grey gallery's north door.
## IMG_6379 shows a double-height room. The door opens on an upper landing; a black stair runs
## round the east end down to the floor with the piano, a storey (about 3.3 m) lower.
## ponytail: the visitor cannot change level, so the whole footprint is built at the door's level
## and the stair, landing, lift and lower doors are left out. Split the levels when the walk can.
## Sizes: structure-from-motion fit of IMG_6379 scaled by the Diao canvas (69.094, 2.21 m wide);
## docs/evidence/museum-238/skylight/NOTES.md has every number, its frame and its confidence.
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
	# The door wall is a deep panelled reveal with both leaves folded in it (IMG_6379 169..182s).
	# ponytail: the Hall reveal's builder, so the knobs sit at the grey gallery end; the footage hinges
	# these leaves on that side. Give the leaves their own hang when the door is fitted.
	room.build_reveal(REVEAL, true)
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
	room.inventory["skylight_gallery"] = {"works": WORKS.size(), "piano": true, "levels_built": 1, "levels_in_footage": 2, "metric_accepted": false, "placement_accepted": false}


# Lift 4: cream doors in a purple reveal under the strip that names the room (IMG_6379 8.0..9.4s).
# A closed wall feature, as lift 5 is in the connector. ponytail: it stands on the lower floor in
# the footage, in the south wall west of the landing; here it is at the door's level.
func _lift(room, b: Array, white: Material) -> void:
	var at: Vector3 = room.wall_point(ROOM, "south", 1.55, 0, 0)
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
	var at := Vector3(b[0] + .85, 0, b[2] + .35)  # keyboard end, spine side
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
