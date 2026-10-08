## #182/#183 throwaway authored rooms, following the Main Hall asset workflow.
## Captured spacing guides placement; every room extent remains provisional.
extends "doorway_walk.gd"

# Per-room addition scripts, built in this order after the rooms themselves.
const ADDITIONS:=["medieval_additions.gd","grey_additions.gd","european_east_additions.gd","european_west_additions.gd","rockefeller_additions.gd","landing_additions.gd","skylight_additions.gd","marble_hall_additions.gd","fixtures_additions.gd"]
const Painting := preload("res://modules/shell/prototype/gallery_walk4/painting_asset.gd")
const SeatedWoman := preload("res://seated_woman_asset.gd")
const VirginChild := preload("res://virgin_child_asset.gd")
const CaseMetal := preload("res://medieval_metal_assets.gd")
const CasePair := preload("res://medieval_ceramic_ivory_assets.gd")
const SaintRoch := preload("res://saint_roch_asset.gd")
const Triptych := preload("res://triptych_asset.gd")
const Pieta := preload("res://pieta_asset.gd")
const RenaissanceA := preload("res://renaissance_case_a_assets.gd")
const RenaissanceB := preload("res://renaissance_case_b_assets.gd")
const RenaissanceWall := preload("res://renaissance_wall_assets.gd")
var inventory := {"point_clouds":0,"bookcase":1,"mirrors":2,"settee":1,"armchairs":3}
var contact_shadow:MeshInstance3D
var ceiling_details:Array[MeshInstance3D]=[]
var _renaissance_grille:Node3D
var _renaissance_triptych_case:StaticBody3D
var _renaissance_pieta_case:StaticBody3D
var _renaissance_east_cases:Array[StaticBody3D]=[]
var _renaissance_wall_art:Array[Node3D]=[]
var hall_reveal:Dictionary # geometry.json's record: wall thickness, leaf width, panel fractions
var reveals:={} # threshold room label -> bounds
var views := [Vector3(-1.50, .25, -2.4), Vector3(-2.50, .25, 3)]

func make_visitor() -> Node3D:
	var actor=load("res://modules/shell/prototype/gallery_walk4/visitor159/visitor.gd").new()
	actor.world_height=1.75
	return actor

var _plan_rooms:Array=[]

## A room's [x0, x1, z0, z1] in room-scene metres, by its geometry.json label.
func room_bounds(label:String) -> Array:
	if _plan_rooms.is_empty():
		_plan_rooms=JSON.parse_string(FileAccess.get_file_as_string("res://geometry.json")).rooms
	for area in _plan_rooms:
		if area.label==label:
			return area.bounds
	assert(false,"No room labelled "+label)
	return []

## A point on a wall of a room: `along` metres from the wall's west end (north and south
## walls) or north end (west and east walls), `height` above the floor, `out` into the room.
func wall_point(label:String,side:String,along:float,height:float,out:=0.0) -> Vector3:
	var b:=room_bounds(label)
	match side:
		"north":return Vector3(b[0]+along,height,b[2]+out)
		"south":return Vector3(b[0]+along,height,b[3]-out)
		"west":return Vector3(b[0]+out,height,b[2]+along)
		_:return Vector3(b[1]-out,height,b[2]+along)

## The wall body nearest `at` on that side of the room: re-parent wall-hung work to it so
## the work disappears with the wall when the camera cuts it away.
func wall_body(label:String,side:String,at:Vector3) -> Node3D:
	var best:Node3D
	var nearest:=INF
	for wall in casings:
		if wall.get_meta("room_wall","")==label+":"+side:
			var d:float=wall.global_position.distance_squared_to(at)
			if d<nearest:
				nearest=d
				best=wall
	return best

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
	var first:=get_child_count()
	build_bookcase()
	build_mirrors()
	build_displays()
	build_furniture()
	build_catalogue_objects()
	# Grey register (opus-grey-register-fit-20261001): Rockefeller and the secretary by its door
	# move 2.2m with the room; the apostles and lion in the same catalogue file keep their z.
	shift_new(first,Vector3(-1.95,0,2.2),1.0)
	# Hall reveal: what now stands in Rockefeller goes north with it; the secretary stays in its gallery.
	shift_new(first,Vector3(0,0,-hall_reveal.wall_m),1.8)
	first=get_child_count()
	build_adjacent_gallery()
	shift_new(first,Vector3(-1.95,0,0))
	first=get_child_count()
	build_sculpture_rooms()
	shift_new(first,Vector3(0,0,9.25))
	# The grille and its slats go with the north wall when that wall is cut away.
	var north_header:Node3D
	for wall in casings:
		if wall.get_meta("room_wall", "") == "light Renaissance room:north:header":
			north_header=wall
	assert(north_header!=null and _renaissance_grille!=null)
	_renaissance_grille.reparent(north_header)
	for wall in casings:
		if wall.get_meta("room_wall", "") == "light Renaissance room:north" and wall.position.x < -3.5:
			assert(_renaissance_triptych_case!=null)
			_renaissance_triptych_case.reparent(wall)
			break
	assert(_renaissance_triptych_case.get_parent().get_meta("room_wall", "") == "light Renaissance room:north")
	for display in _renaissance_east_cases:
		for wall in casings:
			if wall.get_meta("room_wall", "") == "light Renaissance room:east" and abs(wall.position.z-display.position.z)<.1:
				display.reparent(wall)
				break
		assert(display.get_parent().get_meta("room_wall", "") == "light Renaissance room:east")
	for wall in casings:
		if wall.get_meta("room_wall", "") == "light Renaissance room:west":
			assert(_renaissance_pieta_case!=null)
			_renaissance_pieta_case.reparent(wall)
			break
	assert(_renaissance_pieta_case.get_parent().get_meta("room_wall", "") == "light Renaissance room:west")
	for art in _renaissance_wall_art:
		var side:String=art.get_meta("wall_side")
		for wall in casings:
			if wall.get_meta("room_wall", "") == "light Renaissance room:"+side:
				art.reparent(wall)
				break
		assert(art.get_parent().get_meta("room_wall", "") == "light Renaissance room:"+side)
	build_grey_gallery()
	build_connected_hall()
	build_lion_modern_rooms()
	# Room additions (#238): one script per room, each adding only its own nodes with
	# positions taken from the room's walls (room_bounds, wall_point), so a later change
	# to a room's size carries them along.
	for extra in ADDITIONS:
		if ResourceLoader.exists("res://"+extra):
			load("res://"+extra).new().build(self)
	# placed_mesh_check.gd asks for its one fixture; no shipped room has it.
	if "--placed-mesh-fixture" in OS.get_cmdline_user_args():
		load("res://modules/shell/prototype/collection_reconstruction/placed_mesh_fixture.gd").new().build(self)
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

func shift_new(first:int,offset:Vector3,z_before:=INF) -> void:
	# Nodes at or beyond z_before take the x shift only.
	for node in get_children().slice(first):
		if node is Node3D:node.position+=offset if node.position.z<z_before else Vector3(offset.x,offset.y,0)

func build_connected_hall() -> void:
	# Reuse reviewed Main Hall assets, vault and frame shader; no photo doorway cards.
	var builder=load("res://connected_hall.gd").new()
	var scratch:=SubViewport.new()
	add_child(scratch)
	builder._vp=scratch
	builder._build_room()
	builder._build_paintings()
	assert(builder._paintings.size()==23,"All existing Main Hall paintings must survive integration")
	var hall:=Node3D.new()
	hall.name="ConnectedHall"
	hall.position=Vector3(5.55,0,28.1)
	hall.set_meta("painting_lights",builder._paintings)
	add_child(hall)
	for node in scratch.get_children():
		if node is WorldEnvironment:
			node.free()
			continue
		node.reparent(hall,false)
		if node is MeshInstance3D:
			node.layers=1
			if node.material_override is ShaderMaterial:
				var texture=node.material_override.get_shader_parameter("albedo")
				if texture is Texture2D and texture.resource_path.ends_with("/skylight.png"):
					node.set_meta("skylight",true)
					node.material_override.set_shader_parameter("glow",1.0)
			var bounds:AABB=node.mesh.get_aabb()
			if bounds.size.z>26 and bounds.size.y>5.9 and bounds.size.x<.01:
				var side:String="west" if bounds.get_center().x<0 else "east"
				for wall in casings:
					if wall.get_meta("room_wall","")=="Grand Gallery:"+side:
						wall.get_child(1).free()
						node.reparent(wall)
						wall.move_child(node,1)
			if (node.global_transform*node.mesh.get_aabb()).position.y>5.4:ceiling_details.append(node)
		for visual in node.find_children("*","VisualInstance3D",true,false):visual.layers=1
	builder.free()
	scratch.free()
	for z in [11.1,19.1]:
		var bench:=solid(Vector3(5.55,.23,z),Vector3(.95,.46,3),look(Color("2f3a52")),true)
		bench.get_child(1).mesh=ArrayMesh.new()
		bench.set_meta("collision_only",true)
	# Hall177.50s shows a white rectangular casing, not the medieval carved facade.
	# Keep the Muse stone front in medieval; cover its unverified printed reverse here.
	var blue:=look(Color.WHITE,"res://modules/shell/prototype/gallery_walk4/textures/wall-muse.webp")
	for side in [-1,1]:
		var back:=solid(Vector3(5.55+side*(1.9/2+(4.229-1.9)/4),3.861/2,27.857),Vector3((4.229-1.9)/2,3.861,.02),blue,true)
		back.set_meta("room_wall","Grand Gallery:portal-mask")
		wall_face(back,(4.229-1.9)/2,3.861,false,-1)
		var trim:=moulding(.20,3.1,"door-architrave",true)
		trim.position=Vector3(5.55+side*1.05,1.55,27.835)
		trim.rotation.y=PI
		trim.reparent(back)
	var head:=solid(Vector3(5.55,(3.861+3.1)/2,27.857),Vector3(1.9,3.861-3.1,.02),blue,true)
	head.set_meta("room_wall","Grand Gallery:portal-mask-header")
	wall_face(head,1.9,3.861-3.1,false,-1)
	var top:=moulding(.24,2.3,"door-architrave",true)
	top.rotation=Vector3(0,PI,PI/2)
	top.position=Vector3(5.55,3.18,27.835)
	top.reparent(head)
	inventory["main_hall_verified_paintings"]=23
	inventory["connected_museum_loop"]=true
	inventory["museum_metric_accepted"]=false

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
		elif event.keycode == KEY_3:
			reset(Vector3(6.7,.25,.58))
		elif event.keycode == KEY_4:
			reset(Vector3(11.9,.25,26.25))
		elif event.keycode == KEY_5:
			reset(Vector3(14.6,.25,30.05))

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

## A catalogued work as its own mesh: `path` is a .glb (or any scene holding meshes) made by
## prepare_mesh.py, `at` the point its base centre stands on, `yaw` turns its front (+Z), and
## `size_m` is the catalogue width, height, depth in metres. The mesh is scaled to the catalogue
## height. It is drawn as every work in these rooms is, its own texture at full brightness, and
## its shape casts in the room's bake; a mesh that brings no texture is lit by the lightmap
## instead. It blocks walking, is cut away with the camera, and its accession number makes it
## clickable: the caption and detail picture are that number's row in objects.json, or the
## catalogue_* metadata set on the returned node.
func place_mesh(path:String,at:Vector3,yaw:float,size_m:Vector3,accession:String) -> StaticBody3D:
	var scene:Node=load(path).instantiate()
	var sources:Array=scene.find_children("*","MeshInstance3D",true,false)
	if scene is MeshInstance3D:sources.append(scene)
	var parts:Array[MeshInstance3D]=[]
	var box:=AABB()
	for source in sources:
		var pose:=Transform3D.IDENTITY
		var up:Node=source
		while up is Node3D:
			pose=up.transform*pose
			up=up.get_parent()
		# One mesh per surface, each with its own material: what remodel_bake.gd unwraps and bakes.
		for surface in source.mesh.get_surface_count():
			var st:=SurfaceTool.new()
			st.append_from(source.mesh,surface,pose)
			if source.mesh.surface_get_format(surface)&Mesh.ARRAY_FORMAT_NORMAL==0:st.generate_normals()
			var part:=MeshInstance3D.new()
			part.mesh=st.commit()
			# Never the file's own material: a generated mesh arrives fully metallic and bakes black.
			var original=source.get_active_material(surface)
			var skin:Texture2D=original.albedo_texture if original is BaseMaterial3D else null
			var m:=look(Color.WHITE,"",skin!=null)
			if skin!=null:m.albedo_texture=skin
			elif original is BaseMaterial3D:m.albedo_color=original.albedo_color
			part.material_override=m
			box=part.mesh.get_aabb() if parts.is_empty() else box.merge(part.mesh.get_aabb())
			parts.append(part)
	scene.free()
	assert(not parts.is_empty() and box.size.y>0 and size_m.y>0,"No mesh to place, or no catalogue height: "+path)
	var k:=size_m.y/box.size.y
	var node:=StaticBody3D.new()
	node.name="Mesh"+accession.validate_node_name()
	node.position=at
	node.rotation.y=yaw
	var shape:=CollisionShape3D.new()
	var collision:=BoxShape3D.new()
	collision.size=box.size*k
	shape.shape=collision
	shape.position.y=size_m.y/2
	node.add_child(shape)
	for part in parts:
		part.scale=Vector3.ONE*k
		part.position=-Vector3(box.get_center().x,box.position.y,box.get_center().z)*k
		node.add_child(part)
	node.set_meta("catalogue_accession",accession)
	node.set_meta("catalogue_size_m",size_m)
	node.set_meta("placed_mesh",path)
	add_child(node)
	casings.append(node)
	return node

