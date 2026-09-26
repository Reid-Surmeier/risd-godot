## Evidence for map #116 "the Painting Asset recipe on three paintings": each modelled painting seen at an angle
## (bevel and inset), straight on, and in the detail view, inside the real game's Collection tab.
## Run: godot --path . --script res://modules/shell/prototype/gallery_walk3/shot_assets.gd -- --out-dir=<path>
extends "res://testing/harness_base.gd"


func _stand(walk: Control, pt: Dictionary, along: float, dist: float) -> void:
	var n: Vector3 = pt.normal
	var side := Vector3(0, 0, -1) if n.x > 0 else Vector3(0, 0, 1)  # along the wall
	var p: Vector3 = pt.center + n * dist + side * along
	p.y = 0
	walk._pos = p
	var look: Vector3 = pt.center - p
	walk._yaw = atan2(-look.x, -look.z)
	walk._target = null
	walk._target_yaw = null
	walk._update_camera(1.0)
	await create_timer(0.4).timeout


func _initialize() -> void:
	var main: Control = load("res://modules/shell/demo.tscn").instantiate()
	var out_dir := await _mount(main, Vector2i(1920, 1080), "/tmp/gallery-assets")
	await create_timer(4.0).timeout
	var walk: Control = main.find_child("GalleryWalk", true, false)
	for pt in walk._paintings:
		if pt.asset.is_empty():
			continue
		await _stand(walk, pt, 2.2, 2.4)
		await _shot(out_dir, "%s-1-angle.png" % pt.id)
		await _stand(walk, pt, 0.0, 3.2)
		await _shot(out_dir, "%s-2-front.png" % pt.id)
		walk._open_detail(pt)
		await create_timer(0.8).timeout
		await _shot(out_dir, "%s-3-detail.png" % pt.id)
		await walk._close_detail()
	quit(0)
