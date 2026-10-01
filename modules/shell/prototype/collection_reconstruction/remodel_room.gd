## #182/#183 throwaway authored rooms, following the Main Hall asset workflow.
## Captured spacing guides placement; every room extent remains provisional.
extends "doorway_walk.gd"

const Painting := preload("res://modules/shell/prototype/gallery_walk4/painting_asset.gd")
var inventory := {"point_clouds":0,"bookcase":1,"mirrors":2,"settee":1,"armchairs":3}
var contact_shadow:MeshInstance3D
var ceiling_details:Array[MeshInstance3D]=[]
var views := [Vector3(.45, .25, -4.6), Vector3(-.55, .25, 3)]

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
	build_catalogue_objects()
	build_adjacent_gallery()
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
	var ivory := look(Color("e9e4d8"))
	var oak := ShaderMaterial.new()
	oak.shader=load("res://presentation/floor_oak.gdshader")
	oak.set_shader_parameter("oak",load("res://presentation/oak-board-atlas-168-v3.webp"))
	var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://geometry.json"))
	var floor_limits:=Vector2(INF,-INF)
	for area in data.rooms:
		floor_limits.x=min(floor_limits.x,area.bounds[2]-.1)
		floor_limits.y=max(floor_limits.y,area.bounds[3]+.1)
	assert(floor_limits.x<floor_limits.y)
	oak.set_shader_parameter("floor_z_limits",floor_limits)
	for area in data.rooms:
		var b:Array=area.bounds
		var wall:=look(Color("7c7187")) if area.label.begins_with("purple") else look(Color.WHITE,"res://presentation/wall-plaster.png")
		for i in int(ceil((b[1]-b[0])/.14)):
			var xa:float=b[0]+i*.14
			var xb:float=min(b[1],xa+.14)
			for j in int(ceil((b[3]-b[2])/1.8))+1:
				var za:float=max(b[2],b[2]+j*1.8-(i%3)*.6)
				var zb:float=min(b[3],b[2]+(j+1)*1.8-(i%3)*.6)
				if zb<=za:continue
				panel(self,[Vector3(xa,.003,za),Vector3(xb,.003,za),Vector3(xb,.003,zb),Vector3(xa,.003,zb)],
					[Vector2.ZERO,Vector2.DOWN,Vector2.ONE,Vector2.RIGHT],oak,Color(1,1,1,fmod((i*7+j*3)*.131,1.0)))
		for side in ["west","east","north","south"]:
			var vertical:bool=side in ["west","east"]
			var fixed:float=b[0] if side=="west" else b[1] if side=="east" else b[2] if side=="north" else b[3]
			var lo:float=b[2] if vertical else b[0]
			var hi:float=b[3] if vertical else b[1]
			var opening:Array=area.openings.get(side,[])
			var spans:Array=[[lo,hi]] if opening.is_empty() else [[lo,opening[0]],[opening[1],hi]]
			for span in spans:
				if span[1]-span[0]<.001:continue
				var center:=Vector3(fixed,1.75,(span[0]+span[1])/2) if vertical else Vector3((span[0]+span[1])/2,1.75,fixed)
				var size:=Vector3(.12,3.5,span[1]-span[0]) if vertical else Vector3(span[1]-span[0],3.5,.12)
				var casing:=solid(center,size,wall,true)
				var trim:=moulding(span[1]-span[0],.16,"baseboard",false)
				var inward:float=1.0 if side in ["west","north"] else -1.0
				trim.position=Vector3(fixed+inward*.065,.08,(span[0]+span[1])/2) if vertical else Vector3((span[0]+span[1])/2,.08,fixed+inward*.065)
				trim.rotation.y=inward*PI/2 if vertical else 0.0 if inward==1.0 else PI
				trim.reparent(casing)
			if opening.is_empty():continue
			var width:float=opening[1]-opening[0]
			var middle:float=(opening[0]+opening[1])/2
			var header:=solid(Vector3(fixed,3.12,middle) if vertical else Vector3(middle,3.12,fixed),Vector3(.38,.76,width) if vertical else Vector3(width,.76,.38),wall,true)
			for edge in opening:
				# Deep painted reveals are visible in both reciprocal doorway shots.
				var jamb:=solid(Vector3(fixed,1.35,edge) if vertical else Vector3(edge,1.35,fixed),Vector3(.38,2.7,.08) if vertical else Vector3(.08,2.7,.38),ivory)
				jamb.reparent(header)
				for face in [-1,1]:
					var surround:=moulding(.16,2.7,"door-architrave",true)
					surround.position=Vector3(fixed+face*.20,1.35,edge) if vertical else Vector3(edge,1.35,fixed+face*.20)
					surround.rotation.y=face*PI/2 if vertical else 0.0 if face==1 else PI
					surround.reparent(header)
			for face in [-1,1]:
				var top:=moulding(.16,width+.16,"door-architrave",true)
				top.rotation.z=PI/2
				top.rotation.y=face*PI/2 if vertical else 0.0 if face==1 else PI
				top.position=Vector3(fixed+face*.20,2.73,middle) if vertical else Vector3(middle,2.73,fixed+face*.20)
				top.reparent(header)
	# Ceiling rails and vents follow the wide views; omit opaque ceiling for the gallery camera.
	for x in [-1.7,.4,2.5]:
		for z in [-5.5,-3.5,-1.5]:
			var rail:=solid(Vector3(x,3.43,z),Vector3(1.65,.025,.035),ivory)
			ceiling_details.append(rail)
			for offset in [-.5,.5]:
				var fixture:=solid(Vector3(x+offset,3.33,z),Vector3(.08,.15,.08),ivory)
				fixture.reparent(rail)
	for spec in [[Vector3(-.55,3.04,-.61),0.0],[Vector3(3.43,3.04,-2),PI/2]]:
		var vent:=solid(spec[0],Vector3(1.85,.07,.018),look(Color("746f64")))
		vent.rotation.y=spec[1]
	inventory["muse_architecture_assets"]=3

