## Raymond Duchamp-Villon, Seated Woman, RISD 67.089 (API 1552686), and its wall case.
## Closed low polygon masses read from official photographs 0/1 and native IMG_6387 63.0..66.0s.
## Catalogue 71.1 x 20.3 x 24.1 cm fixes the bounds; every limb position inside them is read by eye.
## The rear has no source view: back, buttocks and seat reverse are plain closing faces, not observed form.
extends RefCounted

const SIZE := Vector3(.203, .711, .241)
const GOLD := Color("caa046") # median gold pixel, official photograph 1
# Case metres are estimates against the 71.1 cm figure in native 51.25/63.5/65.5s (about +-15%):
# hood width from the 65.5s front and back edges; depth, deck and plinth heights by eye.
const PLINTH := Vector3(.62, .76, .64) # wall-grey body, width x top height x depth from the wall
const DECK_Y := .92
const HOOD_TOP := 1.70
const FIGURE_Z := .32 # centre of the base, out from the wall

## One closed shell. Rings share a vertex count and run anticlockwise seen from the last ring.
static func shell(rings: Array) -> PackedVector3Array:
	var out := PackedVector3Array()
	var n: int = rings[0].size()
	for i in rings.size() - 1:
		for k in n:
			var a: Vector3 = rings[i][k]
			var b: Vector3 = rings[i][(k + 1) % n]
			var c: Vector3 = rings[i + 1][(k + 1) % n]
			var e: Vector3 = rings[i + 1][k]
			out.append_array([a, c, b, a, e, c])
	for k in range(1, n - 1):
		out.append_array([rings[0][0], rings[0][k], rings[0][k + 1]])
		out.append_array([rings[-1][0], rings[-1][k + 1], rings[-1][k]])
	return out

## Upright four-sided shell through levels of [y, centre x, centre z, half x, half z].
static func slab(levels: Array) -> PackedVector3Array:
	var rings := []
	for l in levels:
		rings.append(PackedVector3Array([Vector3(l[1] + l[3], l[0], l[2] + l[4]), Vector3(l[1] + l[3], l[0], l[2] - l[4]),
			Vector3(l[1] - l[3], l[0], l[2] - l[4]), Vector3(l[1] - l[3], l[0], l[2] + l[4])]))
	return shell(rings)

static func box(lo: Vector3, hi: Vector3) -> PackedVector3Array:
	var c := (lo + hi) / 2
	var h := (hi - lo) / 2
	return slab([[lo.y, c.x, c.z, h.x, h.z], [hi.y, c.x, c.z, h.x, h.z]])

## Faceted limb through stations of [centre, radius across, radius along the limb's own depth].
static func limb(stations: Array, sides: int) -> PackedVector3Array:
	var axis: Vector3 = (stations[-1][0] - stations[0][0]).normalized()
	var hint := Vector3.RIGHT if abs(axis.x) < .8 else Vector3.BACK
	var u := (hint - axis * hint.dot(axis)).normalized()
	var v := axis.cross(u)
	var rings := []
	for s in stations:
		var ring := PackedVector3Array()
		for k in sides:
			var angle := TAU * (k + .5) / sides
			ring.append(s[0] + u * s[1] * cos(angle) + v * s[2] * sin(angle))
		rings.append(ring)
	return shell(rings)

