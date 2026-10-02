## Prototype Pieta, RISD 59.128: Tilman Riemenschneider, linden wood. Not bronze.
## Closed low polygon masses read from official photograph 0 (the colour front), 2 (old black-and-white front) and
## 3 (detail of Christ's head and chest), and native IMG_6383 24.6 s / 62.0 s. Photograph 1 is a white silhouette,
## not a rear. No source shows the back or either side.
## Catalogue 45.7 x 38.1 x 13.2 cm fixes all three bounds exactly. Inside them every position is read by eye from
## photograph 0 in centimetres at the catalogue height (`photo_cm`). The photograph's own outline is only 34.4 cm
## wide at that height (this reading spans 34.8), so `parts` widens x by about 9 percent to meet the catalogue width:
## that conflict is open.
## Depth has no source at all: the layering (Mary behind, Christ in front) is inferred inside the 13.2 cm.
## The back is a plain flat closing face. The catalogue API dates it 1480-1510, the case label and page ca. 1515-1525:
## left unresolved, and no label is made here.
## +Z faces the viewer, +X is the viewer's right: Mary is tall at -X/back with her right hand raised; the dead Christ
## sits at +X/front, head fallen to +X, legs and feet running to -X. Not the Michelangelo pose.
## Faces, fingers, hair curls, thorns, drapery borders and the leaf carving of the base are not modelled.
## The wall case, shelf and hood are not here. Nothing is fidelity-, rear-, metre- or placement-accepted.
extends RefCounted

const S := preload("seated_woman_asset.gd")
const R := preload("saint_roch_asset.gd")
const SIZE := Vector3(.381, .457, .132) # catalogue width, height, depth
# Flat colours, all from photograph 0 pixels over the named part: the median of its middle half by brightness, or of
# its lightest quarter. It is one wood, so the tones sit close together.
const COLORS := {"base": Color("694f41"), "mantle": Color("714b32"), "dress": Color("684025"), "veil": Color("916748"), "christ": Color("936543"),
	"hair": Color("734f38"), "cloth": Color("72503a"), # middle halves
	"mary": Color("8b603f")} # lightest quarter of her face
# Mound outline: each vertex of the base ring pushed in or out.
const MOUND := [1, .95, 1.03, .93, 1, .96, 1.04, .94, 1, .97, 1.03, .92]
# Drapery: every other vertex of a ring pulled in, so the cloth falls in broad vertical pleats.
const PLEATS := [1, .84, 1, .84, 1, .84, 1, .84, 1, .84, 1, .84]

static func v(x: float, y: float, z: float) -> Vector3:
	return Vector3(x, y, z)