## The trim kit's paint: one white for every casing, skirting and cornice (the footage's trim is
## white in every clip). Seen from both sides, because a door head is drawn from either room.
var _trim_paint:StandardMaterial3D
func trim_paint() -> StandardMaterial3D:
	if _trim_paint==null:
		_trim_paint=look(Color("f3f1ea"))
		_trim_paint.cull_mode=BaseMaterial3D.CULL_DISABLED
	return _trim_paint

## The cased doorway's architrave in section, for a casing 0.16 m wide: [metres across from the
## opening's edge, metres proud of the wall]. A bead at the opening, a flat fascia, an ogee, and a
## raised back band with an eased edge (IMG_6385 1.0s, IMG_6383 62.5s). A narrower casing keeps the
## projections and squeezes the widths.
const ARCHITRAVE:=[[0,0],[0,.014],[.003,.019],[.009,.022],[.015,.019],[.018,.014],[.018,.010],[.084,.010],
	[.088,.011],[.094,.016],[.100,.023],[.108,.028],[.116,.030],[.118,.030],[.118,.036],[.150,.036],[.156,.033],[.160,.026],[.160,0]]

## One cased doorway on one room's side of a wall: the architrave swept up one jamb, across the
## head and down the other with mitred corners, and the lining back to the plane the two rooms
## share. Three meshes (left, head, right) under the door head, so the camera's cut-away tests
## each and never the empty opening. `fixed` is the wall's plan line, `opening` its two edges
## along the wall, `head` the clear height, `width` the casing's width.
func door_casing(header:Node3D,side:String,fixed:float,opening:Array,head:float,width:float) -> void:
	var vertical:bool=side in ["west","east"]
	var face:float=1.0 if side in ["west","north"] else -1.0
	# (along the wall, up, out of the wall face) -> room metres; the wall's face stands .061 in.
	var at:=func(s:float,y:float,out:float) -> Vector3:
		return Vector3(fixed+face*(.061+out),y,s) if vertical else Vector3(s,y,fixed+face*(.061+out))
	var along:=Vector3(0,0,1) if vertical else Vector3(1,0,0)
	var outward:=Vector3(face,0,0) if vertical else Vector3(0,0,face)
	var lo:float=opening[0]
	var hi:float=opening[1]
	var section:Array=[]
	for point in ARCHITRAVE:section.append(Vector2(point[0]*width/.16,point[1]))
	# The facet normals of the section, eased together where the section curves.
	var facets:Array=[]
	for i in section.size()-1:
		var run:Vector2=section[i+1]-section[i]
		facets.append(Vector2(-run.y,run.x).normalized())
	for part in ["left","head","right"]:
		var st:=SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		# Which way "across the casing" points for this run, and its two ends for a given offset.
		var across:Vector3=-along if part=="left" else along if part=="right" else Vector3.UP
		var ends:=func(d:float,out:float) -> Array:
			if part=="left":return [at.call(lo-d,0.0,out),at.call(lo-d,head+d,out)]
			if part=="right":return [at.call(hi+d,head+d,out),at.call(hi+d,0.0,out)]
			return [at.call(lo-d,head+d,out),at.call(hi+d,head+d,out)]
		for i in section.size()-1:
			var a:Array=ends.call(section[i].x,section[i].y)
			var b:Array=ends.call(section[i+1].x,section[i+1].y)
			var normals:Array=[]
			for corner in [i,i+1]:
				var n:Vector2=facets[i]
				var other:int=i-1 if corner==i else i+1
				if other>=0 and other<facets.size() and facets[other].dot(n)>.7:n=(n+facets[other]).normalized()
				normals.append((across*n.x+outward*n.y).normalized())
			for corner in [[a[0],normals[0]],[b[0],normals[1]],[b[1],normals[1]],[a[0],normals[0]],[b[1],normals[1]],[a[1],normals[0]]]:
				st.set_normal(corner[1])
				st.add_vertex(corner[0])
		# The lining: from the wall's face back to the shared plane, facing into the opening.
		var lining:Array=ends.call(0.0,0.0)+ends.call(0.0,-.061)
		for corner in [0,2,3,0,3,1]:
			st.set_normal(-across)
			st.add_vertex(lining[corner])
		var mesh:=MeshInstance3D.new()
		mesh.mesh=st.commit()
		mesh.material_override=trim_paint()
		mesh.set_meta("door_casing",width)
		add_child(mesh)
		mesh.reparent(header)

## The lit green sign over a door, lettered with the game's own font: `at` is its centre, `yaw`
## turns its face (+Z) into the room. Hang it on the wall it belongs to with reparent().
func exit_sign(at:Vector3,yaw:float) -> Node3D:
	var sign:=solid(at,Vector3(.42,.20,.05),look(Color("2c5a3c")))
	sign.rotation.y=yaw
	var lettering:=Label3D.new()
	lettering.text="EXIT"
	lettering.font_size=48
	lettering.pixel_size=.0026
	lettering.modulate=Color("8dfab4")
	lettering.position=Vector3(0,0,.027)
	sign.add_child(lettering)
	sign.set_meta("exit_sign",true)
	return sign

func panel(parent: Node3D, corners: Array, uvs: Array, m: Material, tone := Color.WHITE) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_color(tone)
	var floor:bool=m is ShaderMaterial and m.get_shader_parameter("floor_z_limits") is Vector2
	# A floor faces upward with Godot's clockwise winding, including transposed boards.
	if floor and (corners[1]-corners[0]).cross(corners[3]-corners[0]).y>0:
		corners=corners.duplicate()
		uvs=uvs.duplicate()
		corners.reverse()
		uvs.reverse()
	Painting.quad(st, corners, uvs)
	if floor:st.generate_normals()
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
	hall_reveal=data.hall_reveal
	var floor_limits:=Vector2(INF,-INF)
	for area in data.rooms:
		floor_limits.x=min(floor_limits.x,area.bounds[2]-.1)
		floor_limits.y=max(floor_limits.y,area.bounds[3]+.1)
	assert(floor_limits.x<floor_limits.y)
	oak.set_shader_parameter("floor_z_limits",floor_limits)
	for area in data.rooms:
		var b:Array=area.bounds
		var wall:=look(Color.WHITE,"res://presentation/purple-plaster.png") if area.label.begins_with("purple") else look(Color.WHITE,"res://presentation/wall-plaster.png")
		if area.label=="dark medieval room":wall=look(Color("53545b"),"res://presentation/neutral-plaster.png")
		if area.label.begins_with("Main Hall"):wall=look(Color("7c8ca3"))
		if area.label.begins_with("Grand Gallery"):wall=look(Color.WHITE,"res://modules/shell/prototype/gallery_walk4/textures/wall-muse.webp")
		if area.label in ["lion stair landing","modern painting gallery"]:wall=look(Color.WHITE,"res://presentation/landing-plaster.png")
		if area.label=="grey French gallery":wall=look(Color("b6b4ad"),"res://presentation/neutral-plaster.png")
		if area.label=="light Renaissance room":wall=look(Color("e3e2de"),"res://presentation/neutral-plaster.png")
		var height:float=area.get("height",3.5)
		if area.label in ["light Renaissance room","dark medieval room","modern painting gallery","adjacent gallery","Rockefeller","grey French gallery"]:
			# IMG_6383 62.25s / IMG_6382 88.75s: flat plaster, not the Hall skylight. The European gallery
			# (IMG_6386 74.5s), Rockefeller (IMG_6380 223.5s) and the grey gallery (IMG_6380 16.5s) have the
			# same flat white ceiling over their tracks; it hides with the camera as the others do.
			var ceiling:=solid(Vector3((b[0]+b[1])/2,height+.02,(b[2]+b[3])/2),Vector3(b[1]-b[0],.04,b[3]-b[2]),look(Color("ebe9e3"),"res://presentation/neutral-plaster.png"))
			ceiling.set_meta("opaque_ceiling",area.label)
			ceiling_details.append(ceiling)
		if area.get("floor","")=="basket-weave":
			#6387:1/9/17: large alternating square wood panels, not herringbone.
			for i in int(ceil(b[1]-b[0])):
				for j in int(ceil(b[3]-b[2])):
					for k in 5:
						var xa:float=b[0]+i+k*.2 if (i+j)%2==0 else b[0]+i
						var xb:float=min(b[1],xa+(.2 if (i+j)%2==0 else 1.0))
						var za:float=b[2]+j if (i+j)%2==0 else b[2]+j+k*.2
						var zb:float=min(b[3],za+(1.0 if (i+j)%2==0 else .2))
						if xa<13.55:zb=min(zb,33.715)
						if zb<=za or xb<=xa:continue
						panel(self,[Vector3(xa,.003,za),Vector3(xb,.003,za),Vector3(xb,.003,zb),Vector3(xa,.003,zb)],
							[Vector2.ZERO,Vector2.DOWN,Vector2.ONE,Vector2.RIGHT] if (i+j)%2==0 else [Vector2.ZERO,Vector2.RIGHT,Vector2.ONE,Vector2.DOWN],oak,Color(1,1,1,fmod((i*7+j*3+k)*.131,1.0)))
		elif area.label=="dark medieval room" or area.get("floor","")=="herringbone":
			build_parquet(b,oak)
		else:
			var across:bool=area.label.begins_with("purple") or area.get("boards_across",false)
			var fb:Array=[b[2],b[3],b[0],b[1]] if across else b
			for i in int(ceil((fb[1]-fb[0])/.14)):
				var xa:float=fb[0]+i*.14
				var xb:float=min(fb[1],xa+.14)
				for j in int(ceil((fb[3]-fb[2])/1.8))+1:
					var za:float=max(fb[2],fb[2]+j*1.8-(i%3)*.6)
					var zb:float=min(fb[3],fb[2]+(j+1)*1.8-(i%3)*.6)
					if zb<=za:continue
					var corners:Array=[Vector3(xa,.003,za),Vector3(xb,.003,za),Vector3(xb,.003,zb),Vector3(xa,.003,zb)]
					if across:corners=corners.map(func(p):return Vector3(p.z,p.y,p.x))
					panel(self,corners,
						[Vector2.ZERO,Vector2.DOWN,Vector2.ONE,Vector2.RIGHT],oak,Color(1,1,1,fmod((i*7+j*3)*.131,1.0)))
		if area.get("reveal",false):
			# A wall's thickness, not a room: build_reveal lines it.
			reveals[area.label]=b
			continue
		for side in ["west","east","north","south"]:
			var vertical:bool=side in ["west","east"]
			var fixed:float=b[0] if side=="west" else b[1] if side=="east" else b[2] if side=="north" else b[3]
			var lo:float=b[2] if vertical else b[0]
			var hi:float=b[3] if vertical else b[1]
			var opening:Array=area.openings.get(side,[])
			var spans:Array=[[lo,hi]] if opening.is_empty() else [[lo,opening[0]],[opening[1],hi]]
			for span in spans:
				if span[1]-span[0]<.001:continue
				var center:=Vector3(fixed,height/2,(span[0]+span[1])/2) if vertical else Vector3((span[0]+span[1])/2,height/2,fixed)
				var size:=Vector3(.12,height,span[1]-span[0]) if vertical else Vector3(span[1]-span[0],height,.12)
				var casing:=solid(center,size,wall,true)
				casing.set_meta("room_wall",area.label+":"+side)
				var inward:float=1.0 if side in ["west","north"] else -1.0
				wall_face(casing,span[1]-span[0],height,vertical,inward)
				# White and about 20 cm tall in every clip (IMG_6383 34.0s, IMG_6385 1.0s).
				var trim:=moulding(span[1]-span[0],.20,"baseboard",false)
				if area.label.begins_with("purple"):
					trim.material_override=look(Color("15151b") if side=="south" else Color.WHITE,"" if side=="south" else "res://presentation/purple-plaster.png")
					trim.set_meta("connector_baseboard",side)
				trim.position=Vector3(fixed+inward*.065,.10,(span[0]+span[1])/2) if vertical else Vector3((span[0]+span[1])/2,.10,fixed+inward*.065)
				trim.rotation.y=inward*PI/2 if vertical else 0.0 if inward==1.0 else PI
				trim.reparent(casing)
			if opening.is_empty():continue
			var width:float=opening[1]-opening[0]
			var middle:float=(opening[0]+opening[1])/2
			var stone:bool=side in area.get("stone_sides",[])
			var clear_height:float=(3.342 if vertical else 3.861) if stone else 2.74
			clear_height=float(area.get("clear_heights",{}).get(side,clear_height))
			assert(height>clear_height,"Opening must leave a positive header above its source-fitted head")
			var header_y:float=(height+clear_height)/2
			var header:=solid(Vector3(fixed,header_y,middle) if vertical else Vector3(middle,header_y,fixed),Vector3(.38,height-clear_height,width) if vertical else Vector3(width,height-clear_height,.38),wall,true)
			header.set_meta("room_wall",area.label+":"+side+":header")
			wall_face(header,width,height-clear_height,vertical,1.0 if side in ["west","north"] else -1.0)
			if stone or side in area.get("column_sides",[]):continue
			var casing_width:float=.10 if area.label in ["grey French gallery","purple elevator-5 connector","Skylight Gallery"] else .16
			header.set_meta("source_casing_width",casing_width)
			door_casing(header,side,fixed,opening,minf(clear_height,2.74),casing_width)
	# Ceiling rails and vents follow the wide views, and Rockefeller north by the Hall reveal.
	var north:=Vector3(0,0,-hall_reveal.wall_m)
	for x in [-3.65,-1.55,.55]:
		for z in [-3.3,-1.3,.7]:
			var rail:=solid(Vector3(x,3.43,z)+north,Vector3(1.65,.025,.035),ivory)
			ceiling_details.append(rail)
			for offset in [-.5,.5]:
				var fixture:=solid(Vector3(x+offset,3.33,z)+north,Vector3(.08,.15,.08),ivory)
				fixture.reparent(rail)
	for spec in [[Vector3(-2.5,3.04,1.59),0.0],[Vector3(1.48,3.04,.58),PI/2]]:
		var vent:=solid(spec[0]+north,Vector3(1.85,.07,.018),look(Color("746f64")))
		vent.rotation.y=spec[1]
		ceiling_details.append(vent)
	inventory["muse_architecture_assets"]=6

