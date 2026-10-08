## European gallery ("adjacent gallery"), #238: the east wall and the five floor pieces.
## First version under a time box. Identities are catalogue records matched by eye against the footage
## (docs/evidence/museum-238/european-east/NOTES.md); positions are provisional.
## Distances are real metres from the south wall (s) and from the east wall (e), read from the footage
## through the survey reconstruction. The real room came out about 5.8 x 21.2 m against the build's
## 6.1 x 26.3, so every position is laid in by its fraction of the real room: correct the shell and
## the works land on their measured metres.
extends RefCounted

const Painting := preload("res://modules/shell/prototype/gallery_walk4/painting_asset.gd")
const ROOM := "adjacent gallery"
const DIR := "res://modules/shell/collection_rooms/assets/additions/european-east/"
const REAL := Vector2(5.8, 21.2) # width measured wall to wall; length inferred, the north wall is not in the reconstruction
const LABEL := Vector3(.006, .17, .30) # the brief's 0.30 x 0.17 card; the footage's cards are upright, about 0.18 x 0.30
const SQUARE := [[0, 0], [1, 0], [1, 1], [0, 1]]

var room
var b: Array
var wall: Node3D
var white: Material
var glass: Material

func build(r) -> void:
	room = r
	b = room.room_bounds(ROOM)
	wall = room.wall_body(ROOM, "east", Vector3(b[1], 1.5, (b[2] + b[3]) / 2))
	white = room.look(Color("f0eeea"))
	glass = room.look(Color(.82, .90, .91, .10), "", true)
	build_wall()
	build_platform()
	build_floor()
	room.inventory["european_east"] = {"wall_works": 13, "floor_pieces": 5, "real_room_m": [REAL.x, REAL.y], "placement_accepted": false, "frames_accepted": false}

## Real metres from the south and east walls -> room-scene point, by fraction of the real room.
func at(s: float, e: float, h := 0.0) -> Vector3:
	return Vector3(b[1] - e / REAL.x * (b[1] - b[0]), h, b[3] - s / REAL.y * (b[3] - b[2]))

func on_wall(s: float, h: float, out := .065) -> Vector3:
	return room.wall_point(ROOM, "east", (1.0 - s / REAL.y) * (b[3] - b[2]), h, out)

func tag(node: Node, key: String, row: Array, image: String, identified := true) -> void:
	# row: accession, title, maker, date, medium, dimensions
	if row[0] != "":
		node.set_meta("catalogue_accession" if identified else "catalogue_candidate", row[0])
	node.set_meta("catalogue_asset", "european-east-" + key)
	node.set_meta("catalogue_title", row[1])
	node.set_meta("catalogue_maker", row[2])
	node.set_meta("catalogue_date", row[3])
	node.set_meta("catalogue_medium", row[4])
	node.set_meta("catalogue_dimensions", row[5])
	if image != "":
		node.set_meta("catalogue_image", DIR + image)
	node.set_meta("catalogue_identified", identified)
	node.set_meta("placement_accepted", false)

func framed(frame_key: String, image: String, canvas: Vector2) -> Node3D:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://modules/shell/collection_rooms/assets/" + frame_key + "-geometry.json"))
	var p := Painting.new()
	room.add_child(p)
	p.build_framed(load("res://modules/shell/collection_rooms/assets/" + frame_key + ".png"), load(DIR + image), canvas, data.margins_px)
	return p

func slab(image: String, size: Vector2, outline: Array = SQUARE, edge := Color("7c6038")) -> Node3D:
	var p := Painting.new()
	room.add_child(p)
	p.build_shaped(load(DIR + image), size, outline, edge)
	return p

func hang(node: Node3D, s: float, h: float) -> void:
	node.position = on_wall(s, h)
	node.rotation.y = -PI / 2
	node.reparent(wall)

## A blank card south of a work (the side the footage shows), centre 1.40 m up.
func label(s: float, half_width: float) -> void:
	var card: Node3D = room.solid(on_wall(s - (half_width + .10 + LABEL.z / 2) * REAL.y / (b[3] - b[2]), 1.40, .064), LABEL, room.look(Color("e9e4d4")))
	card.set_meta("artwork_label_proxy", true)
	card.reparent(wall)

