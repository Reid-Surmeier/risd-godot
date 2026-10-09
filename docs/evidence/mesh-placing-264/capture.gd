## Before/after pictures for #264: one work in the installed museum from three fixed cameras.
## godot --fixed-fps 60 --path . --script <this> --display-driver x11 --rendering-driver opengl3
##   -- --out=<absolute dir> --prefix=before [--tag=59.131]
## The cameras are offsets from a fixed point in Hall-local metres, not from the work's own box,
## so a slab and the mesh that replaces it are photographed from the same place.
extends SceneTree

const SIZE := Vector2i(1200, 800)
const AIM := Vector3(3.62, 1.75, 5.67)  # the Head of Christ's place on its pedestal, Hall-local
const SHOTS := {
	"front": Vector3(0.0, 0.1, -2.6),
	"oblique": Vector3(-1.25, 0.3, -1.5),
	"side": Vector3(-2.4, 0.2, -0.35),
}


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
	for thing in walk._objects:
		if thing.tag.begins_with(_arg("tag", "59.131") + "#"):
			print("CAPTURE_WORK ", thing.tag, " centre ", thing.center, " outer ", thing.outer, " room ", walk._plan[thing.room].label)
	# Stand in the room, facing its south wall, so that wall and what hangs on it are drawn.
	var stand := Vector3(AIM.x - 0.4, 0, AIM.z - 2.6)
	walk._new_action()
	walk._target = null
	walk._held.clear()
	walk._velocity = Vector3.ZERO
	walk._pos = stand
	walk._last_pos = stand
	walk._space = "far" if walk._plan[walk._room_at(stand)].far else "arch"
	walk.view_mode = 0
	walk.view_yaw = PI
	walk._yaw = PI
	walk._kid.position = stand
	for settle in 30:
		walk._update_camera(1.0)
		await process_frame
	walk.set_process(false)
	walk._kid.hide()
	walk._cam.fov = 45.0
	walk._shadow.hide()
	for name in SHOTS:
		walk._cam.global_transform = Transform3D(Basis(), AIM + SHOTS[name]).looking_at(AIM, Vector3.UP)
		for settle in 4:
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(out.path_join("%s-%s.png" % [prefix, name]))
	print("CAPTURE_DONE ", prefix)
	quit(0)
