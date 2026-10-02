## European gallery ("adjacent gallery"), west wall and both end walls (#238).
## Order and identities: IMG_6384, IMG_6385, IMG_6386 (docs/evidence/museum-238/european-west/NOTES.md).
## Sizes are the catalogue's (assets/additions/european-west/records.json); every position is
## provisional. From the south-west corner to the Guardi pair the distances come from one camera
## solve of the three clips scaled by the Fetti and Tironi frames; the north group and both end
## walls are placed by wall order and catalogue widths only.
## ponytail: free-standing objects are flat cut-outs of their catalogue photograph, not volumes.
extends RefCounted

const Painting := preload("res://modules/shell/prototype/gallery_walk4/painting_asset.gd")
const DIR := "res://assets/additions/european-west/"
const HALL := "res://modules/shell/prototype/gallery_walk4/"
const GALLERY := "adjacent gallery"
const FACE := .065 # the wall's visible face stands .061 inside the room bound
const YAW := {"west": PI / 2, "north": 0.0, "south": PI}
const LABEL := Vector2(.17, .30) # the brief's card, upright as every label in this room is
const SQUARE := [[0, 0], [1, 0], [1, 1], [0, 1]]

var room
var cuts: Dictionary
var records: Dictionary
var hall_margins := {}
var white: Material
var glass: Material

func build(target) -> void:
	room = target
	cuts = JSON.parse_string(FileAccess.get_file_as_string(DIR + "cutouts.json"))
	records = JSON.parse_string(FileAccess.get_file_as_string(DIR + "records.json"))
	for row in JSON.parse_string(FileAccess.get_file_as_string(HALL + "works.json")):
		if row.has("margins_px"):
			hall_margins[row.tag] = row.margins_px
	white = room.look(Color("f0eeea"))
	glass = room.look(Color(.82, .90, .91, .10), "", true)
	west_wall()
	south_wall()
	north_wall()
	room.inventory["european_west"] = {"identified_works": records.size(), "metric_accepted": false, "placement_accepted": false, "objects_are_flat_cutouts": true}

# ---- the three walls -------------------------------------------------------------------------

func west_wall() -> void:
	var b: Array = room.room_bounds(GALLERY)
	var length: float = b[3] - b[2]
	# South group: metres from the south wall, read off the camera solve (NOTES.md).
	var knocker := holder("west", length - 3.0, 1.60)
	part(knocker, Vector3(0, 0, .01), Vector3(.45, .56, .02), white)
	tag(cutout(knocker, "knocker-55.091", .394, Vector3(0, 0, .02), .10), "knocker-55.091")
	hood(knocker, Vector3(0, 0, .09), Vector3(.47, .58, .17))
	label(knocker, .40, -.05)
	attach(knocker, "west")
	# 6384 26.5..30s: two small plates in wide white mounts, one two-entry label after the second.
	# Which plate hangs first is not legible: order provisional.
	var first := matted("west", length - 4.10, 1.60, "kussell-2024.17.5", Vector2(.119, .080), Vector2(.62, .47), .025, Color("1c1b1b"))
	var second := matted("west", length - 4.85, 1.60, "kussell-2024.17.6", Vector2(.122, .081), Vector2(.62, .47), .025, Color("1c1b1b"))
	label(second, .46, -.05)
	attach(first, "west")
	attach(second, "west")
	# 6386 20.5..23s: two upright etchings, the fruit seller on the left.
	var fruit := matted("west", length - 7.61, 1.72, "zompini-67.106.31", Vector2(.178, .259), Vector2(.40, .50), .025, Color("1c1b1b"))
	var hawker := matted("west", length - 8.15, 1.72, "zompini-67.106.8", Vector2(.183, .259), Vector2(.40, .50), .025, Color("1c1b1b"))
	label(hawker, .34, -.08)
	attach(fruit, "west")
	attach(hawker, "west")
	textile_and_case(length - 9.47)
	# 6386 36..39.5s: plain gilt cove frame; nearest existing asset is the Hall's W10.
	var canal = framed("west", length - 12.66, 1.75, "tironi-42.042", Vector2(.838, .518), HALL + "frames/W10.png", hall_margins["W10"])
	label(canal, canal.outer.x / 2 + .17, -.10)
	attach(canal, "west")
	# 6386 46.5..52.5s: stacked pair, one label with two entries beside the lower painting.
	# Nearest existing frames: W2 (carved, straight rails) above, W7 (swept, shell centres) below.
	var ridotto = framed("west", length - 14.08, 1.55, "guardi-24.508", Vector2(.511, .314), HALL + "frames/W7.png", hall_margins["W7"])
	var scuola = framed("west", length - 14.08, 1.55 + ridotto.outer.y / 2 + .06, "guardi-53.115", Vector2(.324, .387), HALL + "frames/W2.png", hall_margins["W2"])
	scuola.position.y += scuola.outer.y / 2
	label(ridotto, ridotto.outer.x / 2 + .17, 0)
	attach(ridotto, "west")
	attach(scuola, "west")
	# North group, by wall order from the Rockefeller door (IMG_6385): dress case, secretary on the
	# same low platform, the Piranesi, then the Delacroix (moved in build_adjacent_gallery).
	room.solid(room.wall_point(GALLERY, "west", 1.325, .065, .525), Vector3(1.05, .13, 2.65), white, true)
	dress_case(room.wall_point(GALLERY, "west", .62, .13, .55))
	var egypt := matted("west", 3.30, 1.72, "piranesi-63.066.45", Vector2(.325, .238), Vector2(.72, .52), .025, Color("1c1b1b"))
	label(egypt, .52, -.06)
	attach(egypt, "west")
	# The existing works keep their builders; they get the label the footage shows on their right.
	for spec in [[b[2] + 5.05, .70], [b[3] - 11.14, .70], [b[3] - 6.09, .40]]:
		var card: Node3D = room.solid(Vector3(b[0] + FACE, 1.62, spec[0] - spec[1]), Vector3(.004, LABEL.y, LABEL.x), room.look(Color("f3f2ed")))
		card.set_meta("artwork_label_proxy", true)
		card.reparent(room.wall_body(GALLERY, "west", card.position))

