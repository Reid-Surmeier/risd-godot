extends SceneTree
# Photographs one piece in the unbaked draft room project.
# godot --path <draft>/extension --display-driver x11 --rendering-method gl_compatibility \
#   --script draft_shot.gd -- <meta key>[=<value>] <shot> [<shot> ...]
# shot = <out.png>:<camera offset x,y,z>:<aim offset x,y,z>[:<fov>[:<width>x<height>]]
# Offsets are metres from the piece's own origin, in the room's axes.
func _initialize() -> void:
	call_deferred("run")
func v(text: String) -> Vector3:
	var p := text.split_floats(",")
	return Vector3(p[0], p[1], p[2])
func run() -> void:
	var args := OS.get_cmdline_user_args()
	var scene = load("res://remodel_room.tscn").instantiate()
	root.add_child(scene)
	for i in 10:
		await process_frame
	scene.set_physics_process(false) # it would cut walls away for the game's own camera
	for node in scene.find_children("*", "Node3D", true, false):
		node.visible = true
	for node in scene.find_children("*", "CanvasItem", true, false):
		node.visible = false # the draft's own on-screen help
	var want := args[0].split("=")
	var target: Node3D
	for node in scene.find_children("*", "Node3D", true, false):
		if node.has_meta(want[0]) and (want.size() == 1 or str(node.get_meta(want[0])) == want[1]):
			target = node
	for shot in args.slice(1):
		var part: PackedStringArray = shot.split(":")
		var size := Vector2i(540, 960)
		if part.size() > 4:
			size = Vector2i(int(part[4].get_slice("x", 0)), int(part[4].get_slice("x", 1)))
		root.size = size
		scene.camera.fov = float(part[3]) if part.size() > 3 else 70.0
		scene.camera.global_transform = Transform3D(Basis(), target.global_position + v(part[1])).looking_at(target.global_position + v(part[2]), Vector3.UP)
		for i in 6:
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(part[0])
	print("DRAFT_SHOT ", target.global_position)
	quit(0)
