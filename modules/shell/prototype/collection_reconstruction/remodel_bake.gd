## Main Hall native UV2 / LightmapGI recipe applied to the new authored room only.
extends SceneTree

func _initialize() -> void:
	call_deferred("prepare")

func prepare() -> void:
	var walk=load("res://remodel_room.tscn").instantiate()
	walk.set_meta("bake_preparing",true)
	root.add_child(walk)
	await process_frame
	assert(not walk.inventory.has("native_lightmap_users"),"Rebake must exclude the previous baked room")
	walk.set_physics_process(false)
	var room:=Node3D.new()
	room.name="BakedRoom"
	var index:=0
	var floors:=SurfaceTool.new()
	var floor_names:=[]
	var floor_material:Material
	for source in walk.find_children("*","MeshInstance3D",true,false):
		if walk.visitor.is_ancestor_of(source) or source.has_meta("contact_shadow") or not source.is_visible_in_tree() or source.mesh.get_surface_count()==0 or source.has_meta("skylight"):continue
		if source.material_override is StandardMaterial3D and source.material_override.transparency==BaseMaterial3D.TRANSPARENCY_ALPHA:continue
		if source.material_override is ShaderMaterial and source.material_override.shader.resource_path.ends_with("floor_oak.gdshader"):
			floors.append_from(source.mesh,0,source.global_transform)
			floor_names.append(source.name)
			floor_material=source.material_override
			continue
		var st:=SurfaceTool.new()
		for surface in source.mesh.get_surface_count():st.append_from(source.mesh,surface,Transform3D.IDENTITY)
		var mesh:=st.commit()
		var normals=mesh.surface_get_arrays(0)[Mesh.ARRAY_NORMAL]
		if normals==null or normals.is_empty():
			st.generate_normals()
			mesh=st.commit()
		var result:=mesh.lightmap_unwrap(source.global_transform,.14)
		assert(result==OK,"Native UV2 unwrap failed")
		var instance:=MeshInstance3D.new()
		instance.name="Surface%03d"%index
		instance.mesh=mesh
		instance.material_override=source.material_override
		# Reuse gallery_walk4/bake/prepare.gd's native PS1-to-bake material handling.
		if source.material_override is ShaderMaterial and source.material_override.shader.resource_path.ends_with("/ps1.gdshader"):
			var original:ShaderMaterial=source.material_override
			var material:=StandardMaterial3D.new()
			var tint=original.get_shader_parameter("tint")
			material.albedo_color=tint if tint!=null else Color.WHITE
			material.albedo_texture=original.get_shader_parameter("albedo")
			var scale_uv=original.get_shader_parameter("uv_scale")
			if scale_uv!=null:material.uv1_scale=Vector3(scale_uv.x,scale_uv.y,1)
			material.specular_mode=BaseMaterial3D.SPECULAR_DISABLED
			material.cull_mode=BaseMaterial3D.CULL_DISABLED
			material.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
			var alpha=original.get_shader_parameter("alpha_cut")
			if alpha!=null and alpha>0:
				material.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
				material.alpha_scissor_threshold=alpha
			if material.albedo_texture and not "/textures/" in material.albedo_texture.resource_path:material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
			if source.get_parent().name=="ConnectedHall" and source.mesh.get_aabb().position.y>=6 and source.mesh.get_aabb().size.y>1:material.albedo_color=Color("e2dccd")
			instance.material_override=material
		instance.transform=source.global_transform
		instance.gi_mode=GeometryInstance3D.GI_MODE_STATIC
		instance.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
		instance.set_meta("source_path",source.name)
		room.add_child(instance)
		instance.owner=room
		index+=1
	# Same continuous world UV2 floor as the Main Hall: joins cannot become bake islands.
	var merged:=floors.commit()
	var arrays:=merged.surface_get_arrays(0)
	var uv2:=PackedVector2Array()
	var bounds:=merged.get_aabb()
	for point in arrays[Mesh.ARRAY_VERTEX]:
		var uv:=Vector2((point.x-bounds.position.x)/bounds.size.x,(point.z-bounds.position.z)/bounds.size.z)
		assert(uv.x>=0 and uv.x<=1 and uv.y>=0 and uv.y<=1)
		uv2.append(uv)
	arrays[Mesh.ARRAY_TEX_UV2]=uv2
	var floor_mesh:=ArrayMesh.new()
	floor_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	floor_mesh.lightmap_size_hint=Vector2i(512,1024)
	var floor_instance:=MeshInstance3D.new()
	floor_instance.name="ContinuousFloor"
	floor_instance.mesh=floor_mesh
	floor_instance.material_override=floor_material
	floor_instance.gi_mode=GeometryInstance3D.GI_MODE_STATIC
	floor_instance.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	floor_instance.set_meta("source_paths",floor_names)
	room.add_child(floor_instance)
	floor_instance.owner=room
	index+=1
	for position in [Vector3(.45,3.25,-5.5),Vector3(.45,3.25,-2),Vector3(4.6,3.25,-2),Vector3(-.55,3.25,2),Vector3(-.55,3.25,6),Vector3(-.55,3.25,10),Vector3(-.55,3.25,14),Vector3(-.55,3.25,17),Vector3(-.55,3.25,22),Vector3(7,4.0,21),Vector3(7,4.0,24),Vector3(12.2,3.25,22.515),Vector3(6.5,3.25,-2),Vector3(10.5,3.25,-2),Vector3(13.5,3.25,-2),Vector3(16.5,3.25,-2)]:
		var light:=OmniLight3D.new()
		light.position=corrected(position)
		light.omni_range=8
		light.omni_attenuation=.65
		light.light_energy=.55
		light.light_color=Color("ffe1b2")
		# Native grey-room wides show neutral track-light fill; keep the warm painting spots.
		if position.x>=9.0 or position.z>19.0:
			light.light_color=Color("f2f0ea")
		# Keep the room fill emitter below the new opaque ceiling.
		var enclosed:bool=position.z>19.0 and position.x<9.0
		light.light_size=.12 if enclosed else 2.5
		if enclosed:
			light.light_energy=1.1
			var ceiling_height:float=3.5 if position.x<0 else 4.25
			assert(light.position.y+light.light_size<ceiling_height,"Room fill emitter must fit below its ceiling")
		light.light_bake_mode=Light3D.BAKE_STATIC
		light.shadow_enabled=true
		room.add_child(light)
		light.owner=room
	# Latest Main Hall's offline painting spots, placed below this room's lower ceiling.
	for spec in [[Vector3(.55,2.43,-7.02),Vector3.BACK],[Vector3(-1.05,2.15,-7),Vector3.BACK],[Vector3(2.25,2.15,-7),Vector3.BACK],[Vector3(-2.67,2,-4.7),Vector3.RIGHT],[Vector3(-3.48,1.75,4.35),Vector3.RIGHT],[Vector3(.70,1.55,30),Vector3.RIGHT,true],[Vector3(.70,1.55,28.78),Vector3.RIGHT,true],[Vector3(2.0,1.55,28.30),Vector3.BACK,true],[Vector3(1.18,1.55,28.30),Vector3.BACK,true]]:
		var spot:=SpotLight3D.new()
		room.add_child(spot)
		spot.owner=room
		var target:Vector3=spec[0] if spec.size()==3 else corrected(spec[0])
		spot.position=target+spec[1]*2.2
		spot.position.y=3.8 if spec.size()==3 else 3.2
		spot.look_at_from_position(spot.position,target,Vector3.UP)
		spot.spot_range=7
		spot.spot_angle=25
		spot.spot_angle_attenuation=1.5
		spot.light_color=Color("f2f0ea") if spec.size()==3 else Color("ffd391")
		spot.light_energy=6.8
		spot.light_size=.35
		spot.light_bake_mode=Light3D.BAKE_STATIC
		spot.shadow_enabled=true

	#6387 neutral ceiling-track fill below the modern ceiling, separate from Hall lighting.
	for position in [Vector3(13.35,3.8,30.1),Vector3(14.4,3.8,35.915),Vector3(11.8,3.25,25.2),Vector3(13.7,3.25,25.2),Vector3(15.6,3.25,25.2)]:
		var light:=OmniLight3D.new()
		light.position=position
		light.omni_range=7
		light.omni_attenuation=.65
		light.light_energy=.8
		light.light_color=Color("f2f0ea")
		light.light_size=.12
		light.light_bake_mode=Light3D.BAKE_STATIC
		light.shadow_enabled=true
		room.add_child(light)
		light.owner=room
	for spec in [[Vector3(14.2,1.65,28.02),Vector3.FORWARD],[Vector3(15.55,1.65,28.02),Vector3.FORWARD],[Vector3(12.0,1.65,22.38),Vector3.BACK],[Vector3(13.65,1.65,22.38),Vector3.BACK],[Vector3(10.78,1.65,24.75),Vector3.RIGHT]]:
		var spot:=SpotLight3D.new()
		room.add_child(spot)
		spot.owner=room
		spot.position=spec[0]+spec[1]*1.2
		spot.position.y=3.2
		spot.look_at_from_position(spot.position,spec[0],Vector3.UP)
		spot.spot_range=5
		spot.spot_angle=40
		spot.light_energy=1.2
		spot.light_color=Color("f2f0ea")
		spot.light_size=.18
		spot.light_bake_mode=Light3D.BAKE_STATIC
		spot.shadow_enabled=true
	var lion_spot:=SpotLight3D.new()
	room.add_child(lion_spot)
	lion_spot.owner=room
	lion_spot.position=Vector3(14.6,3.6,29.75)
	lion_spot.look_at_from_position(lion_spot.position,Vector3(14.6,1.7,28.25),Vector3.UP)
	lion_spot.spot_range=5
	lion_spot.spot_angle=45
	lion_spot.light_energy=1.0
	lion_spot.light_color=Color("f2f0ea")
	lion_spot.light_size=.2
	lion_spot.light_bake_mode=Light3D.BAKE_STATIC
	lion_spot.shadow_enabled=true
	for x in [14.4,11.8,13.7,15.6]:
		for z in ([30.0,31.9,35.515] if x==14.4 else [26.65,23.75]):
			for y in [.3,1.1,2.0]:
				var probe:=LightmapProbe.new()
				probe.position=Vector3(x,y,z)
				room.add_child(probe)
				probe.owner=room
	# Retain the reviewed Hall's5 diffuse sources and23 warm painting spots.
	for z in [25.1,20.1,15.1,10.1,5.1]:
		var light:=OmniLight3D.new()
		light.position=Vector3(5.55,5.7,z)
		light.omni_range=13
		light.omni_attenuation=.65
		light.light_energy=.4
		light.light_color=Color("fff1d9")
		light.light_size=2.5
		light.light_bake_mode=Light3D.BAKE_STATIC
		light.shadow_enabled=true
		room.add_child(light)
		light.owner=room
	var hall:Node3D=walk.get_node("ConnectedHall")
	for painting in hall.get_meta("painting_lights"):
		var spot:=SpotLight3D.new()
		room.add_child(spot)
		spot.owner=room
		var target:Vector3=painting.center+hall.position
		spot.position=target+painting.normal*2.2+Vector3.UP*3.1
		spot.look_at_from_position(spot.position,target,Vector3.UP)
		spot.spot_range=7
		spot.spot_angle=25
		spot.spot_angle_attenuation=1.5
		spot.light_color=Color("ffd391")
		spot.light_energy=6
		spot.light_size=.35
		spot.light_bake_mode=Light3D.BAKE_STATIC
		spot.shadow_enabled=true
	for z in [2.3,5.1,10.1,15.1,20.1,25.1,28.0]:
		for x in [1.35,3.55,5.55,7.55,9.75]:
			for y in [.3,1.1,2]:
				var probe:=LightmapProbe.new()
				probe.position=Vector3(x,y,z)
				room.add_child(probe)
				probe.owner=room
	var daylight:=DirectionalLight3D.new()
	daylight.rotation_degrees=Vector3(-60,-75,0)
	daylight.light_color=Color("eff5ff")
	daylight.light_energy=.8 # same strength as the saved Main Hall native bake
	daylight.light_angular_distance=6
	daylight.light_bake_mode=Light3D.BAKE_STATIC
	daylight.shadow_enabled=true
	room.add_child(daylight)
	daylight.owner=room
	var lm:=LightmapGI.new()
	lm.name="Lightmap"
	lm.quality=LightmapGI.BAKE_QUALITY_MEDIUM
	lm.bounces=2
	lm.directional=false
	lm.generate_probes_subdiv=LightmapGI.GENERATE_PROBES_SUBDIV_8
	lm.environment_mode=LightmapGI.ENVIRONMENT_MODE_CUSTOM_COLOR
	# Reuse the Main Hall's cool diffuse fill rather than adding another amber cast.
	lm.environment_custom_color=Color("cbd4e1")
	lm.environment_custom_energy=.22
	room.add_child(lm)
	lm.owner=room
	for z in [-6.5,-4,-2,0,3,6,9,12,15,18]:
		for x in ([-2,.0,2] if z>=0 else [-2,.0,2,5] if z==-2 else [-2,.0,2]):
			for y in [.3,1.1,2]:
				var probe:=LightmapProbe.new()
				probe.position=corrected(Vector3(x,y,z))
				room.add_child(probe)
				probe.owner=room
	for position in [Vector3(-.55,1.1,22),Vector3(2,1.1,22.5),Vector3(3.1,1.1,22.5),Vector3(5.55,1.1,20),Vector3(5.55,1.1,24),Vector3(10.8,1.1,22),Vector3(5.55,1.1,18),Vector3(12.2,1.1,22.515),Vector3(6.5,1.1,-2),Vector3(10.5,1.1,-2),Vector3(13.5,1.1,-2),Vector3(16.5,1.1,-2)]:
		var probe:=LightmapProbe.new()
		probe.position=corrected(position)
		room.add_child(probe)
		probe.owner=room
	var packed:=PackedScene.new()
	assert(packed.pack(room)==OK)
	assert(ResourceSaver.save(packed,"res://modules/shell/prototype/gallery_walk4/baked/room.tscn")==OK)
	walk.queue_free()
	room.free()
	await process_frame
	print("BAKE_PREPARE surfaces=",index)
	quit()

func corrected(p:Vector3) -> Vector3:
	if p.z>16:
		return p+Vector3(-1.95 if p.x<3.4 else -.95 if p.x>11.5 else 0,0,9.25)
	# Grey register: grey fill follows the shorter room's centre (-2 to -1.2), the connector its new
	# axis (-2 to .58), and Rockefeller with the gallery's door end moves 2.2m as in remodel_room.gd.
	# Hall reveal: the three rooms north of the thick wall go north by its thickness as well.
	var reveal:float=JSON.parse_string(FileAccess.get_file_as_string("res://geometry.json")).hall_reveal.wall_m
	if p.x>=8.45:return p+Vector3(-4.6,0,.8-reveal)
	if p.x>3.65:return Vector3(1.7+(p.x-3.65)*2.15/4.8,p.y,p.z+2.58-reveal)
	return p+Vector3(-1.95,0,(2.2 if p.z<1.0 else 0.0)-(reveal if p.z<-.4 else 0.0))