func moulding(width:float,height:float,kind:String,upright:bool) -> MeshInstance3D:
	# ponytail: shallow faceted profile measured qualitatively; exact millimetres unverified.
	var profile:Array=[[0,.008],[.10,.008],[.10,.018],[.23,.018],[.23,.028],[.43,.028],[.43,.014],[.65,.014],[.65,.038],[.86,.045],[1,.025]] if upright else [[0,.035],[.10,.035],[.10,.012],[.79,.012],[.94,.030],[1,.030]]
	var st:=SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in profile.size()-1:
		var a:Vector2=Vector2(profile[i][0],profile[i][1])
		var b:Vector2=Vector2(profile[i+1][0],profile[i+1][1])
		var corners:Array=[Vector3((a.x-.5)*width,-height/2,a.y),Vector3((b.x-.5)*width,-height/2,b.y),Vector3((b.x-.5)*width,height/2,b.y),Vector3((a.x-.5)*width,height/2,a.y)] if upright else [Vector3(-width/2,(a.x-.5)*height,a.y),Vector3(width/2,(a.x-.5)*height,a.y),Vector3(width/2,(b.x-.5)*height,b.y),Vector3(-width/2,(b.x-.5)*height,b.y)]
		Painting.quad(st,corners,[Vector2(a.x,1),Vector2(b.x,1),Vector2(b.x,0),Vector2(a.x,0)] if upright else [Vector2(0,1-a.x),Vector2(1,1-a.x),Vector2(1,1-b.x),Vector2(0,1-b.x)])
	var mesh:=MeshInstance3D.new()
	mesh.mesh=st.commit()
	mesh.material_override=look(Color.WHITE,"res://assets/"+kind+".png")
	add_child(mesh)
	return mesh

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