func build_grey_gallery() -> void:
	# Reciprocal source views establish wall relationships; all metric offsets are provisional.
	var ivory:=look(Color("eeeae2"))
	# Violet is on the north side looking from Rockefeller; black panels face it.
	var black:=look(Color("28262b"))
	black.cull_mode=BaseMaterial3D.CULL_BACK
	var south:StaticBody3D
	var north:StaticBody3D
	for wall in casings:
		if wall.get_meta("room_wall","")=="purple elevator-5 connector:north":north=wall
		if str(wall.get_meta("room_wall","" )).begins_with("purple") and str(wall.get_meta("room_wall","")).ends_with(":south"):
			assert(south==null,"Purple south wall must have one owner")
			south=wall
	assert(south!=null,"Black panel faces must belong to the purple south wall")
	assert(north!=null,"Lift must have a cutaway wall owner")
	var black_face:=MeshInstance3D.new()
	var quad:=QuadMesh.new()
	quad.size=Vector2(2.15,3.5)
	black_face.mesh=quad
	black_face.material_override=black
	black_face.position=Vector3(2.775,1.75,1.43-hall_reveal.wall_m)
	black_face.rotation.y=PI
	black_face.set_meta("continuous_black_connector",true)
	add_child(black_face)
	black_face.reparent(south)
	# Closed elevator pair: a wall feature, not an invented walkable connection.
	for x in [2.40,2.90]:
		var lift:=solid(Vector3(x,1.35,-.27-hall_reveal.wall_m),Vector3(.49,2.7,.045),ivory)
		lift.set_meta("lift_panel",true)
		lift.reparent(north)
	var number:=Label3D.new()
	number.text="5"
	number.font_size=100
	number.pixel_size=.005
	number.modulate=Color("27252a")
	number.position=Vector3(2.65,2.05,-.23-hall_reveal.wall_m)
	add_child(number)
	number.reparent(north)
	var first:=get_child_count()
	# Wide column opening faces the purple connector, rather than a door at the far end of a tube.
	# The north column keeps its authored 1.6m from the moved north wall (-4.2); 6380 247.5/248.5s
	# has the south one near the connector axis, so it stays. Their spacing is unmeasured.
	for z in [-2.6,.2]:
		var column:=StaticBody3D.new()
		column.position=Vector3(15.65,1.4,z)
		var shape:=CollisionShape3D.new()
		var cylinder:=CylinderShape3D.new()
		cylinder.radius=.19
		cylinder.height=2.8
		shape.shape=cylinder
		column.add_child(shape)
		var visual:=MeshInstance3D.new()
		var mesh:=CylinderMesh.new()
		mesh.top_radius=.145
		mesh.bottom_radius=.18
		mesh.height=2.8
		mesh.radial_segments=12
		mesh.rings=1
		visual.mesh=mesh
		visual.material_override=ivory
		column.add_child(visual)
		add_child(column)
		casings.append(column)
		var base:=solid(Vector3(15.65,.08,z),Vector3(.46,.16,.46),ivory)
		base.reparent(column)
		var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/ionic-capital-geometry.json"))
		assert(data.edge_pair_counts.size()==1 and int(data.edge_pair_counts[0])==2,"Capital must be a closed low polygon solid")
		var capital:=MeshInstance3D.new()
		capital.mesh=stone_mesh(data,data.faces,data.size_m[2])
		capital.material_override=look(Color.WHITE,"res://assets/ionic-capital.png")
		capital.position=Vector3(15.65,2.7,z)
		capital.rotation.y=-PI/2
		add_child(capital)
		capital.reparent(column)
	# 6380 35.0/35.5s: smooth shafts, end pilasters and a cream beam; metres remain provisional.
	# The beam starts where the capitals end (3.10). It used to start at 2.72 and swallow them, so the
	# bake left them black and they showed from the stair side, where the camera cuts the beam away.
	var beam:=solid(Vector3(15.65,3.30,-1.2),Vector3(.48,.40,6.0),ivory)
	beam.set_meta("column_beam",true)
	var cornice:=moulding(6.0,.16,"door-architrave",false)
	cornice.position=Vector3(15.39,3.40,-1.2)
	cornice.rotation.y=PI/2
	cornice.reparent(beam)
	for z in [-4.05,1.65]:
		var pilaster:=solid(Vector3(15.65,1.45,z),Vector3(.16,2.9,.30),ivory)
		pilaster.set_meta("column_end_pilaster",true)
		var cap:=solid(Vector3(15.65,3.0,z),Vector3(.30,.20,.46),ivory)
		cap.reparent(pilaster)
	# Capital side/rear relief, dentils and entablature dimensions are still unaccepted.
	# Bertin sits on the Hall-door wall between Villeneuve and Pannini; exact offsets remain provisional.
	# Courbet centre 4.86m from the south-west corner (fit); Corot rides the north wall, offset along it unmeasured.
	# #238: Courbet 1.80 -> 1.69 (IMG_6380 3.1s, level with the Gericault); Bertin .2m east so its gap to the
	# Pannini is the .58m of IMG_6379 172.3s. Label cards are the polish spec's .30 x .17, clear of the frame.
	for spec in [["courbet","43.571",Vector3(8.53,1.69,-3.06),PI/2],["corot","24.089",Vector3(14.8,1.8,-4.12),0.0],["bertin","56.214",Vector3(13.5,1.75,1.72),PI]]:
		var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/"+spec[0]+"-frame-geometry.json"))
		var painting:=Painting.new()
		add_child(painting)
		painting.build_framed(load("res://assets/"+spec[0]+"-frame.png"),load("res://assets/painting-"+spec[1]+".jpg"),Vector2(data.canvas_m[0],data.canvas_m[1]),data.margins_px)
		painting.position=spec[2]
		painting.rotation.y=spec[3]
		var label:=solid(Vector3.ZERO,Vector3(.30,.17,.004),look(Color("e9e4d4")))
		label.reparent(painting,false)
		label.position=Vector3(painting.outer.x/2+.25,-.12,.01)
		label.set_meta("artwork_label_proxy",true)
	# The Skylight door's two leaves are hung in its own reveal by skylight_additions.gd.
	shift_new(first,Vector3(-4.6,0,-hall_reveal.wall_m))
	build_reveal("Grand Gallery reveal threshold",true)
	build_reveal("Rockefeller reveal threshold",false)
	inventory["grey_gallery_verified_paintings"]=3
	inventory["grey_gallery_hall_reveal_leaves_built"]=true
	inventory["hall_reveal"]={"wall_m":hall_reveal.wall_m,"leaf_m":hall_reveal.leaf_m,"depth_measured":false,"opening_metres_accepted":false,"leaf_fidelity_accepted":false,"rockefeller_leaf_built":false}
	inventory["grey_gallery_objects_complete"]=false
	inventory["grey_gallery_metric_accepted"]=false

func build_reveal(label:String,leaves:bool) -> void:
	# 6343 0.5/35s, 6380 100/106.25s, 6385 0..2s: the wall's thickness is one panelled reveal. Each leaf
	# folds flat on its side, hinged at the north frame with its knob at the south face.
	# ponytail: depth, head and leaf metres are the pose in geometry.json, not a survey. The three Muse
	# panels are re-laid to the observed heights, so their mouldings stretch; redraw only if that reads.
	var b:Array=reveals[label]
	var ivory:=trim_paint()
	var proud:=.19 # every door frame here stands this far out of its wall
	var north:float=b[2]-proud
	var south:float=b[3] if leaves else b[3]+proud
	var soffit:=solid(Vector3((b[0]+b[1])/2,2.76,(north+south)/2),Vector3(b[1]-b[0],.04,south-north),ivory)
	soffit.set_meta("opaque_ceiling",label)
	ceiling_details.append(soffit)
	for side in [-1,1]:
		var x:float=b[0] if side==-1 else b[1]
		var wall:String=label+(":west" if side==-1 else ":east")
		if not leaves:
			# Only the gap between the two door frames; their own jambs line the rest.
			var lining:=solid(Vector3(x,1.35,(b[2]+b[3])/2),Vector3(.08,2.7,b[3]-b[2]-2*proud),ivory,true)
			lining.set_meta("room_wall",wall)
			continue
		var width:float=hall_reveal.leaf_m
		var height:=2.72
		var leaf:=solid(Vector3(x-side*.0225,height/2+.01,b[3]-width/2),Vector3(.045,height,width),ivory,true)
		leaf.set_meta("room_wall",wall)
		leaf.set_meta("hall_reveal_leaf",wall)
		for index in 3:
			var span:Array=hall_reveal.leaf_panels_from_top[index]
			var top:float=height*(.5-span[0])
			var bottom:float=height*(.5-span[1])
			for face in [-.0235,.0235]:
				panel(leaf,[Vector3(face,bottom,-.35*width),Vector3(face,bottom,.35*width),Vector3(face,top,.35*width),Vector3(face,top,-.35*width)],
					[Vector2(0,1),Vector2(1,1),Vector2(1,0),Vector2(0,0)],look(Color.WHITE,"res://assets/white-panel-door-%d.png"%index))
		var knob:=MeshInstance3D.new()
		var sphere:=SphereMesh.new()
		sphere.radius=.025
		sphere.height=.05
		sphere.radial_segments=8
		sphere.rings=4
		knob.mesh=sphere
		knob.material_override=look(Color("514831"))
		# Seen on the face turned to the opening; the hidden face lies on the reveal.
		knob.position=Vector3(-side*.045,height*(.5-hall_reveal.knob_from_top),width/2-.07)
		leaf.add_child(knob)

