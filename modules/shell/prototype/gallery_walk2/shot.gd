## PROTOTYPE 2 evidence: the game's main scene, Collection tab, driven with real key presses and clicks.
## depth step s1->s2, seedance step s2->s3, turn around, walk up to a wall, back.
## Run: godot --path . --script res://modules/shell/prototype/gallery_walk2/shot.gd -- --out-dir=<path>
extends "res://testing/harness_base.gd"


func _initialize() -> void:
	var main: Control = load("res://modules/shell/demo.tscn").instantiate()
	var out_dir := await _mount(main, Vector2i(1920, 1080), "/tmp/gallery-walk2")
	await create_timer(4.0).timeout
	var walk: Control = main.find_child("GalleryWalk", true, false)
	var at := func(fx: float, fy: float) -> Vector2: return walk.get_global_rect().position + walk.size * Vector2(fx, fy)
	await _shot(out_dir, "01-s1.png")
	await _key(KEY_2, "depth mode")
	await _key(KEY_UP, "up")
	await create_timer(1.2).timeout
	await _shot(out_dir, "02-depth-walking.png")
	await create_timer(2.0).timeout
	await _shot(out_dir, "03-s2.png")
	await _key(KEY_1, "seedance mode")
	await _key(KEY_UP, "up")
	await create_timer(1.0).timeout
	await _shot(out_dir, "04-seedance-walking-a.png")
	await create_timer(1.5).timeout
	await _shot(out_dir, "05-seedance-walking-b.png")
	await create_timer(2.5).timeout
	await _shot(out_dir, "06-s3.png")
	await _key(KEY_DOWN, "turn around")
	await create_timer(1.0).timeout
	await _shot(out_dir, "07-r3.png")
	await _click(at.call(0.12, 0.45), "left wall painting")
	await create_timer(1.3).timeout
	await _shot(out_dir, "08-approach-mid.png")
	await create_timer(1.8).timeout
	await _shot(out_dir, "09-at-wall.png")
	await _key(KEY_ESCAPE, "back")
	await create_timer(2.2).timeout
	await _shot(out_dir, "10-back.png")
	quit(0)
