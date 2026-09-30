## #182/#183 throwaway authored rooms, following the Main Hall asset workflow.
## Captured spacing guides placement; every room extent remains provisional.
extends "doorway_walk.gd"

const Painting := preload("res://modules/shell/prototype/gallery_walk4/painting_asset.gd")
var inventory := {"point_clouds": 0, "bookcase": 1, "mirrors": 2, "approved_frames": 1, "muse_upholstery": 1, "settee": 1, "armchairs": 3, "catalogue_tureens": 1}
var contact_shadow:MeshInstance3D
var views := [Vector3(.45, .25, -4.6), Vector3(.45, .25, 2.8)]

func make_visitor() -> Node3D:
	var actor=load("res://modules/shell/prototype/gallery_walk4/visitor159/visitor.gd").new()
	actor.world_height=1.75
	return actor

func _ready() -> void:
	super._ready()
	# Keep the existing collision floors; their flat study colours are replaced.
	for child in get_children():
		if child is MeshInstance3D:
			child.visible = false
		if child is WorldEnvironment:
			child.environment.background_color = Color("e4e0d5")
			child.environment.ambient_light_color = Color("fff0d9")
			child.environment.ambient_light_energy = .55
		if child is DirectionalLight3D:
			child.light_color = Color("fff1d9")
			child.light_energy = .65
	build_rooms()
	build_bookcase()
	build_mirrors()
	build_displays()
	build_furniture()
	var index:=0
	for surface in find_children("*","MeshInstance3D",true,false):
		if not visitor.is_ancestor_of(surface):
			surface.name="AuthoredSurface%03d"%index
			index+=1
	load_bake()
	build_contact_shadow()
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.remodelInventory=" + JSON.stringify(inventory))
	assert(not FileAccess.file_exists("res://points.bin"))
	print("REMODEL_READY " + JSON.stringify(inventory))

func build_contact_shadow() -> void:
	# Reuse the Main Hall's radial contact card, outside static lightmap ownership.
	var gradient:=Gradient.new()
	gradient.set_color(0,Color(0,0,0,.9))
	gradient.set_color(1,Color(0,0,0,0))
	var texture:=GradientTexture2D.new()
	texture.gradient=gradient
	texture.fill=GradientTexture2D.FILL_RADIAL
	texture.fill_from=Vector2(.5,.5)
	texture.fill_to=Vector2(.5,0)
	var m:=look(Color(1,1,1,.25),"",true)
	m.albedo_texture=texture
	contact_shadow=MeshInstance3D.new()
	var plane:=PlaneMesh.new()
	plane.size=Vector2(.75,.42)
	contact_shadow.mesh=plane
	contact_shadow.material_override=m
	contact_shadow.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	contact_shadow.set_meta("contact_shadow",true)
	add_child(contact_shadow)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			reset(views[0])
		elif event.keycode == KEY_2:
			reset(views[1])

func look(color: Color, texture_path := "", unlit := false) -> StandardMaterial3D:
	var m := material(color)
	m.roughness = .95
	m.specular_mode=BaseMaterial3D.SPECULAR_DISABLED
	if color.a < 1:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if not texture_path.is_empty():
		m.albedo_texture = load(texture_path)
	if unlit:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m

func solid(at: Vector3, size: Vector3, m: Material, collide := false) -> Node3D:
	var visual := MeshInstance3D.new()
	var cube := BoxMesh.new()
	assert(size.x > 0 and size.y > 0 and size.z > 0, "Collapsed room or asset solid")
	cube.size = size
	visual.mesh = cube
	visual.material_override = m
	if not collide:
		visual.position = at
		add_child(visual)
		return visual
	var node := StaticBody3D.new()
	node.position = at
	var shape := CollisionShape3D.new()
	var collision := BoxShape3D.new()
	collision.size = size
	shape.shape = collision
	node.add_child(shape)
	node.add_child(visual)
	add_child(node)
	# Reuse the existing gallery camera cutaway, keeping collision intact.
	casings.append(node)
	return node

func panel(parent: Node3D, corners: Array, uvs: Array, m: Material, tone := Color.WHITE) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_color(tone)
	Painting.quad(st, corners, uvs)
	var mesh := MeshInstance3D.new()
	mesh.mesh = st.commit()
	mesh.material_override = m
	parent.add_child(mesh)