func wall_face(body:Node3D,width:float,height:float,vertical:bool,inward:float) -> void:
	# Each room owns its inward face; overlapping shared wall boxes caused colour flicker.
	var visual:MeshInstance3D=body.get_child(1)
	visual.material_override.cull_mode=BaseMaterial3D.CULL_BACK
	assert(visual.material_override.cull_mode==BaseMaterial3D.CULL_BACK,"Room faces must not render their exterior backs")
	var quad:=QuadMesh.new()
	quad.size=Vector2(width,height)
	visual.mesh=quad
	visual.position=Vector3(inward*.061,0,0) if vertical else Vector3(0,0,inward*.061)
	visual.rotation.y=inward*PI/2 if vertical else 0.0 if inward==1.0 else PI
	if str(body.get_meta("room_wall","")).begins_with("Grand Gallery"):
		visual.material_override=visual.material_override.duplicate()
		visual.material_override.uv1_scale=Vector3(width/4,height/4,1)
		if not vertical:visual.position.z=inward*.001

func build_parquet(b:Array,oak:Material) -> void:
	# Reuse the Main Hall's 45-degree herringbone lattice; clip each plank to this room.
	var center:=Vector2((b[0]+b[1])/2,(b[2]+b[3])/2)
	var rot:=Transform2D(PI/4,Vector2.ZERO)
	var inverse:=rot.affine_inverse()
	var bounds:=PackedVector2Array([Vector2(b[0],b[2])-center,Vector2(b[1],b[2])-center,Vector2(b[1],b[3])-center,Vector2(b[0],b[3])-center])
	var st:=SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var covered_area:=0.0
	var j_reach:=0
	var k_reach:=0
	for corner in bounds:
		var q:Vector2=inverse*corner
		j_reach=max(j_reach,int(ceil(abs(q.x-q.y)/(2*.84)))+2)
		k_reach=max(k_reach,int(ceil(abs(q.x+q.y)/(2*.14)))+5) # whole planks span4 lattice rows
	for j in range(-j_reach,j_reach+1):
		for k in range(-k_reach,k_reach+1):
			var origin:=Vector2(k*.14+j*.84,k*.14-j*.84)
			for vertical in [false,true]:
				var r:=Rect2(origin,Vector2(.84,.14)) if not vertical else Rect2(origin+Vector2(0,.14),Vector2(.14,.84))
				var poly:=PackedVector2Array([rot*r.position,rot*Vector2(r.end.x,r.position.y),rot*r.end,rot*Vector2(r.position.x,r.end.y)])
				for clipped in Geometry2D.intersect_polygons(poly,bounds):
					var area:=0.0
					for index in clipped.size():area+=(clipped[index]-clipped[0]).cross(clipped[(index+1)%clipped.size()]-clipped[0])
					covered_area+=abs(area)/2
					for index in Geometry2D.triangulate_polygon(clipped):
						var q:Vector2=clipped[index]
						assert(q.x+center.x>=b[0]-.0001 and q.x+center.x<=b[1]+.0001 and q.y+center.y>=b[2]-.0001 and q.y+center.y<=b[3]+.0001)
						var uv:Vector2=(inverse*q-r.position)/r.size
						if vertical:uv=Vector2(uv.y,1-uv.x)
						st.set_color(Color(1,1,1,fposmod((k*7+j*3)*.131,1.0)))
						st.set_normal(Vector3.UP)
						st.set_uv(uv)
						st.add_vertex(Vector3(q.x+center.x,.003,q.y+center.y))
	assert(abs(covered_area-(b[1]-b[0])*(b[3]-b[2]))<.03,"Parquet area %s /%s bounds%s lattice%s,%s"%[covered_area,(b[1]-b[0])*(b[3]-b[2]),b,j_reach,k_reach])
	var floor:=MeshInstance3D.new()
	floor.mesh=st.commit()
	floor.material_override=oak
	add_child(floor)

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
	# White in every clip: skirting, casings and cornices share the kit's one paint. `kind` names
	# what the run is ("baseboard", "door-architrave"), for the builders that look for it.
	mesh.material_override=trim_paint()
	mesh.set_meta("trim",kind)
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

func display_case(at:Vector3,size:Vector3,pedestal:=false) -> void:
	var ivory:=look(Color("eeeae2"))
	# IMG_6380: gold service has a solid base; pink Worcester has a tray on legs.
	if pedestal:
		var base:=solid(at+Vector3(0,.55,0),Vector3(size.x,1.1,size.z),ivory,true)
		assert(is_equal_approx(base.position.y- base.get_child(0).shape.size.y/2,at.y))
	else:
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
	# #238: the pink case hangs on the wall and is about .6 deep (6380 123..128s, 176..178.5s). At .88 and
	# clear of the wall it reached within .23m of the east door's axis and stopped a visitor walking in.
	display_case(Vector3(1.85,0,-.76),Vector3(1.8,0,.6))
	display_case(Vector3(3.05,0,-3.8),Vector3(1.0,0,1.8),true)
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
		var below_ceiling:bool=has_meta("bake_preparing") or camera.global_position.y<3.4
		rail.visible=below_ceiling if rail.has_meta("opaque_ceiling") else not inventory.has("native_lightmap_users") or below_ceiling
	var baked=get_node_or_null("BakedRoom")
	if baked:
		for surface in baked.get_children():
			if surface is MeshInstance3D and surface.has_meta("live_cutaway"):
				var target=surface.get_meta("live_cutaway")
				surface.visible=target.get_parent().get_child(1).is_visible_in_tree() if target.get_parent() is StaticBody3D and target.get_parent() in casings else target.is_visible_in_tree()

func load_bake() -> void:
	if has_meta("bake_preparing"):return
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
	for spec in [["settee",Vector3(-2.21,.13,-4.7),PI/2],["armchair",Vector3(2.8,.13,-6.65),0.0],["armchair",Vector3(-1.9,.13,-6.65),0.0],["entrance-chair",Vector3(-2.2,.13,-1.95),PI/2]]:
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
		mesh.set_meta("catalogue_asset",row.asset)
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
	# Delacroix follows the Rockefeller door it was filmed from (6385), as the secretary does.
	# Fetti, the piers and Goltzius were read mid-gallery or from the far end (6386); their z is
	# kept as authored and stays unaccepted until the gallery is fitted.
	# #238: the dress case and the secretary take the corner first (6385 2..21s), then the Piranesi;
	# the Delacroix follows them. By wall order and catalogue widths, not measured.
	painting.position=Vector3(-3.485,1.75,6.85)
	painting.rotation.y=PI/2
	painting.set_meta("catalogue_accession","35.786")
	# The secretary (catalogue data, already in the room) clears the dress case in the corner.
	for node in get_children():
		if node is Node3D and node.position.distance_to(Vector3(-5.19,.13,3.05))<.02:node.position.z=3.55
	var fetti:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/fetti-frame-geometry.json"))
	var angels:=Painting.new()
	add_child(angels)
	angels.build_framed(load("res://assets/fetti-frame.png"),load("res://assets/painting-36.003.jpg"),Vector2(.781,.895),fetti.margins_px)
	# #238: 11.1m from the south wall, was 19.3m (camera solve of 6384..6386 scaled by this frame
	# and the Tironi's; docs/evidence/museum-238/european-west/NOTES.md). Provisional.
	angels.position=Vector3(-3.485,1.8,16.96)
	angels.rotation.y=PI/2
	angels.set_meta("catalogue_accession","36.003")
	# IMG_6386 44.5/67.5s: nothing stands out of this wall but the one white display panel on the
	# platform, which european_east_additions.gd builds. The two full-height piers once built here
	# were a misreading of that panel and are gone.
	inventory["gallery_piers"]=0
	# IMG_6386 102.75/104.75s: two unequal panels, leaves swing into Renaissance.
	# ponytail: right-angle swing and leaf dimensions remain provisional; wall relationship is observed.
	for x in [-1.59,.49]:
		var ivory:=look(Color("eee9de"))
		var leaf:=solid(Vector3(x,1.38,28.58),Vector3(.07,2.7,.96),ivory,true)
		for index in 2:
			var y:float=[1.73,.43][index]
			var height:float=[1.66,.60][index]
			for side in [-1,1]:
				var face:float=x+side*.042
				panel(leaf,[Vector3(face-x,y-height/2-1.38,-.36),Vector3(face-x,y-height/2-1.38,.36),Vector3(face-x,y+height/2-1.38,.36),Vector3(face-x,y+height/2-1.38,-.36)],
					[Vector2(0,1),Vector2(1,1),Vector2(1,0),Vector2(0,0)],look(Color.WHITE,"res://assets/european-two-panel-door-%d.png"%index))
				for edge in [-1,1]:
					var stile:=solid(Vector3(x+side*.050,y,28.58+edge*.36),Vector3(.014,height+.03,.03),ivory)
					stile.reparent(leaf)
					var rail:=solid(Vector3(x+side*.050,y+edge*height/2,28.58),Vector3(.014,.03,.75),ivory)
					rail.reparent(leaf)
		for side in [-1,1]:
			var knob:=MeshInstance3D.new()
			var sphere:=SphereMesh.new()
			sphere.radius=.025
			sphere.height=.05
			sphere.radial_segments=8
			sphere.rings=4
			knob.mesh=sphere
			knob.material_override=look(Color("514831"))
			knob.position=Vector3(x+side*.070,.88,28.99)
			add_child(knob)
			knob.reparent(leaf)
	inventory["european_door_panels_per_leaf"]=2
	inventory["european_door_swing_into_renaissance"]=true
	inventory["far_doorway_threshold"]=1
	var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/goltzius-frame-geometry.json"))
	var goltzius:=Painting.new()
	add_child(goltzius)
	goltzius.build_framed(load("res://assets/goltzius-frame.png"),load("res://assets/painting-61.006.jpg"),Vector2(.345,.510),data.margins_px)
	# #238: 6.1m from the south wall, was 13.4m (same solve). Provisional.
	goltzius.position=Vector3(-3.485,1.75,22.01)
	goltzius.rotation.y=PI/2
	goltzius.set_meta("catalogue_accession","61.006")
	inventory["verified_paintings"]=5

func stone_mesh(data:Dictionary,faces:Array,depth:float) -> ArrayMesh:
	var st:=SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for face in faces:
		var corners:Array=[]
		var uv:Array=[]
		for p in face:
			var u:float=float(p[0])/data.grid[0]
			var v:float=float(p[1])/data.grid[1]
			corners.append(Vector3((u-.5)*data.size_m[0],v*data.size_m[1],(p[2]-.5)*depth))
			uv.append(Vector2(u,1-v))
		Painting.quad(st,corners,uv)
	return st.commit()

