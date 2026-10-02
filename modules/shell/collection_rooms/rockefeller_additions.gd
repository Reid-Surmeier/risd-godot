## Rockefeller additions (#238): the Vincennes river-god pair on the central pedestal, the two Mary
## Smirke watercolours under the west sconce, the silk length above the armchair, label cards and the
## exit sign. Sizes are the RISD catalogue's; positions are read from IMG_6380 and are provisional.
extends RefCounted

const Grey := preload("res://modules/shell/collection_rooms/grey_additions.gd")
const DIR := "res://modules/shell/collection_rooms/assets/additions/rockefeller/"
const ROOM := "Rockefeller"


func build(room) -> void:
	vincennes(room)
	watercolours(room)
	textile(room)
	# IMG_6380 238.5..242.5s: green exit sign over the door to the connector.
	var b: Array = room.room_bounds(ROOM)
	var door: Array = []
	for area in room._plan_rooms:
		if area.label == ROOM:
			door = area.openings.east
	var sign: Node3D = room.solid(room.wall_point(ROOM, "east", (door[0] + door[1]) / 2 - b[2], 3.02, .09), Vector3(.05, .2, .36), room.look(Color("86e39a"), "", true))
	sign.reparent(room.wall_body(ROOM, "east", sign.position))
	room.inventory["rockefeller_additions"] = {"vincennes_pair": true, "smirke_watercolours": 2, "silk_length": true, "placement_accepted": false}


func vincennes(room) -> void:
	# IMG_6380 123.5s, 223.5..226.5s: two white biscuit groups on the central pedestal, which
	# build_displays already makes (1.1 x 1.1 x .65). Which way they face is by eye.
	var pedestal: Node3D
	for body in room.casings:
		var shape = body.get_child(0).shape
		if shape is BoxShape3D and shape.size.is_equal_approx(Vector3(1.1, 1.1, .65)):
			pedestal = body
	assert(pedestal != null, "The central pedestal must exist before its porcelain")
	var top: Vector3 = pedestal.global_position + Vector3(0, .55, 0)
	for spec in [["neptune-2017.74.31.1", -.24, "2017.74.31.1", "Neptune as River Deity", "29.8 x 27 x 24 cm"],
			["amphitrite-2017.74.31.2", .24, "2017.74.31.2", "Amphitrite as River Deity", "29.8 x 28 x 19 cm"]]:
		var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DIR + spec[0] + "-cut.json"))
		var group: MeshInstance3D = Grey.volume(data, load(DIR + spec[0] + "-cut.png"))
		room.add_child(group)
		group.position = top + Vector3(spec[1], 0, 0)
		Grey.describe(group, {"accession": spec[2], "title": spec[3], "maker": "Vincennes Porcelain Manufactory", "date": "1745-1750",
			"medium": "Soft-paste porcelain with glaze", "dimensions": spec[4], "image": DIR + spec[0] + ".jpg"})
	Grey.card(room, pedestal, Vector3(0, .25, .327))


func watercolours(room) -> void:
	# IMG_6380 187.5..191.5s: stacked under the sconce west of the gallery door, in gilt frames with
	# wide cream mounts; their labels hang on the door side. Frame and mount sizes are by eye.
	var sconce_x := 0.0
	for node in room.get_children():
		if node.get_meta("catalogue_asset", "") == "sconce-right":
			sconce_x = node.global_position.x
	var b: Array = room.room_bounds(ROOM)
	for spec in [["smirke-2016.80.89", 1.70, Vector2(.245, .166), "2016.80.89", "Cloisters' Wood", "16.6 x 24.5 cm"],
			["smirke-2016.80.91", 1.25, Vector2(.212, .13), "2016.80.91", "A Lady in a Park", "13 x 21.2 cm"]]:
		var art := Node3D.new()
		room.add_child(art)
		art.position = room.wall_point(ROOM, "south", sconce_x - b[0], spec[1], .07)
		art.rotation.y = PI
		var frame: Node3D = room.solid(Vector3.ZERO, Vector3(.50, .40, .03), room.look(Color("b8944a")))
		frame.reparent(art, false)
		frame.position = Vector3(0, 0, .015)
		flat(room, art, Vector2(.46, .36), .031, room.look(Color("efe9da")))
		flat(room, art, spec[2], .033, room.look(Color.WHITE, DIR + spec[0] + ".jpg", true))
		Grey.describe(art, {"accession": spec[3], "title": spec[4], "maker": "Mary Smirke", "date": "1800-1835",
			"medium": "Watercolor on paper", "dimensions": spec[5], "image": DIR + spec[0] + ".jpg",
			"identified": "label name read in IMG_6380 188.2s; both sheets matched by eye to the catalogue photographs"})
		Grey.card(room, art, Vector3(-.42, 0, .01))
		art.reparent(room.wall_body(ROOM, "south", art.position))


func textile(room) -> void:
	# IMG_6380 130.5..136.5s, 195.5s: a silk length on a white board above the pierced-back armchair.
	# The acrylic box over it is not built. Board size and height are by eye.
	var chair_z := 0.0
	for node in room.get_children():
		if node is Node3D and node.global_position.distance_to(Vector3(-4.15, .13, -.51)) < .01:
			chair_z = node.global_position.z
	var b: Array = room.room_bounds(ROOM)
	var art := Node3D.new()
	room.add_child(art)
	art.position = room.wall_point(ROOM, "west", (chair_z if chair_z != 0.0 else -.51) - .7 - b[2], 2.17, .07)
	art.rotation.y = PI / 2
	var board: Node3D = room.solid(Vector3.ZERO, Vector3(.85, 1.45, .02), room.look(Color("efede6")))
	board.reparent(art, false)
	board.position = Vector3(0, 0, .01)
	flat(room, art, Vector2(.53, .997), .022, room.look(Color.WHITE, DIR + "textile-44.226.jpg", true))
	Grey.describe(art, {"accession": "44.226", "title": "Apparel textile length", "maker": "Unknown maker, English", "date": "1705-1715",
		"medium": "Silk damask weave with silk- and metallic-thread weft brocading", "dimensions": "Length: 99.7 cm",
		"image": DIR + "textile-44.226.jpg", "identified": "matched by eye to IMG_6380 135.0s and 195.6s; width from the photograph's proportion"})
	art.reparent(room.wall_body(ROOM, "west", art.position))


## A flat picture `out` metres in front of its parent's wall plane.
static func flat(room, parent: Node3D, size: Vector2, out: float, material: Material) -> void:
	var x := size.x / 2
	var y := size.y / 2
	room.panel(parent, [Vector3(-x, -y, out), Vector3(x, -y, out), Vector3(x, y, out), Vector3(-x, y, out)],
		[Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)], material)
