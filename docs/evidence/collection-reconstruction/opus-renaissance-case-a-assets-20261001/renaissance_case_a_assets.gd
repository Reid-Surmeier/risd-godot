## Six objects from Renaissance case A (east wall, north of the tracery doorway), IMG_6383 41.1/41.2/45.7/46.4/49.8s,
## as closed low polygon masses: Portrait of a Cleric RISD 45.042 (API 1544321), Portrait of a Woman 34.861 (1257341),
## ivory Diptych 22.201 (1572876), silver Book Cover 34.016 (1546231), One Hundred Christian Emblems 2023.17 (1597546)
## and Drug Jar (Albarello) 35.713 (1461531).
## The catalogue fixes the sizes named in OBJECTS. Every other measure is read by eye from the official photographs and the
## film and is provisional: depths, frame bands, splay, recline, opening angle, mounts. Nothing is placed in a case.
## Source pixels stay source pixels: build() lays the caller's photographs and straightened film crops on the solids and
## repaints nothing. With no textures it gives flat observed colours. No Muse texture is used; see REPORT.md.
extends RefCounted

const Base := preload("seated_woman_asset.gd")
const Metal := preload("medieval_metal_assets.gd")

const CM := .01
# `size` is catalogue metres. `flags` are what the evidence supports; every acceptance in FLAGS stays false.
const OBJECTS := {
	"cleric": {"accession": "45.042", "catalogue_id": "1544321", "identity": "confirmed", "size": Vector3(.146, .222, .057),
		"flags": {"source_rear_observed": false, "frame_in_official_photograph": false, "frame_texture": "film crop, provisional, not Muse"},
		"unresolved": "frame band width and profile (film, about +-15%); which part the catalogue 5.7 cm depth measures; sight opening taken as the whole panel; back; its size against the arched portrait in the film"},
	"woman": {"accession": "34.861", "catalogue_id": "1257341", "identity": "confirmed", "size": Vector3(.248, .362, 0),
		"flags": {"source_rear_observed": true, "frame_in_official_photograph": true, "frame_texture": "official photograph 0, the panel's own engaged frame"},
		"unresolved": "depth and recess; photograph is 0.731 wide per high against the catalogue 0.685, so it is stretched 6.7% in height; the film shows it larger against the grey frame than the catalogue allows; side clips not modelled"},
	"diptych": {"accession": "22.201", "catalogue_id": "1572876", "identity": "confirmed", "size": Vector3(.133, .241, 0),
		"flags": {"source_rear_observed": true, "left_leaf_in_official_photograph": false},
		"unresolved": "thickness; left leaf face is film pixels only; carving is twelve plain masses; which back belongs to which leaf; mount size and slope"},
	"bookcover": {"accession": "34.016", "catalogue_id": "1546231", "identity": "confirmed", "size": Vector3(.086, .14, .051),
		"flags": {"source_rear_observed": false, "stands_on": "tail edge, spine to the room, as filmed; not the fore-edge"},
		"unresolved": "splay; chain fixings; what holds the ring up; far board is plain; which board official photograph 0 shows; clasps not modelled"},
	"emblem": {"accession": "2023.17", "catalogue_id": "1597546", "identity": "confirmed", "size": Vector3(.147, .197, 0),
		"flags": {"source_rear_observed": false, "museum_photograph_available": false, "comparative_copy_used": false, "open_emblem": 15,
			"page_pixels": "IMG_6383 46.40s, straightened"},
		"unresolved": "thickness and how it divides at the opening; recline and opening angle; binding outside; cradle shape"},
	"albarello": {"accession": "35.713", "catalogue_id": "1461531", "identity": "confirmed", "size": Vector3(.13, .241, .13),
		"flags": {"source_rear_observed": true, "rear_filmed": false, "sides_observed": false},
		"unresolved": "official photograph 1 taken as the 180 degree reverse; both sides are stretched limbs of the two photographs; inside depth; underside"},
}
const FLAGS := ["placement_accepted", "metric_accepted", "depth_accepted", "side_and_rear_accepted", "frame_metric_accepted",
	"fine_fidelity_accepted", "muse_frame_accepted", "whole_room_complete"]
