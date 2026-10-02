## Four small objects from the tall medieval case, IMG_6382 100.5..112.9s, as closed low polygon masses:
## Monstrance RISD 40.002 (API 1443596), probable Communion Beaker 1992.051 (1550551),
## probable Pyx 30.011 (1230716) and Pax 52.002 (1211626).
## The catalogue fixes each height, and the pax width and depth without its handle. Every other measure
## is read from the official photographs and is provisional. Geometry prototypes only: no Muse texture,
## no engraved, enamelled or carved detail, not installed in a case.
extends RefCounted

const Base := preload("seated_woman_asset.gd")

const CM := .01
const OBJECTS := {
	"monstrance": {"accession": "40.002", "catalogue_id": "1443596", "identity": "matched", "height": .464},
	"beaker": {"accession": "1992.051", "catalogue_id": "1550551", "identity": "probable", "height": .14},
	"pyx": {"accession": "30.011", "catalogue_id": "1230716", "identity": "probable", "height": .089},
	"pax": {"accession": "52.002", "catalogue_id": "1211626", "identity": "matched", "height": .121},
}
# Median pixels of the official photographs; the stand is a guess, it is not catalogued.
const COLORS := {"gilt": Color("a58a64"), "silver": Color("d9d9d3"), "pyx_gilt": Color("907951"), "enamel": Color("283647"),
	"mount": Color("443d37"), "ground": Color("4f5a69"), "relief": Color("c8c3ba"), "stand": Color("c9c9c4")}
const METALS := ["gilt", "silver", "pyx_gilt", "mount", "stand"]
# Monstrance plan depth / width is .70 between official photographs 2 and 0; .81 is that ratio for a hexagon's corner radius.
const HEX_DEPTH := .81
# Museum rod behind the pax, by eye from 102.2 and 105.7s (about +-30%): rod length from the foreshortened rod against the
# 8.9 cm width, lean from the plaque's foreshortening seen from the front and its slope seen from the side. Nothing is measured.
const PAX_STAND_HEIGHT := .15
const PAX_LEAN := deg_to_rad(55.0)
const PAX_GRIP := Vector3(0, .04, -.011) # where the rod meets the back, a third of the way up

## Unit plan polygon, anticlockwise seen from above.
static func ngon(n: int, phase := 0.0) -> PackedVector2Array:
	var out := PackedVector2Array()
	for k in n:
		out.append(Vector2.from_angle(TAU * k / n + phase))
	return out

