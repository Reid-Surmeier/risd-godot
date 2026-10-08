## Actual walking-camera review for #275; GL draft, --out=/absolute/path.
extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var output_dir := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			output_dir = arg.trim_prefix("--out=")
	assert(not output_dir.is_empty(), "Pass --out=/absolute/review/folder")
	DirAccess.make_dir_recursive_absolute(output_dir)
	var walk = load("res://skylight_main_walk.gd").new()
	root.add_child(walk)
	walk.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	walk.set_process(false)
	walk._attach_rooms("res://remodel_room.tscn")
	walk._rooms_path = ""
	walk._space = "far"
	var shots := [
		["game-lower-n", Vector3(5.55,-2.55,-8.40),0.0,0],
		["game-lower-e", Vector3(5.55,-2.55,-8.40),PI/2,0],
		["game-lower-w", Vector3(3.5,-2.55,-7.86),-PI/2,0],
		["game-upper", Vector3(5.55,0,-6.58),0.0,0],
		["game-follow-lower", Vector3(5.55,-2.55,-8.40),0.0,2],
	]
	for row in shots:
		walk._pos = row[1] + walk.ATTACH
		walk._kid.position = walk._pos
		walk._stage = walk.NO_STAGE
		walk.view_yaw = row[2]
		walk.view_mode = row[3]
		walk._update_camera(.016)
		for i in 5:
			await process_frame
			walk._update_camera(.016)
		await RenderingServer.frame_post_draw
		var im = walk._vp.get_texture().get_image()
		im.resize(960,640)
		im.save_jpg(output_dir.path_join(row[0] + ".jpg"),.85)
		print("SKYLIGHT_GAME_CAPTURE ", row[0]," visitor ",walk._pos-walk.ATTACH)
	walk.free()
	quit()
