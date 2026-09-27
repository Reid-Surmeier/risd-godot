## Recess-floor visibility: the room floor must not cover the white passage.
extends "res://testing/harness_base.gd"
var failures := 0
var control_shaders: Array[Shader] = []
func require(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	if "--negative" in OS.get_cmdline_user_args():
		# In-memory missing-clip regression, no production switch or changed assets.
		for name in ["oak", "ps1"]:
			var shader: Shader = load("res://modules/shell/prototype/gallery_walk4/" + name + ".gdshader")
			var lines := PackedStringArray()
			for line in shader.code.split("\n"):
				if not (line.contains("floor_world_z") and line.contains("discard")):
					lines.append(line)
			shader.code = "\n".join(lines)
			control_shaders.append(shader)
	call_deferred("run")
func run() -> void:
	var walk = load("res://modules/shell/prototype/gallery_walk4/walk4.gd").new()
	walk.size = Vector2(1152, 720)
	walk.set_process(false)
	var out := await _mount(walk, Vector2i(1152, 720), "/tmp/gallery-doorway")
	walk.set_process(false)
	walk._new_action()
	walk._entrance_active = false
	walk._entrance_waiting = false
	walk._target = null
	for dimensions in [Vector2i(1152, 720), Vector2i(588, 392)]:
		get_root().size = dimensions
		walk.size = dimensions
		await _frames(3)
		for baked in [true, false]:
			walk._set_lighting(baked)
			for door in ["arch", "far"]:
				walk._pos = Vector3(0, 0, -2.6 if door == "arch" else -walk.L + 2.6)
				walk.view_yaw = PI if door == "arch" else 0.0
				walk._kid.reset_contacts()
				walk._kid.position = walk._pos
				walk._kid.pose(0.0, false, 0, Vector3.FORWARD, walk.view_yaw)
				walk._update_camera(1.0)
				await _frames(4)
				var label := "%s-%s-%s" % [dimensions.x, "baked" if baked else "original", door]
				await _shot(out, label + ".png")
				var image: Image = walk._vp.get_texture().get_image()
				var clear := 0
				for x in [-0.5, 0.0, 0.5]:
					for depth in [0.15, 0.22, 0.32]:
						var z: float = depth if door == "arch" else -walk.L - depth
						var pixel := Vector2i(walk._cam.unproject_position(Vector3(x, 0, z)))
						var color := image.get_pixelv(pixel)
						if color.get_luminance() > (0.65 if door == "arch" else 0.04):
							clear += 1
				print("DOORWAY_FLOOR ",label," clear_samples=",clear,"/9")
				require(clear == 9, "passage floor is obscured or missing: " + label)
	print("DOORWAY_FAILURES ", failures)
	quit(1 if failures else 0)
