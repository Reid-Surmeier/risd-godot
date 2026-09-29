## Private #167 owner corrections: view continuity and source upholstery envelope.
extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	root.size = Vector2i(1080, 1080)
	var walk = load("res://modules/shell/prototype/gallery_walk4/walk4.gd").new()
	walk.size = Vector2(1080, 1080)
	root.add_child(walk)
	walk.set_process(false)
	walk._set_lighting(false)
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		walk._set_lighting(not "--source" in args)
		DirAccess.make_dir_recursive_absolute(args[0])
	for mode in [0, 1]:
		walk.view_mode = mode
		walk._space = "gallery"
		walk._pos = Vector3(0, 0, -4.01)
		walk._update_camera(1)
		var fov: float = walk._cam.fov
		walk._pos.z = -3.99
		walk._update_camera(1)
		assert(is_equal_approx(walk._cam.fov, fov), "Door approach changed view")
		walk._space = "arch"
		walk._pos.z = 3
		walk._update_camera(1)
		assert(is_equal_approx(walk._cam.fov, fov), "Arch changed view")
		assert(walk._cam.cull_mask < 64, "Arch used far-room layers")
		if not args.is_empty():
			for position in [-4.1, -3.9, 3.0]:
				walk._pos = Vector3(0, 0, position)
				walk._space = "arch" if position > 0 else "gallery"
				walk._update_camera(1)
				assert(walk._kid.is_visible_in_tree(), "Review character hidden")
				for frame in 8:
					await process_frame
				assert(root.get_texture().get_image().save_png(args[0].path_join("mode-%s-z-%s.png" % [mode, position])) == OK)
	assert(walk._bench_surface(0.19, 0.21).y < walk._bench_surface(0, 0).y - 0.02, "Missing tuft depression")
	for x in 33:
		for z in 97:
			var p: Vector3 = walk._bench_surface(-0.475 + x * 0.95 / 32, -1.5 + z * 3.0 / 96)
			assert(absf(p.x) <= 0.476 and absf(p.z) <= 1.501 and p.y >= 0.30 and p.y <= 0.421, "Cushion envelope changed")
	print("OWNER_REPAIR source: camera mode/FOV continuity and tufted cushion bounds PASS")
	quit()
