## Prototype Virgin and Child15.108: source photographs + Muse run-45b7430ae44f28051bb2b9a2.
## Height .394m from RISD catalogue. Width (.206 body,.223 over the crescent horns) and depth (.12 back to
## knees) are read from the official front and side photographs against that height; neither is a catalogue metre.
## +Z faces the viewer; +X is Mary's left. Child sits at -X on her right knee.
## Closed faceted masses in centimetres. The seated profile, lap, knees, book, child, bench and horns follow
## official photographs0/2/3. The flat green back and the hair behind are inferred from one blurred video frame.
## Faces, fingers, drapery folds and paint wear are not modelled; nothing here is fidelity-accepted.
extends RefCounted
const S = preload("res://seated_woman_asset.gd")
const HEIGHT := .394

## Upright six-sided shell with a flat back and chamfered front corners, through levels of
## [y, centre x, back z, front z, half width, front half width].
static func prism(levels: Array) -> PackedVector3Array:
	var rings := []
	for l in levels:
		var side: float = lerp(float(l[2]), float(l[3]), .62)
		rings.append(PackedVector3Array([Vector3(l[1] + l[5], l[0], l[3]), Vector3(l[1] + l[4], l[0], side), Vector3(l[1] + l[4], l[0], l[2]),
			Vector3(l[1] - l[4], l[0], l[2]), Vector3(l[1] - l[4], l[0], side), Vector3(l[1] - l[5], l[0], l[3])]))
	return S.shell(rings)

