## Prototype Saint Roch, RISD 21.398: wood with polychromy, French, 1475-1525. Not bronze, not a knight.
## Closed low polygon masses read from official photographs 0 (front), 2 (the actual back) and 1/3 (three-quarter).
## Height 1.054 m including the wooden base is the catalogue's. Width (.545 m over base and dog) is read from
## photographs 0 and 2 against that height. Depth (.278 m) is fitted from photographs 1/3 at an assumed 30 degree
## turn and could be a third off. Neither is a catalogue or survey metre.
## +Z faces the viewer, +X is the saint's left: the dog and the raised, broken arm are at +X, the bag at -X.
## Sheet colour is Muse run-b13a93b2b883bac8562b552d: its FRONT, RIGHT SIDE and REAR panels. Its "LEFT SIDE" panel
## repeats the right profile and is never read; faces turned to +X take one flat front or rear sample each.
## Faces, fingers, buttons, badges, drapery folds, hair curls and paint losses are not modelled.
## The floor plinth and acrylic hood are not here. Nothing is fidelity- or placement-accepted.
extends RefCounted

const S := preload("seated_woman_asset.gd")
const HEIGHT := 1.054
# Flat fallback colours: medians of photograph 0 pixels over each part, not Muse pixels.
const COLORS := {"base": Color("493b2d"), "boots": Color("7e5e3d"), "legs": Color("806248"), "tunic": Color("74593e"), "leather": Color("5f4c3d"),
	"cape": Color("6e4d32"), "flesh": Color("b28f66"), "hair": Color("403225"), "hat": Color("5a4636"), "dog": Color("6e5539"), "bread": Color("b28f6c")}
# The face looks about 25 degrees to his right of the body (between photographs 0 and 3); turned about this point, in cm.
const HEAD_TURN := deg_to_rad(-25.0)
const HEAD_PIVOT := Vector3(-8, 0, 1.5)
# Rock outline: each vertex of the base ring pushed in or out.
const ROCK := [1, .94, 1.03, .9, 1, .95, 1.04, .93, 1, .96, 1.05, .92]
# Where the sculpture sits in the 1760x1440 Muse sheet, measured on the sheet's own silhouettes:
# FRONT/REAR are [px of x=0, px of the base bottom, px per cm]; x=0 is tied to the cape's middle at 60 cm.
# RIGHT is [px of the rearmost point, px of the frontmost point, px of the base bottom, px per cm].
# The base is 2 cm wider than Muse painted it, so FRONT and REAR are held inside their own panel's columns.
const SHEET_PX := Vector2(1760, 1440)
const FRONT := Vector3(289.1, 1288, 10.87)
const FRONT_COLUMNS := Vector2(2, 574)
const REAR := Vector3(1467, 1290, 10.87)
const REAR_COLUMNS := Vector2(1214, 1757)
const RIGHT := Vector4(576, 866, 1286, 10.91)
# The dog stands behind the legs in the Muse right profile, so its faces never read that panel.
const NO_SIDE := ["dog", "bread"]

## Upright closed loft through levels of [y, centre x, centre z, half width, front depth, back depth].
## `back` below 1 squares the rear corners, for the flat carved back; `wobble` scales each vertex.
static func loft(levels: Array, sides: int, back := 1.0, wobble := []) -> PackedVector3Array:
	var unit := PackedVector2Array()
	var most := Vector3.ZERO # widest x, deepest front, deepest back
	for k in sides:
		var a := TAU * (k + .5) / sides
		var e: float = back if sin(a) > 0 else 1.0
		var r: float = wobble[k] if wobble else 1.0
		var p := Vector2(signf(cos(a)) * pow(absf(cos(a)), e), -signf(sin(a)) * pow(absf(sin(a)), e)) * r
		unit.append(p)
		most = most.max(Vector3(absf(p.x), p.y, -p.y))
	var rings := []
	for l in levels:
		var ring := PackedVector3Array()
		for p in unit:
			ring.append(Vector3(l[1] + p.x / most.x * l[3], l[0], l[2] + (p.y / most.y * l[4] if p.y > 0 else p.y / most.z * l[5])))
		rings.append(ring)
	return S.shell(rings)

