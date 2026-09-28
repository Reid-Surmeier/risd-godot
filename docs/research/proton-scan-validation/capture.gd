extends SceneTree

# Scratch evidence harness for #154. Run from the repository root with Godot 4.7.2.
var output := "res://docs/research/proton-scan-validation/godot-captures"
const INGEST := "/home/reidsurmeier/risd-godot-ingestion/proton"
const SCANS := {
	"buddha": "res://modules/sculpture_viewer/assets/models/proton-buddha-3124123123.glb",
	"20260811121459": INGEST + "/20260811121459/candidate-120k-rerun/proton-scan-20260811121459.glb",
	"20260811122415": INGEST + "/20260811122415/candidate-120k/proton-scan-20260811122415.glb",
	"20260811123051": INGEST + "/20260811123051/candidate-120k/proton-scan-20260811123051.glb",
	"20260820133334": INGEST + "/20260820133334/prototype/proton-scan-20260820133334.glb",
}
const FRONT := {"buddha": 0.0, "20260811121459": 0.0, "20260811122415": 180.0, "20260811123051": 180.0, "20260820133334": 180.0}

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var neutral := "--neutral" in OS.get_cmdline_user_args()
	var opaque := "--opaque" in OS.get_cmdline_user_args()
	var group_trial := "--group-trial" in OS.get_cmdline_user_args()
	var relief_trial := "--relief-seam-trial" in OS.get_cmdline_user_args()
	var relief_source := "--relief-source" in OS.get_cmdline_user_args()
	if relief_trial or relief_source:
		output = "res://docs/research/proton-scan-validation/relief-%s-captures" % ("source" if relief_source else "seam-trial")
	elif neutral:
		output = "res://docs/research/proton-scan-validation/neutral-captures"
	elif opaque:
		output = "res://docs/research/proton-scan-validation/opaque-captures"
	elif group_trial:
		output = "res://docs/research/proton-scan-validation/group-base-trial-captures"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	root.size = Vector2i(768, 768)
	var stage := Node3D.new()
	root.add_child(stage)
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#f8f8fa")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#d9e1e7")
	env.ambient_light_energy = 0.82
	var world := WorldEnvironment.new()
	world.environment = env
	stage.add_child(world)
	var key := DirectionalLight3D.new()
	key.light_color = Color.WHITE
	key.light_energy = 1.15
	key.rotation_degrees = Vector3(-42, -28, 0)
	key.shadow_enabled = true
	key.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	stage.add_child(key)
	var fill := OmniLight3D.new()
	fill.position = Vector3(-3.5, 2.5, 4)
	fill.light_color = Color("#dcebf4")
	fill.light_energy = 0.52
	fill.omni_range = 10.0
	stage.add_child(fill)
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(7, 7)
	var floor := MeshInstance3D.new()
	floor.mesh = floor_mesh
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = Color("#f7f7f9")
	floor_mat.roughness = 0.9
	floor.material_override = floor_mat
	stage.add_child(floor)
	var camera := Camera3D.new()
	camera.fov = 36.0
	stage.add_child(camera)
	camera.current = true
	for id in SCANS:
		if (relief_trial or relief_source) and id != "20260811122415":
			continue
		if group_trial and id != "20260811121459":
			continue
		if (neutral or opaque) and id not in ["20260811123051", "20260820133334"]:
			continue
		var state := GLTFState.new()
		var doc := GLTFDocument.new()
		var source: String = "/tmp/risd-scan-154/group-without-flat-underside.glb" if group_trial else SCANS[id]
		if relief_trial or relief_source:
			source = "/tmp/risd-scan-154-relief-seams/%s.glb" % ("source" if relief_source else "candidate")
		var err := doc.append_from_file(source, state)
		if err != OK:
			push_error("GLB load failed %s: %s" % [id, err])
			quit(1)
			return
		var model := doc.generate_scene(state)
		if model == null:
			push_error("Scene generation failed: " + id)
			quit(1)
			return
		stage.add_child(model)
		if opaque:
			_opaque_material(model)
		if neutral:
			var clay := StandardMaterial3D.new()
			clay.albedo_color = Color("#999999")
			clay.roughness = 1.0
			clay.cull_mode = BaseMaterial3D.CULL_DISABLED
			_override_material(model, clay)
		if id == "buddha":
			var texture := load("res://modules/sculpture_viewer/assets/models/3124123123.jpg") as Texture2D
			var gold := StandardMaterial3D.new()
			gold.albedo_texture = texture
			gold.metallic = 0.32
			gold.metallic_specular = 0.64
			gold.roughness = 0.38
			_override_material(model, gold)
		var bounds := _bounds(model, Transform3D.IDENTITY)
		var scale_factor := 4.5 / maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
		model.scale = Vector3.ONE * scale_factor
		model.position = Vector3(-bounds.get_center().x, -bounds.position.y, -bounds.get_center().z) * scale_factor
		var height := bounds.size.y * scale_factor
		print("MODEL %s bounds=%s scale=%.6f normalized_height=%.4f" % [id, bounds, scale_factor, height])
		var target := Vector3(0, height * 0.5, 0)
		var angles := [0.0, 90.0, 180.0, 270.0]
		if relief_trial or relief_source:
			angles = [0.0, 30.0, 60.0, 90.0, 120.0, 150.0, 180.0, 210.0, 240.0, 270.0, 300.0, 330.0]
		for yaw in angles:
			await _capture(camera, target, yaw, 8.7, "%s-%03d" % [id, int(yaw)])
		await _capture(camera, target, FRONT[id], 8.7, "%s-front" % id)
		await _capture(camera, target, FRONT[id], 5.2, "%s-detail" % id)
		if id == "20260811122415" or id == "20260820133334":
			for yaw in [255.0, 285.0]:
				await _capture(camera, target, yaw, 8.7, "%s-%03d" % [id, int(yaw)])
		model.queue_free()
		await process_frame
	quit()

func _capture(camera: Camera3D, target: Vector3, yaw_degrees: float, distance: float, filename: String) -> void:
	var yaw := deg_to_rad(yaw_degrees)
	var pitch := deg_to_rad(-8.0)
	camera.position = target + Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * distance
	camera.look_at(target)
	for i in 4:
		await process_frame
	await RenderingServer.frame_post_draw
	var path := ProjectSettings.globalize_path(output.path_join(filename + ".png"))
	var err := root.get_texture().get_image().save_png(path)
	if err != OK:
		push_error("Screenshot failed: " + path)
	else:
		print("CAPTURE " + path)

func _bounds(node: Node, transform: Transform3D) -> AABB:
	var total := AABB()
	var found := false
	if node is MeshInstance3D:
		total = transform * (node as MeshInstance3D).get_aabb()
		found = true
	for child in node.get_children():
		var child_transform := transform
		if child is Node3D:
			child_transform = transform * (child as Node3D).transform
		var part := _bounds(child, child_transform)
		if part.size != Vector3.ZERO:
			total = total.merge(part) if found else part
			found = true
	return total

func _override_material(node: Node, material: StandardMaterial3D) -> void:
	if node is MeshInstance3D:
		(node as MeshInstance3D).material_override = material
	for child in node.get_children():
		_override_material(child, material)

func _opaque_material(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh := node as MeshInstance3D
		var original := mesh.get_active_material(0) as StandardMaterial3D
		assert(original != null and original.albedo_texture != null)
		var material := StandardMaterial3D.new()
		material.albedo_texture = original.albedo_texture
		material.roughness = 1.0
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		mesh.material_override = material
	for child in node.get_children():
		_opaque_material(child)
