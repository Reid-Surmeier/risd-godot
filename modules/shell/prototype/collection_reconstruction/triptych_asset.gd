## RISD2021.131: authentic front/rear photographs on three closed gabled panels.
## ponytail: source-projected panel proportions, .018m depth and .20rad wing angles are provisional.
extends RefCounted
const Painting := preload("res://modules/shell/prototype/gallery_walk4/painting_asset.gd")

static func build() -> Node3D:
	var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/triptych-2021131-geometry.json"))
	var group:=Node3D.new()
	group.name="Triptych2021_131"
	group.set_meta("catalogue_accession","2021.131")
	group.set_meta("source_rear_observed",true)
	for flag in ["placement_accepted","metric_accepted","fine_fidelity_accepted"]:
		group.set_meta(flag,false)
	for spec in data.panels:
		var piece:=Painting.new()
		group.add_child(piece)
		var size:=Vector2(spec.size_m[0],spec.size_m[1])
		piece.build_shaped(load("res://assets/"+spec.front),size,spec.outline,Color("a27639"))
		# The shared painting helper supplies the front and edges. Close it with the observed rear.
		var st:=SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var faces:PackedVector3Array=piece.get_child(0).mesh.get_faces()
		for i in range(0,faces.size(),3):
			st.set_normal(Vector3.FORWARD)
			for k in [0,2,1]:
				var p:Vector3=faces[i+k]
				st.set_uv(Vector2(.5-p.x/size.x,.5-p.y/size.y))
				st.add_vertex(Vector3(p.x,p.y,0))
		var rear:=MeshInstance3D.new()
		rear.mesh=st.commit()
		rear.material_override=Painting.mat(load("res://assets/"+spec.back))
		piece.add_child(rear)
		piece.scale.z=float(data.depth_m_provisional)/.05
		piece.position=Vector3(spec.centre_x_m,spec.base_y_m+size.y/2,.07)
		piece.rotation.y=.20 if spec.id=="left" else -.20 if spec.id=="right" else 0.0
		piece.set_meta("triptych_panel",spec.id)
	return group