func stone_asset(kind:String,at:Vector3,yaw:float) -> void:
	var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/"+kind+"-geometry.json"))
	assert(data.edge_pair_counts.size()==1 and int(data.edge_pair_counts[0])==2,"Stone asset must be closed around every opening")
	var body:=StaticBody3D.new()
	body.position=at
	body.rotation.y=yaw
	var mesh:=stone_mesh(data,data.faces,data.size_m[2])
	var infill:=stone_mesh(data,data.infill_faces,.13)
	var collision:=CollisionShape3D.new()
	var shape:=ConcavePolygonShape3D.new()
	shape.set_faces(mesh.get_faces()+infill.get_faces())
	collision.shape=shape
	body.add_child(collision)
	var visual:=MeshInstance3D.new()
	visual.mesh=mesh
	visual.material_override=look(Color.WHITE,"res://assets/"+kind+".png")
	body.add_child(visual)
	if kind=="romanesque-portal":
		# The source carving belongs to the medieval front; reverse/depth remain unverified.
		visual.mesh=stone_mesh(data,data.faces.filter(func(q):return q.all(func(p):return int(p[2])==1)),data.size_m[2])
		# Existing quad winding needs two-sided rendering; the closed plain reverse occludes it.
		var reverse:=MeshInstance3D.new()
		reverse.mesh=stone_mesh(data,data.faces.filter(func(q):return not q.all(func(p):return int(p[2])==1)),data.size_m[2])
		reverse.material_override=look(Color("b8ad94"))
		body.add_child(reverse)
	# Solid wall outside the arch, with a different inward face for each adjacent room.
	var front:Array=[]
	var back:Array=[]
	var sides:Array=[]
	for q in data.infill_faces:
		if q.all(func(p):return int(p[2])==1):front.append(q)
		elif q.all(func(p):return int(p[2])==0):back.append(q)
		else:sides.append(q)
	for spec in [[front,look(Color("53545b"),"res://presentation/neutral-plaster.png") if kind=="romanesque-portal" else look(Color("e3e2de"),"res://presentation/neutral-plaster.png")],[back,look(Color("7c8ca3")) if kind=="romanesque-portal" else look(Color("53545b"),"res://presentation/neutral-plaster.png")],[sides,look(Color("53545b"))]]:
		var fill:=MeshInstance3D.new()
		fill.mesh=stone_mesh(data,spec[0],.13)
		fill.material_override=spec[1]
		body.add_child(fill)
	add_child(body)
	casings.append(body)
	inventory[kind+"_triangles"]=data.triangles

func build_sculpture_rooms() -> void:
	# Native6383 35.75/63.75/64.75s, RISD API1546096: right of the European doorway.
	# ponytail: source-relative offset and 9cm frame profile; coupled room fit remains open.
	var frame:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/perugino-frame-geometry.json"))
	var perugino:=Painting.new()
	add_child(perugino)
	perugino.build_framed(load("res://assets/perugino-frame.png"),load("res://assets/painting-16.236.jpg"),Vector2(.391,.575),frame.margins_px)
	perugino.position=Vector3(-.47,1.55,18.93)
	inventory["renaissance_verified_paintings"]=1
	# Reciprocal wides show a shallow horizontal ventilation grille above the north door.
	var grille:=solid(Vector3(-2.5,3.20,18.94),Vector3(1.10,.18,.025),look(Color("474742")))
	_renaissance_grille=grille
	grille.set_meta("renaissance_north_grille",true)
	for y in [-.06,-.03,0,.03,.06]:
		var slat:=solid(Vector3(-2.5,3.20+y,18.963),Vector3(1.08,.008,.012),look(Color("77766d")))
		slat.reparent(grille)
	stone_asset("romanesque-portal",Vector3(5.55,0,18.85),0)
	stone_asset("tracery-arch",Vector3(.55,2.25,22.515),-PI/2)
	# The API size is the top fragment; installed engaged shafts are separately provisional.
	for side in [-1,1]:
		for offset in [-.045,0,.045]:
			var shaft:=MeshInstance3D.new()
			var cylinder:=CylinderMesh.new()
			cylinder.top_radius=.033
			cylinder.bottom_radius=.033
			cylinder.height=2.25
			cylinder.radial_segments=6
			cylinder.rings=1
			shaft.mesh=cylinder
			shaft.position=Vector3(.49+offset,1.125,22.515+side*.62)
			shaft.material_override=look(Color("b8ad94"))
			add_child(shaft)
	# The native close shots show exposed panel outlines on grey mounts, not added frames.
	# ponytail: offsets follow reciprocal wides; absolute wall metres and mounting heights remain provisional.
	for spec in [["20.207",Vector3(.70,1.55,20.75),PI/2],["57.301",Vector3(.70,1.55,19.53),PI/2],["22.047",Vector3(2.00,1.55,19.05),0.0]]:
		var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/panel-"+spec[0]+".json"))
		var mount:=Node3D.new()
		mount.name="MedievalPanel"+str(spec[0]).replace(".","_")
		mount.position=spec[1]
		mount.rotation.y=spec[2]
		add_child(mount)
		var size:=Vector2(data.size_m[0],data.size_m[1])
		var support:=solid(Vector3.ZERO,Vector3(size.x+.10,size.y+.10,.025),look(Color("959691")))
		support.reparent(mount,false)
		var art:=Painting.new()
		mount.add_child(art)
		art.position.z=.013
		art.scale.z=float(data.depth_m)/.05
		art.build_shaped(load("res://assets/painting-"+spec[0]+".jpg"),size,data.outline,Color("674d29"))
		assert(art.get_child_count()==2 and art.outer==size)
	# North-wall display projection and vents are visible in6382 85.25..87.25s.
	var projection:=solid(Vector3(3.05,2.125,18.98),Vector3(.77,4.25,.22),look(Color("53545b")))
	var screen:=solid(Vector3(3.05,2.8,19.104),Vector3(.44,.90,.015),look(Color("0a0a0b")))
	screen.reparent(projection)
	for spec in [[Vector3(1.75,3.82,19.06),Vector2(1.35,.16)],[Vector3(1.46,.45,19.06),Vector2(.48,.24)]]:
		var north_grille:=solid(spec[0],Vector3(spec[1].x,spec[1].y,.02),look(Color("222426")))
		for index in 6:
			var slat:=solid(spec[0]+Vector3(0,(index/5.0-.5)*spec[1].y,.012),Vector3(spec[1].x,.008,.012),look(Color("75756d")))
			slat.reparent(north_grille)
	build_gabled_frame()
	build_iron_grille()
	build_medieval_stair_door()
	# Catalogue41.046 left /41.045 right; native6382 widesshow projecting brackets and grey backplates.
	# Both keep their offsets from the stair door, which moved onto the tracery axis.
	for z in [21.215,23.965]:
		var bracket:=solid(Vector3(10.42,.95,z),Vector3(.32,.18,.36),look(Color("e2e1dd")),true)
		var backplate:=solid(Vector3(10.48,1.43,z),Vector3(.025,1.52,.42),look(Color("74757b")))
		backplate.reparent(bracket)
	inventory["stair_wall_apostles"]={"accessions":["41.046","41.045"],"catalogue_width_height":true,"mount_depth_placement_accepted":false,"muse_damage_fidelity_accepted":false}
	inventory["medieval_verified_panels"]=4
	inventory["medieval_objects_complete"]=false
	# IMG_6383 61.25..64.75s: black central bench; dimensions unmeasured.
	var bench:=solid(Vector3(-2.75,.43,22.4),Vector3(1.65,.16,.55),look(Color("282526")),true)
	for x in [-3.4,-2.1]:
		for z in [22.18,22.62]:
			var leg:=solid(Vector3(x,.2,z),Vector3(.07,.4,.07),look(Color("29231e")))
			leg.reparent(bench)
	# Shuttered west window and raised textile-wall plinth are visible in reciprocal wides.
	var white:=look(Color("f0eeea"))
	#6383 60.60s source-plane ratios: blind .63..3.00m, sill under it, ±6cm; no survey acceptance.
	var blind:=solid(Vector3(-5.47,1.815,22.7),Vector3(.08,2.37,1.25),white)
	blind.set_meta("renaissance_west_blind",true)
	var sill:=solid(Vector3(-5.43,.57,22.7),Vector3(.20,.12,1.45),white)
	sill.set_meta("renaissance_west_sill",true)
	for part in [blind,sill]:
		part.set_meta("wall_side","west")
		_renaissance_wall_art.append(part)
	# IMG_6383 18.3/62.0s: polychromed wood on a white floor plinth before this window.
	# ponytail: plinth/hood metres and window-relative offset are by eye; replace after source fitting.
	var roch_at:=Vector3(-4.86,0,22.7)
	var roch_plinth:=solid(roch_at+Vector3(0,.30,0),Vector3(.70,.60,.70),white,true)
	roch_plinth.set_meta("saint_roch_installation",true)
	for spec in [["foot",.025,.05,.78],["cap",.62,.04,.80],["mount",.66,.04,.64]]:
		var step:=solid(roch_at+Vector3(0,spec[1],0),Vector3(spec[3],spec[2],spec[3]),white)
		step.set_meta("saint_roch_plinth_step",spec[0])
		step.reparent(roch_plinth)
	var roch_label:=solid(roch_at+Vector3(.401,.625,.10),Vector3(.003,.035,.11),look(Color("dedbd4")))
	roch_label.set_meta("artwork_label_proxy",true)
	roch_label.reparent(roch_plinth)
	var roch:=SaintRoch.build() # Muse sheet rejected off-axis; keep the closed flat study.
	add_child(roch)
	roch.position=roch_at+Vector3(0,.68,0)
	roch.rotation.y=PI/2
	roch.reparent(roch_plinth)
	var roch_glass:=look(Color(.82,.90,.91,.10),"",true)
	for side in [-1,1]:
		var pane:=solid(roch_at+Vector3(side*.35,1.365,0),Vector3(.012,1.45,.70),roch_glass)
		pane.reparent(roch_plinth)
		pane=solid(roch_at+Vector3(0,1.365,side*.35),Vector3(.70,1.45,.012),roch_glass)
		pane.reparent(roch_plinth)
	var roch_lid:=solid(roch_at+Vector3(0,2.09,0),Vector3(.70,.012,.70),roch_glass)
	roch_lid.reparent(roch_plinth)
	inventory["saint_roch"]={"accession":"21.398","height_m":1.054,"closed_solid_prototype":true,"muse_sheet_used":false,"placement_accepted":false,"case_metres_accepted":false,"fine_fidelity_accepted":false}
	#6383 30.2/63.9s: three gabled panels in a wall-hung case, left of the north door.
	# ponytail: case metres and offsets are by eye; the front/rear art stays official photography.
	var triptych_at:=Vector3(-4.50,0,18.918)
	var triptych_case:=solid(triptych_at+Vector3(0,1.025,.24),Vector3(.92,.11,.48),white,true)
	triptych_case.set_meta("triptych_wall_case",true)
	_renaissance_triptych_case=triptych_case
	var triptych:=Triptych.build()
	add_child(triptych)
	triptych.position=triptych_at+Vector3(0,1.08,0)
	triptych.reparent(triptych_case)
	for spec in [[Vector3(-.46,1.50,.24),Vector3(.012,.84,.48)],[Vector3(.46,1.50,.24),Vector3(.012,.84,.48)],[Vector3(0,1.50,.48),Vector3(.92,.84,.012)],[Vector3(0,1.50,0),Vector3(.92,.84,.012)],[Vector3(0,1.92,.24),Vector3(.92,.012,.48)]]:
		var pane:=solid(triptych_at+spec[0],spec[1],roch_glass)
		pane.reparent(triptych_case)
	var triptych_label:=solid(triptych_at+Vector3(0,1.03,.485),Vector3(.20,.05,.005),look(Color("dedbd4")))
	triptych_label.set_meta("artwork_label_proxy",true)
	triptych_label.reparent(triptych_case)
	inventory["renaissance_triptych"]={"accession":"2021.131","panels":3,"source_rear_observed":true,"placement_accepted":false,"case_metres_accepted":false,"fine_frame_fidelity_accepted":false}
	#6383 24.6/62.0s: the shallow linden-wood Pietà hangs north of the shuttered window.
	# ponytail: white shelf/hood offsets are by eye; unobserved sculpture sides stay provisional.
	var pieta_at:=Vector3(-5.29,0,20.55)
	var pieta_case:=solid(pieta_at+Vector3(0,1.025,0),Vector3(.38,.11,.65),white,true)
	pieta_case.set_meta("pieta_wall_case",true)
	_renaissance_pieta_case=pieta_case
	var pieta:=Pieta.build()
	add_child(pieta)
	pieta.position=pieta_at+Vector3(0,1.08,0)
	pieta.rotation.y=PI/2
	pieta.reparent(pieta_case)
	for spec in [[Vector3(-.19,1.43,0),Vector3(.012,.70,.65)],[Vector3(.19,1.43,0),Vector3(.012,.70,.65)],[Vector3(0,1.43,-.325),Vector3(.38,.70,.012)],[Vector3(0,1.43,.325),Vector3(.38,.70,.012)],[Vector3(0,1.78,0),Vector3(.38,.012,.65)]]:
		var pane:=solid(pieta_at+spec[0],spec[1],roch_glass)
		pane.reparent(pieta_case)
	var pieta_label:=solid(pieta_at+Vector3(.195,1.025,0),Vector3(.005,.06,.30),look(Color("dedbd4")))
	pieta_label.rotation.z=-.3
	pieta_label.set_meta("artwork_label_proxy",true)
	pieta_label.reparent(pieta_case)
	inventory["renaissance_pieta"]={"accession":"59.128","closed_parts":39,"source_rear_observed":false,"placement_accepted":false,"case_metres_accepted":false,"fine_fidelity_accepted":false}
	build_renaissance_east_cases()
	# Original6383 24.6/30.2s: dark narrow top rails and corner seams, not a floor plinth.
	for spec in [[triptych_case,triptych_at+Vector3(0,0,.24),Vector2(.92,.48),1.92],[pieta_case,pieta_at,Vector2(.38,.65),1.78]]:
		var centre:Vector3=spec[1]
		var size:Vector2=spec[2]
		var top:float=spec[3]
		for side in [-1,1]:
			for rail in [[Vector3(side*size.x/2,top,0),Vector3(.008,.008,size.y)],[Vector3(0,top,side*size.y/2),Vector3(size.x,.008,.008)]]:
				var edge:=solid(centre+rail[0],rail[1],look(Color("3c3a35")))
				edge.set_meta("wall_case_top_rail",true)
				edge.reparent(spec[0])

	#6383 60.60/68.50s: the south platform is below bench height; placement and metres remain provisional.
	var platform:=solid(Vector3(-3.10,.08,24.415),Vector3(4.30,.16,.95),white,true)
	platform.set_meta("renaissance_textile_platform",true)
	build_renaissance_wall_art()
	for origin in [Vector3(-2.5,3.43,22),Vector3(5.55,4.18,22)]:
		var rail:=solid(origin,Vector3(8.6 if origin.y>4 else 4.7,.025,.04),white)
		ceiling_details.append(rail)
		for offset in [-1.6,0,1.6]:
			var fixture:=solid(origin+Vector3(offset,-.09,0),Vector3(.09,.16,.09),white)
			fixture.reparent(rail)
	inventory["sculpture_room_shells"]=2
	inventory["sculpture_room_objects_complete"]=false
	# Reciprocal IMG_6382 78.25/88.75s: broad low case west of the tall stair-side case.
	#6387 13.0/44.0s,6383 66.5s: stair door, tall case and tracery doorway on one axis.
	# ponytail: source-relative arrangement only; replace metric offsets after wide-view fitting.
	var grey:=look(Color("666763"))
	var glass:=look(Color(.82,.90,.91,.10),"",true)
	for case_spec in [[Vector3(5.45,0,22.7),Vector2(2.0,1.15),.88,.30],
		[Vector3(8.05,0,22.515),Vector2(1.05,.90),.88,1.05]]:
		var at:Vector3=case_spec[0]
		var footprint:Vector2=case_spec[1]
		var base_height:float=case_spec[2]
		var glass_height:float=case_spec[3]
		var base:=solid(at+Vector3(0,base_height/2,0),Vector3(footprint.x,base_height,footprint.y),grey,true)
		var tray:=solid(at+Vector3(0,base_height+.025,0),Vector3(footprint.x+.06,.05,footprint.y+.06),white)
		tray.reparent(base)
		var rim:=solid(at+Vector3(0,base_height-.025,0),Vector3(footprint.x+.08,.025,footprint.y+.08),grey)
		rim.reparent(base)
		for z in [-footprint.y/2,footprint.y/2]:
			var pane:=solid(at+Vector3(0,base_height+.05+glass_height/2,z),Vector3(footprint.x,glass_height,.012),glass)
			pane.reparent(base)
		for x in [-footprint.x/2,footprint.x/2]:
			var pane:=solid(at+Vector3(x,base_height+.05+glass_height/2,0),Vector3(.012,glass_height,footprint.y),glass)
			pane.reparent(base)
		var lid:=solid(at+Vector3(0,base_height+.05+glass_height,0),Vector3(footprint.x,.012,footprint.y),glass)
		lid.reparent(base)
		# ponytail: by-eye deck positions; catalogue heights fixed, mounts/spacing await source fitting.
		if footprint.x<1.5:
			for spec in [[Vector3(-.32,1.025,.13),Vector3(.28,.19,.30)],
				[Vector3(0,.958,0),Vector3(.21,.055,.21)]]:
				var riser:=solid(at+spec[0],spec[1],white)
				riser.reparent(base)
			var decals:={"roundel":load("res://assets/decal-queens-roundel.png"),"boat":load("res://assets/decal-queens-boat.png")}
			for spec in [[VirginChild.build(),Vector3(-.32,1.12,.13),-PI/2],
				[CasePair.build("queens",decals),Vector3(0,.985,0),PI],
				[CaseMetal.build("monstrance"),Vector3(.32,.93,.22),PI],
				[CaseMetal.build("beaker"),Vector3(.37,.93,-.23),PI],
				[CaseMetal.build("pyx"),Vector3(.29,.93,-.02),PI],
				[CasePair.christ_on_wedge(),Vector3(.12,.93,-.26),PI],
				[CaseMetal.pax_on_stand(),Vector3(-.29,.93,-.24),PI]]:
				var object:Node3D=spec[0]
				add_child(object)
				object.position=at+spec[1]
				object.rotation.y=spec[2]
				object.set_meta("medieval_case_object",true)
				object.reparent(base)
		else:
			for spec in [["L1",.50,Vector2(.34,.31),Vector2(.07,.09)],
				["L2",-.50,Vector2(.55,.45),Vector2(.27,.16)]]:
				var mount:=solid(at+Vector3(spec[1],.932,0),Vector3(spec[2].x,.004,spec[2].y),look(Color("eee8d7")))
				mount.set_meta("unidentified_paper_slot",spec[0])
				mount.reparent(base)
				# Original tiny filmed image, on a thin flat paper; no generated subject or accession.
				var art:=solid(at+Vector3(spec[1],.935,0),Vector3(spec[3].x,.001,spec[3].y),look(Color.WHITE,"res://assets/medieval-paper-"+spec[0]+".png",true))
				art.reparent(base)
	inventory["medieval_display_cases"]=2
	inventory["medieval_case_object_prototypes"]={"tall":7,"low":2,"probable_accessions":["1992.051","30.011","2014.110"],"unidentified":["L1","L2"],"placement_accepted":false,"fine_fidelity_accepted":false}
	inventory["medieval_case_contents_complete"]=false

