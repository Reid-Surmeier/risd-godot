## Doorway pictures for #273: each named doorway from the game's own camera and from close.
## godot --fixed-fps 60 --path . --script <this> --display-driver x11 --rendering-driver opengl3
##   -- --out=<absolute dir> --prefix=before "--doors=light Renaissance room:north,Rockefeller:east"
extends SceneTree

const SIZE := Vector2i(1200, 800)
const YAW := {"north": 0.0, "east": -PI / 2, "south": PI, "west": PI / 2}
const INWARD := {"north": Vector3(0, 0, 1), "south": Vector3(0, 0, -1), "west": Vector3(1, 0, 0), "east": Vector3(-1, 0, 0)}


func _initialize() -> void:
	call_deferred("_run")


func _arg(name: String, fallback: String) -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--" + name + "="):
			return arg.get_slice("=", 1)
	return fallback


func _run() -> void:
	var out := _arg("out", "")
	var prefix := _arg("prefix", "shot")
	root.size = SIZE
	var walk = load("res://modules/shell/prototype/collection_reconstruction/main_build_walk.gd").new()
	walk.size = Vector2(SIZE)
	root.add_child(walk)
	for i in 240:
		await process_frame
	for door in _arg("doors", "").split(","):
		var label := door.get_slice(":", 0)
		var side := door.get_slice(":", 1)
		for room in walk._plan:
			if room.label != label:
				continue
			var b: Array = room.b
			var o: Array = room.openings[side]
			var mid: float = (o[0] + o[1]) / 2.0
			var on_wall := Vector3(b[0] if side == "west" else b[1], 0, mid) if side in ["west", "east"] else Vector3(mid, 0, b[2] if side == "north" else b[3])
			var inward: Vector3 = INWARD[side]
			var along := Vector3(0, 0, 1) if side in ["west", "east"] else Vector3(1, 0, 0)
			var stand: Vector3 = on_wall + inward * 2.4
			walk.set_process(true)
			walk._new_action()
			walk._target = null
			walk._held.clear()
			walk._velocity = Vector3.ZERO
			walk._pos = stand
			walk._last_pos = stand
			walk._space = "far" if room.far else "arch"
			walk.view_mode = 0
			walk.view_yaw = YAW[side]
			walk._yaw = YAW[side]
			walk._kid.position = stand
			for settle in 40:
				await process_frame
			var slug := "%s-%s-%s" % [prefix, label.to_lower().replace(" ", "-"), side]
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(out.path_join(slug + "-game.png"))
			walk.set_process(false)
			walk._kid.hide()
			walk._shadow.hide()
			walk._cam.fov = 50.0
			walk._cam.global_transform = Transform3D(Basis(), on_wall + inward * 1.9 + along * 1.5 + Vector3(0, 1.7, 0)).looking_at(on_wall + Vector3(0, 1.45, 0), Vector3.UP)
			for settle in 4:
				await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(out.path_join(slug + "-close.png"))
			walk._kid.show()
			walk._shadow.show()
	print("DOOR_CAPTURE_DONE ", prefix)
	quit(0)
