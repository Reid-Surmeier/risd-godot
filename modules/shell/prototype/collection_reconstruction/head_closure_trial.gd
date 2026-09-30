## Isolated #183 inferred volume review. Never loaded by Collection or 3D Viewer.
extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var folder := OS.get_cmdline_user_args()[0]
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(folder.path_join("mesh.json")))
	root.size = Vector2i(1000, 800)
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in data.triangles.size():
		for corner in [2, 1, 0]:
			var index: int = data.triangles[i][corner]
			var p: Array = data.vertices[index]
			var uv: Array = data.face_uv[i][corner]
			tool.set_uv(Vector2(uv[0], uv[1]))
			tool.add_vertex(Vector3(p[0], p[1], p[2]))
	tool.generate_normals()
	var sculpture := MeshInstance3D.new()
	sculpture.mesh = tool.commit()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = ImageTexture.create_from_image(Image.load_from_file(folder.path_join("appearance.webp")))
	sculpture.material_override = material
	root.add_child(sculpture)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("30363a")
	root.add_child(environment)
	var layer := CanvasLayer.new()
	root.add_child(layer)
	var label := Label.new()
	label.position = Vector2(20, 18)
	label.add_theme_font_size_override("font_size", 18)
	layer.add_child(label)
	var camera := Camera3D.new()
	root.add_child(camera)
	camera.current = true
	camera.fov = 45
	for view in [["front", Vector3(0, 0, 1.5)], ["oblique", Vector3(.9, .05, 1.2)], ["profile", Vector3(1.5, 0, 0)], ["rear", Vector3(0, 0, -1.5)], ["walking", Vector3(0, 1.0, 3.5)]]:
		label.text = "Head 59.131 · " + view[0] + " · inferred closed volume study\nExisting Muse front/rear appearance. Side, top and underside are inferred.\nCatalogue envelope only; geometry and visual fidelity remain unaccepted."
		camera.position = view[1]
		camera.look_at(Vector3.ZERO)
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(folder.path_join(view[0] + ".png")) == OK)
	print("HEAD_CLOSURE_REVIEW: five views; inferred side volume, not a completed scan")
	quit()
