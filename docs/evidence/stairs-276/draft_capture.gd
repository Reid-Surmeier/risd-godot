## Issue #276 review cameras, run against the unbaked extension project only.
## timeout 240 godot --path <extension> --rendering-method gl_compatibility
##   --script <absolute path to this file> -- --out=<folder> --part=iron
extends SceneTree


func _initialize() -> void:
	call_deferred("capture")


func arg(key: String, fallback: String) -> String:
	for item in OS.get_cmdline_user_args():
		if item.begins_with("--" + key + "="):
			return item.get_slice("=", 1)
	return fallback


func capture() -> void:
	root.size = Vector2i(900, 900)
	var scene = load("res://remodel_room.tscn").instantiate()
	root.add_child(scene)
	for i in 90:
		await process_frame
	scene.set_process(false)
	scene.set_physics_process(false)
	scene.visitor.hide()
	scene.label.hide()
	for ceiling in scene.ceiling_details:
		ceiling.show()
	if scene.contact_shadow != null:
		scene.contact_shadow.hide()
	var b: Array = scene.room_bounds("marble stair hall")
	var x0: float = b[0]
	var x1: float = b[1]
	var z0: float = b[2]
	var z1: float = b[3]
	var xe := x1 - 1.6
	var zn := z0 + 1.6
	var first := xe - 13 * .35
	var middle := (z0 + z1) / 2
	var shots := {
		"iron": [
			["iron-room", Vector3(x0 + .5, 1.65, z1 - .8), Vector3(xe - 1.5, 1.9, z0 + 1.0)],
			["iron-newel", Vector3(first - 1.0, 1.45, zn + 1.8), Vector3(first + .55, .95, zn - .1)],
			["iron-volute", Vector3(first - .7, 1.95, zn + .9), Vector3(first + .05, 1.05, zn + .1225)],
			["iron-panel", Vector3(first + 1.7, 1.25, zn + .65), Vector3(first + 1.7, 1.1, zn - .06)],
			["iron-upper", Vector3(x1 - 2.7, 5.6, middle), Vector3(x0 + 2.2, 4.9, middle)]
		],
		"floor": [
			["floor-room", Vector3(x0 + .5, 1.65, middle), Vector3(x1 - 2.0, .65, middle)],
			["floor-close", Vector3(x0 + 3.4, 1.55, middle + 1.0), Vector3(x0 + 3.4, 0, middle)]
		],
		"niche": [["niche", Vector3(x0 + .85, 1.6, z1 - 1.0), Vector3(x0 + 2.95, 1.0, z1 - .8)]],
		"window": [
			["window", Vector3(x1 - 3.8, 4.2, middle - 1.35), Vector3(x1 - .1, 5.1, middle)],
			["hall-wide", Vector3(x0 + .55, 2.8, middle), Vector3(x1 - .2, 4.0, middle)],
			["landing-finish", Vector3(x1 - 2.7, 5.6, middle), Vector3(x0 + 2.2, 4.9, middle)]
		],
		"lion": [
			["lion-shaft", Vector3(13.35, 1.7, 29.3), Vector3(13.35, .7, 35.9)],
			["lion-down", Vector3(13.35, 1.7, 32.4), Vector3(13.35, -3.0, 36.0)],
			["lion-wall", Vector3(13.45, 1.7, 31.8), Vector3(14.2, 1.8, 28.1)],
			["lion-rail", Vector3(12.8, 1.45, 32.1), Vector3(13.4, .65, 33.1)],
			["lion-up", Vector3(13.5, 1.7, 32.3), Vector3(13.4, 4.7, 35.5)]
		],
		"columns": [
			["columns-grey", Vector3(x0 - 2.8, 1.6, middle), Vector3(x0, 2.1, middle)],
			["columns-hall", Vector3(x0 + 3.3, 1.6, middle), Vector3(x0, 2.1, middle)]
		]
	}
	var out := arg("out", "")
	DirAccess.make_dir_recursive_absolute(out)
	for part in arg("part", "iron").split(","):
		for shot in shots[part]:
			scene.camera.fov = 58
			scene.camera.global_transform = Transform3D(Basis(), shot[1]).looking_at(shot[2], Vector3.UP)
			for i in 6:
				await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(out.path_join(shot[0] + ".png"))
			print("STAIRS_CAPTURE ", shot[0], " eye=", shot[1], " target=", shot[2])
	print("STAIRS_CAPTURE_DONE triangles_per_scroll_panel=", load("res://marble_hall_additions.gd").scroll_panel_mesh().surface_get_array_len(0) / 3)
	quit(0)
