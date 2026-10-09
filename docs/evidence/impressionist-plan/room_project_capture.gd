## Review only: eye-level pictures in a room project left by scripts/rebuild_rooms.sh, where
## every room is drawn at once (the game draws one stage and hazes the doorways).
## godot --path <trial>/extension --script <this absolute path> --display-driver x11
##   --rendering-driver opengl3 -- --out=<absolute dir>
extends SceneTree

const SIZE := Vector2i(720, 1280)
# name, camera, look-at, field of view; room-scene metres.
const VIEWS := [
	["stair-door", Vector3(13.35, 1.5, -3.0), Vector3(12.25, 1.35, 3.04), 62.0],
	["passage", Vector3(12.25, 1.5, 1.20), Vector3(12.55, 1.3, 12.7), 62.0],
	["A-back", Vector3(14.4, 1.5, 7.4), Vector3(12.6, 1.4, 3.04), 62.0],
	["B-north", Vector3(13.4, 1.5, 20.9), Vector3(13.6, 1.45, 12.7), 70.0],
	["B-west", Vector3(16.0, 1.5, 17.5), Vector3(10.55, 1.5, 17.5), 78.0],
	["B-south", Vector3(13.0, 1.5, 14.2), Vector3(13.4, 1.45, 22.3), 70.0],
	["B-east", Vector3(11.4, 1.5, 17.5), Vector3(16.7, 1.5, 17.5), 78.0]
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var out := ""
	for value in OS.get_cmdline_user_args():
		if value.begins_with("--out="):
			out = value.get_slice("=", 1)
	root.size = SIZE
	var scene: Node = load("res://remodel_room.tscn").instantiate()
	root.add_child(scene)
	for i in 240:
		await process_frame
	var camera := Camera3D.new()
	root.add_child(camera)
	camera.make_current()
	# A flat review fill, as the unbaked draft has: this is a geometry picture, not the game's light.
	var lit := Environment.new()
	lit.background_mode = Environment.BG_COLOR
	lit.background_color = Color("d9d6cd")
	lit.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	lit.ambient_light_color = Color.WHITE
	lit.ambient_light_energy = .75
	camera.environment = lit
	for node in scene.find_children("*", "CanvasLayer", true, false) + scene.find_children("*", "Label", true, false):
		node.hide()
	for view in VIEWS:
		camera.fov = view[3]
		camera.global_transform = Transform3D(Basis(), view[1]).looking_at(view[2], Vector3.UP)
		for i in 6:
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(out.path_join(view[0] + "-rooms.png"))
	print("ROOM_PROJECT_CAPTURE_DONE")
	quit(0)
