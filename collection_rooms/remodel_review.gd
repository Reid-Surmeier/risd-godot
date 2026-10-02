## #182/#183 native room, close-up and oblique visual proof.
extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.size=Vector2i(1100,760)
	var presentation=load("res://collection_rooms/remodel_presenter.tscn").instantiate()
	root.add_child(presentation)
	var scene=presentation.scene
	await process_frame
	# Wall-hung work is owned by its wall's visual for the cutaway, so compare global transforms.
	var lion:Array=scene.find_children("*","MeshInstance3D",true,false).filter(func(node):return node.get_meta("catalogue_asset","")=="lion-panel")
	assert(lion.size()==1 and lion[0].global_position.distance_to(Vector3(14.6,1.18,28.18))<.0001,"Lion must sit on its source wall after the catalogue group shift")
	assert(lion[0].global_transform.basis.z.distance_to(Vector3.BACK)<.0001,"Left-facing source orientation must remain on the modern-door wall")
	var lion_proof:=FileAccess.open("res://collection_rooms/evidence/lion-installed-position.json",FileAccess.WRITE)
	assert(lion_proof!=null)
	lion_proof.store_string(JSON.stringify({"position":[lion[0].global_position.x,lion[0].global_position.y,lion[0].global_position.z],"yaw":0.0,"catalogue_front_size_m":[2.286,1.041],"depth_m_provisional":.08,"closed_slab_triangles":12,"generated_damage_accepted":false,"original_front_retained":true,"individual_brick_relief_complete":false},"\t")+"\n")
	var modern_proof:Array=[]
	for spec in [["1995.043",Vector3(10.78,1.65,24.75),PI/2],["57.037",Vector3(12.0,1.65,22.38),0.0],["43.255",Vector3(13.65,1.65,22.38),0.0],["48.248",Vector3(14.2,1.65,28.02),PI],["70.058",Vector3(15.55,1.65,28.02),PI]]:
		var work:Array=scene.find_children("*","Node3D",true,false).filter(func(node):return node.get_meta("catalogue_accession","")==spec[0])
		assert(work.size()==1 and work[0].global_position.distance_to(spec[1])<.0001 and work[0].global_transform.basis.z.distance_to(Vector3(sin(spec[2]),0,cos(spec[2])))<.0001,"Catalogue painting must keep its assigned source wall")
		modern_proof.append({"accession":spec[0],"position":[work[0].global_position.x,work[0].global_position.y,work[0].global_position.z],"yaw":spec[2],"frame_outer_size_m":[work[0].outer.x,work[0].outer.y],"metric_accepted":false})
	var seated:StaticBody3D=scene.get_node("SeatedWomanCase")
	assert(seated.position.distance_to(Vector3(16.64,0,24.85))<.00001 and abs(seated.rotation.y+PI/2)<.00001)
	var windows:Array=scene.find_children("*","MeshInstance3D",true,false).filter(func(node):return node.has_meta("modern_window"))
	assert(windows.size()==2 and windows.all(func(node):return abs(node.global_position.x-16.624)<.00001),"Two windows share the wall right of the entry")
	var figure:MeshInstance3D=seated.get_child(3)
	assert(figure.get_meta("catalogue_accession")=="67.089" and figure.mesh.get_aabb().size.distance_to(Vector3(.203,.711,.241))<.0005,"Seated Woman catalogue bounds changed")
	var modern_file:=FileAccess.open("res://collection_rooms/evidence/modern-installed-positions.json",FileAccess.WRITE)
	assert(modern_file!=null)
	modern_file.store_string(JSON.stringify(modern_proof,"\t")+"\n")
	for view in [["modern-walk",Vector3(11.9,.25,26.25)],["landing-walk",Vector3(14.6,.25,30.05)],["room",Vector3(.45,.25,-4.6)],["gallery",Vector3(-.55,.25,3)],["grey-walk",Vector3(11.3,.25,.58)],["hall-walk",Vector3(7,.25,11)],["hall-portal-walk",Vector3(5.55,.25,23)],["medieval-walk",Vector3(6.5,.25,22.4)],["renaissance-walk",Vector3(-.55,.25,21.5)]]:
		scene.reset(moved(view[0],view[1]))
		for i in 30:
			await physics_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png("res://collection_rooms/evidence/"+view[0]+".png")==OK)
	scene.set_physics_process(false)
	scene.visitor.hide()
	scene.contact_shadow.hide()
	for casing in scene.casings:
		casing.get_child(1).show()
	scene.label.text="Collection · authored low polygon geometry + Muse textures\nMuseum-catalogued objects / Muse asset trials. Dimensions and hidden profiles provisional."
	for view in [["bookcase-detail",Vector3(.55,1.5,-3.5),Vector3(.55,1.1,-6.84)],
		["bookcase-oblique",Vector3(2.1,1.65,-5.4),Vector3(.45,.95,-6.84)],
		["mirror-detail",Vector3(-1.05,2.15,-4.65),Vector3(-1.05,2.15,-7.00)],
		["entrance-chair-detail",Vector3(.2,1.5,-1.95),Vector3(-2.2,.7,-1.95)],
		["settee-detail",Vector3(.1,1.8,-4.7),Vector3(-2.21,.75,-4.7)],
		["bust-detail",Vector3(-.3,1.65,-6.15),Vector3(-2.2,1.60,-5.87)],
		["gold-service-detail",Vector3(.8,1.7,-3.8),Vector3(3.05,1.27,-3.8)],
		["pink-service-detail",Vector3(1.85,1.7,-3.2),Vector3(1.85,1.24,-.95)],
		["door-sconce-detail",Vector3(-.55,2.1,-3.2),Vector3(-.55,1.9,-.4)],
		["perugino-walking",Vector3(-.55,1.65,22.8),Vector3(.55,1.55,18.93)]]:
		scene.camera.fov=45
		scene.camera.position=moved(view[0],view[1])
		scene.camera.look_at(moved(view[0],view[2]))
		scene.update_baked_visibility()
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png("res://collection_rooms/evidence/"+view[0]+".png")==OK)
	# Inspect geometry at native resolution as well as the shipping 376x252 presentation.
	var ceilings:Array=scene.ceiling_details.filter(func(mesh):return mesh.has_meta("opaque_ceiling"))
	assert(ceilings.size()==3,"Renaissance, medieval and modern ceilings must exist")
	var ceiling_proof:=[]
	for height in [1.65,5.3]:
		scene.camera.position.y=height
		scene.update_baked_visibility()
		var copies:=0
		for ceiling in ceilings:assert(ceiling.visible==(height<3.4))
		var baked=scene.get_node_or_null("BakedRoom")
		if baked:
			for mesh in baked.get_children():
				if mesh is MeshInstance3D and mesh.has_meta("live_cutaway") and mesh.get_meta("live_cutaway") in ceilings:
					assert(mesh.visible==(height<3.4))
					copies+=1
			assert(copies==3,"Baked ceiling copies must follow the walking camera cutaway")
		ceiling_proof.append({"camera_height_m":height,"visible":height<3.4,"authored_ceilings":ceilings.size(),"baked_copies":copies})
	var proof_file:=FileAccess.open("res://collection_rooms/evidence/ceiling-visibility.json",FileAccess.WRITE)
	assert(proof_file!=null)
	proof_file.store_string(JSON.stringify(ceiling_proof,"\t")+"\n")
	var native_view:SubViewport=scene.get_viewport()
	native_view.get_parent().stretch=false
	native_view.size=Vector2i(1100,760)
	for view in [["bookcase-asset",Vector3(.55,1.35,-4.3),Vector3(.55,1.1,-6.84)],
		["gold-service-asset",Vector3(1.7,1.8,-3.8),Vector3(3.05,1.27,-3.8)],
		["pink-service-asset",Vector3(1.85,1.8,-2.7),Vector3(1.85,1.24,-.95)],
		["wide-purple-entry",Vector3(3.2,1.65,-2),Vector3(-2.6,1.35,-4.8)],
		["wide-gallery-entry",Vector3(-.8,1.65,1.1),Vector3(.15,1.3,-6.2)],
		["wide-settee-portrait",Vector3(.8,1.65,-4.9),Vector3(-2.4,1.45,-4.7)],
		["wide-gold-pedestal",Vector3(.8,1.65,-2.8),Vector3(3.05,1.0,-3.8)],
		["purple-wall-detail",Vector3(3.9,1.65,.58),Vector3(5.6,1.65,.38)],
		["purple-grey-wide",Vector3(4.1,1.65,.58),Vector3(15.65,1.5,.58)],
		["grey-purple-reverse",Vector3(14.8,1.65,.58),Vector3(3.1,1.5,.58)],
		["grey-gallery-wide",Vector3(8.9,1.65,.58),Vector3(15.65,1.5,-1.2)],
		["ionic-capital-front",Vector3(13.9,2.9,-2.6),Vector3(15.65,2.9,-2.6)],
		["ionic-capital-oblique",Vector3(14.4,2.95,-1.55),Vector3(15.65,2.9,-2.6)],
		["grey-door-corner",Vector3(13.5,1.65,-3),Vector3(8.9,1.5,.5)],
		#6380 38.3s and 6381 91.0s, the two fitted views of the west wall (approximate eye, not a calibrated camera).
		["grey-west-wall-source",Vector3(13.6,1.6,-2.0),Vector3(8.45,1.7,-.9)],
		["grey-west-wall-stair",Vector3(16.9,2.6,-1.2),Vector3(8.45,1.2,-1.2)],
		#6380 240.3s: inside Rockefeller looking east through the connector, north of the pink case.
		["rockefeller-connector-source",Vector3(1.65,1.6,-1.85),Vector3(7.95,1.5,-1.4)],
		["courbet-in-room",Vector3(10.2,1.8,-3.06),Vector3(8.53,1.8,-3.06)],
		["corot-in-room",Vector3(14.8,1.8,-2.3),Vector3(14.8,1.8,-4.12)],
		["bertin-in-room",Vector3(13.3,1.75,-.8),Vector3(13.3,1.75,1.72)],
		["bertin-hall-wall",Vector3(15,1.65,-1.4),Vector3(12.4,1.7,1.8)],
		["architecture-asset",Vector3(-.55,2.1,-3.5),Vector3(-.55,1.9,-.4)],
		["wallpaper-asset",Vector3(1.6,2.1,-5.4),Vector3(3.59,2.1,-5.4)],
		["gallery-wide",Vector3(-.55,1.65,2.9),Vector3(-.3,1.5,12)],
		["fetti-in-room",Vector3(-1.65,1.8,8.8),Vector3(-3.48,1.8,8.8)],
		["gallery-piers",Vector3(.0,1.65,3.4),Vector3(2.28,1.75,8.4)],
		["gallery-far-door",Vector3(-.55,1.65,16.3),Vector3(-.55,1.6,19.7)],
		["european-door-reverse",Vector3(-.55,1.65,21),Vector3(-.55,1.5,18.85)],
		["european-door-detail",Vector3(-.10,1.55,19.45),Vector3(-1.59,1.38,19.33)],
		["goltzius-in-room",Vector3(-1.65,1.75,14.7),Vector3(-3.48,1.75,14.7)],
		["renaissance-wide",Vector3(-2,1.65,24),Vector3(.8,1.8,19.7)],
		["perugino-in-room",Vector3(1.48,1.55,21),Vector3(1.48,1.55,18.93)],
		["renaissance-door-wall",Vector3(-.55,1.65,22.8),Vector3(-.55,1.65,18.85)],
		["renaissance-door-corner",Vector3(-.6,1.65,23.8),Vector3(1.05,1.65,18.85)],
		["tracery-front",Vector3(-.3,2.6,22.515),Vector3(2.5,2.8,22.515)],
		["tracery-angle",Vector3(.7,2.6,23.7),Vector3(2.5,2.8,22.515)],
		["medieval-wide",Vector3(3.3,1.65,24.1),Vector3(7.5,1.8,20.5)],
		["medieval-portal-wall-wide",Vector3(6.5,1.65,24.05),Vector3(6.5,1.65,18.85)],
		["landing-lion-front",Vector3(14.6,1.7005,31.25),Vector3(14.6,1.7005,28.25)],
		["modern-large-front",Vector3(14.7,1.65,24.75),Vector3(10.78,1.65,24.75)],
		["modern-large-oblique",Vector3(12.8,1.65,27.55),Vector3(10.78,1.65,24.75)],
		["landing-lion-oblique",Vector3(13.15,1.65,30.75),Vector3(14.6,1.7005,28.25)],
		["landing-lion-wide",Vector3(12.65,1.65,31.65),Vector3(13.95,1.70,28.2)],
		["landing-medieval-reverse",Vector3(15.3,1.65,31.765),Vector3(10.55,1.65,31.765)],
		["landing-modern-door",Vector3(11.85,1.65,31.9),Vector3(11.85,1.65,28.1)],
		["landing-white-door",Vector3(12.85,1.65,30.5),Vector3(16.15,1.65,30.5)],
		["landing-stair-void",Vector3(15.4,1.65,35.515),Vector3(11.4,.6,35.315)],
		["modern-entry-wide",Vector3(11.85,1.65,27.35),Vector3(12.4,1.55,22.35)],
		["modern-windows-wide",Vector3(11.8,1.65,27.35),Vector3(16.7,1.65,24.05)],
		["modern-doorway-corner",Vector3(13.0,1.65,25.65),Vector3(15.8,1.5,22.3)],
		["modern-seated-woman",Vector3(14.45,1.32,24.85),Vector3(16.32,1.25,24.85)],
		["modern-seated-woman-oblique",Vector3(14.85,1.55,25.95),Vector3(16.32,1.25,24.85)],
		["modern-braque",Vector3(14.2,1.65,26.1),Vector3(14.2,1.65,28.02)],
		["modern-villon",Vector3(15.55,1.65,26.3),Vector3(15.55,1.65,28.02)],
		["modern-pumpkin",Vector3(12.0,1.65,24.4),Vector3(12.0,1.65,22.38)],
		["modern-cezanne",Vector3(13.65,1.65,24.4),Vector3(13.65,1.65,22.38)],
		["medieval-stair-wall-wide",Vector3(6.3,1.65,23.615),Vector3(10.45,1.65,22.515)],
		["medieval-apostle-left",Vector3(8.6,1.45,21.215),Vector3(10.38,1.453,21.215)],
		["medieval-apostle-right",Vector3(8.6,1.47,23.965),Vector3(10.38,1.472,23.965)],
		["medieval-stair-door-detail",Vector3(8.15,1.75,20.65),Vector3(10.55,1.75,22.515)],
		["medieval-grille-front",Vector3(9.4,1.31,20.85),Vector3(9.4,1.31,19.19)],
		["medieval-grille-oblique",Vector3(7.8,1.65,21.8),Vector3(9.4,1.31,19.19)],
		["medieval-panel-bartolo",Vector3(3.05,1.65,20.75),Vector3(1.65,1.55,20.75)],
		["medieval-panel-virgin",Vector3(3.05,1.65,19.53),Vector3(1.65,1.55,19.53)],
		["medieval-panel-magdalene",Vector3(2.13,1.6,20.5),Vector3(2.13,1.55,19.05)],
		["medieval-frame-front",Vector3(2.13,1.55,20.05),Vector3(2.13,1.55,19.05)],
		["medieval-frame-oblique",Vector3(2.93,1.6,20.05),Vector3(2.13,1.55,19.05)],
		["medieval-panel-peter",Vector3(2.95,1.65,21.0),Vector3(2.95,1.55,19.05)],
		["medieval-north-panel-wide",Vector3(3.35,1.65,21.45),Vector3(2.05,1.55,19.05)],
		["medieval-cases-east",Vector3(3.5,1.65,22.4),Vector3(9,1.2,21.9)],
		["medieval-cases-portal",Vector3(7.6,1.65,24.2),Vector3(5.55,1.5,18.85)],
		["portal-front",Vector3(5.55,2.1,24),Vector3(5.55,1.93,18.85)],
		["portal-angle",Vector3(7.4,2.1,22),Vector3(5.55,1.93,18.85)],
		["hall-portal-join",Vector3(5.55,1.65,23),Vector3(5.55,1.9,29)],
		["hall-grey-join",Vector3(5.55,1.65,2),Vector3(5.55,1.6,-4)],
		["hall-wide-arch",Vector3(5.55,1.65,16),Vector3(5.55,1.8,25.9)],
		["hall-wide-far",Vector3(5.55,1.65,7),Vector3(5.55,1.8,-.4)],
		["hall-west-paintings",Vector3(6.3,1.65,13),Vector3(.55,1.8,13)],
		["bust-asset",Vector3(-.9,1.65,-5.87),Vector3(-2.2,1.60,-5.87)]]:
		scene.camera.fov=82 if view[0] in ["medieval-portal-wall-wide","medieval-grille-front"] else 55 if view[0]=="medieval-grille-oblique" else 70 if view[0] in ["landing-lion-wide","renaissance-wide","medieval-wide","medieval-stair-wall-wide","landing-stair-void","modern-entry-wide","modern-windows-wide","modern-doorway-corner"] else 45
		scene.camera.position=moved(view[0],view[1])
		scene.camera.look_at(moved(view[0],view[2]))
		scene.update_baked_visibility()
		await process_frame
		await RenderingServer.frame_post_draw
		assert(native_view.get_texture().get_image().save_png("res://collection_rooms/evidence/"+view[0]+".png")==OK)
	# Hall177.50 portrait: approximate eye/tilt for source comparison, not a calibrated camera.
	native_view.size=Vector2i(540,960)
	scene.camera.fov=84.2
	scene.camera.position=Vector3(5.4,1.65,9.3)
	scene.camera.look_at(Vector3(5.55,-1.2,28.1))
	scene.update_baked_visibility()
	await process_frame
	await RenderingServer.frame_post_draw
	assert(native_view.get_texture().get_image().save_png("res://collection_rooms/evidence/hall-source-camera.png")==OK)
	var fit:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://collection_rooms/assets/wide-camera-fit.json"))
	native_view.size=Vector2i(540,960)
	scene.camera.fov=fit.vertical_fov_degrees
	scene.camera.position=scene.vec(fit.position)+Vector3(-1.95,0,2.2)
	scene.camera.look_at(scene.vec(fit.target)+Vector3(-1.95,0,2.2),scene.vec(fit.up))
	scene.update_baked_visibility()
	await process_frame
	await RenderingServer.frame_post_draw
	assert(native_view.get_texture().get_image().save_png("res://collection_rooms/evidence/wide-source-camera.png")==OK)
	native_view.size=Vector2i(700,760)
	scene.camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	scene.camera.size=.85
	for view in [["bust-front-uv",Vector3(-.9,1.62,-5.87)],
		["bust-rear-uv",Vector3(-2.63,1.62,-5.87)],
		["bust-side-uv",Vector3(-2.2,1.62,-4.8)]]:
		scene.camera.position=moved(view[0],view[1])
		scene.camera.look_at(Vector3(-4.15,1.62,-3.67))
		scene.update_baked_visibility()
		await process_frame
		await RenderingServer.frame_post_draw
		assert(native_view.get_texture().get_image().save_png("res://collection_rooms/evidence/"+view[0]+".png")==OK)
	native_view.size=Vector2i(800,1200)
	scene.camera.size=43
	scene.camera.position=Vector3(3.55,45,13.3)
	scene.camera.look_at(Vector3(3.55,0,13.3),Vector3.FORWARD)
	scene.update_baked_visibility()
	await process_frame
	await RenderingServer.frame_post_draw
	assert(native_view.get_texture().get_image().save_png("res://collection_rooms/evidence/loop-overview.png")==OK)
	print("REMODEL_VISUAL_PROOF: connected Hall, authored room comparisons, walking views and object details")
	quit()

