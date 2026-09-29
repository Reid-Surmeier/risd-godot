## Private depth/occlusion diagnostic. Temporary flat ID material preserves
## every triangle and depth buffer; normal-material screenshots remain required.
extends RefCounted
static func sample(walk: Control) -> Dictionary:
	var replacements := {}
	var marker := StandardMaterial3D.new()
	marker.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	marker.albedo_color = Color(1, 0, 1)
	for mesh in walk._vp.find_children("*", "MeshInstance3D", true, false):
		var bounds: AABB = mesh.global_transform * mesh.mesh.get_aabb()
		if mesh.is_visible_in_tree() and bounds.position.z >= -0.01 and bounds.end.z > 1.0 and bounds.size.y < 0.01 and absf(bounds.position.y) < 0.01:
			replacements[mesh] = mesh.material_override
			mesh.material_override = marker
	var kid_visible: bool = walk._kid.visible
	walk._kid.hide()
	await walk.get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image: Image = walk._vp.get_texture().get_image()
	var clear := 0
	for x in [-0.5, 0.0, 0.5]:
		for z in [0.15, 0.22, 0.32]:
			var pixel := Vector2i(walk._cam.unproject_position(Vector3(x, -0.002, z)))
			if Rect2i(Vector2i.ZERO, image.get_size()).has_point(pixel):
				var color := image.get_pixelv(pixel)
				if color.r > 0.8 and color.b > 0.8 and color.g < 0.2:
					clear += 1
	for mesh in replacements:
		mesh.material_override = replacements[mesh]
	walk._kid.visible = kid_visible
	await walk.get_tree().process_frame
	await RenderingServer.frame_post_draw
	return {"clear": clear, "meshes": replacements.size(), "image": image}
