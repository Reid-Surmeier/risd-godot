extends SceneTree

const Catalogue := preload("res://modules/sculpture_viewer/catalogue.gd")

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(1080, 1080)
	var page := Catalogue.new()
	root.add_child(page)
	page.selected = 2
	page.hovered = 2
	page._scan_render_mode()
	for yaw in [0.0, 60.0, 120.0, 180.0, 240.0, 300.0]:
		page.scan_yaw = yaw
		page._update_scan_camera()
		page.queue_redraw()
		for _i in 4:
			await process_frame
		await RenderingServer.frame_post_draw
		var path := "/tmp/risd-viewer-157-%03d.png" % int(yaw)
		var err := root.get_texture().get_image().save_png(path)
		assert(err == OK)
		print("CAPTURE " + path)
	page.visible = false
	assert(page.scan_viewport.render_target_update_mode == SubViewport.UPDATE_DISABLED)
	page.visible = true
	assert(page.scan_viewport.render_target_update_mode == SubViewport.UPDATE_ALWAYS)
	quit()
