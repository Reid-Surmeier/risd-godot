## Prototype Virgin and Child15.108: source photographs + Muse run-45b7430ae44f28051bb2b9a2.
## Height .394m from RISD catalogue; width .218 and depth .145 are eye-read and provisional.
## +Z faces the viewer; +X is Mary's left. Child sits at -X on her right knee.
## Closed faceted masses. Fine fingers/damage and rear hair/paint remain unaccepted.
extends RefCounted
const S = preload("res://seated_woman_asset.gd")
const HEIGHT := .394

static func parts() -> Dictionary:
	var wood := []
	var blue := []
	var green := []
	var skin := []
	var hair := []
	var paper := []
	var cm := .01
	wood.append(S.slab([[0,0,0,10.2,6.4],[1.8,0,0,10.9,7.1],[2.8,0,0,10.3,6.5]]))
	# Flat-backed mantle and seat; the lap and separated knee masses read seated from both sides.
	wood.append(S.slab([[2.8,0,-1.3,9.3,4.9],[12,0,-1.5,9.8,4.7],[19,0,-2,8,4.2],[26,0,-3.6,6.2,2.4],[30.5,0,-3.6,4.8,2.1]]))
	blue.append(S.slab([[3,0,2.6,6.7,3.4],[8,0,3.1,7.4,3.5],[17.5,0,1.7,7.9,4.6],[20.3,0,-.2,5.7,3.5]]))
	blue.append(S.slab([[19,0,-1.7,4.4,2.5],[24,0,-1.4,4.3,2.7],[29.4,0,-2,4.4,2.5]]))
	for side in [-1,1]:
		wood.append(S.slab([[3,side*7,1.8,2.8,4.1],[13,side*7.4,2,2.5,4.4],[20,side*6.1,-.7,2.7,3.3],[28.8,side*4.9,-2.6,2.2,2.5]]))
		wood.append(S.limb([[Vector3(side*5,29,-2.8),2,2],[Vector3(side*7,22,.8),2.2,2.1],[Vector3(side*5.4,20.5,4.5),1.4,1.5]],5))
		# Mary's toes are small partly exposed blocks; they remain painted wood.
		wood.append(S.box(Vector3(side*4.6-1.7,2.8,3.4),Vector3(side*4.6+1.7,4.1,6.6)))
	# Mary's neck and bowed head, circlet below crown, long hair reaching shoulders.
	skin.append(S.limb([[Vector3(0,29,-2.4),1.6,1.5],[Vector3(0,31.1,-2.4),1.7,1.5]],6))
	skin.append(S.limb([[Vector3(0,30.5,-1.8),1.4,1.4],[Vector3(0,32,-1.5),2.5,1.8],[Vector3(0,35,-2),2.7,2],[Vector3(0,37.7,-2.8),2.3,1.7]],6))
	hair.append(S.limb([[Vector3(0,30.9,-3.2),3.3,2.3],[Vector3(0,35,-3.7),3.5,2.6],[Vector3(0,38.2,-3.5),2.7,2],[Vector3(0,39.1,-3.5),1.6,.5]],8))
	for side in [-1,1]:
		hair.append(S.limb([[Vector3(side*2.8,36,-2.2),1,1.2],[Vector3(side*3.5,31,-1.1),1.4,1.4],[Vector3(side*4.3,27.5,-1.6),1.1,1.4]],5))
	wood.append(S.limb([[Vector3(0,37.2,-3.5),3.3,2.3],[Vector3(0,37.7,-3.5),3.25,2.3]],8))
	# Child seated sideways on the right knee: visible head, torso, crossed reading arms and feet.
	green.append(S.limb([[Vector3(-4.7,16.5,3.2),2.2,2],[Vector3(-5.5,21,3.7),2.8,2.2],[Vector3(-4.8,26,3),2.4,1.8]],5))
	skin.append(S.limb([[Vector3(-4.5,25.7,3.5),1.5,1.3],[Vector3(-4.5,28.2,3.5),2.2,1.8],[Vector3(-4.8,30.5,2.8),1.7,1.4]],6))
	hair.append(S.limb([[Vector3(-4.8,28.8,2.5),2.3,1.9],[Vector3(-4.8,30.6,2.3),1.8,1.5],[Vector3(-4.8,31.2,2.3),.9,.7]],6))
	for offset in [0,1.7]:
		green.append(S.limb([[Vector3(-6.5+offset,24.3,4.1),1,1],[Vector3(-4+offset,22.3,5),1,1],[Vector3(-1.4+offset,22.2,6),.7,.7]],4))
		skin.append(S.box(Vector3(-2+offset,21.9,5.5),Vector3(-.5+offset,22.7,6.4)))
		green.append(S.limb([[Vector3(-5+offset,18,3.8),1.1,1.2],[Vector3(-5.6+offset,15,5),1,1],[Vector3(-4.7+offset,12.8,5.5),.7,.7]],4))
		skin.append(S.box(Vector3(-5.4+offset,12.4,5),Vector3(-4+offset,13.4,6.6)))
	# Two substantial open book halves angled across the lap; not a billboard.
	for side in [-1,1]:
		var centre := Vector3(2.6,19.5+side*2.1,5.8)
		var pages := S.box(Vector3(-3.9,-1.95,-.65),Vector3(3.9,1.95,.65))
		for i in pages.size(): pages[i] = pages[i].rotated(Vector3.RIGHT,-.25)+centre
		paper.append(pages)
		skin.append(S.box(Vector3(5.6,18+side*3.7,4.9),Vector3(7,19.6+side*3.7,6.7)))
	# Right hand supports the child at the outside of the lap.
	skin.append(S.limb([[Vector3(-7.6,22.6,2.9),.8,.9],[Vector3(-6.5,21.6,4.4),.9,.9]],4))
	# Convert centimetres and bring the hair crown to the catalogue height exactly.
	var groups := {"wood":wood,"blue":blue,"green":green,"skin":skin,"hair":hair,"paper":paper}
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
	var colors := {"wood":Color("a55f37"),"blue":Color("6989b0"),"green":Color("4f6653"),"skin":Color("c7b895"),"hair":Color("513a28"),"paper":Color("ded2b0")}
	var geometry:=parts()
	for key in geometry:
		var visual:=S.mesh(geometry[key],S.flat(colors[key]))
		visual.name=key
		node.add_child(visual)
	return node