func textile_and_case(along: float) -> void:
	# 6386 24.5..28.5s: embroidered panel on a white board behind acrylic, over a white floor
	# pedestal with an acrylic hood and five objects.
	var board := holder("west", along, 1.96)
	part(board, Vector3(0, 0, .012), Vector3(1.0, .80, .024), white)
	var panel := Painting.new()
	board.add_child(panel)
	panel.build_shaped(load(DIR + "textile-85.075.6.jpg"), Vector2(.572 * float(cuts["textile-85.075.6"].aspect), .572), SQUARE, Color("b9ab8b"))
	panel.scale.z = .1
	panel.position.z = .024
	tag(panel, "textile-85.075.6")
	part(board, Vector3(0, 0, .05), Vector3(1.0, .80, .006), glass)
	label(board, .62, -.20)
	attach(board, "west")
	var at: Vector3 = room.wall_point(GALLERY, "west", along, 0, .061 + .225)
	var pedestal: Node3D = room.solid(at + Vector3(0, .5, 0), Vector3(.45, 1.0, 1.0), white, true)
	var deck := Node3D.new()
	room.add_child(deck)
	deck.position = at + Vector3(0, 1.0, 0)
	deck.rotation.y = PI / 2
	hood(deck, Vector3(0, .225, 0), Vector3(.98, .45, .43), true)
	for riser in [Vector3(-.17, .03, -.08), Vector3(.36, .03, -.10)]:
		part(deck, riser, Vector3(.16, .06, .16), white)
	# Left to right as filmed: jug, covered glass on a riser, crystal cup, blue bowl, owl on a riser.
	for spec in [["jug-47.625", .241, Vector3(-.36, 0, .08)], ["cup-45.188", .205, Vector3(-.17, .06, -.08)], ["cup-32.010", .20, Vector3(-.03, 0, .10)], ["bowl-73.060", .127, Vector3(.17, 0, .04)], ["owl-52.533", .229, Vector3(.36, .06, -.10)]]:
		tag(cutout(deck, spec[0], spec[1], spec[2] + Vector3(0, spec[1] / 2, 0), .02), spec[0])
	deck.reparent(pedestal)

func dress_case(at: Vector3) -> void:
	# 6385 2..5.5s: tall glass case on its own white base, on the platform, in the corner.
	var base: Node3D = room.solid(at + Vector3(0, .06, 0), Vector3(.66, .12, .80), white, true)
	var inside := Node3D.new()
	room.add_child(inside)
	inside.position = at + Vector3(0, .12, 0)
	inside.rotation.y = PI / 2
	hood(inside, Vector3(0, .875, 0), Vector3(.74, 1.75, .60), true)
	part(inside, Vector3(0, 1.755, 0), Vector3(.76, .012, .62), room.look(Color("33353a")))
	part(inside, Vector3(0, .01, 0), Vector3(.34, .02, .30), room.look(Color("3a3b40")))
	tag(cutout(inside, "dress-2000.103.3", 1.50, Vector3(0, .77, -.015), .03), "dress-2000.103.3")
	inside.reparent(base)