## Every solid as [name, colour group, closed shell] in photograph centimetres: x from the middle of the photograph's
## outline, y up from the base bottom, z inferred.
static func photo_cm() -> Array:
	# Christ's head lies along chin -> crown, fallen about 65 degrees to the viewer's right (photograph 3).
	var chin := v(11.3, 25.5, 1.2)
	var crown := v(16.4, 28.1, .2)
	return [
		# Low leafy mound, flat cut behind, widest just above the ground.
		["base", "base", R.loft([[0, .25, 0, 14.5, 6.6, 6.6], [2.6, .7, 0, 15.7, 6.6, 6.6], [4.3, .3, 0, 14.6, 6.2, 6.6], [5.4, .6, 0, 14.2, 5, 6.6]], 12, .6, MOUND)],
		# Mary's mantle: one flat-backed mass from the ground to the shoulders. Below 23 cm it spreads to the viewer's
		# right as the cloth hanging behind Christ.
		["mantle back", "mantle", R.loft([[5.4, 1.25, -3.5, 13.75, 2.5, 3.1], [10, 1.65, -3.5, 13.65, 2.5, 3.1], [17, 2.05, -3.5, 12.95, 2.5, 3.1],
			[23, 1.3, -3.5, 11.7, 2.5, 3.1], [27, .2, -3.5, 10.3, 2.5, 3.1], [31, .25, -3.5, 9.25, 2.4, 3.1], [33, .4, -3.5, 8.3, 2.3, 3.1],
			[35, .9, -3.5, 7, 2.2, 3.1], [37, 1.3, -3.5, 5.6, 2, 3.1], [39, 1.7, -3.5, 4.4, 1.8, 3]], 10, .55)],
		# The mantle hanging down her right side to the ground, its turned-over flap, and its edge.
		["mantle wing", "mantle", R.loft([[4, -8.2, 0, 4.4, 2.6, 1.5], [12, -7.8, 0, 4, 2.6, 1.5], [20, -7, 0, 3.6, 2.4, 1.5], [27, -7, 0, 3.2, 2.2, 1.5],
			[31, -6.6, -.3, 2.6, 2, 1.5], [34.5, -4.9, -.8, 1.9, 1.6, 1.2], [36.6, -3.6, -1.6, .9, 1, .9]], 12, 1, PLEATS)],
		["mantle flap", "mantle", S.limb([[v(-8.4, 25.6, 2), 1.3, 1], [v(-8.8, 22.8, 2.6), 1.2, 1], [v(-9, 20, 2.6), .4, .4]], 5)],
		# The mantle gathered over Christ's upper foot at the viewer's left.
		["mantle hem", "mantle", S.limb([[v(-7.5, 12.6, 3.2), 1.8, 1.9], [v(-11.5, 11.6, 3.6), 1.9, 2.1], [v(-15.2, 10.9, 3.5), 1.4, 1.5]], 6)],
		# Her left sleeve reaching down behind Christ's head; her left hand is hidden there.
		["mantle sleeve", "mantle", S.limb([[v(6.8, 36.2, -1.2), 1.9, 2.2], [v(8.4, 31, -.6), 2.4, 2.4], [v(10, 27.6, -.2), 1.9, 2]], 6)],
		# The long skirt between the mantle edges and the chest, set back; the linen wimple under the chin; her right sleeve.
		["skirt", "dress", R.loft([[4.5, -.5, -1, 4.2, 2.2, 1], [13, -.5, -1, 3.6, 1.8, 1], [22, 0, -1, 3.4, 1.5, 1], [29.5, 1.2, -1, 3.6, 1.3, 1]], 12, 1, PLEATS)],
		["chest", "dress", S.slab([[29, 1.75, -.6, 3.7, 1.5], [34.6, 1.75, -.7, 3.4, 1.5]])],
		["wimple", "veil", S.slab([[34.2, 1.7, -.3, 2.9, 1.7], [38, 1.5, -.2, 2.3, 1.7]])],
		["right sleeve", "mantle", S.limb([[v(-7.6, 25.4, 1.4), 1.8, 1.6], [v(-4.9, 29.6, 2.8), 1.7, 1.4]], 5)],
		# Hood over the bowed head: a dome behind, two cheeks and a peaked brow in front, leaving a shadowed niche for the
		# face; then the veil's long swag across the chest.
		["hood", "veil", R.loft([[37.5, 1.8, -2, 4.2, 3.2, 4], [40, 1.8, -2, 4, 3.4, 4], [42, 1.75, -2, 3.75, 3.6, 3.9], [44, 1.45, -2.2, 2.75, 3.2, 3.2],
			[45.3, 1.6, -2.4, 1.4, 1.8, 2], [45.7, 1.7, -2.5, .5, .6, .6]], 8, .7)],
		["hood cheek right", "veil", S.slab([[37.3, -1.8, .2, .7, 2], [42.6, -1.6, .3, .7, 2]])],
		["hood cheek left", "veil", S.slab([[37.3, 5, .1, .7, 2], [42.6, 4.7, .3, .7, 2]])],
		["hood brow", "veil", S.slab([[42.4, 1.45, .3, 3.9, 2.2], [44.1, 1.45, 0, 2.7, 2], [45.3, 1.55, -.8, 1.3, 1.5]])],
		["hood shadow", "dress", S.slab([[37.3, 1.55, -.3, 2.8, 1.3], [42.5, 1.55, -.3, 2.8, 1.3]])],
		["veil swag right", "veil", S.limb([[v(-1.9, 37.2, 1.2), 1.3, .8], [v(-1.5, 33, 1.8), 1.3, .8], [v(-.3, 30.6, 2.2), 1.3, .8], [v(1.6, 29.6, 2.3), 1.3, .8]], 4)],
		["veil swag left", "veil", S.limb([[v(1.6, 29.6, 2.3), 1.3, .8], [v(3.6, 30.6, 2.2), 1.3, .8], [v(5.1, 33.5, 1.8), 1.3, .8], [v(5.8, 37.2, 1), 1.3, .8]], 4)],
		# Mary's face, bowed, and her right hand raised flat beside her chest.
		["mary face", "mary", S.limb([[v(1.5, 37.5, 1), 1, 1], [v(1.55, 39.2, 1.1), 1.7, 1.5], [v(1.55, 40.8, 1), 1.8, 1.6], [v(1.6, 42, .8), 1.5, 1.3]], 6)],
		["mary nose", "mary", S.limb([[v(1.55, 40.9, 2.4), .35, .35], [v(1.5, 39.5, 3), .6, .5]], 4)],
		["mary hand", "mary", S.limb([[v(-5, 29.6, 3), 1.1, .7], [v(-4.8, 33, 3.4), 1.3, .7], [v(-4.5, 35.8, 3.3), 1, .5], [v(-4.4, 36.8, 3.2), .5, .3]], 6)],
		# Christ: torso upright but slumped back and to the viewer's right, head fallen on his left shoulder.
		["christ torso", "christ", S.limb([[v(6.8, 8.5, 2.8), 2.6, 2.2], [v(7.2, 13, 2.4), 2.9, 2.2], [v(8.6, 19, 1.6), 4, 2.6], [v(9.2, 21.8, 1.1), 4.2, 2.3], [v(9.6, 23.4, .8), 2.8, 1.6]], 8)],
		["christ neck", "christ", S.limb([[v(10.4, 22.6, .9), 1.5, 1.5], [v(11.8, 25.4, 1), 1.4, 1.4]], 5)],
		["christ head", "christ", S.limb([[chin, 1.4, 1.3], [chin.lerp(crown, .3), 2.7, 2.6], [chin.lerp(crown, .65), 2.9, 2.9], [chin.lerp(crown, .9), 2.4, 2.4],
			[crown, 1.2, 1.2]], 8)],
		["christ nose", "christ", S.limb([[chin.lerp(crown, .55) + v(0, -.3, 2.7), .45, .45], [chin.lerp(crown, .34) + v(0, -.3, 3.3), .7, .6]], 4)],
		# Hair: a cap over the top of the head rolled at the brow for the crown of thorns, a mass behind, the beard.
		["hair cap", "hair", S.limb([[chin.lerp(crown, .64), 3.6, 3.6], [chin.lerp(crown, .9), 3, 3], [chin.lerp(crown, 1.02), 1.6, 1.6]], 8)],
		["crown of thorns", "hair", S.limb([[chin.lerp(crown, .6), 4, 4], [chin.lerp(crown, .74), 4, 4]], 8)],
		["hair behind", "hair", S.limb([[chin.lerp(crown, .2) + v(-.3, .6, -2), 2.2, 2.4], [chin.lerp(crown, .6) + v(-.3, .6, -2), 2.6, 3]], 6)],
		["beard", "hair", S.limb([[chin.lerp(crown, -.06), 1.1, 1.1], [chin.lerp(crown, .14), 2.2, 2.1]], 8)],
		["hair fall", "hair", S.limb([[v(15.8, 25.4, -.4), 1.4, 1.3], [v(15.3, 22.5, -.2), 1.1, 1], [v(14.9, 20.2, 0), .5, .5]], 5)],
		# Both arms hang; the hands rest on the base.
		["christ right arm", "christ", S.limb([[v(5.2, 22.4, 2.2), 1.5, 1.5], [v(2.6, 18.5, 3.2), 1.3, 1.3], [v(1.5, 14, 3.8), 1.2, 1.2], [v(1.9, 9.5, 4.4), 1.05, 1.05],
			[v(3, 7, 4.8), .9, .9]], 6)],
		["christ right hand", "christ", S.limb([[v(3, 7, 4.8), .9, .6], [v(4.4, 4.6, 5.2), .9, .45]], 5)],
		["christ left arm", "christ", S.limb([[v(13.4, 21, 1.2), 1.5, 1.5], [v(14.3, 16.5, 2.2), 1.3, 1.3], [v(14.6, 12, 3), 1.2, 1.2], [v(14, 8, 3.8), 1.05, 1.05],
			[v(13, 6, 4.2), .9, .9]], 6)],
		["christ left hand", "christ", S.limb([[v(13, 6, 4.2), .6, .9], [v(10.8, 4.4, 4.6), .45, .9]], 5)],
		["loincloth", "cloth", S.limb([[v(6.5, 6.4, 3), 3.4, 2.7], [v(6.9, 11.2, 2.7), 3.3, 2.6]], 8)],
		["loincloth tail", "cloth", S.limb([[v(7.3, 9.5, 4.6), 2.2, 1.2], [v(8.2, 4.2, 5.2), 1, .6]], 5)],
		# Both legs run to the viewer's left, one above the other, the feet beyond the base.
		["christ upper leg", "christ", S.limb([[v(5.2, 10.2, 3.6), 2, 2], [v(-1.5, 12.2, 4.6), 1.6, 1.6], [v(-8, 11.6, 4.2), 1.25, 1.25], [v(-11.5, 10.6, 3.8), .95, .95]], 6)],
		["christ upper foot", "christ", S.limb([[v(-11.5, 10.4, 4.2), .9, 1], [v(-14.9, 9.5, 4.8), .7, .8]], 5)],
		["christ lower leg", "christ", S.limb([[v(5, 7.6, 4), 2, 2], [v(-2.5, 7.4, 5.2), 1.5, 1.5], [v(-9, 7.2, 5), 1.15, 1.15], [v(-13, 7.2, 4.6), .9, .9]], 6)],
		["christ lower foot", "christ", S.limb([[v(-13, 7.2, 4.6), 1.1, 1], [v(-15.5, 6.4, 5), 1.1, 1.1], [v(-17.2, 5.7, 5.3), .6, .9]], 5)],
	]

