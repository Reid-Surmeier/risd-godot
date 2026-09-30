## #182/#183 throwaway authored rooms, following the Main Hall asset workflow.
## Captured spacing guides placement; every room extent remains provisional.
extends "doorway_walk.gd"

const Painting := preload("res://modules/shell/prototype/gallery_walk4/painting_asset.gd")
var inventory := {"point_clouds": 0, "bookcase": 1, "mirrors": 2, "approved_frames": 1, "muse_upholstery": 1}
var views := [Vector3(.45, .25, -2.6), Vector3(.45, .25, 2.8)]

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
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.remodelInventory=" + JSON.stringify(inventory))
	assert(not FileAccess.file_exists("res://points.bin"))
	print("REMODEL_READY " + JSON.stringify(inventory))

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			reset(views[0])
		elif event.keycode == KEY_2:
			reset(views[1])

func look(color: Color, texture_path := "", unlit := false) -> StandardMaterial3D:
	var m := material(color)
	m.roughness = .95
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

func panel(parent: Node3D, corners: Array, uvs: Array, m: Material) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	Painting.quad(st, corners, uvs)
	var mesh := MeshInstance3D.new()
	mesh.mesh = st.commit()
	mesh.material_override = m
	parent.add_child(mesh)

func build_rooms() -> void:
	var wall := ShaderMaterial.new()
	var wall_shader := Shader.new()
	wall_shader.code = "shader_type spatial; render_mode cull_disabled; uniform sampler2D grain: source_color, filter_linear_mipmap; void fragment(){float g=dot(texture(grain,UV).rgb,vec3(.333)); ALBEDO=vec3(.73,.72,.70)*(.96+.10*g); ROUGHNESS=1.0;}"
	wall.shader=wall_shader
	wall.set_shader_parameter("grain",load("res://textures/wall-muse.webp"))
	var ivory := look(Color("eee5d4"))
	var oak := look(Color("d8c69e"), "res://textures/oak-muse.webp")
	for area in [[-1.9, 2.8, -5.26778, -.2], [-2.0, 3.2, .2, 5.73222]]:
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
					[Vector2(.04,band),Vector2(.04,band+.024),Vector2(.96,band+.024),Vector2(.96,band)], oak)
		for side in [x0, x1]:
			var w := solid(Vector3(side, 1.75, (z0+z1)/2), Vector3(.12,3.5,depth+.2), wall, true)
			var trim := MeshInstance3D.new()
			var profile := BoxMesh.new()
			profile.size = Vector3(.17,.14,depth+.2)
			trim.mesh = profile
			trim.position.y = -1.67
			trim.material_override = ivory
			w.add_child(trim)
			# Trim follows the parent's cutaway; the extra child hides with it below.
			var crown := solid(Vector3(side,3.35,(z0+z1)/2),Vector3(.23,.13,depth+.2),ivory)
			crown.reparent(w)
		var end: float = z0 if z0 < 0 else z1
		var w := solid(Vector3((x0+x1)/2,1.75,end),Vector3(width,3.5,.12),wall,true)
		for y in [.07,3.35]:
			var trim := solid(Vector3((x0+x1)/2,y,end+.07),Vector3(width,.14,.15),ivory)
			trim.reparent(w)
	# The observed opening is shared by these rooms; no new connectors.
	for span in [[-1.9,-.62408],[1.17898,3.2]]:
		var width: float = span[1]-span[0]
		solid(Vector3((span[0]+span[1])/2,1.75,0),Vector3(width,3.5,.25),wall,true)
	var lintel:=solid(Vector3(.27745,3.12,0),Vector3(1.80,.76,.25),wall,true)
	for i in 2:
		var x: float = [-.62408,1.17898][i]
		var trim:=solid(Vector3(x,1.35,.16),Vector3(.14,2.7,.13),ivory)
		trim.reparent(casings[i])
	var trim:=solid(Vector3(.27745,2.73,.16),Vector3(1.98,.18,.16),ivory)
	trim.reparent(lintel)
	panel(self,[Vector3(-.62408,.004,-.2),Vector3(1.17898,.004,-.2),Vector3(1.17898,.004,.2),Vector3(-.62408,.004,.2)],
		[Vector2.ZERO,Vector2.RIGHT,Vector2.ONE,Vector2.DOWN],oak)