## Every solid as [name, colour group, closed shell], in metres, base on y=0 and the hat at the catalogue height.
static func parts() -> Array:
	var out := [
		# Irregular rocky base, flat cut at the back (photograph 2), the front sloping down under the right toe.
		["base", "base", loft([[0, -1, 0, 18.5, 11.5, 12], [3.5, -1.5, 0, 21, 12.5, 12.5], [7, -1.5, 0, 25, 13.5, 13.2], [11, -.9, 0, 26.6, 14, 13.5],
			[14.5, 0, 0, 26.4, 13.5, 13.5], [18.5, 1, -1.5, 24, 10, 12]], 12, .6, ROCK)],
		# Right leg forward with the toe over the base front; left leg about 7 cm behind it (photographs 1/3).
		["right shoe", "boots", S.limb([[Vector3(-9.6, 19.4, 3.5), 2.7, 2.6], [Vector3(-12.5, 17.3, 9.5), 2.5, 2.2], [Vector3(-15, 15.6, 13.5), 1.6, 1.4]], 5)],
		["right ankle", "boots", S.limb([[Vector3(-9.8, 25, 5.2), 2.9, 3], [Vector3(-9.9, 19, 5), 3.5, 3.5]], 6)],
		["right shaft", "boots", S.limb([[Vector3(-9.7, 32, 5.6), 3.3, 3.2], [Vector3(-9.8, 24.5, 5.2), 3.1, 3]], 6)],
		["right cuff", "boots", S.limb([[Vector3(-9.7, 37.6, 5.8), 4.6, 4.3], [Vector3(-9.7, 31.5, 5.8), 4.3, 4]], 6)],
		["left shoe", "boots", S.limb([[Vector3(-1.6, 19.4, -2.5), 2.7, 2.6], [Vector3(2.5, 18, 3), 2.4, 2.1], [Vector3(5.6, 17, 7), 1.5, 1.3]], 5)],
		["left ankle", "boots", S.limb([[Vector3(-1.6, 25, -1.3), 2.9, 3], [Vector3(-1.9, 19, -1.3), 3.5, 3.5]], 6)],
		["left shaft", "boots", S.limb([[Vector3(-.8, 33.5, -1.3), 3.3, 3.1], [Vector3(-1.5, 24.5, -1.3), 3.1, 3]], 6)],
		["left cuff", "boots", S.limb([[Vector3(-.3, 38.8, -1.5), 4.4, 4.1], [Vector3(-.5, 33, -1.3), 4.2, 3.9]], 6)],
		# The bared right thigh beside the lifted tunic, and the left thigh under the hem; a clear gap between the legs.
		["right thigh", "legs", S.limb([[Vector3(-8.3, 58, 1.5), 4, 4], [Vector3(-9, 48, 4), 3.7, 3.7], [Vector3(-9.6, 37.5, 5.6), 3.1, 3.2]], 6)],
		["left thigh", "legs", S.limb([[Vector3(.8, 48, -1.2), 3.6, 3.6], [Vector3(-.2, 38.5, -1.5), 3.1, 3.1]], 6)],
		# Belted tunic: skirt to the hem at 45 cm, narrow waist, chest under the cape.
		["tunic", "tunic", loft([[45, 1.5, -2, 7.8, 7, 7], [56, .8, -2.3, 7.3, 6.5, 6.5], [68, -.6, -2.8, 6.2, 5.8, 6], [70.5, -.8, -2.8, 6.4, 5.9, 6],
			[78, -2, -3, 8.3, 6.3, 6], [84.5, -3.3, -3, 9.3, 5.6, 5.6]], 8)],
		["belt", "leather", loft([[68.3, -.7, -2.8, 6.8, 6.4, 6.5], [70.2, -.7, -2.8, 6.8, 6.4, 6.5]], 8)],
		["strap", "leather", S.limb([[Vector3(1.5, 80.5, 4.6), 1, .5], [Vector3(-10.8, 66.8, 6), 1, .5]], 4)],
		["bag", "leather", S.limb([[Vector3(-11, 67, 5.6), 1.6, 1.3], [Vector3(-11.8, 61.5, 6.5), 3.6, 2.4], [Vector3(-12, 57, 6.5), 3.2, 2.2], [Vector3(-12, 55, 6.2), 1.6, 1.2]], 6)],
		# Short cape: one broad flat-backed mass from the shoulders to the hem at 41 cm (photograph 2 outline),
		# a lappet over the right arm, and the fold hanging from the raised left forearm.
		["cape", "cape", loft([[39.6, -3, -5, 13, 6, 7], [43.5, -1.8, -5, 18.9, 6.8, 7], [55, -2.8, -5, 19, 7, 7], [68, -3.1, -5, 18.5, 7, 7], [76, -3.5, -5, 18, 6.6, 7],
			[78.5, -4, -5, 16.9, 6.4, 6.8], [81, -5, -4.8, 15, 6, 6.4], [83.5, -5.5, -4.5, 13, 5.6, 6], [86, -4.4, -4, 9.5, 4.8, 5.2], [87.5, -4.6, -3.6, 7.5, 4.2, 4.4]], 10, .55)],
		["cape right lappet", "cape", S.limb([[Vector3(-14.5, 40.4, 1.5), 4.6, 3.6], [Vector3(-17, 52, 1), 4.6, 3.8], [Vector3(-17.5, 68, 0), 4.2, 3.8], [Vector3(-15.5, 80, -1), 3.5, 3.4]], 6)],
		["cape left fold", "cape", S.limb([[Vector3(11.5, 44.5, 1), 5.2, 5], [Vector3(11.5, 60, 1.5), 5, 4.8], [Vector3(10.5, 73, 2), 4.4, 4.5], [Vector3(9.5, 79.5, 1.5), 3, 3.6]], 6)],
		["cowl", "cape", S.slab([[77.2, -2.2, 3.4, 2.5, 1.6], [80.5, -3, 2.8, 9.5, 2.6], [84.6, -3.8, 1.3, 11, 3.6], [87.2, -4.5, -1, 6, 3.6]])],
		# The roll behind the neck, seen only in photograph 2.
		["collar roll", "cape", loft([[88.2, -4.5, -5, 6.6, 4.4, 4.4], [90.3, -4.5, -5.6, 7.4, 5, 5], [92.4, -5, -5, 6.2, 4.3, 4.3]], 8)],
		# Right arm hanging to the hand at the lifted hem; left forearm raised beside the chest, ending in the break.
		["right sleeve", "tunic", S.limb([[Vector3(-14.5, 79, 2.5), 3, 3], [Vector3(-16.5, 67, 4.2), 3, 3], [Vector3(-15.2, 58, 6), 2.4, 2.4]], 6)],
		["right hand", "flesh", S.limb([[Vector3(-15.2, 58.2, 6), 1.8, 1.3], [Vector3(-13.6, 51.5, 6.8), 1.5, .9]], 5)],
		["left forearm stump", "tunic", S.limb([[Vector3(12, 70, 2.5), 2.5, 2.5], [Vector3(8.3, 79.5, 3.3), 1.9, 1.9]], 6)],
		# Head tilted about 24 degrees to his right and bowed, under the broad hat; hair to the shoulders.
		# Built facing +Z, then turned to his right below: photograph 3 meets the face square on.
		["neck", "flesh", S.limb([[Vector3(-4.5, 85.5, -1.5), 3.6, 3.6], [Vector3(-6.5, 90.5, .5), 3.1, 3.3]], 6)],
		["head", "flesh", S.limb([[Vector3(-7.3, 89.8, 3.2), 2.2, 2.4], [Vector3(-7.7, 92.5, 2.9), 3.6, 4.4], [Vector3(-8.1, 96, 1.9), 4, 5], [Vector3(-8.6, 100, .5), 3.5, 4.3]], 8)],
		["nose", "flesh", S.limb([[Vector3(-8.6, 96.2, 6.4), .55, .5], [Vector3(-8.9, 93.6, 7.4), .9, .8]], 4)],
		["hair right", "hair", S.limb([[Vector3(-12.3, 97, .5), 1.8, 3.3], [Vector3(-12.6, 92, .5), 2.2, 3.3], [Vector3(-11, 88.3, 0), 1.6, 2.4]], 5)],
		["hair left", "hair", S.limb([[Vector3(-4.2, 97.5, 0), 1.8, 3.4], [Vector3(-1.5, 92.5, -.5), 3, 3.6], [Vector3(.8, 88.8, -1), 2.6, 3], [Vector3(1.2, 86.8, -1), 1.3, 1.6]], 5)],
	]
	for part in out:
		if part[0] in ["head", "nose", "hair right", "hair left"]:
			for i in part[2].size():
				part[2][i] = (part[2][i] - HEAD_PIVOT).rotated(Vector3.UP, HEAD_TURN) + HEAD_PIVOT
	# Hat: a disc brim low at the back and turned up 35 degrees over the face; flat-topped crown (photograph 2).
	var up := Vector3(.15, 1, -.7).normalized()
	var brim := Vector3(-6.2, 97.6, -1)
	out.append(["hat brim", "hat", S.limb([[brim - up * .8, 11.1, 10.5], [brim, 11.7, 11], [brim + up * .8, 10.5, 10]], 10)])
	out.append(["hat crown", "hat", S.limb([[brim + Vector3(-2, 0, 0) + up * .5, 5.4, 5.2], [brim + Vector3(-2, 0, 0) + up * 6.5, 4.8, 4.6]], 8)])
	# Lean dog sitting at his left, rump back and chest forward (photographs 1/3), head up with the loaf at his thigh,
	# one forepaw on the base and one on his left boot cuff.
	out.append_array([
		["dog body", "dog", S.limb([[Vector3(23, 23.2, -6), 4.3, 5.2], [Vector3(17.5, 25.5, -2), 4, 4.8], [Vector3(12.5, 26.8, 2), 3.6, 4.6]], 6)],
		["dog neck", "dog", S.limb([[Vector3(12.5, 27.5, 2), 3, 3], [Vector3(10.8, 34.5, 3), 2.6, 2.6]], 6)],
		["dog head", "dog", S.limb([[Vector3(12, 33, 3), 2.9, 2.9], [Vector3(9.9, 37.2, 3.6), 2.6, 2.5], [Vector3(7.4, 40.3, 4.2), 1.3, 1.2]], 6)],
		["dog ear", "dog", S.limb([[Vector3(13.2, 36.6, 3), .9, .7], [Vector3(14.7, 34.2, 3), .5, .4]], 4)],
		["dog standing foreleg", "dog", S.limb([[Vector3(12.8, 26, 3.5), 1.5, 1.5], [Vector3(14, 20, 4.5), 1, 1], [Vector3(15, 13.5, 5.5), .8, .8]], 5)],
		["dog raised foreleg", "dog", S.limb([[Vector3(10, 28.5, 3), 1.3, 1.3], [Vector3(5, 32.5, 1.5), 1, 1], [Vector3(2.3, 35, 0), .9, .9]], 5)],
		["dog near haunch", "dog", S.limb([[Vector3(22.5, 21.5, -2.5), 3.6, 3.4], [Vector3(22, 16.5, -.5), 2.4, 2.2]], 5)],
		["dog far haunch", "dog", S.limb([[Vector3(24, 21.5, -8.5), 3.6, 3.4], [Vector3(24, 16.5, -9.5), 2.4, 2.2]], 5)],
		["dog tail", "dog", S.limb([[Vector3(25, 24, -8), 1.2, 1.2], [Vector3(26.3, 27.2, -8.5), 1.1, 1.1], [Vector3(25, 28.4, -8.5), .8, .8]], 4)],
		["loaf", "bread", S.limb([[Vector3(6.8, 37.8, 4.6), 1.3, .8], [Vector3(6.2, 40, 4.6), 2.5, 1.1], [Vector3(5.5, 44, 4.7), 2.4, 1.1], [Vector3(5.1, 46, 4.8), 1.2, .8]], 6)],
	])
	# Convert centimetres and bring the hat top to the catalogue height exactly.
	var top := -INF
	for part in out:
		for point in part[2]:
			top = max(top, point.y)
	for part in out:
		for i in part[2].size():
			part[2][i] *= HEIGHT / top
	return out