# Median source pixels (measurements.json). The mount white is a guess; the book's outside is one blurred oblique view.
const COLORS := {"frame_grey": Color("645d49"), "frame_brown": Color("684330"), "ivory": Color("b19b7d"), "ivory_back": Color("c1904f"),
	"silver": Color("837b68"), "gilt": Color("51452c"), "page": Color("e6e3da"), "page_edge": Color("98845f"), "binding": Color("bab2a3"),
	"jar_blue": Color("02316d"), "jar_rim": Color("ad8043"), "jar_inside": Color("5b5347"), "mount": Color("f0efea"), "acrylic": Color(.78, .88, .89, .12)}
const METALS := ["silver", "gilt"]
# Texture key -> file in this folder. The .jpg files are byte copies of the official photographs; the .png files are
# straightened source crops (prepare_textures.py). "cleric_frame" is the film's own frame, a stand-in until a Muse pass.
const TEXTURES := {"cleric": "textures/portrait-cleric-45042-zoom-0.jpg", "cleric_frame": "textures/cleric-frame-film.png",
	"woman_front": "textures/portrait-woman-34861-zoom-0.jpg", "woman_rear": "textures/portrait-woman-34861-zoom-1.jpg",
	"diptych_front": "textures/diptych-scenes-nativity-crucifixion-and-last-judgement-22201-zoom-0.jpg", "diptych_left_native": "textures/diptych-left-native.png",
	"bookcover_spine": "textures/book-cover-34016-zoom-1.jpg", "bookcover_board": "textures/bookcover-board.png",
	"emblem_left_page": "textures/emblem-left-page.png", "emblem_right_page": "textures/emblem-right-page.png",
	"albarello_front": "textures/drug-jar-albarello-35713-zoom-0.jpg", "albarello_rear": "textures/drug-jar-albarello-35713-zoom-1.jpg"}

# Cleric: frame bands at the sides and at top and bottom, from 41.2 and 49.8s with the sight opening taken as the whole
# panel (sides 3.9..4.9 cm, top and bottom 4.8..5.2 cm). The catalogue depth is taken as the framed depth.
const CLERIC_BAND := Vector2(.044, .05)
# Woman: hull of the panel in official photograph 0, anticlockwise, in fractions of its box, y down (measurements.json).
const WOMAN_OUTLINE := [[0, .58], [.0008, .8562], [.0055, .9804], [.0575, 1], [.4299, 1], [.9654, .9942], [.9929, .939], [.9992, .5109],
	[1, .4281], [.9937, .3314], [.9835, .2762], [.9638, .2348], [.9386, .1933], [.9039, .1519], [.8575, .1105], [.7913, .069], [.7307, .0414],
	[.6394, .0138], [.478, 0], [.3614, .0138], [.3071, .0276], [.2362, .0552], [.1866, .0829], [.1449, .1105], [.1118, .1381], [.0748, .1795],
	[.0449, .2209], [.0252, .2624], [.0118, .3038], [.0047, .359], [.0016, .4143], [0, .5662]]
# Engaged frame bands in fractions of the photographed box: sides, top, bottom sill. Depth and recess are guesses.
const WOMAN_BAND := Vector3(.0976, .0679, .0978)
const WOMAN_DEPTH := .04
const WOMAN_RECESS := .024
# Diptych: thickness is not catalogued; 1.25 cm at the highest relief is a guess for a 24 cm Gothic leaf.
const LEAF_GAP := .1 # cm between the leaves at the hinge
# Museum mount, by eye from 41.2 and 49.8s (about +-30%): width, slope length, low edge, slope.
const MOUNT := Vector3(.34, .30, .012)
const MOUNT_SLOPE := deg_to_rad(22.0)
# Book cover: splay of each board from straight back, by eye from 49.8s; ring centre above the deck.
const COVER_SPLAY := deg_to_rad(20.0)
const COVER_RING := Vector3(0, 20.5, -3.2)
# Emblem book: 116 leaves open at folios 14v-15r, so 22 leaves lie left and 94 right. Thickness 2 cm is a guess.
const BOOK_LEFT := .005
const BOOK_RIGHT := .015
const BOOK_BOARD := .003
const BOOK_OPENING := deg_to_rad(110.0) # between the two page planes, by eye from 41.2 and 46.4s (about +-20 degrees)
const BOOK_RECLINE := deg_to_rad(40.0) # spine above the deck, by eye (about +-15 degrees)
# Albarello: [height cm, radius cm] from the left edge of official photograph 0 (the right edge runs into the cast
# shadow), scaled 0.9875 so the shoulder is the catalogue 13 cm, then over the lip and down the inside.
# The inner floor height is not observed.
const JAR := [[0, 4.9], [.4, 5.3], [.7, 5.62], [1.3, 5.83], [1.7, 5.6], [2.2, 5.09], [3.1, 5.5], [4.3, 5.97], [5.7, 5.74], [7.3, 5.29], [9.6, 4.82],
	[11.6, 4.65], [14.4, 4.9], [17.6, 5.51], [20, 6.04], [21.4, 6.5], [22, 6.26], [22.6, 5.7], [23.1, 4.95], [23.4, 4.65], [23.8, 4.6], [23.9, 5.05],
	[24.1, 5.05], [24.1, 4.4], [21, 4.25]]