## Ten lobes with a spur between each pair, lobes on the long axis: per lobe [spur, lobe edge, lobe edge].
static func star(spur: float, lobe: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for k in 10:
		var a := TAU * k / 10
		out.append_array([Vector2.from_angle(a - TAU / 20) * spur, Vector2.from_angle(a - .19) * lobe, Vector2.from_angle(a + .19) * lobe])
	return out

## Closed upright shell through levels of [y cm, plan, radius x cm, radius z cm]; first and last plan must be convex.
static func stack(levels: Array) -> PackedVector3Array:
	var rings := []
	for l in levels:
		var ring := PackedVector3Array()
		for p in l[1]:
			ring.append(Vector3(p.x * l[2], l[0], -p.y * l[3]) * CM)
		rings.append(ring)
	return Base.shell(rings)

## One plan turned through levels of [y cm, radius cm]; depth is radius * squash.
static func lathe(plan: PackedVector2Array, levels: Array, squash := 1.0) -> PackedVector3Array:
	return stack(levels.map(func(l): return [l[0], plan, l[1], l[1] * squash]))

## Closed plate through layers of [z cm, scale about the outline's own centre]; outline is convex, anticlockwise seen from +Z.
static func plate(outline: PackedVector2Array, centre: Vector2, layers: Array) -> PackedVector3Array:
	var rings := []
	for l in layers:
		var ring := PackedVector3Array()
		for p in outline:
			var q: Vector2 = centre + (p - centre) * l[1]
			ring.append(Vector3(q.x, q.y, l[0]) * CM)
		rings.append(ring)
	return Base.shell(rings)

static func box(lo: Vector3, hi: Vector3) -> PackedVector3Array:
	return Base.box(lo * CM, hi * CM)

static func corner(k: int, r: float, y: float) -> Vector3:
	var p := Vector2.from_angle(TAU * k / 6)
	return Vector3(p.x * r, y, -p.y * r * HEX_DEPTH) * CM

## Monstrance-local metres: origin under the foot centre, +Z the broad face of official photograph 0, X the long axis.
## Each entry is [name, colour key, closed shell]. The chamber is open between its posts, as the object is.
static func monstrance() -> Array:
	var hex := ngon(6)
	var parts := []
	# Ten-lobed foot 17.6 x 12.4 cm: thin flange with a spur between lobes, upright pierced rim, low trumpet to the stem.
	var rx := 9.25
	var rz := 6.2
	parts.append(["foot", "gilt", stack([[0, star(.2, .2), rx, rz], [0, star(1, .94), rx, rz], [.25, star(1, .94), rx, rz],
		[.25, star(.7, .9), rx, rz], [1.2, star(.7, .9), rx, rz], [2, star(.58, .7), rx, rz], [2.7, star(.3, .33), rx, rz], [4, star(.17, .17), rx, rz]])])
	# Hexagonal stem: two architectural knops as plain chamfered blocks, collar, and the calyx spreading under the platform.
	parts.append(["stem and knops", "gilt", lathe(hex, [[3.9, 1.25], [4.4, 1.25], [4.65, 2.35], [6.55, 2.35], [6.8, 1.12], [8.9, 1.12], [9.2, 2.75], [11.4, 2.75],
		[11.7, 1.12], [14.2, 1.12], [14.2, 2.2], [15.4, 2.2], [15.6, 1.9], [16.3, 1.95], [17.4, 4.6]], HEX_DEPTH)])
	parts.append(["platform", "gilt", lathe(hex, [[17.4, 4.6], [17.6, 5.9], [19.6, 5.9], [19.8, 5.5]], HEX_DEPTH)])
	# Lower storey: six corner posts under a plain arcade band; the glazed chamber between them is left open.
	for k in 6:
		parts.append(["lower post %d" % k, "gilt", Base.limb([[corner(k, 5, 19.8), .5 * CM, .5 * CM], [corner(k, 5, 27.4), .5 * CM, .5 * CM]], 4)])
		parts.append(["lower arcade %d" % k, "gilt", Base.limb([[corner(k, 5, 26.2), .42 * CM, 1.7 * CM], [corner(k + 1, 5, 26.2), .42 * CM, 1.7 * CM]], 4)])
		# Free-standing buttress pinnacle on each platform corner.
		parts.append(["pinnacle %d" % k, "gilt", Base.limb([[corner(k, 5.6, 19.8), .3 * CM, .3 * CM], [corner(k, 5.6, 26), .3 * CM, .3 * CM], [corner(k, 5.6, 27.6), .06 * CM, .06 * CM]], 4)])
	parts.append(["storey floor", "gilt", lathe(hex, [[27.4, 4.3], [27.6, 4.5], [28.2, 4.5], [28.4, 3.4]], HEX_DEPTH)])
	# Narrower upper storey, also open, then cornice and spire in one shell.
	for k in 6:
		parts.append(["upper post %d" % k, "gilt", Base.limb([[corner(k, 2.9, 28.2), .4 * CM, .4 * CM], [corner(k, 2.9, 35), .4 * CM, .4 * CM]], 4)])
		parts.append(["upper arcade %d" % k, "gilt", Base.limb([[corner(k, 2.9, 34.2), .35 * CM, 1.13 * CM], [corner(k + 1, 2.9, 34.2), .35 * CM, 1.13 * CM]], 4)])
	parts.append(["cornice and spire", "gilt", lathe(hex, [[35, 3], [35.2, 3.3], [35.9, 3.3], [36.3, 1.9], [42.8, .6]], HEX_DEPTH)])
	# Knob and flat leaf finial; its tip is the catalogue height.
	parts.append(["finial", "gilt", stack([[42.7, hex, .5, .4], [43, hex, .75, .6], [43.4, hex, .45, .36], [44.6, hex, 1.1, .45], [46.4, hex, .12, .1]])])
	return parts

## Beaker-local metres: origin under the foot centre. One shell with a real mouth; the inner floor height is not observed.
static func beaker() -> Array:
	# Foot rim and dome, frieze band, rope collar as a plain bulge, straight flaring body, everted lip, then down the inside.
	return [["beaker", "silver", lathe(ngon(12), [[0, 3.6], [.3, 3.6], [.4, 3.35], [.85, 2.85], [1.05, 2.55], [2.05, 2.55], [2.15, 2.95], [2.8, 3.1],
		[3.45, 2.95], [3.6, 2.65], [13, 4.38], [14, 4.73], [14, 4.58], [13, 4.25], [3.8, 2.5]])]]

## Pyx-local metres: origin under the base centre, +Z the clasp, hinge behind, cross arms along X.
static func pyx() -> Array:
	var circle := ngon(12)
	return [
		["body", "enamel", lathe(circle, [[0, 3.15], [3.7, 3.15]])],
		["lid", "enamel", lathe(circle, [[3.7, 3.22], [3.95, 3.22], [5.9, 1.3]])],
		["lid top", "pyx_gilt", lathe(circle, [[5.9, 1.3], [7.2, .55]])],
		["knob", "pyx_gilt", lathe(ngon(6), [[7.15, .3], [7.35, .42], [7.6, .42], [7.75, .25]])],
		["cross upright", "pyx_gilt", box(Vector3(-.13, 7.7, -.1), Vector3(.13, 8.9, .1))],
		["cross arms", "pyx_gilt", box(Vector3(-.6, 8.24, -.1), Vector3(.6, 8.52, .1))],
		["hinge", "pyx_gilt", Base.limb([[Vector3(-.55, 3.8, -3.5) * CM, .33 * CM, .33 * CM], [Vector3(.55, 3.8, -3.5) * CM, .33 * CM, .33 * CM]], 6)],
		["clasp", "pyx_gilt", box(Vector3(-.65, 2.95, 3.1), Vector3(.65, 3.95, 3.5))],
		["hasp", "pyx_gilt", box(Vector3(-.2, 1.9, 3.15), Vector3(.2, 2.95, 3.4))],
	]

## Pax-local metres: origin under the centre of its lower edge, +Z the carved shell, standing upright.
## Catalogue 12.1 x 8.9 x 2.2 cm covers everything except "handle". The lean on its rod belongs to pax_on_stand().
static func pax() -> Array:
	# Pointed-arch outline read from official photograph 0, right side up, over the apex, left side down.
	var side := [Vector2(4.45, 0), Vector2(3.94, 4.5), Vector2(3, 8.7), Vector2(2.4, 10), Vector2(1.08, 11.2)]
	var outline := PackedVector2Array(side)
	outline.append(Vector2(0, 12.1))
	for i in range(side.size() - 1, -1, -1):
		outline.append(Vector2(-side[i].x, side[i].y))
	var centre := Vector2(0, 5.2)
	return [
		# Dark silver back and rim, then the shell bulging forward inside it.
		["mount", "mount", plate(outline, centre, [[-1.1, 1], [-.2, 1]])],
		["shell ground", "ground", plate(outline, centre, [[-.2, .93], [.3, .93], [.6, .75], [.75, .4]])],
		# White relief as plain raised masses: angel on the left, Virgin on the right, canopy above her.
		["angel mass", "relief", Base.limb([[Vector3(-2.3, 1, .45) * CM, 1.2 * CM, .35 * CM], [Vector3(-2.3, 4.5, .6) * CM, 1.3 * CM, .45 * CM],
			[Vector3(-2.2, 7.6, .55) * CM, 1 * CM, .4 * CM], [Vector3(-2.2, 8.7, .45) * CM, .45 * CM, .3 * CM]], 6)],
		["virgin mass", "relief", Base.limb([[Vector3(1.5, .5, .5) * CM, 1.7 * CM, .4 * CM], [Vector3(1.4, 4, .65) * CM, 1.5 * CM, .45 * CM],
			[Vector3(1.1, 7.2, .6) * CM, .9 * CM, .4 * CM], [Vector3(1, 8.5, .5) * CM, .5 * CM, .3 * CM]], 6)],
		["canopy mass", "relief", box(Vector3(-.4, 9.5, .3), Vector3(1.9, 10.15, 1.05))],
		# Strap handle on the plain back, from official photograph 1; how far it stands off is not catalogued.
		["handle", "mount", Base.limb([[Vector3(-.5, 6, -1.2) * CM, .53 * CM, .14 * CM], [Vector3(-.55, 5.6, -2.4) * CM, .53 * CM, .14 * CM],
			[Vector3(-.45, 3, -2.7) * CM, .53 * CM, .14 * CM], [Vector3(-.3, .15, -1.9) * CM, .53 * CM, .14 * CM]], 4)],
	]

## Stand-local metres: the museum's rod from the deck up to the pax. Not part of the object or its catalogue size.
static func pax_stand() -> Array:
	return [["rod", "stand", Base.limb([[Vector3.ZERO, .2 * CM, .2 * CM], [Vector3(0, PAX_STAND_HEIGHT, 0), .2 * CM, .2 * CM]], 6)]]

static func parts(key: String) -> Array:
	return {"monstrance": monstrance, "beaker": beaker, "pyx": pyx, "pax": pax, "pax_stand": pax_stand}[key].call()

## Metals take light and highlights; nothing is emissive. Shell and enamel stay matt.
static func material(kind: String) -> StandardMaterial3D:
	var m: StandardMaterial3D = Base.flat(COLORS[kind])
	if kind in METALS:
		m.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
		m.metallic = .6
		m.roughness = .4
	return m

## One object as a node, a mesh per colour key, origin under its base centre, +Z forward.
static func build(key: String) -> Node3D:
	var node := Node3D.new()
	node.name = key.to_pascal_case()
	var shells := {}
	for p in parts(key):
		if not shells.has(p[1]):
			shells[p[1]] = []
		shells[p[1]].append(p[2])
	for kind in shells:
		var visual: MeshInstance3D = Base.mesh(shells[kind], material(kind))
		visual.name = kind
		node.add_child(visual)
	for field in OBJECTS.get(key, {}):
		node.set_meta("catalogue_" + field, OBJECTS[key][field])
	return node

## The pax reclining on its rod, as filmed. Origin on the deck under the rod.
static func pax_on_stand() -> Node3D:
	var node := build("pax_stand")
	node.name = "PaxOnStand"
	var object := build("pax")
	object.rotation.x = -PAX_LEAN
	object.position = Vector3(0, PAX_STAND_HEIGHT, 0) - object.basis * PAX_GRIP
	node.add_child(object)
	return node
