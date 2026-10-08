## Review views for #275; run from its unbaked draft with --out=/absolute/path.
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
	var room = load("res://remodel_room.tscn").instantiate()
	root.add_child(room)
	room.set_physics_process(false)
	room.set_process(false)
	room.body.hide()
	room.visitor.hide()
	if room.contact_shadow:
		room.contact_shadow.hide()
	room.label.get_parent().hide()
	for wall in room.casings:
		for i in range(1, wall.get_child_count()):
			wall.get_child(i).show()
	for part in room.ceiling_details:
		part.show()
	await process_frame
	var shots := [
		["lower-east", Vector3(3.7, -1.7, -8.35), Vector3(8.75, .15, -8.35), 76.0],
		["upper-west", Vector3(6.50, 1.60, -6.75), Vector3(1.30, -.10, -9.80), 74.0],
		["east-stair", Vector3(9.18, .40, -6.65), Vector3(8.75, -1.85, -9.85), 74.0],
		["lower-west", Vector3(7.40, -1.65, -8.10), Vector3(1.30, -.75, -9.20), 75.0],
		["piano", Vector3(4.35, -1.65, -8.10), Vector3(2.10, -2.50, -9.75), 48.0],
		["piano-keyboard", Vector3(1.00, -.50, -8.10), Vector3(2.05, -1.80, -9.65), 57.0],
		["piano-bench", Vector3(2.40, -.90, -7.75), Vector3(1.70, -1.95, -9.65), 55.0],
		["piano-pedals", Vector3(.55, -2.15, -8.70), Vector3(1.48, -2.24, -9.65), 58.0],
		["hanging-north", Vector3(5.55, 1.60, -6.25), Vector3(5.30, 1.10, -10.65), 84.0],
		["hanging-east", Vector3(7.65, .95, -6.65), Vector3(9.78, 1.00, -8.65), 90.0],
		["hanging-lower", Vector3(5.55, -1.10, -7.86), Vector3(5.25, .65, -10.65), 80.0],
		["door-entry", Vector3(5.55, 1.60, -4.00), Vector3(5.55, 1.00, -7.60), 66.0],
		["ceiling", Vector3(5.10, -1.40, -8.26), Vector3(5.10, 3.90, -8.26), 70.0],
	]
	for shot in shots:
		room.camera.fov = shot[3]
		room.camera.position = shot[1]
		room.camera.look_at(shot[2], Vector3.BACK if shot[0] == "ceiling" else Vector3.UP)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var im := root.get_texture().get_image()
		im.save_jpg(output_dir.path_join(shot[0] + ".jpg"), .88)
		print("SKYLIGHT_CAPTURE ", shot[0])
	room.free()
	quit()