## Sheet UV of a point for view 0 front, 1 rear, 2 right profile. `depth` is the model's rearmost and frontmost z.
static func sheet_uv(p: Vector3, view: int, depth: Vector2) -> Vector2:
	var cm := p * 100
	if view == 1:
		return Vector2(clampf(REAR.x - cm.x * REAR.z, REAR_COLUMNS.x, REAR_COLUMNS.y), REAR.y - cm.y * REAR.z) / SHEET_PX
	if view == 2:
		return Vector2(lerpf(RIGHT.x, RIGHT.y, inverse_lerp(depth.x, depth.y, p.z)), RIGHT.z - cm.y * RIGHT.w) / SHEET_PX
	return Vector2(clampf(FRONT.x + cm.x * FRONT.z, FRONT_COLUMNS.x, FRONT_COLUMNS.y), FRONT.y - cm.y * FRONT.z) / SHEET_PX

## One mesh carrying the sheet. A face turned to the viewer or away takes the FRONT or REAR panel per vertex;
## a face turned to his right takes the RIGHT SIDE panel when `side` allows it. Every other face (his left, tops,
## undersides) has no view of its own and takes one flat sample at its centre from the front or rear panel.
static func sheet_mesh(shells: Array, side: bool, depth: Vector2, m: Material) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for s in shells:
		for i in range(0, s.size(), 3):
			var n: Vector3 = (s[i + 2] - s[i]).cross(s[i + 1] - s[i]).normalized()
			var view := 0 if n.z >= 0 else 1
			var one: bool = absf(n.y) > .9 or absf(n.x) > absf(n.z)
			if side and one and absf(n.y) <= .9 and n.x < 0:
				view = 2
				one = false
			st.set_normal(n)
			for j in 3:
				st.set_uv(sheet_uv((s[i] + s[i + 1] + s[i + 2]) / 3 if one else s[i + j], view, depth))
				st.add_vertex(s[i + j])
	var visual := MeshInstance3D.new()
	visual.mesh = st.commit()
	visual.material_override = m
	return visual

