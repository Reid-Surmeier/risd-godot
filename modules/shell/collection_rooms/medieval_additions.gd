## Medieval room additions (#238): the six works the room lacked (south wall and the Angel),
## their pedestals, the crucifix platform, St Anthony's backing panel and blank label cards.
## Sizes: catalogue heights; widths follow each catalogue photograph's own outline (shapes.json).
## Positions: metres along a wall from its west or north end, read from a structure-from-motion
## fit of IMG_6382 and IMG_6344 scaled on St Anthony's panel. All provisional; the measurements
## and what is left are in docs/evidence/museum-238/medieval/NOTES.md.
## ponytail: each work is its catalogue photograph on a slab cut to its outline, not a modelled
## volume. The head, bust and angel need real depth (a generation pass or hand modelling) to read
## from the side; pedestal and platform metres are by eye from the footage.
extends RefCounted

const ROOM := "dark medieval room"
const DIR := "res://modules/shell/collection_rooms/assets/additions/medieval/"
const FACE := 0.061 # a wall's visible face stands this far inside its plan line (wall_face)
const GREY := Color("6b6d73") # pedestals: the wall's grey, a little lighter (6382 28.5..50.5s)
const BACKING := Color("74757b")
const WHITE := Color("f0eeea")
const CARD := Color("e9e4d4")
const WORKS := {
	"head": ["59.131", "Head of Christ or a Saint", "Unknown Maker, Spanish", "ca. 1220-1240", "Walnut with polychromy (colored paint)", "81.3 x 50.8 x 50.8 cm (32 x 20 x 20 inches)"],
	"relief": ["69.196", "Christ in Majesty", "Unknown Maker, Spanish", "ca. 1090-1100", "Limestone", "97.8 x 55.9 cm (38 1/2 x 22 inches)"],
	"cross": ["43.195", "The Crucified Christ", "Unknown Maker, Spanish", "ca. 1150-1200", "Oak with traces of polychrome (colored paint)", "215.9 x 215.9 cm (85 x 85 inches)"],
	"peter": ["20.254", "Saint Peter", "Unknown Maker, French", "ca. 1106-1112", "Limestone with traces of gesso and polychromy (colored paint)", "76.2 x 43.2 x 29.2 cm (30 x 17 x 11 1/2 inches)"],
	"anthony": ["16.243", "St. Anthony Abbot Enthroned", "Spinello Aretino", "ca. 1385", "Tempera and gold on panel", "232.4 x 92.1 x 22.2 cm (91 1/2 x 36 1/4 x 8 3/4 inches)"],
	"angel": ["37.114", "Angel of the Annunciation", "Unknown Maker, Italian", "ca. 1350", "Wood with polychromy (colored paint)", "Height: 152.4 cm (60 inches)"],
}

var room
var shapes: Dictionary

