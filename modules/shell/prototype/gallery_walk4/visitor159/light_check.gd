extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.size = Vector2i(1080, 1080)
	var gallery = load("res://modules/shell/prototype/gallery_walk4/visitor159/play.tscn").instantiate()
	root.add_child(gallery)
	gallery.resized.emit()
	await create_timer(2).timeout
	gallery.set_process(false)
	gallery._new_action()
	gallery._target = null
	gallery.view_yaw = PI / 2
	var samples := {}
	var result := {}
	DirAccess.make_dir_recursive_absolute("/tmp/risd-159-evidence/light")
	for test in ["warm", "cool", "disabled"]:
		gallery._pos = Vector3(-3.4, 0, -12) if test != "cool" else Vector3(1.4, 0, -5)
		gallery._kid.position = gallery._pos
		gallery._kid.reset_contacts()
		gallery._kid.pose(0, false, 0, Vector3.RIGHT, 0)
		gallery._kid.pose(0.2, false, 0, Vector3.RIGHT, 0)
		gallery._update_camera(1)
		for mesh in gallery._kid.meshes:
			mesh.gi_mode = GeometryInstance3D.GI_MODE_DISABLED if test == "disabled" else GeometryInstance3D.GI_MODE_DYNAMIC
		await create_timer(0.5).timeout
		root.get_texture().get_image().save_png("/tmp/risd-159-evidence/light/" + test + ".png")
		var img: Image = gallery._vp.get_texture().get_image()
		var point: Vector2i = Vector2i(gallery._cam.unproject_position(gallery._pos + Vector3.UP * 1.35))
		var color := img.get_pixelv(point)
		samples[test] = Vector3(color.r, color.g, color.b)
		result[test] = [color.r, color.g, color.b]
		print("VISITOR159_LIGHT ", test, " ", color)
		assert(color.r > 0.04 if test != "disabled" else color.r < 0.03, "light regression: " + test)
	# This brown hair sample has a subtle response (unlike the old light-skinned
	# surrogate). Require several 8-bit levels, plus the black GI-off control.
	assert(samples.warm.distance_to(samples.cool) > 0.01, "spatial probe response missing")
	assert(gallery._paintings.size() == 23)
	for painting in gallery._paintings:
		assert(not painting.rec.is_empty() and painting.outer.x > 0 and painting.outer.y > 0)
	FileAccess.open("/tmp/risd-159-evidence/light/metrics.json", FileAccess.WRITE).store_string(JSON.stringify(result))
	print("VISITOR159_LIGHT_PASS ", result, " paintings=23")
	quit()
