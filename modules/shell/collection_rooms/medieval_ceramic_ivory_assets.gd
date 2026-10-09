## Two more objects from the tall medieval case, IMG_6382 100.5..110.5s, as closed low polygon masses:
## Leopold L. Foulem, God Save the Queens, RISD 2020.55 (API 1557221), and the probable
## Christ in Majesty ivory 2014.110 (1197491) with the museum wedge it lies on.
## Catalogue fixes 33 x 16 x 16 cm for the first and 15.9 x 6.4 cm for the second; the ivory's depth is not listed.
## Flat observed colours by default; build("queens", decals) can lay view crops on the ceramic. No carving. Not installed in a case.
extends RefCounted

const Base := preload("seated_woman_asset.gd")
const Metal := preload("medieval_metal_assets.gd")

const CM := .01
# `size` is the catalogue's width, height, depth in metres; 0 where the record gives none.
const OBJECTS := {
	"queens": {"accession": "2020.55", "catalogue_id": "1557221", "identity": "matched", "size": Vector3(.16, .33, .16),
		"front": "+Z is a Christ roundel (north as filmed); -Z the other roundel (south)",
		"boat": "-X is the filmed boat panel (east); +X (west) was never seen and stays plain",
		"unresolved": "west face; rear roundel is a copy of the front; underside; radii are photograph proportions widened 7.5% to the catalogue 16 cm; foot angle; flat colours unless decals are given"},
	"christ": {"accession": "2014.110", "catalogue_id": "1197491", "identity": "probable", "size": Vector3(.064, .159, 0),
		"front": "+Z is the carved face when upright; christ_on_wedge() lays it relief up, feet to +Z (north as filmed), head to -Z (deck centre)",
		"unresolved": "identity is probable; depth; back; all carving; wedge size, slope and position"},
}
# Median pixels of the official photographs; the wedge white is a guess, it is display furniture.
const COLORS := {"chrome": Color("c7c2ae"), "cast": Color("b6aa8e"), "ceramic": Color("ddddd3"), "border": Color("6f9bce"),
	"ivory": Color("c28c55"), "mount": Color("f0efea")}
const METALS := ["chrome", "cast"]
# The four feet stand 63 degrees round from the roundel face: toe offsets in official photographs 0 and 1.
const FOOT_TURN := deg_to_rad(63.0)
# Ceramic body bottom and top in cm, and the arcs the decals cover: boat panel with its lattice strips reads +-38 degrees
# in official photograph 1, the roundel fields take the rest. Decals sit .7 mm outside the faceted body.
const BODY := Vector2(8.3, 23.6)
const ROUNDEL_HALF := deg_to_rad(52.0)
const BOAT_HALF := deg_to_rad(38.0)
const DECAL_RADIUS := 7.0
# Relief thickness is not in the catalogue or any photograph: 1.4 cm is a guess for a 16 cm ivory appliqué.
const CHRIST_DEPTH := 1.4
# Museum wedge, by eye from 102.2/103.7/105.7s (about +-30%): cm width, high edge, length on the deck; and its low edge.
# A 19 cm slope at about 28 degrees: the side view at 105.7s reads between 24 and 35 degrees.
const WEDGE := Vector3(10.5, 10.1, 16.8)
const WEDGE_LOW := 1.2

## Queens-local metres: origin under the centre of the four feet, +Z a Christ roundel, boat panels to the sides.
## Each entry is [name, colour key, closed shell]. Lid, ceramic body, skirt, feet and ring are separate parts.
static func queens() -> Array:
	var circle := Metal.ngon(16)
	var parts := [
		# Bell skirt; its widest ring is the catalogue 16 cm. The underside is a plain closing face.
		["skirt", "chrome", Metal.lathe(circle, [[3.4, 7.95], [3.7, 8], [4.7, 7.95], [5.9, 7.75], [6.6, 7.45], [7.15, 7], [7.35, 6.4]])],
		["neck", "chrome", Metal.lathe(circle, [[7.35, 6.4], [8.3, 6.4]])],
		# Straight ceramic cylinder: blue lattice borders top and bottom, white glaze between where the decals sit.
		["body lower border", "border", Metal.lathe(circle, [[BODY.x, 6.93], [9.3, 6.93]])],
		["body field", "ceramic", Metal.lathe(circle, [[9.3, 6.93], [22.6, 6.93]])],
		["body upper border", "border", Metal.lathe(circle, [[22.6, 6.93], [BODY.y, 6.93]])],
		# Domed lid drawn up into a concave cone, then the collar under the ring.
		["lid", "chrome", Metal.lathe(circle, [[23.6, 6.9], [24, 7.05], [25, 7.02], [25.6, 6.6], [26.2, 5.4], [26.85, 4], [28.1, 2.2], [29.3, 1.36]])],
		["lid collar", "chrome", Metal.lathe(Metal.ngon(8), [[29.3, 1.3], [29.6, 1.2], [29.9, .76], [30.3, .8]])],
	]
	# Cast scroll feet as S-curved square legs: toe out, ankle in, knee out, top under the skirt.
	for k in 4:
		var turn := FOOT_TURN - PI / 2 + k * PI / 2
		var levels := []
		for l in [[0, 7.4, .55], [.5, 7.3, .5], [1.4, 6.9, .4], [2.5, 7.35, .65], [3.6, 6.5, .9]]:
			levels.append([l[0] * CM, l[1] * sin(turn) * CM, l[1] * cos(turn) * CM, l[2] * CM, l[2] * CM])
		parts.append(["foot %d" % k, "cast", Base.slab(levels)])
	# Cast ring finial facing front, eight straight segments, lifted so its top is the catalogue height.
	var ring := []
	var top := -INF
	for k in 8:
		var a := Vector2.from_angle(TAU * k / 8) * 1.12 * CM
		var b := Vector2.from_angle(TAU * (k + 1) / 8) * 1.12 * CM
		ring.append(Base.limb([[Vector3(a.x, a.y, 0), .4 * CM, .4 * CM], [Vector3(b.x, b.y, 0), .4 * CM, .4 * CM]], 4))
		for p in ring[k]:
			top = max(top, p.y)
	for k in 8:
		for i in ring[k].size():
			ring[k][i].y += OBJECTS.queens.size.y - top
		parts.append(["ring %d" % k, "cast", ring[k]])
	return parts