static func volume(shell: PackedVector3Array) -> float:
	var sum := 0.0
	for i in range(0, shell.size(), 3):
		sum += shell[i].dot(shell[i + 2].cross(shell[i + 1]))
	return sum / 6

## Base.shell, turned outward whichever way the rings were given.
static func solid(rings: Array) -> PackedVector3Array:
	var shell: PackedVector3Array = Base.shell(rings)
	if volume(shell) < 0:
		for i in range(0, shell.size(), 3):
			var swap := shell[i + 1]
			shell[i + 1] = shell[i + 2]
			shell[i + 2] = swap
	return shell

## One closed mitred frame strip between two corners. `section` is a convex polygon of [t, z]:
## t runs from the outer edge (0) to the sight edge (1), z is metres out from the wall.
static func strip(outer_a: Vector2, sight_a: Vector2, outer_b: Vector2, sight_b: Vector2, section: Array) -> PackedVector3Array:
	var rings := []
	for ends in [[outer_a, sight_a], [outer_b, sight_b]]:
		var ring := PackedVector3Array()
		for s in section:
			var p: Vector2 = ends[0].lerp(ends[1], s[0])
			ring.append(Vector3(p.x, p.y, s[1]))
		rings.append(ring)
	return solid(rings)

## A flat source image on every chosen face of the parts whose name starts with `part`: UV = rect.position + rect.size *
## ((p - origin) . u, (p - origin) . v). `keep` takes a triangle's centre and outward normal.
static func skin(texture: String, part: String, keep: Callable, origin: Vector3, u: Vector3, v: Vector3, rect := Rect2(0, 0, 1, 1), painted := false) -> Dictionary:
	return {"texture": texture, "part": part, "keep": keep, "origin": origin, "u": u, "v": v, "rect": rect, "painted": painted}

static func pixels(x0: float, y0: float, x1: float, y1: float, width: float, height: float) -> Rect2:
	return Rect2(x0 / width, y0 / height, (x1 - x0) / width, (y1 - y0) / height)

## Wall-local metres: origin on the wall behind the panel centre, +Z into the room.
## Closed back board, the painted panel as its own slab, and four mitred sides of a three-step moulding.
static func cleric() -> Dictionary:
	var size: Vector3 = OBJECTS.cleric.size
	var sight := Vector2(size.x, size.y) / 2
	var outer := sight + CLERIC_BAND
	var parts := [
		["backboard", "frame_grey", Base.box(Vector3(-outer.x, -outer.y, 0), Vector3(outer.x, outer.y, .012))],
		["panel", "frame_grey", Base.box(Vector3(-sight.x, -sight.y, .012), Vector3(sight.x, sight.y, .022))],
	]
	# Outer rail to the full catalogue depth, a lower step, and the slope down to the painting.
	var sections := {"rail": [[0, .012], [.3, .012], [.3, size.z], [0, size.z]], "step": [[.3, .012], [.62, .012], [.62, .046], [.3, .046]],
		"slope": [[.62, .012], [1, .012], [1, .027], [.62, .042]]}
	var corners := [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]
	for k in 4:
		var a: Vector2 = corners[k]
		var b: Vector2 = corners[(k + 1) % 4]
		for name in sections:
			parts.append(["frame %s %d" % [name, k], "frame_grey", strip(outer * a, sight * a, outer * b, sight * b, sections[name])])
	var front := func(_c: Vector3, n: Vector3) -> bool: return n.z > .3
	return {"parts": parts, "skins": [
		skin("cleric", "panel", front, Vector3(-sight.x, sight.y, 0), Vector3.RIGHT / size.x, Vector3.DOWN / size.y, Rect2(0, 0, 1, 1), true),
		skin("cleric_frame", "frame", front, Vector3(-outer.x, outer.y, 0), Vector3.RIGHT / (outer.x * 2), Vector3.DOWN / (outer.y * 2)),
	]}