func moved(name:String,p:Vector3) -> Vector3:
	if name.begins_with("landing-") or name.begins_with("modern-"):return p
	# Hall reveal: views of Rockefeller, the connector and the grey gallery go north with those rooms.
	var reveal:float=JSON.parse_string(FileAccess.get_file_as_string("res://collection_rooms/geometry.json")).hall_reveal.wall_m
	if name.begins_with("hall-"):return p+Vector3(0,0,2.2)
	if name=="grey-purple-reverse" and p.x<8.45:return p+Vector3(-1.95,0,-reveal)
	if name.begins_with("grey-") or name.begins_with("ionic-") or name.begins_with("courbet-") or name.begins_with("corot-") or name.begins_with("bertin-"):return p+Vector3(-4.6,0,-reveal)
	if name.begins_with("purple-"):
		return Vector3(1.7+(p.x-3.65)*2.15/4.8,p.y,p.z-reveal) if p.x<8.45 else p+Vector3(-4.6,0,-reveal)
	if name.begins_with("portal-"):return p+Vector3(0,0,9.25)
	if name.begins_with("medieval-"):return p+Vector3(-.95,0,9.25)
	if name.begins_with("renaissance-") or name.begins_with("perugino-") or name.begins_with("tracery-") or name.begins_with("european-door") or name=="gallery-far-door":return p+Vector3(-1.95,0,9.25)
	# Grey register: Rockefeller views move 2.2m with the room; European gallery views keep their z.
	if name.begins_with("gallery") or name.begins_with("fetti-") or name.begins_with("goltzius-"):return p+Vector3(-1.95,0,0)
	return p+Vector3(-1.95,0,2.2-reveal)
