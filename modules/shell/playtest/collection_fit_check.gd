## #173: Collection art and its live opening share one centered uniform fit.
extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var stage: Control = load("res://modules/shell/demo.tscn").instantiate()
	root.add_child(stage)
	for frame in 90:
		await process_frame
	var picture: TextureRect = stage.find_child("CollectionFrame", true, false)
	assert(picture != null)
	var page: Control = picture.get_parent()
	assert(picture.get_global_rect() == page.get_global_rect(), "Collection must not inherit a desktop icon inset")
	assert(picture.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	var s := minf(page.size.x / picture.texture.get_width(), page.size.y / picture.texture.get_height())
	var origin := (page.size - picture.texture.get_size() * s) / 2
	var walk: Control = picture.get_node("GalleryWalk")
	assert(walk.position.distance_to((origin + Vector2(458, 521) * s).round()) < 1)
	assert(walk.size.distance_to((Vector2(2110, 1412) * s).round()) < 1)
	print("COLLECTION_FIT PASS centered source proportions and live opening ", picture.get_global_rect())
	quit()