func build(scene) -> void:
	room = scene
	shapes = JSON.parse_string(FileAccess.get_file_as_string(DIR + "shapes.json"))
	var south: Node3D = room.wall_body(ROOM, "south", room.wall_point(ROOM, "south", 5, 1.5))
	var west: Node3D = room.wall_body(ROOM, "west", room.wall_point(ROOM, "west", 4.8, 1.5))
	assert(south != null and west != null)

	# St. Anthony Abbot, 1.75 m from the south-west corner, bottom 0.60 m up, on a lighter
	# backing that runs from the floor past the gable (6382 53.5..57.5s, 81..82s).
	var backing: Node3D = room.solid(room.wall_point(ROOM, "south", 1.75, 1.65, FACE + .04), Vector3(1.62, 3.30, .08), room.look(BACKING))
	backing.set_meta("medieval_backing_panel", true)
	backing.reparent(south)
	var anthony := _work("anthony", 2.324, .10, Color("7c6038"))
	anthony.position = room.wall_point(ROOM, "south", 1.75, .60 + 2.324 / 2, FACE + .08)
	anthony.rotation.y = PI
	anthony.reparent(south)
	_label(room.wall_point(ROOM, "south", 2.385, 1.35, FACE + .083), PI, south)

	# Saint Peter, a bust on a rectangular pedestal with a stepped cap (6382 44.5..50.5s).
	var peter_base := _pedestal(room.wall_point(ROOM, "south", 3.27, 0, .36), Vector3(.58, 1.05, .48), Vector3(.50, .15, .40))
	var peter := _mesh("peter", "peter-20254.glb", room.wall_point(ROOM, "south", 3.27, 1.20, .36), PI, Vector3(.432, .762, .292))
	peter.reparent(peter_base)
	_label(room.wall_point(ROOM, "south", 3.27, .82, .36 + .243), PI, peter_base)
	peter_base.reparent(south)

	# The Crucified Christ, feet 1.0 m up, over a long low white platform (6382 38.5..47.5s).
	var platform: Node3D = room.solid(room.wall_point(ROOM, "south", 5.23, .075, FACE + .25), Vector3(3.10, .15, .50), room.look(WHITE), true)
	platform.set_meta("medieval_crucifix_platform", true)
	_label(room.wall_point(ROOM, "south", 5.28, .153, FACE + .38), PI, platform, true)
	platform.reparent(south)
	var cross := _mesh("cross", "cross-43195.glb", room.wall_point(ROOM, "south", 5.28, 1.00, FACE + .24), PI, Vector3(0, 2.159, 0))
	cross.reparent(south)

	# Christ in Majesty, a limestone relief slab standing on a rectangular pedestal (6382 34.5..36.5s).
	var relief_base := _pedestal(room.wall_point(ROOM, "south", 7.39, 0, .30), Vector3(.66, 1.05, .40), Vector3(.60, .15, .34))
	var relief := _mesh("relief", "relief-69196.glb", room.wall_point(ROOM, "south", 7.39, 1.20, .28), PI, Vector3(.559, .978, .20))
	relief.reparent(relief_base)
	_label(room.wall_point(ROOM, "south", 7.39, .82, .30 + .203), PI, relief_base)
	relief_base.reparent(south)

	# Head of Christ or a Saint on an octagonal pedestal near the south-east corner (6382 28.5..32.5s).
	var head_base := _octagon(room.wall_point(ROOM, "south", 8.62, 0, .43), .30, 1.36, .24, .14)
	var head := _mesh("head", "head-59131.glb", room.wall_point(ROOM, "south", 8.62, 1.50, .43), PI, Vector3(.508, .813, .508))
	head.reparent(head_base)
	_label(room.wall_point(ROOM, "south", 8.62, 1.0, .43 + .28), PI, head_base)
	head_base.reparent(south)

	# Angel of the Annunciation on a low octagonal pedestal against the west wall, south of the
	# tracery door (6382 59.5..61.5s); 1.29 m from the south wall.
	var angel_base := _octagon(room.wall_point(ROOM, "west", 4.81, 0, .45), .33, .69, 0, 0)
	var angel := _mesh("angel", "angel-37114.glb", room.wall_point(ROOM, "west", 4.81, .69, .45), PI / 2, Vector3(0, 1.524, 0))
	angel.reparent(angel_base)
	angel_base.reparent(west)
	_label(room.wall_point(ROOM, "west", 4.40, 1.35, FACE + .003), PI / 2, west)
	room.inventory["medieval_additions"] = {"works": WORKS.keys(), "pedestals": 4, "platform": 1, "backing_panel": 1, "label_cards": 6, "placement_accepted": false, "volumes_modelled": false}

## One catalogued work as a mesh (#263): the file in DIR, the point its base stands on, its turn, its catalogue size.
func _mesh(key: String, file: String, at: Vector3, yaw: float, size_m: Vector3) -> Node3D:
	var row: Array = WORKS[key]
	var art: Node3D = room.place_mesh(DIR + file, at, yaw, size_m, row[0])
	art.name = "Medieval" + key.capitalize()
	for i in 5:
		art.set_meta(["catalogue_title", "catalogue_maker", "catalogue_date", "catalogue_medium", "catalogue_dimensions"][i], row[i + 1])
	art.set_meta("catalogue_image", DIR + row[0] + "-front.jpg")
	art.set_meta("placement_accepted", false)
	return art