func build_wall() -> void:
	# key, [accession, title, maker, date, medium, dimensions], image, canvas m, existing frame asset, s, centre height
	var paintings := [
		["perseus", ["57.167", "Perseus and Andromeda", "Giuseppe Cesari, called Cavaliere d'Arpino", "ca. 1592", "Oil on slate", "70.5 x 54.9 cm"], "painting-57.167.jpg", Vector2(.549, .705), "romany-frame", 1.20, 1.565],
		["poussin", ["54.186", "Venus and Adonis", "Nicolas Poussin", "ca. 1628", "Oil on canvas", "76.2 x 101 cm"], "painting-54.186.jpg", Vector2(1.01, .762), "bertin-frame", 3.77, 1.57],
		["crucifixion", ["69.197", "Crucifixion", "Unknown Maker, Spanish", "ca. 1490", "Tempera and gold on panel", "143.8 x 113 cm"], "painting-69.197.jpg", Vector2(1.13, 1.438), "matisse-frame", 7.49, 1.573],
		["longhi", ["34.1371", "A Meal at Home", "Pietro Longhi", "ca. 1753", "Oil on canvas", "61.9 x 50.5 cm"], "painting-34.1371.jpg", Vector2(.505, .619), "romany-frame", 10.72, 1.56],
		["mengs", ["57.281", "Portrait of an English Gentleman", "Anton Raphael Mengs", "ca. 1754", "Oil on canvas", "99.1 x 73.3 cm"], "painting-57.281.jpg", Vector2(.733, .991), "edwards-frame", 12.16, 1.55],
		["reynolds", ["53.349", "A Caricature Group: Sir Charles Turner, Mr. Cook, Mr. John Woodyeare, and Rev. Dr. William Drake", "Joshua Reynolds", "ca. 1751", "Oil on canvas", "62.9 x 48.3 cm"], "painting-53.349.jpg", Vector2(.483, .629), "fetti-frame", 13.49, 1.56],
	]
	for row in paintings:
		var p = framed(row[4], row[2], row[3])
		tag(p, row[0], row[1], row[2])
		hang(p, row[5], row[6])
		label(row[5], p.outer.x / 2)
	# The record's own photographs of these two show the frame; hung as one slab at the footage's outer size.
	var slabs := [
		["adoration", ["21.482", "The Adoration of the Magi", "Unknown Maker, Netherlandish", "ca. 1510", "Oil on wood panel", "52.1 x 34.6 cm"], "framed-21.482.jpg", Vector2(.52, .80), 5.85, 1.595, "painting-21.482.jpg"],
		["vigee", ["2025.86", "Portrait of an Artist", "Elisabeth Louise Vigée Le Brun", "ca. 1773", "Oil on canvas", "55.6 x 46 cm"], "framed-2025.86.jpg", Vector2(.705, .80), 20.45, 1.56, "painting-2025.86.jpg"],
	]
	for row in slabs:
		var p := slab(row[2], row[3])
		tag(p, row[0], row[1], row[6]) # the detail view gets the unframed photograph
		hang(p, row[4], row[5])
		label(row[4], row[3].x / 2)
	# After Bruegel: black frame, white mount, the plate at catalogue size.
	var print_at := on_wall(2.27, 1.57)
	var frame: Node3D = room.solid(print_at + Vector3(-.012, 0, 0), Vector3(.03, .432, .573), room.look(Color("1b1a19")))
	frame.reparent(wall)
	var mount: Node3D = room.solid(print_at + Vector3(-.029, 0, 0), Vector3(.004, .382, .525), room.look(Color("efece4")))
	mount.reparent(frame)
	var plate := slab("print-84.198.1032.jpg", Vector2(.346, .276), SQUARE, Color("d8d2c2"))
	plate.position = print_at + Vector3(-.031, 0, 0)
	plate.rotation.y = -PI / 2
	plate.scale.z = .04
	tag(plate, "bruegel-print", ["84.198.1032", "River Landscape with Mercury Abducting Psyche", "After Pieter Bruegel I", "ca. 1595", "Etching on paper", "Plate 27.6 x 34.6 cm"], "print-84.198.1032.jpg")
	plate.reparent(frame)
	label(2.27, .29)
	# Cloth of Gold in its white mount. Catalogue gives the length only; width from the photograph's proportion.
	var cloth_at := on_wall(9.22, 1.566)
	var board: Node3D = room.solid(cloth_at + Vector3(-.015, 0, 0), Vector3(.04, 1.40, .80), white)
	board.reparent(wall)
	var cloth := slab("textile-46.256.jpg", Vector2(.562, 1.295), SQUARE, Color("c9b27a"))
	cloth.position = cloth_at + Vector3(-.036, 0, 0)
	cloth.rotation.y = -PI / 2
	cloth.scale.z = .1
	tag(cloth, "cloth-of-gold", ["46.256", "Cloth of Gold", "Unknown Maker, French", "ca. 1750-1769", "Silk- and metallic-thread ribbed weave", "Length 129.5 cm"], "textile-46.256.jpg")
	cloth.reparent(board)
	label(9.22, .40)