func build_rooms() -> void:
	var wall := look(Color.WHITE, "res://presentation/wall-plaster.png")
	var ivory := look(Color("e9e4d8"))
	ivory.emission_enabled=true
	ivory.emission=Color(.55,.55,.55)
	var oak := ShaderMaterial.new()
	oak.shader=load("res://presentation/floor_oak.gdshader")
	oak.set_shader_parameter("oak",load("res://presentation/oak-board-atlas-168-v3.webp"))
	oak.set_shader_parameter("floor_z_limits",Vector2(-7.3,7.1))
	for area in [[-2.75, 3.65, -7.20, -.2], [-2.75, 3.65, .2, 7.0]]:
		var x0: float = area[0]
		var x1: float = area[1]
		var z0: float = area[2]
		var z1: float = area[3]
		var width := x1 - x0
		var depth := z1 - z0
		# Straight oak boards in these source rooms, not the Hall's herringbone layout.
		for i in int(ceil(width / .14)):
			var xa: float = x0 + i * .14
			var xb: float = min(x1, xa + .14)
			for j in int(ceil(depth / 1.8)) + 1:
				var za: float = max(z0, z0 + j * 1.8 - (i % 3) * .6)
				var zb: float = min(z1, z0 + (j + 1) * 1.8 - (i % 3) * .6)
				if zb <= za:
					continue
				var band: float = .05 + (i % 6) * .07
				panel(self, [Vector3(xa,.003,za),Vector3(xb,.003,za),Vector3(xb,.003,zb),Vector3(xa,.003,zb)],
					[Vector2.ZERO,Vector2.DOWN,Vector2.ONE,Vector2.RIGHT], oak,Color(1,1,1,fmod((i*7+j*3)*.131,1.0)))
		for side in [x0, x1]:
			# Source IMG_6380/245 enters through the right wall from the purple corridor.
			var spans:Array=[Vector2(z0,z1)]
			if side==x1 and z0<0:spans=[Vector2(z0,-2.8),Vector2(-1.2,z1)]
			for span in spans:
				var w:=solid(Vector3(side,1.75,(span.x+span.y)/2),Vector3(.12,3.5,span.y-span.x),wall,true)
				for y in [.07,3.35]:
					var trim:=solid(Vector3(side,y,(span.x+span.y)/2),Vector3(.17,.14,span.y-span.x),ivory)
					trim.reparent(w)

		var end: float = z0 if z0 < 0 else z1
		var w := solid(Vector3((x0+x1)/2,1.75,end),Vector3(width,3.5,.12),wall,true)
		for y in [.07,3.35]:
			var trim := solid(Vector3((x0+x1)/2,y,end+.07),Vector3(width,.14,.15),ivory)
			trim.reparent(w)
	# The observed opening is shared by these rooms; no new connectors.
	for span in [[-2.75,-.711604],[1.233235,3.65]]:
		var width: float = span[1]-span[0]
		solid(Vector3((span[0]+span[1])/2,1.75,0),Vector3(width,3.5,.25),wall,true)
	var lintel:=solid(Vector3(.26082,3.12,0),Vector3(1.945,.76,.25),wall,true)
	for i in 2:
		var x: float = [-.711604,1.233235][i]
		var trim:=solid(Vector3(x,1.35,.16),Vector3(.14,2.7,.13),ivory)
		trim.reparent(lintel)
	var trim:=solid(Vector3(.26082,2.73,.16),Vector3(2.1,.18,.16),ivory)
	trim.reparent(lintel)
	panel(self,[Vector3(-.711604,.004,-.2),Vector3(1.233235,.004,-.2),Vector3(1.233235,.004,.2),Vector3(-.711604,.004,.2)],
		[Vector2.ZERO,Vector2.RIGHT,Vector2.ONE,Vector2.DOWN],oak)

	# ponytail: bounded corridor stub; extend only after its next room is source-verified.
	var purple:=look(Color("7c7187"))
	var header:=solid(Vector3(3.65,3.12,-2.0),Vector3(.12,.76,1.6),wall,true)
	for z in [-2.8,-1.2]:
		var jamb:=solid(Vector3(3.57,1.35,z),Vector3(.17,2.7,.14),ivory)
		jamb.reparent(header)
	var top:=solid(Vector3(3.57,2.73,-2),Vector3(.17,.18,1.74),ivory)
	top.reparent(header)
	for z in [-2.8,-1.2]:solid(Vector3(4.62,1.75,z),Vector3(1.94,3.5,.12),purple,true)
	solid(Vector3(5.6,1.75,-2),Vector3(.12,3.5,1.6),purple,true)
	panel(self,[Vector3(3.65,.003,-2.8),Vector3(5.6,.003,-2.8),Vector3(5.6,.003,-1.2),Vector3(3.65,.003,-1.2)],
		[Vector2.ZERO,Vector2.RIGHT,Vector2.ONE,Vector2.DOWN],oak)

