## Room capture for one builder: godot --path EXT --script capture.gd -- --views=FILE.json --out=DIR
## Each view: {"name":..,"eye":[x,y,z],"at":[x,y,z],"fov":deg, "hide":["room:side",...] (optional wall tags to hide)}
extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var views_path := ""
	var out := ""
	var size := Vector2i(1280, 800)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--views="): views_path = arg.trim_prefix("--views=")
		if arg.begins_with("--out="): out = arg.trim_prefix("--out=")
		if arg.begins_with("--size="):
			var p := arg.trim_prefix("--size=").split("x")
			size = Vector2i(int(p[0]), int(p[1]))
	root.size = size
	var scene = load("res://remodel_room.tscn").instantiate()
	root.add_child(scene)
	for i in 4:
		await physics_frame
	scene.set_physics_process(false)
	scene.visitor.hide()
	if scene.contact_shadow: scene.contact_shadow.hide()
	scene.label.hide()
	DirAccess.make_dir_recursive_absolute(out)
	var views: Array = JSON.parse_string(FileAccess.get_file_as_string(views_path))
	for view in views:
		for casing in scene.casings:
			casing.get_child(1).show()
			for i in range(2, casing.get_child_count()):
				if casing.get_child(i) is Node3D: casing.get_child(i).visible = true
		for tag in view.get("hide", []):
			for casing in scene.casings:
				if str(casing.get_meta("room_wall", "")) == tag or (tag.ends_with("*") and str(casing.get_meta("room_wall", "")).begins_with(tag.trim_suffix("*"))):
					casing.get_child(1).hide()
					for i in range(2, casing.get_child_count()):
						if casing.get_child(i) is Node3D: casing.get_child(i).visible = false
		scene.camera.fov = view.get("fov", 60)
		scene.camera.position = Vector3(view.eye[0], view.eye[1], view.eye[2])
		scene.camera.look_at(Vector3(view.at[0], view.at[1], view.at[2]))
		scene.update_baked_visibility()
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		image.save_png(out.path_join(view.name + ".png"))
	print("CAPTURE_DONE ", views.size(), " baked=", scene.inventory.has("native_lightmap_users"))
	quit()
