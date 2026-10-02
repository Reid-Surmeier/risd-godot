extends SceneTree
func _initialize():call_deferred("run")
func run():
	var scene=load("res://remodel_room.tscn").instantiate();root.add_child(scene)
	var floors:=0
	var wrong:=0
	for mesh in scene.find_children("*","MeshInstance3D",true,false):
		if mesh.mesh==null or mesh.has_meta("retained_main_hall"):continue
		var material=mesh.material_override
		if not material is ShaderMaterial or not material.get_shader_parameter("floor_z_limits") is Vector2:continue
		if mesh.mesh.get_surface_count()==0 or mesh.mesh.get_aabb().size.y>.001:continue
		floors+=1
		var normals=mesh.mesh.surface_get_arrays(0)[Mesh.ARRAY_NORMAL]
		for normal in normals:
			if normal.y<.99:wrong+=1
	var report={"floor_meshes":floors,"wrong_floor_normals":wrong,"passed":floors>0 and wrong==0}
	print("FLOOR_NORMAL_CHECK ",JSON.stringify(report));quit(0 if report.passed else 1)