func build_bookcase() -> void:
	var node := Node3D.new()
	node.position = Vector3(.45,.13,-4.87)
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
	solid(Vector3(.45,.87,-4.99),Vector3(1.2,1.55,.42),look(Color(0,0,0,0)),true).get_child(1).hide()

func build_mirrors() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/mirror-outline.json"))
	for x in [-.95,1.85]:
		var mirror := Painting.new()
		add_child(mirror)
		mirror.build_shaped(load("res://assets/mirror.png"),Vector2(.78,1.95),data.outline,Color("a27c37"))
		mirror.get_child(0).material_override.set_shader_parameter("alpha_cut",.5)
		mirror.position=Vector3(x,1.95,-5.04)
	# Repeated placement is a pair proxy, not a verified second mirror identity.

func build_displays() -> void:
	var ivory:=look(Color("eeeae2"))
	var wood:=look(Color("38281d"))
	var cloth:=look(Color.WHITE,"res://assets/sofa-cloth.webp")
	# Source-observed white furniture platforms, sofa, and ceramic display case.
	solid(Vector3(.45,.065,-4.72),Vector3(4.25,.13,.95),ivory,true)
	solid(Vector3(-1.46,.065,-2.65),Vector3(.80,.13,2.75),ivory,true)
	var sofa:=Node3D.new()
	sofa.position=Vector3(-1.40,.13,-2.65)
	sofa.rotation.y=PI/2
	add_child(sofa)
	for spec in [[Vector3(0,.45,0),Vector3(1.5,.24,.6)],[Vector3(0,.8,-.23),Vector3(1.5,.65,.14)],[Vector3(-.74,.61,0),Vector3(.12,.5,.62)],[Vector3(.74,.61,0),Vector3(.12,.5,.62)]]:
		var part:=solid(spec[0],spec[1],cloth)
		part.reparent(sofa,false)
	for x in [-.63,.63]:
		for z in [-.22,.22]:
			var leg:=solid(Vector3(x,.16,z),Vector3(.055,.32,.055),wood)
			leg.reparent(sofa,false)
	# Furniture clearance boxes keep the visitor off museum platforms.
	solid(Vector3(2.23,.55,-2.0),Vector3(.8,1.1,1.75),ivory,true)
	var glass:=look(Color(.78,.88,.89,.16))
	glass.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	for z in [-2.88,-1.12]:
		solid(Vector3(2.23,1.5,z),Vector3(.8,.80,.012),glass)
	for x in [1.83,2.63]:
		solid(Vector3(x,1.5,-2),Vector3(.012,.8,1.75),glass)
	# Six-sided vessel silhouettes: temporary until individual asset passes.
	for z in [-2.5,-2,-1.5]:
		var vase:=MeshInstance3D.new()
		var cylinder:=CylinderMesh.new()
		cylinder.top_radius=.10
		cylinder.bottom_radius=.06
		cylinder.height=.23
		cylinder.radial_segments=8
		vase.mesh=cylinder
		vase.position=Vector3(2.23,1.22,z)
		vase.material_override=ivory
		add_child(vase)
	var frame_data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/frame-geometry.json"))
	var frame:=Painting.new()
	add_child(frame)
	frame.build_framed(load("res://assets/frame.png"),load("res://assets/painting-35.786.jpg"),Vector2(.651,.541),frame_data.margins_px)
	frame.position=Vector3(-1.92,1.9,2.8)
	frame.rotation.y=PI/2
	# Other painting identities are not yet verified; do not fill walls with invented works.

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	# Trim is part of its wall's camera cutaway, not a floating independent band.
	for wall in casings:
		for i in range(2,wall.get_child_count()):
			wall.get_child(i).visible=wall.get_child(1).visible
