extends SceneTree


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	var probe = load("res://docs/evidence/owner-world-177/passage-current/probe.gd").new()
	root.add_child(probe)
	for dimensions in [Vector2i(720, 480), Vector2i(1600, 1067)]:
		root.size = dimensions
		for frame in 12:
			await process_frame
		root.get_texture().get_image().save_png(
			"res://docs/evidence/owner-world-177/passage-current/native-%d.png" % dimensions.x
		)
	print("PASSAGE_NATIVE 720/1600 exported")
	quit()