## One catalogued work: its photograph on a slab cut to its outline, local +z out of the wall.
func _work(key: String, height: float, depth: float, edge: Color) -> Node3D:
	var row: Array = WORKS[key]
	var shape: Dictionary = shapes[key]
	var art = room.Painting.new()
	art.name = "Medieval" + key.capitalize()
	room.add_child(art)
	art.build_shaped(load(DIR + key + "-cut.jpg"), Vector2(height * shape.aspect, height), shape.outline, edge)
	assert(art.get_child(0).mesh.get_faces().size() > 0, "Outline did not triangulate: " + key)
	art.scale.z = depth / .05
	art.set_meta("catalogue_accession", row[0])
	art.set_meta("catalogue_title", row[1])
	art.set_meta("catalogue_maker", row[2])
	art.set_meta("catalogue_date", row[3])
	art.set_meta("catalogue_medium", row[4])
	art.set_meta("catalogue_dimensions", row[5])
	art.set_meta("catalogue_image", DIR + row[0] + "-front.jpg")
	art.set_meta("placement_accepted", false)
	return art

## Rectangular pedestal standing on floor point `at`, with a narrower cap and a foot.
func _pedestal(at: Vector3, size: Vector3, cap: Vector3) -> StaticBody3D:
	var body: StaticBody3D = room.solid(at + Vector3(0, size.y / 2, 0), size, room.look(GREY), true)
	for spec in [[size.y + cap.y / 2, cap], [.04, Vector3(size.x + .04, .08, size.z + .04)]]:
		var part: Node3D = room.solid(at + Vector3(0, spec[0], 0), spec[1], room.look(GREY))
		part.reparent(body)
	return body

## Octagonal pedestal on floor point `at`, on a projecting base band (6382 30.0/60.5s); an
## optional narrower octagonal cap on top, or without one a projecting band round its head.
func _octagon(at: Vector3, radius: float, height: float, cap_radius: float, cap_height: float) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = at + Vector3(0, height / 2, 0)
	var collider := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(radius * 1.85, height, radius * 1.85)
	collider.shape = box
	body.add_child(collider)
	var bands := [[radius + .02, .10, -height / 2 + .05]]
	if cap_radius <= 0:
		bands.append([radius + .015, .08, height / 2 - .04])
	for spec in [[radius, height, 0.0], [cap_radius, cap_height, height / 2 + cap_height / 2]] + bands:
		if spec[1] <= 0:
			continue
		var visual := MeshInstance3D.new()
		var prism := CylinderMesh.new()
		prism.top_radius = spec[0]
		prism.bottom_radius = spec[0]
		prism.height = spec[1]
		prism.radial_segments = 8
		prism.rings = 1
		visual.mesh = prism
		visual.material_override = room.look(GREY)
		visual.position.y = spec[2]
		visual.rotation.y = PI / 8
		body.add_child(visual)
	room.add_child(body)
	room.casings.append(body)
	return body

## Blank label card of the finish spec: 0.30 x 0.17 m, off-white, two grey bars, no words.
func _label(at: Vector3, yaw: float, parent: Node3D, lying := false) -> void:
	var card: Node3D = room.solid(at, Vector3(.30, .004, .17) if lying else Vector3(.30, .17, .004), room.look(CARD))
	card.rotation.y = yaw
	card.set_meta("artwork_label_proxy", true)
	for offset in [.03, -.02]:
		var bar: Node3D = room.solid(Vector3.ZERO, Vector3(.20, .002, .012) if lying else Vector3(.20, .012, .002), room.look(Color("8c8a84")))
		bar.reparent(card, false)
		bar.position = Vector3(-.03, .003, -offset) if lying else Vector3(-.03, offset, .003)
	card.reparent(parent)
