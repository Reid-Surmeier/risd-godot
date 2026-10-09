extends SceneTree


func _initialize() -> void:
	call_deferred("run")


func run() -> void:
	root.size = Vector2i(720, 720)
	var scene = (
		load("res://modules/shell/prototype/gallery_walk4/doorway_prototype.tscn").instantiate()
	)
	root.add_child(scene)
	scene.set_view(12)
	for frame in 8:
		await process_frame
	root.get_texture().get_image().save_png("res://docs/evidence/floor-selection-186/native.png")
	quit()
