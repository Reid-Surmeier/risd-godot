## Review-only script. Copy to the one --draft extension as vessel_capture.gd.
## Copy the unchanged accepted character package to the draft for scale pictures.
extends SceneTree

var scene: Node3D
var out_dir: String


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	out_dir = "res://evidence/vessels"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out-dir="):
			out_dir = arg.trim_prefix("--out-dir=")
	DirAccess.make_dir_recursive_absolute(out_dir)
	root.size = Vector2i(960, 760)
	scene = load("res://remodel_room.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.set_physics_process(false)
	scene.label.hide()
	scene.contact_shadow.hide()
	scene.visitor.hide()
	var visitor = load("res://modules/shell/character/visitor.gd").new()
	visitor.world_height = 1.75
	scene.add_child(visitor)
	visitor.set_physics_process(false)
	visitor.set_process(false)
	for i in 20:
		await process_frame
	for casing in scene.casings:
		casing.get_child(1).show()
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/additions/vessels-turned/profiles.json"))
	var catalogue: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/catalogue-objects.json"))
	var measurements: Array = []
	for work in data.works:
		var vessel: Node3D
		for node in scene.get_children():
			if node.get_meta("catalogue_asset", "") == work.asset:
				vessel = node
		assert(vessel != null and vessel.get_meta("turned_profile", false))
		var box := bounds(vessel)
		var actual := local_bounds(vessel)
		var expected := Vector3(work.size_m[0], work.size_m[1], work.size_m[2])
		assert(actual.size.distance_to(expected) < .0001, "Catalogue size differs: " + work.asset)
		var old := old_blob(catalogue.meshes[work.asset], load("res://assets/" + work.asset + "-volume.png"))
		scene.add_child(old)
		# Recreate the original transform from its records and the existing room shifts.
		var placement: Dictionary
		for row in catalogue.instances:
			if row.asset == work.asset:
				placement = row
		old.position = Vector3(placement.position[0], placement.position[1], placement.position[2])
		old.position.x -= 1.95
		if old.position.z < 1.0:
			old.position.z += 2.2
		if old.position.z < 1.8:
			old.position.z -= scene.hall_reveal.wall_m
		old.rotation = Vector3(placement.get("pitch", 0.0), placement.get("yaw", 0.0), 0)
		assert(old.global_transform.is_equal_approx(vessel.global_transform), "A vessel's placement may not change")
		old.hide()
		var old_actual := old.mesh.get_aabb()
		measurements.append({"asset": work.asset, "origin_m": [vessel.position.x, vessel.position.y, vessel.position.z],
			"catalogue_size_m": work.size_m, "measured_local_size_m": [actual.size.x, actual.size.y, actual.size.z],
			"old_size_m": catalogue.meshes[work.asset].size_m,
			"old_measured_local_size_m": [old_actual.size.x, old_actual.size.y, old_actual.size.z],
			"rotation_radians": [vessel.rotation.x, vessel.rotation.y, vessel.rotation.z],
			"placement_equals_old": true, "parts": vessel.get_child_count()})
		var face := vessel.global_transform.basis.z.normalized()
		var right := vessel.global_transform.basis.x.normalized()
		var target := box.get_center()
		visitor.position = vessel.position + face * .65 - right * .78
		visitor.position.y = .13
		visitor.pose(0.0, false, 0.0, face, 0.0)
		# The close pair uses the same lens, target and eye for both geometries.
		for view in [["front", face], ["three-quarter", (face * .83 - right * .56).normalized()]]:
			var distance: float = maxf(expected.x, expected.y) * 2.25
			var elevation := .10
			if work.asset in ["gold-cup-a", "gold-cup-b", "pink-compote", "gold-ecuelle-clean"]:
				elevation = .35
			# Look over the neighbouring cup, without moving any displayed work.
			if work.asset == "gold-ecuelle-clean" and view[0] == "three-quarter":
				view[1] = (face * .83 + right * .56).normalized()
			scene.camera.fov = 36
			scene.camera.position = target + view[1] * distance + Vector3(0, distance * elevation, 0)
			# The unchanged ladle pitch presents its front upward, so its own Y
			# is the camera-up direction instead of the collinear room Y.
			var up := vessel.global_transform.basis.y.normalized() if work.asset == "pink-ladle" else Vector3.UP
			scene.camera.look_at(target, up)
			await take(work.asset + "-" + view[0] + "-after")
			vessel.hide()
			old.show()
			await take(work.asset + "-" + view[0] + "-before")
			old.hide()
			vessel.show()
		if work.asset == "tureen":
			var middle: Vector3 = (visitor.position + Vector3(0, .86, 0) + target) / 2
			scene.camera.fov = 42
			scene.camera.position = middle + face * 3.5 + Vector3(0, .25, 0)
			scene.camera.look_at(middle)
			await take(work.asset + "-visitor-after")
			vessel.hide()
			old.show()
			await take(work.asset + "-visitor-before")
			old.hide()
			vessel.show()
		old.free()
	var file := FileAccess.open(out_dir.path_join("measurements.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(measurements, "\t") + "\n")
	print("VESSEL_CAPTURE ", JSON.stringify({"works": measurements.size(), "measurements": measurements, "baked": false}))
	quit()


func take(label: String) -> void:
	scene.update_baked_visibility()
	for i in 3:
		await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(out_dir.path_join(label + ".png")) == OK)


func bounds(node: Node3D) -> AABB:
	var box := AABB()
	var first := true
	for part in node.get_children():
		var reach: AABB = part.global_transform * part.mesh.get_aabb()
		box = reach if first else box.merge(reach)
		first = false
	return box


func local_bounds(node: Node3D) -> AABB:
	var box := AABB()
	var first := true
	for part in node.get_children():
		var reach: AABB = part.transform * part.mesh.get_aabb()
		box = reach if first else box.merge(reach)
		first = false
	return box


func old_blob(asset: Dictionary, texture: Texture2D) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for face in asset.triangles:
		var a := Vector3(asset.vertices[face[0]][0], asset.vertices[face[0]][1], asset.vertices[face[0]][2])
		var b := Vector3(asset.vertices[face[1]][0], asset.vertices[face[1]][1], asset.vertices[face[1]][2])
		var c := Vector3(asset.vertices[face[2]][0], asset.vertices[face[2]][1], asset.vertices[face[2]][2])
		st.set_normal((b - a).cross(c - a).normalized())
		for i in face:
			st.set_uv(Vector2(asset.uv[i][0], asset.uv[i][1]))
			st.add_vertex(Vector3(asset.vertices[i][0], asset.vertices[i][1], asset.vertices[i][2]))
	var mesh := MeshInstance3D.new()
	mesh.mesh = st.commit()
	mesh.material_override = load("res://modules/shell/prototype/gallery_walk4/painting_asset.gd").mat(texture, 1.0, true)
	return mesh
