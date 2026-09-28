## #167 isolated portal comparison, using the saved room and fixed square cameras.
extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var scene = load("res://modules/shell/prototype/gallery_walk4/doorway_prototype.tscn").instantiate()
	root.add_child(scene)
	var output := OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output)
	for width in [1600, 720]:
		root.size = Vector2i(width, width)
		for view in [8, 9, 10]:
			scene.set_view(view)
			for frame in 8:
				await process_frame
			var path: String = output.path_join("%s-view-%s.png" % [width, view])
			assert(root.get_texture().get_image().save_png(path) == OK)
			print("PORTAL_CAPTURE ", path)
	quit()