func build_bookcase() -> void:
	var node := Node3D.new()
	node.position = Vector3(.55,.13,-6.84)
	add_child(node)
	var wood := look(Color("674024"))
	var painted := look(Color.WHITE,"res://assets/bookcase.png",true)
	painted.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	painted.alpha_scissor_threshold=.5
	# Pixel ranges are recorded against the untouched Muse front raster.
	var size := Vector2(1.1,1.515)
	var front := func(rect: Rect2, z: float) -> void:
		var x0: float = (rect.position.x-151)/1136.0*size.x-size.x/2
		var x1: float = (rect.end.x-151)/1136.0*size.x-size.x/2
		var y0: float = (1655-rect.end.y)/1531.0*size.y
		var y1: float = (1655-rect.position.y)/1531.0*size.y
		panel(node,[Vector3(x0,y0,z),Vector3(x1,y0,z),Vector3(x1,y1,z),Vector3(x0,y1,z)],
			[Vector2(rect.position.x/1440,rect.end.y/1760),Vector2(rect.end.x/1440,rect.end.y/1760),Vector2(rect.end.x/1440,rect.position.y/1760),Vector2(rect.position.x/1440,rect.position.y/1760)],painted)
	# Nine recessed backs; shelves/dividers remain separately modeled solids.
	for col in [[175,442],[455,987],[1000,1274]]:
		for row in [[163,345],[359,579],[591,855]]:
			front.call(Rect2(col[0],row[0],col[1]-col[0],row[1]-row[0]),-.29)
	for y in [149,349,583,863]:
		var height: float = (1655-y)/1531.0*1.515
		assert(y != 149 or height > 1.4, "Shelf pixel conversion must retain fractional metres")
		var shelf := solid(Vector3(0,height,-.13),Vector3(1.1,.016,.33),wood)
		shelf.reparent(node,false)
		front.call(Rect2(151,y-5,1136,14),.035)
	for x in [165,449,993,1270]:
		var side := solid(Vector3((x-151)/1136.0*1.1-.55,1.13,-.13),Vector3(.017,.70,.33),wood)
		side.reparent(node,false)
		front.call(Rect2(x-7,155,16,710),.035)
	for section in [[151,442,0.0],[442,1001,.035],[1001,1287,0.0]]:
		var x: float = (section[0]+section[1])/2
		var lower := solid(Vector3((x-151)/1136.0*1.1-.55,.505,-.13),Vector3((section[1]-section[0])/1136.0*1.1,.568,.33),wood)
		lower.reparent(node,false)
		front.call(Rect2(section[0],866,section[1]-section[0],571),section[2]+.04)
	for x in [-.5,-.255,.255,.5]:
		var leg := MeshInstance3D.new()
		var cylinder := CylinderMesh.new()
		cylinder.top_radius=.025
		cylinder.bottom_radius=.011
		cylinder.height=.22
		cylinder.radial_segments=8
		leg.mesh=cylinder
		leg.position=Vector3(x,.11,.02)
		leg.material_override=wood
		node.add_child(leg)
	front.call(Rect2(151,122,1136,33),.04)
	# All unobserved sides are authored plain wood, not photographic room cards.
	solid(Vector3(.55,.87,-6.97),Vector3(1.2,1.55,.42),look(Color(0,0,0,0)),true).get_child(1).hide()

