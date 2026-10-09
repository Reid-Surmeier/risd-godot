# #168 throwaway matched square gameplay capture; no runtime dependency.
extends SceneTree

const Walk = preload("res://modules/shell/prototype/gallery_walk4/walk4.gd")
const Doorway = preload("res://modules/shell/prototype/gallery_walk4/doorway_prototype.gd")


func _initialize() -> void:
	call_deferred("capture")


func capture() -> void:
	var output := OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output)
	var views := (
		[2, 3]
		if OS.get_cmdline_user_args().size() > 1 and OS.get_cmdline_user_args()[1] == "surfaces"
		else [0, 1]
	)
	for width in [720, 1600]:
		root.size = Vector2i(width, width)
		for index in views:
			var walk := Walk.new()
			root.add_child(walk)
			if OS.get_cmdline_user_args().size() > 1 and OS.get_cmdline_user_args()[1] == "unbaked":
				walk._set_lighting(false)
			walk.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			Doorway.set_floor_pose(walk, index)
			for frame in 12:
				await process_frame
			var path := output.path_join("%s-view-%s.png" % [width, index])
			root.get_texture().get_image().save_png(path)
			print("FLOOR_CAPTURE ", path)
			walk.queue_free()
			await process_frame
	quit()
