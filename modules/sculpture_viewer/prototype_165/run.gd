## Run: DISPLAY=:99 godot --display-driver x11 --rendering-method gl_compatibility
##      --resolution 1080x1080 --windowed
##      --path . --script modules/sculpture_viewer/prototype_165/run.gd
## Add -- --capture to save native 1080-square evidence and exercise real pointer input.
extends SceneTree

const Catalogue := preload("res://modules/sculpture_viewer/prototype_165/catalogue.gd")

var catalogue: Control


func _initialize() -> void:
	root.size = Vector2i(1080, 1080)
	catalogue = Catalogue.new()
	root.add_child.call_deferred(catalogue)
	if "--capture" in OS.get_cmdline_user_args():
		capture.call_deferred()


func capture() -> void:
	await process_frame
	await process_frame
	for layout in range(3):
		_key(KEY_F1 + layout)
		await process_frame
		assert(catalogue.state().variant == layout)
		catalogue.selected = 0
		catalogue.hovered = -1
		catalogue.queue_redraw()
		await RenderingServer.frame_post_draw
		_save("layout-%s.png" % ["a", "b", "c"][layout])
		_mouse(catalogue._card_rect(2).get_center(), true)
		await process_frame
		assert(catalogue.state().selected_id == "20260811123051")
		await RenderingServer.frame_post_draw
		_save("selected-%s.png" % ["a", "b", "c"][layout])
		_mouse(catalogue._card_rect(5).get_center(), false)
		await process_frame
		assert(catalogue.state().hovered == 5)
		await RenderingServer.frame_post_draw
		_save("hover-%s.png" % ["a", "b", "c"][layout])
		_mouse(catalogue._card_rect(19).get_center(), true)
		await process_frame
		assert(catalogue.state().selected_id == "panel-cell:22")
		assert(not catalogue.state()["3d_preview_available"])
	quit()


func _key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.pressed = true
	Input.parse_input_event(event)


func _mouse(at: Vector2, click: bool) -> void:
	var move := InputEventMouseMotion.new()
	move.position = at
	move.global_position = at
	Input.parse_input_event(move)
	if click:
		var down := InputEventMouseButton.new()
		down.position = at
		down.global_position = at
		down.button_index = MOUSE_BUTTON_LEFT
		down.pressed = true
		Input.parse_input_event(down)
		var up := InputEventMouseButton.new()
		up.position = at
		up.global_position = at
		up.button_index = MOUSE_BUTTON_LEFT
		Input.parse_input_event(up)


func _save(filename: String) -> void:
	var path := "res://modules/sculpture_viewer/prototype_165/evidence/" + filename
	var error := root.get_texture().get_image().save_png(ProjectSettings.globalize_path(path))
	assert(error == OK, "save failed: %s" % path)