func build_mirrors() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/mirror-outline.json"))
	for spec in [[-1.05,"pair-mirror"],[2.25,"mirror"]]:
		var x:float=spec[0]
		var kind:String=spec[1]
		data=JSON.parse_string(FileAccess.get_file_as_string("res://assets/"+kind+"-outline.json"))
		var mirror := Painting.new()
		add_child(mirror)
		mirror.build_shaped(load("res://assets/"+kind+".png"),Vector2(.914,2.311),data.outline,Color("a27c37"))
		mirror.get_child(0).material_override.set_shader_parameter("alpha_cut",.5)
		mirror.position=Vector3(x,2.15,-7.00)
	# The two catalogue photographs show opposite central scrolls: .4.2 left, .4.1 right.

func build_displays() -> void:
	var ivory:=look(Color("eeeae2"))
	var wood:=look(Color("38281d"))
	var cloth:=look(Color.WHITE,"res://assets/sofa-cloth.webp")
	# Source-observed white furniture platforms, sofa, and ceramic display case.
	solid(Vector3(.45,.065,-6.73),Vector3(5.8,.13,.95),ivory,true)
	solid(Vector3(-2.23,.065,-4.0),Vector3(.85,.13,4.8),ivory,true)
	# Furniture clearance boxes keep the visitor off museum platforms.
	solid(Vector3(3.05,.55,-3.55),Vector3(.8,1.1,1.75),ivory,true)
	var glass:=look(Color(.78,.88,.89,.16))
	glass.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	for z in [-4.43,-2.67]:
		solid(Vector3(3.05,1.5,z),Vector3(.8,.80,.012),glass)
	for x in [2.65,3.45]:
		solid(Vector3(x,1.5,-3.55),Vector3(.012,.8,1.75),glass)
	build_tureen(Vector3(3.05,1.10,-3.55))
	var frame_data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/frame-geometry.json"))
	var frame:=Painting.new()
	add_child(frame)
	frame.build_framed(load("res://assets/frame.png"),load("res://assets/painting-35.786.jpg"),Vector2(.651,.541),frame_data.margins_px)
	frame.position=Vector3(-2.67,1.9,2.8)
	frame.rotation.y=PI/2
	var edwards_data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/edwards-frame-geometry.json"))
	var edwards:=Painting.new()
	add_child(edwards)
	edwards.build_framed(load("res://assets/edwards-frame.png"),load("res://assets/painting-58.197.jpg"),Vector2(.637,.760),edwards_data.margins_px)
	edwards.position=Vector3(.55,2.43,-7.02)
	inventory["verified_portraits"]=1
	# Sofa portrait and remaining artwork identities stay unfilled pending catalogue match.

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if contact_shadow:contact_shadow.position=Vector3(body.position.x,.012,body.position.z)
	var baked=get_node_or_null("BakedRoom")
	if baked:
		for surface in baked.get_children():
			if surface is MeshInstance3D and surface.has_meta("live_cutaway"):
				var target=surface.get_meta("live_cutaway")
				surface.visible=target.get_parent().get_child(1).visible if target.get_parent() is StaticBody3D and target.get_parent() in casings else true
	# Trim is part of its wall's camera cutaway, not a floating independent band.
	for wall in casings:
		for i in range(2,wall.get_child_count()):
			wall.get_child(i).visible=wall.get_child(1).visible

func load_bake() -> void:
	if not ResourceLoader.exists("res://modules/shell/prototype/gallery_walk4/baked/room.lmbake"):
		return
	var bake=load("res://modules/shell/prototype/gallery_walk4/baked/room.tscn").instantiate()
	# Retain authored collision and cutaway ownership; reuse saved native UV2 meshes/materials.
	var by_name={}
	for mesh in find_children("*","MeshInstance3D",true,false):
		if mesh.is_visible_in_tree() and not visitor.is_ancestor_of(mesh):
			by_name[mesh.name]=mesh
	for source in bake.get_children():
		if source is MeshInstance3D:
			var keys=source.get_meta("source_paths",[])
			if not keys.is_empty():
				for name in keys:
					assert(by_name.has(name))
					by_name[name].layers=2
				continue
			var key=source.get_meta("source_path", "")
			assert(by_name.has(key),"Baked surface must match authored mesh: "+str(key))
			var target=by_name[key]
			target.mesh=source.mesh
			target.material_override=source.material_override
			# LightmapGI user paths must remain those in the saved bake, so the live mesh
			# takes the original baked node; hiding follows the original cutaway visual.
			target.layers=2
			source.set_meta("live_cutaway",target)
	camera.cull_mask=1
	add_child(bake)
	for child in get_children():
		if child is DirectionalLight3D: child.hide()
		if child is WorldEnvironment:child.environment.ambient_light_energy=0
	inventory["native_lightmap_users"]=bake.get_node("Lightmap").light_data.get_user_count()