## Wall-local metres: origin on the wall behind the centre of the catalogue box, +Z into the room.
## The arched panel is one closed plate; its engaged frame is a ring of closed strips with a flat face and an inner slope.
static func woman() -> Dictionary:
	var size: Vector3 = OBJECTS.woman.size
	var outline := PackedVector2Array()
	var outline_cm := PackedVector2Array()
	for q in WOMAN_OUTLINE:
		outline.append(Vector2((q[0] - .5) * size.x, (.5 - q[1]) * size.y))
		outline_cm.append(outline[-1] / CM)
	var back := WOMAN_DEPTH - WOMAN_RECESS
	var parts := [["panel", "frame_brown", Metal.plate(outline_cm, Vector2.ZERO, [[0, 1], [back / CM, 1]])]]
	# Sight edge: the outline drawn in toward the arch centre by the photographed bands.
	var centre := Vector2(0, size.y / 2 - size.x / 2)
	var inner := PackedVector2Array()
	for p in outline:
		var up := p.y > centre.y
		var band := WOMAN_BAND.y * size.y / (size.y / 2 - centre.y) if up else WOMAN_BAND.z * size.y / (centre.y + size.y / 2)
		inner.append(Vector2(p.x * (1 - WOMAN_BAND.x * 2), centre.y + (p.y - centre.y) * (1 - band)))
	var section := [[0, back], [1, back], [.55, WOMAN_DEPTH], [0, WOMAN_DEPTH]]
	for i in outline.size():
		var j := (i + 1) % outline.size()
		parts.append(["frame %d" % i, "frame_brown", strip(outline[i], inner[i], outline[j], inner[j], section)])
	var front := func(_c: Vector3, n: Vector3) -> bool: return n.z > .3
	return {"parts": parts, "skins": [
		# Only if the caller gives a separate frame image (a Muse pass); otherwise the photograph's own frame is used.
		skin("woman_frame", "frame", front, Vector3(-size.x / 2, size.y / 2, 0), Vector3.RIGHT / size.x, Vector3.DOWN / size.y),
		skin("woman_front", "", front,
			Vector3(-size.x / 2, size.y / 2, 0), Vector3.RIGHT / size.x, Vector3.DOWN / size.y, pixels(34, 32, 1304, 1770, 1324, 1793), true),
		# Official photograph 1: the painted coat of arms on the back, seen from behind.
		skin("woman_rear", "panel", func(_c: Vector3, n: Vector3) -> bool: return n.z < -.5,
			Vector3(size.x / 2, size.y / 2, 0), Vector3.LEFT / size.x, Vector3.DOWN / size.y, pixels(24, 21, 1300, 1767, 1324, 1791), true),
	]}

## One ivory leaf, upright, centred on x cm: back plate, raised border, the band between the tiers,
## and under each of the six arches one broad raised mass with a pointed head. No figures are carved.
static func leaf(side: String, x: float) -> Array:
	var w := OBJECTS.diptych.size.x * 50
	var h := OBJECTS.diptych.size.y * 100
	var at := Vector3(x, 0, 0)
	var parts := [
		[side + " plate", "ivory", Metal.box(at + Vector3(-w, 0, 0), at + Vector3(w, h, .5))],
		[side + " rim left", "ivory", Metal.box(at + Vector3(-w, 0, .5), at + Vector3(-w + .4, h, 1))],
		[side + " rim right", "ivory", Metal.box(at + Vector3(w - .4, 0, .5), at + Vector3(w, h, 1))],
		[side + " rim foot", "ivory", Metal.box(at + Vector3(-w + .4, 0, .5), at + Vector3(w - .4, .4, 1))],
		[side + " rim head", "ivory", Metal.box(at + Vector3(-w + .4, h - .5, .5), at + Vector3(w - .4, h, 1))],
		[side + " tier band", "ivory", Metal.box(at + Vector3(-w + .4, 11.7, .5), at + Vector3(w - .4, 12.7, .95))],
	]
	var bay := (w * 2 - .8) / 3
	for tier in 2:
		var foot := .5 + tier * 12.3
		for k in 3:
			var cx := x - w + .4 + bay * (k + .5)
			var half := bay / 2 - .12
			var mass := PackedVector2Array([Vector2(cx - half, foot), Vector2(cx + half, foot), Vector2(cx + half, foot + 8.4), Vector2(cx + half * .62, foot + 9.8),
				Vector2(cx, foot + 10.7), Vector2(cx - half * .62, foot + 9.8), Vector2(cx - half, foot + 8.4)])
			parts.append(["%s mass %d %d" % [side, tier, k], "ivory", Metal.plate(mass, Vector2(cx, foot + 5), [[.5, 1], [.95, 1], [1.25, .78]])])
	return parts