## The same solids in metres, each axis fitted to the catalogue: x and z centred on the origin, the base on y=0.
static func parts() -> Array:
	var out := photo_cm()
	var low := Vector3.ONE * INF
	var high := -Vector3.ONE * INF
	for part in out:
		for point in part[2]:
			low = low.min(point)
			high = high.max(point)
	var origin := Vector3((low.x + high.x) / 2, low.y, (low.z + high.z) / 2)
	for part in out:
		for i in part[2].size():
			part[2][i] = (part[2][i] - origin) * SIZE / (high - low)
	return out

## The sculpture as one node, a mesh per colour group, origin under the middle of the base, +Z forward, metres.
static func build() -> Node3D:
	var node := Node3D.new()
	node.name = "Pieta59128"
	var shells := {}
	for part in parts():
		if not shells.has(part[1]):
			shells[part[1]] = []
		shells[part[1]].append(part[2])
	for group in shells:
		var visual: MeshInstance3D = S.mesh(shells[group], S.flat(COLORS[group]))
		visual.name = group
		node.add_child(visual)
	node.set_meta("catalogue_accession", "59.128")
	node.set_meta("catalogue_medium", "linden wood")
	node.set_meta("catalogue_size_m", SIZE)
	node.set_meta("dating", "unresolved: API 1480-1510, case label and page ca. 1515-1525")
	node.set_meta("rear_source", "none: flat closing faces")
	node.set_meta("survey_metres_accepted", false)
	node.set_meta("placement_accepted", false)
	node.set_meta("rear_fidelity_accepted", false)
	node.set_meta("visual_fidelity_accepted", false)
	node.set_meta("whole_room_complete", false)
	return node