static func parts() -> Dictionary:
	var mantle := []
	var orange := []
	var lining := []
	var blue := []
	var tunic := []
	var skin := []
	var hair := []
	var paper := []
	var cover := []
	var stone := []
	var gold := []
	var cm := .01
	# Stepped base with a canted front, and the two-block bench whose ends show behind the drapery (photos2/3).
	stone.append(prism([[0, 0, -6.1, 5.7, 9.5, 5.4], [1.7, 0, -6.1, 5.7, 9.5, 5.4]]))
	stone.append(prism([[1.7, 0, -6.15, 6.2, 10.1, 6.0], [3.1, 0, -6.15, 6.2, 10.1, 6.0]]))
	stone.append(S.box(Vector3(-8.5, 3.1, -6), Vector3(8.5, 12.4, -1.4)))
	stone.append(S.box(Vector3(-8.7, 12.4, -6), Vector3(8.7, 17.6, -1.1)))
	# Inferred rear: one flat plane, painted green (edge seen in photo2, colour in the blurred105.70s frame).
	lining.append(S.box(Vector3(-8.75, 3.1, -6.22), Vector3(8.75, 17.7, -6)))
	lining.append(S.slab([[17.7, 0, -6.11, 8.35, .11], [22, 0, -6.11, 7.45, .11], [26, 0, -5.51, 6.65, .11], [29.2, 0, -4.81, 5.45, .11]]))
	# Lower body: the drapery falls straight from the knees to the base; the lap is its top.
	mantle.append(prism([[3.1, 0, -1.6, 5, 10.3, 7.4], [9, 0, -1.6, 4.9, 10.2, 7.2], [14.5, 0, -1.6, 4.8, 10, 7], [17.6, 0, -1.6, 4.6, 9.3, 6.6], [18.8, 0, -1.4, 3.4, 8.2, 5.4]]))
	# Her right thigh, knee and shin show the blue dress; the mantle crosses from her left knee to her right foot.
	blue.append(S.limb([[Vector3(-3, 16.6, .3), 3, 2.3], [Vector3(-3.8, 16.6, 4.8), 2.8, 2.3]], 6))
	blue.append(S.limb([[Vector3(-3.7, 16.3, 3.8), 2.8, 2.1], [Vector3(-3.2, 4.2, 3.9), 2.6, 1.9]], 6))
	blue.append(S.slab([[3.2, -2.9, 3.4, 3.9, 2.1], [10, -3, 3.3, 3.7, 2.1], [16.4, -3, 3.1, 3.4, 1.9]]))
	mantle.append(S.limb([[Vector3(3.6, 16.9, .3), 3.2, 2.4], [Vector3(5.6, 17.2, 4.8), 3.1, 2.4]], 6))
	mantle.append(S.limb([[Vector3(6, 16.8, 3.6), 3.2, 2.1], [Vector3(5.7, 4.1, 3.7), 3.8, 2]], 6))
	mantle.append(S.limb([[Vector3(2.9, 17.2, 4.3), 1.9, 1.5], [Vector3(.7, 4.1, 4.8), 2.4, 1.5]], 5))
	lining.append(S.slab([[12.2, -.3, 4.7, .85, 1], [17.6, -.1, 4.4, .85, 1]]))
	lining.append(S.slab([[3.2, 5.6, 5.1, 1.9, 1], [5.4, 5.4, 4.9, 1.6, 1]]))
	# Mantle gathered over the bench ends, the brightest orange in photos2/3: deep on her left, a lip on her right.
	orange.append(S.limb([[Vector3(8, 13.6, -3.5), 1.6, 2.2], [Vector3(8.1, 16.6, -3.5), 2, 2.5], [Vector3(7.6, 19.8, -3.7), 1.5, 2.2]], 6))
	orange.append(S.limb([[Vector3(-8, 17.3, -3.5), 1.7, 2.4], [Vector3(-7.6, 20, -3.7), 1.5, 2.1], [Vector3(-6.4, 24.5, -3.5), 1.3, 1.9]], 6))
	for side in [-1, 1]:
		# Crescent horns: a thin plate rising behind the drapery at each side (photo0); only its outer edge clears it.
		# Where it sits in depth is not seen in any side photograph; it is put against the bench end.
		gold.append(S.limb([[Vector3(side * 9.6, 6.6, -3.4), 1.3, .3], [Vector3(side * 10.5, 9.6, -3.4), .95, .3], [Vector3(side * 11, 11.4, -3.4), .5, .25], [Vector3(side * 11.15, 12.4, -3.4), .15, .12]], 5))
	# Shoes: two rounded toes on the base, her left foot near the centre under the crossing mantle.
	for x in [-4.9, -.3]:
		cover.append(S.limb([[Vector3(x, 4, 5.3), 1.3, .9], [Vector3(x - .2, 3.8, 6.9), 1, .6]], 5))
	# Upper body: mantle over both shoulders against the flat back, blue bodice between its edges.
	# Its back leans forward above the bench by about a centimetre at the shoulders (photos2/3).
	mantle.append(prism([[17.4, 0, -6, .2, 8.3, 6], [22, 0, -6, .3, 7.4, 5.2], [26, 0, -5.4, 0, 6.6, 4.4], [29.2, 0, -4.7, -.9, 5.4, 3.4], [30.7, 0, -4.2, -1.9, 3.4, 2.2]]))
	blue.append(S.slab([[19.5, 0, -1.6, 3.6, 2.2], [25.5, 0, -1.6, 3.3, 2.1], [29.8, 0, -1.9, 2.6, 1.7], [31.5, 0, -2.2, 1.9, 1.2]]))
	for side in [-1, 1]:
		# Sloping shoulders: the photo0 outline is 10.8 wide at y29 and 14.7 at the elbows.
		mantle.append(S.limb([[Vector3(side * 4.2, 29.4, -2.6), 1.3, 1.8], [Vector3(side * 5.2, 25.8, -1.9), 1.6, 1.9], [Vector3(side * 5.6, 22.4, -1), 1.6, 1.9]], 5))
	# Her left forearm carries the mantle to the hand at the book's edge; her right shows the blue sleeve.
	mantle.append(S.limb([[Vector3(5.8, 22.4, -.8), 1.5, 1.4], [Vector3(6, 22, 1.8), 1, .9]], 5))
	skin.append(S.limb([[Vector3(6, 22, 1.8), .8, .7], [Vector3(4.9, 22.4, 3.2), .7, .45]], 4))
	# The mantle hangs from that forearm onto her left thigh in one deep fold (photos0/3).
	mantle.append(S.slab([[15.5, 7.4, 1.2, 1.6, 2.5], [19, 7.2, .9, 1.6, 2.8], [22.4, 6.2, .2, 1.2, 2]]))
	blue.append(S.limb([[Vector3(-6.4, 22.4, -.8), 1.3, 1.3], [Vector3(-7.4, 23, 1.6), 1, .9]], 5))
	skin.append(S.limb([[Vector3(-7.4, 23, 1.6), .8, .7], [Vector3(-6.8, 23.8, 3.5), .7, .45]], 4))
	# Neck and bowed head, well forward of the back plane (photo2): faceted face inside the hair, circlet.
	skin.append(S.limb([[Vector3(0, 30.3, -1.7), 1.3, 1.2], [Vector3(0, 33, -.2), 1.2, 1.1]], 6))
	hair.append(S.limb([[Vector3(0, 32.6, -.95), 3, 2.6], [Vector3(0, 35.6, -.75), 3.45, 2.8], [Vector3(0, 37.6, -.8), 3.2, 2.7], [Vector3(0, 38.8, -.9), 2.3, 2], [Vector3(0, 39.4, -.95), 1.1, 1]], 8))
	skin.append(S.limb([[Vector3(0, 32.6, .75), 1.1, .9], [Vector3(0, 34.2, 1.25), 1.95, 1.3], [Vector3(0, 36.4, 1.4), 2.05, 1.3], [Vector3(0, 37.3, 1.15), 1.7, .85]], 6))
	skin.append(S.limb([[Vector3(0, 35.5, 2.55), .22, .2], [Vector3(0, 34, 2.8), .42, .3]], 4))
	gold.append(S.limb([[Vector3(0, 37, -.75), 3.3, 2.92], [Vector3(0, 37.6, -.75), 3.25, 2.88]], 8))
	for side in [-1, 1]:
		hair.append(S.limb([[Vector3(side * 3.05, 36.2, -.3), .75, 1.1], [Vector3(side * 3.2, 32.6, -.4), 1.35, 1.3], [Vector3(side * 3.6, 29.6, -.6), 1.25, 1.2], [Vector3(side * 3.9, 27.6, -.9), .6, .6]], 5))
	# Hair down the back to the shoulder blades: outline from photos2/3, surface inferred.
	hair.append(S.slab([[23.6, 0, -5.3, 3.9, .8], [28, 0, -4.4, 4.6, 1.1], [32, 0, -3.3, 3.9, 1.4], [36.4, 0, -2, 3, 1.3]]))
	# Open book leaning from her chest down onto her left thigh, spine across: pages on a brown cover.
	for half in [[24.47, 1.5, -.38], [21.27, 3.45, -.72]]:
		for leaf in [[paper, Vector3(-2.9, -1.9, -.2), Vector3(2.9, 1.9, .55)], [cover, Vector3(-3.25, -2.05, -.6), Vector3(3.25, 2.05, .15)]]:
			var block := S.box(leaf[1], leaf[2])
			for i in block.size():
				block[i] = block[i].rotated(Vector3.RIGHT, half[2]) + Vector3(2.3, half[0], half[1])
			leaf[0].append(block)
	# Child sideways on her right knee, turned to the book: back to her right, both arms out over the page.
	tunic.append(S.limb([[Vector3(-4.4, 20.3, 3.1), 2, 2.1], [Vector3(-4.2, 24.2, 3.2), 2, 2.1], [Vector3(-3.7, 26.9, 3.5), 1.6, 1.7]], 6))
	skin.append(S.limb([[Vector3(-4.1, 27.4, 4), .95, .95], [Vector3(-4, 28.9, 4.1), 1.5, 1.55], [Vector3(-4.1, 30.2, 4), 1.35, 1.4], [Vector3(-4.1, 30.7, 4), .8, .8]], 6))
	hair.append(S.limb([[Vector3(-4.7, 28.8, 3.9), 1.55, 1.7], [Vector3(-4.65, 30.4, 3.9), 1.5, 1.6], [Vector3(-4.5, 31, 3.9), .8, .85]], 6))
	tunic.append(S.limb([[Vector3(-3.2, 26.2, 4.4), .9, .9], [Vector3(-1.4, 25.6, 4), .85, .85], [Vector3(.3, 24.9, 2.9), .65, .65]], 4))
	skin.append(S.limb([[Vector3(.3, 24.9, 2.9), .5, .5], [Vector3(1.1, 24.6, 2.4), .4, .35]], 4))
	tunic.append(S.limb([[Vector3(-3.4, 25.4, 2.4), .9, .9], [Vector3(-1.6, 24.4, 2.9), .85, .85], [Vector3(-.2, 23.6, 3), .65, .65]], 4))
	skin.append(S.limb([[Vector3(-.2, 23.6, 3), .5, .5], [Vector3(.7, 23.3, 2.8), .4, .35]], 4))
	# Bent legs in the long tunic: one knee toward the book, the far leg hanging; bare feet over her knee.
	tunic.append(S.limb([[Vector3(-4.2, 20.6, 3.8), 1.3, 1.3], [Vector3(-2.3, 20.9, 5), 1.15, 1.15]], 5))
	tunic.append(S.limb([[Vector3(-2.3, 20.9, 5), 1.05, 1.05], [Vector3(-4.1, 18.9, 5.5), .8, .8]], 5))
	tunic.append(S.limb([[Vector3(-4.6, 20.8, 4.3), 1.2, 1.2], [Vector3(-5.3, 19.4, 5.2), .9, .9]], 5))
	skin.append(S.limb([[Vector3(-4.1, 18.9, 5.5), .6, .55], [Vector3(-4.5, 18.1, 5.9), .45, .4]], 4))
	# Convert centimetres and bring the hair crown to the catalogue height exactly.
	var groups := {"mantle": mantle, "orange": orange, "lining": lining, "blue": blue, "tunic": tunic, "skin": skin, "hair": hair, "paper": paper, "cover": cover, "stone": stone, "gold": gold}
	var top := -INF
	for group in groups.values():
		for shell in group:
			for point in shell: top=max(top,point.y)
	for group in groups.values():
		for shell in group:
			for i in shell.size(): shell[i]*=cm*HEIGHT/(top*cm)
	return groups

static func build() -> Node3D:
	var node:=Node3D.new()
	node.name="VirginChild15108"
	node.set_meta("catalogue_accession","15.108")
	node.set_meta("height_m",HEIGHT)
	node.set_meta("placement_accepted",false)
	node.set_meta("rear_fidelity_accepted",false)
	node.set_meta("visual_fidelity_accepted",false)
	# Flat colours are medians of hue-selected pixels in official photographs0/2/3, not Muse pixels.
	var colors := {"mantle":Color("8d5a3c"),"orange":Color("bd693c"),"lining":Color("47604d"),"blue":Color("5b6f94"),"tunic":Color("9aa184"),"skin":Color("cdb89e"),
		"hair":Color("54402d"),"paper":Color("d2c0a6"),"cover":Color("70452f"),"stone":Color("a99d8c"),"gold":Color("8a6a3e")}
	var geometry:=parts()
	for key in geometry:
		var visual:=S.mesh(geometry[key],S.flat(colors[key]))
		visual.name=key
		node.add_child(visual)
	return node