## Diptych-local metres: origin under the hinge, both leaves upright side by side, +Z the carved faces.
## The right leaf takes official photograph 0. The left leaf is blanked in that photograph, so it takes the film.
static func diptych() -> Dictionary:
	var size: Vector3 = OBJECTS.diptych.size
	var x := size.x / 2 + LEAF_GAP * CM / 2
	var front := func(_c: Vector3, n: Vector3) -> bool: return n.z > .3
	# Plain backs keep their own darker colour from official photograph 1; no texture.
	return {"parts": leaf("left", -x * 100) + leaf("right", x * 100),
		"tint": func(_name: String, _c: Vector3, n: Vector3) -> String: return "ivory_back" if n.z < -.5 else "",
		"skins": [
		skin("diptych_left_native", "left", front, Vector3(-x - size.x / 2, size.y, 0), Vector3.RIGHT / size.x, Vector3.DOWN / size.y),
		skin("diptych_front", "right", front, Vector3(x - size.x / 2, size.y, 0), Vector3.RIGHT / size.x, Vector3.DOWN / size.y, pixels(638, 42, 1187, 1044, 1324, 1126)),
	]}

## Mount-local metres: origin on the deck under the mount centre, low edge toward +Z. Display furniture, not catalogued.
static func diptych_mount() -> Dictionary:
	var run := MOUNT.y * cos(MOUNT_SLOPE)
	var high := MOUNT.z + MOUNT.y * sin(MOUNT_SLOPE)
	var rings := []
	for x in [-MOUNT.x / 2, MOUNT.x / 2]:
		rings.append(PackedVector3Array([Vector3(x, 0, run / 2), Vector3(x, 0, -run / 2), Vector3(x, high, -run / 2), Vector3(x, MOUNT.z, run / 2)]))
	return {"parts": [["mount", "mount", solid(rings)]], "skins": []}

## Cover-local metres: origin on the deck under the spine, +Z the spine as filmed, the two boards splayed open behind it.
## It stands on its tail edge with three chains raised to a ring. The catalogue 14 x 8.6 x 5.1 cm is the closed cover.
static func bookcover() -> Dictionary:
	var size: Vector3 = OBJECTS.bookcover.size
	var half := size.z * 50
	var tall := size.y * 100
	var board := size.x * 100
	# Five raised feathered bands and four recessed filigree panels, heights from official photograph 1.
	var levels := []
	var y := 0.0
	for edge in [.25, 1.26, 3.64, 4.33, 6.59, 7.6, 9.92, 10.61, 12.93, 13.94, tall]:
		var raised := levels.size() % 4 == 2
		for at in [y, edge]:
			levels.append([at * CM, 0, -.5 * CM, (half if raised else half - .1) * CM, (.6 if raised else .45) * CM])
		y = edge
	var parts := [["spine", "silver", Base.slab(levels)]]
	var skins := [skin("bookcover_spine", "spine", func(_c: Vector3, n: Vector3) -> bool: return n.z > .5,
		Vector3(-half, tall, 0) * CM, Vector3.RIGHT / size.z, Vector3.DOWN / size.y, pixels(455, 100, 825, 1215, 1324, 1324))]
	var heads := [Vector3(0, tall, -.5) * CM]
	for side in [-1, 1]:
		var name := "board left" if side < 0 else "board right"
		var hinge := Transform3D(Basis(Vector3.UP, -side * COVER_SPLAY), Vector3(side * half, 0, -.5) * CM)
		var slab: PackedVector3Array = Metal.box(Vector3(min(0, -side * .45), 0, -board), Vector3(max(0, -side * .45), tall, 0))
		parts.append([name, "silver", hinge * slab])
		# Round boss at the middle of the outer face, from official photograph 0.
		var out := hinge.basis * Vector3(side, 0, 0)
		var middle := hinge * (Vector3(0, tall / 2, -board / 2) * CM)
		parts.append([name + " boss", "silver", Base.limb([[middle - out * .1 * CM, 1.35 * CM, 1.35 * CM], [middle + out * .3 * CM, 1.15 * CM, 1.15 * CM]], 8)])
		heads.append(hinge * (Vector3(-side * .22, tall, -board + .5) * CM))
		if side > 0:
			# Official photograph 0 shows one board; it goes on the board the film shows. The other stays plain.
			skins.append(skin("bookcover_board", name, func(_c: Vector3, n: Vector3) -> bool: return n.dot(out) > .9,
				hinge * (Vector3(0, tall, 0) * CM), hinge.basis * Vector3.FORWARD / size.x, Vector3.DOWN / size.y))
	# Ring of eight straight segments facing the room, and three stiff chains up to it. No link is modelled.
	var ring := COVER_RING * CM
	for k in 8:
		var a := Vector2.from_angle(TAU * k / 8) * .9 * CM
		var b := Vector2.from_angle(TAU * (k + 1) / 8) * .9 * CM
		parts.append(["ring %d" % k, "silver", Base.limb([[ring + Vector3(a.x, a.y, 0), .16 * CM, .16 * CM], [ring + Vector3(b.x, b.y, 0), .16 * CM, .16 * CM]], 4)])
	for k in heads.size():
		var top := ring + Vector3((k - 1) * .35, -.9, 0) * CM
		var sag: Vector3 = heads[k].lerp(top, .5) + Vector3(0, -.6, 0) * CM
		parts.append(["chain %d" % k, "silver", Base.limb([[heads[k], .2 * CM, .2 * CM], [sag, .2 * CM, .2 * CM], [top, .2 * CM, .2 * CM]], 4)])
	return {"parts": parts, "skins": skins}

