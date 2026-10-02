## Collection extension trial: keep the actual main-build Hall and its saved bake.
extends "remodel_room.gd"

func stone_asset(kind:String,at:Vector3,yaw:float) -> void:
	if kind != "romanesque-portal":super.stone_asset(kind,at,yaw)

func build_connected_hall() -> void:
	var hall:Node3D=load("res://modules/shell/prototype/gallery_walk4/baked/room.tscn").instantiate()
	hall.name="ConnectedHall"
	hall.position=Vector3(5.55,0,28.1)
	hall.set_meta("painting_lights",[])
	add_child(hall)
	var meshes:=hall.find_children("*","MeshInstance3D",true,false)
	assert(meshes.size()==139,"Retained Hall fixture changed; review its attachment before using it")
	# Only the adjoining placeholder room is hidden. Hall and stone portal stay intact.
	var placeholders:=["Surface006","Surface007","Surface008","Surface009","Surface010","Surface011"]
	for mesh in meshes:
		mesh.set_meta("retained_main_hall",true)
		mesh.layers=1
		# Native plank UVs stay unchanged; only their world-space clipping planes move.
		if mesh.material_override is ShaderMaterial and mesh.material_override.shader.resource_path.ends_with("/floor_oak.gdshader"):
			mesh.material_override=mesh.material_override.duplicate()
			mesh.material_override.set_shader_parameter("floor_z_limits",Vector2(1.8,28.1))
		if str(mesh.name) in placeholders:
			mesh.hide()
		elif mesh.mesh.get_aabb().position.y>5.4:
			ceiling_details.append(mesh)
	assert(hall.get_node("Surface004").visible and hall.get_node("Surface005").visible)
	# Remove the extension's duplicate Hall surfaces while retaining its wall collisions.
	for casing in casings:
		var wall:String=casing.get_meta("room_wall","")
		if wall.begins_with("Grand Gallery:"):
			for visual in casing.find_children("*","MeshInstance3D",true,false):
				visual.mesh=ArrayMesh.new()
	for mesh in find_children("*","MeshInstance3D",true,false):
		if mesh.has_meta("retained_main_hall") or mesh.get_parent() is StaticBody3D:continue
		var bounds:AABB=mesh.global_transform*mesh.mesh.get_aabb()
		if bounds.end.y<.02 and bounds.position.x>=.549 and bounds.end.x<=10.551 and bounds.position.z>=1.799 and bounds.end.z<=28.101:
			mesh.mesh=ArrayMesh.new()
	# Physical guards follow the retained portal's solid sides, rather than its outer box.
	# Their depth is read from the retained stone, so it follows walk4's PORTAL_DEPTH.
	var portal:MeshInstance3D=hall.get_node("Surface004")
	var stone:AABB=portal.transform*portal.get_aabb()
	for side in [-1,1]:
		var guard:=solid(Vector3(5.55+side*1.52,1.5,hall.position.z+stone.get_center().z),Vector3(1.14,3.0,stone.size.z),look(Color.WHITE),true)
		guard.get_child(1).mesh=ArrayMesh.new()
	for z in [11.1,19.1]:
		var bench:=solid(Vector3(5.55,.23,z),Vector3(.95,.46,3),look(Color.WHITE),true)
		bench.get_child(1).mesh=ArrayMesh.new()
	inventory["main_hall_verified_paintings"]=23
	inventory["main_hall_rebuilt"]=false
	inventory["main_hall_native_meshes_retained"]=133
	inventory["main_hall_placeholder_meshes_hidden"]=placeholders
	inventory["connected_museum_loop"]=true
	inventory["museum_metric_accepted"]=false
