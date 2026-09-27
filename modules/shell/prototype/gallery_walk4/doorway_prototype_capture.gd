extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	var scene = load("res://modules/shell/prototype/gallery_walk4/doorway_prototype.tscn").instantiate()
	root.add_child(scene)
	var output := OS.get_cmdline_user_args()[0]
	var failures := 0
	DirAccess.make_dir_recursive_absolute(output)
	for width in [1600, 720]:
		root.size = Vector2i(width, roundi(width * 0.75))
		for index in 4:
			scene.set_view(index)
			for frame in 8:
				await process_frame
			var frame := root.get_texture().get_image()
			frame.save_png(output.path_join("%s-view-%s.png" % [width, index]))
			if index == 0:
				for side in [-1, 1]:
					var pixel := Vector2i(scene.camera.unproject_position(Vector3(side * 1.12, 1.4, -26.22)))
					var lit := frame.get_pixelv(pixel).get_luminance()
					if lit < 0.08:
						push_error("Mirrored trim is dark: " + str(side) + " luminance=" + str(lit))
						failures += 1
	print("DOORWAY_PROFILE failures=", failures)
	quit(1 if failures else 0)