## Sculpture-local metres: origin under the base centre, +Z the knees, +X the figure's left.
static func figure_shells() -> Array:
	var cm := .01
	var parts := []
	# Gold-wash base with its low step, and the narrow seat post set back and to the figure's right.
	parts.append(box(Vector3(-10.15, 0, -12.05) * cm, Vector3(10.15, 6, 12.05) * cm))
	parts.append(box(Vector3(-7.2, 6, -8.5) * cm, Vector3(7.2, 6.9, 8.5) * cm))
	parts.append(box(Vector3(-6.3, 6.9, -9.5) * cm, Vector3(1.7, 32, -.5) * cm))
	# Hips overhang the seat behind; the torso narrows at the waist and leans forward as it rises.
	parts.append(limb([[Vector3(0, 31, -6) * cm, 5 * cm, 4.5 * cm], [Vector3(0, 36, -5.8) * cm, 6.3 * cm, 6 * cm], [Vector3(0, 43, -4.5) * cm, 5.2 * cm, 4.4 * cm],
		[Vector3(0, 51, -3.2) * cm, 7.4 * cm, 4.8 * cm], [Vector3(0, 58.5, -2) * cm, 8.6 * cm, 4.2 * cm]], 6))
	# Blocky left shoulder and upright upper arm; its forearm crosses the chest to the right shoulder.
	parts.append(limb([[Vector3(7.9, 58, -2) * cm, 3.18 * cm, 3.0 * cm], [Vector3(7.5, 45.5, 1.5) * cm, 2.8 * cm, 2.8 * cm]], 4))
	parts.append(limb([[Vector3(7, 46, 2.6) * cm, 2.9 * cm, 2.6 * cm], [Vector3(-6.5, 55.5, 3.2) * cm, 2.5 * cm, 2.2 * cm]], 4))
	# Right arm hangs long and nearly straight to a hand at seat height.
	parts.append(limb([[Vector3(-8.3, 57.5, -1.5) * cm, 2.6 * cm, 2.6 * cm], [Vector3(-8.5, 42, 0) * cm, 2.33 * cm, 2.6 * cm], [Vector3(-7.8, 24.5, 2) * cm, 2.0 * cm, 2.2 * cm]], 4))
	# Crossing leg: full thigh to a knee high on the figure's left, teardrop calf falling back to a foot that hangs clear.
	parts.append(limb([[Vector3(-1.5, 37.5, -5) * cm, 5 * cm, 5 * cm], [Vector3(2.5, 40.3, 3) * cm, 5 * cm, 5 * cm], [Vector3(5.2, 41.2, 8.4) * cm, 3.7 * cm, 3.7 * cm], [Vector3(5.6, 41.4, 10.4) * cm, 1.8 * cm, 1.8 * cm]], 6))
	parts.append(limb([[Vector3(5.6, 40, 8.6) * cm, 3.3 * cm, 3.3 * cm], [Vector3(5.7, 35, 6) * cm, 3.4 * cm, 3.4 * cm], [Vector3(5.6, 28.5, 3) * cm, 1.6 * cm, 1.6 * cm]], 5))
	parts.append(limb([[Vector3(5.6, 29, 3) * cm, 2.3 * cm, 2.1 * cm], [Vector3(5, 23.5, 5.2) * cm, 1.4 * cm, 1.3 * cm]], 4))
	# Lower leg underneath: knee low and furthest forward on the right, calf running back to a tiptoe at the centre.
	parts.append(limb([[Vector3(1, 32.5, -3) * cm, 4.2 * cm, 4.2 * cm], [Vector3(-4.8, 34.5, 8.6) * cm, 3.6 * cm, 3.6 * cm], [Vector3(-5.3, 34.6, 10.9) * cm, 1.8 * cm, 1.8 * cm]], 6))
	parts.append(limb([[Vector3(-4.6, 33.5, 8.9) * cm, 3.1 * cm, 3.1 * cm], [Vector3(-3.2, 27, 7.4) * cm, 3.3 * cm, 3.3 * cm], [Vector3(-.3, 14.5, 4.6) * cm, 1.4 * cm, 1.4 * cm]], 5))
	parts.append(limb([[Vector3(-.3, 14.8, 4.6) * cm, 1.8 * cm, 1.8 * cm], [Vector3(-.3, 6.9, 5.6) * cm, 1.2 * cm, 1.2 * cm]], 4))
	# Faceless egg head, bowed about 20 degrees; lifted so its crown meets the catalogue height.
	var chin := Vector3(.2, 55.5, .5) * cm
	var crown := chin + Vector3(-.3, 14.6, 5.2) * cm
	var head := limb([[chin, 1.3 * cm, 1.4 * cm], [chin.lerp(crown, .3), 3.1 * cm, 3.4 * cm], [chin.lerp(crown, .65), 4.1 * cm, 4.6 * cm],
		[chin.lerp(crown, .9), 3.3 * cm, 3.7 * cm], [crown, 1.5 * cm, 1.7 * cm]], 6)
	var top := -INF
	for p in head:
		top = max(top, p.y)
	for i in head.size():
		head[i].y += SIZE.y - top
	parts.append(head)
	return parts