func build_furniture() -> void:
	for spec in [["settee",Vector3(-2.21,.13,-4.7),PI/2],["armchair",Vector3(2.8,.13,-6.65),0.0],["armchair",Vector3(-1.9,.13,-6.65),0.0],["entrance-chair",Vector3(-2.2,.13,-1.8),PI/2]]:
		var kind: String=spec[0]
		var node:=Node3D.new()
		add_child(node)
		node.position=spec[1]
		node.rotation.y=spec[2]
		var parts: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/"+kind+"-parts.json"))
		for part in parts.reliefs:
			var face:=Painting.new()
			node.add_child(face)
			face.build_shaped(load("res://assets/"+part.texture),Vector2(part.size[0],part.size[1]),part.outline,Color("67422b"))
			face.position=vec(part.position)
			face.scale.z=part.depth/.09
			face.get_child(0).material_override.set_shader_parameter("alpha_cut",.5)
		var cloth:=look(Color.WHITE,"res://assets/"+kind+"-cloth.png",true)
		var wood:=look(Color("67422b"))
		var width:float=1.23 if kind=="settee" else .56
		var depth:float=.64 if kind=="settee" else .47
		for row in [[Vector3(0,.40,.20),Vector3(width,.11,depth),cloth],[Vector3(0,.72,-.06),Vector3(width,.40,.12),cloth]]:
			if kind!="settee" and row[0].y>.5:continue
			var piece:=solid(row[0],row[1],row[2])
			piece.reparent(node,false)
		for x in [-width/2,width/2]:
			if kind!="settee":
				for row in [[Vector3(x,.56,.20),Vector3(.04,.04,.48)],[Vector3(x,.49,.43),Vector3(.04,.18,.04)]]:
					var arm:=solid(row[0],row[1],wood)
					arm.reparent(node,false)
			var leg:=solid(Vector3(x,.18,-.08),Vector3(.035,.36,.04),wood)
			leg.reparent(node,false)

func build_tureen(at:Vector3) -> void:
	var node:=Node3D.new()
	node.position=at
	add_child(node)
	var texture:=look(Color.WHITE,"res://assets/tureen.png",true)
	var profile=[[0.0,.01],[.25,.025],[.2795,.05],[.22,.07],[.08,.09],[.10,.13],[.17,.18],[.195,.26],[.185,.29],[.19,.31],[.17,.34],[.13,.37],[.05,.39],[0.0,.40]]
	var st:=SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for j in profile.size()-1:
		for i in 16:
			var positions=[]
			var uvs=[]
			for pair in [[j,i],[j,i+1],[j+1,i+1],[j+1,i]]:
				var y:float=profile[pair[0]][1]
				var r:float=profile[pair[0]][0]
				var angle:float=TAU*pair[1]/16.0
				var x:float=cos(angle)*r
				positions.append(Vector3(x,y,sin(angle)*r*.637))
				uvs.append(Vector2((185+(x/.559+.5)*1385)/1760.0,(1300-y/.457*1124)/1440.0))
			Painting.quad(st,positions,uvs)
	var mesh:=MeshInstance3D.new()
	mesh.mesh=st.commit()
	mesh.material_override=texture
	node.add_child(mesh)
	var gold:=look(Color("dbbc74"))
	for center in [Vector3(-.228,.275,0),Vector3(.228,.275,0),Vector3(0,.421,0)]:
		var ring:=MeshInstance3D.new()
		var torus:=TorusMesh.new()
		torus.inner_radius=.024 if center.x==0 else .029
		torus.outer_radius=.036 if center.x==0 else .044
		torus.rings=12
		torus.ring_segments=4
		ring.mesh=torus
		ring.rotation.x=PI/2
		ring.position=center
		ring.material_override=gold
		node.add_child(ring)