func south_wall() -> void:
	# 6384 0..4s, 12..21s. East of the door: Apollo in a wall case, then the Previtali; west of it
	# the tabernacle on a tall pedestal. Offsets along the wall are by eye from those frames.
	var b: Array = room.room_bounds(GALLERY)
	var apollo := holder("south", 4.65, 1.20)
	part(apollo, Vector3(0, -.05, .14), Vector3(.44, .10, .28), white)
	hood(apollo, Vector3(0, .225, .14), Vector3(.40, .45, .26))
	tag(cutout(apollo, "apollo-73.079", .21, Vector3(0, .105, .13), .02), "apollo-73.079")
	label(apollo, -.38, .30)
	attach(apollo, "south")
	# Gilt tabernacle frame with a cornice and a base: nearest existing asset is the Perugino's.
	var frame: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/perugino-frame-geometry.json"))
	var risen = framed("south", 5.50, 1.62, "previtali-16.237", Vector2(.26, .292), "res://assets/perugino-frame.png", frame.margins_px)
	label(risen, -(risen.outer.x / 2 + .15), -.02)
	attach(risen, "south")
	var at: Vector3 = room.wall_point(GALLERY, "south", 1.20, 0, .061 + .17)
	var pedestal: Node3D = room.solid(at + Vector3(0, .51, 0), Vector3(.80, 1.02, .32), room.look(Color("dcdad4")), true)
	var relief := Node3D.new()
	room.add_child(relief)
	relief.position = at + Vector3(0, 1.02, .06)
	relief.rotation.y = PI
	tag(cutout(relief, "tabernacle-06.057", .508, Vector3(0, .254, 0), .15), "tabernacle-06.057")
	relief.reparent(pedestal)
	var card: Node3D = room.solid(room.wall_point(GALLERY, "south", 1.72, 1.20, FACE), Vector3(.12, .20, .004), room.look(Color("f3f2ed")))
	card.set_meta("artwork_label_proxy", true)
	card.reparent(room.wall_body(GALLERY, "south", card.position))
	exit_sign("south", (b[1] - b[0]) / 2)

func north_wall() -> void:
	# 6385 0..8s west of the door; 6384 100.5..103.5s east of it.
	var b: Array = room.room_bounds(GALLERY)
	var wolff := matted("north", 1.40, 1.62, "lawrence-42.072", Vector2(.241, .222), Vector2(.42, .40), .018, Color("7d6230"))
	label(wolff, -.36, -.03)
	attach(wolff, "north")
	var top := holder("north", 5.10, 1.82)
	part(top, Vector3(0, 0, .012), Vector3(.76, .76, .024), white)
	var disc := Painting.new()
	top.add_child(disc)
	var ring: Array = []
	for i in 40:
		ring.append([.5 + .5 * cos(i * TAU / 40), .5 + .5 * sin(i * TAU / 40)])
	disc.build_shaped(load(DIR + "mosaic-1990.060.jpg"), Vector2(.597, .597), ring, Color("26241f"))
	disc.scale.z = .6
	disc.position.z = .024
	tag(disc, "mosaic-1990.060")
	hood(top, Vector3(0, 0, .05), Vector3(.78, .78, .10))
	label(top, -.56, -.10)
	# Shelf case under it: white tray, sloped label deck, acrylic hood. Its small objects are not built.
	part(top, Vector3(0, -.80, .21), Vector3(.86, .10, .42), white)
	var deck := part(top, Vector3(0, -.70, .22), Vector3(.76, .012, .34), white)
	deck.rotation.x = .30
	hood(top, Vector3(0, -.60, .21), Vector3(.80, .30, .38))
	attach(top, "north")
	exit_sign("north", (b[1] - b[0]) / 2)

# ---- pieces ----------------------------------------------------------------------------------

func place(node: Node3D, side: String, along: float, height: float) -> void:
	node.position = room.wall_point(GALLERY, side, along, height, FACE)
	node.rotation.y = YAW[side]

func holder(side: String, along: float, height: float) -> Node3D:
	var node := Node3D.new()
	room.add_child(node)
	place(node, side, along, height)
	return node