## The white platform at the north end: the display panel with the Indian cover, and the Cressent commode.
func build_platform() -> void:
	var k: float = (b[3] - b[2]) / REAL.y
	var deck: Node3D = room.plinth(at(16.95, .65), Vector3(1.3, .14, 4.9 * k))
	deck.set_meta("european_east_platform", true)
	# Panel: about 2.7 m wide, to 10 cm under the ceiling, 0.31 m deep as in the footage.
	var panel: Node3D = room.solid(at(16.0, .155, 1.795), Vector3(.31, 3.31, 2.7), room.wall_paint("adjacent gallery"), true)
	panel.set_meta("european_east_display_panel", true)
	var cover := slab("textile-37.009.jpg", Vector2(.92, 1.334), SQUARE, Color("6d2f2a"))
	cover.position = at(16.0, .306, 1.56)
	cover.rotation.y = -PI / 2
	cover.scale.z = .1
	tag(cover, "indian-cover", ["37.009", "Cover", "Unknown Maker, Indian", "ca. 1700-1800", "Painted, mordant-printed and resist-dyed cotton", "Length 133.4 cm"], "textile-37.009.jpg")
	cover.reparent(panel)
	room.label_stand(at(15.2, 1.1, .14), -PI / 2).reparent(deck)
	# Commode: a real mesh (#263) at catalogue size on the deck, its front to the room. It carries its own
	# marble top, mounts and legs; the box, the slab and the front photograph are no longer built.
	var size := Vector3(.648, .864, 1.448)
	var body: Node3D = room.place_mesh(DIR + "commode-201746.glb", at(18.5, .40, .14), -PI / 2, Vector3(size.z, size.y, size.x), "2017.46")
	tag(body, "commode", ["2017.46", "Commode", "Charles Cressent", "ca. 1725-1730", "Fir, oak, amaranth, macacauba and bois satine with gilt bronze mounts and marble top", "86.4 x 144.8 x 64.8 cm"], "commode-2017.46.jpg")
	# Meissen charger in its acrylic box on the marble.
	var disc: Array = []
	for i in 32:
		disc.append([.5 + .40 * cos(i * TAU / 32), .5 + .445 * sin(i * TAU / 32)])
	var charger := slab("charger-2014.31.jpg", Vector2(.432 / .80, .432 / .89), disc, Color("e8e6e0"))
	charger.position = at(18.5, .40, .14 + .864 + .05 + .216)
	charger.rotation.y = -PI / 2
	charger.scale.z = .4
	tag(charger, "charger", ["2014.31", "Charger", "Meissen Porcelain Manufactory", "ca. 1745", "Porcelain with enamels, glaze and gilding", "Diameter 43.2 cm"], "charger-2014.31.jpg")
	charger.reparent(body)
	var hood: Node3D = room.solid(at(18.5, .40, .14 + .864 + .29), Vector3(.30, .58, .62), glass)
	hood.reparent(body)

## A floor case as filmed (IMG_6385 33.0s, IMG_6386 7.0/41.2s, IMG_6384 40.0s): a white base on a
## recessed kick, a cap, a clear hood with pale edges, and inside the hood a riser sloped down to
## the cap all round. The works stand on the riser's top, at base_h + .04 where they always
## stood; the cap and the hood's foot are the riser's 8 cm (by eye) lower.
func display_case(s: float, e: float, foot: Vector2, base_h: float, glass_h: float) -> Node3D:
	# foot.x across the room, foot.y along it
	var c := at(s, e)
	var rise := .08
	var low: float = base_h + .04 - rise
	var top: float = base_h + .04 + glass_h
	var base: Node3D = room.plinth(c, Vector3(foot.x, low - .04, foot.y))
	var cap: Node3D = room.solid(c + Vector3(0, low - .02, 0), Vector3(foot.x + .06, .04, foot.y + .06), white)
	cap.reparent(base)
	for side in [-1, 1]:
		var pane: Node3D = room.solid(c + Vector3(side * foot.x / 2, (low + top) / 2, 0), Vector3(.012, top - low, foot.y), glass)
		pane.reparent(base)
		pane = room.solid(c + Vector3(0, (low + top) / 2, side * foot.y / 2), Vector3(foot.x, top - low, .012), glass)
		pane.reparent(base)
	var lid: Node3D = room.solid(c + Vector3(0, top, 0), Vector3(foot.x, .012, foot.y), glass)
	lid.reparent(base)
	room.hood_edges(base, c, foot.x, foot.y, low, top)
	room.case_riser(base, c, foot / 2 - Vector2(.01, .01), low, rise, rise)
	return base

