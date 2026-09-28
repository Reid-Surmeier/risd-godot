# #168 throwaway matched square gameplay capture; no runtime dependency.
extends SceneTree

const Walk = preload("res://modules/shell/prototype/gallery_walk4/walk4.gd")

func set_floor_pose(walk: Control, index: int) -> void:
	walk._new_action()
	walk._entrance_active = false
	walk._entrance_waiting = false
	walk._target = null
	walk._pos = Vector3(0, 0, -17.0)
	walk.view_mode = 1
	walk.view_yaw = 0.0
	walk._kid.hide()
	walk._shadow.hide()
	for shadow in walk._sole_shadows:
		shadow.hide()
	walk._update_camera(1.0)
	if index == 1:
		walk.set_process(false)
		walk._cam.position = Vector3(0.8, 1.75, -14.0)
		walk._cam.look_at(Vector3(0.2, 0.0, -18.5))
		walk._cam.fov = 55.0

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var output := OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output)
	for width in [720, 1600]:
		root.size = Vector2i(width, width)
		for index in [0, 1]:
			var walk := Walk.new()
			root.add_child(walk)
			if OS.get_cmdline_user_args().size() > 1 and OS.get_cmdline_user_args()[1] == "unbaked":
				walk._set_lighting(false)
			walk.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			set_floor_pose(walk, index)
			for frame in 12:
				await process_frame
			var path := output.path_join("%s-view-%s.png" % [width, index])
			root.get_texture().get_image().save_png(path)
			print("FLOOR_CAPTURE ", path)
			walk.queue_free()
			await process_frame
	quit()
