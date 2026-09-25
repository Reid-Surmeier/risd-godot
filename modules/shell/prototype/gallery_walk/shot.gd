## PROTOTYPE evidence: the game's main scene, Collection tab, walked with real key presses and clicks:
## doorway -> walk in -> turn right -> click the poppy Monet -> close-up -> museum photo -> back out.
## Run: godot --path . --script res://modules/shell/prototype/gallery_walk/shot.gd -- --out-dir=<path>
extends "res://testing/harness_base.gd"


func _image_point(walk: Control, p: Vector2) -> Vector2:
	return walk.get_global_rect().position + p / Vector2(1920, 1280) * walk.size


func _initialize() -> void:
	var main: Control = load("res://modules/shell/demo.tscn").instantiate()
	var out_dir := await _mount(main, Vector2i(1920, 1080), "/tmp/gallery-walk")
	await create_timer(4.0).timeout
	var walk: Control = main.find_child("GalleryWalk", true, false)
	await _shot(out_dir, "01-doorway.png")
	await _key(KEY_UP, "up")
	await create_timer(0.22).timeout
	await _shot(out_dir, "02-walking-in.png")
	await create_timer(0.6).timeout
	await _shot(out_dir, "03-room.png")
	await _key(KEY_RIGHT, "right")
	await create_timer(0.9).timeout
	await _shot(out_dir, "04-right-wall.png")
	await _click(_image_point(walk, Vector2(872, 608)), "poppy Monet")
	await create_timer(0.9).timeout
	await _shot(out_dir, "05-approaching.png")
	await create_timer(1.6).timeout
	await _shot(out_dir, "06-close-up.png")
	await _click(_image_point(walk, Vector2(960, 640)), "close-up")
	await create_timer(0.9).timeout
	await _shot(out_dir, "07-museum-photo.png")
	await _key(KEY_ESCAPE, "escape")
	await create_timer(2.0).timeout
	await _shot(out_dir, "08-back-out.png")
	quit(0)