func display_case(at:Vector3,size:Vector3) -> void:
	var ivory:=look(Color("eeeae2"))
	# Wide shots show a suspended tray, not a solid pedestal down to the floor.
	solid(at+Vector3(0,1.04,0),Vector3(size.x,.12,size.z),ivory,true)
	for x in [-size.x*.4,size.x*.4]:
		for z in [-size.z*.36,size.z*.36]:
			solid(at+Vector3(x,.49,z),Vector3(.025,.98,.025),ivory,true)
	var glass:=look(Color(.78,.88,.89,.12),"",true)
	for z in [-size.z/2,size.z/2]:solid(at+Vector3(0,1.5,z),Vector3(size.x,.8,.012),glass)
	for x in [-size.x/2,size.x/2]:solid(at+Vector3(x,1.5,0),Vector3(.012,.8,size.z),glass)

func build_displays() -> void:
	var ivory:=look(Color("eeeae2"))
	solid(Vector3(.45,.065,-6.73),Vector3(5.8,.13,.95),ivory,true)
	solid(Vector3(-2.23,.065,-4.075),Vector3(.85,.13,6.25),ivory,true)
	# Pink Worcester left of the gallery door; gold export service beside the purple door.
	display_case(Vector3(1.85,0,-.95),Vector3(1.8,0,.88))
	display_case(Vector3(3.05,0,-3.8),Vector3(1.0,0,1.8))
	# Raised central stand for the gold tureen, visible in the reference video.
	solid(Vector3(3.32,1.15,-3.8),Vector3(.32,.1,.40),ivory)
	# The Vincennes pair occupies its own central pedestal.
	solid(Vector3(.45,.55,-3.85),Vector3(1.1,1.1,.65),ivory,true)
	# The photographed bust keeps its separate white plinth and black-and-white socle.
	solid(Vector3(-2.2,.63,-5.87),Vector3(.48,1.0,.48),ivory,true)
	solid(Vector3(-2.2,1.15,-5.87),Vector3(.34,.18,.34),look(Color("343332")))
	for y in [1.05,1.27]:solid(Vector3(-2.2,y,-5.87),Vector3(.4,.06,.4),ivory)
	var portraits=[["edwards","58.197",Vector2(.637,.760),Vector3(.55,2.43,-7.02),0.0],
		["romany","2009.9",Vector2(.762,.952),Vector3(-2.67,2.12,-4.7),PI/2]]
	for row in portraits:
		var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/"+row[0]+"-frame-geometry.json"))
		var painting:=Painting.new()
		add_child(painting)
		painting.build_framed(load("res://assets/"+row[0]+"-frame.png"),load("res://assets/painting-"+row[1]+".jpg"),row[2],data.margins_px)
		painting.position=row[3]
		painting.rotation.y=row[4]
	inventory["verified_paintings"]=2
	inventory["display_cases"]=2
	inventory["central_pedestals"]=1
	# Arabesque Wallpaper 34.912: diamond/birds/garlands match IMG_6380 210.25s.
	# The catalogue paper size is measured; the white conservation mount is provisional.
	solid(Vector3(3.59,2.10,-5.4),Vector3(.018,1.345,.76),ivory)
	var paper:=Painting.new()
	add_child(paper)
	paper.build_shaped(load("res://assets/wallpaper-34.912.jpg"),Vector2(.56,1.145),[[0,0],[1,0],[1,1],[0,1]],Color("e7dfcd"))
	paper.position=Vector3(3.575,2.10,-5.4)
	paper.rotation.y=-PI/2
	for z in [-5.70,-5.10]:solid(Vector3(3.55,2.75,z),Vector3(.025,.025,.025),look(Color("b4b4ad")))
	inventory["verified_wallpaper_panels"]=1

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if contact_shadow:contact_shadow.position=Vector3(body.position.x,.012,body.position.z)
	# Trim is part of its wall's camera cutaway, not a floating independent band.
	for wall in casings:
		for i in range(2,wall.get_child_count()):
			wall.get_child(i).visible=wall.get_child(1).visible
	update_baked_visibility()

