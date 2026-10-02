## Grey French gallery additions (#238): Rodin's Hand of God on its plinth, six paintings, label
## cards, the exit sign, two vents and the ceiling track.
## Sizes are the RISD catalogue's. Positions are read from IMG_6380 and IMG_6379 and are provisional.
## The six frames are borrowed from the three Muse frames this room already has; none is the work's own.
extends RefCounted

const Painting := preload("res://modules/shell/prototype/gallery_walk4/painting_asset.gd")
const DIR := "res://modules/shell/collection_rooms/assets/additions/grey/"
const GREY := "grey French gallery"
const YAW := {"north": 0.0, "south": PI, "west": PI / 2, "east": -PI / 2}
const CARD := Vector3(.30, .17, .004)  # blank label card, the polish spec's size

## along: metres from the wall's west end (north, south walls) or north end (west wall).
## card: which side of the frame the label hangs on, seen by the viewer (+1 right, 0 none).
const WORKS := [
	# IMG_6380 5.5..8.0s: between the Courbet and the connector door; centre 3.25 m from the south-west corner.
	{"side": "west", "along": 2.75, "height": 1.69, "size": [.733, .595], "frame": "courbet", "card": 1,
		"image": DIR + "gericault-43.539.jpg", "accession": "43.539", "title": "A Cart Loaded with Kegs (Le Haquet)",
		"maker": "Jean-Louis-André-Théodore Géricault", "date": "1817-1828", "medium": "Oil on canvas", "dimensions": "59.5 x 73.3 cm"},
	# IMG_6380 19.5..30.5s: three small landscapes east of the piano door, the Corot last.
	{"side": "north", "along": 4.25, "height": 1.80, "size": [.305, .229], "frame": "corot", "card": 1,
		"image": DIR + "bannister-2023.53.jpg", "accession": "2023.53", "title": "Landscape with shepherdess, sheep and cows",
		"maker": "Edward Mitchell Bannister", "date": "1877-1887", "medium": "Oil on canvas", "dimensions": "22.9 x 30.5 cm"},
	{"side": "north", "along": 5.30, "height": 1.80, "size": [.672, .381], "frame": "bertin", "card": 1,
		"image": DIR + "daubigny-73.120.jpg", "accession": "73.120", "title": "Landscape",
		"maker": "Charles François Daubigny", "date": "1871", "medium": "Oil on panel", "dimensions": "38.1 x 67.2 cm"},
	# IMG_6379 172.3s: the Hall-door wall seen square on from the piano door.
	{"side": "south", "along": 3.60, "height": 1.75, "size": [.746, .413], "frame": "courbet", "card": 1,
		"image": DIR + "pannini-56.094.jpg", "accession": "56.094", "title": "The Colosseum",
		"maker": "Giovanni Paolo Pannini", "date": "1725-1775", "medium": "Oil on canvas", "dimensions": "41.3 x 74.6 cm"},
	# The record gives the frame, 50.8 x 61 cm; the canvas is its footage share of that, about 31 x 41 cm.
	{"side": "south", "along": 6.20, "height": 1.75, "size": [.41, .31], "frame": "courbet", "card": 1,
		"image": DIR + "villeneuve-1998.35.jpg", "accession": "1998.35", "title": "View of a Roman Aqueduct, near Tivoli",
		"maker": "Louis-Jules-Frédéric Villeneuve", "date": "1827", "medium": "Oil on canvas", "dimensions": "50.8 x 61 x 8.3 cm (frame)"},
	# The pier between the Hall door and the connector door. It is 0.70 m here and about 1.2 m in the
	# footage, so the frame is the thin one and there is no room for its label beside it.
	{"side": "south", "along": .355, "height": 1.75, "size": [.448, .335], "frame": "bertin", "card": 0,
		"image": DIR + "eastlake-56.099.jpg", "accession": "56.099", "title": "The Celian Hill from the Palatine",
		"maker": "Charles Lock Eastlake", "date": "1798-1848", "medium": "Oil on canvas", "dimensions": "33.5 x 44.8 x 6.4 cm",
		"identified": "by eye against IMG_6380 105.4s; the label is not legible"},
]


func build(room) -> void:
	for work in WORKS:
		hang(room, GREY, work)
	rodin(room)
	fixtures(room)
	room.inventory["grey_gallery_additions"] = {"paintings": WORKS.size(), "rodin": true, "frames_borrowed": true, "placement_accepted": false}


## One framed painting on a wall, with its catalogue metadata and blank label card.
static func hang(room, label: String, work: Dictionary) -> Node3D:
	var frame: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://modules/shell/collection_rooms/assets/%s-frame-geometry.json" % work.frame))
	var art := Painting.new()
	room.add_child(art)
	art.build_framed(load("res://modules/shell/collection_rooms/assets/%s-frame.png" % work.frame), load(work.image), Vector2(work.size[0], work.size[1]), frame.margins_px)
	art.position = room.wall_point(label, work.side, work.along, work.height, .07)
	art.rotation.y = YAW[work.side]
	describe(art, work)
	if work.card != 0:
		card(room, art, Vector3(work.card * (art.outer.x / 2 + .25), -.12, .01))
	art.reparent(room.wall_body(label, work.side, art.position))
	return art


static func describe(node: Node, work: Dictionary) -> void:
	for key in ["accession", "title", "maker", "date", "medium", "dimensions", "image"]:
		if work.has(key):
			node.set_meta("catalogue_" + key, work[key])
	if work.has("identified"):
		node.set_meta("catalogue_identification_basis", work.identified)


