extends "res://testing/harness_base.gd"

func _initialize() -> void:
	var main: Control = load("res://modules/shell/demo.tscn").instantiate()
	var out := await _mount(main, Vector2i(720, 720), "/tmp/risd-skylight-168-0900")
	await create_timer(4.0).timeout
	var walk: Control = main.find_child("GalleryWalk", true, false)
	walk._pos = Vector3(0, 0, -18)
	walk.view_mode = 2
	walk._update_camera(1.0)
	walk.set_process(false)
	walk._vp.get_parent().stretch = false
	walk._vp.size = Vector2i(720, 720)
	walk._cam.look_at(Vector3(0, 6.2, -23))
	await RenderingServer.frame_post_draw
	walk._vp.get_texture().get_image().save_png(out.path_join("skylight-native-720.png"))
	quit()
