## Main Hall native UV2 / LightmapGI recipe applied to the new authored room only.
extends SceneTree

func _initialize() -> void:
	call_deferred("prepare")

func prepare() -> void:
	var walk=load("res://remodel_room.tscn").instantiate()
	root.add_child(walk)
	await process_frame
	walk.set_physics_process(false)
	var room:=Node3D.new()
	room.name="BakedRoom"
	var index:=0
	var floors:=SurfaceTool.new()
	var floor_names:=[]
	var floor_material:Material
	for source in walk.find_children("*","MeshInstance3D",true,false):
		if walk.visitor.is_ancestor_of(source) or source.has_meta("contact_shadow") or not source.is_visible_in_tree():continue
		if source.material_override is StandardMaterial3D and source.material_override.transparency==BaseMaterial3D.TRANSPARENCY_ALPHA:continue
		if source.material_override is ShaderMaterial and source.material_override.shader.resource_path.ends_with("floor_oak.gdshader"):
			floors.append_from(source.mesh,0,source.global_transform)
			floor_names.append(source.name)
			floor_material=source.material_override
			continue
		var st:=SurfaceTool.new()
		for surface in source.mesh.get_surface_count():st.append_from(source.mesh,surface,Transform3D.IDENTITY)
		var mesh:=st.commit()
		var result:=mesh.lightmap_unwrap(source.global_transform,.14)
		assert(result==OK,"Native UV2 unwrap failed")
		var instance:=MeshInstance3D.new()
		instance.name="Surface%03d"%index
		instance.mesh=mesh
		instance.material_override=source.material_override
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
	for position in [Vector3(.45,3.25,-5.5),Vector3(.45,3.25,-2),Vector3(4.6,3.25,-2),Vector3(-.55,3.25,2),Vector3(-.55,3.25,6),Vector3(-.55,3.25,10),Vector3(-.55,3.25,14),Vector3(-.55,3.25,17),Vector3(-.55,3.25,22),Vector3(7,4.0,21),Vector3(7,4.0,24),Vector3(12.2,3.25,20.8)]:
		var light:=OmniLight3D.new()
		light.position=position
		light.omni_range=8
		light.omni_attenuation=.65
		light.light_energy=.55
		light.light_color=Color("ffe1b2")
		light.light_size=2.5
		light.light_bake_mode=Light3D.BAKE_STATIC
		light.shadow_enabled=true
		room.add_child(light)
		light.owner=room
	# Latest Main Hall's offline painting spots, placed below this room's lower ceiling.
	for spec in [[Vector3(.55,2.43,-7.02),Vector3.BACK],[Vector3(-1.05,2.15,-7),Vector3.BACK],[Vector3(2.25,2.15,-7),Vector3.BACK],[Vector3(-2.67,2,-4.7),Vector3.RIGHT],[Vector3(-3.48,1.75,2.15),Vector3.RIGHT]]:
		var spot:=SpotLight3D.new()
		room.add_child(spot)
		spot.owner=room
		spot.position=spec[0]+spec[1]*2.2
		spot.position.y=3.2
		spot.look_at_from_position(spot.position,spec[0],Vector3.UP)
		spot.spot_range=7
		spot.spot_angle=25
		spot.spot_angle_attenuation=1.5
		spot.light_color=Color("ffd391")
		spot.light_energy=6.8
		spot.light_size=.35
		spot.light_bake_mode=Light3D.BAKE_STATIC
		spot.shadow_enabled=true

	var daylight:=DirectionalLight3D.new()
	daylight.rotation_degrees=Vector3(-60,-75,0)
	daylight.light_color=Color("eff5ff")
	daylight.light_energy=.35
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
	lm.environment_custom_color=Color("dfd6c7")
	lm.environment_custom_energy=.18
	room.add_child(lm)
	lm.owner=room
	for z in [-6.5,-4,-2,0,3,6,9,12,15,18]:
		for x in ([-2,.0,2] if z>=0 else [-2,.0,2,5] if z==-2 else [-2,.0,2]):
			for y in [.3,1.1,2]:
				var probe:=LightmapProbe.new()
				probe.position=Vector3(x,y,z)
				room.add_child(probe)
				probe.owner=room
	for position in [Vector3(-.55,1.1,22),Vector3(2,1.1,22.5),Vector3(3.1,1.1,22.5),Vector3(5.55,1.1,20),Vector3(5.55,1.1,24),Vector3(10.8,1.1,22),Vector3(5.55,1.1,18),Vector3(12.2,1.1,20.8)]:
		var probe:=LightmapProbe.new()
		probe.position=position
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