## Christ-local metres: origin under the centre of the footstool, +Z the carved face, standing upright.
## Thin backing pieces carry raised masses of real depth; the back is a plain plane, never seen.
static func christ() -> Array:
	var back := -CHRIST_DEPTH / 2
	var halo := PackedVector2Array()
	for p in Metal.ngon(12):
		halo.append(Vector2(-.07 + p.x * 1.95, 14.2 + p.y * 1.7))
	var body := PackedVector2Array([Vector2(2, 1.9), Vector2(2.05, 10.5), Vector2(1.95, 12.6), Vector2(-2.1, 12.6),
		Vector2(-3.1, 10.4), Vector2(-3.2, 8.2), Vector2(-2.9, 5), Vector2(-2.3, 1.9)])
	return [
		["halo plate", "ivory", Metal.plate(halo, Vector2(-.07, 14.2), [[back, 1], [back + .4, 1]])],
		["body plate", "ivory", Metal.plate(body, Vector2(-.5, 7), [[back, 1], [back + .45, 1]])],
		["footstool", "ivory", Base.slab([[0, -.23 * CM, -.28 * CM, 2.1 * CM, .42 * CM], [1.8 * CM, -.2 * CM, -.28 * CM, 2.15 * CM, .42 * CM]])],
		# Throne cushion at his left hand: the widest point on that side.
		["throne side", "ivory", Base.slab([[4.6 * CM, 2.7 * CM, -.2 * CM, .35 * CM, .3 * CM], [6 * CM, 2.72 * CM, -.15 * CM, .48 * CM, .45 * CM],
			[7.6 * CM, 2.72 * CM, -.15 * CM, .48 * CM, .45 * CM], [8.3 * CM, 2.6 * CM, -.2 * CM, .35 * CM, .3 * CM]])],
		["head", "ivory", Base.limb([[Vector3(-.13, 12.8, .05) * CM, .45 * CM, .35 * CM], [Vector3(-.13, 13.6, .2) * CM, .8 * CM, .5 * CM],
			[Vector3(-.13, 14.7, .2) * CM, .85 * CM, .5 * CM], [Vector3(-.13, 15.6, .05) * CM, .55 * CM, .35 * CM]], 6)],
		["torso", "ivory", Base.limb([[Vector3(-.1, 9, 0) * CM, 1.5 * CM, .5 * CM], [Vector3(-.1, 11, .1) * CM, 1.9 * CM, .6 * CM],
			[Vector3(-.1, 12.5, 0) * CM, 2 * CM, .45 * CM]], 6)],
		# Seated lap and knees: the deepest relief.
		["lap and knees", "ivory", Base.slab([[1.8 * CM, -.15 * CM, 0, 2.1 * CM, .5 * CM], [4.3 * CM, -.1 * CM, .1 * CM, 2.6 * CM, .6 * CM],
			[6.6 * CM, -.05 * CM, .1 * CM, 2.3 * CM, .6 * CM], [8.6 * CM, 0, .05 * CM, 1.6 * CM, .55 * CM]])],
		# Blessing right hand raised over its sleeve: the widest point on that side.
		["blessing sleeve", "ivory", Base.slab([[7 * CM, -2.2 * CM, 0, .7 * CM, .4 * CM], [8.4 * CM, -2.45 * CM, .05 * CM, .75 * CM, .5 * CM],
			[9.6 * CM, -2.5 * CM, .05 * CM, .7 * CM, .45 * CM], [10.6 * CM, -2.3 * CM, 0, .5 * CM, .35 * CM]])],
		["blessing hand", "ivory", Metal.box(Vector3(-2.2, 9.3, -.1), Vector3(-1.35, 11, .45))],
		# Book held on his left knee, the hand resting on it.
		["book", "ivory", Metal.box(Vector3(.65, 6.75, .15), Vector3(1.95, 7.5, .7))],
		["book hand", "ivory", Metal.box(Vector3(.6, 7.5, .1), Vector3(1.9, 8.6, .6))],
		["foot left", "ivory", Base.limb([[Vector3(-.35, 1.7, .25) * CM, .3 * CM, .25 * CM], [Vector3(-1.35, .5, .35) * CM, .42 * CM, .3 * CM]], 4)],
		["foot right", "ivory", Base.limb([[Vector3(.15, 1.7, .25) * CM, .3 * CM, .25 * CM], [Vector3(1.25, .5, .35) * CM, .42 * CM, .3 * CM]], 4)],
	]