func build_lion_modern_rooms() -> void:
	#6387 pan door order (medieval west, modern/lion north, white sculpture east) and
	# painting/window wall groups; authored metres unaccepted.
	var ivory:=look(Color("eeeae2"),"res://presentation/wall-plaster.png")
	var metal:=look(Color("535657"))
	# The stair, its well, guard, stone floor and ceiling are built in landing_additions.gd (#238).
	#6387:2.25/42.25s: lion on the modern-door (north) wall, to the right facing that door.
	# 41.0/3.0s: label and a strip of white wall before the corner, so .35m left of the turned centre.
	# Original front assembled on the closed low polygon catalogue slab; Muse damage trial unaccepted.
	# Wall-hung work belongs to its wall's visual, as the windows do, so a cut-away wall takes it along.
	var hung:={}
	for wall in casings:
		var tag:String=wall.get_meta("room_wall","")
		if tag=="lion stair landing:north" and wall.position.x<12.7:continue
		if tag=="modern painting gallery:north" and wall.position.x>15.1:continue
		hung[tag]=wall.get_child(1)
	var lion_wall:Node3D=hung["lion stair landing:north"]
	for node in get_children():
		if node.get_meta("catalogue_asset","")=="lion-panel":node.reparent(lion_wall)
	solid(Vector3(14.6,1.7005,28.158),Vector3(2.446,1.201,.035),look(Color("e9e8e2")),true).reparent(lion_wall)
	for side in [-1,1]:
		solid(Vector3(14.6,1.7005+side*.5605,28.295),Vector3(2.446,.08,.045),look(Color("eeeae2"))).reparent(lion_wall)
		solid(Vector3(14.6+side*1.183,1.7005,28.295),Vector3(.08,1.201,.045),look(Color("eeeae2"))).reparent(lion_wall)
	# Source grille above the lion, separate from its frame.
	var lion_vent:=solid(Vector3(14.6,3.32,28.19),Vector3(1.65,.18,.03),look(Color("424341")))
	for i in 7:
		var slat:=solid(Vector3(14.6,3.24+i*.026,28.21),Vector3(1.64,.008,.02),look(Color("74756f")))
		slat.reparent(lion_vent)
	lion_vent.reparent(lion_wall)
	# Three distinct double-panel doors: medieval already built; modern and white-gallery leaves.
	# Modern leaves stand open into the modern room (north), white-gallery leaves into that gallery (east).
	for spec in [[Vector3(11.85,0,28.1),true,.85,-.45],[Vector3(16.15,0,30.5),false,1.0,.45]]:
		var root_at:Vector3=spec[0]
		var horizontal:bool=spec[1]
		for side in [-1,1]:
			var at:=root_at+Vector3(spec[3],1.35,side*spec[2]) if not horizontal else root_at+Vector3(side*spec[2],1.35,spec[3])
			var leaf:=solid(at,Vector3(.90,2.70,.065),ivory,true)
			if horizontal:leaf.rotation.y=PI/2
			for face in [-1,1]:
				for index in 2:
					var y:float=[1.78,.45][index]-1.35
					var h:float=[1.58,.56][index]
					panel(leaf,[Vector3(-.34,y-h/2,face*.035),Vector3(.34,y-h/2,face*.035),Vector3(.34,y+h/2,face*.035),Vector3(-.34,y+h/2,face*.035)],
						[Vector2(0,1),Vector2(1,1),Vector2(1,0),Vector2(0,0)],look(Color.WHITE,"res://assets/european-two-panel-door-%d.png"%index))
				var bar:=solid(Vector3.ZERO,Vector3(.66,.045,.04),metal)
				bar.reparent(leaf,false)
				bar.position=Vector3(0,-.37,face*.072)
	#6387 58.0..68.0s: two windows on the wall right of the entry, the case between them.
	# Windows/blinds/radiator bases belong to that east wall so cutaway follows it.
	var east:Node3D=hung["modern painting gallery:east"]
	for z in [26.75,23.45]:
		var window:=solid(Vector3(16.624,1.98,z),Vector3(.018,1.78,1.20),look(Color("f3f4ef"),"",true))
		window.reparent(east)
		window.set_meta("modern_window",true)
		for side in [-1,1]:
			var stile:=solid(Vector3(16.60,1.98,z+side*.63),Vector3(.075,1.94,.075),ivory)
			stile.reparent(window)
			var rail:=solid(Vector3(16.60,1.98+side*.94,z),Vector3(.075,.075,1.34),ivory)
			rail.reparent(window)
		for j in 25:
			var slat:=solid(Vector3(16.587,1.19+j*.066,z),Vector3(.022,.025,1.19),look(Color("dddcd4")))
			slat.reparent(window)
		var radiator:=solid(Vector3(16.58,.45,z),Vector3(.18,.52,1.20),ivory,true)
		radiator.reparent(window)
		for j in 12:
			var vent:=solid(Vector3(16.48,.23+j*.013,z),Vector3(.025,.006,1.12),metal)
			vent.reparent(radiator)
	# Central bench, long side along the large-painting wall (50.5/51.0s).
	var bench:=solid(Vector3(13.7,.40,25.35),Vector3(.80,.13,2.20),look(Color("343130")),true)
	for x in [13.38,14.02]:
		for z in [24.48,26.22]:
			var leg:=solid(Vector3(x,.17,z),Vector3(.06,.34,.06),look(Color("343130")))
			leg.reparent(bench)
	# RISD originals remain separate from generated frame texture. Metres supplied by catalogue.
	var frame:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/braque-frame-geometry.json"))
	var braque:=Painting.new()
	add_child(braque)
	braque.build_framed(load("res://assets/braque-frame.png"),load("res://assets/painting-48.248.jpg"),Vector2(.721,.464),frame.margins_px)
	#6387 83.0..83.5s: on the entry wall, beyond the door; Villon beyond it toward the windows.
	braque.position=Vector3(14.2,1.65,28.02)
	braque.rotation.y=PI
	braque.set_meta("catalogue_accession","48.248")
	#57.037 retains its original museum image with its own source-led Muse frame.
	var pumpkin:=Painting.new()
	add_child(pumpkin)
	var pumpkin_frame:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/matisse-frame-geometry.json"))
	pumpkin.build_framed(load("res://assets/matisse-frame.png"),load("res://assets/painting-57.037.jpg"),Vector2(.645,.800),pumpkin_frame.margins_px)
	pumpkin.position=Vector3(12.0,1.65,22.38)
	pumpkin.set_meta("catalogue_accession","57.037")
	var landscape:=Painting.new()
	add_child(landscape)
	var landscape_frame:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/cezanne-frame-geometry.json"))
	landscape.build_framed(load("res://assets/cezanne-frame.png"),load("res://assets/painting-43.255.jpg"),Vector2(.737,.610),landscape_frame.margins_px)
	landscape.position=Vector3(13.65,1.65,22.38)
	landscape.set_meta("catalogue_accession","43.255")
	var villon:=Painting.new()
	add_child(villon)
	var villon_frame:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/villon-frame-geometry.json"))
	# White box: one unbroken Muse face carrying the backing and dark oval rim; no opening is cut, so no reveals.
	var villon_box:Texture2D=load("res://assets/villon-frame.png")
	villon.build_shaped(villon_box,villon_box.get_size()*.548/(villon_box.get_height()-villon_frame.margins_px[1]-villon_frame.margins_px[3]),[[0,0],[1,0],[1,1],[0,1]],Color.WHITE)
	villon.position=Vector3(15.55,1.65,28.02)
	villon.rotation.y=PI
	villon.set_meta("catalogue_accession","70.058")
	# Official pixels only inside the oval, standing 4mm proud of the backing within that rim.
	var villon_art:=Painting.new()
	villon.add_child(villon_art)
	var oval:Array=[]
	for i in 48:oval.append([.5+.5*cos(i*TAU/48),.5+.5*sin(i*TAU/48)])
	villon_art.build_shaped(load("res://assets/painting-70.058.png"),Vector2(.460,.548),oval,Color("5a5a5a"))
	villon_art.position.z=.004
	#6387 46.0..47.5/82.0s: large original on the wall running off the entry's left jamb.
	var mountaineers:=Painting.new()
	add_child(mountaineers)
	var large_frame:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/fauconnier-frame-geometry.json"))
	mountaineers.build_framed(load("res://assets/fauconnier-frame.png"),load("res://assets/painting-1995.043.jpg"),Vector2(3.054,2.396),large_frame.margins_px)
	mountaineers.position=Vector3(10.78,1.65,24.75)
	mountaineers.rotation.y=PI/2
	mountaineers.set_meta("catalogue_accession","1995.043")
	# Braque and Villon back onto the lion wall; its taller landing face is the one the walking camera cuts.
	for spec in [[braque,"lion stair landing:north"],[villon,"lion stair landing:north"],[pumpkin,"modern painting gallery:north"],[landscape,"modern painting gallery:north"],[mountaineers,"modern painting gallery:west"]]:
		spec[0].reparent(hung[spec[1]])
	# Source track grid, repeated low polygon fixtures; bake supplies its light.
	for x in [12.2,13.7,15.2]:
		var track:=solid(Vector3(x,3.34,25.2),Vector3(.025,.025,5.0),ivory)
		ceiling_details.append(track)
		for z in [27.05,25.8,24.6,23.35]:
			var fixture:=solid(Vector3(x,3.24,z),Vector3(.10,.16,.10),ivory)
			fixture.reparent(track)
	inventory["lion_landing"]={"doors":3,"floor_void":true,"metric_accepted":false,"lion_relief_complete":false,"lion_panel_front_installed":true,"lion_generated_damage_accepted":false}
	#6387 63.5..65.5s: floor-standing case against the pier between windows, facing into the room.
	# ponytail: by-eye offset on the pier, nearer the second window; label side toward the first.
	var seated:StaticBody3D=SeatedWoman.build(look(Color.WHITE,"res://presentation/landing-plaster.png"),ivory,look(Color.WHITE,"res://assets/seated-woman-bronze.webp"))
	seated.position=Vector3(16.64,0,24.85)
	seated.rotation.y=-PI/2
	add_child(seated)
	casings.append(seated)
	inventory["modern_gallery"]={"windows":2,"window_wall":"east","entry_wall":"south","large_painting_wall":"west","catalogue_paintings":["48.248","57.037","70.058","43.255","1995.043"],"dedicated_muse_frames":5,"seated_woman_accession":"67.089","seated_woman_rear_observed":false,"seated_woman_case_metres_accepted":false,"bench":true,"deeper_opening":true,"all_objects_complete":false,"placement_accepted":false,"fine_frame_fidelity_accepted":false}

