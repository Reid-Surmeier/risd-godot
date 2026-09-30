extends "res://testing/harness_base.gd"


func _initialize():
	call_deferred("run")


func run():
	var stage = load("res://modules/shell/demo.tscn").instantiate()
	var out = await _mount(stage, Vector2i(1080, 1080), "/dev/shm/risd-display161-current-native")
	await _frames(90)
	var walk = stage.find_child("GalleryWalk", true, false)
	assert(walk != null and walk._paintings.size() == 23)
	var probe = load("res://modules/shell/prototype/gallery_walk4/render_diagnostics.gd").new()
	probe.view = walk
	var finish = walk._vp.get_parent().material
	for width in [720, 1600]:
		root.size = Vector2i(width, width)
		await _frames(10)
		for label in ["A", "B", "C"]:
			finish.set_shader_parameter("quantization_mode", 0 if label == "B" else 2)
			finish.set_shader_parameter(
				"copy_filter", 0.0 if label == "B" else (1.0 if label == "A" else 0.5)
			)
			for scene in ["warm", "art", "white"]:
				probe._pose(scene)
				await _frames(10)
				await _shot(out, "%s-%d-%s.png" % [label, width, scene])
	print("DISPLAY_NATIVE 18 matched square captures PASS")
	probe.free()
	_finish(out)
