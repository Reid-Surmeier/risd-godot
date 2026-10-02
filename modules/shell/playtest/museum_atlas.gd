## Museum atlas: stands the visitor in every room of the connected museum and photographs it
## from the four dollhouse directions and the follow view. Pictures are for looking at;
## this asserts nothing. godot --path . --script res://modules/shell/playtest/museum_atlas.gd
##   --display-driver x11 --rendering-driver opengl3 -- --out-dir=<dir> [--rooms=a,b]
extends SceneTree

const SIZE := Vector2i(960, 640)


func _initialize() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--" + name + "="):
			return arg.get_slice("=", 1)
	return fallback


func _run() -> void:
	var out := _arg("out-dir", "res://build/museum-atlas")
	var only := _arg("rooms", "")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	root.size = SIZE
	var walk = load("res://modules/shell/prototype/collection_reconstruction/main_build_walk.gd").new()
	walk.size = Vector2(SIZE)
	root.add_child(walk)
	for i in 240:
		await process_frame
	walk.set_process(false)
	walk._entrance_active = false
	walk._entrance_waiting = false
	walk._target = null
	walk._path.clear()
	var stops := [{"label": "Grand Gallery", "space": "gallery", "b": [-5.0, 5.0, -26.3, 0.0]}]
	for room in walk._plan:
		stops.append({"label": room.label, "space": "far" if room.far else "arch", "b": room.b})
	var index := []
	for stop in stops:
		var slug: String = stop.label.to_lower().replace(" ", "-").replace("/", "-")
		if only != "" and not slug in only.split(","):
			continue
		var b: Array = stop.b
		var long_z: bool = b[3] - b[2] > b[1] - b[0]
		var span: float = (b[3] - b[2]) if long_z else (b[1] - b[0])
		# One standpoint per ~7 m along the room's long axis.
		var count := maxi(1, roundi(span / 7.0))
		for n in count:
			var along := (n + 0.5) / count
			var here := Vector3(
				(b[0] + b[1]) / 2.0 if long_z else lerpf(b[0], b[1], along),
				0,
				lerpf(b[2], b[3], along) if long_z else (b[2] + b[3]) / 2.0
			)
			for view in ["n", "e", "s", "w", "follow"]:
				walk._pos = here
				walk._space = stop.space
				walk._last_pos = here
				walk.view_mode = 2 if view == "follow" else 0
				var yaw: float = {"n": 0.0, "e": -PI / 2, "s": PI, "w": PI / 2, "follow": 0.0}[view]
				walk.view_yaw = yaw
				walk._yaw = yaw
				walk._kid.position = here
				walk._kid.reset_contacts()
				walk._kid.pose(0.0, false, 0.0, Vector3(-sin(yaw), 0, -cos(yaw)), yaw)
				for settle in 4:
					walk._update_camera(1.0)
					await process_frame
				await RenderingServer.frame_post_draw
				var file := "%s-%d-%s.png" % [slug, n, view]
				root.get_texture().get_image().save_png(out.path_join(file))
				index.append({"room": stop.label, "stand": [here.x, here.z], "view": view, "file": file})
	var listing := FileAccess.open(out.path_join("atlas.json"), FileAccess.WRITE)
	listing.store_string(JSON.stringify({"state": walk.state(), "shots": index}, " "))
	listing.close()
	print("MUSEUM_ATLAS shots=", index.size(), " ", JSON.stringify(walk.state()))
	quit()