static func card(room, parent: Node3D, at: Vector3, yaw := 0.0) -> Node3D:
	var label: Node3D = room.solid(Vector3.ZERO, CARD, room.look(Color("e9e4d4")))
	label.reparent(parent, false)
	label.position = at
	label.rotation.y = yaw
	label.set_meta("artwork_label_proxy", true)
	return label


## Closed faceted volume from a catalogue photograph's silhouette (rows of [left, right], 0..1 of the
## width), the idiom of prepare_remodel.py's volume_asset. The front photograph is repeated on the back.
static func volume(data: Dictionary, texture: Texture2D, sides := 12) -> MeshInstance3D:
	var rows: Array = data.rows
	var size: Array = data.size_m
	var n := rows.size()
	var points := []
	for r in n:
		var centre: float = (rows[r][0] + rows[r][1]) / 2
		var radius: float = max((rows[r][1] - rows[r][0]) / 2, .001)
		for k in sides:
			var a := TAU * k / sides
			var u: float = centre + radius * cos(a)
			points.append([Vector3((u - .5) * size[0], (1.0 - float(r) / (n - 1)) * size[1], sin(a) * size[2] / 2 * min(1.0, max(.2, radius * 3))),
				Vector2(u, float(r) / (n - 1))])
	var faces := []
	for r in n - 1:
		for k in sides:
			var a := r * sides + k
			var b := r * sides + (k + 1) % sides
			var c := (r + 1) * sides + (k + 1) % sides
			faces.append_array([[a, b, c], [a, c, (r + 1) * sides + k]])
	for k in range(1, sides - 1):
		faces.append([0, k + 1, k])
		faces.append([(n - 1) * sides, (n - 1) * sides + k, (n - 1) * sides + k + 1])
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for face in faces:
		st.set_normal((points[face[1]][0] - points[face[0]][0]).cross(points[face[2]][0] - points[face[0]][0]).normalized())
		for i in face:
			st.set_uv(points[i][1])
			st.add_vertex(points[i][0])
	var mesh := MeshInstance3D.new()
	mesh.mesh = st.commit()
	mesh.material_override = Painting.mat(texture, 1.0, true)
	return mesh


func rodin(room) -> void:
	# IMG_6380 16.5..17.5s, 36.5..39.5s, IMG_6381 31.5s and 90.5s: free-standing before the columns, on the
	# connector door's axis, on a low white plinth. Distance from the columns is by eye.
	var b: Array = room.room_bounds(GREY)
	var door: Array = []
	for area in room._plan_rooms:
		if area.label == GREY:
			door = area.openings.west
	var at := Vector3(b[1] - 2.35, 0, (door[0] + door[1]) / 2)
	var plinth: Node3D = room.solid(at + Vector3(0, .25, 0), Vector3(1.0, .5, 1.0), room.look(Color("eeeae2")), true)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DIR + "rodin-23.005-cut.json"))
	var hand := volume(data, load(DIR + "rodin-23.005-cut.png"))
	room.add_child(hand)
	hand.position = at + Vector3(0, .5, 0)
	hand.rotation.y = -PI / 2  # the photographed front faces the connector door
	describe(hand, {"accession": "23.005", "title": "The Hand of God", "maker": "Auguste Rodin", "date": "1873-1923",
		"medium": "Marble", "dimensions": "100.3 x 82.6 x 68 cm", "image": DIR + "rodin-23.005.jpg"})
	card(room, plinth, Vector3(-.502, .12, .3), -PI / 2)


func fixtures(room) -> void:
	var b: Array = room.room_bounds(GREY)
	var white: Material = room.look(Color("eeeae2"))
	# IMG_6380 14.5s: green exit sign over the piano door.
	var sign: Node3D = room.solid(room.wall_point(GREY, "north", 1.7, 3.02, .09), Vector3(.36, .2, .05), room.look(Color("86e39a"), "", true))
	sign.reparent(room.wall_body(GREY, "north", sign.position))
	# IMG_6380 85.5..87.5s: square-grid return low under the Villeneuve; IMG_6379 172.3s: slot high on the same wall.
	var low: Node3D = room.solid(room.wall_point(GREY, "south", 5.88, .52, .07), Vector3(.60, .42, .02), room.look(Color("5b5a55")))
	low.reparent(room.wall_body(GREY, "south", low.position))
	var slot: Node3D = room.solid(room.wall_point(GREY, "south", 5.0, 3.2, .07), Vector3(1.1, .1, .02), room.look(Color("3c3b38")))
	slot.reparent(room.wall_body(GREY, "south", slot.position))
	# IMG_6380 108..116s: a rectangle of white track with spot heads. Run and count are by eye.
	var mid := Vector3((b[0] + b[1]) / 2, 3.43, (b[2] + b[3]) / 2)
	var half := Vector2((b[1] - b[0]) / 2 - 1.4, (b[3] - b[2]) / 2 - 1.4)
	for edge in [[Vector3(0, 0, -half.y), true], [Vector3(0, 0, half.y), true], [Vector3(-half.x, 0, 0), false], [Vector3(half.x, 0, 0), false]]:
		var along_x: bool = edge[1]
		var length: float = (half.x if along_x else half.y) * 2
		var rail: Node3D = room.solid(mid + edge[0], Vector3(length, .025, .035) if along_x else Vector3(.035, .025, length), white)
		room.ceiling_details.append(rail)
		for step in [-.33, 0.0, .33]:
			var head: Node3D = room.solid(mid + edge[0] + (Vector3(step * length, -.1, 0) if along_x else Vector3(0, -.1, step * length)), Vector3(.08, .15, .08), white)
			head.reparent(rail)