func build_medieval_stair_door() -> void:
	# Native6382 18.25/20.75/24.75s: leaves open into landing, push bars, closers and black hinges.
	# ponytail: right-angle swing and hardware dimensions provisional; photographed doorway order retained.
	var ivory:=look(Color("eee9de"))
	var black:=look(Color("252526"))
	for edge in [21.665,23.365]:
		var leaf:=solid(Vector3(11.0,1.35,edge),Vector3(.90,2.70,.065),ivory,true)
		for side in [-1,1]:
			for index in 2:
				var y:float=[1.78,.45][index]
				var height:float=[1.58,.56][index]
				var face:float=side*.035
				panel(leaf,[Vector3(-.34,y-height/2-1.35,face),Vector3(.34,y-height/2-1.35,face),Vector3(.34,y+height/2-1.35,face),Vector3(-.34,y+height/2-1.35,face)],
					[Vector2(0,1),Vector2(1,1),Vector2(1,0),Vector2(0,0)],look(Color.WHITE,"res://assets/european-two-panel-door-%d.png"%index))
				for sign in [-1,1]:
					var stile:=solid(Vector3(11.0+sign*.35,y,edge+side*.045),Vector3(.035,height+.035,.018),ivory)
					stile.reparent(leaf)
					var rail:=solid(Vector3(11.0,y+sign*height/2,edge+side*.045),Vector3(.735,.035,.018),ivory)
					rail.reparent(leaf)
			var push:=solid(Vector3(11.0,.98,edge+side*.072),Vector3(.66,.045,.04),black)
			push.reparent(leaf)
			for x in [10.67,11.33]:
				var fitting:=solid(Vector3(x,.98,edge+side*.053),Vector3(.06,.075,.065),black)
				fitting.reparent(leaf)
			var closer:=solid(Vector3(10.80,2.51,edge+side*.06),Vector3(.23,.09,.05),black)
			closer.reparent(leaf)
		for y in [.16,1.32,2.50]:
			var hinge:=solid(Vector3(10.58,y,edge),Vector3(.065,.11,.11),black)
			hinge.reparent(leaf)
		for spec in [[Vector3(10.65,2.65,edge),Vector3(.20,.035,.035)],[Vector3(10.76,2.57,edge),Vector3(.035,.17,.035)]]:
			var arm:=solid(spec[0],spec[1],black)
			arm.reparent(leaf)
	# Exact sign lettering is not legible in the video; keep the documented green EXIT only.
	var sign:=solid(Vector3(10.45,3.17,22.515),Vector3(.05,.17,.40),look(Color("273a2d")))
	var lettering:=Label3D.new()
	lettering.text="EXIT"
	lettering.font_size=48
	lettering.pixel_size=.0024
	lettering.modulate=Color("70f89e")
	lettering.no_depth_test=false
	lettering.position=Vector3(10.416,3.17,22.515)
	lettering.rotation.y=-PI/2
	add_child(lettering)
	lettering.reparent(sign)
	inventory["medieval_stair_door"]={"leaves":2,"push_bars":true,"hardware_source":"IMG_6382 18.25..24.75s","metric_accepted":false,"source_paint_texture":false,"material":"Existing Muse ivory two-panel crops; panel proportions provisional"}

func build_iron_grille() -> void:
	# Reciprocal6382 wides: north wall right of portal, low plinth, brace to wall.
	var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/medieval-grille-geometry.json"))
	assert(data.columns==7 and data.metric_accepted==false)
	var st:=SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var coils:=0
	for row in int(data.rows):
		for column in int(data.columns):
			var hand:float=1.0 if column%2==0 else -1.0
			var center:=Vector3((column+.5)*data.cell_pitch_m-data.size_m[0]/2,(row+.5)*data.cell_pitch_m,0)
			for triangle in data.triangles:
				var indices:Array=triangle if hand>0 else [triangle[2],triangle[1],triangle[0]]
				var points:Array=[]
				for index in indices:
					var p:=vec(data.vertices[int(index)])
					points.append(center+Vector3(p.x*hand,p.y,p.z))
				st.set_normal((points[1]-points[0]).cross(points[2]-points[0]).normalized())
				for i in 3:
					var uv:Array=data.uv[int(indices[i])]
					st.set_uv(Vector2(uv[0],uv[1]))
					st.add_vertex(points[i])
			coils+=1
	var metal:=look(Color.WHITE,"res://assets/medieval-grille-metal.png")
	var base:=solid(Vector3(8.45,.06,19.19),Vector3(1.18,.12,.50),look(Color("f0eeea")),true)
	var grille:=MeshInstance3D.new()
	grille.mesh=st.commit()
	if not OS.has_feature("web"):
		var ids:Dictionary={}
		var edges:Dictionary={}
		var faces:=grille.mesh.get_faces()
		var volume:=0.0
		for i in range(0,faces.size(),3):
			volume+=faces[i].dot(faces[i+1].cross(faces[i+2]))/6
			var triangle:Array=[]
			for j in 3:
				var key:=Vector3i((faces[i+j]*1000000).round())
				if not ids.has(key):ids[key]=ids.size()
				triangle.append(ids[key])
			for j in 3:
				var a:int=triangle[j]
				var b:int=triangle[(j+1)%3]
				var edge:=Vector2i(min(a,b),max(a,b))
				if not edges.has(edge):edges[edge]=Vector2i.ZERO
				edges[edge]+=Vector2i(1,1 if a<b else -1)
		for pair in edges.values():assert(pair==Vector2i(2,0),"Iron coil edge must pair with opposite winding")
		assert(volume>0 and abs(volume-coils*float(data.coil_signed_volume_m3))<.00001)
		var proof={"vertices":ids.size(),"triangles":faces.size()/3,"closed_edges":edges.size(),"signed_volume_m3":volume,"coils":coils,"columns":data.columns,"rows_provisional":data.rows,"accepted":false}
		var file:=FileAccess.open("res://evidence/iron-grille-native.json",FileAccess.WRITE)
		if file!=null:
			file.store_string(JSON.stringify(proof,"  ")+"\n")
	grille.material_override=metal
	grille.position=Vector3(8.45,.12,19.19)
	add_child(grille)
	grille.reparent(base)
	# Individual holes are smaller than the visitor; a thin collision envelope blocks passage.
	var collider:=CollisionShape3D.new()
	var envelope:=BoxShape3D.new()
	envelope.size=Vector3(data.size_m[0],data.size_m[1],.12)
	collider.shape=envelope
	collider.position=Vector3(0,.06+data.size_m[1]/2,0)
	base.add_child(collider)
	for row in range(int(data.rows)+1):
		var bar:=solid(Vector3(8.45,.12+row*data.cell_pitch_m,19.19),Vector3(data.size_m[0]+.024,.012,.024),metal)
		bar.reparent(base)
	for x in [7.95,8.95]:
		var post:=solid(Vector3(x,.12+data.size_m[1]/2,19.19),Vector3(.018,data.size_m[1]+.06,.024),metal)
		post.reparent(base)
		var a:=Vector3(x,.12+data.size_m[1],19.19)
		var b:=Vector3(x,.12+data.size_m[1]-.10,18.92)
		var brace:=solid((a+b)/2,Vector3(.014,a.distance_to(b),.014),metal)
		brace.rotation=Quaternion(Vector3.UP,(b-a).normalized()).get_euler()
		brace.reparent(base)
	assert(coils==int(data.columns)*int(data.rows))
	inventory["medieval_iron_grille"]={"coils":coils,"columns":data.columns,"rows":data.rows,"coil_triangles":coils*data.triangles.size(),"closed_coil_edges":data.coil_closed_edges,"row_count_provisional":true,"accepted":false}
	print("IRON_GRILLE_OK "+JSON.stringify(inventory["medieval_iron_grille"]))