func part(parent: Node3D, at: Vector3, size: Vector3, m: Material) -> Node3D:
	var piece: Node3D = room.solid(Vector3.ZERO, size, m)
	piece.reparent(parent, false)
	piece.position = at
	return piece

func framed(side: String, along: float, height: float, key: String, canvas: Vector2, frame: String, margins: Array) -> Node3D:
	var painting := Painting.new()
	room.add_child(painting)
	painting.build_framed(load(frame), load(DIR + key + ".jpg"), canvas, margins)
	place(painting, side, along, height)
	tag(painting, key)
	return painting

## A print or drawing: plate at catalogue size on a white mount inside a plain moulding of `band`.
func matted(side: String, along: float, height: float, key: String, plate: Vector2, outer: Vector2, band: float, colour: Color) -> Node3D:
	var node := holder(side, along, height)
	part(node, Vector3(0, 0, .010), Vector3(outer.x - band, outer.y - band, .012), room.look(Color("f3efe4")))
	var half := plate / 2
	room.panel(node, [Vector3(-half.x, -half.y, .018), Vector3(half.x, -half.y, .018), Vector3(half.x, half.y, .018), Vector3(-half.x, half.y, .018)],
		[Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0)], Painting.mat(load(DIR + key + ".jpg")))
	var moulding: Material = room.look(colour)
	for side_sign in [-1, 1]:
		part(node, Vector3(side_sign * (outer.x - band) / 2, 0, .015), Vector3(band, outer.y, .03), moulding)
		part(node, Vector3(0, side_sign * (outer.y - band) / 2, .015), Vector3(outer.x - 2 * band, band, .03), moulding)
	tag(node, key)
	return node

## The object's catalogue photograph cut to its outline, `height` tall, centred on `at`.
func cutout(parent: Node3D, key: String, height: float, at: Vector3, depth: float) -> Node3D:
	var cut: Dictionary = cuts[key]
	var shape := Painting.new()
	parent.add_child(shape)
	shape.build_shaped(load(DIR + key + ".jpg"), Vector2(height * float(cut.aspect), height), cut.get("outline", SQUARE), Color("6b6558"))
	shape.scale.z = depth / .05
	shape.position = at
	return shape

## Five acrylic panes around `centre`; `all_round` adds the back for a case that stands free.
func hood(parent: Node3D, centre: Vector3, size: Vector3, all_round := false) -> void:
	for x in [-1, 1]:
		part(parent, centre + Vector3(x * size.x / 2, 0, 0), Vector3(.008, size.y, size.z), glass)
	for z in ([-1, 1] if all_round else [1]):
		part(parent, centre + Vector3(0, 0, z * size.z / 2), Vector3(size.x, size.y, .008), glass)
	part(parent, centre + Vector3(0, size.y / 2, 0), Vector3(size.x, .008, size.z), glass)

func label(parent: Node3D, x: float, y: float) -> void:
	var card := part(parent, Vector3(x, y, .002), Vector3(LABEL.x, LABEL.y, .004), room.look(Color("f3f2ed")))
	card.set_meta("artwork_label_proxy", true)

func attach(node: Node3D, side: String) -> void:
	node.reparent(room.wall_body(GALLERY, side, node.global_position))

func tag(node: Node3D, key: String) -> void:
	var record: Dictionary = records[key]
	node.set_meta("catalogue_accession", record.accession)
	node.set_meta("catalogue_asset", key)
	node.set_meta("catalogue_title", record.title)
	node.set_meta("catalogue_maker", record.maker)
	node.set_meta("catalogue_date", record.date)
	node.set_meta("catalogue_medium", record.medium)
	node.set_meta("catalogue_dimensions", record.dimensions)
	node.set_meta("catalogue_image", DIR + key + ".jpg")
	node.set_meta("placement_accepted", false)

func exit_sign(side: String, along: float) -> void:
	# 6384 12..14.5s, 6386 66.5s: green lit EXIT over each end door, on the gallery side.
	var node := holder(side, along, 3.04)
	part(node, Vector3(0, 0, .02), Vector3(.42, .20, .04), room.look(Color("2c5a3c")))
	var text := Label3D.new()
	text.text = "EXIT"
	text.font_size = 48
	text.pixel_size = .0026
	text.modulate = Color("8dfab4")
	text.position = Vector3(0, 0, .042)
	node.add_child(text)
	for wall in room.casings:
		if wall.get_meta("room_wall", "") == GALLERY + ":" + side + ":header":
			node.reparent(wall)
