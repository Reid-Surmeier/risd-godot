## Isolated scan study; never loaded by Collection or 3D Viewer.
extends SceneTree
const ROOT := "/home/reidsurmeier/risd-godot-ingestion/collection-expansion/"

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.size = Vector2i(960, 720)
	var trial := "head-surface-v1" if OS.get_cmdline_user_args().is_empty() else OS.get_cmdline_user_args()[0]
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ROOT + trial + "/surface.json"))
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for face in data.triangles:
		for index in face:
			var p: Array = data.vertices[int(index)]
			var uv: Array = data.uv[int(index)]
			st.set_uv(Vector2(uv[0], uv[1]))
			st.add_vertex(Vector3(p[0], p[1], p[2]))
	st.generate_normals()
	var surface := MeshInstance3D.new()
	surface.mesh = st.commit()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_texture = ImageTexture.create_from_image(Image.load_from_file(ROOT + "survey-2fps/IMG_6382/000064.jpg"))
	surface.material_override = material
	root.add_child(surface)
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("30363a")
	root.add_child(environment)
	var camera := Camera3D.new()
	root.add_child(camera)
	camera.current = true
	camera.fov = 45
	for view in [["front", Vector3(0, 0, 1.6)], ["oblique", Vector3(0.75, 0.05, 1.2)]]:
		camera.position = view[1]
		camera.look_at(Vector3.ZERO)
		await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png("res://docs/evidence/collection-reconstruction/" + trial + "-" + view[0] + ".png") == OK)
	print("HEAD_SURFACE_STUDY: %d triangles; cropped front only; rear absent" % data.triangles.size())
	quit()