func build_gabled_frame() -> void:
	var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/magdalene-frame.json"))
	var points:=PackedVector2Array()
	for p in data.points_m:points.append(Vector2(p[0],p[1]))
	var front:Array=[]
	var front_area:=0.0
	for polygon in data.polygons:
		var band:=PackedVector2Array()
		for i in polygon:band.append(points[int(i)])
		var indices:=Geometry2D.triangulate_polygon(band)
		assert(indices.size()==(band.size()-2)*3,"Gabled band triangulation failed")
		for t in range(0,indices.size(),3):
			var triangle=[int(polygon[indices[t]]),int(polygon[indices[t+1]]),int(polygon[indices[t+2]])]
			front.append(triangle)
			front_area+=abs((points[triangle[1]]-points[triangle[0]]).cross(points[triangle[2]]-points[triangle[0]]))/2
	var pixel_area:float=data.source_band_area_px2*.225/849*.495/1912
	assert(abs(front_area-pixel_area)<.000001,"Frame bands overlap or leave gaps")
	var count:=points.size()
	var vertices:=PackedVector3Array()
	for depth in [float(data.depth_m),0.0]:
		for p in points:vertices.append(Vector3(p.x,p.y,depth))
	var rest:Array=[]
	for t in front:rest.append([t[2]+count,t[1]+count,t[0]+count])
	for loop in data.loops:
		for i in loop.size():
			var a:int=int(loop[i])
			var b:int=int(loop[(i+1)%loop.size()])
			rest.append([a,b,b+count])
			rest.append([a,b+count,a+count])
	var edges:Dictionary={}
	var signed_volume:=0.0
	for t in front+rest:
		signed_volume+=vertices[t[0]].dot(vertices[t[1]].cross(vertices[t[2]]))/6
		for i in 3:
			var a:int=t[i]
			var b:int=t[(i+1)%3]
			var key:=Vector2i(min(a,b),max(a,b))
			if not edges.has(key):edges[key]=Vector2i.ZERO
			edges[key]+=Vector2i(1,1 if a<b else -1)
	for pair in edges.values():assert(pair==Vector2i(2,0),"Gabled frame is not a closed oriented mesh")
	assert(signed_volume>0 and abs(signed_volume-front_area*float(data.depth_m))<.000001)
	var frame:=Painting.new()
	frame.name="MagdaleneGabledFrame"
	frame.position=Vector3(1.18,1.55,19.05)
	add_child(frame)
	for group in [front,rest]:
		frame._mesh(func(st:SurfaceTool) -> void:
			for t in group:
				st.set_normal((vertices[t[1]]-vertices[t[0]]).cross(vertices[t[2]]-vertices[t[0]]).normalized())
				for i in t:
					var p:Array=data.points_px[i%count]
					st.set_uv(Vector2(p[0]/data.source_size_px[0],p[1]/data.source_size_px[1]))
					st.add_vertex(vertices[i]),Painting.mat(load("res://assets/magdalene-frame.png")) if group==front else look(Color("7c6038")))
	var support:=solid(Vector3(1.18,1.55,19.015),Vector3(data.outer_size_m[0]+.10,data.outer_size_m[1]+.10,.025),look(Color("959691")))
	support.name="MagdaleneGreySupport"
	var art:=Painting.new()
	frame.add_child(art)
	art.position.z=.004
	art.scale.z=.021/.05
	art.build_shaped(load("res://assets/painting-21.250.png"),Vector2(.225,.495),data.painting_outline,Color("674d29"))
	var proof={"vertices":vertices.size(),"triangles":front.size()+rest.size(),"closed_edges":edges.size(),"front_area_m2":front_area,"signed_volume_m3":signed_volume,"depth_m":data.depth_m,"accepted":false,"source_outline_vertices":data.outline_vertices}
	inventory["magdalene_frame"]=proof
	if not OS.has_feature("web"):
		var file:=FileAccess.open("res://evidence/magdalene-frame-native.json",FileAccess.WRITE)
		if file!=null:
			file.store_string(JSON.stringify(proof,"  ")+"\n")
	print("GABLED_FRAME_OK "+JSON.stringify(proof))

#6383 41.2/49.8 and55.6/56.0s: two wall-hung cases on opposite sides of the east tracery door.
# ponytail: case offsets, height, tilt and mount sizes are by eye; all placement/metric flags remain false.
func build_renaissance_east_cases() -> void:
	var white:=look(Color("f0eeea"))
	var glass:=StandardMaterial3D.new()
	glass.albedo_color=Color(.90,.95,.96,.055)
	glass.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.cull_mode=BaseMaterial3D.CULL_DISABLED
	glass.roughness=.18
	var images:=RenaissanceA.textures("res://assets/renaissance-case-a")
	images["cleric_frame"]=load("res://assets/cleric-45042-frame-fitted.png")
	for row in [["A",20.40],["B",24.015]]:
		var anchor:=Vector3(.477,0,row[1])
		var body:=solid(anchor+Vector3(-.28,1.025,0),Vector3(.56,.11,1.20),white,true)
		body.set_meta("renaissance_wall_case",row[0])
		_renaissance_east_cases.append(body)
		var display:=Node3D.new()
		add_child(display)
		display.position=anchor
		display.rotation.y=-PI/2
		display.reparent(body)
		for spec in [[Vector3(0,1.53,.006),Vector3(1.20,.90,.012)],[Vector3(0,1.98,.28),Vector3(1.20,.012,.56)],[Vector3(0,1.53,.56),Vector3(1.20,.90,.012)],[Vector3(-.60,1.53,.28),Vector3(.012,.90,.56)],[Vector3(.60,1.53,.28),Vector3(.012,.90,.56)]]:
			var pane:=solid(Vector3.ZERO,spec[1],glass)
			pane.reparent(display,false)
			pane.position=spec[0]
		var backing:=solid(Vector3.ZERO,Vector3(1.19,.90,.012),white)
		backing.reparent(display,false)
		backing.position=Vector3(0,1.53,.018)
		for side in [-1,1]:
			for rail in [[Vector3(side*.60,1.98,.28),Vector3(.008,.008,.56)],[Vector3(0,1.98,.28+side*.28),Vector3(1.20,.008,.008)]]:
				var edge:=solid(Vector3.ZERO,rail[1],look(Color("3c3a35")))
				edge.reparent(display,false)
				edge.position=rail[0]
				edge.set_meta("east_case_top_rail",true)
		if row[0]=="A":
			for spec in [["cleric",Vector3(-.26,1.58,.027)],["woman",Vector3(.16,1.58,.027)],["diptych",Vector3(-.40,1.08,.32)],["bookcover",Vector3(-.16,1.08,.35)],["emblem",Vector3(.12,1.08,.30)],["albarello",Vector3(.45,1.08,.30)]]:
				var art:=RenaissanceA.on_display(spec[0],images,Painting.mat)
				display.add_child(art)
				art.position=spec[1]
				art.set_meta("renaissance_case_object",spec[0])
				if spec[0]=="cleric":art.set_meta("frame_texture","source-guided Muse study, source-band fit; provisional")
				if spec[0]=="bookcover":art.rotation.y=.28
		else:
			for spec in [["plate_46391",Vector3(-.27,1.55,.027),0.0],["plate_57302",Vector3(.22,1.55,.027),0.0],["roundel_51105",Vector3(-.38,1.14,.34),-.95],["glass_201729",Vector3(0,1.20,.29),-.15],["plaque_34024",Vector3(.40,1.15,.34),-.72]]:
				var art:=RenaissanceB.build(spec[0],"res://assets/renaissance-case-b/textures/")
				display.add_child(art)
				art.position=spec[1]
				art.rotation.x=spec[2]
				art.set_meta("renaissance_case_object",spec[0])
				if spec[0] in ["roundel_51105","plaque_34024"]:
					var mount:=solid(Vector3.ZERO,Vector3(.12,.018,.10),white)
					mount.reparent(display,false)
					mount.position=Vector3(spec[1].x,1.09,.34)
					mount.rotation.x=-.28
		for spec in [[-.40,.28],[-.16,.18],[.12,.24],[.45,.16]] if row[0]=="A" else [[-.38,.23],[0.0,.25],[.40,.22]]:
			var label:=solid(Vector3.ZERO,Vector3(spec[1],.06,.005),look(Color("dedbd4")))
			label.reparent(display,false)
			label.position=Vector3(spec[0],1.025,.565)
			label.rotation.x=.25
			label.set_meta("artwork_label_proxy",true)
	inventory["renaissance_case_objects"]={"case_a":6,"case_b":5,"probable":["34.024"],"placement_accepted":false,"case_metres_accepted":false,"fine_fidelity_accepted":false}

#6383 reciprocal wides: velvet east and tapestry west on south wall, framed Madonna south of west window.
# ponytail: catalogue artwork sizes; all room offsets, hood depth and blank label stands remain provisional.
func build_renaissance_wall_art() -> void:
	var glass:=StandardMaterial3D.new()
	glass.albedo_color=Color(.90,.95,.96,.045)
	glass.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.cull_mode=BaseMaterial3D.CULL_DISABLED
	glass.roughness=.18
	for row in [["velvet_23307x",Vector3(-1.775,1.31,24.867),PI,"south"],["woodcutters_29280",Vector3(-3.225,1.35,24.887),PI,"south"],["madonna_58196",Vector3(-5.478,1.22,24.10),PI/2,"west"]]:
		var art:=RenaissanceWall.build(row[0])
		add_child(art)
		art.position=row[1]
		art.rotation.y=row[2]
		art.set_meta("renaissance_wall_object",row[0])
		art.set_meta("wall_side",row[3])
		_renaissance_wall_art.append(art)
		if row[0]=="velvet_23307x":
			# The hood extends beneath the board in the original close shot; five panes, no invented opaque back.
			for pane in [[Vector3(.003,-.077,.066),Vector3(1.04,1.60,.006)],[Vector3(-.517,-.077,.026),Vector3(.006,1.60,.08)],[Vector3(.523,-.077,.026),Vector3(.006,1.60,.08)],[Vector3(.003,.723,.026),Vector3(1.04,.006,.08)],[Vector3(.003,-.877,.026),Vector3(1.04,.006,.08)]]:
				var mesh:=solid(Vector3.ZERO,pane[1],glass)
				mesh.reparent(art,false)
				mesh.position=pane[0]
				mesh.set_meta("velvet_hood_pane",true)
		if row[3]=="south":
			var stand:=solid(Vector3.ZERO,Vector3(.21,.15,.17),look(Color("eeeae3")))
			stand.position=Vector3(row[1].x,.235,24.03)
			stand.set_meta("artwork_label_proxy",true)
			stand.set_meta("renaissance_textile_label",true)
			var label:=solid(Vector3.ZERO,Vector3(.13,.006,.10),look(Color("dedbd4")))
			label.reparent(stand,false)
			label.position=Vector3(0,.079,0)
			label.set_meta("artwork_label_proxy",true)
		else:
			var label:=solid(Vector3.ZERO,Vector3(.11,.07,.006),look(Color("dedbd4")))
			label.reparent(art,false)
			label.position=Vector3(.60,0,.016)
			label.set_meta("artwork_label_proxy",true)
	inventory["renaissance_verified_paintings"]=2
	inventory["renaissance_wall_assets"]={"accessions":["23.307X","29.280","58.196"],"source_rear_observed":["23.307X"],"frame_texture":"source-video strips; Muse trial rejected for broad gold band","placement_accepted":false,"metres_accepted":false,"fine_fidelity_accepted":false}