## One case object as the record's photograph on a thin card (both faces), or flat on the deck.
## `size` is the whole photograph. `fill` is the share of it the object takes (width, height) and
## `foot` the share of its height below the object's foot, both measured on the photograph (#266):
## size x fill is the object at its catalogue size, and an upright card is sunk by `foot` so the
## object, not the photograph's backdrop, stands on the deck.
func card(base: Node3D, key: String, row: Array, image: String, size: Vector2, pos: Vector3, yaw: float, flat := false, outline: Array = SQUARE, identified := true, fill := Vector2.ONE, foot := 0.0) -> void:
	for face in ([0] if flat else [0, 1]):
		var p := slab(image, size, outline, Color("8c8780"))
		p.scale.z = .2
		p.position = pos + Vector3(0, .012 if flat else size.y * (.5 - foot), 0)
		p.rotation = Vector3(-PI / 2 if flat else 0.0, yaw + face * PI, 0)
		if face == 0:
			tag(p, key, row, image, identified)
			# the object's share of the built slab, which a round outline cuts inside the photograph
			var span := Vector2.ZERO
			for corner in outline:
				span = span.max(Vector2(absf(corner[0] - .5), absf(corner[1] - .5)) * 2)
			p.set_meta("object_fill", fill / span)
		p.reparent(base)
	var note: Node3D = room.solid(pos + Vector3(-.01 if flat else 0.0, .006, size.y / 2 + .10 if flat else .14), Vector3(.09, .004, .05), room.look(Color("e9e4d4")))
	note.set_meta("artwork_label_proxy", true)
	note.reparent(base)

func plain(base: Node3D, key: String, title: String, size: Vector3, pos: Vector3, color: Color, candidate := "") -> void:
	var block: Node3D = room.solid(pos + Vector3(0, size.y / 2, 0), size, room.look(color))
	tag(block, key, [candidate, title, "", "", "", ""], "", false)
	block.reparent(base)

