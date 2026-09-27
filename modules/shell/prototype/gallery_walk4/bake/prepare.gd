## Offline authoring only: save the exact static room, with unique lighting UVs.
extends SceneTree

const DIR := "res://modules/shell/prototype/gallery_walk4/"

func _initialize() -> void:
	call_deferred("_prepare")

func _prepare() -> void:
	var walk = load(DIR + "walk4.gd").new()
	root.add_child(walk)
	await process_frame
	walk.set_process(false)
	var room := Node3D.new()
	room.name = "BakedRoom"
	root.add_child(room)
	var index := 0
	for source in walk._vp.find_children("*", "MeshInstance3D", true, false):
		if source.get_parent().name == "BakedRoom":
			continue
		var original = source.material_override
		if not original is ShaderMaterial:
			continue  # old shadow cards and lamp pools must not be lit twice
		var mesh := ArrayMesh.new()
		var floor_mesh: bool = original.get_shader_parameter("plank_seams") == true
		for surface in source.mesh.get_surface_count():
			var arrays = source.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL] if arrays[Mesh.ARRAY_NORMAL] != null else PackedVector3Array()
			if normals.is_empty():
				var builder := SurfaceTool.new()
				builder.create_from(source.mesh, surface)
				builder.generate_normals()
				arrays = builder.commit().surface_get_arrays(0)
			var colors: PackedColorArray = arrays[Mesh.ARRAY_COLOR] if arrays[Mesh.ARRAY_COLOR] != null else PackedColorArray()
			var uv2 := PackedVector2Array()
			if floor_mesh:
				for i in vertices.size():
					var world: Vector3 = source.global_transform * vertices[i]
					uv2.append(Vector2((world.x + 5.5) / 11.0, (0.5 - world.z) / 27.3))
					if not colors.is_empty():
						colors[i] /= maxf(walk._ao(world, false), 0.01)
				arrays[Mesh.ARRAY_TEX_UV2] = uv2
			elif not colors.is_empty():
				# Keep intrinsic material colour; drop the old room-light multiplier.
				for i in colors.size():
					colors[i] = Color.WHITE
			arrays[Mesh.ARRAY_COLOR] = colors if not colors.is_empty() else null
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		if floor_mesh:
			mesh.lightmap_size_hint = Vector2i(512, 1024)
		else:
			var error := mesh.lightmap_unwrap(source.global_transform, 0.12)
			if error != OK:
				push_error("UV unwrap failed for " + str(index))
				quit(1)
				return
		var material := StandardMaterial3D.new()
		material.albedo_color = original.get_shader_parameter("tint") if original.get_shader_parameter("tint") != null else Color.WHITE
		material.albedo_texture = original.get_shader_parameter("albedo")
		var uv_scale = original.get_shader_parameter("uv_scale")
		if uv_scale != null:
			material.uv1_scale = Vector3(uv_scale.x, uv_scale.y, 1)
		material.vertex_color_use_as_albedo = floor_mesh
		material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
		material.disable_ambient_light = false  # Compatibility gates lightmaps with ambient lighting
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		if original.get_shader_parameter("alpha_cut") != null and original.get_shader_parameter("alpha_cut") > 0:
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
			material.alpha_scissor_threshold = original.get_shader_parameter("alpha_cut")
		# Preserve artwork/painted frame colours; they still occlude the surrounding light.
		if material.albedo_texture and not "/textures/" in material.albedo_texture.resource_path:
			material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		if source.layers == 32:
			material.albedo_color = Color("#e2dccd")
		var instance := MeshInstance3D.new()
		instance.name = "Surface%03d" % index
		instance.mesh = mesh
		instance.material_override = material
		if floor_mesh:
			var oak := ShaderMaterial.new()
			oak.shader = load(DIR + "oak.gdshader")
			oak.set_shader_parameter("oak", material.albedo_texture)
			instance.material_override = oak
		instance.transform = source.global_transform
		instance.layers = source.layers
		instance.gi_mode = GeometryInstance3D.GI_MODE_STATIC
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
		if material.albedo_texture and material.albedo_texture.resource_path.ends_with("/skylight.png"):
			instance.gi_mode = GeometryInstance3D.GI_MODE_DISABLED  # omit glazing from bake ray geometry
			material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		room.add_child(instance)
		instance.owner = room
		index += 1
	for z in [-3.0, -8.0, -13.0, -18.0, -23.0]:
		var light := OmniLight3D.new()
		light.position = Vector3(0, 5.7, z)
		light.omni_range = 13.0
		light.omni_attenuation = 0.65
		light.light_energy = 0.4
		light.light_color = Color("#fff1d9")
		light.light_size = 2.5
		light.light_bake_mode = Light3D.BAKE_STATIC
		light.shadow_enabled = true
		room.add_child(light)
		light.owner = room
	# Offline spotlights: local warm pools around the paintings, retained in the lightmap.
	for painting in walk._paintings:
		var spot := SpotLight3D.new()
		room.add_child(spot)
		spot.owner = room
		spot.position = painting.center + painting.normal * 2.2 + Vector3.UP * 3.1
		spot.look_at(painting.center, Vector3.UP)
		spot.spot_range = 7.0
		spot.spot_angle = 25.0
		spot.spot_angle_attenuation = 1.5
		spot.light_color = Color("#ffd391")
		spot.light_energy = 6.0
		spot.light_size = 0.35
		spot.light_bake_mode = Light3D.BAKE_STATIC
		spot.shadow_enabled = true
	var daylight := DirectionalLight3D.new()
	daylight.rotation_degrees = Vector3(-60, -75, 0)  # across the gallery, avoiding a hard far-lunette shadow
	daylight.light_color = Color("#eff5ff")
	daylight.light_energy = 0.8
	daylight.light_angular_distance = 6.0
	daylight.light_bake_mode = Light3D.BAKE_STATIC
	daylight.shadow_enabled = true
	room.add_child(daylight)
	daylight.owner = room
	var lm := LightmapGI.new()
	lm.name = "Lightmap"
	lm.quality = LightmapGI.BAKE_QUALITY_MEDIUM
	lm.bounces = 2
	lm.directional = false
	lm.generate_probes_subdiv = LightmapGI.GENERATE_PROBES_SUBDIV_8
	# Dynamic visitor captures are sampled near body height. Manual probes keep
	# walkable edges/thresholds represented without increasing the whole grid.
	for z in [0.1, -0.7, -3.0, -8.0, -13.0, -18.0, -23.0, -26.4]:
		for x in [-4.2, -2.0, 0.0, 2.0, 4.2]:
			for y in [0.3, 1.1, 2.0]:
				var probe := LightmapProbe.new()
				probe.position = Vector3(x, y, z)
				room.add_child(probe)
				probe.owner = room
	lm.environment_mode = LightmapGI.ENVIRONMENT_MODE_CUSTOM_COLOR
	lm.environment_custom_color = Color("#cbd4e1")
	lm.environment_custom_energy = 0.22
	room.add_child(lm)
	lm.owner = room
	var scene := PackedScene.new()
	scene.pack(room)
	var error := ResourceSaver.save(scene, DIR + "baked/room.tscn")
	print("BAKE_PREPARE surfaces=", index, " result=", error)
	quit(0 if error == OK else 1)
