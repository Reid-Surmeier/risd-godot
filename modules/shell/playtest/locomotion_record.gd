## #259 locomotion recorder: real key events through the museum at a fixed frame rate, one
## cropped picture and one log row per frame. It judges nothing; visitor174_check.gd does.
## source ~/promo-lab/gpu-env.sh; DISPLAY=:99 godot --fixed-fps 60 --path . \
##   --script res://modules/shell/playtest/locomotion_record.gd \
##   --display-driver x11 --rendering-driver opengl3 -- --out-dir=res://build/locomotion-259
## Each sequence is a list of [frames, keys held]; a key that appears is pressed, one that
## goes is released. D walks the visitor across the Hall, in profile to the opening view.
extends SceneTree

const SIZE := Vector2i(960, 640)
const CROP := Vector2i(360, 360)
const W := KEY_W
const A := KEY_A
const D := KEY_D
const SHIFT := KEY_SHIFT
const SPACE := KEY_SPACE
const SEQUENCES := {
	"1-hold": [[180, [D]], [40, []]],
	"2-walk-shift-walk": [[70, [D]], [70, [D, SHIFT]], [70, [D]], [40, []]],
	"3-run-jump": [[60, [D, SHIFT]], [2, [D, SHIFT, SPACE]], [80, [D, SHIFT]], [40, []]],
	"4-idle-jump": [[20, []], [2, [SPACE]], [90, []]],
	"5-walk-jump-land": [[60, [D]], [2, [D, SPACE]], [100, [D]], [40, []]],
	"6-reversals":
	[
		[24, [D]], [24, [A]], [10, [D]], [10, [A]], [10, [D]], [30, [A]], [30, []],
		[50, [D, SHIFT]], [50, [A, SHIFT]], [14, [D, SHIFT]], [14, [A, SHIFT]], [50, []]
	],
	"7-taps":
	[[5, [D]], [6, []], [5, [D]], [6, []], [5, [D]], [6, []], [5, [A]], [6, []], [5, [D]], [40, []]],
	"8-doorway": [[200, [W]], [40, []]],
	"9-run-turn": [[50, [D, SHIFT]], [50, [W, SHIFT]], [50, [D, SHIFT]], [40, [D]], [40, []]],
}

var walk
var out := ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	out = "res://build/locomotion-259"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out-dir="):
			out = arg.get_slice("=", 1)
	root.size = SIZE
	walk = load("res://modules/shell/prototype/collection_reconstruction/main_build_walk.gd").new()
	walk.size = Vector2(SIZE)
	root.add_child(walk)
	for i in 240:
		await process_frame
	walk._new_action()
	for name in SEQUENCES:
		await _record(name)
	quit()


func _record(name: String) -> void:
	var dir: String = out.path_join(name)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var doorway: bool = name == "8-doorway"
	walk._new_action()
	walk._target = null
	walk._held.clear()
	walk._velocity = Vector3.ZERO
	walk._pos = Vector3(0, 0, -walk.L + 2.2) if doorway else Vector3(-4.2, 0, -4.0)
	walk._last_pos = walk._pos
	walk._space = "gallery"
	walk.view_mode = 0
	walk.view_yaw = 0.0
	walk._kid.position = walk._pos
	walk._kid.reset()
	# Stand facing the way the first key leads, so the recording starts without a turn.
	walk._motion_heading = Vector3(0, 0, -1) if doorway else Vector3(1, 0, 0)
	walk._kid.rotation.y = PI if doorway else PI / 2.0
	walk._update_camera(1.0)
	for settle in 30:
		await process_frame
	var kid = walk._kid
	var bones: int = kid.target.get_bone_count()
	var before_pose := []
	var before_pos: Vector3 = walk._pos
	var held := []
	var frame := 0
	var log := FileAccess.open(dir.path_join("log.csv"), FileAccess.WRITE)
	log.store_line(
		"frame,keys,clip,playing,pos_s,phase,speed_scale,gait,velocity,speed_mps,air,launched,"
		+ "landed,height,yaw,contacts,planted,foot_l,foot_r,pose_change"
	)
	for step in SEQUENCES[name]:
		for code in [W, A, D, SHIFT, SPACE]:
			if (code in step[1]) != (code in held):
				var event := InputEventKey.new()
				event.keycode = code
				event.physical_keycode = code
				event.pressed = code in step[1]
				Input.parse_input_event(event)
		held = step[1]
		for tick in step[0]:
			await RenderingServer.frame_post_draw
			# How far the whole skeleton turned since the last frame: a snap is a spike here.
			var change := 0.0
			var pose := []
			for bone in bones:
				pose.append(kid.target.get_bone_pose_rotation(bone))
				if not before_pose.is_empty():
					change += pose[bone].angle_to(before_pose[bone])
			before_pose = pose
			var player: AnimationPlayer = kid.player
			var length: float = maxf(player.current_animation_length, 0.0001)
			log.store_line(
				(
					"%d,%s,%s,%s,%.4f,%.4f,%.3f,%s,%.3f,%.3f,%.3f,%s,%.3f,%.3f,%.3f,%d,%s,%.3f,%.3f,%.3f"
					% [
						frame,
						"+".join(held.map(func(code): return OS.get_keycode_string(code))),
						kid._clip,
						player.current_animation,
						player.current_animation_position,
						player.current_animation_position / length,
						player.speed_scale,
						kid._kit.movement.gait,
						kid._kit.movement.velocity,
						walk._pos.distance_to(before_pos) * 60.0,
						kid._air,
						kid._launched,
						kid._landed,
						kid._height,
						kid.rotation.y,
						kid.contacts,
						"".join(kid.sole_support().map(func(down): return "1" if down else "0")),
						kid._feet[0].low,
						kid._feet[1].low,
						change
					]
				)
			)
			before_pos = walk._pos
			var image: Image = root.get_texture().get_image()
			var at: Vector2 = (
				walk._cam.unproject_position(kid.global_position + Vector3(0, 0.9, 0))
				* Vector2(SIZE)
				/ Vector2(walk._vp.size)
			)
			if frame == 0:
				image.save_jpg(dir.path_join("full.jpg"), 0.85)
			var corner := Vector2i(at) - CROP / 2
			corner = corner.clamp(Vector2i.ZERO, SIZE - CROP)
			image.get_region(Rect2i(corner, CROP)).save_jpg(dir.path_join("%04d.jpg" % frame), 0.85)
			frame += 1
	log.close()
	print("RECORDED ", name, " ", frame, " frames")