func build_floor() -> void:
	var round_plate: Array = []
	for i in 32:
		round_plate.append([.5 + .47 * cos(i * TAU / 32), .5 + .47 * sin(i * TAU / 32)])
	# 1. Silver and porcelain, north end (IMG_6385 30.5-37 s, IMG_6386 57.25 s).
	var c := at(15.2, 4.0)
	var silver := display_case(15.2, 4.0, Vector2(1.3, 1.6), .85, .60)
	silver.set_meta("european_east_case", "silver")
	var deck := .89
	var riser: Node3D = room.solid(c + Vector3(.15, deck + .15, -.35), Vector3(.36, .30, .36), white)
	riser.reparent(silver)
	card(silver, "cake-basket", ["2016.124", "Cake Basket", "Peter Archambo I", "1736", "Silver", "10.5 x 31.5 x 27.5 cm"], "basket-2016.124.jpg", Vector2(.315, .295), c + Vector3(-.25, deck, .40), PI / 2)
	card(silver, "coffeepot", ["2014.33", "Coffeepot", "Paul de Lamerie", "1745", "Silver with wood", "23.5 x 19.1 cm"], "coffeepot-2014.33.jpg", Vector2(.227, .280), c + Vector3(.40, deck + .03, .05), PI / 2, false, SQUARE, true, Vector2(.77, .84), .07)
	card(silver, "plate-scholten", ["09.351", "Plate with Scholten Impaling Hogenberg Coat of Arms", "Unknown Maker, Chinese", "ca. 1725-1745", "Porcelain with enamels and gilding", "Diameter 22.9 cm"], "plate-09.351.jpg", Vector2(.358, .273), c + Vector3(-.30, deck, -.35), 0.0, true, SQUARE, true, Vector2(.64, .86), 0.0)
	card(silver, "plate-colebrooke", ["2016.62", "Plate with Colebrooke Impaling Hudson Coat of Arms", "Unknown Maker, Chinese", "ca. 1732-1742", "Porcelain with enamels and gilding", ""], "plate-2016.62.jpg", Vector2(.318, .291), c + Vector3(.05, deck, .15), PI / 2, false, SQUARE, true, Vector2(.72, .82), .08)
	card(silver, "plate-elephant", ["2016.102.2", "Plate with Elephant", "Unknown Maker, Chinese", "ca. 1745-1755", "Porcelain with glaze", ""], "plate-2016.102.2.jpg", Vector2(.388, .288), c + Vector3(-.20, deck, .05), 0.0, true, SQUARE, true, Vector2(.59, .81), 0.0)
	card(silver, "platter-saldanha", ["55.023.6H", "Saldanha Platter", "Unknown Maker, Chinese", "ca. 1735-1785", "Porcelain with enamels and glaze", "Length 29.5 cm"], "platter-55.023.6H.jpg", Vector2(.421, .317), c + Vector3(.15, deck, -.62), 0.0, false, SQUARE, false, Vector2(.70, .73), .13)
	plain(silver, "figure-turkish-man", "Porcelain figure of a man in a turban beside a covered pot", Vector3(.08, .175, .08), c + Vector3(.07, deck + .30, -.35), Color("ece6c9"), "37.087")
	plain(silver, "figure-turkish-woman", "Porcelain figure of a woman in pink beside a covered pot", Vector3(.08, .162, .08), c + Vector3(.23, deck + .30, -.35), Color("e7c3d2"), "37.086")
	plain(silver, "pineapple-teapot", "Small green and yellow moulded teapot", Vector3(.12, .10, .09), c + Vector3(.42, deck, -.25), Color("a9b25a"))
	# 2. Bench (IMG_6386 42-43.5 s): black slab top on two black leg frames, each a loop with a
	# rail on the floor; sizes by eye.
	var seat: Node3D = room.solid(at(10.3, 2.6, .43), Vector3(.45, .05, 2.0), room.look(Color("1c1b1b")), true)
	seat.set_meta("european_east_bench", true)
	for z in [-.8, .8]:
		for x in [-.17, .17]:
			var leg: Node3D = room.solid(at(10.3, 2.6, .205) + Vector3(x, 0, z), Vector3(.05, .41, .05), room.look(Color("1c1b1b")))
			leg.reparent(seat)
		var rail: Node3D = room.solid(at(10.3, 2.6, .02) + Vector3(0, 0, z), Vector3(.39, .04, .05), room.look(Color("1c1b1b")))
		rail.reparent(seat)
	# 3. Cabinet case (IMG_6386 41.2 s, 83.5-84.5 s): the Schreibtisch stands open, its long faces across the
	# gallery. At 41.2 s the camera looks south to the exit sign and sees its back; at 84.0 s the fall front lies
	# lowered before it. The front and the flap carry the museum's two square-on photographs; no photograph of
	# the back, the ends or the top exists, so those stay plain wood. Which way it faces is read from those two frames.
	c = at(8.3, 3.0)
	var cabinet_case := display_case(8.3, 3.0, Vector2(.85, 1.05), .80, .70)
	cabinet_case.set_meta("european_east_case", "cabinet")
	var box: Node3D = room.solid(c + Vector3(0, .84 + .2255, -.20), Vector3(.606, .451, .333), room.look(Color("7a3a16")))
	tag(box, "schreibtisch", ["75.023", "Writing Desk (Schreibtisch)", "Unknown Maker, German", "ca. 1590", "Walnut, burled walnut, ebonized walnut", "45.1 x 60.6 x 33.3 cm"], "cabinet-75.023.jpg")
	box.reparent(cabinet_case)
	var face := slab("cabinet-75.023-open.jpg", Vector2(.606, .451), SQUARE, Color("7a3a16"))
	face.position = c + Vector3(0, .84 + .2255, -.20 + .1665)
	face.scale.z = .1
	face.reparent(box)
	var flap := slab("cabinet-75.023-flap.jpg", Vector2(.606, .445), SQUARE, Color("7a3a16"))
	flap.position = c + Vector3(0, .84 + .012, -.20 + .1665 + .2225)
	flap.rotation.x = -PI / 2
	flap.scale.z = .3
	flap.reparent(box)
	# 4. Majolica case by the west wall, south end (IMG_6386 0.5-14.5 s, IMG_6384 30.5-32.5 s).
	# Its deck as filmed from the room side (IMG_6386 12 s): mortar, bone casket and jar along the
	# wall side, the two plates and the roundel along the room side, the gilt casket at the north end.
	c = at(4.9, 4.5)
	var majolica := display_case(4.9, 4.5, Vector2(1.0, 2.2), .85, .60)
	majolica.set_meta("european_east_case", "majolica")
	card(majolica, "mortar", ["54.147.9", "Mortar (with Pestle 54.147.20)", "Unknown Maker, Italian", "1680", "Bronze", "Height 17.6 cm"], "mortar-54.147.9.jpg", Vector2(.304, .289), c + Vector3(-.10, deck, .855), -PI / 2, false, SQUARE, true, Vector2(.64, .61), .05)
	card(majolica, "embriachi-casket", ["85.075.8", "Casket", "Baldessare degli Imbriachi", "ca. 1400", "Bone, wood and horn", "Base 31.8 x 22.9 cm"], "casket-85.075.8.jpg", Vector2(.477, .358), c + Vector3(-.25, deck + .04, .46), -PI / 2, false, SQUARE, true, Vector2(.48, .90), .05)
	card(majolica, "orciuolo", ["43.351", "Apothecary Jar (Orciuolo)", "Unknown Maker, Italian", "ca. 1414-1465", "Earthenware with tin glaze", "23.5 x 25.4 x 20.3 cm"], "jar-43.351.jpg", Vector2(.324, .324), c + Vector3(-.20, deck, .05), -PI / 2, false, SQUARE, true, Vector2(.75, .76), .14)
	card(majolica, "istoriato-plate", ["35.703", "Plate", "Unknown Maker, Italian", "ca. 1535-1555", "Earthenware with tin glaze", "Diameter 27 cm"], "plate-35.703.jpg", Vector2(.365, .349), c + Vector3(.15, deck, .45), -PI / 2, false, round_plate, true, Vector2(.74, .80), .10)
	card(majolica, "calendar-plate", ["1989.085", "March Calendar Plate", "Pierre Reymond", "ca. 1535-1585", "Enamel with gilding on copper", "Diameter 18.4 cm"], "plate-1989.085.jpg", Vector2(.227, .227), c + Vector3(.10, deck, -.20), -PI / 2, false, round_plate, true, Vector2(.81, .84), .08)
	card(majolica, "apollo-roundel", ["51.502", "Apollo and the Muses on Mount Parnassus", "Unknown Maker, Flemish", "ca. 1520-1570", "Silver with gilding", "Diameter 15.1 cm"], "roundel-51.502.jpg", Vector2(.151, .151), c + Vector3(.25, deck, -.55), 0.0, true, round_plate)
	card(majolica, "pastiglia-casket", ["51.272", "Casket", "Unknown Maker, Italian", "ca. 1475-1525", "Wood with pastiglia and gilding", "15.2 x 21 x 14 cm"], "casket-51.272.jpg", Vector2(.238, .217), c + Vector3(-.25, deck + .03, -.45), -PI / 2, false, SQUARE, true, Vector2(.86, .72), .13)
	var low: Node3D = room.solid(c + Vector3(-.05, deck + .02, -.92), Vector3(.40, .04, .22), white)
	low.reparent(majolica)
	plain(majolica, "small-dish", "Small brass dish", Vector3(.10, .015, .10), c + Vector3(-.15, deck + .04, -.92), Color("b89a55"))
	for i in 3:
		plain(majolica, "small-metal-%d" % i, "Small metal object", Vector3(.04, .02, .04), c + Vector3(0, deck + .04, -.98 + i * .06), Color("8f8a80"))
	# 5. Giambologna's River God in its hooded case, south end (IMG_6384 34.5-40.5 s).
	c = at(2.8, 2.5)
	var god_case := display_case(2.8, 2.5, Vector2(.75, .75), 1.0, .95)
	god_case.set_meta("european_east_case", "river-god")
	var skirt: Node3D = room.solid(c + Vector3(0, .09, 0), Vector3(.83, .18, .83), white)
	skirt.reparent(god_case)
	card(god_case, "river-god", ["44.674", "River God (The Virile Age; The Euphrates)", "Giambologna", "ca. 1575", "Terracotta", "48.3 x 43.5 x 31.8 cm"], "rivergod-44.674.jpg", Vector2(.528, .654), c + Vector3(0, 1.04, 0), -PI / 4, false, SQUARE, true, Vector2(.77, .74), .09)
