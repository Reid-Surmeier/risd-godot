## Review only: pictures of the Impressionist entry from an installed (baked) room build.
## godot --fixed-fps 60 --path . --script <this absolute path> --display-driver x11
##   --rendering-driver opengl3 -- --out=<absolute dir> [--views=a,b]
## Each view: the game's own camera with the visitor standing there (-game), then an eye-level
## camera with the neighbouring rooms drawn too (-close), which the game itself never shows.
extends SceneTree

const SIZE := Vector2i(720, 1280)
const ATTACH := Vector3(-5.55, 0, -28.1)
# name, visitor stand, visitor yaw, camera, look-at; room-scene metres.
const VIEWS := [
	["stair-door", Vector3(12.6, 0, -1.6), PI, Vector3(13.25, 1.5, -2.3), Vector3(12.25, 1.35, 3.04)],
	["passage", Vector3(12.45, 0, 1.5), PI, Vector3(12.25, 1.5, 1.25), Vector3(12.55, 1.3, 12.7)],
	["A-entry", Vector3(12.45, 0, 4.4), PI, Vector3(12.45, 1.5, 3.3), Vector3(13.2, 1.3, 12.7)],
	["A-back", Vector3(13.6, 0, 6.6), 0.0, Vector3(14.4, 1.5, 7.4), Vector3(12.6, 1.4, 3.04)],
	["exit-door", Vector3(15.6, 0, -1.96), -PI / 2, Vector3(14.6, 1.5, -1.96), Vector3(17.85, 1.3, -1.96)],
	["B-north", Vector3(13.6, 0, 18.6), 0.0, Vector3(13.6, 1.5, 20.6), Vector3(13.2, 1.45, 12.7)],
	["B-west", Vector3(14.6, 0, 17.5), PI / 2, Vector3(15.9, 1.5, 17.5), Vector3(10.55, 1.5, 17.5)],
	["B-south", Vector3(13.6, 0, 16.6), PI, Vector3(13.2, 1.5, 14.4), Vector3(13.6, 1.45, 22.3)]
]


func _initialize() -> void:
	call_deferred("_run")


func _arg(name: String) -> String:
	for value in OS.get_cmdline_user_args():
		if value.begins_with("--" + name + "="):
			return value.get_slice("=", 1)
	return ""


func _run() -> void:
	root.size = SIZE
	var walk = load("res://modules/shell/prototype/collection_reconstruction/main_build_walk.gd").new()
	walk.size = Vector2(SIZE)
	root.add_child(walk)
	for i in 300:
		await process_frame
	for view in VIEWS:
		if not _arg("views").is_empty() and view[0] not in _arg("views").split(","):
			continue
		walk.set_process(true)
		walk._new_action()
		walk._target = null
		walk._held.clear()
		walk._velocity = Vector3.ZERO
		walk._pos = view[1] + ATTACH
		walk._last_pos = walk._pos
		walk._kid.position = walk._pos
		walk._space = "far" if walk._plan[walk._room_at(walk._pos)].far else "arch"
		walk.view_mode = 0
		walk.view_yaw = view[2]
		walk._yaw = view[2]
		for i in 60:
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(_arg("out").path_join(view[0] + "-game.png"))
		walk.set_process(false)
		walk._kid.hide()
		walk._shadow.hide()
		walk._cam.fov = 62.0
		walk._cam.global_transform = Transform3D(Basis(), view[3] + ATTACH).looking_at(view[4] + ATTACH, Vector3.UP)
		walk._floor_mask.hide()
		walk._cam.cull_mask |= 2048 | 4096
		for part in walk._parts:
			part.node.visible = part.shown
		for wall in walk._walls:
			for j in range(1, wall.body.get_child_count()):
				wall.body.get_child(j).show()
		for ceiling in walk._rooms.ceiling_details:
			if is_instance_valid(ceiling) and ceiling.has_meta("opaque_ceiling"):
				ceiling.show()
		for i in 4:
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(_arg("out").path_join(view[0] + "-close.png"))
		walk._floor_mask.show()
		walk._kid.show()
		walk._shadow.show()
	print("ENTRY_CAPTURE_DONE")
	quit(0)