## Case-local metres: origin on the floor at the wall, +Z into the room.
static func case_shells() -> Dictionary:
	var w := PLINTH.x / 2
	var d := PLINTH.z
	var glass := []
	var t := .012
	# Acrylic hood stands on the cap around the raised deck and closes against the wall.
	for x in [-w, w - t]:
		glass.append(box(Vector3(x, .83, 0), Vector3(x + t, HOOD_TOP, d)))
	for z in [0.0, d - t]:
		glass.append(box(Vector3(-w + t, .83, z), Vector3(w - t, HOOD_TOP, z + t)))
	glass.append(box(Vector3(-w + t, HOOD_TOP - t, t), Vector3(w - t, HOOD_TOP, d - t)))
	return {
		"body": [box(Vector3(-w, .10, 0), Vector3(w, PLINTH.y, d))],
		# White foot moulding, stepped cap, and the chamfered deck the sculpture stands on.
		"trim": [box(Vector3(-w - .02, 0, 0), Vector3(w + .02, .10, d + .02)),
			box(Vector3(-w - .03, PLINTH.y, 0), Vector3(w + .03, .83, d + .03)),
			slab([[.83, 0, d / 2, w - .02, d / 2 - .02], [DECK_Y, 0, FIGURE_Z, .2, .21]])],
		"glass": glass,
	}

static func mesh(shells: Array, m: Material) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for s in shells:
		for i in range(0, s.size(), 3):
			var normal: Vector3 = (s[i + 2] - s[i]).cross(s[i + 1] - s[i]).normalized()
			st.set_normal(normal)
			for j in 3:
				# Flat metre-scaled projection so the room's plaster reads at wall scale.
				var p: Vector3 = s[i + j]
				st.set_uv(Vector2(p.z if abs(normal.x) > .7 else p.x, p.z if abs(normal.y) > .7 else p.y) / 4)
				st.add_vertex(p)
	var visual := MeshInstance3D.new()
	visual.mesh = st.commit()
	visual.material_override = m
	return visual

static func flat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = .95
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	return m

## The whole case as one body. Put its origin on the floor against the pier between the windows
## and turn +Z into the room. `body` is the room's wall material, `trim` its white woodwork.
static func build(body: Material = null, trim: Material = null, bronze: Material = null) -> StaticBody3D:
	var node := StaticBody3D.new()
	node.name = "SeatedWomanCase"
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(PLINTH.x + .06, HOOD_TOP, PLINTH.z + .03)
	collision.shape = shape
	collision.position = Vector3(0, HOOD_TOP / 2, shape.size.z / 2)
	node.add_child(collision)
	var shells := case_shells()
	node.add_child(mesh(shells.body, body if body else flat(Color("afaba3"))))
	node.add_child(mesh(shells.trim, trim if trim else flat(Color("eeeae2"))))
	var figure := mesh(figure_shells(), bronze if bronze else flat(GOLD))
	figure.name = "SeatedWoman"
	figure.position = Vector3(0, DECK_Y, FIGURE_Z)
	figure.set_meta("catalogue_accession", "67.089")
	node.add_child(figure)
	# Same unshaded acrylic as remodel_room.gd display_case; the bake skips alpha materials.
	var glass := flat(Color(.78, .88, .89, .12))
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	node.add_child(mesh(shells.glass, glass))
	return node