func update_baked_visibility() -> void:
	for rail in ceiling_details:
		rail.visible=not inventory.has("native_lightmap_users") or camera.global_position.y<3.4
	var baked=get_node_or_null("BakedRoom")
	if baked:
		for surface in baked.get_children():
			if surface is MeshInstance3D and surface.has_meta("live_cutaway"):
				var target=surface.get_meta("live_cutaway")
				surface.visible=target.get_parent().get_child(1).visible if target.get_parent() is StaticBody3D and target.get_parent() in casings else target.is_visible_in_tree()

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
	for spec in [["settee",Vector3(-2.21,.13,-5.2),PI/2],["armchair",Vector3(2.8,.13,-6.65),0.0],["armchair",Vector3(-1.9,.13,-6.65),0.0],["entrance-chair",Vector3(-2.2,.13,-1.95),PI/2]]:
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

func build_catalogue_objects() -> void:
	var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/catalogue-objects.json"))
	for row in data.instances:
		var asset:Dictionary=data.meshes[row.asset]
		if row.get("shape","") in ["cabinet","table"]:
			build_front_furniture(row,asset)
			continue
		var st:=SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for t in asset.triangles.size():
			var triangle:Array=asset.triangles[t]
			var a:=vec(asset.vertices[triangle[0]])
			var b:=vec(asset.vertices[triangle[1]])
			var c:=vec(asset.vertices[triangle[2]])
			st.set_normal((b-a).cross(c-a).normalized())
			for corner in 3:
				var i:int=triangle[corner]
				var uv:Array=asset.triangle_uv[t][corner] if asset.has("triangle_uv") else asset.uv[i]
				st.set_uv(Vector2(uv[0],uv[1]))
				st.add_vertex(vec(asset.vertices[i]))
		var mesh:=MeshInstance3D.new()
		mesh.mesh=st.commit()
		mesh.material_override=Painting.mat(load("res://assets/"+row.asset+"-volume.png"),1.0,true)
		mesh.position=vec(row.position)
		if asset.has("socle_height_m"):
			mesh.position.y+=asset.socle_height_m
			var marble:=look(Color("ded4bf"))
			for band in [[.02,.04,.235,.195],[.075,.07,.18,.15],[.12,.02,.215,.175]]:
				solid(vec(row.position)+Vector3(0,band[0],0),Vector3(band[2],band[1],band[3]),marble)
		mesh.rotation=Vector3(row.get("pitch",0.0),row.get("yaw",0.0),0)
		add_child(mesh)
	inventory["catalogue_volume_objects"]=data.instances.size()

func build_front_furniture(row:Dictionary,asset:Dictionary) -> void:
	var node:=Node3D.new()
	add_child(node)
	node.position=vec(row.position)
	node.rotation.y=row.get("yaw",0.0)
	var size:=vec(row.size_m)
	var wood:=look(Color("583a25"))
	var cabinet:bool=row.shape=="cabinet"
	var body:=solid(Vector3(0,(size.y+.16)/2,0),Vector3(size.x*.96,size.y-.16,size.z*.94),wood) if cabinet else solid(Vector3(0,size.y-.025,0),Vector3(size.x,.05,size.z),wood)
	body.reparent(node,false)
	for x in [-size.x*.40,size.x*.40]:
		for z in [-size.z*.35,size.z*.35]:
			var height:float=.16 if cabinet else size.y-.05
			var leg:=solid(Vector3(x,height/2,z),Vector3(.035,height,.035),wood)
			leg.reparent(node,false)
	var front:=Painting.new()
	node.add_child(front)
	front.build_shaped(load("res://assets/"+row.asset+"-volume.png"),Vector2(size.x,size.y),asset.outline,Color("583a25"))
	front.position=Vector3(0,size.y/2,size.z/2)
	# Muse carries the actual front ornament; source-observed box/table depth is native geometry.
	# ponytail: plain wood reverse and square rear legs need side/rear source passes before acceptance.

func build_adjacent_gallery() -> void:
	# Placement follows the secretary/Delacroix sequence in IMG_6385, not the old axial stub.
	var frame:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/frame-geometry.json"))
	var painting:=Painting.new()
	add_child(painting)
	painting.build_framed(load("res://assets/frame.png"),load("res://assets/painting-35.786.jpg"),Vector2(.651,.541),frame.margins_px)
	painting.position=Vector3(-3.48,1.75,2.15)
	painting.rotation.y=PI/2
	inventory["verified_paintings"]=3