## The two halves of the open book and the cradle, in book metres: tail of the spine at the origin, head along +Y,
## pages facing +Z. `lift` then reclines the book and stands its lowest point on the deck.
static func emblem_halves() -> Dictionary:
	var page: Vector3 = OBJECTS.emblem.size
	var fold := (PI - BOOK_OPENING) / 2
	var book := []
	var cradle := []
	var skins := []
	for side in [-1, 1]:
		var name := "left" if side < 0 else "right"
		var thick := BOOK_LEFT if side < 0 else BOOK_RIGHT
		var hinge := Transform3D(Basis(Vector3.UP, -side * fold), Vector3.ZERO)
		var x := func(a: float, b: float) -> Array: return [min(side * a, side * b), max(side * a, side * b)]
		var span: Array = x.call(0, page.x)
		book.append([name + " block", "page_edge", hinge * Base.box(Vector3(span[0], 0, -thick), Vector3(span[1], page.y, 0))])
		span = x.call(0, page.x + .004)
		book.append([name + " board", "binding", hinge * Base.box(Vector3(span[0], -.003, -thick - BOOK_BOARD), Vector3(span[1], page.y + .003, -thick))])
		# Clear rest under the board and a lip that holds the tail edge.
		span = x.call(.004, .125)
		var under := -thick - BOOK_BOARD
		cradle.append([name + " rest", "acrylic", hinge * Base.box(Vector3(span[0], -.008, under - .004), Vector3(span[1], .16, under))])
		cradle.append([name + " lip", "acrylic", hinge * Base.box(Vector3(span[0], -.012, under - .004), Vector3(span[1], -.008, under + .012))])
		# Page face: [texture, part, top corner at the outer or gutter edge, u, v, facing].
		skins.append(["emblem_%s_page" % name, name + " block", hinge * Vector3(-page.x if side < 0 else 0.0, page.y, 0),
			hinge.basis.x / page.x, Vector3.DOWN / page.y, hinge.basis.z])
	book.append(["spine", "binding", Base.limb([[Vector3(0, -.003, -.011), .007, .011], [Vector3(0, page.y + .003, -.011), .007, .011]], 6)])
	return {"book": book, "cradle": cradle, "skins": skins}

## Reclines book metres about the tail and stands the lowest point of the book and cradle together on the deck.
static func emblem_lift() -> Transform3D:
	var halves := emblem_halves()
	var recline := Transform3D(Basis(Vector3.RIGHT, BOOK_RECLINE - PI / 2), Vector3.ZERO)
	var low := INF
	for part in halves.book + halves.cradle:
		for p in recline * part[2]:
			low = min(low, p.y)
	return Transform3D(recline.basis, Vector3(0, -low, 0))

