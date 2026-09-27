## Same white navigation geometry, offline only. Keep its capture separate from gallery.
extends SceneTree
const DIR := "res://modules/shell/prototype/gallery_walk4/"
func _initialize() -> void:
	call_deferred("prepare")
func prepare() -> void:
	var walk = load(DIR + "walk4.gd").new()
	root.add_child(walk)
	await process_frame
	walk.set_process(false)
	var room := Node3D.new()
	room.name = "WhiteCapture"
	root.add_child(room)
	var index := 0
	for source in walk._vp.find_children("*", "MeshInstance3D", true, false):
		if source.layers < 64 or source.layers > 1024:
			continue
		var builder := SurfaceTool.new()
		for surface in source.mesh.get_surface_count():
			builder.append_from(source.mesh, surface, source.global_transform)
		var mesh := builder.commit()
		if mesh.lightmap_unwrap(Transform3D.IDENTITY, 0.4) != OK:
			quit(1)
			return
		var instance := MeshInstance3D.new()
		instance.name = "White%02d" % index
		instance.mesh = mesh
		instance.gi_mode = GeometryInstance3D.GI_MODE_STATIC
		var material: StandardMaterial3D = source.material_override.duplicate()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
		instance.material_override = material
		room.add_child(instance)
		instance.owner = room
		index += 1
	var lm := LightmapGI.new()
	lm.name = "Lightmap"
	lm.generate_probes_subdiv = LightmapGI.GENERATE_PROBES_SUBDIV_4
	lm.quality = LightmapGI.BAKE_QUALITY_MEDIUM
	lm.directional = false
	lm.bounces = 2
	lm.environment_mode = LightmapGI.ENVIRONMENT_MODE_CUSTOM_COLOR
	lm.environment_custom_color = Color("#f2f2ea")
	lm.environment_custom_energy = 0.6
	room.add_child(lm)
	lm.owner = room
	for x in [-2.5, 0, 2.5]:
		for z in [-0.2, -3.0, -5.6]:
			for y in [0.2, 1.0, 2.0]:
				var probe := LightmapProbe.new()
				probe.position = Vector3(x, y, z)
				room.add_child(probe)
				probe.owner = room
	var packed := PackedScene.new()
	packed.pack(room)
	var result := ResourceSaver.save(packed, DIR + "baked/white.tscn")
	print("WHITE_PREPARE users=",index," result=",result)
	quit(0 if result == OK else 1)
