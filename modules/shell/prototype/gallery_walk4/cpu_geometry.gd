## Private #281 build helper. Procedural arrays stay on the CPU; native primitives
## use prepare_cpu_geometry.gd's exact source arrays rather than renderer reads.
extends RefCounted


static func primitive_key(mesh: PrimitiveMesh) -> String:
	var values := [mesh.get_class()]
	for property in mesh.get_property_list():
		var name: String = property.name
		if not (property.usage & PROPERTY_USAGE_STORAGE):
			continue
		if name in ["resource_local_to_scene", "resource_name", "script", "material", "custom_aabb"]:
			continue
		if name.begins_with("metadata/"):
			continue
		values.append([name, mesh.get(name)])
	return var_to_str(values)


static func commit(tool: SurfaceTool) -> ArrayMesh:
	var arrays := tool.commit_to_arrays()
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(tool.get_primitive_type(), arrays)
	mesh.set_meta("cpu_arrays", [arrays])
	return mesh


static func source(mesh: Mesh, surface := 0) -> Array:
	if mesh.has_meta("cpu_arrays"):
		return mesh.get_meta("cpu_arrays")[surface]
	assert(mesh is PrimitiveMesh, "Keep ArrayMesh source arrays before uploading them")
	var native: Resource = load("res://modules/shell/prototype/gallery_walk4/native_cpu_arrays.res")
	var key := primitive_key(mesh)
	assert(native.get_meta("arrays").has(key), "Regenerate native_cpu_arrays.res for this primitive")
	var arrays: Array = native.get_meta("arrays")[key]
	mesh.set_meta("cpu_arrays", [arrays])
	return arrays


## Same transform, missing-channel defaults and index offsets as SurfaceTool.append_from,
## using the retained arrays. The Hall has normals, tangents, colors and two UV channels.
static func append(
	tool: SurfaceTool, arrays: Array, transform: Transform3D, offset: int, channels: Dictionary
) -> int:
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var flip := -1.0 if transform.basis.determinant() < 0 else 1.0
	for vertex in vertices.size():
		if channels.has(Mesh.ARRAY_NORMAL):
			var normal: Vector3 = (
				arrays[Mesh.ARRAY_NORMAL][vertex]
				if arrays[Mesh.ARRAY_NORMAL] != null else Vector3.ZERO
			)
			tool.set_normal(transform.basis * normal)
		if channels.has(Mesh.ARRAY_TANGENT):
			var tangent := Plane(0, 0, 0, 0)
			if arrays[Mesh.ARRAY_TANGENT] != null:
				var values: PackedFloat32Array = arrays[Mesh.ARRAY_TANGENT]
				tangent = Plane(
					Vector3(values[vertex * 4], values[vertex * 4 + 1], values[vertex * 4 + 2]),
					values[vertex * 4 + 3]
				)
			tool.set_tangent(Plane(transform.basis * tangent.normal, tangent.d * flip))
		if channels.has(Mesh.ARRAY_COLOR):
			tool.set_color(
				arrays[Mesh.ARRAY_COLOR][vertex]
				if arrays[Mesh.ARRAY_COLOR] != null else Color(0, 0, 0, 1)
			)
		if channels.has(Mesh.ARRAY_TEX_UV):
			tool.set_uv(
				arrays[Mesh.ARRAY_TEX_UV][vertex] if arrays[Mesh.ARRAY_TEX_UV] != null else Vector2.ZERO
			)
		if channels.has(Mesh.ARRAY_TEX_UV2):
			tool.set_uv2(
				arrays[Mesh.ARRAY_TEX_UV2][vertex] if arrays[Mesh.ARRAY_TEX_UV2] != null else Vector2.ZERO
			)
		tool.add_vertex(transform * vertices[vertex])
	if arrays[Mesh.ARRAY_INDEX] != null:
		for index in arrays[Mesh.ARRAY_INDEX]:
			tool.add_index(offset + index)
	return offset + vertices.size()