## Book-on-deck metres: origin on the deck under the tail of the spine, +Z toward the reader, open at emblem 15.
## The page faces carry the straightened film. No other copy of the book is used anywhere.
static func emblem() -> Dictionary:
	var halves := emblem_halves()
	var lift := emblem_lift()
	var parts := []
	for part in halves.book:
		parts.append([part[0], part[1], lift * part[2]])
	var skins := []
	for s in halves.skins:
		var facing: Vector3 = lift.basis * s[5]
		skins.append(skin(s[0], s[1], func(_c: Vector3, n: Vector3) -> bool: return n.dot(facing) > .9, lift * s[2], lift.basis * s[3], lift.basis * s[4]))
	return {"parts": parts, "skins": skins}

## Same metres as emblem(): two clear rests with lips, and one upright fin under the spine. Museum furniture, by eye.
static func emblem_cradle() -> Dictionary:
	var lift := emblem_lift()
	var parts := []
	for part in emblem_halves().cradle:
		parts.append([part[0], part[1], lift * part[2]])
	var under := -BOOK_RIGHT - BOOK_BOARD - .012
	var tail: Vector3 = lift * Vector3(0, .01, under)
	var head: Vector3 = lift * Vector3(0, .15, under)
	var rings := []
	for x in [-.003, .003]:
		rings.append(PackedVector3Array([Vector3(x, 0, tail.z), Vector3(x, tail.y, tail.z), Vector3(x, head.y, head.z), Vector3(x, 0, head.z)]))
	parts.append(["fin", "acrylic", solid(rings)])
	return {"parts": parts, "skins": []}

## Jar-local metres: origin under the foot centre, +Z the saint in his cartouche (official photograph 0).
## One closed sixteen-sided shell with a real mouth. Each photograph is laid straight back onto the half that faces it,
## so the facets at each side carry the stretched limb of a photograph and the two meet in a seam nobody has seen.
static func albarello() -> Dictionary:
	var size: Vector3 = OBJECTS.albarello.size
	var wall := func(c: Vector3, n: Vector3) -> bool: return abs(n.y) < .9 and n.dot(Vector3(c.x, 0, c.z)) > 0
	# Sampled 5% inside the silhouette, so the limb facets take glaze and not the studio ground.
	var across := size.x / .95
	# Photograph 0: rim plane at row 333, base at row 1545, axis at column 664. Photograph 1 sits 12 rows higher, axis 681.
	return {"parts": [["jar", "jar_blue", Metal.lathe(Metal.ngon(16), JAR)]],
		# Dark unglazed inside (film 46.4s) and the ochre lip and underside; everything else is the blue ground.
		"tint": func(_name: String, c: Vector3, n: Vector3) -> String:
			if n.dot(Vector3(c.x, 0, c.z)) < -.01 or (n.y > .9 and c.y < size.y - .01):
				return "jar_inside"
			return "jar_rim" if abs(n.y) > .9 else "",
		"skins": [
		skin("albarello_front", "jar", func(c: Vector3, n: Vector3) -> bool: return wall.call(c, n) and n.z > 0,
			Vector3(-across / 2, size.y, 0), Vector3.RIGHT / across, Vector3.DOWN / size.y, pixels(333, 333, 995, 1545, 1324, 1765)),
		skin("albarello_rear", "jar", func(c: Vector3, n: Vector3) -> bool: return wall.call(c, n) and n.z <= 0,
			Vector3(across / 2, size.y, 0), Vector3.LEFT / across, Vector3.DOWN / size.y, pixels(350, 321, 1012, 1533, 1324, 1765)),
	]}

static func parts(key: String) -> Dictionary:
	return {"cleric": cleric, "woman": woman, "diptych": diptych, "diptych_mount": diptych_mount, "bookcover": bookcover,
		"emblem": emblem, "emblem_cradle": emblem_cradle, "albarello": albarello}[key].call()

## Metals take light and highlights; nothing is emissive. Acrylic is the unshaded glass of seated_woman_asset.gd.
static func material(kind: String) -> StandardMaterial3D:
	var m: StandardMaterial3D = Base.flat(COLORS[kind])
	if kind in METALS:
		m.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
		m.metallic = .35 # Metal's .6 reads near black here: the boards are broad flat faces with nothing to reflect
		m.roughness = .45
	if kind == "acrylic":
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m