## Wedge-local metres: origin on the deck under the wedge centre, low edge toward +Z. Display furniture, not catalogued.
static func christ_wedge() -> Array:
	var rings := []
	for x in [-WEDGE.x / 2, WEDGE.x / 2]:
		rings.append(PackedVector3Array([Vector3(x, 0, WEDGE.z / 2) * CM, Vector3(x, 0, -WEDGE.z / 2) * CM,
			Vector3(x, WEDGE.y, -WEDGE.z / 2) * CM, Vector3(x, WEDGE_LOW, WEDGE.z / 2) * CM]))
	return [["wedge", "mount", Base.shell(rings)]]

static func parts(key: String) -> Array:
	return {"queens": queens, "christ": christ, "christ_wedge": christ_wedge}[key].call()

## Metals take light and highlights; nothing is emissive. Ceramic, ivory and the mount stay matt.
static func material(kind: String) -> StandardMaterial3D:
	var m: StandardMaterial3D = Base.flat(COLORS[kind])
	if kind in METALS:
		m.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
		m.metallic = .6
		m.roughness = .25 if kind == "chrome" else .5
	return m

## Lit matt decal on the ceramic: one whole view of the body projected straight back onto the arc facing `yaw`.
## The texture spans the body's full width and height in that view; the arc takes the middle of it.
static func decal(texture: Texture2D, yaw: float, half: float) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 8:
		for corner in [[0, 0], [0, 1], [1, 1], [0, 0], [1, 1], [1, 0]]:
			var a := lerpf(-half, half, (i + corner[0]) / 8.0)
			var out := Vector3(sin(a + yaw), 0, cos(a + yaw))
			st.set_normal(out)
			st.set_uv(Vector2(.5 + sin(a) / 2, 1 - corner[1]))
			st.add_vertex((out * DECAL_RADIUS + Vector3.UP * lerpf(BODY.x, BODY.y, corner[1])) * CM)
	var visual := MeshInstance3D.new()
	visual.mesh = st.commit()
	var m: StandardMaterial3D = Base.flat(Color.WHITE)
	m.albedo_texture = texture
	visual.material_override = m
	return visual

## One object as a node, a mesh per colour key, origin under its base centre, +Z forward.
## For "queens", `decals` may carry Texture2D views of the body: "roundel" goes on +Z and is copied to -Z,
## "boat" goes on -X, and "west" (if anyone ever sees that face) on +X.
static func build(key: String, decals := {}) -> Node3D:
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
	if key == "queens":
		for face in [["roundel", "decal roundel front", 0.0, ROUNDEL_HALF], ["roundel", "decal roundel rear copy", PI, ROUNDEL_HALF],
				["boat", "decal boat east", -PI / 2, BOAT_HALF], ["west", "decal west", PI / 2, BOAT_HALF]]:
			if decals.has(face[0]):
				var visual := decal(decals[face[0]], face[2], face[3])
				visual.name = face[1]
				node.add_child(visual)
	return node

## The ivory lying on its wedge as filmed: back on the slope, feet toward the low edge. Origin on the deck.
static func christ_on_wedge() -> Node3D:
	var node := build("christ_wedge")
	node.name = "ChristOnWedge"
	var low := Vector3(0, WEDGE_LOW, WEDGE.z / 2) * CM
	var up := (Vector3(0, WEDGE.y, -WEDGE.z / 2) * CM - low).normalized()
	var object := build("christ")
	object.rotation.x = -up.angle_to(Vector3.UP)
	# Footstool 1.5 cm up the slope from the low edge, the back plane resting on the slope.
	object.position = low + up * 1.5 * CM + up.cross(Vector3.LEFT) * CHRIST_DEPTH / 2 * CM
	node.add_child(object)
	return node