## The sculpture as one node, a mesh per colour group, origin under the base centre, +Z forward.
## `sheet` is the whole Muse sheet (edge-padded, so a silhouette edge never reads the grey ground); without it the
## groups take the flat observed colours.
static func build(sheet: Texture2D = null) -> Node3D:
	var node := Node3D.new()
	node.name = "SaintRoch21398"
	var shells := {}
	var low := Vector3.ONE * INF
	var high := -Vector3.ONE * INF
	for part in parts():
		if not shells.has(part[1]):
			shells[part[1]] = []
		shells[part[1]].append(part[2])
		for point in part[2]:
			low = low.min(point)
			high = high.max(point)
	var skin: StandardMaterial3D = S.flat(Color.WHITE)
	skin.albedo_texture = sheet
	skin.texture_repeat = false
	for group in shells:
		var visual: MeshInstance3D = sheet_mesh(shells[group], group not in NO_SIDE, Vector2(low.z, high.z), skin) if sheet else S.mesh(shells[group], S.flat(COLORS[group]))
		visual.name = group
		node.add_child(visual)
	node.set_meta("catalogue_accession", "21.398")
	node.set_meta("catalogue_medium", "wood with polychromy")
	node.set_meta("height_m", HEIGHT)
	node.set_meta("width_m_provisional", high.x - low.x)
	node.set_meta("depth_m_provisional", high.z - low.z)
	node.set_meta("left_side_source", "none: masses from official photographs 0/3 and the back 2; the Muse left panel is rejected")
	node.set_meta("survey_metres_accepted", false)
	node.set_meta("placement_accepted", false)
	node.set_meta("rear_fidelity_accepted", false)
	node.set_meta("visual_fidelity_accepted", false)
	return node