## Textures from this folder's source files, with no Godot import: {key: ImageTexture}. Missing files are left out.
static func textures(dir: String) -> Dictionary:
	var out := {}
	for key in TEXTURES:
		var image := Image.new()
		if image.load(dir.path_join(TEXTURES[key])) == OK:
			image.generate_mipmaps()
			out[key] = ImageTexture.create_from_image(image)
	return out

## One object as a node: a mesh per flat colour and a mesh per source image, origin and axes as its function says.
## `images` is {key: Texture2D} as textures() returns; leave it empty for flat observed colours.
## `painted` turns a painting's Texture2D into the room's painting material (painting_asset.gd `mat`), passed by the
## caller; without it a painting is drawn like the other source images, lit and matt.
static func build(key: String, images := {}, painted := Callable()) -> Node3D:
	var spec := parts(key)
	var node := Node3D.new()
	node.name = key.to_pascal_case()
	var flat := {}
	var skinned := {}
	for part in spec.parts:
		var shell: PackedVector3Array = part[2]
		for i in range(0, shell.size(), 3):
			var normal := (shell[i + 2] - shell[i]).cross(shell[i + 1] - shell[i]).normalized()
			var centre := (shell[i] + shell[i + 1] + shell[i + 2]) / 3
			# A face is its part's colour, or the object's own override for that face, or a source image.
			var target: Variant = part[1]
			if spec.has("tint") and spec.tint.call(part[0], centre, normal) != "":
				target = spec.tint.call(part[0], centre, normal)
			for k in spec.skins.size():
				var s: Dictionary = spec.skins[k]
				if images.has(s.texture) and part[0].begins_with(s.part) and s.keep.call(centre, normal):
					target = k
					break
			var bucket: Dictionary = skinned if target is int else flat
			if not bucket.has(target):
				bucket[target] = PackedVector3Array()
			bucket[target].append_array([shell[i], shell[i + 1], shell[i + 2]])
	for kind in flat:
		var visual: MeshInstance3D = Base.mesh([flat[kind]], material(kind))
		visual.name = kind
		node.add_child(visual)
	for k in skinned:
		var s: Dictionary = spec.skins[k]
		var soup: PackedVector3Array = skinned[k]
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for i in range(0, soup.size(), 3):
			st.set_normal((soup[i + 2] - soup[i]).cross(soup[i + 1] - soup[i]).normalized())
			for j in 3:
				var p: Vector3 = soup[i + j] - s.origin
				st.set_uv(s.rect.position + s.rect.size * Vector2(p.dot(s.u), p.dot(s.v)))
				st.add_vertex(soup[i + j])
		var visual := MeshInstance3D.new()
		visual.name = "source " + s.texture
		visual.mesh = st.commit()
		if s.painted and painted.is_valid():
			visual.material_override = painted.call(images[s.texture])
		else:
			var m: StandardMaterial3D = Base.flat(Color.WHITE)
			m.albedo_texture = images[s.texture]
			visual.material_override = m
		node.add_child(visual)
	if OBJECTS.has(key):
		for field in ["accession", "catalogue_id", "identity", "size", "unresolved"]:
			node.set_meta("catalogue_" + field, OBJECTS[key][field])
		for field in OBJECTS[key].flags:
			node.set_meta(field, OBJECTS[key].flags[field])
		for flag in FLAGS:
			node.set_meta(flag, false)
		node.set_meta("source_images", skinned.keys().map(func(k): return spec.skins[k].texture))
	return node

## The object with the museum furniture it is filmed on: the diptych lying on its sloped mount, the book on its cradle.
## The other four are returned as build() gives them. Origin on the deck (or the wall for the two portraits).
static func on_display(key: String, images := {}, painted := Callable()) -> Node3D:
	var object := build(key, images, painted)
	if key == "diptych":
		var node := build("diptych_mount")
		node.name = "DiptychOnMount"
		var run := MOUNT.y * cos(MOUNT_SLOPE)
		var up := Vector3(0, sin(MOUNT_SLOPE), -cos(MOUNT_SLOPE))
		object.rotation.x = MOUNT_SLOPE - PI / 2
		object.position = Vector3(0, MOUNT.z, run / 2) + up * .025
		node.add_child(object)
		return node
	if key == "emblem":
		var node := build("emblem_cradle")
		node.name = "EmblemOnCradle"
		node.add_child(object)
		return node
	return object
